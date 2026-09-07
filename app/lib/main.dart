/// The entrypoint.
///
/// Assembles the pieces and starts resolving who is signed in. The customer
/// shell is still a placeholder — that is M11 — but the vendor side is real as
/// of M10: the onboarding gate, leads, the quote builder, visits with address
/// release, and stage proof with a queue that survives the app closing.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_core_auth/aangan_core_auth.dart';
import 'package:aangan_core_upload/aangan_core_upload.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:aangan_feature_vendor/aangan_feature_vendor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'env.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final session = SecureSessionStore();
  final api = AanganApi(ApiConfig(baseUrl: Env.baseUrl), session: session);
  final auth = AuthController(api: api, session: session);
  final gate = BiometricGate();

  await gate.load();

  runApp(
    ProviderScope(
      // The feature packages read the client from here rather than being handed
      // it down a widget tree, which is what lets a test swap the transport.
      overrides: [apiProvider.overrideWithValue(api)],
      child: AanganApp(api: api, auth: auth, gate: gate),
    ),
  );
}

class AanganApp extends StatefulWidget {
  const AanganApp({
    super.key,
    required this.api,
    required this.auth,
    required this.gate,
  });

  final AanganApi api;
  final AuthController auth;
  final BiometricGate gate;

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

  late final _router = buildRouter(
    auth: widget.auth,
    gate: widget.gate,
    queueFor: _queueFor,
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
    );
  }
}
