/// The catalogue's price bands, which must agree with the web's.
///
/// `priceBands` is a port of `priceBuckets` in `apps/web/src/lib/filters.ts`.
/// If the two drift, the same trade offers different bands in the app and on
/// the site, and a customer comparing them reasonably wonders which is lying.
library;

import 'package:interiobee_feature_customer/src/filter_choices.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cuts at rounded quartiles, open at both ends', () {
    final bands = priceBands([
      800,
      1200,
      2500,
      4000,
      9000,
      15000,
      30000,
      60000,
    ]);

    expect(bands, const [
      PriceBand(max: 1000),
      PriceBand(min: 1000, max: 5000),
      PriceBand(min: 5000, max: 20000),
      PriceBand(min: 20000),
    ]);
  });

  test('fewer than four prices offers no bands rather than silly ones', () {
    expect(priceBands([1000, 2000, 3000]), isEmpty);
  });

  test('ignores prices of zero, which are unpriced rather than free', () {
    expect(priceBands([0, 0, 0, 1000, 2000, 3000]), isEmpty);
  });

  test('collapses cuts that round to the same figure', () {
    expect(priceBands([1000, 1000, 1000, 1000]), const [
      PriceBand(max: 1000),
      PriceBand(min: 1000),
    ]);
  });

  test('rating floors are written as the web writes them', () {
    expect(ratingFloor(4), '4');
    expect(ratingFloor(4.5), '4.5');
  });
}
