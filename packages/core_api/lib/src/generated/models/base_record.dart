// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_record.freezed.dart';
part 'base_record.g.dart';

@Freezed()
abstract class BaseRecord with _$BaseRecord {
  const factory BaseRecord({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
  }) = _BaseRecord;
  
  factory BaseRecord.fromJson(Map<String, Object?> json) => _$BaseRecordFromJson(json);
}
