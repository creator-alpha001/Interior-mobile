/// The partner agreement, acknowledged clause by clause.
///
/// MOBILE.md §6.2: the terminal onboarding step, "behind a clause-by-clause
/// acknowledgement". That is not ceremony — `PartnerTerms.acknowledgements`
/// exists because those are the clauses vendors most often claim not to have
/// seen, and the server stores each ticked key so consent can be proved one
/// clause at a time rather than as a single "I agree".
///
/// So the Continue button stays disabled until every clause is ticked
/// individually. There is deliberately no "accept all".
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'providers.dart';

class PartnerAgreementScreen extends ConsumerStatefulWidget {
  const PartnerAgreementScreen({super.key, required this.terms});

  final PartnerTerms terms;

  @override
  ConsumerState<PartnerAgreementScreen> createState() =>
      _PartnerAgreementScreenState();
}

class _PartnerAgreementScreenState
    extends ConsumerState<PartnerAgreementScreen> {
  final _ticked = <String>{};
  final _signature = TextEditingController();
  final _name = TextEditingController();
  final _role = TextEditingController(text: 'Proprietor');

  bool _busy = false;
  Object? _error;

  @override
  void dispose() {
    _signature.dispose();
    _name.dispose();
    _role.dispose();
    super.dispose();
  }

  bool get _complete =>
      _ticked.length == widget.terms.acknowledgements.length &&
      _signature.text.trim().length >= 3 &&
      _name.text.trim().length >= 2 &&
      _role.text.trim().isNotEmpty;

  Future<void> _sign() async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await ref
          .read(vendorApiProvider)
          .vendor
          .signPartnerAgreement(
            body: SignPartnerAgreementBody(
              signatoryName: _name.text.trim(),
              signatoryRole: _role.text.trim(),
              signatureText: _signature.text.trim(),
              acknowledgedClauses: _ticked.toList(),
            ),
          )
          .orThrow();

      if (!mounted) return;
      refreshAfterWriteFrom(ref);
      ref.invalidate(onboardingProvider);
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final terms = widget.terms;

    return Scaffold(
      appBar: AppBar(title: Text(context.t('Partner agreement'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
          children: [
            const SizedBox(height: Space.md),
            Text(terms.title, style: context.text.headlineLarge),
            const SizedBox(height: Space.xxs),
            Row(
              children: [
                // Which version they are signing. An agreement pointing at
                // "the current terms" is worth very little once the terms move
                // on, which is why these are versioned at all.
                StatusPill('v${terms.version}', tone: StatusTone.neutral),
                const SizedBox(width: Space.xs),
                Text(
                  'Effective ${terms.effectiveFrom}',
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.md),
            Text(terms.summary, style: context.text.bodyLarge),

            for (final section in terms.sections) ...[
              const SizedBox(height: Space.lg),
              Text(section.heading, style: context.text.headlineSmall),
              const SizedBox(height: Space.xs),
              Text(section.body, style: context.text.bodyMedium),
            ],

            SectionHead(
              context.t('Acknowledgements'),
              eyebrow: context.t('Tick each one'),
            ),
            Text(
              context.t(
                'Each of these is confirmed separately, and recorded separately.',
              ),
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Space.sm),

            for (final clause in terms.acknowledgements)
              AanganCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.xs,
                  vertical: Space.xxs,
                ),
                child: CheckboxListTile(
                  value: _ticked.contains(clause.key),
                  onChanged: _busy
                      ? null
                      : (on) => setState(() {
                          if (on ?? false) {
                            _ticked.add(clause.key);
                          } else {
                            _ticked.remove(clause.key);
                          }
                        }),
                  title: Text(clause.label, style: context.text.bodyMedium),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),

            SectionHead(
              context.t('Signature'),
              eyebrow: context.t('Typed, and stored as typed'),
            ),
            TextField(
              controller: _name,
              enabled: !_busy,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: context.t('Signatory name'),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: Space.sm),
            TextField(
              controller: _role,
              enabled: !_busy,
              decoration: InputDecoration(labelText: context.t('Role')),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: Space.sm),
            TextField(
              controller: _signature,
              enabled: !_busy,
              decoration: InputDecoration(
                labelText: context.t('Type your full name to sign'),
              ),
              onChanged: (_) => setState(() {}),
            ),

            if (_error != null) ...[
              const SizedBox(height: Space.md),
              ErrorState(
                error: _error!,
                onRetry: () => setState(() => _error = null),
              ),
            ],

            const SizedBox(height: Space.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                // Disabled until every clause is ticked. No "accept all", and
                // no way to reach the server without the individual keys it
                // stores.
                onPressed: _complete && !_busy ? _sign : null,
                child: _busy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _complete
                            ? context.t('Sign and continue')
                            : 'Tick all ${terms.acknowledgements.length} to continue',
                      ),
              ),
            ),
            const SizedBox(height: Space.xs),
            Text(
              context.t(
                'Signing records the time, your IP and your device, so the '
                'agreement can be evidenced later.',
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
