/// What the client promises, asserted against a stubbed transport.
///
/// No network and no database: dio's `DioAdapter` seam lets the interceptors be
/// exercised for real while the responses are ours. What is checked here is the
/// set of decisions in MOBILE.md §7.5 — the ones that are cheap to get wrong
/// and expensive to discover on somebody's phone.
library;

import 'dart:convert';

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

/// A transport that answers from a script and records what it was asked.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.respond);

  /// Given the attempt number (1-based), produce a response.
  final ResponseBody Function(int attempt, RequestOptions options) respond;

  final List<RequestOptions> seen = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    seen.add(options);
    return respond(seen.length, options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, int status) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
    'x-request-id': ['req-abc123'],
  },
);

(InterioBeeApi, _StubAdapter, InMemorySession) _build(
  ResponseBody Function(int attempt, RequestOptions options) respond, {
  String? token,
}) {
  final adapter = _StubAdapter(respond);
  final session = InMemorySession(token);
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
    ..httpClientAdapter = adapter;
  final api = InterioBeeApi.withDio(dio, session: session);
  return (api, adapter, session);
}

void main() {
  group('headers', () {
    test(
      'identifies itself as mobile, so sign-in returns a bearer token',
      () async {
        // Without this the API only sets a cookie, and a Flutter client that
        // holds a cookie jar inherits every SameSite and domain question for no
        // benefit. The header is what makes the session token a value the app
        // owns.
        final (api, adapter, _) = _build((_, __) => _json([], 200));
        await api.public.listCities();

        expect(adapter.seen.single.headers[kClientHeader], kClientValue);
      },
    );

    test('sends the bearer token when there is a session', () async {
      final (api, adapter, _) = _build(
        (_, __) => _json([], 200),
        token: 'sess-token',
      );
      await api.public.listCities();

      expect(adapter.seen.single.headers['authorization'], 'Bearer sess-token');
    });

    test('sends no authorization header when signed out', () async {
      final (api, adapter, _) = _build((_, __) => _json([], 200));
      await api.public.listCities();

      expect(adapter.seen.single.headers.containsKey('authorization'), isFalse);
    });

    test('carries a request id, which the API echoes back', () async {
      final (api, adapter, _) = _build((_, __) => _json([], 200));
      await api.public.listCities();

      final id = adapter.seen.single.headers[kRequestIdHeader];
      expect(id, isA<String>());
      expect((id! as String).length, greaterThan(8));
    });

    test('reads the token freshly on each request', () async {
      // Signing in, signing out and being revoked all change the token while
      // the app is running. Capturing it once at construction is a bug that
      // only shows up after the second sign-in.
      final (api, adapter, session) = _build((_, __) => _json([], 200));

      await api.public.listCities();
      session.token = 'arrived-later';
      await api.public.listCities();

      expect(adapter.seen.first.headers.containsKey('authorization'), isFalse);
      expect(
        adapter.seen.last.headers['authorization'],
        'Bearer arrived-later',
      );
    });
  });

  group('errors become ApiException', () {
    test('a 404 says not found, and never "no access"', () async {
      // The API answers 404 for a record belonging to somebody else, on
      // purpose: a 403 would confirm it exists. The client must not
      // re-interpret that.
      final (api, _, __) = _build(
        (_, __) => _json({
          'code': 'not_found',
          'message': 'We could not find that.',
        }, 404),
      );

      final error = await _capture(() => api.customer.listRequirements());
      expect(error.failure, ApiFailure.notFound);
      expect(error.message.toLowerCase(), isNot(contains('access')));
    });

    test(
      'carries the request id through, for a support conversation',
      () async {
        final (api, _, __) = _build(
          (_, __) => _json({'code': 'internal_error', 'message': 'Boom'}, 500),
        );

        final error = await _capture(() => api.customer.listRequirements());
        expect(error.requestId, 'req-abc123');
      },
    );

    test('a 422 keeps the field details', () async {
      final (api, _, __) = _build(
        (_, __) => _json({
          'code': 'invalid_request',
          'message': 'Some of those values are not valid',
          'details': [
            {
              'path': 'budgetMin',
              'message': 'The lower budget must not exceed the upper one',
            },
          ],
        }, 422),
      );

      final error = await _capture(() => api.customer.listRequirements());
      expect(error.failure, ApiFailure.invalidRequest);
      expect(error.details, isA<List<dynamic>>());
    });

    test('a 429 surfaces the retry time rather than guessing', () async {
      final adapter = _StubAdapter(
        (_, __) => ResponseBody.fromString(
          jsonEncode({'code': 'rate_limited', 'message': 'Too many attempts'}),
          429,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
            'retry-after': ['45'],
          },
        ),
      );
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = adapter;
      final api = InterioBeeApi.withDio(dio);

      final error = await _capture(() => api.customer.listRequirements());
      expect(error.failure, ApiFailure.rateLimited);
      expect(error.retryAfter, const Duration(seconds: 45));
    });
  });

  group('a revoked session', () {
    test('clears the session exactly once and does not retry', () async {
      // A 401 mid-session means suspended, or signed out on another device.
      // Sessions are rows rather than JWTs precisely so that can happen. There
      // is nothing to retry: the answer is to clear and route to sign-in.
      final (api, adapter, session) = _build(
        (_, __) => _json({
          'code': 'not_authenticated',
          'message': 'Please sign in again.',
        }, 401),
        token: 'stale',
      );

      final error = await _capture(() => api.customer.listRequirements());

      expect(error.failure, ApiFailure.notAuthenticated);
      expect(session.revocations, 1);
      expect(
        adapter.seen.length,
        1,
        reason: 'a revoked session must not be retried',
      );
    });
  });

  group('retry', () {
    test('retries a failed GET twice, then gives up', () async {
      final (api, adapter, _) = _build(
        (_, __) => _json({'code': 'internal_error', 'message': 'Boom'}, 500),
      );

      final error = await _capture(() => api.public.listCities());

      expect(error.failure, ApiFailure.serverError);
      expect(
        adapter.seen.length,
        3,
        reason: 'the original attempt plus two retries',
      );
    });

    test('stops retrying as soon as one succeeds', () async {
      final (api, adapter, _) = _build(
        (attempt, __) => attempt == 1
            ? _json({'code': 'internal_error', 'message': 'Boom'}, 500)
            : _json(<dynamic>[], 200),
      );

      await api.public.listCities();
      expect(adapter.seen.length, 2);
    });

    test('NEVER retries a POST', () async {
      // The one that matters. `POST /me/agreements/:id/sign` is the largest
      // transaction in the system — five tables, a locked row, one commission
      // invoice. A retried sign is a second set of projects and a second
      // invoice. When a write times out the app re-reads; it does not resend.
      final (api, adapter, _) = _build(
        (_, __) => _json({'code': 'internal_error', 'message': 'Boom'}, 500),
      );

      await _capture(() => api.customer.signAgreement(id: 'agreement-1'));

      expect(
        adapter.seen.length,
        1,
        reason: 'a write must never be retried automatically',
      );
      expect(adapter.seen.single.method, 'POST');
    });

    test(
      'does not retry a 429 — that is the opposite of what was asked',
      () async {
        final (api, adapter, _) = _build(
          (_, __) =>
              _json({'code': 'rate_limited', 'message': 'Slow down'}, 429),
        );

        await _capture(() => api.public.listCities());
        expect(adapter.seen.length, 1);
      },
    );

    test('does not retry a 404, which will not become true', () async {
      final (api, adapter, _) = _build(
        (_, __) => _json({'code': 'not_found', 'message': 'No'}, 404),
      );

      await _capture(() => api.public.listCities());
      expect(adapter.seen.length, 1);
    });
  });
}

/// Runs [action] and returns the [ApiException] it threw.
Future<ApiException> _capture(Future<void> Function() action) async {
  try {
    await action();
  } on DioException catch (error) {
    final wrapped = error.error;
    if (wrapped is ApiException) return wrapped;
    fail('expected an ApiException, got ${error.error}');
  } on ApiException catch (error) {
    return error;
  }
  fail('expected the call to fail');
}
