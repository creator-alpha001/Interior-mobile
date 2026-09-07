// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'catalogue_selection.dart';
import 'material_source.dart';
import 'site_accessibility_tag.dart';
import 'urgency.dart';

part 'create_requirement_body.freezed.dart';
part 'create_requirement_body.g.dart';

@Freezed()
abstract class CreateRequirementBody with _$CreateRequirementBody {
  const factory CreateRequirementBody({
    required String cityId,
    required List<String> domainIds,
    required String description,
    required Urgency urgency,
    required Map<String, MaterialSource> materialSource,
    List<SiteAccessibilityTag>? siteAccessibilityTags,
    int? budgetMin,
    int? budgetMax,
    String? preferredProfessionalId,
    List<String>? photoIds,
    List<CatalogueSelection>? catalogueItems,
  }) = _CreateRequirementBody;
  
  factory CreateRequirementBody.fromJson(Map<String, Object?> json) => _$CreateRequirementBodyFromJson(json);
}
