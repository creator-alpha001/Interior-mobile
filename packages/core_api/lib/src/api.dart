/// The client, assembled.
///
/// One `Dio` with the interceptors in a deliberate order, and the three
/// generated clients that sit on it. There is no fourth: see
/// `tool/fix_generated.dart` for why the staff client is deleted rather than
/// merely left unexported.
library;

import 'package:dio/dio.dart';

import 'generated/clients/client_client.dart';
import 'generated/clients/professional_client.dart';
import 'generated/clients/public_client.dart';
import 'interceptors.dart';
import 'session.dart';

/// Where this build points, and how patiently it waits.
class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 10),
    // Generous, because a vendor uploading stage proof from a basement is the
    // reality this app is built for. The upload itself does not go through
    // here — photographs PUT straight at storage — but the ticket request that
    // precedes it is on the same connection.
    this.receiveTimeout = const Duration(seconds: 30),
  });

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
}

/// Everything the app talks to.
class AanganApi {
  AanganApi._(this.dio, this.public, this.customer, this.vendor);

  /// Exposed so `core_upload` can PUT bytes at storage on the same client, and
  /// so tests can install an adapter. Screens should not reach for it.
  final Dio dio;

  final PublicClient public;
  final ClientClient customer;
  final ProfessionalClient vendor;

  /// There is deliberately no `staff` client.
  ///
  /// MOBILE.md §1: admin stays on the web, with no mobile surface now or
  /// planned. The ops endpoints exist in `openapi.json` because it documents
  /// the whole API, but the generated staff client is deleted from this package
  /// during generation — so a screen cannot call `/ops/*` even by mistake, and
  /// commission figures and customer phone numbers have no route into this
  /// binary at all.
  static const staff = null;

  factory AanganApi(ApiConfig config, {SessionStore session = const NoSession()}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        // The API answers JSON for everything, including errors, and dio must
        // not throw before ErrorInterceptor has turned the body into an
        // ApiException.
        responseType: ResponseType.json,
        validateStatus: (status) => status != null && status < 400,
      ),
    );

    // Order matters, and this is not the order they run in for errors.
    //
    // On the way *out*: auth attaches the token, then the request id is added.
    // On the way *back*: dio walks error interceptors in registration order, so
    // ErrorInterceptor must come before RetryInterceptor — the retry logic
    // decides using a typed ApiException, which is what ErrorInterceptor
    // produces. Registered the other way round, retry sees a raw DioException,
    // never matches, and silently does nothing.
    dio.interceptors.addAll([
      AuthInterceptor(session),
      RequestIdInterceptor(),
      ErrorInterceptor(session),
      RetryInterceptor(dio),
    ]);

    return AanganApi._(
      dio,
      PublicClient(dio),
      ClientClient(dio),
      ProfessionalClient(dio),
    );
  }

  /// For tests: build against a dio that already has an adapter installed.
  factory AanganApi.withDio(Dio dio, {SessionStore session = const NoSession()}) {
    dio.interceptors.addAll([
      AuthInterceptor(session),
      RequestIdInterceptor(),
      ErrorInterceptor(session),
      RetryInterceptor(dio),
    ]);
    return AanganApi._(
      dio,
      PublicClient(dio),
      ClientClient(dio),
      ProfessionalClient(dio),
    );
  }
}
