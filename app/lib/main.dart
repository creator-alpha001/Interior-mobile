/// The entrypoint.
///
/// Assembles the four pieces and starts resolving who is signed in. The shells
/// behind the router are still placeholders — M10 and M11 fill them — but
/// everything in front of them is real: a bearer session in Keychain, the OTP
/// flow, the role gates, and a biometric lock on resume.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_core_auth/aangan_core_auth.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';

import 'env.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final session = SecureSessionStore();
  final api = AanganApi(ApiConfig(baseUrl: Env.baseUrl), session: session);
  final auth = AuthController(api: api, session: session);
  final gate = BiometricGate();

  await gate.load();

  runApp(AanganApp(auth: auth, gate: gate));
}

class AanganApp extends StatefulWidget {
  const AanganApp({super.key, required this.auth, required this.gate});

  final AuthController auth;
  final BiometricGate gate;

  @override
  State<AanganApp> createState() => _AanganAppState();
}

class _AanganAppState extends State<AanganApp> with WidgetsBindingObserver {
  late final _router = buildRouter(auth: widget.auth, gate: widget.gate);

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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The lock is on *resume*, not on the session. `paused` covers both
    // backgrounding and the app switcher, which is where a shoulder-surfer
    // sees a vendor's pipeline.
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        widget.gate.onPaused();
      case AppLifecycleState.resumed:
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
