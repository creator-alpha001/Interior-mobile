// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'city_slice.freezed.dart';
part 'city_slice.g.dart';

@Freezed()
abstract class CitySlice with _$CitySlice {
  const factory CitySlice({
    required String cityName,
    required num leads,
    required num revenue,
  }) = _CitySlice;
  
  factory CitySlice.fromJson(Map<String, Object?> json) => _$CitySliceFromJson(json);
}
