// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'message.dart';
import 'professional_summary.dart';

part 'relay_thread.freezed.dart';
part 'relay_thread.g.dart';

@Freezed()
abstract class RelayThread with _$RelayThread {
  const factory RelayThread({
    required ProfessionalSummary professional,
    required List<Message> messages,
    required bool awaitingReply,
  }) = _RelayThread;
  
  factory RelayThread.fromJson(Map<String, Object?> json) => _$RelayThreadFromJson(json);
}
