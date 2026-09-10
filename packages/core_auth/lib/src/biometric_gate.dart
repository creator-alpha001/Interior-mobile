/// Biometric re-entry on resume.
///
/// MOBILE.md §5.3: a vendor opens this app twenty times a day, so `local_auth`
/// sits behind a preference and gates **app resume, not the session**. The
/// distinction is the whole design:
///
///   - the session token stays valid and stays in Keychain
///   - failing or cancelling the prompt shows a locked screen, not a sign-out
///   - a device with no enrolled biometric is not locked out of the app
///
/// Tying the session's lifetime to a fingerprint would mean a vendor who
/// changed their passcode has to sign in again by SMS, on a site, with no
/// signal. That is a worse failure than the one this protects against.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The platform side, behind an interface so the gate is testable.
abstract interface class Biometrics {
  Future<bool> isAvailable();
  Future<bool> authenticate(String reason);
}

class LocalAuthBiometrics implements Biometrics {
  LocalAuthBiometrics([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      if (!await _auth.isDeviceSupported()) return false;
      return _auth.canCheckBiometrics;
    } on PlatformException catch (error) {
      debugPrint('biometrics unavailable: $error');
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          // Allows the device passcode as a fallback. Without it, somebody
          // whose fingerprint stops being read — wet hands on a site, which is
          // the actual working condition here — has no way in at all.
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (error) {
      debugPrint('biometric prompt failed: $error');
      return false;
    }
  }
}

class BiometricGate extends ChangeNotifier {
  BiometricGate({Biometrics? biometrics, SharedPreferences? preferences})
    : _biometrics = biometrics ?? LocalAuthBiometrics(),
      _preferences = preferences;

  final Biometrics _biometrics;
  SharedPreferences? _preferences;

  static const _enabledKey = 'interiobee.biometric.enabled';

  bool _enabled = false;
  bool get enabled => _enabled;

  /// True while the app is showing the locked screen.
  bool _locked = false;
  bool get locked => _locked;

  Future<void> load() async {
    _preferences ??= await SharedPreferences.getInstance();
    _enabled = _preferences!.getBool(_enabledKey) ?? false;
    notifyListeners();
  }

  /// Turning it on prompts once, so nobody enables a lock they cannot pass.
  Future<bool> setEnabled(bool value) async {
    if (value) {
      if (!await _biometrics.isAvailable()) return false;
      final ok = await _biometrics.authenticate('Confirm it is you');
      if (!ok) return false;
    }

    _preferences ??= await SharedPreferences.getInstance();
    await _preferences!.setBool(_enabledKey, value);
    _enabled = value;
    notifyListeners();
    return true;
  }

  /// Called when the app goes to the background.
  void onPaused() {
    if (!_enabled || _locked) return;
    _locked = true;
    notifyListeners();
  }

  /// Called when the app comes back. Prompts, and unlocks on success.
  ///
  /// A failed prompt leaves the app locked rather than signing out. The person
  /// can try again, or sign out deliberately from the locked screen.
  Future<void> unlock() async {
    if (!_locked) return;
    final ok = await _biometrics.authenticate('Unlock Decora Shine');
    if (!ok) return;
    _locked = false;
    notifyListeners();
  }
}
