/// The app without an account.
///
/// Signing in used to be the price of admission: the router sent anybody
/// without a token to the sign-in screen and nowhere else. That cost the
/// catalogue, packages, the professional directory, the blog, the estimator
/// and the requirement form — every one of which the API serves to an
/// anonymous caller, and every one of which the web site shows to strangers.
///
/// It also contradicted the app's own centrepiece. MOBILE.md §6.3 designs the
/// requirement flow so verification comes *last*, because "asking for an
/// account first is how a form loses the people who opened it". The shell was
/// asking first.
///
/// So: sign-in is offered where it is needed and nowhere else.
library;

import 'package:aangan_core_upload/aangan_core_upload.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:aangan_feature_customer/aangan_feature_customer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

/// Screens that are one person's own record and nothing else.
///
/// Each is built entirely from `/me/*`, so signed out every one of them opens
/// on "Please try again" — which reads as broken rather than locked. The first
/// version of this guard covered the first link and the last and left three
/// showing, which is why the list is asserted rather than eyeballed.
const _perPerson = <String>[
  'Agreements',
  'Progress',
  'Notifications',
  'Invite a friend',
  'Help',
];

/// Readable by anybody, and the reason the shell opens at all.
const _public = <String>['How it works', 'Work with us'];

Future<void> _pumpAccount(WidgetTester tester, {required bool signedIn}) async {
  tester.view.physicalSize = const Size(1200, 5000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [customerApiProvider.overrideWithValue(fixtureApi())],
      child: MaterialApp(
        theme: AanganTheme.light,
        home: CustomerShell(
          queue: UploadQueue(api: fixtureApi()),
          authChanges: ChangeNotifier(),
          isSignedIn: () => signedIn,
          verify: (context) async => signedIn,
          onSignOut: signedIn ? () {} : null,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // The Account tab is the last of the five.
  await tester.tap(find.text('ACCOUNT'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('signed out, the Account tab offers a way in', (tester) async {
    await _pumpAccount(tester, signedIn: false);

    expect(find.text('Sign in'), findsWidgets);
    expect(
      find.text(
        'Your number is your account. We send a code — there is no password '
        'to remember.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('signed out, no link opens somebody else\'s record', (
    tester,
  ) async {
    await _pumpAccount(tester, signedIn: false);

    for (final link in _perPerson) {
      expect(
        find.text(link),
        findsNothing,
        reason: '"$link" is built from /me and would open on an error',
      );
    }
  });

  testWidgets('signed out, the public pages are still there', (tester) async {
    // The whole point. Locking the account links must not lock the app.
    await _pumpAccount(tester, signedIn: false);

    for (final link in _public) {
      expect(find.text(link), findsOneWidget);
    }
  });

  testWidgets('signed in, every link is back and the offer is gone', (
    tester,
  ) async {
    await _pumpAccount(tester, signedIn: true);

    for (final link in [..._perPerson, ..._public]) {
      expect(find.text(link), findsOneWidget);
    }
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets('signed out, Explore still browses', (tester) async {
    // Explore is entirely public reads. If this ever needs a session, the
    // shell has regressed to the wall it used to be.
    await _pumpAccount(tester, signedIn: false);

    await tester.tap(find.text('EXPLORE'));
    await tester.pumpAndSettle();

    expect(find.text('Catalogue'), findsOneWidget);
    expect(find.text('Professionals'), findsOneWidget);
  });

  testWidgets('signed out, Jobs says what is behind it and offers both ways', (
    tester,
  ) async {
    await _pumpAccount(tester, signedIn: false);

    await tester.tap(find.text('JOBS'));
    await tester.pumpAndSettle();

    expect(find.text('Your jobs live here'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    // The other way in, which for somebody with no account is the right one.
    expect(find.text('Tell us what you need'), findsOneWidget);
  });
}
