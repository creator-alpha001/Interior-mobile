/// The home screen as a way into the customer's own work.
///
/// It used to be four trade cards and a sales panel, with the customer's live
/// jobs reachable only if they knew which tab they were under — and the one
/// panel that did mention them ("quotes are ready for 2 of your jobs") was a
/// statement with nothing to press.
///
/// Three things are held here:
///
///   * **The promise leads.** "Homes that feel like you", with the way to get
///     quotes directly under it, whoever is looking.
///   * **Something under way** is listed with the state that matters and a way
///     in — and a failed read shows nothing rather than a lie.
///   * **The setup strip** asks for what signup skipped, says why, and goes
///     away when told to.
library;

import 'dart:async';

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:interiobee_feature_customer/interiobee_feature_customer.dart';
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
  SetupNeeds? setup,
  VoidCallback? onFinishSetup,
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
        theme: InterioBeeTheme.light,
        home: HomeScreen(
          onStart: onStart ?? () {},
          onOpenJobs: onOpenJobs ?? () {},
          setup: setup,
          onFinishSetup: onFinishSetup,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('the hero', () {
    testWidgets('leads with the promise and a way to get quotes', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.byType(DecoraShineLogo), findsOneWidget);
      expect(find.text('Homes that feel like you'), findsOneWidget);
      expect(find.text('Get free design quotes'), findsOneWidget);
    });

    testWidgets('the button starts a requirement', (tester) async {
      var started = false;
      await _pump(tester, onStart: () => started = true);

      await tester.tap(find.text('Get free design quotes'));
      await tester.pump();

      expect(started, isTrue);
    });

    testWidgets('greets a returning customer by name', (tester) async {
      await _pump(
        tester,
        setup: const SetupNeeds(city: false, number: false, firstName: 'Asha'),
      );

      expect(find.text('Welcome back, Asha'), findsOneWidget);
    });
  });

  group('the setup strip', () {
    testWidgets('asks for what signup skipped, and says why', (tester) async {
      var opened = false;
      await _pump(
        tester,
        setup: const SetupNeeds(city: true, number: true),
        onFinishSetup: () => opened = true,
      );

      expect(find.text('Add your mobile number and city'), findsOneWidget);
      expect(find.textContaining('call you about your quotes'), findsOneWidget);

      await tester.tap(find.text('Add mobile number'));
      await tester.pump();

      expect(opened, isTrue);
    });

    testWidgets('only the city, when only the city is missing', (tester) async {
      await _pump(
        tester,
        setup: const SetupNeeds(city: true, number: false),
        onFinishSetup: () {},
      );

      // The headline and the button both say it.
      expect(find.text('Choose your city'), findsNWidgets(2));
      expect(find.text('Add mobile number'), findsNothing);
    });

    testWidgets('Not now puts it away', (tester) async {
      await _pump(
        tester,
        setup: const SetupNeeds(city: true, number: true),
        onFinishSetup: () {},
      );

      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();

      expect(find.text('Add your mobile number and city'), findsNothing);
    });

    testWidgets('says nothing when nothing is missing', (tester) async {
      await _pump(
        tester,
        setup: const SetupNeeds(city: false, number: false),
        onFinishSetup: () {},
      );

      expect(find.text('Not now'), findsNothing);
    });
  });

  group('with work under way', () {
    testWidgets('counts the jobs and says how many need the reader', (
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
      expect(find.text('1 job'), findsOneWidget);
      expect(findPill('1 needs you'), findsOneWidget);
    });

    testWidgets('does not reprint the Jobs tab', (tester) async {
      /// **The rule this group exists for now.**
      ///
      /// Home used to list every live requirement with its trades, its
      /// reference and its state — which is the Jobs tab in a smaller font.
      /// Two screens showing one list is not a dashboard; it is the same
      /// screen twice, and the second copy is the one that goes stale.
      ///
      /// The reference number is the tell: it belongs to the record, and the
      /// record lives one tap away.
      await _pump(
        tester,
        requirements: AsyncValue.data([fixtureRequirement()]),
      );

      expect(find.text('REQ-1042'), findsNothing);
      expect(find.text('Furniture Work'), findsNothing);
    });

    testWidgets('the summary row opens the Jobs tab', (tester) async {
      var opened = false;
      await _pump(
        tester,
        requirements: AsyncValue.data([fixtureRequirement()]),
        onOpenJobs: () => opened = true,
      );

      await tester.tap(find.text('1 job'));
      await tester.pump();

      expect(opened, isTrue);
    });

    testWidgets('says nothing is stuck on the reader when nothing is', (
      tester,
    ) async {
      // fixtureService() carries no quotes, so nothing is waiting on them and
      // the peach alert must stay away — it means "you are the blocker" and
      // nothing else.
      await _pump(
        tester,
        requirements: AsyncValue.data([fixtureRequirement()]),
      );

      expect(findPill('All with us'), findsOneWidget);
      expect(
        find.text('Quotes are ready for your furniture work'),
        findsNothing,
      );
    });
  });

  testWidgets('a failed read shows no list, and the rest still renders', (
    tester,
  ) async {
    // Telling somebody they have no jobs because a read failed would be a lie
    // with a button on it, so a failure shows nothing of theirs at all.
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

    expect(find.text('Your work'), findsNothing);
    expect(find.byType(DecoraShineLogo), findsOneWidget);
    expect(find.text('Homes that feel like you'), findsOneWidget);
  });
}
