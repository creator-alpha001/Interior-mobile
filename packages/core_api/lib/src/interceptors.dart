/// The interceptors.
///
/// MOBILE.md §4.2 picks dio for one reason: "interceptors are where session,
/// request id, retry and 401 handling live once". This file is that. Every
/// policy below is a decision recorded in MOBILE.md §7.5, and none of it should
/// be re-implemented at a call site.
library;

import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'session.dart';

/// Marks the caller as a mobile client.
///
/// `POST /auth/otp/verify` returns the session token in the body when it sees
/// this, instead of only setting a cookie. Same session row, same immediate
/// revocation — deliberately not a JWT.
const kClientHeader = 'x-client';
const kClientValue = 'mobile';

const kRequestIdHeader = 'x-request-id';
const kIdempotencyHeader = 'idempotency-key';

/// Attaches the bearer token, and the headers the API expects from a phone.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._session);

  final SessionStore _session;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers[kClientHeader] = kClientValue;

    final token = await _session.read();
    if (token != null) options.headers['authorization'] = 'Bearer $token';

    handler.next(options);
  }
}

/// Generates a request id, unless the caller set one.
///
/// The API accepts an inbound id if it looks like one and echoes it on the
/// response, so a screenshot and a server log become the same story. Generating
/// it here rather than server-side means the app can show the id even when the
/// request never arrived.
class RequestIdInterceptor extends Interceptor {
  RequestIdInterceptor([Random? random]) : _random = random ?? Random();

  final Random _random;

  static const _alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';

  String _id() => List.generate(
    20,
    (_) => _alphabet[_random.nextInt(_alphabet.length)],
  ).join();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent(kRequestIdHeader, _id);
    handler.next(options);
  }
}

/// Turns every `DioException` into an [ApiException], and handles 401 once.
///
/// The 401 path is the one worth reading. A 401 mid-session means the session
/// was revoked — suspended, or signed out on another device. The response is to
/// clear the session and route to sign-in **with a reason**, and specifically
/// *not* to retry: nothing about trying again makes a revoked session valid,
/// and a silent retry loop on a suspended vendor is how you get a blank screen
/// nobody can explain.
class ErrorInterceptor extends Interceptor {
  ErrorInterceptor(this._session);

  final SessionStore _session;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final failure = ApiException.from(err);

    if (failure.failure == ApiFailure.notAuthenticated) {
      await _session.onRevoked();
    }

    // `next`, not `reject`.
    //
    // `reject` ends the interceptor chain there, so RetryInterceptor — which is
    // registered after this one and decides using the typed ApiException this
    // produces — never ran at all. Retries silently did nothing, which the two
    // retry tests caught. `next` hands the enriched error along; if nothing
    // else handles it, dio throws it just the same.
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: failure,
        message: failure.message,
      ),
    );
  }
}

/// Retries idempotent reads, and nothing else.
///
/// MOBILE.md §7.5: *retry idempotent GETs twice with backoff; never retry a
/// POST automatically.* The asymmetry is deliberate and it is not fussiness —
/// a retried `POST /me/agreements/:id/sign` is a second set of projects and a
/// second commission invoice. When a write times out the answer is to re-read
/// the record and find out whether it landed, which is a screen's job, not an
/// interceptor's.
///
/// A request may opt in explicitly by carrying an [kIdempotencyHeader], which
/// is what the signing screen does.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(
    this._dio, {
    this.maxAttempts = 2,
    this.baseDelay = const Duration(milliseconds: 300),
  });

  final Dio _dio;
  final int maxAttempts;
  final Duration baseDelay;

  static const _attemptKey = 'aangan.retryAttempt';

  bool _mayRetry(RequestOptions options, ApiException failure) {
    if (!failure.isTransient) return false;
    // A 429 is the server asking for less traffic. Retrying immediately is the
    // opposite of what it asked for; the screen shows the retry time instead.
    if (failure.failure == ApiFailure.rateLimited) return false;

    final method = options.method.toUpperCase();
    final idempotent = method == 'GET' || method == 'HEAD';
    final optedIn = options.headers.containsKey(kIdempotencyHeader);
    return idempotent || optedIn;
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final failure = err.error;
    if (failure is! ApiException) return handler.next(err);

    final options = err.requestOptions;
    final attempt = (options.extra[_attemptKey] as int?) ?? 0;

    if (attempt >= maxAttempts || !_mayRetry(options, failure)) {
      return handler.next(err);
    }

    // Exponential, so a server that is briefly overloaded is not hammered by
    // every phone at once.
    await Future<void>.delayed(baseDelay * pow(2, attempt).toInt());

    options.extra[_attemptKey] = attempt + 1;

    try {
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
