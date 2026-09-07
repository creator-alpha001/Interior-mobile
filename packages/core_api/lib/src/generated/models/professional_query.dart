// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'professional_query.freezed.dart';
part 'professional_query.g.dart';

@Freezed()
abstract class ProfessionalQuery with _$ProfessionalQuery {
  const factory ProfessionalQuery({
    String? cursor,
    String? domain,
    String? city,
    String? search,
    dynamic verifiedOnly,
    @Default(24)
    int limit,
  }) = _ProfessionalQuery;
  
  factory ProfessionalQuery.fromJson(Map<String, Object?> json) => _$ProfessionalQueryFromJson(json);
}
