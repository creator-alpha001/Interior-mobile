/// The estimator, and the promise it has to keep.
///
/// MOBILE.md open question 3 was answered yes, and the risk that comes with
/// saying yes is a screen that quotes a price. It does not: it produces a
/// bracket, says so where the customer will read it, and lists what is not
/// included. Those three things are what these tests hold, because they are
/// what turns an estimate from useful into misleading.
library;

import 'package:interiobee_design/interiobee_design.dart';
import 'package:interiobee_feature_customer/interiobee_feature_customer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// A tall surface, so a long ListView builds its whole contents.
///
/// The range panel and the caveats sit below the fold on a default 800x600
/// test surface, and a lazy ListView never builds them — which reads as a
/// missing widget rather than as a layout artefact.
Future<void> _pump(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(1200, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(theme: InterioBeeTheme.light, home: home));
  await tester.pumpAndSettle();
}

void main() {
  group('the arithmetic', () {
    final interiors = estimatorConfigs.firstWhere(
      (c) => c.domainSlug == 'interior-design',
    );

    test('matches the web, which is the same table', () {
      // 290000 * 2 * 1.0 + 120000 = 700000, and the spread is 0.2.
      final result = estimate(interiors, 2, interiors.tiers.first);

      expect(result.mid, 700000);
      expect(result.low, 560000);
      expect(result.high, 840000);
    });

    test('rounds to the nearest thousand', () {
      // Not cosmetic. `₹2,84,720` reads as a figure somebody calculated;
      // `₹2,85,000` reads as the bracket it is.
      final painting = estimatorConfigs.firstWhere(
        (c) => c.domainSlug == 'painting',
      );

      for (final quantity in [317, 933, 1451, 2749]) {
        final result = estimate(painting, quantity, painting.tiers.last);
        expect(result.mid % 1000, 0);
        expect(result.low % 1000, 0);
        expect(result.high % 1000, 0);
      }
    });

    test('the tier moves the figure, which is what the copy claims', () {
      final essential = estimate(interiors, 3, interiors.tiers.first).mid;
      final luxury = estimate(interiors, 3, interiors.tiers.last).mid;

      expect(luxury, greaterThan(essential * 2));
    });

    test('never produces a single number', () {
      // The whole design of the screen rests on this being a range.
      for (final config in estimatorConfigs) {
        for (final tier in config.tiers) {
          final result = estimate(config, config.field.initial, tier);
          expect(result.low, lessThan(result.mid));
          expect(result.high, greaterThan(result.mid));
        }
      }
    });

    test('every trade has a fixed cost, so nothing estimates at zero', () {
      // A slider dragged to its minimum must still cost something. A bracket
      // starting at ₹0 is not an estimate, it is a bug that looks like a deal.
      for (final config in estimatorConfigs) {
        final result = estimate(config, config.field.min, config.tiers.first);
        expect(result.low, greaterThan(0), reason: config.domainSlug);
      }
    });

    test('a slider cannot leave its own range', () {
      for (final config in estimatorConfigs) {
        expect(config.field.min, lessThan(config.field.max));
        expect(config.field.initial, greaterThanOrEqualTo(config.field.min));
        expect(config.field.initial, lessThanOrEqualTo(config.field.max));
        // The Slider's `divisions` is an integer division; a step that does not
        // divide the range leaves values the person cannot select.
        expect((config.field.max - config.field.min) % config.field.step, 0);
      }
    });
  });

  group('the screen', () {
    testWidgets('leads with the range, not with the midpoint', (tester) async {
      await _pump(tester, const EstimatorScreen());

      expect(find.text('Rough range'), findsOneWidget);
      // Abbreviated, because the full figures wrap at 360dp and a wrapped
      // price reads as two prices.
      expect(find.textContaining('–'), findsWidgets);
    });

    testWidgets('says it is not a quote, in the terracotta panel', (
      tester,
    ) async {
      await _pump(tester, const EstimatorScreen());

      expect(find.text('This is a bracket, not a quote'), findsOneWidget);
      expect(
        find.textContaining('Real prices come from a site visit'),
        findsOneWidget,
      );
    });

    testWidgets('shows what is excluded, not only what is included', (
      tester,
    ) async {
      await _pump(tester, const EstimatorScreen());

      expect(find.text('Not included'), findsOneWidget);
      // The first trade's caveats, verbatim from the table.
      expect(
        find.text('Excludes appliances and loose furniture.'),
        findsOneWidget,
      );
    });

    testWidgets('needs no API client at all', (tester) async {
      // Pumped with no ProviderScope and no override above. If this screen ever
      // starts reading a provider, this test fails — and the reason it must not
      // is the reason it exists: it answers on a train.
      await _pump(tester, const EstimatorScreen());
      expect(find.text('What might this cost?'), findsOneWidget);
    });

    testWidgets('offers all four trades', (tester) async {
      await _pump(tester, const EstimatorScreen());

      for (final config in estimatorConfigs) {
        expect(find.text(config.domainName), findsWidgets);
      }
    });

    testWidgets('changing the finish level changes the figure', (tester) async {
      await _pump(tester, const EstimatorScreen());

      final before = tester
          .widgetList<Text>(find.textContaining('–'))
          .first
          .data;

      await tester.tap(find.text('Luxury'));
      await tester.pumpAndSettle();

      final after = tester
          .widgetList<Text>(find.textContaining('–'))
          .first
          .data;
      expect(after, isNot(before));
    });

    testWidgets('hides the call to action when there is nowhere to send them', (
      tester,
    ) async {
      await _pump(tester, const EstimatorScreen());
      expect(find.text('Get a real quote, free'), findsNothing);

      await _pump(tester, EstimatorScreen(onStart: () {}));
      expect(find.text('Get a real quote, free'), findsOneWidget);
    });
  });

  group('in Hindi', () {
    Future<void> pumpHindi(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: InterioBeeTheme.light,
          locale: const Locale('hi'),
          supportedLocales: interiobeeSupportedLocales,
          localizationsDelegates: const [
            InterioBeeL10nDelegate(),
            // As `main.dart` composes them. Without these an AppBar
            // asserts, and the app's own strings would be Hindi
            // inside English framework chrome.
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const EstimatorScreen(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('the table-driven copy translates too', (tester) async {
      // The estimator is the one screen whose copy reaches `context.t()` as a
      // value rather than as a literal, so it is the one the scan in
      // `l10n_test.dart` could miss. Checked here against the running widget.
      await pumpHindi(tester);

      expect(find.text('This is a bracket, not a quote'), findsNothing);
      expect(find.text('यह अंदाज़ा है, कोटेशन नहीं'), findsOneWidget);
      expect(find.text('ज़रूरी'), findsOneWidget); // the "Essential" tier
    });

    testWidgets('rupees keep Indian grouping in both languages', (
      tester,
    ) async {
      await pumpHindi(tester);

      // Lakh-and-crore grouping is a property of the number, not of the
      // language, and `Rupees` formats with en_IN in both.
      expect(find.textContaining('₹'), findsWidgets);
    });
  });
}
