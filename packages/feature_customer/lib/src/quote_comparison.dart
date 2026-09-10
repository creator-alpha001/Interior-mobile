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

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_design/interiobee_design.dart';
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
              const SizedBox(height: Space.md),
              ActionRequired(
                title: context.t('Your turn'),
                body: context.t(
                  'Nothing moves until you choose. Take your time — the '
                  'ratings beside each price are for this trade only.',
                ),
              ),
            ],

            /// **The comparison, before the reading.**
            ///
            /// Each quote's own card is most of a screen tall — materials,
            /// line items, warranty, a rating and a button — so comparing
            /// three meant scrolling past three of them and holding the
            /// numbers in your head. That is not a comparison; it is three
            /// quotes in a row.
            ///
            /// The web solves this with a table, and the table is the right
            /// answer on a phone too: the three figures that actually decide
            /// it, aligned in columns, all visible at once. The cards below
            /// are then what somebody reads *after* they know which two they
            /// are choosing between.
            if (quotes.length > 1) ...[
              const SizedBox(height: Space.lg),
              _AtAGlance(quotes: quotes, domain: service.domain),
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
              InterioBeeCard(
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

/// Every quote's decisive figures, in one table.
class _AtAGlance extends StatelessWidget {
  const _AtAGlance({required this.quotes, required this.domain});

  final List<QuoteView> quotes;
  final Domain domain;

  @override
  Widget build(BuildContext context) {
    /// The winner in each column, worked out once.
    ///
    /// One quote can win more than one, and often the cheapest is also the
    /// slowest — which is exactly the trade-off this screen exists to make
    /// visible.
    final cheapest = quotes
        .map((q) => q.quote.total)
        .reduce((a, b) => a < b ? a : b);
    final fastest = quotes
        .map((q) => q.quote.timelineDays)
        .reduce((a, b) => a < b ? a : b);
    final longest = quotes
        .map((q) => q.quote.warrantyMonths)
        .reduce((a, b) => a > b ? a : b);

    return InterioBeeCard(
      padding: const EdgeInsets.all(Space.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(flex: 4, child: SizedBox.shrink()),
              _Head(context.t('Price'), flex: 4),
              _Head(context.t('Time'), flex: 2),
              _Head(context.t('Warranty'), flex: 3),
            ],
          ),
          const SizedBox(height: Space.xxs),
          const InterioBeeDivider(inset: 0),

          for (final (index, view) in quotes.indexed) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ${view.professional.companyName}',
                          style: context.text.bodyMedium,
                          maxLines: 2,
                        ),

                        /// The rating for **this trade**, never the blended
                        /// one. A carpentry average under a painting heading
                        /// is the wrong number under the right label.
                        ///
                        /// `ratingCount`, not a null check. The object is
                        /// present for an unrated professional with an average
                        /// of zero, so testing for null printed "0.0 ★" — a
                        /// professional with no reviews shown as the worst
                        /// possible score, on the screen where somebody is
                        /// choosing between them. The card below always got
                        /// this right; the table did not.
                        Text(
                          (view.professional.domainRating?.ratingCount ?? 0) ==
                                  0
                              ? context.t('Not yet rated here')
                              : '${view.professional.domainRating!.avgRating.toStringAsFixed(1)} ★',
                          style: context.text.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _Cell(
                    value: Rupees(view.quote.total).formatted,
                    best: view.quote.total == cheapest,
                    bestLabel: context.t('Lowest'),
                    flex: 4,
                    tabular: true,
                  ),
                  _Cell(
                    value: context.t('{n}d', {'n': view.quote.timelineDays}),
                    best: view.quote.timelineDays == fastest,
                    bestLabel: context.t('Fastest'),
                    flex: 2,
                  ),
                  _Cell(
                    value: context.t('{n} mo', {
                      'n': view.quote.warrantyMonths,
                    }),
                    best: view.quote.warrantyMonths == longest,
                    bestLabel: context.t('Longest'),
                    flex: 3,
                  ),
                ],
              ),
            ),
            if (index < quotes.length - 1) const InterioBeeDivider(inset: 0),
          ],

          const SizedBox(height: Space.xs),

          /// Said once, here, because it is the question a price invites and
          /// the web's own table answers it in the same words.
          Text(
            context.t('Sorted by price. All figures include GST.'),
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Head extends StatelessWidget {
  const _Head(this.label, {required this.flex});

  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label.toUpperCase(),
        textAlign: TextAlign.right,
        style: InterioBeeTextStyles.eyebrow.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
        semanticsLabel: label,
      ),
    );
  }
}

/// One figure, and a word when it is the best of its column.
///
/// The word matters. Marking the winner by colour alone would leave the whole
/// comparison invisible to anybody who cannot separate terracotta from ink,
/// which on a screen whose entire job is comparing is the wrong corner to cut.
class _Cell extends StatelessWidget {
  const _Cell({
    required this.value,
    required this.best,
    required this.bestLabel,
    required this.flex,
    this.tabular = false,
  });

  final String value;
  final bool best;
  final String bestLabel;
  final int flex;
  final bool tabular;

  @override
  Widget build(BuildContext context) {
    final colour = best ? context.colors.primary : context.colors.onSurface;

    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            value,
            textAlign: TextAlign.right,
            style: tabular
                ? InterioBeeTextStyles.financialNum.copyWith(
                    fontSize: 15,
                    height: 20 / 15,
                    color: colour,
                  )
                : context.text.bodyMedium?.copyWith(color: colour),
          ),
          if (best)
            Text(
              bestLabel.toUpperCase(),
              textAlign: TextAlign.right,
              style: InterioBeeTextStyles.eyebrow.copyWith(
                color: context.colors.primary,
              ),
              semanticsLabel: bestLabel,
            ),
        ],
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

    return InterioBeeCard(
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
                          // Sage: a person at Decora Shine verified them.
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
            context.t('{days} days · {months} months warranty', {
              'days': view.quote.timelineDays,
              'months': view.quote.warrantyMonths,
            }),
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),

          if (view.quote.materialsSummary.isNotEmpty) ...[
            const SizedBox(height: Space.sm),
            const InterioBeeDivider(inset: 0),
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
                context.l10n.plural(
                  view.quote.lineItems.length,
                  '{n} line',
                  '{n} lines',
                ),
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
