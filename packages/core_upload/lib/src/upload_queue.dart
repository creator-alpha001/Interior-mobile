/// Uploads that survive the app closing.
///
/// MOBILE.md §7.1 names three things the mobile client owes that the web did
/// not, and this file is all three:
///
///   **Compress before uploading.** A modern phone camera produces 4–8MB per
///   frame. Target the long edge at 2048px and JPEG quality 80 — roughly 400KB,
///   ample for proof — and show the saving, because vendors watch their data.
///
///   **A queue that survives the app closing.** *"A stage submission that dies
///   in a lift and takes eight photos with it is the failure that loses vendor
///   trust fastest."* So the queue is written to disk, resumed on next launch,
///   and retried with backoff.
///
///   **Client-side limits, and no faith in them.** The backend enforces size
///   and type again. The check here is a courtesy — it saves a round trip — not
///   a control.
///
/// The bytes never pass through the API: `POST /uploads/tickets` returns a
/// presigned URL and the client PUTs straight at storage. That matters far more
/// on mobile than it did on the web, since the vendor uploading eight site
/// photos is on mobile data in somebody's basement.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

/// What the compressor aims for. Generous enough to read a joint in a
/// photograph, small enough not to cost a vendor their data plan.
const kMaxEdge = 2048;
const kJpegQuality = 80;

/// Mirrors `packages/data/src/uploads.ts`. The server checks again.
const kMaxBytes = 10 * 1024 * 1024;

enum UploadState { pending, uploading, done, failed }

/// One file on its way to storage.
@immutable
class QueuedUpload {
  const QueuedUpload({
    required this.id,
    required this.localPath,
    required this.purpose,
    required this.contentType,
    this.assetId,
    this.state = UploadState.pending,
    this.attempts = 0,
    this.error,
    this.originalBytes,
    this.compressedBytes,
  });

  final String id;
  final String localPath;
  final UploadPurpose purpose;
  final String contentType;

  /// Set once storage has the bytes. This is what a form submits.
  final String? assetId;

  final UploadState state;
  final int attempts;
  final String? error;

  /// Kept so the UI can show the saving, per MOBILE.md.
  final int? originalBytes;
  final int? compressedBytes;

  QueuedUpload copyWith({
    String? assetId,
    UploadState? state,
    int? attempts,
    String? error,
    int? originalBytes,
    int? compressedBytes,
    bool clearError = false,
  }) {
    return QueuedUpload(
      id: id,
      localPath: localPath,
      purpose: purpose,
      contentType: contentType,
      assetId: assetId ?? this.assetId,
      state: state ?? this.state,
      attempts: attempts ?? this.attempts,
      error: clearError ? null : (error ?? this.error),
      originalBytes: originalBytes ?? this.originalBytes,
      compressedBytes: compressedBytes ?? this.compressedBytes,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'localPath': localPath,
    'purpose': purpose.name,
    'contentType': contentType,
    'assetId': assetId,
    'state': state.name,
    'attempts': attempts,
    'originalBytes': originalBytes,
    'compressedBytes': compressedBytes,
  };

  factory QueuedUpload.fromJson(Map<String, Object?> json) => QueuedUpload(
    id: json['id']! as String,
    localPath: json['localPath']! as String,
    purpose: UploadPurpose.values.firstWhere(
      (p) => p.name == json['purpose'],
      orElse: () => UploadPurpose.milestoneProof,
    ),
    contentType: json['contentType']! as String,
    assetId: json['assetId'] as String?,
    // Anything that was mid-flight when the app died is pending again.
    // The PUT is idempotent on the storage key, so re-sending is safe.
    state: switch (json['state']) {
      'done' => UploadState.done,
      'failed' => UploadState.failed,
      _ => UploadState.pending,
    },
    attempts: (json['attempts'] as num?)?.toInt() ?? 0,
    originalBytes: (json['originalBytes'] as num?)?.toInt(),
    compressedBytes: (json['compressedBytes'] as num?)?.toInt(),
  );
}

/// Compresses, tickets and PUTs — and remembers where it got to.
class UploadQueue extends ChangeNotifier {
  UploadQueue({
    required InterioBeeApi api,
    Directory? storageDirectory,
    ImageCompressor? compressor,
  }) : _api = api,
       _directory = storageDirectory,
       _compress = compressor ?? const FlutterImageCompressor();

  final InterioBeeApi _api;
  final ImageCompressor _compress;
  Directory? _directory;

  final _items = <String, QueuedUpload>{};
  List<QueuedUpload> get items => _items.values.toList(growable: false);

  bool _draining = false;

  /// Everything that finished, in the order it was added.
  List<String> get completedAssetIds =>
      items.where((i) => i.assetId != null).map((i) => i.assetId!).toList();

  bool get isSettled => items.every(
    (i) => i.state == UploadState.done || i.state == UploadState.failed,
  );

  /// Reads back whatever was in flight when the app last closed.
  ///
  /// `_stateFile()` is inside the `try`, and that placement is the point. It
  /// used to sit outside, so the guard caught a corrupt file and missed the
  /// likelier failure — no support directory at all, which throws from
  /// `getApplicationSupportDirectory()` and escaped as an unhandled error from
  /// an unawaited `..restore()` in `main`.
  Future<void> restore() async {
    try {
      final file = await _stateFile();
      if (!file.existsSync()) return;

      final raw = jsonDecode(file.readAsStringSync()) as List<dynamic>;
      for (final entry in raw) {
        final item = QueuedUpload.fromJson(entry as Map<String, Object?>);
        // A file the OS has since cleaned out of the camera cache cannot be
        // resumed. Drop it rather than retrying forever.
        if (item.state != UploadState.done &&
            !File(item.localPath).existsSync()) {
          continue;
        }
        _items[item.id] = item;
      }
      notifyListeners();
    } on Object catch (error) {
      debugPrint('upload queue unreadable, starting empty: $error');
    }
  }

  /// Writes the queue to disk, and does not throw if it cannot.
  ///
  /// Losing the on-disk copy costs the promise that a submission survives the
  /// process being killed. Throwing from here would cost the upload itself,
  /// which is in memory and working — so a failure degrades the guarantee
  /// rather than the operation, and says so.
  Future<void> _persist() async {
    try {
      final file = await _stateFile();
      await file.parent.create(recursive: true);
      await file.writeAsString(
        jsonEncode(items.map((i) => i.toJson()).toList()),
      );
    } on Object catch (error) {
      debugPrint(
        'upload queue not persisted — it will not survive a kill: $error',
      );
    }
  }

  Future<File> _stateFile() async {
    _directory ??= await getApplicationSupportDirectory();
    return File('${_directory!.path}/upload-queue.json');
  }

  /// Adds a file and starts working through the queue.
  Future<QueuedUpload> add({
    required String localPath,
    required UploadPurpose purpose,
    String contentType = 'image/jpeg',
  }) async {
    final id = '${DateTime.now().microsecondsSinceEpoch}-${_items.length}';
    final item = QueuedUpload(
      id: id,
      localPath: localPath,
      purpose: purpose,
      contentType: contentType,
      originalBytes: File(localPath).existsSync()
          ? File(localPath).lengthSync()
          : null,
    );

    _items[id] = item;
    notifyListeners();
    await _persist();

    unawaited(drain());
    return item;
  }

  void remove(String id) {
    _items.remove(id);
    notifyListeners();
    unawaited(_persist());
  }

  /// Works through everything pending. Safe to call repeatedly.
  Future<void> drain() async {
    if (_draining) return;
    _draining = true;

    try {
      for (final item in items) {
        if (item.state == UploadState.done) continue;
        if (item.state == UploadState.failed && item.attempts >= 3) continue;
        await _send(item);
      }
    } finally {
      _draining = false;
      await _persist();
    }
  }

  /// Retries one that gave up.
  Future<void> retry(String id) async {
    final item = _items[id];
    if (item == null) return;
    _items[id] = item.copyWith(
      state: UploadState.pending,
      attempts: 0,
      clearError: true,
    );
    notifyListeners();
    await drain();
  }

  Future<void> _send(QueuedUpload item) async {
    _update(item.copyWith(state: UploadState.uploading, clearError: true));

    try {
      final file = File(item.localPath);
      if (!file.existsSync()) {
        throw const FileSystemException(
          'The photograph is no longer on the device',
        );
      }

      final bytes = await _compress.compress(item.localPath);

      // A courtesy check, not a control. The server enforces this again, and
      // the presign refuses a mismatched size.
      if (bytes.length > kMaxBytes) {
        throw const FileSystemException('That photograph is too large to send');
      }

      final ticket = await _api.public
          .createUploadTicket(
            body: CreateUploadTicketBody(
              purpose: item.purpose,
              fileName: item.localPath.split(Platform.pathSeparator).last,
              contentType: item.contentType,
              sizeBytes: bytes.length,
            ),
          )
          .orThrow();

      // Straight at storage. This request deliberately does not carry the
      // session — it is presigned, and the interceptors' Authorization header
      // would be rejected by R2.
      await Dio().putUri<void>(
        Uri.parse(ticket.uploadUrl),
        data: Stream.fromIterable([bytes]),
        options: Options(
          headers: {
            ...ticket.headers,
            Headers.contentLengthHeader: bytes.length,
          },
          contentType: item.contentType,
        ),
      );

      _update(
        item.copyWith(
          state: UploadState.done,
          assetId: ticket.assetId,
          compressedBytes: bytes.length,
          attempts: item.attempts + 1,
        ),
      );
    } on Object catch (error) {
      _update(
        item.copyWith(
          state: UploadState.failed,
          attempts: item.attempts + 1,
          error: error is ApiException ? error.message : '$error',
        ),
      );

      // Backoff, so a basement with one bar is not hammered.
      if (item.attempts < 2) {
        await Future<void>.delayed(Duration(seconds: 2 * (item.attempts + 1)));
      }
    }
  }

  void _update(QueuedUpload item) {
    _items[item.id] = item;
    notifyListeners();
  }
}

/// The compressor, behind an interface so the queue is testable without a
/// platform channel.
abstract interface class ImageCompressor {
  Future<Uint8List> compress(String path);
}

class FlutterImageCompressor implements ImageCompressor {
  const FlutterImageCompressor();

  @override
  Future<Uint8List> compress(String path) async {
    final result = await FlutterImageCompress.compressWithFile(
      path,
      minWidth: kMaxEdge,
      minHeight: kMaxEdge,
      quality: kJpegQuality,
      // Photographs taken sideways are the norm on a site. Without this the
      // proof arrives rotated and ops cannot read it.
      keepExif: true,
    );

    // A HEIC the plugin cannot read, or a file that is not an image. Send the
    // original and let the server decide.
    return result ?? await File(path).readAsBytes();
  }
}
