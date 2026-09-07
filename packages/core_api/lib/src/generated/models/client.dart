// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'client.freezed.dart';
part 'client.g.dart';

@Freezed()
abstract class Client with _$Client {
  const factory Client({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String userId,
    required String? address,
    required String referralCode,
    required String? referredByUserId,
  }) = _Client;
  
  factory Client.fromJson(Map<String, Object?> json) => _$ClientFromJson(json);
}
