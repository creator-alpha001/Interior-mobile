/// The professional's five tabs.
///
/// `Dashboard · Leads · Projects · Visits · More`, per MOBILE.md §6.2 — and the
/// gate comes before all of it. An unsigned professional gets
/// [OnboardingGate] instead of this widget, not a tab inside it, because they
/// are in no lead pool and every tab here would be empty for a reason no screen
/// would explain.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_core_upload/aangan_core_upload.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'dashboard_screen.dart';
import 'lead_detail_screen.dart';
import 'leads_screen.dart';
import 'more_screen.dart';
import 'onboarding_gate.dart';
import 'projects_screen.dart';
import 'providers.dart';
import 'thread_screen.dart';
import 'visits_screen.dart';

/// Decides between the gate and the shell, from `GET /vendor/onboarding`.
///
/// The check lives here rather than in the router because it is a *vendor*
/// question, not an auth one — the session is perfectly valid either way, and
/// the router already did its job by choosing the vendor shell at all.
class VendorHome extends ConsumerStatefulWidget {
  const VendorHome({super.key, required this.queueFor, this.onSignOut});

  final UploadQueue Function(String milestoneId) queueFor;
  final VoidCallback? onSignOut;

  @override
  ConsumerState<VendorHome> createState() => _VendorHomeState();
}

class _VendorHomeState extends ConsumerState<VendorHome> {
  /// Set once the vendor taps through from a completed gate, so they are not
  /// bounced back by a stale read.
  bool _dismissedGate = false;

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);

    return AsyncView(
      value: onboarding,
      onRetry: () => ref.invalidate(onboardingProvider),
      data: (state) {
        if (!state.canReceiveLeads && !_dismissedGate) {
          return OnboardingGate(
            onComplete: () => setState(() => _dismissedGate = true),
          );
        }
        return VendorShell(
          queueFor: widget.queueFor,
          onSignOut: widget.onSignOut,
        );
      },
    );
  }
}

class VendorShell extends ConsumerStatefulWidget {
  const VendorShell({super.key, required this.queueFor, this.onSignOut});

  final UploadQueue Function(String milestoneId) queueFor;
  final VoidCallback? onSignOut;

  @override
  ConsumerState<VendorShell> createState() => _VendorShellState();
}

class _VendorShellState extends ConsumerState<VendorShell> {
  int _tab = 0;

  void _openLead(BuildContext context, VendorLeadCard lead) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LeadDetailScreen(
          leadDomainId: lead.leadDomain.id,
          onOpenThread: (l) => _openThread(context, l),
        ),
      ),
    );
  }

  void _openThread(BuildContext context, VendorLeadCard lead) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ThreadScreen(
          leadDomainId: lead.leadDomain.id,
          title: lead.client.displayName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        onOpenLeads: (filter) {
          ref.read(leadFilterProvider.notifier).state = filter;
          setState(() => _tab = 1);
        },
      ),
      LeadsScreen(onOpen: (lead) => _openLead(context, lead)),
      ProjectsScreen(queueFor: widget.queueFor),
      const VisitsScreen(),
      MoreScreen(onSignOut: widget.onSignOut),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        // Thin outline glyphs, terracotta only on the active item — the
        // prototype's bar, carried over directly.
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'DASHBOARD',
          ),
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox),
            label: 'LEADS',
          ),
          NavigationDestination(
            icon: Icon(Icons.construction_outlined),
            selectedIcon: Icon(Icons.construction),
            label: 'PROJECTS',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'VISITS',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz_outlined),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'MORE',
          ),
        ],
      ),
    );
  }
}
