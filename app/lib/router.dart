/// The router, and the one `redirect` that owns the gates.
///
/// The shells behind these routes are still placeholders — the customer tabs
/// are M11 and the vendor tabs are M10 — but the gates in front of them are
/// real as of M9, driven by `AuthController` and a live `GET /me`.
///
/// Everything the app gates on lives in this one `redirect`, rather than each
/// screen checking for itself. A screen that decides its own visibility is a
/// screen somebody will forget to write, and the one they forget is always the
/// one that mattered.
library;

import 'package:aangan_core_auth/aangan_core_auth.dart';
import 'package:aangan_core_upload/aangan_core_upload.dart';
import 'package:aangan_feature_vendor/aangan_feature_vendor.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'env.dart';
import 'gallery.dart';
import 'screens/sign_in.dart';

abstract final class Routes {
  static const splash = '/';
  static const signIn = '/sign-in';
  static const staffRefused = '/staff';
  static const locked = '/locked';
  static const customerHome = '/home';
  static const vendorDashboard = '/vendor';
  static const vendorOnboarding = '/vendor/onboarding';
  static const gallery = '/_gallery';
}

GoRouter buildRouter({
  required AuthController auth,
  required BiometricGate gate,
  required UploadQueue Function(String milestoneId) queueFor,
}) {
  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: Listenable.merge([auth, gate]),
    debugLogDiagnostics: !Env.isProduction,

    redirect: (context, state) {
      final location = state.matchedLocation;

      // The gallery is a development surface, deliberately outside the gates —
      // it renders components, not anybody's data.
      if (location == Routes.gallery) {
        return Env.showsGallery ? null : Routes.splash;
      }

      /// The biometric lock sits above everything, including the shells.
      ///
      /// It gates the *UI on resume*, not the session: the token is still in
      /// Keychain and still valid, and failing the prompt leaves the app locked
      /// rather than signed out. See BiometricGate.
      if (gate.locked && auth.shell != Shell.signedOut) {
        return location == Routes.locked ? null : Routes.locked;
      }
      if (!gate.locked && location == Routes.locked) {
        return Routes.splash;
      }

      return switch (auth.shell) {
        // Still asking `GET /me`. Hold the splash rather than flashing the
        // sign-in screen at somebody who is already signed in.
        Shell.resolving => location == Routes.splash ? null : Routes.splash,

        Shell.signedOut => location == Routes.signIn ? null : Routes.signIn,

        // Staff have no mobile surface. Say so, and say where to go instead —
        // silently refusing a valid password is how a support ticket starts.
        Shell.staffRefused =>
          location == Routes.staffRefused ? null : Routes.staffRefused,

        // The gate comes before the dashboard, not beside it.
        Shell.vendorOnboarding => location.startsWith(Routes.vendorOnboarding)
            ? null
            : Routes.vendorOnboarding,

        Shell.vendor => location.startsWith(Routes.vendorDashboard) &&
                !location.startsWith(Routes.vendorOnboarding)
            ? null
            : Routes.vendorDashboard,

        Shell.customer =>
          location.startsWith(Routes.customerHome) ? null : Routes.customerHome,
      };
    },

    routes: [
      GoRoute(path: Routes.splash, builder: (context, state) => const _Splash()),
      GoRoute(
        path: Routes.signIn,
        builder: (context, state) => SignInScreen(auth: auth),
      ),
      GoRoute(
        path: Routes.locked,
        builder: (context, state) => _Locked(gate: gate, auth: auth),
      ),
      GoRoute(
        path: Routes.staffRefused,
        builder: (context, state) => _StaffRefused(auth: auth),
      ),
      GoRoute(
        path: Routes.customerHome,
        builder: (context, state) => _Placeholder('Customer shell', 'M11', auth: auth),
      ),
      /// Both vendor states land on the same widget.
      ///
      /// `VendorHome` reads `GET /vendor/onboarding` and decides between the
      /// gate and the shell itself — that is a vendor question rather than an
      /// auth one, and the router has already done its job by choosing the
      /// vendor side at all.
      GoRoute(
        path: Routes.vendorOnboarding,
        builder: (context, state) =>
            VendorHome(queueFor: queueFor, onSignOut: auth.signOut),
      ),
      GoRoute(
        path: Routes.vendorDashboard,
        builder: (context, state) =>
            VendorHome(queueFor: queueFor, onSignOut: auth.signOut),
      ),
      GoRoute(path: Routes.gallery, builder: (context, state) => const GalleryScreen()),
    ],
  );
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Aangan', style: context.text.displayLarge),
            const SizedBox(height: Space.md),
            Text(
              'Resolving your session…',
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The resume lock. Not a sign-out.
class _Locked extends StatelessWidget {
  const _Locked({required this.gate, required this.auth});

  final BiometricGate gate;
  final AuthController auth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Space.gutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Aangan is locked', style: context.text.headlineLarge),
              const SizedBox(height: Space.sm),
              Text(
                'Your session is still active. Unlock to carry on.',
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Space.lg),
              FilledButton(onPressed: gate.unlock, child: const Text('Unlock')),
              const SizedBox(height: Space.xs),
              TextButton(
                onPressed: auth.signOut,
                child: const Text('Sign out instead'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Staff sign in on the web. Refused here, with somewhere to go.
class _StaffRefused extends StatelessWidget {
  const _StaffRefused({required this.auth});

  final AuthController auth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Space.gutter),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ActionRequired(
                title: 'Staff sign in on the web',
                body:
                    'This app is for customers and professionals. Ops and admin '
                    'work from the web panel, which has the tools this one does '
                    'not.',
              ),
              const SizedBox(height: Space.md),
              TextButton(onPressed: auth.signOut, child: const Text('Sign out')),
            ],
          ),
        ),
      ),
    );
  }
}

/// A shell that a later milestone fills in.
class _Placeholder extends StatelessWidget {
  const _Placeholder(this.title, this.milestone, {required this.auth});

  final String title;
  final String milestone;
  final AuthController auth;

  @override
  Widget build(BuildContext context) {
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton(onPressed: auth.signOut, child: const Text('Sign out')),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(Space.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusPill(milestone, tone: StatusTone.waiting),
            const SizedBox(height: Space.md),
            if (user != null) ...[
              Text('Signed in as ${user.name}', style: context.text.headlineSmall),
              // Their own number, which is the only one this app ever shows.
              // Anybody else's is a MaskedClientSummary, which has no field
              // capable of carrying one.
              Text(
                user.mobile,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Space.md),
            ],
            Text('$title arrives in $milestone.', style: context.text.bodyLarge),
          ],
        ),
      ),
    );
  }
}
