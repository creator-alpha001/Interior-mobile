/// The two release requirements that are code rather than paperwork.
library;

import 'package:aangan_app/screens/delete_account.dart';
import 'package:aangan_app/version_gate.dart';
import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// A tall surface, so a long ListView builds its whole contents.
///
/// The confirm field and the destructive button sit at the bottom of the
/// deletion screen, and a lazy ListView on the default 800x600 test surface
/// never builds them — which reads as "Bad state: No element" rather than as a
/// layout problem.
Future<void> _pumpTall(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(1200, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(theme: AanganTheme.light, home: home));
  await tester.pumpAndSettle();
}

void main() {
  group('the forced upgrade', () {
    /// The only lever there is once a bad build is on somebody's phone.
    test('blocks a build below the floor', () async {
      final api = StubApi()
        ..on('GET', '/app/version', {
          'minBuild': 42,
          'message': 'This version corrupts saved drafts. Please update.',
        });

      final gate = VersionGate(api: apiWith(api, const NoSession()), build: 41);
      await gate.check();

      expect(gate.isBlocked, isTrue);
      // The server's words, not the app's — it knows why the floor moved.
      expect(gate.message, contains('corrupts saved drafts'));
    });

    test('lets the current build through', () async {
      final api = StubApi()
        ..on('GET', '/app/version', {'minBuild': 42, 'message': 'update'});

      final gate = VersionGate(api: apiWith(api, const NoSession()), build: 42);
      await gate.check();

      expect(gate.isBlocked, isFalse);
    });

    test('does NOT block when the server cannot be reached', () async {
      // The rule that keeps the lever from becoming a liability. An upgrade
      // gate that locks people out because the *server* is down is a worse
      // outage than the bug it guards against.
      final api = StubApi()
        ..on('GET', '/app/version', {'code': 'internal_error', 'message': 'down'},
            status: 500);

      final gate = VersionGate(api: apiWith(api, const NoSession()), build: 1);
      await gate.check();

      expect(gate.isBlocked, isFalse);
    });

    test('does not block a development build with no build number', () async {
      final api = StubApi()
        ..on('GET', '/app/version', {'minBuild': 99, 'message': 'update'});

      final gate = VersionGate(api: apiWith(api, const NoSession()), build: 0);
      await gate.check();

      expect(gate.isBlocked, isFalse);
      // It should not even ask: there is no version to compare.
      expect(api.seen, isEmpty);
    });

    testWidgets('a blocked build offers no way past it', (tester) async {
      // No dismiss, no "later", no "continue anyway". A build below the floor
      // is one the platform has decided must not talk to the API.
      await tester.pumpWidget(
        const MaterialApp(
          home: UpgradeRequiredScreen(message: 'Please update to continue.'),
        ),
      );

      expect(find.text('Open the app store'), findsOneWidget);
      expect(find.text('Later'), findsNothing);
      expect(find.text('Continue anyway'), findsNothing);
      expect(find.text('Skip'), findsNothing);
      expect(find.text('Dismiss'), findsNothing);
    });
  });

  group('closing an account', () {
    /// Both stores require this to exist, and to be reachable from inside the
    /// app rather than by emailing support.
    testWidgets('will not proceed without the exact word', (tester) async {
      final api = StubApi();

      await _pumpTall(
        tester,
        DeleteAccountScreen(
          api: apiWith(api, const NoSession()),
          onClosed: () async {},
        ),
      );

      final button = find.widgetWithText(
        FilledButton,
        'Close my account permanently',
      );
      expect(tester.widget<FilledButton>(button).onPressed, isNull);

      // Close, but not exact. A mis-tap must not be able to do this.
      await tester.enterText(find.byType(TextField).last, 'delete');
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(button).onPressed, isNull);

      await tester.enterText(find.byType(TextField).last, 'DELETE');
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
    });

    testWidgets('says what is kept before they act, not after', (tester) async {
      // Somebody expecting total erasure and later finding an invoice with
      // their agreement on it would reasonably feel misled.
      await _pumpTall(
        tester,
        DeleteAccountScreen(
          api: apiWith(StubApi(), const NoSession()),
          onClosed: () async {},
        ),
      );

      expect(
        find.text('Agreements, invoices and reviews are kept.'),
        findsOneWidget,
      );
      expect(find.textContaining('professional on the other side'), findsOneWidget);
    });

    testWidgets('reports what the server actually retained', (tester) async {
      // Straight from the response, so the screen cannot drift from what was
      // really kept.
      final api = StubApi()
        ..on('POST', '/me/account/delete', {
          'closedAt': '2026-09-08T10:00:00.000Z',
          'retained': ['2 agreements', '1 commission invoice', '3 reviews'],
        });

      await _pumpTall(
        tester,
        DeleteAccountScreen(
          api: apiWith(api, const NoSession()),
          onClosed: () async {},
        ),
      );

      await tester.enterText(find.byType(TextField).last, 'DELETE');
      await tester.pumpAndSettle();

      await tester.tap(
        find.widgetWithText(FilledButton, 'Close my account permanently'),
      );
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Account closed'), findsOneWidget);
      expect(find.text('• 1 commission invoice'), findsOneWidget);
      expect(find.text('• 3 reviews'), findsOneWidget);
    });
  });
}
