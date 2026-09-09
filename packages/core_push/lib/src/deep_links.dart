/// Where a notification tap should land.
///
/// MOBILE.md §7.2: *"Deep links per notification type, so a tap lands on the
/// record, not the home screen."* A push that opens the home screen wastes the
/// only interruption the platform is allowed, and the person has to go and find
/// whatever it was telling them about.
///
/// The mapping is a pure function of `entityType` and `entityId`, which every
/// notification carries precisely so this is possible. It is here, in a package
/// with no UI, so the routes can be tested without a widget tree and so the
/// same table serves a foreground tap, a background tap and a cold start.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:meta/meta.dart';

/// A destination inside the app.
@immutable
class DeepLink {
  const DeepLink(this.location, {this.requiresRole});

  /// A go_router location, e.g. `/home/requirements/abc`.
  final String location;

  /// Which shell this belongs to, when it belongs to exactly one.
  ///
  /// A vendor tapping "quote selected" and a customer tapping "agreement ready"
  /// go to different places, and a notification for the wrong shell is a bug
  /// worth catching rather than rendering.
  final PushAudience? requiresRole;

  @override
  bool operator ==(Object other) =>
      other is DeepLink &&
      other.location == location &&
      other.requiresRole == requiresRole;

  @override
  int get hashCode => Object.hash(location, requiresRole);

  @override
  String toString() => 'DeepLink($location)';
}

enum PushAudience { customer, vendor }

/// Resolves a notification to somewhere worth opening.
///
/// Returns null when there is nothing better than where the person already is —
/// a legitimate answer, and better than inventing a route.
///
/// [signedInAs] matters more than it looks. Several notifications in
/// MOBILE.md §7.2 go to **both** parties — a confirmed visit, a relay message,
/// a stage decision — and mean something different to each. Their destination
/// cannot come from the type, so it comes from who is reading it. Without this
/// parameter those types resolved to nothing at all, which two tests caught.
DeepLink? deepLinkFor({
  required NotificationType type,
  NotificationEntityType? entityType,
  String? entityId,
  PushAudience? signedInAs,
}) {
  final boundTo = _audienceFor(type);

  // A notification addressed to the other shell is not followed. That is a
  // server-side addressing bug, and chasing it would land somebody on a screen
  // that does not exist for them.
  if (boundTo != null && signedInAs != null && boundTo != signedInAs) {
    return null;
  }

  // Bound types keep their audience; dual-audience ones take the reader's.
  final audience = boundTo ?? signedInAs;
  if (audience == null) return _fallbackFor(type, boundTo);

  if (entityId == null || entityType == null) {
    // Still worth opening the right list. "Commission due" with no invoice id
    // should land on the invoices screen rather than nowhere.
    return _fallbackFor(type, audience);
  }

  return switch ((audience, entityType)) {
    // ---- the customer side ----
    (PushAudience.customer, NotificationEntityType.lead) => DeepLink(
      '/home/requirements/$entityId',
      requiresRole: audience,
    ),
    (PushAudience.customer, NotificationEntityType.leadDomain) => DeepLink(
      '/home/services/$entityId',
      requiresRole: audience,
    ),
    (PushAudience.customer, NotificationEntityType.quote) => DeepLink(
      '/home/services/$entityId/quotes',
      requiresRole: audience,
    ),
    (PushAudience.customer, NotificationEntityType.agreement) => DeepLink(
      '/home/agreements/$entityId',
      requiresRole: audience,
    ),
    (PushAudience.customer, NotificationEntityType.project) => DeepLink(
      '/home/projects/$entityId',
      requiresRole: audience,
    ),
    (PushAudience.customer, NotificationEntityType.meeting) => DeepLink(
      '/home/visits/$entityId',
      requiresRole: audience,
    ),
    (PushAudience.customer, NotificationEntityType.message) => DeepLink(
      '/home/services/$entityId/messages',
      requiresRole: audience,
    ),

    // ---- the vendor side ----
    (PushAudience.vendor, NotificationEntityType.leadDomain) => DeepLink(
      '/vendor/leads/$entityId',
      requiresRole: audience,
    ),
    (PushAudience.vendor, NotificationEntityType.lead) => DeepLink(
      '/vendor/leads/$entityId',
      requiresRole: audience,
    ),
    (PushAudience.vendor, NotificationEntityType.quote) => DeepLink(
      '/vendor/leads/$entityId',
      requiresRole: audience,
    ),
    (PushAudience.vendor, NotificationEntityType.meeting) => DeepLink(
      '/vendor/visits',
      requiresRole: audience,
    ),
    (PushAudience.vendor, NotificationEntityType.project) => DeepLink(
      '/vendor/projects/$entityId',
      requiresRole: audience,
    ),
    (PushAudience.vendor, NotificationEntityType.invoice) => DeepLink(
      '/vendor/invoices',
      requiresRole: audience,
    ),
    (PushAudience.vendor, NotificationEntityType.message) => DeepLink(
      '/vendor/leads/$entityId/messages',
      requiresRole: audience,
    ),

    // An entity type this build predates, or one that does not belong to the
    // audience the type implies. Fall back rather than guess.
    _ => _fallbackFor(type, audience),
  };
}

/// The shell a notification is addressed to, when the type decides it alone.
///
/// Exposed so a caller can tell "this is not mine" from "this has no better
/// destination", which are different situations.
PushAudience? audienceFor(NotificationType type) => _audienceFor(type);

/// Which shell a notification type belongs to.
///
/// From the table in MOBILE.md §7.2. `meeting_confirmed` and
/// `message_received` go to both sides, and are resolved by whichever shell is
/// signed in rather than by the type.
PushAudience? _audienceFor(NotificationType type) => switch (type) {
  NotificationType.newLead ||
  NotificationType.commissionDue ||
  NotificationType.reviewReceived => PushAudience.vendor,

  NotificationType.professionalAssigned ||
  NotificationType.quoteUploaded ||
  NotificationType.agreementReady => PushAudience.customer,

  // Both sides get these, and the meaning differs. Left unbound so the
  // signed-in shell decides.
  NotificationType.meetingConfirmed ||
  NotificationType.messageReceived ||
  NotificationType.agreementSigned ||
  NotificationType.projectStarted ||
  NotificationType.projectCompleted ||
  NotificationType.$unknown => null,
};

DeepLink? _fallbackFor(NotificationType type, PushAudience? audience) {
  return switch (audience) {
    PushAudience.vendor => switch (type) {
      NotificationType.newLead => const DeepLink(
        '/vendor/leads',
        requiresRole: PushAudience.vendor,
      ),
      NotificationType.commissionDue => const DeepLink(
        '/vendor/invoices',
        requiresRole: PushAudience.vendor,
      ),
      NotificationType.reviewReceived => const DeepLink(
        '/vendor/performance',
        requiresRole: PushAudience.vendor,
      ),
      NotificationType.messageReceived => const DeepLink('/vendor/leads'),
      NotificationType.projectStarted ||
      NotificationType.projectCompleted ||
      NotificationType.agreementSigned => const DeepLink('/vendor/projects'),
      NotificationType.meetingConfirmed => const DeepLink('/vendor/visits'),
      _ => null,
    },
    PushAudience.customer => switch (type) {
      NotificationType.agreementReady => const DeepLink(
        '/home/agreements',
        requiresRole: PushAudience.customer,
      ),
      NotificationType.quoteUploaded ||
      NotificationType.professionalAssigned => const DeepLink(
        '/home/requirements',
        requiresRole: PushAudience.customer,
      ),
      NotificationType.messageReceived => const DeepLink('/home/messages'),
      NotificationType.projectStarted ||
      NotificationType.projectCompleted ||
      NotificationType.agreementSigned => const DeepLink('/home/projects'),
      NotificationType.meetingConfirmed => const DeepLink('/home/visits'),
      _ => null,
    },
    // Nothing better than where they are. An honest null.
    null => null,
  };
}
