// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'attention_entry.dart';
import 'attention_key.dart';

part 'attention_card.freezed.dart';
part 'attention_card.g.dart';

@Freezed()
abstract class AttentionCard with _$AttentionCard {
  const factory AttentionCard({
    required AttentionKey key,
    required int count,
    required String? note,
    required bool failed,
    required List<AttentionEntry> entries,
  }) = _AttentionCard;

  factory AttentionCard.fromJson(Map<String, Object?> json) =>
      _$AttentionCardFromJson(json);
}
