/// Turning a notification tap into a screen.
///
/// `core_push` decides *where* a notification should land; this decides how to
/// get there given how the shells are actually built.
///
/// **What works, and what does not.** The shells are `IndexedStack`s with their
/// own `Navigator`, not nested `go_router` routes — which means a deep link can
/// select the right shell and the right *tab* today, but cannot yet open a
/// specific record. So `newLead` lands on the vendor's Leads tab rather than on
/// lead `ld-42`.
///
/// That is short of MOBILE.md §9's bar for M12 — *"Every push in 7.2 lands on
/// the right screen"* — and closing it means moving both shells onto nested
/// routes so every record has a URL. That is a real restructure and is recorded
/// in the README rather than half-done here: a deep link that silently drops
/// its id is worse than one that admits it only reaches the list.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_core_auth/aangan_core_auth.dart';
import 'package:aangan_core_push/aangan_core_push.dart';
import 'package:flutter/foundation.dart';

/// Which tab a notification should open, in whichever shell owns it.
@immutable
class NotificationTarget {
  const NotificationTarget({required this.audience, required this.tab});

  final PushAudience audience;

  /// The index into that shell's `NavigationBar`.
  final int tab;
}

/// The vendor's tabs: Dashboard · Leads · Projects · Visits · More.
abstract final class VendorTab {
  static const dashboard = 0;
  static const leads = 1;
  static const projects = 2;
  static const visits = 3;
  static const more = 4;
}

/// The customer's tabs: Home · Explore · Jobs · Messages · Account.
abstract final class CustomerTab {
  static const home = 0;
  static const explore = 1;
  static const jobs = 2;
  static const messages = 3;
  static const account = 4;
}

/// Resolves a notification to a shell and a tab.
///
/// Returns null when the notification belongs to a shell the person is not
/// signed in as — a vendor's "new lead" arriving on a customer session is a
/// server-side addressing bug, and following it would be worse than ignoring
/// it.
NotificationTarget? targetFor(Notification notification, Shell shell) {
  final signedInAs = switch (shell) {
    Shell.customer => PushAudience.customer,
    Shell.vendor || Shell.vendorOnboarding => PushAudience.vendor,
    _ => null,
  };
  if (signedInAs == null) return null;

  // Who is reading decides where the dual-audience notifications go — a
  // confirmed visit and a relay message reach both parties and mean something
  // different to each.
  final link = deepLinkFor(
    type: notification.type,
    entityType: notification.entityType,
    entityId: notification.entityId,
    signedInAs: signedInAs,
  );
  if (link == null) return null;

  final tab = _tabFor(link.location, signedInAs);
  if (tab == null) return null;

  return NotificationTarget(audience: signedInAs, tab: tab);
}

int? _tabFor(String location, PushAudience audience) {
  return switch (audience) {
    PushAudience.vendor => switch (location) {
        final l when l.startsWith('/vendor/leads') => VendorTab.leads,
        final l when l.startsWith('/vendor/projects') => VendorTab.projects,
        final l when l.startsWith('/vendor/visits') => VendorTab.visits,
        final l when l.startsWith('/vendor/invoices') => VendorTab.more,
        final l when l.startsWith('/vendor/performance') => VendorTab.more,
        _ => VendorTab.dashboard,
      },
    PushAudience.customer => switch (location) {
        final l when l.startsWith('/home/services') && l.endsWith('/messages') =>
          CustomerTab.messages,
        final l when l.startsWith('/home/requirements') => CustomerTab.jobs,
        final l when l.startsWith('/home/services') => CustomerTab.jobs,
        final l when l.startsWith('/home/agreements') => CustomerTab.account,
        final l when l.startsWith('/home/projects') => CustomerTab.account,
        final l when l.startsWith('/home/visits') => CustomerTab.jobs,
        _ => CustomerTab.home,
      },
  };
}
