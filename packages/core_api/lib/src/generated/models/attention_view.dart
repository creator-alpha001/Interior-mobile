// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'attention_card.dart';

part 'attention_view.freezed.dart';
part 'attention_view.g.dart';

@Freezed()
abstract class AttentionView with _$AttentionView {
  const factory AttentionView({required List<AttentionCard> cards}) =
      _AttentionView;

  factory AttentionView.fromJson(Map<String, Object?> json) =>
      _$AttentionViewFromJson(json);
}
