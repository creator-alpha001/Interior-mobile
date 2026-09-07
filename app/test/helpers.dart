/// A stubbed API, so the sign-in flow and the gates run for real in a test.
///
/// The interceptors, the controller, the router and the screens are all the
/// production ones. Only the transport is ours, which is the seam worth faking:
/// everything above it is the part that has bugs.
library;

import 'dart:convert';

import 'package:aangan_core_api/aangan_core_api.dart';
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

AanganApi apiWith(StubApi stub, SessionStore session) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))..httpClientAdapter = stub;
  return AanganApi.withDio(dio, session: session);
}

/// A `SessionUser` body, as the API would send it.
Map<String, Object?> sessionUser({
  required String role,
  String name = 'Priya Sharma',
  String mobile = '919839012477',
}) {
  return {
    'actor': switch (role) {
      'client' => {'role': 'client', 'userId': 'u1', 'clientId': 'c1'},
      'professional' => {'role': 'professional', 'userId': 'u2', 'professionalId': 'p1'},
      'sales_agent' => {'role': 'sales_agent', 'userId': 'u3', 'salesAgentId': 's1'},
      _ => {'role': 'admin', 'userId': 'u4'},
    },
    'name': name,
    'mobile': mobile,
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
    _ => {
        'role': 'admin',
        'userId': 'u4',
        'sessionToken': ?token,
      },
  };
}
