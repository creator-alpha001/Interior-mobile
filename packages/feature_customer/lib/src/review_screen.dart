/// Leaving a review, and asking to move a visit.
///
/// Two writes the web has and the app did not: `submitReview` and
/// `requestReschedule` were both unreachable.
///
/// **A review is for one trade.** Ratings are per trade throughout the
/// platform — a good carpenter is not automatically a good painter, leads are
/// ranked on the trade being browsed, and a professional's profile shows each
/// separately. A review that fed one overall average would quietly undo all of
/// that, so this screen reviews a *project*, and a project is one trade.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, required this.project});

  final ProjectView project;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final _comment = TextEditingController();

  int _overall = 0;
  int _quality = 0;
  int _timeliness = 0;
  int _professionalism = 0;
  bool _sending = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _sending = true);
    try {
      await ref
          .read(customerApiProvider)
          .customer
          .submitReview(
            body: SubmitReviewBody(
              projectId: widget.project.project.id,
              rating: _overall,
              // Sent only when actually given. A zero here would post "nothing"
              // as "the worst possible", which is a different statement.
              qualityRating: _quality == 0 ? null : _quality,
              timelinessRating: _timeliness == 0 ? null : _timeliness,
              professionalismRating: _professionalism == 0
                  ? null
                  : _professionalism,
              comment: _comment.text.trim(),
            ),
          )
          .orThrow();

      refreshAfterWrite(ref);
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final view = widget.project;

    return Scaffold(
      appBar: AppBar(title: Text(context.t('Leave a review'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
          children: [
            const SizedBox(height: Space.md),
            Text(
              view.professional.companyName,
              style: context.text.displayLarge,
            ),
            const SizedBox(height: Space.xs),

            /// Names the trade, deliberately.
            ///
            /// This rating attaches to their record in *this* trade and
            /// nowhere else, and somebody rating a painter three stars should
            /// know it does not follow them to carpentry.
            Text(
              context.t(
                'This rates their {trade} only. Ratings on InterioBee are per '
                'trade, so it will not affect their other work.',
                {'trade': view.domain.name.toLowerCase()},
              ),
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),

            SectionHead(
              context.t('Overall'),
              eyebrow: context.t('The one that counts'),
            ),
            _Stars(
              value: _overall,
              onChanged: (v) => setState(() => _overall = v),
            ),

            SectionHead(
              context.t('And in detail'),
              eyebrow: context.t('Optional'),
            ),
            _Detail(
              label: context.t('Quality of the work'),
              value: _quality,
              onChanged: (v) => setState(() => _quality = v),
            ),
            _Detail(
              label: context.t('Kept to the timeline'),
              value: _timeliness,
              onChanged: (v) => setState(() => _timeliness = v),
            ),
            _Detail(
              label: context.t('How they were to deal with'),
              value: _professionalism,
              onChanged: (v) => setState(() => _professionalism = v),
            ),

            const SizedBox(height: Space.md),
            TextField(
              controller: _comment,
              enabled: !_sending,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: context.t('Anything you would tell a friend'),
                hintText: context.t('Optional, and read by the next customer'),
              ),
            ),

            const SizedBox(height: Space.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                // The overall star is the only required one; a review with no
                // rating is not a review.
                onPressed: _overall == 0 || _sending ? null : _submit,
                child: _sending
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(context.t('Post this review')),
              ),
            ),
            const SizedBox(height: Space.xs),
            Text(
              context.t(
                'Reviews appear on their public profile and cannot be edited '
                'afterwards.',
              ),
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Space.xxxl),
          ],
        ),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var star = 1; star <= 5; star++)
          IconButton(
            // The full 48dp, because this is the one control on the screen.
            constraints: const BoxConstraints(
              minWidth: TapTarget.minimum,
              minHeight: TapTarget.minimum,
            ),
            onPressed: () => onChanged(star),
            icon: Icon(
              star <= value ? Icons.star : Icons.star_border,
              size: 32,
              color: star <= value
                  ? context.palette.waiting
                  : context.colors.outline,
            ),
            tooltip: context.l10n.plural(star, '{n} star', '{n} stars'),
          ),
      ],
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.text.bodyMedium),
          _Stars(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Asking to move a visit.
///
/// A *request*, never a reschedule. The coordinator arranges visits with both
/// sides and confirms the slot; a customer who taps this and then assumes the
/// old time is cancelled would miss a professional standing at their door.
Future<void> showRescheduleSheet(
  BuildContext context,
  WidgetRef ref, {
  required String meetingId,
}) {
  final note = TextEditingController();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surface,
    builder: (sheet) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(sheet).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.gutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t('Ask to move this visit'),
                style: context.text.headlineSmall,
              ),
              const SizedBox(height: Space.xs),
              Text(
                context.t(
                  'We will find a slot that works for both of you and confirm '
                  'it. The current time stands until we do.',
                ),
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Space.md),
              TextField(
                controller: note,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: context.t('When would suit you?'),
                  hintText: context.t('Any morning next week, say'),
                ),
              ),
              const SizedBox(height: Space.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    Navigator.of(sheet).pop();
                    try {
                      await ref
                          .read(customerApiProvider)
                          .customer
                          .requestReschedule(
                            id: meetingId,
                            body: RequestRescheduleBody(note: note.text.trim()),
                          )
                          .orThrow();
                      refreshAfterWrite(ref);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.t(
                                'Asked. We will come back with a new time.',
                              ),
                            ),
                          ),
                        );
                      }
                    } on ApiException catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(error.message)));
                      }
                    }
                  },
                  child: Text(context.t('Send the request')),
                ),
              ),
              const SizedBox(height: Space.sm),
            ],
          ),
        ),
      ),
    ),
  );
}
