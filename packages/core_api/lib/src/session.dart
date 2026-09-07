/// Where the session token comes from, and what happens when it stops working.
///
/// An interface, not an implementation. `core_api` deliberately has no Flutter
/// dependency (MOBILE.md §4.1), so it cannot reach Keychain or Keystore —
/// `core_auth` provides the real store on top of `flutter_secure_storage`, and
/// the tests here provide an in-memory one.
///
/// Keeping the seam here is also what makes the 401 path testable without a
/// device: [SessionStore.onRevoked] is called from the interceptor, and a test
/// can assert it fired.
library;

import 'dart:async';

abstract interface class SessionStore {
  /// The bearer token, or null when signed out.
  ///
  /// Read on every request rather than captured once: signing in, signing out
  /// and being revoked all change it while the app is running.
  FutureOr<String?> read();

  /// Called when the API says the session is no longer valid.
  ///
  /// The implementation clears secure storage and routes to sign-in. It must
  /// not retry, and it must not leave the user on a blank screen — a 401
  /// mid-session means suspended or signed out elsewhere, and the person
  /// deserves to be told which.
  Future<void> onRevoked();
}

/// A store that is always signed out. The default before `core_auth` lands.
class NoSession implements SessionStore {
  const NoSession();

  @override
  String? read() => null;

  @override
  Future<void> onRevoked() async {}
}

/// An in-memory store. For tests, and for a development flavour.
class InMemorySession implements SessionStore {
  InMemorySession([this._token]);

  String? _token;
  int revocations = 0;

  set token(String? value) => _token = value;

  @override
  String? read() => _token;

  @override
  Future<void> onRevoked() async {
    _token = null;
    revocations++;
  }
}
