/// The entrypoint.
///
/// M8 wires the pieces together and stops there: the design system, the API
/// client, the router and its gates all exist, and the screens behind them do
/// not. `SessionState` is still set by hand rather than by `GET /me` — that,
/// and the OTP flow that produces a token, are M9.
///
/// The gallery is reachable at `/_gallery` in non-production builds, which is
/// what M8's "done when" asks for: the component gallery renders every state.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';

import 'env.dart';
import 'router.dart';

void main() {
  final api = AanganApi(ApiConfig(baseUrl: Env.baseUrl));
  runApp(AanganApp(api: api));
}

class AanganApp extends StatefulWidget {
  const AanganApp({super.key, required this.api});

  final AanganApi api;

  @override
  State<AanganApp> createState() => _AanganAppState();
}

class _AanganAppState extends State<AanganApp> {
  final _session = SessionState();
  late final _router = buildRouter(_session);

  @override
  void initState() {
    super.initState();

    /// Stands in for `GET /me`.
    ///
    /// M9 replaces this with the real resolution: read the bearer token from
    /// secure storage, call `/me`, and map the actor's role onto a shell —
    /// `client` to the customer tabs, `professional` to the vendor tabs (via
    /// the onboarding gate), and staff to a refusal. Until then the app opens
    /// on the gallery, which is the only thing M8 has to show.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _session.shell = Shell.signedOut;
      if (Env.showsGallery) _router.go(Routes.gallery);
    });
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
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
