/// The router, and the one `redirect` that owns the gates.
///
/// A skeleton at M8. The shells are placeholders and there is no session yet —
/// `core_auth` and the real sign-in arrive in M9. What is here already is the
/// *shape* MOBILE.md §5.2 and §6.2 describe, because the shape is the part that
/// is expensive to change later:
///
///   - one `redirect` owns both gates, rather than each screen checking
///   - the role decides the shell, resolved once at launch from `GET /me`
///   - staff are refused on this path entirely, with a reason and a URL
///   - an unsigned professional sees the onboarding gate, never an empty
///     dashboard
///
/// The last one is not a detail. An unsigned vendor is in no lead pool however
/// verified they are, so a dashboard reading "0 leads" is both true and the
/// worst first impression this app can make. They must see what is missing.
library;

import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'env.dart';
import 'gallery.dart';

/// What the app knows about who is using it.
///
/// Replaced in M9 by the real session, resolved from `GET /me` against a bearer
/// token in secure storage. Kept deliberately small: the router needs the role
/// and the onboarding state, and nothing else.
enum Shell { unknown, signedOut, customer, vendor, vendorOnboarding, staffRefused }

/// Notifies the router when the shell changes, so `redirect` re-runs.
class SessionState extends ChangeNotifier {
  Shell _shell = Shell.unknown;
  Shell get shell => _shell;

  set shell(Shell value) {
    if (_shell == value) return;
    _shell = value;
    notifyListeners();
  }
}

abstract final class Routes {
  static const splash = '/';
  static const signIn = '/sign-in';
  static const staffRefused = '/staff';
  static const customerHome = '/home';
  static const vendorDashboard = '/vendor';
  static const vendorOnboarding = '/vendor/onboarding';
  static const gallery = '/_gallery';
}

GoRouter buildRouter(SessionState session) {
  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: session,
    debugLogDiagnostics: !Env.isProduction,

    /// One redirect, not a check per screen.
    ///
    /// Every gate in the app lives here. A screen that decides for itself
    /// whether the user may see it is a screen somebody will forget to write,
    /// and the one they forget is always the one that mattered.
    redirect: (context, state) {
      final location = state.matchedLocation;

      // The gallery is a development surface and deliberately outside the
      // gates — it renders components, not anybody's data.
      if (location == Routes.gallery) {
        return Env.showsGallery ? null : Routes.splash;
      }

      return switch (session.shell) {
        // Still asking `GET /me`. Hold on the splash rather than flashing the
        // sign-in screen at somebody who is already signed in.
        Shell.unknown => location == Routes.splash ? null : Routes.splash,

        Shell.signedOut =>
          location == Routes.signIn ? null : Routes.signIn,

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
      GoRoute(path: Routes.signIn, builder: (context, state) => const _Placeholder('Sign in', 'M9')),
      GoRoute(path: Routes.staffRefused, builder: (context, state) => const _StaffRefused()),
      GoRoute(
        path: Routes.customerHome,
        builder: (context, state) => const _Placeholder('Customer shell', 'M11'),
      ),
      GoRoute(
        path: Routes.vendorOnboarding,
        builder: (context, state) => const _Placeholder('Onboarding gate', 'M10'),
      ),
      GoRoute(
        path: Routes.vendorDashboard,
        builder: (context, state) => const _Placeholder('Vendor shell', 'M10'),
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

/// Staff sign in on the web. Refused here, with somewhere to go.
class _StaffRefused extends StatelessWidget {
  const _StaffRefused();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Space.gutter),
        child: Center(
          child: ActionRequired(
            title: 'Staff sign in on the web',
            body:
                'This app is for customers and professionals. Ops and admin work '
                'from the web panel, which has the tools this one does not.',
          ),
        ),
      ),
    );
  }
}

/// A screen that a later milestone fills in.
class _Placeholder extends StatelessWidget {
  const _Placeholder(this.title, this.milestone);

  final String title;
  final String milestone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(Space.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusPill(milestone, tone: StatusTone.waiting),
            const SizedBox(height: Space.md),
            Text('$title arrives in $milestone.', style: context.text.bodyLarge),
          ],
        ),
      ),
    );
  }
}
