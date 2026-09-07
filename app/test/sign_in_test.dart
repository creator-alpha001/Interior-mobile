/// Signing in, end to end against a stubbed API.
///
/// Everything above the transport is production code — the interceptors, the
/// controller, the screens, the OTP field. What is asserted here is the set of
/// decisions MOBILE.md §5.2 records, each of which the web version got wrong
/// at least once.
library;

import 'package:aangan_app/screens/sign_in.dart';
import 'package:aangan_core_auth/aangan_core_auth.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Future<(AuthController, StubApi)> _pump(WidgetTester tester) async {
  final api = StubApi();
  final session = InMemoryAuthSession();
  final auth = AuthController(api: apiWith(api, session), session: session);

  await tester.pumpWidget(
    MaterialApp(theme: AanganTheme.light, home: SignInScreen(auth: auth)),
  );
  return (auth, api);
}


/// Performs an interaction and lets the real async work behind it finish.
///
/// Three steps, all needed. `pump` shows the busy state; `runAsync` gives the
/// stubbed HTTP a real async gap, which the widget test's fake clock otherwise
/// never grants; `pumpAndSettle` then settles once the spinner is gone.
///
/// Calling `pumpAndSettle` while the button still shows a
/// `CircularProgressIndicator` never returns — it is a continuous animation, so
/// there is always another frame scheduled. That is what eight of these tests
/// did before this helper existed.
Future<void> _act(WidgetTester tester, Future<void> Function() action) async {
  await action();
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('the phone stage', () {
    testWidgets('has no "Sign up" button, because there is no such action',
        (tester) async {
      // Signing up and signing in are one action: an unrecognised number
      // creates a customer account. A "Sign up" button would be a second door
      // into the same room, and the web learned that people pick the wrong one.
      await _pump(tester);

      expect(find.text('Send code'), findsOneWidget);
      expect(find.text('Sign up'), findsNothing);
      expect(find.text('Create account'), findsNothing);
      expect(find.textContaining('New here?'), findsOneWidget);
    });

    testWidgets('sends the number and moves to the code stage', (tester) async {
      final (_, api) = await _pump(tester);
      api.on('POST', '/auth/otp/request', {
        'challengeId': 'ch-1',
        'expiresInSeconds': 300,
      });

      await tester.enterText(find.byType(TextField), '9839012477');
      await _act(tester, () => tester.tap(find.text('Send code')));

      expect(find.textContaining('We sent a code'), findsOneWidget);
      expect(find.byType(OtpField), findsOneWidget);
    });

    testWidgets('renders the server rate limit honestly', (tester) async {
      // The limits are the server's — five per mobile per hour. A client-side
      // counter would eventually disagree, and when it does it is always the
      // client that is wrong and the customer who is confused.
      final (_, api) = await _pump(tester);
      api.on(
        'POST',
        '/auth/otp/request',
        {'code': 'rate_limited', 'message': 'Too many attempts.'},
        status: 429,
      );

      await tester.enterText(find.byType(TextField), '9839012477');
      await _act(tester, () => tester.tap(find.text('Send code')));

      expect(find.textContaining('Too many attempts'), findsOneWidget);
      // Still on the phone stage: no code was sent, so asking for one is wrong.
      expect(find.byType(OtpField), findsNothing);
    });
  });

  group('the code field', () {
    /// The bug this widget exists to prevent.
    ///
    /// SMS autofill and a clipboard paste both deliver all six digits to
    /// whichever field has focus. The web shipped six one-character fields,
    /// kept the first digit and silently dropped five — no error, and no way
    /// for the person to understand what happened.
    testWidgets('accepts all six digits arriving at once', (tester) async {
      String? completed;

      await tester.pumpWidget(
        MaterialApp(
          theme: AanganTheme.light,
          home: Scaffold(
            body: OtpField(onCompleted: (code) => completed = code),
          ),
        ),
      );

      // One `enterText` of the whole code is exactly what autofill does.
      await tester.enterText(find.byType(TextField), '484220');
      await tester.pumpAndSettle();

      expect(completed, '484220');
    });

    testWidgets('is one field, not six', (tester) async {
      // The structural version of the same assertion. Six fields cannot be
      // made paste-safe, so the count is the invariant worth pinning.
      await tester.pumpWidget(
        MaterialApp(
          theme: AanganTheme.light,
          home: Scaffold(body: OtpField(onCompleted: (_) {})),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('offers the one-time-code autofill hint', (tester) async {
      // What makes iOS show the code above the keyboard, and what pairs with
      // the SMS Retriever API on Android.
      await tester.pumpWidget(
        MaterialApp(
          theme: AanganTheme.light,
          home: Scaffold(body: OtpField(onCompleted: (_) {})),
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.autofillHints, contains(AutofillHints.oneTimeCode));
    });

    testWidgets('takes digits only, and stops at six', (tester) async {
      String? completed;
      await tester.pumpWidget(
        MaterialApp(
          theme: AanganTheme.light,
          home: Scaffold(body: OtpField(onCompleted: (code) => completed = code)),
        ),
      );

      await tester.enterText(find.byType(TextField), 'ab12cd3456789');
      await tester.pumpAndSettle();

      expect(completed, '123456');
    });
  });

  group('verifying', () {
    testWidgets('a new number is signed in without ever being asked to sign up',
        (tester) async {
      final (auth, api) = await _pump(tester);
      api.on('POST', '/auth/otp/request', {
        'challengeId': 'ch-1',
        'expiresInSeconds': 300,
      });
      api.on('POST', '/auth/otp/verify', authSession(role: 'client', token: 'tok-1'));
      api.on('GET', '/me', sessionUser(role: 'client'));

      await tester.enterText(find.byType(TextField), '9839012477');
      await _act(tester, () => tester.tap(find.text('Send code')));

      await _act(
        tester,
        () => tester.enterText(find.byType(TextField), '484220'),
      );

      expect(auth.shell, Shell.customer);
      expect(auth.user?.name, 'Priya Sharma');
    });

    testWidgets('a wrong code is reported without losing the stage',
        (tester) async {
      final (auth, api) = await _pump(tester);
      api.on('POST', '/auth/otp/request', {
        'challengeId': 'ch-1',
        'expiresInSeconds': 300,
      });
      api.on(
        'POST',
        '/auth/otp/verify',
        {'code': 'invalid_code', 'message': 'That code is not right.'},
        status: 422,
      );

      await tester.enterText(find.byType(TextField), '9839012477');
      await _act(tester, () => tester.tap(find.text('Send code')));

      await _act(
        tester,
        () => tester.enterText(find.byType(TextField), '000000'),
      );

      expect(auth.signIn.stage, SignInStage.code);
      expect(auth.signIn.error, contains('not right'));
      expect(auth.shell, isNot(Shell.customer));
    });

    testWidgets('a professional goes to the onboarding gate, not the dashboard',
        (tester) async {
      final (auth, api) = await _pump(tester);
      api.on('POST', '/auth/otp/request', {
        'challengeId': 'ch-1',
        'expiresInSeconds': 300,
      });
      api.on(
        'POST',
        '/auth/otp/verify',
        authSession(role: 'professional', token: 'tok-2'),
      );
      api.on('GET', '/me', sessionUser(role: 'professional', name: 'Aarohi Verma'));

      await tester.enterText(find.byType(TextField), '9810000000');
      await _act(tester, () => tester.tap(find.text('Send code')));

      await _act(
        tester,
        () => tester.enterText(find.byType(TextField), '484220'),
      );

      expect(auth.shell, Shell.vendorOnboarding);
    });

    testWidgets('staff are refused even with a valid code', (tester) async {
      final (auth, api) = await _pump(tester);
      api.on('POST', '/auth/otp/request', {
        'challengeId': 'ch-1',
        'expiresInSeconds': 300,
      });
      api.on('POST', '/auth/otp/verify', authSession(role: 'admin', token: 'tok-3'));
      api.on('GET', '/me', sessionUser(role: 'admin', name: 'Ops'));

      await tester.enterText(find.byType(TextField), '9810099999');
      await _act(tester, () => tester.tap(find.text('Send code')));

      await _act(
        tester,
        () => tester.enterText(find.byType(TextField), '484220'),
      );

      expect(auth.shell, Shell.staffRefused);
    });

    testWidgets('refuses to proceed if no bearer token came back',
        (tester) async {
      // The API only returns a token when it sees `X-Client: mobile`.
      // Continuing without one would leave the app "signed in" with nothing to
      // authenticate the next request — a state that looks fine until the
      // first tap.
      final (auth, api) = await _pump(tester);
      api.on('POST', '/auth/otp/request', {
        'challengeId': 'ch-1',
        'expiresInSeconds': 300,
      });
      api.on('POST', '/auth/otp/verify', authSession(role: 'client'));

      await tester.enterText(find.byType(TextField), '9839012477');
      await _act(tester, () => tester.tap(find.text('Send code')));

      await _act(
        tester,
        () => tester.enterText(find.byType(TextField), '484220'),
      );

      expect(auth.shell, isNot(Shell.customer));
      expect(auth.signIn.error, contains('did not return a session'));
    });
  });

  group('the mobile client header', () {
    testWidgets('is sent on sign-in, which is what returns the token',
        (tester) async {
      final (_, api) = await _pump(tester);
      api.on('POST', '/auth/otp/request', {
        'challengeId': 'ch-1',
        'expiresInSeconds': 300,
      });

      await tester.enterText(find.byType(TextField), '9839012477');
      await _act(tester, () => tester.tap(find.text('Send code')));

      expect(api.seen.single.headers['x-client'], 'mobile');
    });
  });
}
