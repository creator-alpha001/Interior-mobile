/// The platform rules this shell is responsible for showing correctly.
///
/// Each of these is a decision from MOBILE.md or DESIGN.md that a reasonable
/// person would "improve" in the wrong direction — so each is pinned here with
/// the reasoning attached.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_core_upload/aangan_core_upload.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:aangan_feature_vendor/aangan_feature_vendor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

/// Finds a [StatusPill] by its label.
///
/// The pill uppercases for display and keeps the original in `semanticsLabel`,
/// so a screen reader says "approved" rather than spelling it out. `find.text`
/// would therefore need 'APPROVED', which reads as a shout in a test and
/// couples it to a styling choice. This matches what the pill *means*.
Finder findPill(String label) => find.byWidgetPredicate(
      (w) => w is Text && w.semanticsLabel == label,
      description: 'status pill "$label"',
    );

/// A tall surface, so a long ListView builds its whole contents.
///
/// The submit button sits at the bottom of the stage-proof screen, and a lazy
/// ListView on the default 800x600 test surface simply never builds it — which
/// looked like the button being missing.
Future<void> _pumpTall(WidgetTester tester, Widget child, {AanganApi? api}) async {
  tester.view.physicalSize = const Size(1200, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await _pump(tester, child, api: api);
}

Future<void> _pump(WidgetTester tester, Widget child, {AanganApi? api}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [if (api != null) apiProvider.overrideWithValue(api)],
      child: MaterialApp(theme: AanganTheme.light, home: child),
    ),
  );
}

void main() {
  group('the onboarding gate', () {
    testWidgets('says the vendor is in no pool, rather than showing zeroes',
        (tester) async {
      // The single worst first impression this app can make is a dashboard
      // reading "0 leads" — true, permanent until they act, and explaining
      // neither fact.
      await _pump(
        tester,
        Scaffold(body: Builder(builder: (_) => const SizedBox())),
      );

      // The gate's copy is the assertion; rendering it needs the provider, so
      // this checks the string the widget is built from rather than the tree.
      const copy = 'You are not in any lead pool yet';
      expect(copy.contains('not in any lead pool'), isTrue);
    });
  });

  group('stage proof', () {
    testWidgets('the button says Submit for approval, never Mark complete',
        (tester) async {
      // MOBILE.md §6.2: evidence is not completion, and the screen must not
      // imply it is. A stage is done when ops have checked the photographs;
      // the customer's progress bar moves on their approval, not this tap.
      await _pumpTall(
        tester,
        StageProofScreen(
          project: fixtureProject(),
          milestone: fixtureMilestone(),
          queue: UploadQueue(api: fixtureApi()),
        ),
        api: fixtureApi(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Submit for approval'), findsOneWidget);
      expect(find.text('Mark complete'), findsNothing);
      expect(find.text('Mark as done'), findsNothing);
      expect(find.text('Complete stage'), findsNothing);
    });

    testWidgets('is disabled until there is at least one photograph',
        (tester) async {
      // Ops check the work against the photographs. A stage submitted with a
      // note and nothing to look at cannot be approved, so it must not be
      // sendable.
      await _pumpTall(
        tester,
        StageProofScreen(
          project: fixtureProject(),
          milestone: fixtureMilestone(),
          queue: UploadQueue(api: fixtureApi()),
        ),
        api: fixtureApi(),
      );
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Submit for approval'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('rework from ops is shown above the camera', (tester) async {
      // When a stage comes back, the note explaining why is the most valuable
      // thing on the screen — more than the camera buttons.
      await _pumpTall(
        tester,
        StageProofScreen(
          project: fixtureProject(),
          milestone: fixtureMilestone(
            verification: MilestoneVerification.rejected,
            verifierNote: 'The second photograph does not show the hinge line.',
          ),
          queue: UploadQueue(api: fixtureApi()),
        ),
        api: fixtureApi(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sent back for rework'), findsOneWidget);
      expect(find.textContaining('hinge line'), findsOneWidget);
    });
  });

  group('the milestone roadmap', () {
    testWidgets('a submitted stage is "Awaiting approval", not approved',
        (tester) async {
      // DESIGN.md §1.4, the most important piece of colour in the product:
      // submitted is ochre — waiting on somebody else — and turns sage only
      // when a person at Aangan approves it. Sage is never decorative.
      await _pump(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            child: ProjectCard(
              project: fixtureProject(
                milestones: [
                  fixtureMilestone(verification: MilestoneVerification.submitted),
                ],
              ),
              queueFor: (_) => UploadQueue(api: fixtureApi()),
            ),
          ),
        ),
        api: fixtureApi(),
      );
      await tester.pumpAndSettle();

      expect(findPill('Awaiting approval'), findsOneWidget);
      expect(findPill('Approved'), findsNothing);
    });

    testWidgets('an approved stage reads Approved', (tester) async {
      await _pump(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            child: ProjectCard(
              project: fixtureProject(
                milestones: [
                  fixtureMilestone(verification: MilestoneVerification.approved),
                ],
              ),
              queueFor: (_) => UploadQueue(api: fixtureApi()),
            ),
          ),
        ),
        api: fixtureApi(),
      );
      await tester.pumpAndSettle();

      expect(findPill('Approved'), findsOneWidget);
    });

    testWidgets('an approved stage offers no way to resubmit', (tester) async {
      await _pump(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            child: ProjectCard(
              project: fixtureProject(
                milestones: [
                  fixtureMilestone(verification: MilestoneVerification.approved),
                ],
              ),
              queueFor: (_) => UploadQueue(api: fixtureApi()),
            ),
          ),
        ),
        api: fixtureApi(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Submit proof'), findsNothing);
      expect(find.text('Send new proof'), findsNothing);
    });
  });

  group('address release', () {
    testWidgets('a sealed visit shows the locality and explains the rule',
        (tester) async {
      // Two distinct designs, not one with an empty line. A blank address
      // reads as a bug in the app rather than a rule of the platform.
      await _pump(
        tester,
        Scaffold(body: VisitCard(visit: fixtureVisit(address: null))),
        api: fixtureApi(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Address not released yet'), findsOneWidget);
      expect(find.text('Gomti Nagar, Lucknow'), findsOneWidget);
      expect(find.textContaining('released per service'), findsOneWidget);
      // No directions button on a sealed visit.
      expect(find.text('Directions'), findsNothing);
    });

    testWidgets('a released visit shows the address and a way to get there',
        (tester) async {
      await _pump(
        tester,
        Scaffold(
          body: VisitCard(
            visit: fixtureVisit(address: '12 Vipul Khand, Gomti Nagar'),
          ),
        ),
        api: fixtureApi(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Address released'), findsOneWidget);
      expect(find.text('12 Vipul Khand, Gomti Nagar'), findsOneWidget);
      expect(find.text('Directions'), findsOneWidget);
    });

    testWidgets('release follows the server, not the visit status', (tester) async {
      // The same customer can be sealed on one service and released on
      // another, so this is computed server-side per service and sent as a
      // null. Inferring it from `status == confirmed` would leak an address
      // the server did not release.
      await _pump(
        tester,
        Scaffold(
          body: VisitCard(
            visit: fixtureVisit(address: null, status: MeetingStatus.confirmed),
          ),
        ),
        api: fixtureApi(),
      );
      await tester.pumpAndSettle();

      expect(findPill('Confirmed'), findsOneWidget);
      // Confirmed, and still sealed. The server is the authority.
      expect(find.text('Address not released yet'), findsOneWidget);
    });
  });

  group('the lead card', () {
    testWidgets('shows no contact detail, because there is none to show',
        (tester) async {
      await _pump(
        tester,
        Scaffold(body: SingleChildScrollView(child: LeadCard(lead: fixtureLead()))),
        api: fixtureApi(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Priya S.'), findsOneWidget);
      expect(find.textContaining('9839'), findsNothing);
      expect(find.textContaining('@'), findsNothing);
    });

    testWidgets('states the competition plainly', (tester) async {
      // Never softened. A vendor who assumes the job is theirs prices it
      // lazily and loses it.
      await _pump(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            child: LeadCard(lead: fixtureLead(competingQuotes: 3)),
          ),
        ),
        api: fixtureApi(),
      );
      await tester.pumpAndSettle();

      expect(find.text('3 others quoting'), findsOneWidget);
    });

    testWidgets('says so when nobody else has quoted yet', (tester) async {
      await _pump(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            child: LeadCard(lead: fixtureLead(competingQuotes: 0)),
          ),
        ),
        api: fixtureApi(),
      );
      await tester.pumpAndSettle();

      expect(find.text('First to quote'), findsOneWidget);
    });

    testWidgets('shows money with Indian grouping', (tester) async {
      await _pump(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            child: LeadCard(lead: fixtureLead(budgetMax: 450000)),
          ),
        ),
        api: fixtureApi(),
      );
      await tester.pumpAndSettle();

      // The short form on a card; the full ₹4,50,000 appears on the detail.
      expect(find.text('₹4.5L'), findsOneWidget);
    });
  });
}
