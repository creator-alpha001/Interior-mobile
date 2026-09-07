// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_closure.freezed.dart';
part 'account_closure.g.dart';

@Freezed()
abstract class AccountClosure with _$AccountClosure {
  const factory AccountClosure({
    required String closedAt,
    required List<String> retained,
  }) = _AccountClosure;
  
  factory AccountClosure.fromJson(Map<String, Object?> json) => _$AccountClosureFromJson(json);
}
