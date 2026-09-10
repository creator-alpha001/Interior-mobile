/// Asking to become a vendor, and hearing back.
///
/// The web's `/account/become-a-professional`, and the mobile half of a gap
/// that existed on both platforms: `JoinAsProfessionalScreen` explained why you
/// would want to work here and then told you to sign in with a number "our team
/// has approved", with nothing anywhere that could get a number approved.
/// Professional records were created by ops directly in the database.
///
/// One screen for all four states on purpose. "Can I work here yet?" is a
/// single question, and somebody who was refused needs the reason on the same
/// screen they would use to apply again.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'providers.dart';

class BecomeProfessionalScreen extends ConsumerWidget {
  const BecomeProfessionalScreen({super.key, this.sentHereBySignIn = false});

  /// Set when sign-in sent them here because the number is not a vendor.
  ///
  /// The web carries this as `?from=signin`. Here it is a constructor argument,
  /// because the router hands the screen its arguments rather than a URL.
  final bool sentHereBySignIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final application = ref.watch(professionalApplicationProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.t('Work with us'))),
      body: SafeArea(
        child: AsyncView(
          value: application,
          onRetry: () => ref.invalidate(professionalApplicationProvider),
          data: (view) => _Body(view: view, sentHereBySignIn: sentHereBySignIn),
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.view, required this.sentHereBySignIn});

  final ProfessionalApplicationView? view;
  final bool sentHereBySignIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final application = view?.application;
    final status = application?.status;

    if (status == ProfessionalApplicationStatus.approved) {
      return _Approved(view: view!);
    }

    if (status == ProfessionalApplicationStatus.submitted ||
        status == ProfessionalApplicationStatus.underReview) {
      return _Waiting(view: view!);
    }

    // Everything left over shows the form: never applied, refused, or asked for
    // changes. The last of those prefills, so nothing is retyped.
    return _ApplyForm(
      previous: status == ProfessionalApplicationStatus.changesRequested
          ? application
          : null,
      rejected: status == ProfessionalApplicationStatus.rejected
          ? application
          : null,
      changesRequested: status == ProfessionalApplicationStatus.changesRequested
          ? application
          : null,
      sentHereBySignIn: sentHereBySignIn,
    );
  }
}

/* ------------------------------------------------------------------ *
 * Decided
 * ------------------------------------------------------------------ */

class _Approved extends StatelessWidget {
  const _Approved({required this.view});

  final ProfessionalApplicationView view;

  @override
  Widget build(BuildContext context) {
    final trades = view.requestedDomains.map((d) => d.name).join(', ');

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
      children: [
        const SizedBox(height: Space.md),
        StatusPill(context.t('Approved'), tone: StatusTone.verified),
        const SizedBox(height: Space.sm),
        Text(context.t('You are in.'), style: context.text.displayLarge),
        const SizedBox(height: Space.xs),
        Text(
          trades.isEmpty
              ? context.t('Your application has been approved.')
              : context.t('You have been approved for {trades}.', {
                  'trades': trades,
                }),
          style: context.text.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Space.md),
        Text(
          context.t(
            'Sign out and back in and the app opens on your leads instead of '
            'the customer view. There are a few setup steps waiting — the '
            'partner agreement, your documents and your bank details. Leads '
            'start once those are done.',
          ),
          style: context.text.bodyMedium,
        ),
        if (view.application.reviewerNote case final note?
            when note.trim().isNotEmpty) ...[
          const SizedBox(height: Space.md),
          InterioBeeCard(child: Text(note, style: context.text.bodyMedium)),
        ],
        const SizedBox(height: Space.xxxl),
      ],
    );
  }
}

class _Waiting extends ConsumerStatefulWidget {
  const _Waiting({required this.view});

  final ProfessionalApplicationView view;

  @override
  ConsumerState<_Waiting> createState() => _WaitingState();
}

class _WaitingState extends ConsumerState<_Waiting> {
  bool _withdrawing = false;
  String? _error;

  Future<void> _withdraw() async {
    setState(() {
      _withdrawing = true;
      _error = null;
    });
    try {
      await ref
          .read(customerApiProvider)
          .customer
          .withdrawProfessionalApplication()
          .orThrow();
      ref.invalidate(professionalApplicationProvider);
    } on ApiException catch (error) {
      // The API writes these for the person who caused them — "Your
      // application is already with our team" — so they are better than
      // anything invented here.
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _withdrawing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.view.application;
    final underReview = a.status == ProfessionalApplicationStatus.underReview;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
      children: [
        const SizedBox(height: Space.md),
        StatusPill(
          underReview
              ? context.t('Being reviewed')
              : context.t('Application received'),
          tone: StatusTone.waiting,
        ),
        const SizedBox(height: Space.sm),
        Text(
          underReview
              ? context.t('Our team is looking at this now')
              : context.t('Your application is with our team'),
          style: context.text.displayLarge,
        ),
        const SizedBox(height: Space.xs),
        Text(
          context.t(
            'We read applications in the order they arrive and usually come '
            'back within two working days, by phone.',
          ),
          style: context.text.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Space.lg),
        InterioBeeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Detail(label: context.t('Business'), value: a.companyName),
              _Detail(
                label: context.t('Experience'),
                value: context.t('{n} years', {'n': a.experienceYears}),
              ),
              _Detail(
                label: context.t('Trades applied for'),
                value: widget.view.requestedDomains
                    .map((d) => d.name)
                    .join(', '),
              ),
              _Detail(
                label: context.t('Cities'),
                value: widget.view.serviceCities.map((c) => c.name).join(', '),
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.lg),
        Text(
          context.t(
            'Changed your mind, or sent the wrong details? Withdraw this and '
            'you can apply again whenever you like.',
          ),
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        if (_error case final message?) ...[
          const SizedBox(height: Space.xs),
          Text(
            message,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.error,
            ),
          ),
        ],
        const SizedBox(height: Space.xs),
        OutlinedButton(
          onPressed: _withdrawing ? null : _withdraw,
          child: Text(
            _withdrawing
                ? context.t('Withdrawing…')
                : context.t('Withdraw application'),
          ),
        ),
        const SizedBox(height: Space.xxxl),
      ],
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Space.xxs),
          Text(value.isEmpty ? '—' : value, style: context.text.bodyMedium),
        ],
      ),
    );
  }
}

/* ------------------------------------------------------------------ *
 * Applying
 * ------------------------------------------------------------------ */

class _ApplyForm extends ConsumerStatefulWidget {
  const _ApplyForm({
    required this.previous,
    required this.rejected,
    required this.changesRequested,
    required this.sentHereBySignIn,
  });

  final ProfessionalApplication? previous;
  final ProfessionalApplication? rejected;
  final ProfessionalApplication? changesRequested;
  final bool sentHereBySignIn;

  @override
  ConsumerState<_ApplyForm> createState() => _ApplyFormState();
}

class _ApplyFormState extends ConsumerState<_ApplyForm> {
  late final TextEditingController _company;
  late final TextEditingController _years;
  late final TextEditingController _bio;
  late final TextEditingController _contactName;
  late final TextEditingController _contactMobile;
  late final TextEditingController _gst;
  late final TextEditingController _areaNote;

  late Set<String> _domainIds;
  late Set<String> _cityIds;

  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = widget.previous;
    _company = TextEditingController(text: p?.companyName ?? '');
    _years = TextEditingController(
      text: p == null ? '' : '${p.experienceYears}',
    );
    _bio = TextEditingController(text: p?.bio ?? '');
    _contactName = TextEditingController(text: p?.contactName ?? '');
    _contactMobile = TextEditingController(text: p?.contactMobile ?? '');
    _gst = TextEditingController(text: p?.gstNumber ?? '');
    _areaNote = TextEditingController(text: p?.serviceAreaNote ?? '');
    _domainIds = {...?p?.requestedDomainIds};
    _cityIds = {...?p?.serviceCityIds};
  }

  @override
  void dispose() {
    for (final c in [
      _company,
      _years,
      _bio,
      _contactName,
      _contactMobile,
      _gst,
      _areaNote,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  int? get _yearsValue {
    final n = int.tryParse(_years.text.trim());
    if (n == null || n < 0 || n > 70) return null;
    return n;
  }

  bool get _ready =>
      _company.text.trim().length >= 2 &&
      _contactName.text.trim().length >= 2 &&
      _bio.text.trim().length >= 30 &&
      _yearsValue != null &&
      _domainIds.isNotEmpty &&
      _cityIds.isNotEmpty;

  Future<void> _submit() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref
          .read(customerApiProvider)
          .customer
          .submitProfessionalApplication(
            body: SubmitProfessionalApplicationBody(
              companyName: _company.text.trim(),
              experienceYears: _yearsValue!,
              bio: _bio.text.trim(),
              contactName: _contactName.text.trim(),
              requestedDomainIds: _domainIds.toList(),
              serviceCityIds: _cityIds.toList(),
              serviceAreaNote: _areaNote.text.trim(),
              gstNumber: _gst.text.trim().isEmpty ? null : _gst.text.trim(),
              contactMobile: _contactMobile.text.trim().isEmpty
                  ? null
                  : _contactMobile.text.trim(),
            ),
          )
          .orThrow();
      ref.invalidate(professionalApplicationProvider);
    } on ApiException catch (error) {
      // The API writes these for the person who caused them — "Your
      // application is already with our team" — so they are better than
      // anything invented here.
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final domains = ref.watch(domainsProvider);
    final cities = ref.watch(citiesProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
      children: [
        const SizedBox(height: Space.md),

        if (widget.sentHereBySignIn) ...[
          InterioBeeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusPill(
                  context.t('Not a professional account'),
                  tone: StatusTone.waiting,
                ),
                const SizedBox(height: Space.xs),
                Text(
                  context.t(
                    'You are signed in, but this number is not registered as a '
                    'professional. Professional accounts are created by our '
                    'team after an application is approved — you cannot sign '
                    'up for one directly.',
                  ),
                  style: context.text.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.md),
        ],

        if (widget.changesRequested case final a?) ...[
          InterioBeeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusPill(
                  context.t('Needs a change'),
                  tone: StatusTone.yours,
                ),
                const SizedBox(height: Space.xs),
                Text(
                  a.reviewerNote ?? context.t('Our team asked for a change.'),
                  style: context.text.bodyMedium,
                ),
                const SizedBox(height: Space.xs),
                Text(
                  context.t(
                    'Update this and send it again — it goes back to the same '
                    'reviewer.',
                  ),
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.md),
        ],

        if (widget.rejected case final a?) ...[
          InterioBeeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusPill(context.t('Not approved'), tone: StatusTone.wrong),
                const SizedBox(height: Space.xs),
                Text(
                  a.reviewerNote ??
                      context.t(
                        'Our team reviewed your application and could not '
                        'approve it.',
                      ),
                  style: context.text.bodyMedium,
                ),
                const SizedBox(height: Space.xs),
                Text(
                  context.t(
                    'You are welcome to apply again once that has changed. '
                    'Your customer account is unaffected.',
                  ),
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.md),
        ],

        Text(
          widget.previous == null
              ? context.t('Tell us about your business')
              : context.t('Update your application'),
          style: context.text.displayLarge,
        ),
        const SizedBox(height: Space.xs),
        Text(
          context.t(
            'Our team reads every application. Nothing here is published '
            'anywhere until you are approved.',
          ),
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: Space.lg),
        _Field(
          controller: _company,
          label: context.t('Business name'),
          hint: context.t('e.g. Sri Balaji Interiors'),
          onChanged: () => setState(() {}),
        ),
        _Field(
          controller: _years,
          label: context.t('Years in the trade'),
          hint: context.t('e.g. 8'),
          keyboardType: TextInputType.number,
          onChanged: () => setState(() {}),
          error: _years.text.trim().isNotEmpty && _yearsValue == null
              ? context.t('A whole number of years, up to 70')
              : null,
        ),
        _Field(
          controller: _contactName,
          label: context.t('Who should we ask for?'),
          hint: context.t('The person who takes our calls'),
          onChanged: () => setState(() {}),
        ),
        _Field(
          controller: _contactMobile,
          label: context.t('Best number to reach you'),
          hint: context.t('Leave blank to use the number on your account'),
          keyboardType: TextInputType.phone,
          onChanged: () => setState(() {}),
        ),
        _Field(
          controller: _gst,
          label: context.t('GST number'),
          hint: context.t('Optional — not required for smaller workshops'),
          onChanged: () => setState(() {}),
        ),

        const SizedBox(height: Space.md),
        SectionHead(
          context.t('Which trades do you want leads for?'),
          eyebrow: context.t('Approval is per trade'),
        ),
        domains.when(
          data: (list) => Wrap(
            spacing: Space.xs,
            runSpacing: Space.xs,
            children: [
              for (final domain in list)
                ChoiceChip(
                  label: Text(domain.name),
                  selected: _domainIds.contains(domain.id),
                  onSelected: (on) => setState(() {
                    on ? _domainIds.add(domain.id) : _domainIds.remove(domain.id);
                  }),
                ),
            ],
          ),
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => Text(
            context.t('Could not load the trades.'),
            style: context.text.bodySmall,
          ),
        ),

        const SizedBox(height: Space.md),
        SectionHead(
          context.t('Where do you work?'),
          eyebrow: context.t('Leads are matched by city'),
        ),
        cities.when(
          data: (list) => Wrap(
            spacing: Space.xs,
            runSpacing: Space.xs,
            children: [
              for (final city in list)
                ChoiceChip(
                  label: Text(city.name),
                  selected: _cityIds.contains(city.id),
                  onSelected: (on) => setState(() {
                    on ? _cityIds.add(city.id) : _cityIds.remove(city.id);
                  }),
                ),
            ],
          ),
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => Text(
            context.t('Could not load the cities.'),
            style: context.text.bodySmall,
          ),
        ),

        const SizedBox(height: Space.md),
        _Field(
          controller: _areaNote,
          label: context.t('Localities, in your own words'),
          hint: context.t('e.g. Anywhere in south Lucknow; Kanpur for big jobs'),
          maxLines: 2,
          onChanged: () => setState(() {}),
        ),
        _Field(
          controller: _bio,
          label: context.t('What kind of work do you do?'),
          hint: context.t(
            'The jobs you take on, the size of your team, and a couple of '
            'recent projects.',
          ),
          maxLines: 5,
          onChanged: () => setState(() {}),
          helper: _bio.text.trim().length < 30
              ? context.t('{n} more characters', {
                  'n': 30 - _bio.text.trim().length,
                })
              : context.t('Good. Specifics get read properly.'),
        ),

        if (_error case final message?) ...[
          const SizedBox(height: Space.sm),
          Text(
            message,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.error,
            ),
          ),
        ],

        const SizedBox(height: Space.lg),
        Text(
          context.t(
            'Approval switches this account over to the professional portal, '
            'where your leads, quotes and commission live.',
          ),
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Space.xs),
        FilledButton(
          onPressed: _ready && !_sending ? _submit : null,
          child: Text(
            _sending
                ? context.t('Sending…')
                : widget.previous == null
                ? context.t('Send application')
                : context.t('Send updated application'),
          ),
        ),
        const SizedBox(height: Space.xxxl),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.hint,
    this.helper,
    this.error,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final VoidCallback onChanged;
  final String? hint;
  final String? helper;
  final String? error;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.sm),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helper,
          errorText: error,
        ),
      ),
    );
  }
}
