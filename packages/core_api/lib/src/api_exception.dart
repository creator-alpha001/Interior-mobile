/// What a failed request becomes.
///
/// Every error the API can answer with carries the same body —
/// `{ code, message, details? }` — because `app.setErrorHandler` gives all of
/// them that shape. So there is one exception type here rather than one per
/// endpoint, and `code` is the thing to branch on: it is stable and
/// machine-readable, where `message` is written for a person and will change.
library;

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

/// The status codes the API uses deliberately, with what each one means here.
///
/// Named rather than compared as integers, because two of them mean something
/// non-obvious and a bare `404` at a call site invites the wrong handling.
enum ApiFailure {
  /// The request body or query failed validation. `details` lists the fields.
  invalidRequest,

  /// Not signed in, or the session was revoked while the app was open.
  ///
  /// Sessions are rows in Postgres, not JWTs, precisely so that suspending a
  /// vendor logs them out of the screen they are looking at. A 401 mid-session
  /// is therefore normal and means exactly that — it is never a transient
  /// error to retry.
  notAuthenticated,

  /// Signed in, but not permitted. Real for staff-only routes; a customer
  /// should never see one.
  forbidden,

  /// No such record — **which also covers a record belonging to somebody else.**
  ///
  /// Deliberately indistinguishable: a 403 on another customer's requirement
  /// would confirm that requirement exists. Render this as "not found", never
  /// as "you do not have access", because the app genuinely cannot tell.
  notFound,

  /// A constraint refused it. Re-read and show the current state.
  ///
  /// The common one is a stale quote version: the vendor is looking at v2 while
  /// v3 exists. Guessing is worse than re-reading.
  conflict,

  /// Rate limited. [ApiException.retryAfter] carries when to try again.
  rateLimited,

  /// The server broke. Safe to retry only for reads — see [RetryInterceptor].
  serverError,

  /// The request never reached the API: no signal, DNS, TLS, a timeout.
  ///
  /// Distinct from [serverError] because the app can say something useful
  /// about it, and because a write that failed this way may still have landed.
  network,
}

@immutable
class ApiException implements Exception {
  const ApiException({
    required this.failure,
    required this.code,
    required this.message,
    this.details,
    this.statusCode,
    this.requestId,
    this.retryAfter,
  });

  final ApiFailure failure;

  /// Stable and machine-readable. Branch on this, not on [message].
  final String code;

  /// Written for a person. Safe to show, and expected to change.
  final String message;

  final Object? details;
  final int? statusCode;

  /// Echoed by the API on every response.
  ///
  /// The one thing worth putting in front of a user when something breaks: a
  /// support conversation starts with them reading it out, and it is what makes
  /// their screenshot and a server log the same story.
  final String? requestId;

  /// Set on [ApiFailure.rateLimited] when the API said how long to wait.
  final Duration? retryAfter;

  /// True when the same request can safely be sent again as-is.
  ///
  /// Deliberately conservative. It says nothing about whether *this* request
  /// may be retried — that depends on the method, and [RetryInterceptor] owns
  /// that decision.
  bool get isTransient =>
      failure == ApiFailure.network ||
      failure == ApiFailure.serverError ||
      failure == ApiFailure.rateLimited;

  /// Builds the exception from whatever dio surfaced.
  factory ApiException.from(DioException error) {
    final response = error.response;
    final requestId = response?.headers.value('x-request-id');

    if (response == null) {
      return ApiException(
        failure: ApiFailure.network,
        code: 'network_error',
        message:
            'We could not reach Aangan. Check your connection and try again.',
        requestId: requestId,
      );
    }

    final body = response.data;
    final problem = body is Map<String, dynamic>
        ? body
        : const <String, dynamic>{};
    final status = response.statusCode ?? 0;

    return ApiException(
      failure: _failureFor(status),
      // The API always sends a code. The fallback is for a proxy or a gateway
      // answering on its behalf, which does not.
      code: problem['code'] as String? ?? 'http_$status',
      message: problem['message'] as String? ?? _defaultMessage(status),
      details: problem['details'],
      statusCode: status,
      requestId: requestId,
      retryAfter: _retryAfter(response),
    );
  }

  static ApiFailure _failureFor(int status) => switch (status) {
    401 => ApiFailure.notAuthenticated,
    403 => ApiFailure.forbidden,
    404 => ApiFailure.notFound,
    409 => ApiFailure.conflict,
    422 => ApiFailure.invalidRequest,
    429 => ApiFailure.rateLimited,
    _ => status >= 500 ? ApiFailure.serverError : ApiFailure.invalidRequest,
  };

  static String _defaultMessage(int status) => switch (status) {
    401 => 'Please sign in again.',
    403 => 'You do not have access to that.',
    404 => 'We could not find that.',
    409 => 'That has changed since you loaded it. Pull to refresh.',
    429 => 'Too many attempts. Please wait a moment.',
    _ => 'Something went wrong on our side.',
  };

  /// `Retry-After` is seconds in practice here; the header also allows a date.
  static Duration? _retryAfter(Response<dynamic> response) {
    final header = response.headers.value('retry-after');
    if (header == null) return null;
    final seconds = int.tryParse(header);
    return seconds == null ? null : Duration(seconds: seconds);
  }

  @override
  String toString() =>
      'ApiException($code, ${statusCode ?? '-'}): $message'
      '${requestId == null ? '' : ' [$requestId]'}';
}

/// Unwraps dio's exception into the [ApiException] it carries.
///
/// Dio always throws `DioException` from a request, whatever an interceptor
/// puts in its `error` field — so `on ApiException catch` on a bare client call
/// silently never matches, and the failure escapes as an unhandled async error.
/// That is not hypothetical: it is what this codebase did until the router
/// tests hung on it.
///
/// Every call through a generated client goes through here, so the rest of the
/// app only ever handles one exception type.
///
/// ```dart
/// final me = await api.public.me().orThrow();
/// ```
extension ApiCall<T> on Future<T> {
  Future<T> orThrow() async {
    try {
      return await this;
    } on DioException catch (error) {
      final carried = error.error;
      throw carried is ApiException ? carried : ApiException.from(error);
    }
  }
}
