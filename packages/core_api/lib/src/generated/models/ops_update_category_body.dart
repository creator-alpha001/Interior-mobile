// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ops_update_category_body.freezed.dart';
part 'ops_update_category_body.g.dart';

@Freezed()
abstract class OpsUpdateCategoryBody with _$OpsUpdateCategoryBody {
  const factory OpsUpdateCategoryBody({
    @Default('') String description,
    String? domainId,
    String? name,
    String? imageMediaId,
    String? parentId,
    int? sortOrder,
    bool? isActive,
  }) = _OpsUpdateCategoryBody;

  factory OpsUpdateCategoryBody.fromJson(Map<String, Object?> json) =>
      _$OpsUpdateCategoryBodyFromJson(json);
}
