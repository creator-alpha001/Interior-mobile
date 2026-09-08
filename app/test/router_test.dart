/// The gates, driven by the real controller against a stubbed API.
///
/// The shells behind these routes are placeholders until M10 and M11, but the
/// redirect logic is not — it is what every screen depends on being right, and
/// the failures it prevents are the kind nobody notices until a real vendor is
/// looking at the wrong page.
library;

import 'package:aangan_app/router.dart';
import 'package:aangan_core_auth/aangan_core_auth.dart';
import 'package:aangan_core_upload/aangan_core_upload.dart';
import 'package:aangan_feature_customer/aangan_feature_customer.dart';
import 'package:aangan_feature_vendor/aangan_feature_vendor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// Builds the app the way `main.dart` does, minus the platform pieces.
Future<(AuthController, StubApi)> _pump(
  WidgetTester tester, {
  String? token,
  void Function(StubApi)? stub,
}) async {
  final api = StubApi();
  stub?.call(api);

  final session = InMemoryAuthSession(token);
  final client = apiWith(api, session);
  final auth = AuthController(api: client, session: session);
  final gate = BiometricGate(biometrics: _NoBiometrics(), preferences: null);
  final queue = UploadQueue(api: client);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerApiProvider.overrideWithValue(client),
        vendorApiProvider.overrideWithValue(client),
      ],
      child: MaterialApp.router(
        theme: AanganTheme.light,
        routerConfig: buildRouter(
          api: client,
          auth: auth,
          gate: gate,
          queueFor: (_) => queue,
          requirementQueue: queue,
        ),
      ),
    ),
  );

  // `runAsync`, not a bare await.
  //
  // A widget test runs on a fake clock, and anything that resolves through a
  // real async gap — the HTTP stub, and the backoff in RetryInterceptor —
  // simply never completes under it. The symptom is a test that reports "did
  // not complete" with no stack trace, which is what the first version of this
  // file did for four minutes.
  await tester.runAsync(() => auth.resolve());
  await tester.pumpAndSettle();
  return (auth, api);
}

class _NoBiometrics implements Biometrics {
  @override
  Future<bool> isAvailable() async => false;
  @override
  Future<bool> authenticate(String reason) async => false;
}

void main() {
  testWidgets('holds the splash while /me is in flight', (tester) async {
    // Not the sign-in screen. Flashing "sign in" at somebody who is already
    // signed in, for the length of one request, is the common version of this.
    final api = StubApi();
    final session = InMemoryAuthSession('token');
    final client = apiWith(api, session);
    final auth = AuthController(api: client, session: session);
    final gate = BiometricGate(biometrics: _NoBiometrics(), preferences: null);
    final queue = UploadQueue(api: client);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerApiProvider.overrideWithValue(client),
          vendorApiProvider.overrideWithValue(client),
        ],
        child: MaterialApp.router(
          theme: AanganTheme.light,
          routerConfig: buildRouter(
            api: client,
            auth: auth,
            gate: gate,
            queueFor: (_) => queue,
            requirementQueue: queue,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Resolving your session…'), findsOneWidget);
  });

  testWidgets('no token means the sign-in screen, without asking /me', (
    tester,
  ) async {
    final (_, api) = await _pump(tester);

    expect(find.text('Send code'), findsOneWidget);
    expect(
      api.seen.where((r) => r.path == '/me'),
      isEmpty,
      reason:
          'there is no session to resolve, so /me is not worth a round trip',
    );
  });

  testWidgets('a customer token lands on the customer shell', (tester) async {
    await _pump(
      tester,
      token: 'sess-customer',
      stub: (api) => api
        ..on('GET', '/me', sessionUser(role: 'client'))
        ..on('GET', '/domains', <Object>[])
        ..on('GET', '/me/requirements', <Object>[]),
    );

    // The five customer tabs, not the vendor's.
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('JOBS'), findsOneWidget);
    expect(find.text('DASHBOARD'), findsNothing);
  });

  testWidgets('a professional lands on the onboarding gate, not a dashboard', (
    tester,
  ) async {
    // The most important redirect in the app. An unsigned professional is in no
    // lead pool however verified they are, so a dashboard reading "0 leads" is
    // true and tells them nothing about why. Whether they have signed is a
    // separate call, so the *gate* decides — assuming "signed" here would show
    // the dashboard to somebody in no pool.
    await _pump(
      tester,
      token: 'sess-vendor',
      stub: (api) => api
        ..on('GET', '/me', sessionUser(role: 'professional'))
        ..on('GET', '/vendor/onboarding', onboarding(canReceiveLeads: false)),
    );

    expect(find.text('Before you receive work'), findsOneWidget);
    expect(find.textContaining('not in any lead pool'), findsOneWidget);
    // Emphatically not the dashboard.
    expect(find.text('DASHBOARD'), findsNothing);
  });

  testWidgets('a signed vendor goes straight to the shell', (tester) async {
    await _pump(
      tester,
      token: 'sess-vendor',
      stub: (api) => api
        ..on('GET', '/me', sessionUser(role: 'professional'))
        ..on('GET', '/vendor/onboarding', onboarding(canReceiveLeads: true))
        ..on('GET', '/vendor/dashboard', dashboard()),
    );

    expect(find.text('DASHBOARD'), findsOneWidget);
    expect(find.text('Before you receive work'), findsNothing);
  });

  testWidgets('staff are refused, and told where to go', (tester) async {
    await _pump(
      tester,
      token: 'sess-staff',
      stub: (api) => api.on('GET', '/me', sessionUser(role: 'sales_agent')),
    );

    expect(find.text('Staff sign in on the web'), findsOneWidget);
    expect(find.textContaining('web panel'), findsOneWidget);
  });

  testWidgets('an admin is refused on the same path', (tester) async {
    await _pump(
      tester,
      token: 'sess-admin',
      stub: (api) => api.on('GET', '/me', sessionUser(role: 'admin')),
    );

    expect(find.text('Staff sign in on the web'), findsOneWidget);
  });

  testWidgets('a revoked session drops to sign-in and says why', (
    tester,
  ) async {
    // Sessions are rows rather than JWTs precisely so a suspension takes effect
    // on the screen somebody is looking at. Being signed out with no
    // explanation is what generates the support call.
    final (auth, api) = await _pump(
      tester,
      token: 'sess-customer',
      stub: (api) => api
        ..on('GET', '/me', sessionUser(role: 'client'))
        ..on('GET', '/domains', <Object>[])
        ..on('GET', '/me/requirements', <Object>[]),
    );
    expect(find.text('HOME'), findsOneWidget);

    // The next request 401s, as it would for a suspended vendor.
    api.on('GET', '/me', {
      'code': 'not_authenticated',
      'message': 'no',
    }, status: 401);
    await tester.runAsync(() => auth.resolve());
    await tester.pumpAndSettle();

    expect(find.text('Send code'), findsOneWidget);
    expect(find.text('You were signed out'), findsOneWidget);
    expect(find.textContaining('suspended'), findsOneWidget);
  });

  testWidgets('a network failure at launch does not present as signed in', (
    tester,
  ) async {
    // Guessing is worse than the sign-in screen. An app that assumes the last
    // known role when it cannot reach the API shows a vendor a dashboard built
    // from nothing.
    await _pump(
      tester,
      token: 'sess-customer',
      stub: (api) => api.on('GET', '/me', {
        'code': 'internal_error',
        'message': 'down',
      }, status: 500),
    );

    expect(find.text('Send code'), findsOneWidget);
    expect(find.text('HOME'), findsNothing);
  });
}
