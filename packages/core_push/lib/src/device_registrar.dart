/// Registering this handset for push, and — more importantly — forgetting it.
///
/// MOBILE.md §7.2 puts the emphasis on the second half: *"`DELETE
/// /me/devices/:token`. **Delete on sign-out**, or the next person to hold that
/// phone gets somebody else's job alerts."*
///
/// The server binds the token to the *session* rather than only to the user,
/// so signing out takes exactly this handset with it. The client's job is to
/// make sure the call actually happens — including when the network is down at
/// the moment somebody signs out, which is precisely when it is skipped.
library;

import 'dart:io';

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:flutter/foundation.dart';

/// Where the push token comes from.
///
/// An interface because `firebase_messaging` cannot initialise without a
/// Firebase project, and the app must build and run before one exists. The API
/// solved the same problem with `PUSH_DRIVER=log`; this is the client half of
/// that idea. [NoPushTokens] is the default, and everything downstream of the
/// token is built and tested against it.
abstract interface class PushTokenSource {
  /// The current token, or null when push is unavailable on this device.
  Future<String?> token();

  /// Fires when the platform rotates the token, which it does on reinstall,
  /// restore-from-backup, and occasionally for its own reasons.
  Stream<String> get onRefresh;

  /// Asks the person. Returns false if they decline.
  ///
  /// Requested in context, at the moment of use, with a sentence of why —
  /// never speculatively on first launch, which costs a conversion and a store
  /// review question.
  Future<bool> requestPermission();
}

/// The default until a Firebase project exists.
///
/// Nothing is lost with push off: the notification row is still written inside
/// the transaction that caused it and still goes out by SMS. Push only adds the
/// buzz.
class NoPushTokens implements PushTokenSource {
  const NoPushTokens();

  @override
  Future<String?> token() async => null;

  @override
  Stream<String> get onRefresh => const Stream.empty();

  @override
  Future<bool> requestPermission() async => false;
}

/// Keeps the server's idea of this handset in step with reality.
class DeviceRegistrar {
  DeviceRegistrar({
    required AanganApi api,
    PushTokenSource tokens = const NoPushTokens(),
    String? appVersion,
  }) : _api = api,
       _tokens = tokens,
       _appVersion = appVersion;

  final AanganApi _api;
  final PushTokenSource _tokens;
  final String? _appVersion;

  String? _registered;

  /// Call after a session exists. Safe to call repeatedly.
  ///
  /// Re-registering is normal — the app does it on every launch — and the
  /// server upserts. That upsert is also why device registration runs on the
  /// unscoped pool: when a handset changes hands the row belongs to its
  /// previous owner and is invisible under row-level security, but the unique
  /// index on the token is enforced regardless, so a scoped upsert would fail
  /// on a row the caller cannot see.
  Future<void> register() async {
    final token = await _tokens.token();
    if (token == null || token == _registered) return;

    try {
      await _api.public
          .registerDevice(
            body: RegisterDeviceBody(
              token: token,
              platform: _platform,
              appVersion: _appVersion,
            ),
          )
          .orThrow();
      _registered = token;
    } on ApiException catch (error) {
      // Not fatal. Push is an enhancement; SMS still carries the notification.
      debugPrint('device registration failed, continuing without push: $error');
    }
  }

  /// Call *before* clearing the session.
  ///
  /// The order matters: the delete is authenticated, so a token cleared first
  /// leaves the row behind and the handset keeps receiving.
  Future<void> forget() async {
    final token = _registered ?? await _tokens.token();
    if (token == null) return;

    try {
      await _api.public.forgetDevice(token: token).orThrow();
    } on ApiException catch (error) {
      // Offline at sign-out is the case that matters, and there is no local
      // fix for it — the row lives on the server. Logged loudly rather than
      // swallowed, because the consequence is somebody else's job alerts on
      // this phone.
      debugPrint('could not deregister this device: $error');
    } finally {
      _registered = null;
    }
  }

  /// Follows platform token rotation for as long as the session lasts.
  Stream<void> watchRefreshes() =>
      _tokens.onRefresh.asyncMap((_) async => register());

  Future<bool> requestPermission() => _tokens.requestPermission();

  RegisterDeviceBodyPlatform get _platform {
    if (Platform.isAndroid) return RegisterDeviceBodyPlatform.android;
    if (Platform.isIOS) return RegisterDeviceBodyPlatform.ios;
    return RegisterDeviceBodyPlatform.web;
  }
}
