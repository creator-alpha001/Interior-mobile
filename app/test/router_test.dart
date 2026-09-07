/// The gates, asserted.
///
/// The screens behind these routes are placeholders until M10 and M11, but the
/// redirect logic is not — it is the thing every screen depends on being right,
/// and the failures it prevents are the kind nobody notices until a real vendor
/// is looking at the wrong page.
library;

import 'package:aangan_app/router.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, SessionState session) async {
  await tester.pumpWidget(
    MaterialApp.router(
      theme: AanganTheme.light,
      routerConfig: buildRouter(session),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('holds on the splash while the session is unknown', (tester) async {
    // Not the sign-in screen. Flashing "sign in" at somebody who is already
    // signed in, for the length of one `GET /me`, is the most common version
    // of this bug.
    await _pump(tester, SessionState());
    expect(find.text('Resolving your session…'), findsOneWidget);
  });

  testWidgets('sends a signed-out visitor to sign in', (tester) async {
    final session = SessionState()..shell = Shell.signedOut;
    await _pump(tester, session);
    expect(find.text('Sign in'), findsWidgets);
  });

  testWidgets('refuses staff, and says where to go instead', (tester) async {
    // Ops and admin have no mobile surface. Refusing silently, or dropping them
    // on an empty customer home, is how a support ticket starts.
    final session = SessionState()..shell = Shell.staffRefused;
    await _pump(tester, session);

    expect(find.text('Staff sign in on the web'), findsOneWidget);
    expect(find.textContaining('web panel'), findsOneWidget);
  });

  testWidgets('an unsigned vendor gets the gate, never the dashboard', (tester) async {
    // The single most important redirect in the app. An unsigned professional
    // is in no lead pool however verified they are, so a dashboard reading
    // "0 leads" is true and useless — they must see what is missing.
    final session = SessionState()..shell = Shell.vendorOnboarding;
    await _pump(tester, session);

    expect(find.text('Onboarding gate'), findsWidgets);
    expect(find.text('Vendor shell'), findsNothing);
  });

  testWidgets('a signed vendor gets the dashboard', (tester) async {
    final session = SessionState()..shell = Shell.vendor;
    await _pump(tester, session);

    expect(find.text('Vendor shell'), findsWidgets);
    expect(find.text('Onboarding gate'), findsNothing);
  });

  testWidgets('a customer gets the customer shell', (tester) async {
    final session = SessionState()..shell = Shell.customer;
    await _pump(tester, session);

    expect(find.text('Customer shell'), findsWidgets);
  });

  testWidgets('the shell follows the session changing under it', (tester) async {
    // Signing in, and being revoked, both happen while the app is open —
    // sessions are rows rather than JWTs precisely so a suspension takes effect
    // on the screen somebody is looking at. The router has to follow.
    final session = SessionState()..shell = Shell.signedOut;
    await _pump(tester, session);
    expect(find.text('Sign in'), findsWidgets);

    session.shell = Shell.customer;
    await tester.pumpAndSettle();
    expect(find.text('Customer shell'), findsWidgets);

    session.shell = Shell.signedOut;
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsWidgets);
  });
}
