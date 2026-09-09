/// The rough cost calculator.
///
/// **Why the table is here and not behind an endpoint.** The maths is four
/// numbers and a multiplier, and it has to respond to a dragging thumb. A
/// request per frame is absurd, a request per release is a stale bracket, and
/// either way an estimator that cannot answer without a network is useless on
/// the train where somebody is actually wondering what a wardrobe costs.
///
/// The cost of that choice is real and worth naming: these rates now live in
/// two places, here and in `packages/data/src/estimator.ts` on the web, and
/// nothing but a person keeps them in step. When the rates next move, moving
/// them into the API and shipping the *config* rather than the *result* is the
/// fix — the maths can stay client-side, because it is the rates that go out of
/// date, not the arithmetic.
///
/// Every result is a range, never a figure. An estimate that looks precise is
/// worse than one that admits what it is: the customer anchors on it and then
/// feels misled when the real quote lands.
library;

import 'package:flutter/widgets.dart';

import 'package:interiobee_design/interiobee_design.dart';

enum EstimatorInputKind { rooms, area, pieces, runningFt }

@immutable
class EstimatorField {
  const EstimatorField({
    required this.label,
    required this.hint,
    required this.kind,
    required this.min,
    required this.max,
    required this.step,
    required this.initial,
  });

  final String label;
  final String hint;
  final EstimatorInputKind kind;
  final int min;
  final int max;
  final int step;
  final int initial;

  /// The unit, which is a word rather than a symbol and so has to translate.
  String unit(BuildContext context, int quantity) => switch (kind) {
    EstimatorInputKind.rooms => context.l10n.plural(
      quantity,
      'bedroom',
      'bedrooms',
    ),
    EstimatorInputKind.area => context.t('sq.ft carpet area'),
    EstimatorInputKind.pieces => context.l10n.plural(
      quantity,
      'piece',
      'pieces',
    ),
    EstimatorInputKind.runningFt => context.t('running ft'),
  };
}

@immutable
class EstimatorTier {
  const EstimatorTier({
    required this.label,
    required this.hint,
    required this.multiplier,
  });

  final String label;
  final String hint;
  final double multiplier;
}

@immutable
class EstimatorConfig {
  const EstimatorConfig({
    required this.domainSlug,
    required this.domainName,
    required this.basis,
    required this.field,
    required this.tiers,
    required this.baseRate,
    required this.fixed,
    required this.spread,
    required this.caveats,
  });

  final String domainSlug;
  final String domainName;

  /// Plain-English statement of what drives the price in this trade.
  final String basis;

  final EstimatorField field;
  final List<EstimatorTier> tiers;

  /// Rate per unit at the baseline tier, before the tier multiplier.
  final double baseRate;

  /// Added regardless of size — mobilisation, setup, supervision.
  final int fixed;

  /// How wide the range sits either side of the midpoint, as a fraction.
  final double spread;

  final List<String> caveats;
}

@immutable
class EstimateResult {
  const EstimateResult({
    required this.low,
    required this.mid,
    required this.high,
  });

  final Rupees low;
  final Rupees mid;
  final Rupees high;
}

/// The same arithmetic as `estimate()` on the web, rounded the same way.
///
/// Rounding to the nearest thousand is not cosmetic. `₹2,84,720` reads as a
/// figure somebody calculated; `₹2,85,000` reads as the bracket it is.
EstimateResult estimate(
  EstimatorConfig config,
  int quantity,
  EstimatorTier tier,
) {
  final raw = config.baseRate * quantity * tier.multiplier + config.fixed;
  final mid = (raw / 1000).round() * 1000;
  return EstimateResult(
    low: Rupees((mid * (1 - config.spread) / 1000).round() * 1000),
    mid: Rupees(mid),
    high: Rupees((mid * (1 + config.spread) / 1000).round() * 1000),
  );
}

/// The four trades, in the order the home screen lists them.
///
/// Ported from the web's table. The English here is a key into the Hindi
/// tables like any other copy — the rates are data, the words around them are
/// not.
const estimatorConfigs = <EstimatorConfig>[
  EstimatorConfig(
    domainSlug: 'interior-design',
    domainName: 'Interior Design',
    basis:
        'Turnkey interiors are quoted per project against a BOQ. This estimate '
        'is anchored on home size and the finish level you choose.',
    field: EstimatorField(
      label: 'Bedrooms',
      hint: '1BHK through 5BHK or villa',
      kind: EstimatorInputKind.rooms,
      min: 1,
      max: 5,
      step: 1,
      initial: 2,
    ),
    tiers: [
      EstimatorTier(
        label: 'Essential',
        hint: 'Kitchen, wardrobes, TV unit',
        multiplier: 1,
      ),
      EstimatorTier(
        label: 'Premium',
        hint: 'Adds ceiling, lighting, panelling',
        multiplier: 1.7,
      ),
      EstimatorTier(
        label: 'Luxury',
        hint: 'Bespoke detailing throughout',
        multiplier: 2.8,
      ),
    ],
    baseRate: 290000,
    fixed: 120000,
    spread: 0.2,
    caveats: [
      'Excludes civil, plumbing and electrical rework.',
      'Excludes appliances and loose furniture.',
      'A real figure comes from the BOQ after the site visit — this is only a '
          'bracket.',
    ],
  ),
  EstimatorConfig(
    domainSlug: 'furniture',
    domainName: 'Furniture Work',
    basis:
        'Furniture is priced per piece, or per sq.ft of shutter area for '
        'storage. This estimates a typical mix of wardrobe, bed and unit work.',
    field: EstimatorField(
      label: 'Number of pieces',
      hint: 'Wardrobes, beds, units — count each item',
      kind: EstimatorInputKind.pieces,
      min: 1,
      max: 15,
      step: 1,
      initial: 3,
    ),
    tiers: [
      EstimatorTier(
        label: 'Laminate',
        hint: 'BWR ply, laminate finish',
        multiplier: 1,
      ),
      EstimatorTier(
        label: 'Membrane / veneer',
        hint: 'Seamless or natural finish',
        multiplier: 1.35,
      ),
      EstimatorTier(
        label: 'Acrylic / PU',
        hint: 'Premium finish, soft-close throughout',
        multiplier: 1.7,
      ),
    ],
    baseRate: 38000,
    fixed: 6000,
    spread: 0.25,
    caveats: [
      'Assumes standard sizes. Floor-to-ceiling and loft work costs more.',
      'Excludes loose furniture, mattresses and soft furnishing.',
      'If you supply the board yourself, expect roughly 30% less.',
    ],
  ),
  EstimatorConfig(
    domainSlug: 'fabrication',
    domainName: 'Fabrication',
    basis:
        'Fabrication is priced per running foot or per sq.ft of fabricated '
        'area, and the metal you choose moves the figure more than anything '
        'else.',
    field: EstimatorField(
      label: 'Approximate running feet',
      hint: 'Total of gates, grills and railings',
      kind: EstimatorInputKind.runningFt,
      min: 5,
      max: 300,
      step: 5,
      initial: 60,
    ),
    tiers: [
      EstimatorTier(
        label: 'MS, enamel',
        hint: 'Mild steel, painted on site',
        multiplier: 1,
      ),
      EstimatorTier(
        label: 'MS, powder coated',
        hint: 'Workshop finish, lasts far longer',
        multiplier: 1.2,
      ),
      EstimatorTier(
        label: 'Stainless 304',
        hint: 'No rust, no repainting',
        multiplier: 2.6,
      ),
    ],
    baseRate: 620,
    fixed: 5000,
    spread: 0.22,
    caveats: [
      'Design complexity matters — laser-cut panels and glass infill add '
          'substantially.',
      'Excludes motorisation, civil work and site preparation.',
      'Site measurement will change the running feet, usually upward.',
    ],
  ),
  EstimatorConfig(
    domainSlug: 'painting',
    domainName: 'Painting',
    basis:
        'Painting is priced on painted area. A 1000 sq.ft carpet-area flat has '
        'roughly 3,200 sq.ft of wall and ceiling to paint.',
    field: EstimatorField(
      label: 'Carpet area',
      hint: 'We convert this to painted area at roughly 3.2×',
      kind: EstimatorInputKind.area,
      min: 300,
      max: 4000,
      step: 50,
      initial: 1000,
    ),
    tiers: [
      EstimatorTier(
        label: 'Repaint',
        hint: 'Walls already puttied, minor repair',
        multiplier: 1,
      ),
      EstimatorTier(
        label: 'Repaint + full putty',
        hint: 'Two coats putty and sanding',
        multiplier: 1.55,
      ),
      EstimatorTier(
        label: 'Fresh painting',
        hint: 'New plaster, full system',
        multiplier: 1.9,
      ),
    ],
    // 24 per sq.ft of painted area, at 3.2x carpet area.
    baseRate: 24 * 3.2,
    fixed: 4000,
    spread: 0.18,
    caveats: [
      'Assumes premium emulsion. A luxury product line adds roughly 40%.',
      'Excludes exterior walls, texture finishes and waterproofing.',
      'Excludes wood and metal polishing.',
    ],
  ),
];
