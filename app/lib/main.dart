/// The entrypoint.
///
/// Assembles the pieces and starts resolving who is signed in. Both shells are
/// real as of M11 — the vendor's leads, quotes, visits and stage proof, and the
/// customer's requirement flow, quote comparison and signing.
library;

import 'dart:async';
import 'dart:io';

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_core_auth/aangan_core_auth.dart';
import 'package:aangan_core_push/aangan_core_push.dart';
import 'package:aangan_core_upload/aangan_core_upload.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:aangan_feature_vendor/aangan_feature_vendor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'env.dart';
import 'router.dart';
import 'version_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final session = SecureSessionStore();

  // The read cache lives beside the upload queue, in support rather than
  // documents: it is derived data, and the OS may reclaim it.
  final support = await getApplicationSupportDirectory();
  final api = AanganApi(
    ApiConfig(baseUrl: Env.baseUrl),
    session: session,
    cacheDirectory: Directory('${support.path}/read-cache'),
  );

  /// Push, behind a driver.
  ///
  /// `NoPushTokens` until a Firebase project exists — the same shape the API
  /// uses with `PUSH_DRIVER=log`. Nothing is lost meanwhile: the notification
  /// row is still written inside the transaction that caused it and still goes
  /// out by SMS. Push only adds the buzz.
  final devices = DeviceRegistrar(api: api, tokens: const NoPushTokens());

  final auth = AuthController(
    api: api,
    session: session,
    onSignedIn: devices.register,
    onSigningOut: () async {
      // Order matters and is asserted in core_auth: deregistering is an
      // authenticated call, and the cache holds one person's figures.
      await devices.forget();
      api.cache?.clear();
    },
  );

  final gate = BiometricGate();
  await gate.load();

  /// The forced upgrade, checked before anything else is drawn.
  ///
  /// Deliberately not awaited into a blocking splash: `check()` fails silently
  /// if the server cannot be reached, so the app opens either way. An upgrade
  /// gate that locks people out because the *server* is down is a worse outage
  /// than the bug it guards against.
  final version = VersionGate(api: api);
  unawaited(version.check());

  runApp(
    ProviderScope(
      // The feature packages read the client from here rather than being handed
      // it down a widget tree, which is what lets a test swap the transport.
      overrides: [apiProvider.overrideWithValue(api)],
      child: AanganApp(api: api, auth: auth, gate: gate, version: version),
    ),
  );
}

class AanganApp extends StatefulWidget {
  const AanganApp({
    super.key,
    required this.api,
    required this.auth,
    required this.gate,
    required this.version,
  });

  final AanganApi api;
  final AuthController auth;
  final BiometricGate gate;
  final VersionGate version;

  @override
  State<AanganApp> createState() => _AanganAppState();
}

class _AanganAppState extends State<AanganApp> with WidgetsBindingObserver {
  /// One upload queue per stage.
  ///
  /// Held here rather than inside the screen, so a vendor can leave the stage,
  /// take a call, and come back to photographs still uploading. The queue also
  /// writes itself to disk, so it survives the process being killed — MOBILE.md
  /// §7.1: *"A stage submission that dies in a lift and takes eight photos with
  /// it is the failure that loses vendor trust fastest."*
  final _queues = <String, UploadQueue>{};

  /// One queue for requirement photographs, shared across the flow.
  ///
  /// Separate from the per-stage queues: a customer attaches photographs once,
  /// before they even have an account.
  late final UploadQueue _requirementQueue = UploadQueue(api: widget.api)
    ..restore();

  late final _router = buildRouter(
    api: widget.api,
    auth: widget.auth,
    gate: widget.gate,
    queueFor: _queueFor,
    requirementQueue: _requirementQueue,
  );

  UploadQueue _queueFor(String milestoneId) {
    return _queues.putIfAbsent(milestoneId, () {
      final queue = UploadQueue(api: widget.api);
      // Picks up anything that was mid-flight when the app last closed.
      queue.restore().then((_) => queue.drain());
      return queue;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Ask `GET /me` immediately. Until it answers the router holds the splash,
    // rather than flashing sign-in at somebody who is already signed in.
    widget.auth.resolve();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final queue in _queues.values) {
      queue.dispose();
    }
    _requirementQueue.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        // The lock is on *resume*, not on the session. `paused` covers both
        // backgrounding and the app switcher, which is where a shoulder-surfer
        // sees a vendor's pipeline.
        widget.gate.onPaused();
      case AppLifecycleState.resumed:
        // Anything that failed on a bad connection gets another go the moment
        // the app is in front of somebody again.
        for (final queue in _queues.values) {
          queue.drain();
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: Env.flavour.appName,
      debugShowCheckedModeBanner: false,
      theme: AanganTheme.light,

      /// Light only, deliberately and on the record — DESIGN.md §3.8.
      ///
      /// Not an oversight, and not `ThemeMode.system` pointing at a dark theme
      /// nobody has looked at. The palette is warm lime-washed plaster and the
      /// argument is daylight on stone; a mechanical inversion reads as a bug.
      themeMode: ThemeMode.light,
      darkTheme: AanganTheme.light,

      routerConfig: _router,

      /// The stale banner wraps every screen.
      ///
      /// Staleness is a property of the connection rather than of any one list,
      /// so it is drawn once here instead of being reimplemented per screen.
      builder: (context, child) => AnimatedBuilder(
        animation: widget.version,
        builder: (context, _) {
          /// A blocked build shows one screen and nothing else — not even
          /// sign-in. There is no dismiss and no "later": a build below the
          /// floor is one the platform has decided must not talk to the API.
          if (widget.version.isBlocked) {
            return UpgradeRequiredScreen(message: widget.version.message);
          }

          return Column(
            children: [
              StreamBuilder<DateTime?>(
                stream: widget.api.cache?.status.changes,
                initialData: widget.api.cache?.status.servingSince,
                builder: (context, snapshot) => StaleBanner(since: snapshot.data),
              ),
              Expanded(child: child ?? const SizedBox.shrink()),
            ],
          );
        },
      ),
    );
  }
}
