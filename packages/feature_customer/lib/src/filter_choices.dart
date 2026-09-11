/// What every listing's filter sheet is built from.
///
/// The professionals directory, the catalogue and our work all offer the web's
/// marketplace filters — a section of choices with "any" first, rating floors,
/// and price bands — so the pieces live once, here, rather than three times.
library;

import 'dart:math' as math;

import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';

/// One filter section's choices. Exactly one is selected, `null` meaning any.
class FilterChoices<T> extends StatelessWidget {
  const FilterChoices({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<(T?, String)> options;
  final T? selected;
  final ValueChanged<T?> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Space.xxs,
      runSpacing: Space.xxs,
      children: [
        for (final (value, label) in options)
          ChoiceChip(
            label: Text(label),
            selected: selected == value,
            onSelected: (_) => onSelect(value),
          ),
      ],
    );
  }
}

/// `4` rather than `4.0`, as the web writes a rating floor.
String ratingFloor(double rating) =>
    rating == rating.roundToDouble() ? '${rating.round()}' : '$rating';

/// A price range, open on either side.
@immutable
class PriceBand {
  const PriceBand({this.min, this.max});

  final int? min;
  final int? max;

  @override
  bool operator ==(Object other) =>
      other is PriceBand && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(min, max);
}

/// Price bands drawn from the prices actually on offer.
///
/// A port of the web's `priceBuckets` in `apps/web/src/lib/filters.ts`, so both
/// offer the same bands for the same trade. Fixed bands cannot work across
/// trades: painting is priced per square foot in tens of rupees and furniture
/// per piece in lakhs, so "under ₹10,000" is every painting job and almost no
/// wardrobe. Quartiles of the trade's own prices give bands that each hold
/// something.
List<PriceBand> priceBands(Iterable<int> prices) {
  final sorted = prices.where((p) => p > 0).toList()..sort();
  if (sorted.length < 4) return const [];

  int at(double fraction) =>
      _nice(sorted[((sorted.length - 1) * fraction).floor()]);

  final cuts = {at(0.25), at(0.5), at(0.75)}.where((c) => c > 0).toList()
    ..sort();
  if (cuts.isEmpty) return const [];

  return [
    for (var i = 0; i < cuts.length; i++)
      PriceBand(min: i == 0 ? null : cuts[i - 1], max: cuts[i]),
    PriceBand(min: cuts.last),
  ];
}

/// Rounds to 1, 2 or 5 times a power of ten, so a bound reads like a price
/// somebody would say.
int _nice(int n) {
  if (n <= 0) return 0;
  var power = 1;
  while (power * 10 <= n) {
    power *= 10;
  }
  final f = n / power;
  final step = f < 1.5
      ? 1
      : f < 3.5
      ? 2
      : f < 7.5
      ? 5
      : 10;
  return math.max(step * power, 1);
}

/// "Under ₹5K", "₹5K – ₹20K", "₹20K and above".
String priceBandLabel(BuildContext context, PriceBand band) {
  final min = band.min;
  final max = band.max;
  if (min == null) {
    return context.t('Under {price}', {'price': Rupees(max ?? 0).short});
  }
  if (max == null) {
    return context.t('{price} and above', {'price': Rupees(min).short});
  }
  return context.t('{from} – {to}', {
    'from': Rupees(min).short,
    'to': Rupees(max).short,
  });
}
