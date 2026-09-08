// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain.dart';
import 'message.dart';
import 'relay_thread.dart';

part 'relay_view.freezed.dart';
part 'relay_view.g.dart';

@Freezed()
abstract class RelayView with _$RelayView {
  const factory RelayView({
    required String leadDomainId,
    required Domain domain,
    required String clientName,
    required List<Message> clientThread,
    required bool clientAwaitingReply,
    required List<RelayThread> vendorThreads,
  }) = _RelayView;

  factory RelayView.fromJson(Map<String, Object?> json) =>
      _$RelayViewFromJson(json);
}
