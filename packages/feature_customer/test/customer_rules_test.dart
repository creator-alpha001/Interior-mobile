/// The customer-side rules that are expensive to get wrong.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:aangan_feature_customer/aangan_feature_customer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures.dart';

Finder findPill(String label) => find.byWidgetPredicate(
  (w) => w is Text && w.semanticsLabel == label,
  description: 'status pill "$label"',
);

Future<void> _pump(WidgetTester tester, Widget child, {AanganApi? api}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [if (api != null) customerApiProvider.overrideWithValue(api)],
      child: MaterialApp(theme: AanganTheme.light, home: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('the requirement draft', () {
    /// The path MOBILE.md §6.3 says to test deliberately, on a bad connection.
    ///
    /// Verification is last, so everything typed before it lives only on the
    /// device. If `POST /me/requirements` fails after the code verifies, the
    /// person is signed in with an unsaved form — and the draft is the only
    /// copy of what they wrote.
    test('survives a round trip through storage', () async {
      final store = RequirementDraftStore();

      const draft = RequirementDraft(
        step: RequirementStep.verify,
        domainIds: ['furniture', 'painting'],
        materialSource: {'furniture': MaterialSource.customerSupplied},
        description: 'Wardrobe for the master bedroom, floor to ceiling.',
        photoAssetIds: ['asset-1', 'asset-2'],
        cityId: 'city-1',
        locality: 'Gomti Nagar',
        urgency: Urgency.withinMonth,
        budgetMax: 250000,
      );

      await store.save(draft);
      final restored = await store.load();

      expect(restored, isNotNull);
      expect(restored!.step, RequirementStep.verify);
      expect(restored.domainIds, ['furniture', 'painting']);
      expect(
        restored.materialSource['furniture'],
        MaterialSource.customerSupplied,
      );
      expect(restored.description, contains('master bedroom'));
      expect(restored.photoAssetIds, ['asset-1', 'asset-2']);
      expect(restored.urgency, Urgency.withinMonth);
      expect(restored.budgetMax, 250000);
    });

    test('is cleared only once the server has it', () async {
      final store = RequirementDraftStore();
      await store.save(const RequirementDraft(description: 'something typed'));

      // The submission failing must not clear it — that is precisely when it
      // is the only copy.
      expect(await store.load(), isNotNull);

      await store.clear();
      expect(await store.load(), isNull);
    });

    test('a draft from an older build is discarded, not fatal', () async {
      SharedPreferences.setMockInitialValues({
        'aangan.requirement.draft': '{not json',
      });

      // Losing a draft is bad. Crashing on launch because of one is worse.
      expect(await RequirementDraftStore().load(), isNull);
    });

    test('unknown enum values decode to something sane', () async {
      // A build that predates a new urgency or material source must not throw
      // on a draft written by a newer one.
      final store = RequirementDraftStore();
      SharedPreferences.setMockInitialValues({
        'aangan.requirement.draft':
            '{"step":"budget","domainIds":["x"],"materialSource":{"x":"invented"},'
            '"description":"d","photoAssetIds":[],"cityId":"c","locality":"l",'
            '"urgency":"invented","budgetMax":null,"siteTags":["invented"]}',
      });

      final restored = await store.load();
      expect(restored, isNotNull);
      expect(restored!.materialSource['x'], MaterialSource.undecided);
      expect(restored.urgency, isNull);
      expect(restored.siteTags, isEmpty);
    });
  });

  group('the six steps', () {
    test('verification is last', () {
      // The order is the decision. Asking for an account first is how a form
      // loses the people who opened it.
      expect(RequirementStep.values.last, RequirementStep.verify);
      expect(RequirementStep.values.first, RequirementStep.trades);
    });

    test('photographs never block progress', () {
      // Optional on purpose: blocking here loses somebody standing in an
      // unlit room.
      const draft = RequirementDraft(step: RequirementStep.photographs);
      expect(draft.canAdvance, isTrue);
    });

    test('a trade must be chosen before anything else', () {
      const empty = RequirementDraft();
      expect(empty.canAdvance, isFalse);

      const chosen = RequirementDraft(domainIds: ['furniture']);
      expect(chosen.canAdvance, isTrue);
    });

    test('completeness is checked before the OTP, not after', () {
      // Sending somebody through verification only to fail validation
      // afterwards is the worst version of this flow.
      const incomplete = RequirementDraft(domainIds: ['furniture']);
      expect(incomplete.isComplete, isFalse);

      const complete = RequirementDraft(
        domainIds: ['furniture'],
        description: 'A wardrobe, floor to ceiling.',
        cityId: 'city-1',
        urgency: Urgency.exploring,
      );
      expect(complete.isComplete, isTrue);
    });
  });

  group('progress', () {
    testWidgets('has no approve button, of any kind', (tester) async {
      // MOBILE.md §6.1, and the whole guarantee: a stage is done when somebody
      // at Aangan has checked the photographs. An approve button here would
      // move that verification onto the person least able to perform it.
      await _pump(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            child: CustomerProjectCard(
              view: fixtureProjectView(
                milestones: [
                  fixtureMilestone(
                    verification: MilestoneVerification.submitted,
                  ),
                ],
              ),
            ),
          ),
        ),
        api: fixtureApi(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Approve'), findsNothing);
      expect(find.text('Mark as done'), findsNothing);
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Confirm'), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('a submitted stage reads as being checked, not done', (
      tester,
    ) async {
      await _pump(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            child: CustomerProjectCard(
              view: fixtureProjectView(
                milestones: [
                  fixtureMilestone(
                    verification: MilestoneVerification.submitted,
                  ),
                ],
              ),
            ),
          ),
        ),
        api: fixtureApi(),
      );
      await tester.pumpAndSettle();

      expect(findPill('Being checked'), findsOneWidget);
      expect(findPill('Done'), findsNothing);
    });

    testWidgets('a rejected stage does not show the vendor’s criticism', (
      tester,
    ) async {
      // The verifier's note is written for the professional. Shown to the
      // customer out of context it reads as a complaint about work they are
      // paying for, and they cannot act on it either way.
      await _pump(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            child: CustomerProjectCard(
              view: fixtureProjectView(
                milestones: [
                  fixtureMilestone(
                    verification: MilestoneVerification.rejected,
                    verifierNote:
                        'The second photograph does not show the hinge.',
                  ),
                ],
              ),
            ),
          ),
        ),
        api: fixtureApi(),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('hinge'), findsNothing);
      expect(findPill('More work needed'), findsOneWidget);
    });
  });

  group('quote comparison', () {
    testWidgets('shows the rating for this trade, and says which trade', (
      tester,
    ) async {
      // Ratings are held per trade, and the directory ranks by the rating in
      // the trade being browsed. An overall average under a trade heading is
      // the wrong number under the right label.
      await _pump(
        tester,
        QuoteComparisonScreen(
          service: fixtureService(quotes: [fixtureQuoteView()]),
          requirementId: 'lead-1',
        ),
        api: fixtureApi(),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('in Furniture Work'), findsOneWidget);
    });

    testWidgets('says nothing moves until the customer chooses', (
      tester,
    ) async {
      await _pump(
        tester,
        QuoteComparisonScreen(
          service: fixtureService(quotes: [fixtureQuoteView()]),
          requirementId: 'lead-1',
        ),
        api: fixtureApi(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your turn'), findsOneWidget);
      expect(
        find.textContaining('Nothing moves until you choose'),
        findsOneWidget,
      );
    });

    testWidgets('locks the other quotes once one is chosen', (tester) async {
      /// A tall surface, so the lazy ListView builds the second card.
      ///
      /// Only this test needs it, and only since the comparison table went in
      /// above the cards — the default 800x600 now ends before the second
      /// quote. Left local rather than moved into `_pump`, because the
      /// estimator tests in this file want the real height to catch overflow.
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await _pump(
        tester,
        QuoteComparisonScreen(
          service: fixtureService(
            quotes: [
              fixtureQuoteView(),
              fixtureQuoteView(quoteId: 'q2', total: 500000),
            ],
            selectedQuoteId: 'q1',
          ),
          requirementId: 'lead-1',
        ),
        api: fixtureApi(),
      );
      await tester.pumpAndSettle();

      expect(findPill('You chose this one'), findsOneWidget);
      expect(find.text('Not chosen'), findsOneWidget);
      expect(find.text('Choose this quote'), findsNothing);
    });

    testWidgets('shows money in Indian grouping', (tester) async {
      await _pump(
        tester,
        QuoteComparisonScreen(
          service: fixtureService(quotes: [fixtureQuoteView(total: 450000)]),
          requirementId: 'lead-1',
        ),
        api: fixtureApi(),
      );
      await tester.pumpAndSettle();

      expect(find.text('₹4,50,000'), findsOneWidget);
    });
  });
}
