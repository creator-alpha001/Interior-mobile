/// Which tab a notification opens, and which it refuses to.
library;

import 'package:aangan_app/notifications.dart';
import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_core_auth/aangan_core_auth.dart';
import 'package:aangan_core_push/aangan_core_push.dart';
import 'package:flutter_test/flutter_test.dart';

Notification _notification({
  required NotificationType type,
  NotificationEntityType? entityType,
  String? entityId,
}) {
  return Notification(
    createdAt: '2026-09-01T00:00:00.000Z',
    updatedAt: '2026-09-01T00:00:00.000Z',
    deletedAt: null,
    id: 'n1',
    userId: 'u1',
    type: type,
    title: 'Something happened',
    body: 'Details',
    entityType: entityType,
    entityId: entityId,
    isRead: false,
  );
}

void main() {
  group('the vendor', () {
    test('a new lead opens the Leads tab', () {
      final target = targetFor(
        _notification(
          type: NotificationType.newLead,
          entityType: NotificationEntityType.leadDomain,
          entityId: 'ld-42',
        ),
        Shell.vendor,
      );

      expect(target?.audience, PushAudience.vendor);
      expect(target?.tab, VendorTab.leads);
    });

    test('commission due opens More, where invoices live', () {
      final target = targetFor(
        _notification(
          type: NotificationType.commissionDue,
          entityType: NotificationEntityType.invoice,
          entityId: 'inv-1',
        ),
        Shell.vendor,
      );

      expect(target?.tab, VendorTab.more);
    });

    test('a stage decision opens Projects', () {
      final target = targetFor(
        _notification(
          type: NotificationType.projectStarted,
          entityType: NotificationEntityType.project,
          entityId: 'pr-1',
        ),
        Shell.vendor,
      );

      expect(target?.tab, VendorTab.projects);
    });
  });

  group('the customer', () {
    test('an agreement ready to sign opens Account', () {
      final target = targetFor(
        _notification(
          type: NotificationType.agreementReady,
          entityType: NotificationEntityType.agreement,
          entityId: 'ag-1',
        ),
        Shell.customer,
      );

      expect(target?.audience, PushAudience.customer);
      expect(target?.tab, CustomerTab.account);
    });

    test('a quote opens Jobs, where comparison lives', () {
      final target = targetFor(
        _notification(
          type: NotificationType.quoteUploaded,
          entityType: NotificationEntityType.leadDomain,
          entityId: 'ld-7',
        ),
        Shell.customer,
      );

      expect(target?.tab, CustomerTab.jobs);
    });

    test('a message opens Messages', () {
      final target = targetFor(
        _notification(
          type: NotificationType.messageReceived,
          entityType: NotificationEntityType.message,
          entityId: 'ld-7',
        ),
        Shell.customer,
      );

      expect(target?.tab, CustomerTab.messages);
    });
  });

  group('notifications for the wrong shell', () {
    test('a vendor notification is ignored on a customer session', () {
      // A "new lead" arriving on a customer session is a server-side
      // addressing bug. Following it would land them somewhere that does not
      // exist for them; ignoring it is the honest response.
      final target = targetFor(
        _notification(
          type: NotificationType.newLead,
          entityType: NotificationEntityType.leadDomain,
          entityId: 'ld-42',
        ),
        Shell.customer,
      );

      expect(target, isNull);
    });

    test('a customer notification is ignored on a vendor session', () {
      final target = targetFor(
        _notification(
          type: NotificationType.agreementReady,
          entityType: NotificationEntityType.agreement,
          entityId: 'ag-1',
        ),
        Shell.vendor,
      );

      expect(target, isNull);
    });

    test('nothing is followed while signed out', () {
      final target = targetFor(
        _notification(type: NotificationType.newLead),
        Shell.signedOut,
      );

      expect(target, isNull);
    });

    test('nothing is followed for staff, who have no shell here', () {
      final target = targetFor(
        _notification(type: NotificationType.messageReceived),
        Shell.staffRefused,
      );

      expect(target, isNull);
    });
  });

  test('every notification type resolves without throwing, on both shells', () {
    // A type added to the contract after this build shipped must not crash the
    // app from a lock screen.
    for (final type in NotificationType.values) {
      for (final shell in Shell.values) {
        expect(
          () => targetFor(_notification(type: type), shell),
          returnsNormally,
          reason: '$type on $shell',
        );
      }
    }
  });
}
