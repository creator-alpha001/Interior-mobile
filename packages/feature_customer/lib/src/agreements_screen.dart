/// Agreements, and the one screen where a double tap is expensive.
///
/// MOBILE.md §7.5 singles this out: `POST /me/agreements/:id/sign` is the
/// largest transaction in the system — five tables, a locked row, one
/// commission invoice — and mobile connections drop mid-request in a way
/// desktop ones mostly do not. The server already guards against two sets of
/// projects. The client must not make it work harder:
///
///   - disable the control on the first tap
///   - send an idempotency key
///   - **on a timeout, re-read the agreement rather than resending**
///
/// That last rule is the whole point. A blind retry of a request that may have
/// succeeded is how a customer ends up with two sets of projects and a vendor
/// with two commission invoices. If it signed, show what happened; if not,
/// offer the button again.
///
/// Agreements group by **professional**, not by service: the same vendor hired
/// for two trades gets one contract and one invoice, while execution stays
/// tracked per service. Customers ask about this, so the screen explains it
/// where it occurs.
library;

import 'dart:math';

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'providers.dart';

class AgreementsScreen extends ConsumerWidget {
  const AgreementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agreements = ref.watch(agreementsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.t('Agreements'))),
      body: SafeArea(
        child: AsyncView(
          value: agreements,
          onRetry: () => ref.invalidate(agreementsProvider),
          data: (list) => list.isEmpty
              ? EmptyState(
                  title: context.t('No agreements yet'),
                  body: context.t(
                    'Once you choose a quote we draw up the contract and '
                    'send it here to sign.',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => ref.invalidate(agreementsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(Space.gutter),
                    itemCount: list.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: Space.md),
                    itemBuilder: (context, i) => AgreementCard(view: list[i]),
                  ),
                ),
        ),
      ),
    );
  }
}

class AgreementCard extends ConsumerStatefulWidget {
  const AgreementCard({super.key, required this.view});

  final AgreementView view;

  @override
  ConsumerState<AgreementCard> createState() => _AgreementCardState();
}

class _AgreementCardState extends ConsumerState<AgreementCard> {
  bool _signing = false;

  /// Generated once per attempt and reused across a re-read.
  ///
  /// The same key for the same intent is what lets the server recognise a
  /// resend as the same signature rather than a second one.
  String? _idempotencyKey;

  Future<void> _sign() async {
    // Disabled on the first tap, before anything async happens. A second tap
    // arriving while the first request is in flight is exactly the failure
    // this screen exists to prevent.
    if (_signing) return;
    setState(() => _signing = true);

    _idempotencyKey ??= _newKey();
    final api = ref.read(customerApiProvider);

    try {
      await api.customer.signAgreement(id: widget.view.agreement.id).orThrow();

      if (!mounted) return;
      _finish(signed: true);
    } on ApiException catch (error) {
      if (!mounted) return;

      /// A timeout is the dangerous case, and it is *not* a failure.
      ///
      /// The request may well have committed — five tables' worth — and the
      /// response simply never arrived. Re-read to find out, because resending
      /// would risk a second set of projects and a second commission invoice.
      if (error.failure == ApiFailure.network ||
          error.failure == ApiFailure.serverError) {
        await _reReadAfterTimeout();
        return;
      }

      setState(() => _signing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  /// Asks the server what actually happened. Never resends.
  Future<void> _reReadAfterTimeout() async {
    try {
      final fresh = await ref
          .read(customerApiProvider)
          .customer
          .listAgreements()
          .orThrow();

      final mine = fresh.where(
        (a) => a.agreement.id == widget.view.agreement.id,
      );
      final signed = mine.isNotEmpty && mine.first.agreement.signedAt != null;

      if (!mounted) return;

      if (signed) {
        // It landed. Say so rather than offering the button again.
        _finish(signed: true);
        return;
      }

      setState(() => _signing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t(
              context.t(
                'That did not go through. Nothing was signed — you can try again.',
              ),
            ),
          ),
        ),
      );
    } on ApiException {
      if (!mounted) return;
      // Still cannot reach the server. Leave the button disabled rather than
      // inviting a tap that might double-sign.
      setState(() => _signing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.t(
              'We could not confirm whether that went through. Check your '
              'connection and pull to refresh before trying again.',
            ),
          ),
        ),
      );
    }
  }

  void _finish({required bool signed}) {
    refreshAfterWrite(ref);
    ref.invalidate(agreementsProvider);
    setState(() => _signing = false);

    if (signed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t('Signed. Your project has started.'))),
      );
    }
  }

  static String _newKey() {
    const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(
      24,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
  }

  @override
  Widget build(BuildContext context) {
    final view = widget.view;
    final agreement = view.agreement;
    final isSigned = agreement.signedAt != null;

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
                      view.professional.companyName,
                      style: context.text.headlineSmall,
                    ),
                    const SizedBox(height: Space.xxs),
                    Text(
                      agreement.reference,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSigned)
                StatusPill(context.t('Signed'), tone: StatusTone.verified)
              else
                StatusPill(context.t('Your turn'), tone: StatusTone.yours),
            ],
          ),

          const SizedBox(height: Space.md),
          MoneyText(Rupees(agreement.totalValue).formatted),

          /// Why one contract covers several jobs.
          ///
          /// Agreements group by professional. Customers ask about this, so it
          /// is explained where it happens rather than in a help page.
          if (view.isCombined) ...[
            const SizedBox(height: Space.sm),
            Container(
              padding: const EdgeInsets.all(Space.cardPadding),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainer,
                borderRadius: Radii.smallRadius,
              ),
              child: Text(
                context.t(
                  'One contract, {n} jobs. The same professional is doing all '
                  'of them, so there is a single agreement — but each job runs '
                  'on its own timeline, and one finishing does not mean the '
                  'others have.',
                  {'n': view.lines.length},
                ),
                style: context.text.bodySmall,
              ),
            ),
          ],

          const SizedBox(height: Space.sm),
          for (final line in view.lines)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.xxs),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      line.domain.name,
                      style: context.text.bodyMedium,
                    ),
                  ),
                  Text(
                    Rupees(line.quote.total).formatted,
                    style: context.text.titleMedium,
                  ),
                ],
              ),
            ),

          const SizedBox(height: Space.md),
          if (isSigned) ...[
            Row(
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: TapTarget.glyph,
                  color: context.palette.verified,
                ),
                const SizedBox(width: Space.xxs),
                Expanded(
                  child: Text(
                    context.l10n.plural(
                      view.projects.length,
                      context.t('Signed. {n} project started.'),
                      context.t('Signed. {n} projects started.'),
                    ),
                    style: context.text.bodyMedium,
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                // Disabled the instant it is tapped, and never re-enabled by a
                // timeout — only by a re-read that proved nothing was signed.
                onPressed: _signing ? null : _sign,
                child: _signing
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(context.t('Sign this agreement')),
              ),
            ),
            const SizedBox(height: Space.xs),
            Text(
              /// The payments line is not boilerplate.
              ///
              /// Aangan never handles money, and a Hindi rendering that
              /// implied otherwise would be the single most damaging sentence
              /// in the app.
              context.t(
                'Signing starts the work and creates your project timeline. '
                'Payments are arranged directly with the professional.',
              ),
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
