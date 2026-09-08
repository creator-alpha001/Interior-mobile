/// The vendor's agreements, and their own profile.
///
/// Two of the web's `/partner/projects` and `/partner/profile` that the app
/// never rendered. `agreementsProvider` already existed in `providers.dart`
/// with nothing reading it — the same signal as an unreachable client method,
/// one level up.
///
/// **A combined agreement is one contract and several jobs.** When one
/// professional wins two of a customer's trades that is a single agreement, and
/// a vendor who reads it as two will invoice twice and chase a payment that was
/// never owed. The card says so where it happens.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'providers.dart';

class VendorAgreementsScreen extends ConsumerWidget {
  const VendorAgreementsScreen({super.key});

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
                    'One is drawn up when a customer picks your quote.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(Space.gutter),
                  itemCount: list.length,
                  separatorBuilder: (context, i) =>
                      const SizedBox(height: Space.sm),
                  itemBuilder: (context, i) => _AgreementCard(view: list[i]),
                ),
        ),
      ),
    );
  }
}

class _AgreementCard extends StatelessWidget {
  const _AgreementCard({required this.view});

  final VendorAgreementView view;

  @override
  Widget build(BuildContext context) {
    final signed = view.agreement.status == AgreementStatus.signed;

    return AanganCard(
      padding: const EdgeInsets.all(Space.cardPaddingWide),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  view.agreement.reference,
                  style: context.text.titleLarge,
                ),
              ),
              StatusPill(
                view.agreement.status.name,
                tone: signed ? StatusTone.verified : StatusTone.waiting,
              ),
            ],
          ),
          const SizedBox(height: Space.xxs),

          /// The masked client. There is no phone number on this object to
          /// leak — `MaskedClientSummary` has no field for one.
          Text(
            view.client.displayName,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: Space.sm),
          MoneyText(Rupees(view.agreement.totalValue).formatted),

          if (view.isCombined) ...[
            const SizedBox(height: Space.sm),
            AanganCard(
              nested: true,
              child: Text(
                context.l10n.plural(
                  view.lines.length,
                  'One contract covering {n} job. Execution still runs '
                      'per job, and commission is invoiced once.',
                  'One contract covering {n} jobs. Execution still runs '
                      'per job, and commission is invoiced once.',
                ),
                style: context.text.bodySmall,
              ),
            ),
          ],

          if (view.invoice != null) ...[
            const SizedBox(height: Space.sm),
            Row(
              children: [
                Text(
                  context.t('Commission'),
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  Rupees(view.invoice!.amount).formatted,
                  style: context.text.titleMedium,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// The vendor's own record, as the web's `/partner/profile` shows it.
class VendorProfileScreen extends ConsumerWidget {
  const VendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.t('Your profile'))),
      body: SafeArea(
        child: AsyncView(
          value: dashboard,
          onRetry: () => ref.invalidate(dashboardProvider),
          data: (data) => ListView(
            padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
            children: [
              const SizedBox(height: Space.md),
              Text(
                data.professional.companyName,
                style: context.text.displayLarge,
              ),
              const SizedBox(height: Space.xs),
              Text(
                data.displayName,
                style: context.text.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),

              if (data.professional.bio.isNotEmpty) ...[
                const SizedBox(height: Space.md),
                Text(data.professional.bio, style: context.text.bodyMedium),
              ],

              SectionHead(
                context.t('Approved trades'),
                eyebrow: context.t('What you may be sent'),
              ),
              Wrap(
                spacing: Space.xxs,
                runSpacing: Space.xxs,
                children: [
                  // Approved only. A trade still under review is not one a
                  // lead can be sent for, and showing it as approved here
                  // would be the app contradicting the onboarding gate.
                  for (final link in data.domains)
                    if (link.link.verificationStatus ==
                        DomainApprovalStatus.approved)
                      StatusPill(link.domain.name, tone: StatusTone.verified),
                ],
              ),

              SectionHead(
                context.t('On record'),
                eyebrow: context.t('What customers see'),
              ),
              _Fact(
                label: context.t('Experience'),
                value: context.l10n.plural(
                  data.professional.experienceYears.round(),
                  '{n} year',
                  '{n} years',
                ),
              ),
              _Fact(
                label: context.t('Jobs completed'),
                value: '${data.professional.completedProjects}',
              ),
              _Fact(
                label: context.t('Median response'),
                value: context.l10n.plural(
                  data.professional.avgResponseHours.round(),
                  '{n} hour',
                  '{n} hours',
                ),
              ),

              SectionHead(
                context.t('Business details'),
                eyebrow: context.t('What we hold on file'),
              ),
              _Fact(label: context.t('Contact'), value: data.displayName),
              _Fact(
                label: context.t('GST'),
                value:
                    data.professional.gstNumber ?? context.t('Not registered'),
              ),
              if (data.professional.languages.isNotEmpty)
                _Fact(
                  label: context.t('Languages'),
                  value: data.professional.languages.join(', '),
                ),

              /// Editing is not self-service anywhere — not here and not on
              /// the web, which has no form for it and no endpoint behind one.
              ///
              /// This is the same rule as trade approval: what a customer sees
              /// about a professional is changed by a person at Aangan, not by
              /// the professional. Saying "not built yet" would have described
              /// a mobile shortfall that does not exist.
              const SizedBox(height: Space.lg),
              AanganCard(
                nested: true,
                child: Text(
                  context.t(
                    'To change any of this, message your coordinator. Your '
                    'public record is edited by our team, the same way trade '
                    'approval is — never from an app.',
                  ),
                  style: context.text.bodySmall,
                ),
              ),
              const SizedBox(height: Space.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xxs),
      child: Row(
        children: [
          SizedBox(
            width: 150,
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
