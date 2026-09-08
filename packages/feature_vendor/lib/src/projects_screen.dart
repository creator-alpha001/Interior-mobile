/// Live work, and the stepped roadmap each project moves along.
///
/// The prototype's milestone ledger, redrawn around what actually gates
/// progress here. The colour rule does the explaining:
///
///   not started  neutral — nothing to do yet
///   submitted    **ochre** — waiting on somebody else
///   approved     **sage** — a person at Aangan checked it
///   rejected     iron — sent back, and the note says why
///
/// A stage the vendor has uploaded proof for is ochre, never sage. It turns
/// sage the moment ops approve it, and that single transition is the whole of
/// "a stage is done when somebody checked", made visible.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_core_upload/aangan_core_upload.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'providers.dart';
import 'stage_proof_screen.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key, required this.queueFor});

  /// A queue per stage, so two stages in flight cannot mix their photographs.
  final UploadQueue Function(String milestoneId) queueFor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Space.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
              child: Text(
                context.t('Projects'),
                style: context.text.headlineLarge,
              ),
            ),
            const SizedBox(height: Space.sm),
            Expanded(
              child: AsyncView(
                value: projects,
                onRetry: () => ref.invalidate(projectsProvider),
                data: (list) {
                  if (list.isEmpty) {
                    return EmptyState(
                      title: context.t('No live work'),
                      body: context.t(
                        'A project starts when a customer signs an '
                        'agreement for a quote you won.',
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(projectsProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Space.gutter,
                        vertical: Space.xs,
                      ),
                      itemCount: list.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: Space.md),
                      itemBuilder: (context, i) =>
                          ProjectCard(project: list[i], queueFor: queueFor),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, required this.queueFor});

  final VendorProjectView project;
  final UploadQueue Function(String milestoneId) queueFor;

  @override
  Widget build(BuildContext context) {
    final milestones = project.project.milestones;
    final approved = milestones
        .where((m) => m.verification == MilestoneVerification.approved)
        .length;

    return AanganCard(
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
                    Text(
                      project.client.displayName,
                      style: context.text.headlineSmall,
                    ),
                    const SizedBox(height: Space.xxs),
                    Text(
                      '${project.project.reference} · ${project.cityName}',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(project.domain.name, tone: StatusTone.neutral),
            ],
          ),

          const SizedBox(height: Space.sm),
          Row(
            children: [
              Text(
                Rupees(project.project.value).formatted,
                style: context.text.titleLarge,
              ),
              const Spacer(),
              Text(
                context.t('{approved} of {total} stages approved', {
                  'approved': approved,
                  'total': milestones.length,
                }),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: Space.md),
          const AanganDivider(inset: 0),
          const SizedBox(height: Space.sm),

          for (final (index, milestone) in milestones.indexed)
            _MilestoneRow(
              milestone: milestone,
              isLast: index == milestones.length - 1,
              onSubmit: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => StageProofScreen(
                    project: project,
                    milestone: milestone,
                    queue: queueFor(milestone.id),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({
    required this.milestone,
    required this.isLast,
    required this.onSubmit,
  });

  final ProjectMilestone milestone;
  final bool isLast;
  final VoidCallback onSubmit;

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
        context.t('Approved'),
        StatusTone.verified,
      ),
      // Ochre, not sage. Submitted is waiting on ops, not done.
      MilestoneVerification.submitted => (
        palette.waiting,
        Icons.schedule,
        context.t('Awaiting approval'),
        StatusTone.waiting,
      ),
      MilestoneVerification.rejected => (
        palette.wrong,
        Icons.error_outline,
        context.t('Sent back'),
        StatusTone.wrong,
      ),
      MilestoneVerification.notStarted || MilestoneVerification.$unknown => (
        context.colors.outline,
        Icons.radio_button_unchecked,
        context.t('Not started'),
        StatusTone.neutral,
      ),
    };

    final canSubmit =
        milestone.verification == MilestoneVerification.notStarted ||
        milestone.verification == MilestoneVerification.rejected;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The ledger's spine.
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
                  if (milestone.verifierNote != null) ...[
                    const SizedBox(height: Space.xxs),
                    Text(
                      milestone.verifierNote!,
                      style: context.text.bodySmall?.copyWith(
                        color: palette.wrong,
                      ),
                    ),
                  ],
                  if (milestone.proofNote != null &&
                      milestone.verification !=
                          MilestoneVerification.rejected) ...[
                    const SizedBox(height: Space.xxs),
                    Text(
                      milestone.proofNote!,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],

                  /// What was actually sent.
                  ///
                  /// A vendor arguing a rejection needs to see the
                  /// photographs the verifier saw, and until now the app that
                  /// took them showed them back to nobody. It matters most on
                  /// the rejected path, which is exactly where the note above
                  /// is a criticism of pictures the reader cannot look at.
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
                  if (canSubmit) ...[
                    const SizedBox(height: Space.xs),
                    OutlinedButton(
                      onPressed: onSubmit,
                      child: Text(
                        milestone.verification == MilestoneVerification.rejected
                            ? context.t('Send new proof')
                            : context.t('Submit proof'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
