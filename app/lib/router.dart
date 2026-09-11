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

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_core_auth/interiobee_core_auth.dart';
import 'package:interiobee_core_upload/interiobee_core_upload.dart';
import 'package:interiobee_feature_customer/interiobee_feature_customer.dart';
import 'package:interiobee_feature_vendor/interiobee_feature_vendor.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'env.dart';
import 'gallery.dart';
import 'screens/delete_account.dart';
import 'screens/finish_setup.dart';
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

  /// Both stores require account deletion to be reachable from inside the app.
  static const deleteAccount = '/account/close';
}

GoRouter buildRouter({
  required InterioBeeApi api,
  required AuthController auth,
  required BiometricGate gate,
  required UploadQueue Function(String milestoneId) queueFor,
  required UploadQueue requirementQueue,
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

      // Reachable from either shell while signed in. Bouncing somebody back to
      // a tab here would make the screen the stores require unreachable.
      if (location == Routes.deleteAccount) {
        return auth.shell == Shell.signedOut ? Routes.signIn : null;
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

        /// **Signed out is not a wall.**
        ///
        /// This used to be `location == signIn ? null : signIn`, which meant
        /// an account was the price of admission: no catalogue, no packages,
        /// no professionals, no blog, no estimator, and no requirement form —
        /// though the API serves all of that to an anonymous caller and the
        /// web site does exactly that.
        ///
        /// It also contradicted the app's own centrepiece. §6.3 designs the
        /// requirement flow so verification is *last*: "Asking for an account
        /// first is how a form loses the people who opened it." The shell was
        /// asking first.
        ///
        /// So the customer shell is the signed-out home, and `/sign-in` stays
        /// a real route that anything can push. What needs a session asks for
        /// one where it is needed, and says why.
        /// Two different signed-out states, and they are not interchangeable.
        ///
        /// **Never signed in** — let them in. The catalogue, packages,
        /// professionals, blog, estimator and the requirement form are all
        /// anonymous reads, and the web serves every one of them that way.
        ///
        /// **Signed out unexpectedly** — a suspension, a revoked row, a
        /// session the server no longer honours — show the sign-in screen,
        /// because it is the only surface that carries the reason. Dropping
        /// somebody into the public app mid-job with no explanation is exactly
        /// the failure `notice` exists to prevent: sessions are rows rather
        /// than JWTs so that a suspension lands on the screen somebody is
        /// looking at.
        Shell.signedOut =>
          auth.notice != null
              ? (location == Routes.signIn ? null : Routes.signIn)
              : (location.startsWith(Routes.customerHome) ||
                        location == Routes.signIn
                    ? null
                    : Routes.customerHome),

        // Staff have no mobile surface. Say so, and say where to go instead —
        // silently refusing a valid password is how a support ticket starts.
        Shell.staffRefused =>
          location == Routes.staffRefused ? null : Routes.staffRefused,

        // The gate comes before the dashboard, not beside it.
        Shell.vendorOnboarding =>
          location.startsWith(Routes.vendorOnboarding)
              ? null
              : Routes.vendorOnboarding,

        Shell.vendor =>
          location.startsWith(Routes.vendorDashboard) &&
                  !location.startsWith(Routes.vendorOnboarding)
              ? null
              : Routes.vendorDashboard,

        Shell.customer =>
          location.startsWith(Routes.customerHome) ? null : Routes.customerHome,
      };
    },

    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const _Splash(),
      ),
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
        builder: (context, state) => CustomerShell(
          queue: requirementQueue,
          authChanges: auth,
          isSignedIn: () => auth.shell == Shell.customer,
          // The requirement flow can reach step 6 with no session at all —
          // that is the point of it. Verification happens here, and only then.
          verify: (context) => presentSignIn(context, auth),
          onSignOut: auth.signOut,

          /// The web's setup strip, fed from the same `GET /me` it reads.
          setupNeeds: () {
            final me = auth.user;
            if (auth.shell != Shell.customer || me == null) return null;
            final first = me.name.trim().split(RegExp(r'\s+')).first;
            return SetupNeeds(
              city: me.cityId == null,
              number: me.mobile == null || !me.mobileVerified,
              firstName: first.isEmpty ? null : first,
            );
          },
          onFinishSetup: (context) =>
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute<void>(
                  builder: (_) => FinishSetupScreen(auth: auth),
                ),
              ),
        ),
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
      GoRoute(
        path: Routes.deleteAccount,
        builder: (context, state) =>
            DeleteAccountScreen(api: api, onClosed: auth.signOut),
      ),
      GoRoute(
        path: Routes.gallery,
        builder: (context, state) => const GalleryScreen(),
      ),
    ],
  );
}

/// Raises the sign-in screen over whatever is on top, and reports the outcome.
///
/// The one way into a session from inside the app. Every trigger goes through
/// it — the Jobs tab, the Account tab's button, the last step of the
/// requirement form — so there is one screen and one answer to "am I signed in
/// now", rather than each caller inventing its own.
///
/// Returns immediately when a session already exists, so a caller can guard
/// with it unconditionally.
Future<bool> presentSignIn(BuildContext context, AuthController auth) async {
  if (auth.shell != Shell.signedOut) return true;

  await Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => SignInScreen(auth: auth, dismissible: true),
    ),
  );

  /// Asked of the controller rather than tracked through the route's result.
  /// A pop can come from the back button, a successful verification, or the
  /// system, and only the controller knows which of those left a session.
  return auth.shell != Shell.signedOut;
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
            const DecoraShineLogo(height: 56),
            const SizedBox(height: Space.md),
            Text(
              context.t('Resolving your session…'),
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
              Text(
                context.t('Decora Shine is locked'),
                style: context.text.headlineLarge,
              ),
              const SizedBox(height: Space.sm),
              Text(
                context.t('Your session is still active. Unlock to carry on.'),
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Space.lg),
              FilledButton(
                onPressed: gate.unlock,
                child: Text(context.t('Unlock')),
              ),
              const SizedBox(height: Space.xs),
              TextButton(
                onPressed: auth.signOut,
                child: Text(context.t('Sign out instead')),
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
              ActionRequired(
                title: context.t('Staff sign in on the web'),
                body: context.t(
                  'This app is for customers and professionals. Ops and admin '
                  'work from the web panel, which has the tools this one does '
                  'not.',
                ),
              ),
              const SizedBox(height: Space.md),
              TextButton(
                onPressed: auth.signOut,
                child: Text(context.t('Sign out')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
