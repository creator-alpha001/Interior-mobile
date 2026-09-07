// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain.dart';

part 'domain_count.freezed.dart';
part 'domain_count.g.dart';

@Freezed()
abstract class DomainCount with _$DomainCount {
  const factory DomainCount({
    required Domain domain,
    required int count,
  }) = _DomainCount;
  
  factory DomainCount.fromJson(Map<String, Object?> json) => _$DomainCountFromJson(json);
}
