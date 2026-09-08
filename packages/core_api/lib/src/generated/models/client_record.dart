// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'client.dart';
import 'user.dart';

part 'client_record.freezed.dart';
part 'client_record.g.dart';

@Freezed()
abstract class ClientRecord with _$ClientRecord {
  const factory ClientRecord({required Client client, required User user}) =
      _ClientRecord;

  factory ClientRecord.fromJson(Map<String, Object?> json) =>
      _$ClientRecordFromJson(json);
}
