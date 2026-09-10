/// A stubbed API, so the sign-in flow and the gates run for real in a test.
///
/// The interceptors, the controller, the router and the screens are all the
/// production ones. Only the transport is ours, which is the seam worth faking:
/// everything above it is the part that has bugs.
library;

import 'dart:convert';

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:dio/dio.dart';

/// Answers from a route table, and records what it was asked for.
class StubApi implements HttpClientAdapter {
  StubApi();

  /// `'POST /auth/otp/request'` -> a response.
  final Map<String, (int, Object)> routes = {};
  final List<RequestOptions> seen = [];

  void on(String method, String path, Object body, {int status = 200}) {
    routes['$method $path'] = (status, body);
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    seen.add(options);
    final key = '${options.method} ${options.path}';
    final match = routes[key];

    if (match == null) {
      return ResponseBody.fromString(
        jsonEncode({'code': 'not_found', 'message': 'No stub for $key'}),
        404,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    return ResponseBody.fromString(
      jsonEncode(match.$2),
      match.$1,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        'x-request-id': ['req-test'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

InterioBeeApi apiWith(StubApi stub, SessionStore session) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
    ..httpClientAdapter = stub;
  return InterioBeeApi.withDio(dio, session: session);
}

/// A `SessionUser` body, as the API would send it.
/// `mobile` and `cityId` are nullable on purpose, and default to set.
///
/// Most tests want an ordinary, fully set-up account and should not have to say
/// so. The tests that care about somebody who signed up with Google and gave
/// neither pass `mobile: null, cityId: null` — which is a real state now, not a
/// malformed fixture.
Map<String, Object?> sessionUser({
  required String role,
  String name = 'Priya Sharma',
  String? mobile = '919839012477',
  String? cityId = 'city-luc',
  bool? mobileVerified,
}) {
  return {
    'actor': switch (role) {
      'client' => {'role': 'client', 'userId': 'u1', 'clientId': 'c1'},
      'professional' => {
        'role': 'professional',
        'userId': 'u2',
        'professionalId': 'p1',
      },
      'sales_agent' => {
        'role': 'sales_agent',
        'userId': 'u3',
        'salesAgentId': 's1',
      },
      _ => {'role': 'admin', 'userId': 'u4'},
    },
    'name': name,
    'mobile': mobile,
    // Having a number and having proved it are separate answers, so the default
    // follows the number rather than being hard-coded true.
    'mobileVerified': mobileVerified ?? (mobile != null),
    'cityId': cityId,
    'avatarUrl': null,
  };
}

Map<String, Object?> authSession({required String role, String? token}) {
  return switch (role) {
    'client' => {
      'role': 'client',
      'userId': 'u1',
      'clientId': 'c1',
      'sessionToken': ?token,
    },
    'professional' => {
      'role': 'professional',
      'userId': 'u2',
      'professionalId': 'p1',
      'sessionToken': ?token,
    },
    _ => {'role': 'admin', 'userId': 'u4', 'sessionToken': ?token},
  };
}

/// A `VendorOnboarding` body.
///
/// `canReceiveLeads` is the whole decision: false shows the gate, true shows
/// the shell. It is server-computed, so the app never infers it.
Map<String, Object?> onboarding({required bool canReceiveLeads}) {
  Map<String, Object?> step(String key, String label, bool done) => {
    'key': key,
    'label': label,
    'description': 'Needed before leads reach you.',
    'done': done,
    'blocking': true,
    'hint': null,
  };

  return {
    'professionalId': 'p1',
    'steps': [
      step('profile', 'Your profile', true),
      step('identity', 'Identity', true),
      step('trades', 'Trades', canReceiveLeads),
      step('agreement', 'Partner agreement', canReceiveLeads),
    ],
    'completedCount': canReceiveLeads ? 4 : 2,
    'totalCount': 4,
    'canReceiveLeads': canReceiveLeads,
    'blockedReason': canReceiveLeads
        ? null
        : 'The partner agreement is not signed yet.',
    'agreement': null,
    'terms': {
      'version': '1.0',
      'effectiveFrom': '2026-01-01',
      'title': 'Decora Shine partner terms',
      'summary': 'How work reaches you, and what commission is charged.',
      'sections': <Object>[],
      'acknowledgements': <Object>[],
    },
  };
}

/// A `VendorDashboard` body.
Map<String, Object?> dashboard() => {
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
  'newLeads': 0,
  'awaitingQuote': 0,
  'quotesOut': 0,
  'wonThisPeriod': 0,
  'liveProjects': 0,
  'visitsToday': 0,
  'commissionDue': 0,
  'commissionOverdue': 0,
  'unreadMessages': 0,
};
