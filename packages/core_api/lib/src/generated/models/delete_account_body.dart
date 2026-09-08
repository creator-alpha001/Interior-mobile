// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'delete_account_body_confirm.dart';

part 'delete_account_body.freezed.dart';
part 'delete_account_body.g.dart';

@Freezed()
abstract class DeleteAccountBody with _$DeleteAccountBody {
  const factory DeleteAccountBody({
    required DeleteAccountBodyConfirm confirm,
    String? reason,
  }) = _DeleteAccountBody;

  factory DeleteAccountBody.fromJson(Map<String, Object?> json) =>
      _$DeleteAccountBodyFromJson(json);
}
