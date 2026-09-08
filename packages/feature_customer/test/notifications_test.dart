/// A notification that opens the thing it is about.
///
/// The row used to have no tap at all. "Aangan replied about your wardrobes"
/// was a sentence and a dead end: the reader had to close the screen, find the
/// Jobs tab, find the requirement, find the service, and open the thread —
/// having already been told which one it was.
///
/// The resolution runs against **what is already loaded**, never a fetch. A
/// spinner on a list row, or four requests fired because somebody opened their
/// notifications, would both be worse than a row that is not tappable.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:aangan_feature_customer/aangan_feature_customer.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

Future<void> _pump(
  WidgetTester tester, {
  required List<Notification> notifications,
  List<LeadView>? requirements,
}) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerApiProvider.overrideWithValue(fixtureApi()),
        notificationsProvider.overrideWith((ref) async => notifications),
        requirementsProvider.overrideWith(
          (ref) async => requirements ?? const <LeadView>[],
        ),
      ],
      child: MaterialApp(
        theme: AanganTheme.light,
        home: const NotificationsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a message notification opens that service thread', (
    tester,
  ) async {
    await _pump(
      tester,
      notifications: [
        fixtureNotification(
          entityType: NotificationEntityType.message,
          entityId: 'ld-1',
        ),
      ],
      requirements: [fixtureRequirement()],
    );

    await tester.tap(find.text('Aangan replied about your wardrobes'));
    await tester.pumpAndSettle();

    expect(find.byType(ServiceThreadScreen), findsOneWidget);
  });

  testWidgets('a quote notification opens the comparison, not the list', (
    tester,
  ) async {
    await _pump(
      tester,
      notifications: [
        fixtureNotification(
          entityType: NotificationEntityType.quote,
          entityId: 'ld-1',
          type: NotificationType.quoteUploaded,
        ),
      ],
      requirements: [
        fixtureRequirement(
          services: [
            fixtureService(quotes: [fixtureQuoteView()]),
          ],
        ),
      ],
    );

    await tester.tap(find.text('Aangan replied about your wardrobes'));
    await tester.pumpAndSettle();

    expect(find.byType(QuoteComparisonScreen), findsOneWidget);
  });

  testWidgets('a quote notification with no quotes yet does not open an '
      'empty comparison', (tester) async {
    // The notification can outrun the read: it fires when a quote lands, and
    // the requirements in memory may predate it. An empty comparison screen
    // would look like the quote had been withdrawn.
    await _pump(
      tester,
      notifications: [
        fixtureNotification(
          entityType: NotificationEntityType.quote,
          entityId: 'ld-1',
          type: NotificationType.quoteUploaded,
        ),
      ],
      requirements: [fixtureRequirement()],
    );

    await tester.tap(find.text('Aangan replied about your wardrobes'));
    await tester.pumpAndSettle();

    expect(find.byType(QuoteComparisonScreen), findsNothing);
  });

  testWidgets('a notification whose record is gone stays put', (tester) async {
    // A notification outliving the thing it points at is ordinary, not an
    // error. It must not throw inside a list builder.
    await _pump(
      tester,
      notifications: [
        fixtureNotification(
          entityType: NotificationEntityType.message,
          entityId: 'ld-vanished',
        ),
      ],
      requirements: [fixtureRequirement()],
    );

    await tester.tap(find.text('Aangan replied about your wardrobes'));
    await tester.pumpAndSettle();

    expect(find.byType(ServiceThreadScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a notification with no entity at all is still readable', (
    tester,
  ) async {
    await _pump(tester, notifications: [fixtureNotification()]);

    expect(find.text('Aangan replied about your wardrobes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
