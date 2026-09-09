/// The cost estimator.
///
/// The one screen in the customer half that needs no network at all — see
/// `estimator.dart` for why the table is compiled in. That is the point of it:
/// somebody wondering on a train what a wardrobe costs gets an answer.
///
/// **It answers with a range and never with a figure.** The single most
/// important thing on this screen is the panel saying so. An estimate that
/// looks precise is worse than one that admits what it is — the customer
/// anchors on it, and then feels misled when three real quotes arrive against a
/// measured brief. So the bracket is the headline, the midpoint is a smaller
/// line beneath it, and what is *not* included is given as much room as what
/// is.
library;

import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';

import 'estimator.dart';

class EstimatorScreen extends StatefulWidget {
  const EstimatorScreen({super.key, this.onStart});

  /// Opens the requirement flow. Null when there is nowhere to send them.
  final VoidCallback? onStart;

  @override
  State<EstimatorScreen> createState() => _EstimatorScreenState();
}

class _EstimatorScreenState extends State<EstimatorScreen> {
  int _trade = 0;

  /// Kept per trade rather than reset on every switch.
  ///
  /// Somebody comparing a 3BHK interior against the painting for the same flat
  /// should not have to re-enter the flat each time they look across.
  late final _quantities = <String, int>{
    for (final config in estimatorConfigs)
      config.domainSlug: config.field.initial,
  };
  late final _tiers = <String, int>{
    for (final config in estimatorConfigs) config.domainSlug: 0,
  };

  @override
  Widget build(BuildContext context) {
    final config = estimatorConfigs[_trade];
    final quantity = _quantities[config.domainSlug]!;
    final tierIndex = _tiers[config.domainSlug]!;
    final tier = config.tiers[tierIndex];
    final result = estimate(config, quantity, tier);

    return Scaffold(
      appBar: AppBar(title: Text(context.t('Rough cost'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
          children: [
            const SizedBox(height: Space.md),
            Text(
              context.t('What might this cost?'),
              style: context.text.displayLarge,
            ),
            const SizedBox(height: Space.sm),
            Text(
              context.t(
                'A bracket to plan around, worked out from the same rates our '
                'professionals quote at. It needs no account and no phone '
                'number.',
              ),
              style: context.text.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: Space.lg),
            _TradeTabs(
              configs: estimatorConfigs,
              selected: _trade,
              onSelect: (i) => setState(() => _trade = i),
            ),

            const SizedBox(height: Space.md),
            Text(
              // What actually drives the price in this trade, said plainly.
              // Somebody who understands the basis argues with the number less.
              context.t(config.basis),
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),

            SectionHead(
              context.t(config.field.label),
              eyebrow: context.t('Drag to change'),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  // Indian grouping, so 1,000 sq.ft is not 1000.
                  groupedNumber(quantity),
                  style: context.text.headlineMedium,
                ),
                const SizedBox(width: Space.xxs),
                Text(
                  config.field.unit(context, quantity),
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Slider(
              value: quantity.toDouble(),
              min: config.field.min.toDouble(),
              max: config.field.max.toDouble(),
              divisions:
                  (config.field.max - config.field.min) ~/ config.field.step,
              label: '$quantity',
              onChanged: (value) => setState(
                () => _quantities[config.domainSlug] = value.round(),
              ),
            ),
            Text(
              context.t(config.field.hint),
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),

            SectionHead(
              context.t('Finish level'),
              eyebrow: context.t('Moves the figure most'),
            ),
            for (final (index, option) in config.tiers.indexed) ...[
              _TierOption(
                tier: option,
                selected: index == tierIndex,
                onTap: () => setState(() => _tiers[config.domainSlug] = index),
              ),
              const SizedBox(height: Space.xs),
            ],

            const SizedBox(height: Space.md),
            _Range(config: config, result: result),

            if (widget.onStart != null) ...[
              const SizedBox(height: Space.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: widget.onStart,
                  child: Text(context.t('Get a real quote, free')),
                ),
              ),
            ],
            const SizedBox(height: Space.xxxl),
          ],
        ),
      ),
    );
  }
}

/// The trade selector. Horizontal, because four is too many for a segmented
/// control at 360dp and a dropdown hides the choice.
class _TradeTabs extends StatelessWidget {
  const _TradeTabs({
    required this.configs,
    required this.selected,
    required this.onSelect,
  });

  final List<EstimatorConfig> configs;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TapTarget.minimum,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: configs.length,
        separatorBuilder: (context, index) => const SizedBox(width: Space.xs),
        itemBuilder: (context, i) {
          final active = i == selected;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelect(i),
              borderRadius: Radii.smallRadius,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: Space.md),
                decoration: BoxDecoration(
                  color: active
                      ? context.colors.primaryContainer
                      : context.colors.surfaceContainer,
                  borderRadius: Radii.smallRadius,
                  border: Border.all(
                    color: active
                        ? context.colors.primary
                        : context.palette.hairline,
                  ),
                ),
                child: Text(
                  // Trade names come from the same table as the rates. They are
                  // the API's words elsewhere in the app, so they are not copy.
                  configs[i].domainName,
                  style: context.text.titleMedium?.copyWith(
                    color: active
                        ? context.colors.onPrimaryContainer
                        : context.colors.onSurface,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TierOption extends StatelessWidget {
  const _TierOption({
    required this.tier,
    required this.selected,
    required this.onTap,
  });

  final EstimatorTier tier;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.panelRadius,
        child: Container(
          constraints: const BoxConstraints(minHeight: TapTarget.minimum),
          padding: const EdgeInsets.all(Space.cardPadding),
          decoration: BoxDecoration(
            color: selected
                ? context.colors.primaryContainer
                : context.colors.surfaceContainerLow,
            borderRadius: Radii.panelRadius,
            border: Border.all(
              color: selected
                  ? context.colors.primary
                  : context.palette.hairline,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.t(tier.label), style: context.text.titleLarge),
                    Text(
                      context.t(tier.hint),
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: TapTarget.glyph,
                color: selected
                    ? context.colors.primary
                    : context.colors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The answer, and the caveat that keeps it honest.
class _Range extends StatelessWidget {
  const _Range({required this.config, required this.result});

  final EstimatorConfig config;
  final EstimateResult result;

  @override
  Widget build(BuildContext context) {
    return InterioBeeCard(
      padding: const EdgeInsets.all(Space.cardPaddingWide),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('Rough range'),
            style: context.text.labelMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Space.xxs),

          /// The bracket is the headline. Abbreviated, because `₹5,80,000 –
          /// ₹8,70,000` wraps at 360dp and a wrapped price reads as two prices.
          Text(
            '${result.low.short} – ${result.high.short}',
            style: InterioBeeTextStyles.financialNum.copyWith(
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: Space.xxs),
          Text(
            // The midpoint in full, because `short` rounds and somebody
            // budgeting wants the actual number somewhere on the screen.
            context.t('Midpoint {amount}', {'amount': result.mid.formatted}),
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: Space.md),

          /// Terracotta, and it is the only thing on this screen that gets the
          /// colour: it is the sentence the customer must read.
          ActionRequired(
            title: context.t('This is a bracket, not a quote'),
            body: context.t(
              'Real prices come from a site visit. Three professionals will '
              'each measure the job and quote against the same brief — that is '
              'the number to decide on.',
            ),
          ),

          const SizedBox(height: Space.md),
          Text(
            context.t('Not included'),
            style: context.text.labelMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Space.xs),
          for (final caveat in config.caveats)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.xxs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.colors.outline,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: Space.xs),
                  Expanded(
                    child: Text(
                      context.t(caveat),
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
