/// The session store and the resume gate.
///
/// Both have a rule that is easy to state and easy to implement backwards, so
/// both are asserted rather than assumed.
library;

import 'package:aangan_core_auth/aangan_core_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // The gate stores its on/off flag in preferences — which are not a secret,
  // unlike the token. That still needs a binding and a backing store in a test.
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('the session store', () {
    test('reports a revocation once, however many requests 401', () async {
      // Several requests are usually in flight at once. Each gets its own 401,
      // and the person should be told they were signed out once — not five
      // times, and not once per screen that happened to be loading.
      final reasons = <SessionLostReason>[];
      final session = InMemoryAuthSession('token')..onLost = reasons.add;

      await Future.wait([
        session.onRevoked(),
        session.onRevoked(),
        session.onRevoked(),
      ]);

      expect(reasons, [SessionLostReason.revoked]);
      expect(session.read(), isNull);
    });

    test('distinguishes signing out from being revoked', () async {
      // They need different copy. "You were signed out" with no reason, shown
      // to somebody who tapped Sign out, is noise; shown to somebody who was
      // suspended, silence is what generates the support call.
      final reasons = <SessionLostReason>[];
      final session = InMemoryAuthSession('token')..onLost = reasons.add;

      await session.clear();
      expect(reasons, [SessionLostReason.signedOut]);
    });

    test('a cleared session reads as null', () async {
      final session = InMemoryAuthSession('token');
      expect(session.read(), 'token');
      await session.clear();
      expect(session.read(), isNull);
    });
  });

  group('the biometric gate', () {
    test('does nothing when it is switched off', () async {
      final gate = BiometricGate(
        biometrics: _FakeBiometrics(),
        preferences: null,
      );

      gate.onPaused();
      expect(
        gate.locked,
        isFalse,
        reason: 'a gate nobody enabled must not lock',
      );
    });

    test('will not enable itself on a device with no biometric', () async {
      // Enabling a lock the person cannot pass would strand them behind it.
      final gate = BiometricGate(
        biometrics: _FakeBiometrics(available: false),
        preferences: null,
      );

      expect(await gate.setEnabled(true), isFalse);
      expect(gate.enabled, isFalse);
    });

    test('a failed unlock leaves the app locked, never signed out', () async {
      // The whole point of §5.3: the gate is on the UI, not the session. The
      // token stays in Keychain and stays valid, so a vendor on a site with no
      // signal is never forced back through an SMS.
      final biometrics = _FakeBiometrics()..succeeds = true;
      final gate = BiometricGate(biometrics: biometrics, preferences: null);

      await gate.setEnabled(true);
      gate.onPaused();
      expect(gate.locked, isTrue);

      biometrics.succeeds = false;
      await gate.unlock();
      expect(gate.locked, isTrue, reason: 'a refused prompt is not a sign-out');

      biometrics.succeeds = true;
      await gate.unlock();
      expect(gate.locked, isFalse);
    });
  });
}

class _FakeBiometrics implements Biometrics {
  _FakeBiometrics({this.available = true});

  final bool available;
  bool succeeds = true;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate(String reason) async => succeeds;
}
