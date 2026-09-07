// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain.dart';

part 'domain_slice.freezed.dart';
part 'domain_slice.g.dart';

@Freezed()
abstract class DomainSlice with _$DomainSlice {
  const factory DomainSlice({
    required Domain domain,
    required int leads,
    required int quoted,
    required int won,
    required int revenue,
    required int commission,
    required int avgTicket,
    required num conversionPercent,
    required int vendors,
  }) = _DomainSlice;
  
  factory DomainSlice.fromJson(Map<String, Object?> json) => _$DomainSliceFromJson(json);
}
