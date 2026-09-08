/// The home screen as a way into the customer's own work.
///
/// It used to be four trade cards and a sales panel, with the customer's live
/// jobs reachable only if they knew which tab they were under — and the one
/// panel that did mention them ("quotes are ready for 2 of your jobs") was a
/// statement with nothing to press.
///
/// Two states, and the distinction between them is the delicate part:
///
///   * **Nothing under way**, which we only claim when the request came back
///     *empty*. Telling somebody they have no jobs because a read failed would
///     be a lie with a button on it.
///   * **Something under way**, listed with the state that matters and a way
///     in. Quotes to choose outrank everything else, because that is the only
///     state where the customer is the one holding the job up.
library;

import 'dart:async';

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:aangan_feature_customer/aangan_feature_customer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

/// Finds a [StatusPill] by its label.
///
/// The pill uppercases for display and keeps the original in `semanticsLabel`.
/// `find.text` would need 'CHOOSE A QUOTE', which reads as a shout in a test
/// and couples it to a styling choice. Same finder as the vendor suite's.
Finder findPill(String label) => find.byWidgetPredicate(
  (w) => w is Text && w.semanticsLabel == label,
  description: 'status pill "$label"',
);

Future<void> _pump(
  WidgetTester tester, {
  AsyncValue<List<LeadView>> requirements = const AsyncValue.data([]),
  List<AgreementView> agreements = const [],
  List<ProjectView> projects = const [],
  VoidCallback? onStart,
  VoidCallback? onOpenJobs,
}) async {
  tester.view.physicalSize = const Size(1200, 5000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerApiProvider.overrideWithValue(fixtureApi()),
        domainsProvider.overrideWith((ref) async => const []),
        bannersProvider.overrideWith((ref) async => const []),
        testimonialsProvider.overrideWith((ref) async => const []),
        catalogueCountsProvider.overrideWith((ref) async => const []),
        agreementsProvider.overrideWith((ref) async => agreements),
        projectsProvider.overrideWith((ref) async => projects),
        requirementsProvider.overrideWith(
          (ref) => requirements.when(
            data: (list) => Future.value(list),
            loading: () => Completer<List<LeadView>>().future,
            error: (e, _) => Future<List<LeadView>>.error(e),
          ),
        ),
      ],
      child: MaterialApp(
        theme: AanganTheme.light,
        home: HomeScreen(
          onStart: onStart ?? () {},
          onOpenJobs: onOpenJobs ?? () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('with nothing under way', () {
    testWidgets('offers a way to get quotes', (tester) async {
      await _pump(tester);

      expect(find.text('Nothing under way yet'), findsOneWidget);
      expect(find.text('Get quotes'), findsOneWidget);
    });

    testWidgets('the button starts a requirement', (tester) async {
      var started = false;
      await _pump(tester, onStart: () => started = true);

      await tester.tap(find.text('Get quotes'));
      await tester.pump();

      expect(started, isTrue);
    });
  });

  group('with work under way', () {
    testWidgets('lists the job, and says the customer is the blocker', (
      tester,
    ) async {
      await _pump(
        tester,
        requirements: AsyncValue.data([
          fixtureRequirement(
            services: [
              fixtureService(quotes: [fixtureQuoteView()]),
            ],
          ),
        ]),
      );

      expect(find.text('Your work'), findsOneWidget);
      expect(find.text('REQ-1042'), findsOneWidget);
      // Peach, and worded as an instruction rather than a status.
      expect(findPill('Choose a quote'), findsOneWidget);
      // Never the empty state at the same time.
      expect(find.text('Nothing under way yet'), findsNothing);
    });

    testWidgets('the row opens the Jobs tab', (tester) async {
      var opened = false;
      await _pump(
        tester,
        requirements: AsyncValue.data([fixtureRequirement()]),
        onOpenJobs: () => opened = true,
      );

      await tester.tap(find.text('REQ-1042'));
      await tester.pump();

      expect(opened, isTrue);
    });

    testWidgets('does not claim quotes are ready when none are', (
      tester,
    ) async {
      // fixtureService() carries no quotes, so the peach alert must stay away
      // — it means "you are the blocker" and nothing else.
      await _pump(
        tester,
        requirements: AsyncValue.data([fixtureRequirement()]),
      );

      expect(findPill('Choose a quote'), findsNothing);
      expect(findPill('Finding professionals'), findsOneWidget);
    });
  });

  testWidgets('a failed read shows neither the list nor the empty state', (
    tester,
  ) async {
    // The distinction the whole widget turns on. "Nothing under way yet, get
    // quotes" under a customer who has three live jobs and a flaky connection
    // is worse than showing nothing at all.
    await _pump(
      tester,
      requirements: AsyncValue.error(
        const ApiException(
          failure: ApiFailure.serverError,
          code: 'internal_error',
          message: 'down',
        ),
        StackTrace.empty,
      ),
    );

    expect(find.text('Nothing under way yet'), findsNothing);
    expect(find.text('Your work'), findsNothing);
    // The rest of the screen still renders.
    expect(find.text('Aangan'), findsOneWidget);
  });
}
