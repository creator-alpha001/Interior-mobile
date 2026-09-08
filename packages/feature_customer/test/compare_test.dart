/// Comparing quotes, which is what this screen is named after.
///
/// Each quote's own card is most of a screen tall — materials, line items,
/// warranty, a rating and a button — so three of them meant scrolling past
/// three screens and holding the numbers in your head. That is three quotes in
/// a row, not a comparison. The table puts the three deciding figures in view
/// at once; the cards are what somebody reads *after* they know which two they
/// are choosing between.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:aangan_feature_customer/aangan_feature_customer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

Future<void> _pump(WidgetTester tester, List<QuoteView> quotes) async {
  tester.view.physicalSize = const Size(1200, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [customerApiProvider.overrideWithValue(fixtureApi())],
      child: MaterialApp(
        theme: AanganTheme.light,
        home: QuoteComparisonScreen(
          service: fixtureService(quotes: quotes),
          requirementId: 'lead-1',
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('marks the best figure in each column, in words', (tester) async {
    // Colour alone would leave the whole comparison invisible to anybody who
    // cannot separate terracotta from ink — on the one screen whose entire
    // job is comparing.
    await _pump(tester, [
      fixtureQuoteView(total: 100000),
      fixtureQuoteView(quoteId: 'q2', total: 150000),
    ]);

    expect(find.text('LOWEST'), findsOneWidget);
    expect(find.text('FASTEST'), findsWidgets);
    expect(find.text('LONGEST'), findsWidgets);
  });

  testWidgets('an unrated professional is not shown as nought out of five', (
    tester,
  ) async {
    /// The bug this test exists for.
    ///
    /// `domainRating` is not null for somebody nobody has reviewed — it comes
    /// back with an average of zero and a count of zero. Null-checking it
    /// printed "0.0 ★": the worst possible score, shown for the absence of any
    /// score, on the screen where a customer is choosing between people. The
    /// detail card had always said "No ratings yet"; the table disagreed with
    /// it three lines above.
    await _pump(tester, [fixtureQuoteView(rated: false)]);

    expect(find.text('0.0 ★'), findsNothing);
  });

  testWidgets('a rated professional still shows the trade rating', (
    tester,
  ) async {
    await _pump(tester, [
      fixtureQuoteView(total: 100000),
      fixtureQuoteView(quoteId: 'q2', total: 150000),
    ]);

    // 4.6 is the fixture's rating *in this trade*, not its 4.1 blended one.
    expect(find.text('4.6 ★'), findsWidgets);
    expect(find.text('4.1 ★'), findsNothing);
  });

  testWidgets('one quote needs no table', (tester) async {
    // There is nothing to compare, and a one-row table is furniture.
    await _pump(tester, [fixtureQuoteView()]);

    expect(find.text('LOWEST'), findsNothing);
  });
}
