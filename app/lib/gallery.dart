/// The component gallery.
///
/// M8's "done when" in `MOBILE.md` §9: *the component gallery renders every
/// state, and goldens pass*. That is not busywork — the design system is as
/// much the deliverable as the features, and an untested design system drifts
/// within a month. This screen is what the golden tests photograph.
///
/// It is also the honest check on the colour rule in DESIGN.md §1.4: every
/// state a status pill can take is on screen at once, so "sage is never
/// decorative" is something you can look at rather than something written down.
library;

import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
          children: const [
            _Masthead(),
            _TypeSpecimen(),
            _StatusPills(),
            _Surfaces(),
            _TheActionPanel(),
            _Money(),
            _Controls(),
            _CodeInput(),
            SizedBox(height: Space.xxxl),
          ],
        ),
      ),
    );
  }
}

class _Masthead extends StatelessWidget {
  const _Masthead();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Space.xl, bottom: Space.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COMPONENT GALLERY',
            style: AanganTextStyles.eyebrow
                .copyWith(color: context.colors.onSurfaceVariant),
            semanticsLabel: 'Component gallery',
          ),
          const SizedBox(height: Space.xs),
          Text('Warm Architectural\nMinimalism', style: context.text.displayLarge),
          const SizedBox(height: Space.sm),
          Text(
            'Every component, in every state. If a padding changes, this screen '
            'changes, and the golden diff says so.',
            style: context.text.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeSpecimen extends StatelessWidget {
  const _TypeSpecimen();

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHead('Typography', eyebrow: 'Two families'),
        AanganCard(
          padding: const EdgeInsets.all(Space.cardPaddingWide),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Display, Newsreader', style: text.displayLarge),
              const SizedBox(height: Space.sm),
              Text('Headline large', style: text.headlineLarge),
              const SizedBox(height: Space.xxs),
              Text('Section head, headline medium', style: text.headlineMedium),
              const SizedBox(height: Space.xxs),
              Text('Card title, headline small', style: text.headlineSmall),
              const SizedBox(height: Space.md),
              const AanganDivider(inset: 0),
              const SizedBox(height: Space.md),
              Text('List row title — Manrope 18/600', style: text.titleLarge),
              const SizedBox(height: Space.xxs),
              Text(
                'Body large, for long prose. Briefs, terms and the blog reader '
                'set at sixteen on twenty-six.',
                style: text.bodyLarge,
              ),
              const SizedBox(height: Space.xxs),
              Text('Body medium — the default.', style: text.bodyMedium),
              const SizedBox(height: Space.xxs),
              Text('Body small, meta and timestamps.', style: text.bodySmall),
              const SizedBox(height: Space.sm),
              Text('FIELD LABEL', style: text.labelMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPills extends StatelessWidget {
  const _StatusPills();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHead('Status', eyebrow: 'Colour carries meaning'),
        AanganCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Wrap(
                spacing: Space.xs,
                runSpacing: Space.xs,
                children: [
                  StatusPill('Verified', tone: StatusTone.verified),
                  StatusPill('Signed', tone: StatusTone.verified),
                  StatusPill('Your turn', tone: StatusTone.yours),
                  StatusPill('Awaiting approval', tone: StatusTone.waiting),
                  StatusPill('Overdue', tone: StatusTone.wrong),
                  StatusPill('Carpentry', tone: StatusTone.neutral),
                ],
              ),
              const SizedBox(height: Space.md),
              Text(
                'Sage is never decorative. A stage the vendor has uploaded proof '
                'for is ochre; it turns sage the moment ops approve it.',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Surfaces extends StatelessWidget {
  const _Surfaces();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHead('Depth', eyebrow: 'Three levels, one shadow'),
        AanganCard(
          padding: const EdgeInsets.all(Space.cardPaddingWide),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Level 1 — raised', style: context.text.headlineSmall),
              const SizedBox(height: Space.xs),
              Text(
                'Tonal fill and a hairline. No shadow.',
                style: context.text.bodyMedium,
              ),
              const SizedBox(height: Space.md),
              AanganCard(
                nested: true,
                child: Text(
                  'A panel nested inside a card steps one level darker, rather '
                  'than gaining a border or a shadow.',
                  style: context.text.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.md),
        const AanganOverlay(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Level 2 — overlay'),
              SizedBox(height: Space.xs),
              Text(
                'Pure chalk, a heavier border, and the only permitted shadow: a '
                'mineral diffusion at six percent.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TheActionPanel extends StatelessWidget {
  const _TheActionPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHead('Action required', eyebrow: 'When you are the blocker'),
        ActionRequired(
          title: 'Three quotes are ready',
          body:
              'Compare them and choose a professional. Nothing moves until you do.',
          action: FilledButton(onPressed: () {}, child: const Text('Compare quotes')),
        ),
      ],
    );
  }
}

class _Money extends StatelessWidget {
  const _Money();

  @override
  Widget build(BuildContext context) {
    // The point of the column: tabular figures, so the digits line up.
    const quotes = <(String, Rupees)>[
      ('Meher Interiors', Rupees(450000)),
      ('Sethi & Sons', Rupees(1128000)),
      ('Kalpataru Works', Rupees(96500)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHead('Money', eyebrow: 'Whole rupees, Indian grouping'),
        AanganCard(
          padding: const EdgeInsets.symmetric(vertical: Space.cardPadding),
          child: Column(
            children: [
              for (final (index, quote) in quotes.indexed) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.cardPadding),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(quote.$1, style: context.text.titleLarge),
                            Text(
                              'Carpentry · 4.6 in this trade',
                              style: context.text.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      MoneyText(quote.$2.formatted),
                    ],
                  ),
                ),
                if (index < quotes.length - 1) ...[
                  const SizedBox(height: Space.sm),
                  const AanganDivider(),
                  const SizedBox(height: Space.sm),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHead('Controls', eyebrow: '48dp minimum'),
        AanganCard(
          padding: const EdgeInsets.all(Space.cardPaddingWide),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FilledButton(onPressed: () {}, child: const Text('Primary')),
                  const SizedBox(width: Space.sm),
                  OutlinedButton(onPressed: () {}, child: const Text('Secondary')),
                ],
              ),
              const SizedBox(height: Space.sm),
              Row(
                children: [
                  TextButton(onPressed: () {}, child: const Text('Tertiary')),
                  const SizedBox(width: Space.sm),
                  const FilledButton(onPressed: null, child: Text('Disabled')),
                ],
              ),
              const SizedBox(height: Space.md),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Locality',
                  hintText: 'Gomti Nagar',
                ),
              ),
              const SizedBox(height: Space.sm),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Budget ceiling',
                  errorText: 'The lower budget must not exceed the upper one',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CodeInput extends StatelessWidget {
  const _CodeInput();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHead('The code field', eyebrow: 'One field, six boxes'),
        AanganCard(
          padding: const EdgeInsets.all(Space.cardPaddingWide),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OtpField(autofocus: false, onCompleted: (_) {}),
              const SizedBox(height: Space.lg),
              const AanganDivider(inset: 0),
              const SizedBox(height: Space.lg),
              OtpField(
                autofocus: false,
                errorText: 'That code is not right.',
                onCompleted: (_) {},
              ),
              const SizedBox(height: Space.md),
              Text(
                'There is one TextField behind those boxes, not six. SMS '
                'autofill delivers all six digits to whichever field has focus, '
                'so six fields keep the first and silently drop five.',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
