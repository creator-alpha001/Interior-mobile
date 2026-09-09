/// The session token, in Keychain or Keystore.
///
/// MOBILE.md §5.1: *store the token in `flutter_secure_storage`. Never in
/// `shared_preferences`.* The distinction is not pedantry — preferences are a
/// plain file, readable by anything with filesystem access on a rooted or
/// jailbroken handset, and this token is a live session.
///
/// The token itself is not a JWT and carries nothing. It is 32 random bytes
/// naming a row in Postgres, stored there as a SHA-256 hash. That is what makes
/// revocation immediate: suspending a vendor logs them out of the screen they
/// are looking at, which a self-describing token could not do.
library;

import 'dart:async';

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Told when the session goes away, so the router can react.
typedef OnSessionLost = void Function(SessionLostReason reason);

enum SessionLostReason {
  /// The person signed out.
  signedOut,

  /// The API answered 401 on a request we thought was authenticated.
  ///
  /// Means suspended, or signed out on another device. Worth telling them,
  /// because "you have been signed out" with no reason invites a support call.
  revoked,
}

/// What `AuthController` needs of a session store.
///
/// `core_api`'s [SessionStore] is the read side — all an interceptor needs.
/// This adds the write side, and exists as an interface rather than a concrete
/// class so the controller does not depend on Keychain: a widget test has no
/// platform channels, and a controller that could only be built on a device
/// would be a controller nobody tests.
abstract interface class AuthSessionStore implements SessionStore {
  Future<void> save(String token);
  Future<void> clear();
  set onLost(OnSessionLost? value);
}

class SecureSessionStore implements AuthSessionStore {
  SecureSessionStore({FlutterSecureStorage? storage, this.onLost})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  final FlutterSecureStorage _storage;

  /// Called from the interceptor's thread when a 401 arrives.
  OnSessionLost? onLost;

  static const _tokenKey = 'interiobee.session.token';

  /// Cached after the first read.
  ///
  /// Keychain access is not free and this is read on every single request. The
  /// cache is only ever invalidated here, by [save] and [clear], so it cannot
  /// drift from what is on disk.
  String? _cached;
  bool _loaded = false;

  @override
  Future<String?> read() async {
    if (_loaded) return _cached;

    try {
      _cached = await _storage.read(key: _tokenKey);
    } on PlatformException catch (error) {
      // A corrupted Keystore entry, or a backup restored onto a device that
      // cannot decrypt it. Treat as signed out rather than crashing on launch:
      // the person can sign in again, and a launch crash they cannot get past
      // is far worse than an unexpected sign-in screen.
      debugPrint('secure storage unreadable, treating as signed out: $error');
      _cached = null;
      await _clearQuietly();
    }

    _loaded = true;
    return _cached;
  }

  @override
  Future<void> save(String token) async {
    _cached = token;
    _loaded = true;
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Signing out on purpose.
  ///
  /// The caller is expected to have told the API first — the session row has to
  /// be revoked server-side, and the device token deleted with it, or the next
  /// person to hold this handset gets somebody else's job alerts.
  @override
  Future<void> clear() async {
    await _clearQuietly();
    onLost?.call(SessionLostReason.signedOut);
  }

  Future<void> _clearQuietly() async {
    _cached = null;
    _loaded = true;
    try {
      await _storage.delete(key: _tokenKey);
    } on PlatformException catch (error) {
      debugPrint('secure storage delete failed: $error');
    }
  }

  /// Called by `ErrorInterceptor` on a 401. Never retries; nothing to retry.
  @override
  Future<void> onRevoked() async {
    // Idempotent on purpose. Several requests in flight at once will each get
    // a 401, and the person should be told once, not five times.
    if (_cached == null && _loaded) return;
    await _clearQuietly();
    onLost?.call(SessionLostReason.revoked);
  }
}

/// An in-memory session store, for tests and for a development flavour.
///
/// Same contract as [SecureSessionStore] without the platform channels, so the
/// sign-in flow and the router gates can be exercised in a widget test.
class InMemoryAuthSession implements AuthSessionStore {
  InMemoryAuthSession([this._token]);

  String? _token;

  @override
  OnSessionLost? onLost;

  @override
  String? read() => _token;

  @override
  Future<void> save(String token) async => _token = token;

  @override
  Future<void> clear() async {
    _token = null;
    onLost?.call(SessionLostReason.signedOut);
  }

  @override
  Future<void> onRevoked() async {
    if (_token == null) return;
    _token = null;
    onLost?.call(SessionLostReason.revoked);
  }
}
