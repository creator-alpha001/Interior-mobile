// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ops_create_category_body.freezed.dart';
part 'ops_create_category_body.g.dart';

@Freezed()
abstract class OpsCreateCategoryBody with _$OpsCreateCategoryBody {
  const factory OpsCreateCategoryBody({
    required String domainId,
    required String name,
    String? imageMediaId,
    String? parentId,
    int? sortOrder,
    @Default('') String description,
  }) = _OpsCreateCategoryBody;

  factory OpsCreateCategoryBody.fromJson(Map<String, Object?> json) =>
      _$OpsCreateCategoryBodyFromJson(json);
}
