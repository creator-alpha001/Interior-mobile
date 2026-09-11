// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'attention_entry.freezed.dart';
part 'attention_entry.g.dart';

@Freezed()
abstract class AttentionEntry with _$AttentionEntry {
  const factory AttentionEntry({
    required String? targetId,
    required String title,
    required String detail,
    required String? at,
  }) = _AttentionEntry;

  factory AttentionEntry.fromJson(Map<String, Object?> json) =>
      _$AttentionEntryFromJson(json);
}
