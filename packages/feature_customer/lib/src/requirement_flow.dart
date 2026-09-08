/// Submitting a requirement. Six steps, and verification is last.
///
/// The order is MOBILE.md §6.3, and the reason it matters is in the last step:
/// **everything before verification stays on the device.** Asking for an
/// account first is how a form loses the people who opened it, and the API is
/// built for this — `/uploads/tickets` accepts an anonymous caller for
/// `requirement_photo` and rate-limits by address.
///
/// The risk that buys is concentrated in one place: if `POST /me/requirements`
/// fails *after* the code verifies, the person is suddenly signed in with an
/// unsaved form. So the draft is persisted after every step and the retry runs
/// against what was saved. That path is the one worth testing on a bad
/// connection, and it is covered in `test/requirement_flow_test.dart`.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_core_upload/aangan_core_upload.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'async_view.dart';
import 'providers.dart';
import 'requirement_draft.dart';

/// What the flow needs from the app: a way to verify a number, and a queue.
typedef VerifyNumber = Future<bool> Function(BuildContext context);

class RequirementFlow extends ConsumerStatefulWidget {
  const RequirementFlow({
    super.key,
    required this.queue,
    required this.isSignedIn,
    required this.verify,
    this.store,
  });

  final UploadQueue queue;

  /// Whether there is already a session. A signed-in customer skips step 6.
  final bool Function() isSignedIn;

  /// Runs the OTP flow. Returns true once a session exists.
  final VerifyNumber verify;

  final RequirementDraftStore? store;

  @override
  ConsumerState<RequirementFlow> createState() => _RequirementFlowState();
}

class _RequirementFlowState extends ConsumerState<RequirementFlow> {
  late final RequirementDraftStore _store =
      widget.store ?? RequirementDraftStore();

  RequirementDraft _draft = const RequirementDraft();
  bool _loading = true;
  bool _submitting = false;
  Object? _error;

  final _description = TextEditingController();
  final _locality = TextEditingController();
  final _budget = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.queue.addListener(_onQueue);
    _restore();
  }

  @override
  void dispose() {
    widget.queue.removeListener(_onQueue);
    _description.dispose();
    _locality.dispose();
    _budget.dispose();
    super.dispose();
  }

  void _onQueue() {
    // Asset ids arrive as uploads finish, and the draft carries them.
    final ids = widget.queue.completedAssetIds;
    if (ids.length != _draft.photoAssetIds.length) {
      _update(_draft.copyWith(photoAssetIds: ids));
    } else {
      setState(() {});
    }
  }

  Future<void> _restore() async {
    final saved = await _store.load();
    if (!mounted) return;
    setState(() {
      if (saved != null) {
        _draft = saved;
        _description.text = saved.description;
        _locality.text = saved.locality;
        _budget.text = saved.budgetMax?.toString() ?? '';
      }
      _loading = false;
    });
  }

  void _update(RequirementDraft next) {
    setState(() => _draft = next);
    // After every change, not every step: the failure this guards against is
    // the app dying, and it does not wait for a step boundary.
    _store.save(next);
  }

  void _back() {
    final index = _draft.step.index;
    if (index == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    _update(_draft.copyWith(step: RequirementStep.values[index - 1]));
  }

  Future<void> _next() async {
    final index = _draft.step.index;

    // A signed-in customer has nothing to verify; submit from the budget step.
    if (_draft.step == RequirementStep.budget && widget.isSignedIn()) {
      await _submit();
      return;
    }

    if (index < RequirementStep.values.length - 1) {
      _update(_draft.copyWith(step: RequirementStep.values[index + 1]));
    }
  }

  /// Verify, then submit — in that order, and never the reverse.
  Future<void> _verifyAndSubmit() async {
    if (!widget.isSignedIn()) {
      final verified = await widget.verify(context);
      if (!verified) return;
    }
    await _submit();
  }

  Future<void> _submit() async {
    if (!_draft.isComplete) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final lead = await ref
          .read(customerApiProvider)
          .customer
          .createRequirement(body: _draft.toBody())
          .orThrow();

      // Only now. If this line is never reached the draft is the only copy of
      // what they typed, and clearing it would be the actual data loss.
      await _store.clear();

      if (!mounted) return;
      refreshAfterWrite(ref);
      Navigator.of(context).pop(lead);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final step = _draft.step;
    final total = RequirementStep.values.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _submitting ? null : _back,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          context.t('Step {n} of {total}', {
            'n': step.index + 1,
            'total': total,
          }),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (step.index + 1) / total,
              minHeight: 3,
              backgroundColor: context.colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(context.colors.primary),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
                children: [
                  const SizedBox(height: Space.lg),
                  Text(step.title(context), style: context.text.displayLarge),
                  const SizedBox(height: Space.md),
                  switch (step) {
                    RequirementStep.trades => _Trades(
                      draft: _draft,
                      onChanged: _update,
                    ),
                    RequirementStep.detail => _Detail(
                      draft: _draft,
                      controller: _description,
                      onChanged: _update,
                    ),
                    RequirementStep.photographs => _Photographs(
                      queue: widget.queue,
                      onPick: _pick,
                    ),
                    RequirementStep.where => _Where(
                      draft: _draft,
                      locality: _locality,
                      onChanged: _update,
                    ),
                    RequirementStep.budget => _Budget(
                      draft: _draft,
                      budget: _budget,
                      onChanged: _update,
                    ),
                    RequirementStep.verify => _Verify(draft: _draft),
                  },
                  if (_error != null) ...[
                    const SizedBox(height: Space.md),
                    ErrorState(
                      error: _error!,
                      onRetry: () => setState(() => _error = null),
                    ),
                    const SizedBox(height: Space.xs),
                    Text(
                      // The reassurance that matters at this exact moment.
                      context.t(
                        'Nothing you typed is lost — it is saved on this device. '
                        'Tap below to try sending it again.',
                      ),
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: Space.xxxl),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Space.gutter),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitting
                      ? null
                      : step == RequirementStep.verify
                      ? _verifyAndSubmit
                      : (_draft.canAdvance ? _next : null),
                  child: _submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_buttonLabel(context, step)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buttonLabel(BuildContext context, RequirementStep step) {
    if (step == RequirementStep.verify) {
      return _error == null
          ? context.t('Verify and send')
          : context.t('Try sending again');
    }
    if (step == RequirementStep.budget && widget.isSignedIn()) {
      return context.t('Send my requirement');
    }
    if (step == RequirementStep.photographs && widget.queue.items.isEmpty) {
      return context.t('Skip for now');
    }
    return context.t('Continue');
  }

  Future<void> _pick(ImageSource source) async {
    final picker = ImagePicker();

    if (source == ImageSource.gallery) {
      for (final file in await picker.pickMultiImage(limit: 6)) {
        await widget.queue.add(
          localPath: file.path,
          // Anonymous is allowed for exactly this purpose, and no other.
          purpose: UploadPurpose.requirementPhoto,
        );
      }
      return;
    }

    final shot = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 3000,
    );
    if (shot == null) return;
    await widget.queue.add(
      localPath: shot.path,
      purpose: UploadPurpose.requirementPhoto,
    );
  }
}

/* ------------------------------------------------------------------ *
 * The steps
 * ------------------------------------------------------------------ */

class _Trades extends ConsumerWidget {
  const _Trades({required this.draft, required this.onChanged});

  final RequirementDraft draft;
  final ValueChanged<RequirementDraft> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domains = ref.watch(domainsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t(
            'Pick everything you need. Each becomes its own job, with its own '
            'quotes and its own timeline.',
          ),
          style: context.text.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Space.md),
        AsyncView(
          value: domains,
          onRetry: () => ref.invalidate(domainsProvider),
          data: (list) => Column(
            children: [
              for (final domain in list) ...[
                _Selectable(
                  title: domain.name,
                  subtitle: domain.tagline,
                  selected: draft.domainIds.contains(domain.id),
                  onTap: () {
                    final next = [...draft.domainIds];
                    final material = {...draft.materialSource};

                    if (next.remove(domain.id)) {
                      material.remove(domain.id);
                    } else {
                      next.add(domain.id);
                      material[domain.id] = MaterialSource.undecided;
                    }
                    onChanged(
                      draft.copyWith(domainIds: next, materialSource: material),
                    );
                  },
                ),
                const SizedBox(height: Space.xs),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({
    required this.draft,
    required this.controller,
    required this.onChanged,
  });

  final RequirementDraft draft;
  final TextEditingController controller;
  final ValueChanged<RequirementDraft> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domains = ref.watch(domainsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t(
            'A rough idea is enough. Our coordinator will call and take the '
            'detail properly.',
          ),
          style: context.text.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Space.md),
        TextField(
          controller: controller,
          maxLines: 6,
          decoration: InputDecoration(
            labelText: context.t('What needs doing'),
            hintText: context.t(
              context.t('Wardrobe for the master bedroom, floor to ceiling…'),
            ),
          ),
          onChanged: (value) => onChanged(draft.copyWith(description: value)),
        ),

        SectionHead(context.t('Material'), eyebrow: context.t('Asked per job')),
        Text(
          // Per trade, because it genuinely differs: somebody may have their
          // own wood and not their own paint.
          context.t(
            context.t(
              'You can supply your own material for some jobs and not others.',
            ),
          ),
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Space.sm),
        domains.maybeWhen(
          data: (list) => Column(
            children: [
              for (final domain in list.where(
                (d) => draft.domainIds.contains(d.id),
              ))
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.xs),
                  child: AanganCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(domain.name, style: context.text.titleLarge),
                        const SizedBox(height: Space.xs),
                        Wrap(
                          spacing: Space.xs,
                          children: [
                            for (final source in const [
                              MaterialSource.vendorSupplied,
                              MaterialSource.customerSupplied,
                              MaterialSource.undecided,
                            ])
                              ChoiceChip(
                                label: Text(switch (source) {
                                  MaterialSource.vendorSupplied => context.t(
                                    context.t('They supply'),
                                  ),
                                  MaterialSource.customerSupplied => context.t(
                                    context.t('I supply'),
                                  ),
                                  _ => context.t('Not sure yet'),
                                }),
                                selected:
                                    draft.materialSource[domain.id] == source,
                                onSelected: (_) => onChanged(
                                  draft.copyWith(
                                    materialSource: {
                                      ...draft.materialSource,
                                      domain.id: source,
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _Photographs extends StatelessWidget {
  const _Photographs({required this.queue, required this.onPick});

  final UploadQueue queue;
  final ValueChanged<ImageSource> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t(
            'Photographs help a professional quote accurately, and mean fewer '
            'visits before work starts. Optional, but worth it.',
          ),
          style: context.text.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Space.md),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => onPick(ImageSource.camera),
                icon: const Icon(
                  Icons.photo_camera_outlined,
                  size: TapTarget.glyph,
                ),
                label: Text(context.t('Camera')),
              ),
            ),
            const SizedBox(width: Space.xs),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onPick(ImageSource.gallery),
                icon: const Icon(
                  Icons.photo_library_outlined,
                  size: TapTarget.glyph,
                ),
                label: Text(context.t('Gallery')),
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.sm),
        for (final upload in queue.items)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.xs),
            child: AanganCard(
              child: Row(
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: TapTarget.glyph,
                    color: context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: Space.xs),
                  Expanded(
                    child: Text(
                      upload.localPath.split(RegExp(r'[/\\]')).last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium,
                    ),
                  ),
                  StatusPill(
                    switch (upload.state) {
                      UploadState.done => context.t('Added'),
                      UploadState.failed => context.t('Failed'),
                      _ => context.t('Sending'),
                    },
                    tone: switch (upload.state) {
                      UploadState.done => StatusTone.verified,
                      UploadState.failed => StatusTone.wrong,
                      _ => StatusTone.waiting,
                    },
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: Space.xs),
        Text(
          // Says the quiet part: you do not have an account yet, and that is
          // fine. This is the step where people expect a wall.
          context.t('You do not need an account to add these.'),
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Where extends ConsumerWidget {
  const _Where({
    required this.draft,
    required this.locality,
    required this.onChanged,
  });

  final RequirementDraft draft;
  final TextEditingController locality;
  final ValueChanged<RequirementDraft> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cities = ref.watch(citiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          /// The address rule, stated where it is asked about.
          ///
          /// Release per service, only after a confirmed visit. A Hindi
          /// rendering that blurred this into "we share your address with
          /// professionals" would describe a different product.
          context.t(
            'Your locality is enough for now. The full address is only shared '
            'with a professional once you confirm a visit with them.',
          ),
          style: context.text.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Space.md),
        AsyncView(
          value: cities,
          onRetry: () => ref.invalidate(citiesProvider),
          data: (list) => Column(
            children: [
              for (final city in list.where((c) => c.isActive)) ...[
                _Selectable(
                  title: city.name,
                  subtitle: city.state,
                  selected: draft.cityId == city.id,
                  onTap: () => onChanged(draft.copyWith(cityId: city.id)),
                ),
                const SizedBox(height: Space.xs),
              ],
            ],
          ),
        ),
        const SizedBox(height: Space.sm),
        TextField(
          controller: locality,
          decoration: InputDecoration(
            labelText: context.t('Locality'),
            // A real Lucknow locality, as an example. Not translated: it is a
            // place name.
            // A place name, as an example. Not copy.
            hintText: 'Gomti Nagar',
          ),
          onChanged: (value) => onChanged(draft.copyWith(locality: value)),
        ),
      ],
    );
  }
}

class _Budget extends StatelessWidget {
  const _Budget({
    required this.draft,
    required this.budget,
    required this.onChanged,
  });

  final RequirementDraft draft;
  final TextEditingController budget;
  final ValueChanged<RequirementDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.t('How soon?'), style: context.text.headlineSmall),
        const SizedBox(height: Space.xs),
        for (final urgency in const [
          Urgency.immediate,
          Urgency.withinMonth,
          Urgency.exploring,
        ]) ...[
          _Selectable(
            title: switch (urgency) {
              Urgency.immediate => context.t('As soon as possible'),
              Urgency.withinMonth => context.t('Within a month'),
              _ => context.t('Just exploring'),
            },
            subtitle: switch (urgency) {
              Urgency.immediate => context.t('We will prioritise your call'),
              Urgency.withinMonth => context.t('The usual pace'),
              _ => context.t('No rush — get a feel for prices'),
            },
            selected: draft.urgency == urgency,
            onTap: () => onChanged(draft.copyWith(urgency: urgency)),
          ),
          const SizedBox(height: Space.xs),
        ],

        SectionHead(context.t('Budget'), eyebrow: context.t('Optional')),
        Text(
          context.t(
            'A ceiling helps professionals judge whether they are right for the '
            'job. It is a signal, not a promise, and you are not held to it.',
          ),
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Space.sm),
        TextField(
          controller: budget,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: context.t('Up to'),
            // The symbol, not a word.
            prefixText: '₹ ',
          ),
          onChanged: (value) {
            final parsed = int.tryParse(value);
            onChanged(
              parsed == null
                  ? draft.copyWith(clearBudget: true)
                  : draft.copyWith(budgetMax: parsed),
            );
          },
        ),
        if (draft.budgetMax != null) ...[
          const SizedBox(height: Space.xs),
          Text(
            Rupees(draft.budgetMax!).formatted,
            style: context.text.titleLarge,
          ),
        ],
      ],
    );
  }
}

class _Verify extends StatelessWidget {
  const _Verify({required this.draft});

  final RequirementDraft draft;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t(
            'One last thing. We will text you a code — that is how we reach you '
            'about this job, and it sets up your account at the same time.',
          ),
          style: context.text.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Space.lg),
        AanganCard(
          padding: const EdgeInsets.all(Space.cardPaddingWide),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t('What you are sending'),
                style: context.text.labelMedium,
              ),
              const SizedBox(height: Space.xs),
              _Summary(
                label: context.t('Jobs'),
                value: '${draft.domainIds.length}',
              ),
              _Summary(
                label: context.t('Photographs'),
                value: '${draft.photoAssetIds.length}',
              ),
              _Summary(label: context.t('Locality'), value: draft.locality),
              _Summary(
                label: context.t('Budget'),
                value: draft.budgetMax == null
                    ? context.t('Not stated')
                    : Rupees(draft.budgetMax!).formatted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xxs),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: context.text.titleMedium)),
        ],
      ),
    );
  }
}

class _Selectable extends StatelessWidget {
  const _Selectable({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
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
                    Text(title, style: context.text.titleLarge),
                    Text(
                      subtitle,
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
