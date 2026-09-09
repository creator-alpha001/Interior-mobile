/// The read cache, and the three deliberate exceptions to being online-first.
///
/// MOBILE.md §7.4: *"Read cache for catalogue, packages, professionals and the
/// current dashboard, so a cold launch on bad signal shows the last state with
/// an explicit 'as of' timestamp rather than a spinner."*
///
/// Two rules give this its shape, and both are about honesty rather than
/// performance:
///
///   **Only reads, and only some.** A cached list is a photograph of the past.
///   That is fine for a catalogue and useful for a dashboard; it is wrong for
///   anything the person is about to act on, so quotes, agreements and messages
///   are never served from here.
///
///   **Nothing that writes is ever queued.** §7.4 again: *"A quote submitted
///   from a basement two hours ago and delivered now is worse than a quote that
///   failed loudly at the time — versioning, ordering and the one-live-quote
///   constraint are all serialised server-side and cannot absorb a time
///   traveller."* The upload queue is the single exception, and it queues
///   *bytes*, not decisions.
///
/// The cache is a fallback, never a first choice: every request goes to the
/// network, and a cached body is returned only when the network fails.
library;

import 'dart:convert';
import 'dart:io';

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

/// Whether the app is currently showing something it fetched earlier.
///
/// A screen cannot easily see this for itself: the generated client returns a
/// typed model, not a `Response`, so the "as of" stamp never reaches the
/// widget. This carries it out of band, so a stale banner is drawn once at the
/// top of the app rather than reimplemented per screen.
///
/// A `Stream` rather than a `ChangeNotifier`, because `ChangeNotifier` lives in
/// `package:flutter/foundation.dart` and this package must not depend on
/// Flutter — that is what makes it generatable and testable without a widget
/// tree, and `contract_guarantees_test.dart` fails the build if the import
/// appears. The app bridges this to a notifier in one line.
class OfflineStatus {
  final _controller = StreamController<DateTime?>.broadcast();

  DateTime? _servingSince;

  /// When the data currently on screen was fetched, or null when live.
  DateTime? get servingSince => _servingSince;
  bool get isStale => _servingSince != null;

  /// Emits on every change: a timestamp while stale, null once live again.
  Stream<DateTime?> get changes => _controller.stream;

  void _servedFromCache(DateTime at) {
    if (_servingSince == at) return;
    _servingSince = at;
    _controller.add(at);
  }

  void _servedLive() {
    if (_servingSince == null) return;
    _servingSince = null;
    _controller.add(null);
  }

  Future<void> dispose() => _controller.close();
}

/// A response that came from disk, and when it was fetched.
@immutable
class CachedAt {
  const CachedAt(this.at);

  /// When the network last answered this request successfully.
  final DateTime at;

  static const key = 'interiobee.cachedAt';
}

/// Which paths may be served stale.
///
/// An allowlist rather than a denylist, because the failure mode of getting
/// this wrong is showing somebody a quote that has since been revised, or an
/// agreement they have already signed.
bool isCacheable(String path) {
  const readable = [
    '/domains',
    '/cities',
    '/products',
    '/categories',
    '/packages',
    '/professionals',
    '/portfolio',
    '/stats',
    '/banners',
    '/testimonials',
    '/catalogue/counts',
    // The vendor's own summary. Stale counters with an "as of" beat a spinner
    // on a site with no signal, and nothing here is acted on directly.
    '/vendor/dashboard',
  ];

  return readable.any(
    (prefix) => path == prefix || path.startsWith('$prefix/'),
  );
}

/// Serves the last good body when the network cannot be reached.
class OfflineCacheInterceptor extends Interceptor {
  OfflineCacheInterceptor(this._directory, {OfflineStatus? status})
    : status = status ?? OfflineStatus();

  final Directory _directory;

  /// Listened to by the shell, so the "as of" line is drawn in one place.
  final OfflineStatus status;

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final path = response.requestOptions.path;

    if (response.requestOptions.method == 'GET' &&
        response.statusCode == 200 &&
        isCacheable(path)) {
      _write(path, response.data);
      // A live answer clears the banner. Only a real network response does —
      // a resolved-from-cache one goes through `onError`.
      status._servedLive();
    }

    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;

    /// Only a *network* failure falls back.
    ///
    /// A 404 or a 422 is the server's considered answer and replacing it with
    /// yesterday's body would be a lie. A 500 is arguably serveable, but it
    /// also means something is wrong that the person should find out about.
    final isOffline =
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.unknown && err.response == null;

    if (options.method != 'GET' || !isOffline || !isCacheable(options.path)) {
      return handler.next(err);
    }

    final cached = await _read(options.path);
    if (cached == null) return handler.next(err);

    handler.resolve(
      Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
        data: cached.body,
        // How a screen knows to draw the "as of" line. Without this the person
        // cannot tell a stale list from a live one, which is worse than the
        // spinner it replaced.
        extra: {CachedAt.key: CachedAt(cached.at)},
      ),
    );

    status._servedFromCache(cached.at);
  }

  File _fileFor(String path) {
    final safe = base64Url.encode(utf8.encode(path));
    return File('${_directory.path}/cache-$safe.json');
  }

  void _write(String path, dynamic body) {
    try {
      final file = _fileFor(path)..parent.createSync(recursive: true);
      file.writeAsStringSync(
        jsonEncode({'at': DateTime.now().toIso8601String(), 'body': body}),
      );
    } on Object {
      // A full disk must not fail a request that already succeeded.
    }
  }

  Future<({DateTime at, dynamic body})?> _read(String path) async {
    try {
      final file = _fileFor(path);
      if (!file.existsSync()) return null;

      final raw = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final at = DateTime.tryParse(raw['at'] as String? ?? '');
      if (at == null) return null;

      return (at: at, body: raw['body']);
    } on Object {
      return null;
    }
  }

  /// Drops everything. Called on sign-out: a cached vendor dashboard is one
  /// person's pipeline, and the next person to sign in on this handset must
  /// not see it.
  void clear() {
    status._servedLive();
    if (!_directory.existsSync()) return;
    for (final entity in _directory.listSync()) {
      final name = entity.uri.pathSegments.last;
      if (entity is File && name.startsWith('cache-')) {
        try {
          entity.deleteSync();
        } on Object {
          // Best effort.
        }
      }
    }
  }
}

/// Reads the "as of" stamp off a response, when it came from disk.
extension CachedResponse on Response<dynamic> {
  DateTime? get servedFromCacheAt => (extra[CachedAt.key] as CachedAt?)?.at;
}
