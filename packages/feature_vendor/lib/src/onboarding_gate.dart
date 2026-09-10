/// What a professional sees before they are in any pool.
///
/// MOBILE.md §6.2 is blunt about why this screen exists: *"An unsigned vendor
/// seeing '0 leads' is the single worst first impression this app can make;
/// they must see what is missing and how to finish it."*
///
/// The reason it is true is a platform rule, not a UI preference. Eligibility
/// is re-checked inside the assignment transaction, and an unsigned
/// professional is excluded however verified they are — so "0 leads" is
/// accurate, permanent until they act, and tells them nothing about either
/// fact.
///
/// So the gate replaces the shell rather than sitting inside it, and the
/// terminal step is the partner agreement, acknowledged clause by clause.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'partner_agreement.dart';
import 'providers.dart';

class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key, this.onComplete});

  /// Called once every blocking step is done, so the shell can take over.
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);

    return Scaffold(
      body: SafeArea(
        child: AsyncView(
          value: onboarding,
          onRetry: () => ref.invalidate(onboardingProvider),
          data: (state) => _Steps(state: state, onComplete: onComplete),
        ),
      ),
    );
  }
}

class _Steps extends ConsumerWidget {
  const _Steps({required this.state, this.onComplete});

  final VendorOnboarding state;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocking = state.steps.where((s) => s.blocking && !s.done).toList();

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(onboardingProvider),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
        children: [
          const SizedBox(height: Space.xl),
          Text(
            context.t('Before you receive work'),
            style: context.text.displayLarge,
          ),
          const SizedBox(height: Space.sm),
          Text(
            state.canReceiveLeads
                ? context.t(
                    context.t(
                      'Everything is in place. Leads will start arriving.',
                    ),
                  )
                // Says the quiet part out loud. A vendor who does not know they
                // are excluded assumes the platform has no work.
                : context.t(
                    'You are not in any lead pool yet. These are the steps '
                    'between you and the first job.',
                  ),
            style: context.text.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),

          if (state.blockedReason != null) ...[
            const SizedBox(height: Space.lg),
            ActionRequired(
              title: context.t('What is holding things up'),

              /// The server's reason, in the server's language.
              ///
              /// `blockedReason`, and the step labels below it, are written by
              /// the API. Translating them means translating them there — the
              /// app cannot do it without keeping a shadow copy of every
              /// sentence the onboarding module can produce. Noted rather than
              /// papered over: this is the one place a Hindi user still sees
              /// English, and it is a server change, not a client one.
              body: state.blockedReason!,
            ),
          ],

          const SizedBox(height: Space.xl),
          _Progress(done: state.completedCount, total: state.totalCount),
          const SizedBox(height: Space.lg),

          for (final step in state.steps) ...[
            _StepRow(
              step: step,
              onOpen: step.key == OnboardingStepKey.agreement && !step.done
                  ? () => _openAgreement(context, ref)
                  : null,
            ),
            const SizedBox(height: Space.xs),
          ],

          if (state.canReceiveLeads && onComplete != null) ...[
            const SizedBox(height: Space.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onComplete,
                child: Text(context.t('Go to my dashboard')),
              ),
            ),
          ],

          const SizedBox(height: Space.xl),
          Text(
            blocking.isEmpty
                ? context.t(
                    context.t(
                      'Anything still outstanding is optional, and can wait.',
                    ),
                  )
                : context.l10n.plural(
                    blocking.length,
                    context.t(
                      '{n} of these must be finished before you are eligible. '
                      'The rest can wait.',
                    ),
                    context.t(
                      '{n} of these must be finished before you are eligible. '
                      'The rest can wait.',
                    ),
                  ),
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Space.xxxl),
        ],
      ),
    );
  }

  Future<void> _openAgreement(BuildContext context, WidgetRef ref) async {
    final signed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PartnerAgreementScreen(terms: state.terms),
      ),
    );
    if (signed ?? false) ref.invalidate(onboardingProvider);
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.done, required this.total});

  final num done;
  final num total;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : done / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.t('{done} of {total} complete', {
                'done': done,
                'total': total,
              }),
              style: context.text.titleMedium,
            ),
            const Spacer(),
            if (done == total)
              StatusPill(context.t('Ready'), tone: StatusTone.verified)
            else
              StatusPill(context.t('In progress'), tone: StatusTone.waiting),
          ],
        ),
        const SizedBox(height: Space.xs),
        ClipRRect(
          borderRadius: Radii.smallRadius,
          child: LinearProgressIndicator(
            value: fraction.toDouble(),
            minHeight: 6,
            backgroundColor: context.colors.surfaceContainerHighest,
            // Terracotta: this is the thing on screen to act on.
            valueColor: AlwaysStoppedAnimation(context.colors.primary),
          ),
        ),
      ],
    );
  }
}

/// One step of the stepped ledger.
class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, this.onOpen});

  final OnboardingStep step;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return InterioBeeCard(
      onTap: onOpen,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Sage only once it is genuinely done.
          ///
          /// DESIGN.md §1.4: sage means a person at Decora Shine checked something.
          /// A step in progress is ochre, and an optional one not yet started
          /// is neutral — never a hopeful green.
          Icon(
            step.done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: TapTarget.glyph,
            color: step.done
                ? palette.verified
                : step.blocking
                ? palette.waiting
                : context.colors.outline,
          ),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(step.label, style: context.text.titleLarge),
                    ),
                    if (!step.done && step.blocking)
                      StatusPill(context.t('Required'), tone: StatusTone.yours),
                  ],
                ),
                const SizedBox(height: Space.xxs),
                Text(
                  step.description,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                if (step.hint != null) ...[
                  const SizedBox(height: Space.xxs),
                  Text(
                    step.hint!,
                    style: context.text.bodySmall?.copyWith(
                      color: palette.waiting,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onOpen != null)
            Icon(Icons.chevron_right, color: context.colors.onSurfaceVariant),
        ],
      ),
    );
  }
}
