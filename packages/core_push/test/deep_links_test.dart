/// Where each notification lands.
///
/// MOBILE.md §9 sets M12's bar as *"Every push in 7.2 lands on the right
/// screen"*, and §7.2 lists exactly which notifications earn an interruption.
/// This walks that table.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_core_push/interiobee_core_push.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the vendor’s pushes', () {
    test('a new lead opens that lead, not the list', () {
      // Time-critical: the first quote in often wins. Landing on a list and
      // making them find it wastes the interruption.
      final link = deepLinkFor(
        type: NotificationType.newLead,
        entityType: NotificationEntityType.leadDomain,
        entityId: 'ld-42',
      );

      expect(link?.location, '/vendor/leads/ld-42');
      expect(link?.requiresRole, PushAudience.vendor);
    });

    test('commission due opens the invoices screen', () {
      final link = deepLinkFor(
        type: NotificationType.commissionDue,
        entityType: NotificationEntityType.invoice,
        entityId: 'inv-1',
      );

      expect(link?.location, '/vendor/invoices');
      expect(link?.requiresRole, PushAudience.vendor);
    });

    test('a review opens performance, where per-trade ratings live', () {
      final link = deepLinkFor(type: NotificationType.reviewReceived);
      expect(link?.location, '/vendor/performance');
    });

    test('falls back to the leads list when the id is missing', () {
      // A notification with no entity id is still worth opening the right
      // screen for. Nowhere is the wrong answer.
      final link = deepLinkFor(type: NotificationType.newLead);
      expect(link?.location, '/vendor/leads');
    });
  });

  group('the customer’s pushes', () {
    test('a quote lands on the comparison for that service', () {
      final link = deepLinkFor(
        type: NotificationType.quoteUploaded,
        entityType: NotificationEntityType.leadDomain,
        entityId: 'ld-7',
      );

      expect(link?.location, '/home/services/ld-7');
      expect(link?.requiresRole, PushAudience.customer);
    });

    test('an agreement ready to sign opens that agreement', () {
      // The single most valuable deep link on the customer side: signing is
      // the action that starts the work.
      final link = deepLinkFor(
        type: NotificationType.agreementReady,
        entityType: NotificationEntityType.agreement,
        entityId: 'ag-9',
      );

      expect(link?.location, '/home/agreements/ag-9');
      expect(link?.requiresRole, PushAudience.customer);
    });

    test('a professional assigned opens the requirement', () {
      final link = deepLinkFor(
        type: NotificationType.professionalAssigned,
        entityType: NotificationEntityType.lead,
        entityId: 'lead-3',
      );

      expect(link?.location, '/home/requirements/lead-3');
    });
  });

  group('notifications that go to both sides', () {
    /// "New relay message" reaches both parties and means something different
    /// to each, so the destination comes from who is reading it rather than
    /// from the type. Binding it to one audience would send half of them wrong;
    /// leaving it unresolved sends all of them nowhere.
    test('a message goes to the vendor’s thread for a vendor', () {
      final link = deepLinkFor(
        type: NotificationType.messageReceived,
        entityType: NotificationEntityType.message,
        entityId: 'ld-4',
        signedInAs: PushAudience.vendor,
      );

      expect(link?.location, '/vendor/leads/ld-4/messages');
    });

    test('and to the customer’s thread for a customer', () {
      final link = deepLinkFor(
        type: NotificationType.messageReceived,
        entityType: NotificationEntityType.message,
        entityId: 'ld-4',
        signedInAs: PushAudience.customer,
      );

      expect(link?.location, '/home/services/ld-4/messages');
    });

    test('a confirmed visit follows the reader too', () {
      // Someone is travelling — which someone depends on who is reading it.
      expect(
        deepLinkFor(
          type: NotificationType.meetingConfirmed,
          entityType: NotificationEntityType.meeting,
          entityId: 'meet-1',
          signedInAs: PushAudience.vendor,
        )?.location,
        '/vendor/visits',
      );

      expect(
        deepLinkFor(
          type: NotificationType.meetingConfirmed,
          entityType: NotificationEntityType.meeting,
          entityId: 'meet-1',
          signedInAs: PushAudience.customer,
        )?.location,
        '/home/visits/meet-1',
      );
    });

    test(
      'a bound notification read by the wrong shell resolves to nothing',
      () {
        // A vendor's "new lead" arriving on a customer session is a server-side
        // addressing bug. Following it would land them somewhere that does not
        // exist for them.
        final link = deepLinkFor(
          type: NotificationType.newLead,
          entityType: NotificationEntityType.leadDomain,
          entityId: 'ld-42',
          signedInAs: PushAudience.customer,
        );

        expect(link, isNull);
      },
    );
  });

  group('when there is nothing better to open', () {
    test('returns null rather than inventing a route', () {
      // An honest null. The app stays where it is, which beats a route that
      // does not exist or a home screen that explains nothing.
      final link = deepLinkFor(type: NotificationType.projectCompleted);
      expect(link, isNull);
    });

    test('an entity type this build predates does not throw', () {
      // The generator emits `$unknown` for values added server-side after this
      // build shipped. A push carrying one must not crash the app.
      final link = deepLinkFor(
        type: NotificationType.$unknown,
        entityType: NotificationEntityType.$unknown,
        entityId: 'x',
      );

      expect(link, isNull);
    });
  });

  test('every notification type resolves without throwing', () {
    // The table has to stay total. A type added to the contract that nothing
    // here handles would otherwise surface as a crash on somebody's lock
    // screen.
    for (final type in NotificationType.values) {
      for (final entity in [null, ...NotificationEntityType.values]) {
        expect(
          () => deepLinkFor(type: type, entityType: entity, entityId: 'id-1'),
          returnsNormally,
          reason: 'type $type with entity $entity',
        );
      }
    }
  });
}
