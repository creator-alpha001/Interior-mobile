/// How the platform works, and how to join it as a professional.
///
/// The web's `/how-it-works` and `/join-as-professional`. Both are static
/// explanations rather than data screens, and both were missing.
///
/// **They earn their place for different reasons.** "How it works" answers the
/// question the product's shape provokes — *why can I not just call the
/// carpenter?* — and a customer who does not understand the relay reads it as
/// obstruction rather than as the service. The recruiting page is here because
/// there is one binary: a professional who installs Aangan lands in the
/// customer app, and without this there is nothing telling them where to go.
library;

import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';

/// One numbered step.
@immutable
class _Step {
  const _Step(this.title, this.body, [this.note]);

  final String title;
  final String body;

  /// The sharp edge of the step — usually the part somebody would otherwise
  /// find out later and feel misled by.
  final String? note;
}

/// The seven steps, in the web's words and order.
const _steps = <_Step>[
  _Step(
    'You submit one short form',
    'What you need, where, in your own words, and when you want to start. If '
        'you pick more than one trade, one extra question each: who supplies '
        'the material. That is the whole form.',
    'We deliberately do not ask for carpet area, paint finish or exact '
        'dimensions. At enquiry stage those answers are guesses, and a guess '
        'produces a bad quote.',
  ),
  _Step(
    'We call you',
    'A short call for the detail the form left out — rooms, sizes, finishes, '
        'site constraints. It is recorded against your requirement so every '
        'professional works from the same brief.',
  ),
  _Step(
    'Three professionals for each trade',
    'Our team rings professionals in your city who are approved for that '
        'specific trade, checks they are free and interested, and only then '
        'assigns them. Nobody is auto-assigned by an algorithm.',
    'A requirement covering two trades gets three professionals for each — '
        'six in total, working separately.',
  ),
  _Step(
    'Site visits and written quotes',
    'We arrange each visit, confirming the slot with you and the professional '
        'separately. They measure, then send a written quote with line items, '
        'a timeline, a warranty and the material specification.',
    'A professional is given your address for a confirmed visit and nothing '
        'else. Your phone number is never shared with them.',
  ),
  _Step(
    'Every question goes through us',
    'There is no direct line between you and the professionals, in either '
        'direction. You ask us; we put it to all three and bring the answers '
        'back. One question improves three quotes instead of one, and you are '
        'not fielding calls from three people.',
  ),
  _Step(
    'You compare and choose',
    'One comparison per trade, the same columns for every quote. Choose '
        'whoever you want — cheapest, fastest, longest warranty, or the person '
        'you simply trusted most on site.',
  ),
  _Step(
    'Agreements, then work',
    'One agreement per professional. If one of them is doing two of your '
        'trades that is a single combined contract, not two. Work is then '
        'tracked per trade, stage by stage, through to handover.',
  ),
];

/// What onboarding asks a professional for, before any customer sees them.
///
/// A named const rather than an inline list, so `l10n_test.dart` can find it:
/// `context.t(item)` passes a value, and a literal inside a widget tree is
/// invisible to a source scan that looks for `context.t('…')`.
const _requirements = <String>[
  'Your registered mobile number, verified.',
  'GST registration, where you have one. Not required for smaller workshops.',
  'Recent completed jobs, with locality and approximate date.',
  'Past customers we can call.',
  'The cities and localities you actually travel to.',
];

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key, this.onStart});

  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t('How it works'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
          children: [
            const SizedBox(height: Space.md),
            Text(
              context.t('One person who answers'),
              style: context.text.displayLarge,
            ),
            const SizedBox(height: Space.sm),
            Text(
              context.t(
                'Seven steps from a description to a finished job. The only '
                'unusual one is that we stay in the middle the whole way.',
              ),
              style: context.text.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: Space.lg),
            for (final (index, step) in _steps.indexed)
              _StepRow(index: index + 1, step: step),

            /// Said once, plainly, at the end.
            ///
            /// It is the thing customers most often assume otherwise, and
            /// finding out late — after signing — would be the worst possible
            /// moment.
            const SizedBox(height: Space.md),
            AanganCard(
              padding: const EdgeInsets.all(Space.cardPaddingWide),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t('Money is between you and them'),
                    style: context.text.titleLarge,
                  ),
                  const SizedBox(height: Space.xxs),
                  Text(
                    context.t(
                      'Aangan does not hold your money or take a cut of what '
                      'you pay. You settle directly with your professional, on '
                      'the terms in the agreement. We are paid a commission by '
                      'them.',
                    ),
                    style: context.text.bodyMedium,
                  ),
                ],
              ),
            ),

            if (onStart != null) ...[
              const SizedBox(height: Space.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onStart,
                  child: Text(context.t('Tell us what you need')),
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

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.step});

  final int index;
  final _Step step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$index',
              // Tabular figures, so the numbers line up down the column.
              style: AanganTextStyles.financialNum.copyWith(
                fontSize: 20,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.t(step.title), style: context.text.titleLarge),
                const SizedBox(height: Space.xxs),
                Text(context.t(step.body), style: context.text.bodyMedium),
                if (step.note != null) ...[
                  const SizedBox(height: Space.xs),
                  AanganCard(
                    nested: true,
                    child: Text(
                      context.t(step.note!),
                      style: context.text.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Why a professional would want to be on the platform, and what it costs.
class JoinAsProfessionalScreen extends StatelessWidget {
  const JoinAsProfessionalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t('Work with us'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
          children: [
            const SizedBox(height: Space.md),
            Text(context.t('Work with us'), style: context.text.displayLarge),
            const SizedBox(height: Space.sm),
            Text(
              context.t(
                'Verified leads for the trades you are approved for. No '
                'listing fee — commission only on work you win.',
              ),
              style: context.text.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),

            SectionHead(
              context.t('What you get'),
              eyebrow: context.t('And what you do not pay'),
            ),
            _Promise(
              title: context.t('Never charged to be here'),
              body: context.t(
                'No listing fee, no charge to receive a lead. Commission is '
                'raised only when a customer signs, at your rate for that '
                'trade.',
              ),
            ),
            _Promise(
              title: context.t('One brief, one clarification'),
              body: context.t(
                'You quote against the same written brief as everybody else, '
                'and questions come to you through us. No chasing a customer '
                'who has stopped answering.',
              ),
            ),
            _Promise(
              title: context.t('Approved trade by trade'),
              body: context.t(
                'You are approved for each trade separately and rated in each '
                'separately, so being excellent at one is not diluted by a '
                'job somebody else took.',
              ),
            ),
            _Promise(
              title: context.t('Two trades, one invoice'),
              body: context.t(
                'Handle two trades for one customer under a combined agreement '
                'and you get one invoice, not two.',
              ),
            ),

            SectionHead(
              context.t('What we ask for'),
              eyebrow: context.t('Before any customer sees you'),
            ),
            for (final item in _requirements)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.xxs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: TapTarget.glyph,
                      color: context.palette.verified,
                    ),
                    const SizedBox(width: Space.xs),
                    Expanded(
                      child: Text(
                        context.t(item),
                        style: context.text.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: Space.lg),
            AanganCard(
              padding: const EdgeInsets.all(Space.cardPaddingWide),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t('How to start'),
                    style: context.text.titleLarge,
                  ),
                  const SizedBox(height: Space.xxs),

                  /// There is one binary, so a professional is already in the
                  /// right app — they simply have to sign in with a number our
                  /// team has approved. Saying so is the whole point of this
                  /// screen existing here.
                  Text(
                    context.t(
                      'Sign in with the mobile number you registered with us. '
                      'Once our team has approved you, this same app opens on '
                      'your leads instead of the customer view.',
                    ),
                    style: context.text.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.xxxl),
          ],
        ),
      ),
    );
  }
}

class _Promise extends StatelessWidget {
  const _Promise({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.text.titleLarge),
          const SizedBox(height: Space.xxs),
          Text(
            body,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
