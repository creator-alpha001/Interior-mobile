/// Progress on work that is under way.
///
/// The same milestone roadmap the vendor sees, redrawn **read-only**. MOBILE.md
/// §6.1 is explicit: *"Four stages, proof photographs, ochre while submitted,
/// sage on approval. **No approve button.**"*
///
/// That absence is the product. A stage is done when somebody at Decora Shine has
/// checked the photographs against it — not when the vendor says so, and not
/// when the customer says so. Putting an approve button here would move a
/// verification the platform performs onto the person least able to perform it,
/// and would quietly turn the guarantee into a formality.
///
/// So the customer sees the evidence and the state, and nothing to press.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'providers.dart';
import 'review_screen.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.t('Progress'))),
      body: SafeArea(
        child: AsyncView(
          value: projects,
          onRetry: () => ref.invalidate(projectsProvider),
          data: (list) => list.isEmpty
              ? EmptyState(
                  title: context.t('Nothing under way'),
                  body: context.t('Work starts once you sign an agreement.'),
                )
              : RefreshIndicator(
                  onRefresh: () async => ref.invalidate(projectsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(Space.gutter),
                    itemCount: list.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: Space.md),
                    itemBuilder: (context, i) =>
                        CustomerProjectCard(view: list[i]),
                  ),
                ),
        ),
      ),
    );
  }
}

class CustomerProjectCard extends StatelessWidget {
  const CustomerProjectCard({super.key, required this.view});

  final ProjectView view;

  @override
  Widget build(BuildContext context) {
    final milestones = view.project.milestones;
    final approved = milestones
        .where((m) => m.verification == MilestoneVerification.approved)
        .length;

    /// A review is offered once every stage has been *approved*, not once the
    /// vendor says it is finished. Approval is the platform's definition of
    /// done and the review has to use the same one.
    final finished = milestones.isNotEmpty && approved == milestones.length;

    return InterioBeeCard(
      padding: const EdgeInsets.all(Space.cardPaddingWide),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(view.domain.name, style: context.text.headlineSmall),
                    const SizedBox(height: Space.xxs),
                    Text(
                      view.professional.companyName,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(
                context.t('{approved} of {total}', {
                  'approved': approved,
                  'total': milestones.length,
                }),
                tone: approved == milestones.length
                    ? StatusTone.verified
                    : StatusTone.neutral,
              ),
            ],
          ),

          const SizedBox(height: Space.sm),
          ClipRRect(
            borderRadius: Radii.smallRadius,
            child: LinearProgressIndicator(
              // Follows approved stages, which is the only thing that moves it.
              value: milestones.isEmpty ? 0 : approved / milestones.length,
              minHeight: 6,
              backgroundColor: context.colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(context.palette.verified),
            ),
          ),

          const SizedBox(height: Space.md),
          for (final (index, milestone) in milestones.indexed)
            _Stage(
              milestone: milestone,
              isLast: index == milestones.length - 1,
            ),

          if (finished && view.review == null) ...[
            const SizedBox(height: Space.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReviewScreen(project: view),
                  ),
                ),
                child: Text(context.t('Leave a review')),
              ),
            ),
          ] else if (view.review != null) ...[
            const SizedBox(height: Space.sm),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: TapTarget.glyph,
                  color: context.palette.waiting,
                ),
                const SizedBox(width: Space.xxs),
                Text(
                  context.t('You rated this {n} ★', {'n': view.review!.rating}),
                  style: context.text.bodyMedium,
                ),
              ],
            ),
          ],

          const SizedBox(height: Space.sm),
          Text(
            // Explains why there is nothing to press, in the customer's terms.
            context.t(
              'Our team checks each stage against the professional’s photographs '
              'before it counts as done.',
            ),
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({required this.milestone, required this.isLast});

  final ProjectMilestone milestone;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final (
      Color colour,
      IconData glyph,
      String label,
      StatusTone tone,
    ) = switch (milestone.verification) {
      MilestoneVerification.approved => (
        palette.verified,
        Icons.check_circle,
        context.t('Done'),
        StatusTone.verified,
      ),
      // Ochre. The professional has sent photographs and our team has not
      // checked them yet — so it is genuinely not done.
      MilestoneVerification.submitted => (
        palette.waiting,
        Icons.schedule,
        context.t('Being checked'),
        StatusTone.waiting,
      ),
      // The customer is told it was sent back, but not why: the verifier's note
      // is written for the vendor, and reads as criticism out of context.
      MilestoneVerification.rejected => (
        palette.waiting,
        Icons.schedule,
        context.t('More work needed'),
        StatusTone.waiting,
      ),
      MilestoneVerification.notStarted || MilestoneVerification.$unknown => (
        context.colors.outline,
        Icons.radio_button_unchecked,
        context.t('Not started'),
        StatusTone.neutral,
      ),
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(glyph, size: TapTarget.glyph, color: colour),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(vertical: Space.xxs),
                    color: palette.hairline,
                  ),
                ),
            ],
          ),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : Space.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          milestone.title,
                          style: context.text.titleLarge,
                        ),
                      ),
                      StatusPill(label, tone: tone),
                    ],
                  ),
                  if (milestone.proofNote != null) ...[
                    const SizedBox(height: Space.xxs),
                    Text(milestone.proofNote!, style: context.text.bodyMedium),
                  ],

                  /// The evidence itself, not a count of it.
                  ///
                  /// This said "3 photographs" where the photographs should
                  /// have been. The platform's claim is that a stage is done
                  /// when somebody has looked at the proof, and a customer
                  /// cannot look at a number.
                  if (milestone.proof.isNotEmpty) ...[
                    const SizedBox(height: Space.xs),
                    MediaStrip(
                      items: [
                        for (final asset in milestone.proof)
                          MediaItem(
                            url: asset.url,
                            caption: asset.caption ?? milestone.title,
                          ),
                      ],
                    ),
                  ],
                  // Deliberately no button here, of any kind.
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
