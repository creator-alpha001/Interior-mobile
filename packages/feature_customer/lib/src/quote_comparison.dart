/// Choosing a professional, by comparing their quotes.
///
/// The prototype's vault block with the vault taken out: a large tabular
/// figure, numbered rows, and each professional's rating **in this trade**
/// beside their price. That last part is not decoration — a good carpenter is
/// not automatically a good painter, ratings are held per trade, and the
/// directory ranks by the rating in the trade being browsed. Showing an overall
/// star average here would be showing the wrong number.
///
/// Selecting is a commitment: it sets the winning quote for the service and is
/// what an agreement is later generated from. So the screen says what happens
/// next before the tap, not after.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

class QuoteComparisonScreen extends ConsumerStatefulWidget {
  const QuoteComparisonScreen({
    super.key,
    required this.service,
    required this.requirementId,
  });

  final LeadDomainView service;
  final String requirementId;

  @override
  ConsumerState<QuoteComparisonScreen> createState() =>
      _QuoteComparisonScreenState();
}

class _QuoteComparisonScreenState extends ConsumerState<QuoteComparisonScreen> {
  String? _busyQuoteId;

  Future<void> _select(QuoteView view) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          context.t('Choose {name}?', {'name': view.professional.companyName}),
        ),
        content: Text(
          context.t(
            'We will draw up an agreement for {amount} and send it to you to '
            'sign. The other quotes for this job close.',
            {'amount': Rupees(view.quote.total).formatted},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.t('Not yet')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.t('Choose them')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busyQuoteId = view.quote.id);

    try {
      await ref
          .read(customerApiProvider)
          .customer
          .selectQuote(
            id: widget.service.leadDomain.id,
            body: SelectQuoteBody(quoteId: view.quote.id),
          )
          .orThrow();

      if (!mounted) return;
      refreshAfterWrite(ref);
      ref.invalidate(requirementProvider(widget.requirementId));
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _busyQuoteId = null);

      // A 409 means the quote moved — most often a vendor revised it while
      // this screen was open. Re-read rather than guess which version won.
      final message = error.failure == ApiFailure.conflict
          ? context.t(
              'That quote has been revised since you opened this screen. '
              'Pull to refresh to see the current one.',
            )
          : error.message;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    // Cheapest first. Not a recommendation — the rating beside each price is
    // there so cheapest is not read as best.
    final quotes = [...service.quotes]
      ..sort((a, b) => a.quote.total.compareTo(b.quote.total));

    final selected = service.leadDomain.selectedQuoteId;

    return Scaffold(
      appBar: AppBar(title: Text(service.domain.name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
          children: [
            const SizedBox(height: Space.md),
            Text(context.t('Compare quotes'), style: context.text.displayLarge),
            const SizedBox(height: Space.xs),
            Text(
              quotes.isEmpty
                  ? context.t('No quotes yet. We are still gathering them.')
                  : context.l10n
                        .plural(
                          quotes.length,
                          context.t(
                            '{n} professional has quoted for your {trade}.',
                          ),
                          context.t(
                            '{n} professionals have quoted for your {trade}.',
                          ),
                        )
                        .replaceAll(
                          '{trade}',
                          service.domain.name.toLowerCase(),
                        ),
              style: context.text.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),

            if (selected == null && quotes.isNotEmpty) ...[
              const SizedBox(height: Space.lg),
              ActionRequired(
                title: context.t('Your turn'),
                body: context.t(
                  'Nothing moves until you choose. Take your time — the '
                  'ratings beside each price are for this trade only.',
                ),
              ),
            ],

            const SizedBox(height: Space.lg),
            for (final (index, view) in quotes.indexed) ...[
              _QuoteRow(
                index: index + 1,
                view: view,
                isSelected: selected == view.quote.id,
                isLocked: selected != null,
                busy: _busyQuoteId == view.quote.id,
                onSelect: () => _select(view),
              ),
              const SizedBox(height: Space.sm),
            ],

            if (quotes.isEmpty) ...[
              const SizedBox(height: Space.lg),
              AanganCard(
                padding: const EdgeInsets.all(Space.cardPaddingWide),
                child: Text(
                  context.t(
                    'Our coordinator calls each professional before offering them '
                    'your job, so quotes arrive over a day or two rather than '
                    'instantly.',
                  ),
                  style: context.text.bodyMedium,
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

class _QuoteRow extends StatelessWidget {
  const _QuoteRow({
    required this.index,
    required this.view,
    required this.isSelected,
    required this.isLocked,
    required this.busy,
    required this.onSelect,
  });

  final int index;
  final QuoteView view;
  final bool isSelected;
  final bool isLocked;
  final bool busy;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final professional = view.professional;

    /// The rating **in this trade**, not the overall average.
    ///
    /// `domainRating` is populated when a vendor is viewed in the context of
    /// one domain, which is exactly this screen. Falling back to the overall
    /// figure would quietly show a different number under the same label, so
    /// the label changes with it.
    final domainRating = professional.domainRating;
    final showsTradeRating = domainRating != null;
    final rating = domainRating?.avgRating ?? professional.avgRating;
    final ratingCount = domainRating?.ratingCount ?? professional.ratingCount;

    return AanganCard(
      padding: const EdgeInsets.all(Space.cardPaddingWide),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The numbered rhythm from the prototype's tranche rows.
              Text(
                '$index',
                style: context.text.displayLarge?.copyWith(
                  color: context.colors.outline,
                ),
              ),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            professional.companyName,
                            style: context.text.headlineSmall,
                          ),
                        ),
                        if (professional.isVerified)
                          // Sage: a person at Aangan verified them.
                          StatusPill(
                            context.t('Verified'),
                            tone: StatusTone.verified,
                          ),
                      ],
                    ),
                    const SizedBox(height: Space.xxs),
                    Text(
                      ratingCount == 0
                          ? context.t('No ratings in {trade} yet', {
                              'trade': view.domain.name,
                            })
                          : showsTradeRating
                          ? context.l10n
                                .plural(
                                  ratingCount,
                                  context.t(
                                    '{rating} ★ · {n} review in {trade}',
                                  ),
                                  context.t(
                                    '{rating} ★ · {n} reviews in {trade}',
                                  ),
                                )
                                .replaceAll(
                                  '{rating}',
                                  rating.toStringAsFixed(1),
                                )
                                .replaceAll('{trade}', view.domain.name)
                          : context.l10n
                                .plural(
                                  ratingCount,
                                  context.t('{rating} ★ · {n} review overall'),
                                  context.t('{rating} ★ · {n} reviews overall'),
                                )
                                .replaceAll(
                                  '{rating}',
                                  rating.toStringAsFixed(1),
                                ),
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: Space.md),
          MoneyText(Rupees(view.quote.total).formatted),
          const SizedBox(height: Space.xxs),
          Text(
            '${view.quote.timelineDays} days · '
            '${view.quote.warrantyMonths} months warranty',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),

          if (view.quote.materialsSummary.isNotEmpty) ...[
            const SizedBox(height: Space.sm),
            const AanganDivider(inset: 0),
            const SizedBox(height: Space.sm),
            Text(view.domain.labels.materials, style: context.text.labelMedium),
            const SizedBox(height: Space.xxs),
            Text(view.quote.materialsSummary, style: context.text.bodyMedium),
          ],

          if (view.quote.lineItems.isNotEmpty) ...[
            const SizedBox(height: Space.sm),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              shape: const Border(),
              collapsedShape: const Border(),
              title: Text(
                '${view.quote.lineItems.length} lines',
                style: context.text.titleMedium,
              ),
              children: [
                for (final line in view.quote.lineItems)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.xxs),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${line.description} · ${line.quantity} ${line.unit}',
                            style: context.text.bodySmall,
                          ),
                        ),
                        Text(
                          Rupees(line.amount).formatted,
                          style: context.text.bodySmall,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],

          const SizedBox(height: Space.md),
          if (isSelected)
            StatusPill(
              context.t('You chose this one'),
              tone: StatusTone.verified,
            )
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLocked || busy ? null : onSelect,
                child: busy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isLocked
                            ? context.t('Not chosen')
                            : context.t('Choose this quote'),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
