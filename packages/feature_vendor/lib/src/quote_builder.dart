/// Building a quote.
///
/// Quotes are versioned server-side and there is a database constraint allowing
/// exactly one live quote per vendor per service. MOBILE.md §6.2 draws the
/// consequence: *"Show 'this replaces quote v2' before submitting, not after
/// the 409."* Discovering the rule from an error is a worse experience than
/// being told it up front, and the vendor has usually forgotten what they
/// quoted last time.
///
/// Everything is whole rupees. The total is computed here for the vendor to
/// see, and computed again server-side for the record — this arithmetic is a
/// preview, never the source of truth.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// One line while it is being typed. Not the wire shape.
class _Line {
  _Line();

  final description = TextEditingController();
  final quantity = TextEditingController(text: '1');
  final unit = TextEditingController(text: 'piece');
  final rate = TextEditingController();

  void dispose() {
    description.dispose();
    quantity.dispose();
    unit.dispose();
    rate.dispose();
  }

  num get quantityValue => num.tryParse(quantity.text.trim()) ?? 0;
  int get rateValue => int.tryParse(rate.text.trim()) ?? 0;
  int get amount => (quantityValue * rateValue).round();

  bool get isComplete =>
      description.text.trim().isNotEmpty && quantityValue > 0 && rateValue > 0;

  QuoteLineDraft toDraft() => QuoteLineDraft(
        description: description.text.trim(),
        quantity: quantityValue,
        unit: unit.text.trim(),
        rate: rateValue,
      );
}

class QuoteBuilderScreen extends ConsumerStatefulWidget {
  const QuoteBuilderScreen({super.key, required this.lead});

  final VendorLeadCard lead;

  @override
  ConsumerState<QuoteBuilderScreen> createState() => _QuoteBuilderScreenState();
}

class _QuoteBuilderScreenState extends ConsumerState<QuoteBuilderScreen> {
  final _lines = <_Line>[_Line()];
  final _tax = TextEditingController(text: '18');
  final _timeline = TextEditingController(text: '30');
  final _warrantyMonths = TextEditingController(text: '12');
  final _warrantyDetails = TextEditingController();
  final _materials = TextEditingController();
  final _notes = TextEditingController();

  bool _busy = false;

  @override
  void dispose() {
    for (final line in _lines) {
      line.dispose();
    }
    _tax.dispose();
    _timeline.dispose();
    _warrantyMonths.dispose();
    _warrantyDetails.dispose();
    _materials.dispose();
    _notes.dispose();
    super.dispose();
  }

  int get _subtotal => _lines.fold(0, (sum, line) => sum + line.amount);
  num get _taxPercent => num.tryParse(_tax.text.trim()) ?? 0;
  int get _taxAmount => (_subtotal * _taxPercent / 100).round();
  int get _total => _subtotal + _taxAmount;

  bool get _valid =>
      _lines.any((line) => line.isComplete) &&
      _lines.where((line) => !line.isComplete).isEmpty &&
      int.tryParse(_timeline.text.trim()) != null;

  Future<void> _submit() async {
    final existing = widget.lead.myQuote;

    if (existing != null) {
      // Before the request, not after the 409. The constraint is one live
      // quote per vendor per service, so this genuinely replaces the old one.
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Replace quote v${existing.version}?'),
          content: Text(
            'Your current quote of ${Rupees(existing.total).formatted} will be '
            'superseded by this one. The customer sees only the new version.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep the old one'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Replace with v${existing.version + 1}'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _busy = true);

    try {
      await ref
          .read(apiProvider)
          .vendor
          .submitQuote(
            id: widget.lead.leadDomain.id,
            body: SubmitQuoteBody(
              lineItems: [
                for (final line in _lines)
                  if (line.isComplete) line.toDraft(),
              ],
              taxPercent: _taxPercent,
              timelineDays: int.parse(_timeline.text.trim()),
              warrantyMonths: int.tryParse(_warrantyMonths.text.trim()) ?? 0,
              warrantyDetails: _warrantyDetails.text.trim(),
              materialsSummary: _materials.text.trim(),
              notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
            ),
          )
          .orThrow();

      if (!mounted) return;
      refreshAfterWriteFrom(ref);
      ref.invalidate(leadProvider(widget.lead.leadDomain.id));
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);

      // A 409 here means the version moved under us — somebody submitted from
      // another device, or a retry landed twice. Re-read rather than guess.
      final message = error.failure == ApiFailure.conflict
          ? 'Your quote has changed since this screen opened. Close and reopen '
              'the lead to see the current one.'
          : error.message;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.lead.myQuote;
    final labels = widget.lead.domain.labels;

    return Scaffold(
      appBar: AppBar(
        title: Text(existing == null ? 'New quote' : 'Revise quote'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
          children: [
            if (existing != null) ...[
              const SizedBox(height: Space.md),
              ActionRequired(
                title: 'This replaces quote v${existing.version}',
                body: 'Currently ${Rupees(existing.total).formatted}. One quote '
                    'per job is live at a time; sending this supersedes it.',
              ),
            ],

            const SectionHead('Lines', eyebrow: 'What you are pricing'),
            for (final (index, line) in _lines.indexed) ...[
              _LineEditor(
                line: line,
                index: index,
                unitHint: labels.pricingBasis,
                onChanged: () => setState(() {}),
                onRemove: _lines.length == 1
                    ? null
                    : () => setState(() {
                          _lines.removeAt(index).dispose();
                        }),
              ),
              const SizedBox(height: Space.xs),
            ],
            OutlinedButton.icon(
              onPressed: () => setState(() => _lines.add(_Line())),
              icon: const Icon(Icons.add, size: TapTarget.glyph),
              label: const Text('Add a line'),
            ),

            const SectionHead('Total', eyebrow: 'Whole rupees'),
            AanganCard(
              padding: const EdgeInsets.all(Space.cardPaddingWide),
              child: Column(
                children: [
                  _TotalRow(label: 'Subtotal', amount: _subtotal),
                  const SizedBox(height: Space.xs),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Tax %', style: context.text.bodyMedium),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _tax,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                          ],
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Space.xs),
                  _TotalRow(label: 'Tax', amount: _taxAmount),
                  const SizedBox(height: Space.sm),
                  const AanganDivider(inset: 0),
                  const SizedBox(height: Space.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Total', style: context.text.titleLarge),
                      ),
                      MoneyText(Rupees(_total).formatted),
                    ],
                  ),
                  if (widget.lead.budgetMax != null &&
                      _total > widget.lead.budgetMax!) ...[
                    const SizedBox(height: Space.xs),
                    Text(
                      // Not blocked — a ceiling is a signal, not a rule, and a
                      // job may genuinely cost more. But say so before sending.
                      'Above the customer’s stated ceiling of '
                      '${Rupees(widget.lead.budgetMax!).formatted}.',
                      style: context.text.bodySmall
                          ?.copyWith(color: context.palette.waiting),
                    ),
                  ],
                ],
              ),
            ),

            const SectionHead('Terms', eyebrow: 'What you are committing to'),
            AanganCard(
              padding: const EdgeInsets.all(Space.cardPaddingWide),
              child: Column(
                children: [
                  TextField(
                    controller: _timeline,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Working days'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: Space.sm),
                  TextField(
                    controller: _warrantyMonths,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Warranty (months)'),
                  ),
                  const SizedBox(height: Space.sm),
                  TextField(
                    controller: _warrantyDetails,
                    maxLines: 2,
                    // The caption changes per trade — "Material Grade" for
                    // fabrication, and so on. One component, each trade's words.
                    decoration: InputDecoration(labelText: labels.warranty),
                  ),
                  const SizedBox(height: Space.sm),
                  TextField(
                    controller: _materials,
                    maxLines: 3,
                    decoration: InputDecoration(labelText: labels.materials),
                  ),
                  const SizedBox(height: Space.sm),
                  TextField(
                    controller: _notes,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notes for the coordinator (optional)',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: Space.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _valid && !_busy ? _submit : null,
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
                        existing == null
                            ? 'Send quote · ${Rupees(_total).formatted}'
                            : 'Replace with v${existing.version + 1}',
                      ),
              ),
            ),
            const SizedBox(height: Space.xs),
            Text(
              'The coordinator reviews this before the customer sees it.',
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

class _LineEditor extends StatelessWidget {
  const _LineEditor({
    required this.line,
    required this.index,
    required this.unitHint,
    required this.onChanged,
    this.onRemove,
  });

  final _Line line;
  final int index;
  final String unitHint;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return AanganCard(
      child: Column(
        children: [
          Row(
            children: [
              Text('${index + 1}', style: context.text.titleLarge),
              const SizedBox(width: Space.xs),
              Expanded(
                child: TextField(
                  controller: line.description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (_) => onChanged(),
                ),
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, size: TapTarget.glyph),
                  tooltip: 'Remove this line',
                ),
            ],
          ),
          const SizedBox(height: Space.xs),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: line.quantity,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Qty'),
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: Space.xs),
              Expanded(
                child: TextField(
                  controller: line.unit,
                  decoration: InputDecoration(labelText: 'Unit', hintText: unitHint),
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: Space.xs),
              Expanded(
                child: TextField(
                  controller: line.rate,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Rate ₹'),
                  onChanged: (_) => onChanged(),
                ),
              ),
            ],
          ),
          if (line.amount > 0) ...[
            const SizedBox(height: Space.xs),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                Rupees(line.amount).formatted,
                style: context.text.titleMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.amount});

  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: context.text.bodyMedium)),
        Text(Rupees(amount).formatted, style: context.text.titleMedium),
      ],
    );
  }
}
