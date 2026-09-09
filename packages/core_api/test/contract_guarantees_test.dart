/// Guarantees about the *generated* code that the generator will not give us.
///
/// MOBILE.md §4.3 names two of these explicitly as things that "must be added
/// by hand", because a schema change on the server could otherwise introduce
/// them silently, months later, and the first sign would be a customer's phone
/// number on a vendor's screen.
library;

import 'dart:io';

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:test/test.dart';

/// Source with comment lines stripped.
///
/// Without this, prose *explaining* a rule trips the check for that rule — the
/// comment in `offline_cache.dart` saying why `ChangeNotifier` is unavailable
/// mentions `package:flutter/foundation.dart`, and failed the very test it was
/// describing.
String _code(File file) => file
    .readAsStringSync()
    .split('\n')
    .where((line) {
      final trimmed = line.trimLeft();
      return !trimmed.startsWith('//') && !trimmed.startsWith('///');
    })
    .join('\n');

void main() {
  group('masking survives code generation', () {
    /// The platform's central promise, checked on this side of the wire too.
    ///
    /// The web repository asserts it three ways already: the schema has no such
    /// key, a contract test follows every `$ref` in every `/vendor` response
    /// looking for one, and an integration test greps real responses for seed
    /// phone numbers. This is the fourth place it could break — a generated
    /// model that somehow acquired the field — and it is the one closest to a
    /// vendor's handset.
    test('MaskedClientSummary has no field for contact details', () {
      const masked = MaskedClientSummary(
        displayName: 'Priya S.',
        city: City(
          id: 'city-1',
          name: 'Lucknow',
          slug: 'lucknow',
          state: 'Uttar Pradesh',
          isActive: true,
        ),
        locality: 'Gomti Nagar',
        address: null,
        contactReleased: false,
      );

      final json = masked.toJson();

      for (final forbidden in ['mobile', 'email', 'phone', 'phoneNumber']) {
        expect(
          json.containsKey(forbidden),
          isFalse,
          reason: 'MaskedClientSummary must have nowhere to put a $forbidden',
        );
      }

      expect(json['contactReleased'], isFalse);
    });

    test('the address is nullable, because it is released per service', () {
      // Locality up front; the full address only once a visit for *that*
      // service is confirmed. The null is the sealed state, and it is a
      // first-class UI state rather than an empty line.
      expect(
        () => MaskedClientSummary.fromJson(const {
          'displayName': 'Priya S.',
          'city': {
            'id': 'city-1',
            'name': 'Lucknow',
            'slug': 'lucknow',
            'state': 'Uttar Pradesh',
            'isActive': true,
          },
          'locality': 'Gomti Nagar',
          'address': null,
          'contactReleased': false,
        }),
        returnsNormally,
      );
    });
  });

  group('money is never a double', () {
    /// MOBILE.md §4.3: *`Rupees` is an `int`. Make it a Dart `int`, never a
    /// `double`.* Money in a floating-point type is how ₹1 goes missing.
    ///
    /// The generator decides this from `{"type": "integer"}` versus
    /// `{"type": "number"}` in the schema, so it is a property of the contract
    /// rather than of the Dart, and worth pinning here.
    test('a quote line is statically an int, not merely an int at runtime', () {
      final quote = QuoteLineItem.fromJson(const {
        'id': 'line-1',
        'description': 'Wardrobe shutters',
        'quantity': 4,
        'unit': 'piece',
        'rate': 12500,
        'amount': 50000,
      });

      /// The assignment *is* the assertion.
      ///
      /// The first version of this test wrote `expect(quote.rate, isA<int>())`
      /// and passed while every amount in the generated client was typed
      /// `num` — because `isA` inspects the runtime value, and `12500` decoded
      /// from JSON is an `int` whatever the declaration says. It proved nothing,
      /// and the gap only surfaced when a screen tried to build a `Rupees` out
      /// of one.
      ///
      /// These two lines do not compile unless the fields are declared `int`,
      /// which holds only because `openapi.json` says `"type": "integer"`,
      /// which holds only because `rupeesSchema` is `z.number().int()`.
      final int rate = quote.rate;
      final int amount = quote.amount;

      expect(rate, 12500);
      expect(amount, 50000);
    });

    test('commission on the dashboard is an int', () {
      // The figure that matters most: money the vendor owes, computed
      // server-side and frozen at signing.
      final due = _dashboard.commissionDue;
      final overdue = _dashboard.commissionOverdue;

      // Same mechanism — these fail to compile if the fields become `num`.
      final int dueRupees = due;
      final int overdueRupees = overdue;

      expect(dueRupees, 45000);
      expect(overdueRupees, 0);
    });
  });

  group('the roles are a compiler-checked union', () {
    /// MOBILE.md §4.2 wanted freezed unions so "the four-way lead status" gets
    /// a compiler-checked `switch` in the UI. The same applies to the actor,
    /// which is what the router branches on at launch.
    ///
    /// This only works because `openapi.json` describes `Actor` as `oneOf` with
    /// a `discriminator`; a bare `anyOf` generated `ActorUnion.variant1`, which
    /// is a union you cannot read.
    test('an actor switch is exhaustive and names its variants', () {
      const actors = <Actor>[
        Actor.client(
          role: ActorClientRole.client,
          userId: 'u1',
          clientId: 'c1',
        ),
        Actor.professional(
          role: ActorProfessionalRole.professional,
          userId: 'u2',
          professionalId: 'p1',
        ),
        Actor.salesAgent(
          role: ActorSalesAgentRole.salesAgent,
          userId: 'u3',
          salesAgentId: 's1',
        ),
        Actor.admin(role: ActorAdminRole.admin, userId: 'u4'),
      ];

      // No default branch. If a fifth role is ever added to the contract, this
      // stops compiling — which is the entire point.
      final shells = actors.map(
        (actor) => switch (actor) {
          ActorClient() => 'customer',
          ActorProfessional() => 'vendor',
          ActorSalesAgent() => 'refused: staff sign in on the web',
          ActorAdmin() => 'refused: staff sign in on the web',
        },
      );

      expect(shells, [
        'customer',
        'vendor',
        'refused: staff sign in on the web',
        'refused: staff sign in on the web',
      ]);
    });

    test('round-trips through JSON on the role discriminator', () {
      final decoded = Actor.fromJson(const {
        'role': 'sales_agent',
        'userId': 'u3',
        'salesAgentId': 's1',
      });

      expect(decoded, isA<ActorSalesAgent>());
    });
  });

  group('an unset optional is absent from the wire, not null', () {
    /// This one bit for real, on the sign-in screen, against the running API.
    ///
    /// Every returning customer verifies a code with no name and no city, and
    /// the generated body serialised those as `"name": null`. The API's schema
    /// declares them as optional strings, and optional in JSON Schema means
    /// *absent* — JSON has no `undefined`, so the only way to say "not
    /// supplied" is to leave the key out. It answered 422, and the screen said
    /// "Some of those values are not valid" with nothing to act on.
    ///
    /// `include_if_null: false` in `build.yaml` is the fix. This test is here
    /// because that setting lives in a config file nobody reads, and losing it
    /// would break sign-in for existing accounts only — the path least likely
    /// to be tried first.
    test('an omitted optional does not appear as a null', () {
      final json = const VerifyOtpBody(
        challengeId: '01a07f5b-5ae0-7123-98b5-6e4858533051',
        code: '680800',
      ).toJson();

      expect(json.containsKey('name'), isFalse);
      expect(json.containsKey('cityId'), isFalse);
      expect(json, {
        'challengeId': '01a07f5b-5ae0-7123-98b5-6e4858533051',
        'code': '680800',
      });
    });

    test('a supplied optional is still sent', () {
      final json = const VerifyOtpBody(
        challengeId: '01a07f5b-5ae0-7123-98b5-6e4858533051',
        code: '680800',
        name: 'Priya Sharma',
      ).toJson();

      expect(json['name'], 'Priya Sharma');
      expect(json.containsKey('cityId'), isFalse);
    });

    /// Not specific to sign-in. Every request model the generator emits shares
    /// the setting, so one more is checked to prove it is the config and not a
    /// coincidence of that one class.
    test('the rule belongs to the generator, not to one model', () {
      final json = const DeleteAccountBody(
        confirm: DeleteAccountBodyConfirm.delete,
      ).toJson();

      expect(json.containsKey('reason'), isFalse);
    });
  });

  group('this package stays free of the things it must not have', () {
    /// MOBILE.md §4.1: `core_api` depends on neither Flutter nor `design`.
    ///
    /// That is what makes it generatable and testable without a widget tree —
    /// this whole file runs under `dart test`, not `flutter test`. A stray
    /// `package:flutter` import would end that quietly.
    test('no Flutter import anywhere', () {
      final offenders = <String>[];

      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (_code(entity).contains('package:flutter/'))
          offenders.add(entity.path);
      }

      expect(offenders, isEmpty, reason: 'core_api must not depend on Flutter');
    });

    /// The ops surface has no client in this binary at all.
    ///
    /// `openapi.json` documents it, because it is the API's document. But
    /// admin is web-only, and the ops responses carry commission figures,
    /// vendor margins and unmasked customer phone numbers. Deleting the
    /// generated client means a screen cannot call `/ops/*` even by mistake —
    /// there is no method to call.
    test('no staff client was generated', () {
      expect(
        File('lib/src/generated/clients/staff_client.dart').existsSync(),
        isFalse,
        reason: 'the mobile binary must have no route into the ops surface',
      );

      final exported = File('lib/src/generated/export.dart').readAsStringSync();
      expect(exported.contains('staff_client'), isFalse);
    });

    test('no dialer or SMS launcher reachable from here', () {
      // The vendor packages get their own grep test when they exist. This one
      // covers the layer they all sit on.
      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final code = _code(entity);
        if (code.contains('tel:') || code.contains('url_launcher')) {
          offenders.add(entity.path);
        }
      }
      expect(offenders, isEmpty);
    });
  });
}

/// A dashboard payload, as the API sends it.
final _dashboard = VendorDashboard.fromJson(const {
  'professional': {
    'createdAt': '2026-01-01T00:00:00.000Z',
    'updatedAt': '2026-01-01T00:00:00.000Z',
    'deletedAt': null,
    'id': 'p1',
    'userId': 'u2',
    'companyName': 'Meher Interiors',
    'gstNumber': null,
    'experienceYears': 9,
    'bio': '',
    'avgRating': 4.6,
    'ratingCount': 22,
    'completedProjects': 31,
    'languages': <String>[],
    'verificationStatus': 'verified',
    'avgResponseHours': 3,
  },
  'displayName': 'Aarohi Verma',
  'domains': <Object>[],
  'newLeads': 2,
  'awaitingQuote': 1,
  'quotesOut': 3,
  'wonThisPeriod': 1,
  'liveProjects': 2,
  'visitsToday': 0,
  'commissionDue': 45000,
  'commissionOverdue': 0,
  'unreadMessages': 4,
});
