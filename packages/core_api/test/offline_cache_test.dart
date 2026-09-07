/// What the read cache will and will not serve.
///
/// The interesting assertions are the refusals. A cache that is too eager is
/// worse than no cache: it shows somebody a quote that has since been revised,
/// or an agreement they have already signed, and gives them no way to tell.
library;

import 'dart:convert';
import 'dart:io';

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

/// Answers once from the network, then fails as if offline.
class _FlakyAdapter implements HttpClientAdapter {
  _FlakyAdapter(this.body);

  final Object body;
  bool offline = false;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    if (offline) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'no route to host',
      );
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('aangan-cache-test'));
  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  Dio buildDio(_FlakyAdapter adapter) {
    return Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(OfflineCacheInterceptor(dir));
  }

  group('what may be cached', () {
    test('the catalogue and the vendor dashboard, per MOBILE.md 7.4', () {
      for (final path in const [
        '/domains',
        '/cities',
        '/products',
        '/packages',
        '/professionals',
        '/vendor/dashboard',
      ]) {
        expect(isCacheable(path), isTrue, reason: path);
      }
    });

    test('never anything the person is about to act on', () {
      // A cached list is a photograph of the past. Fine for a catalogue;
      // actively harmful for a quote about to be chosen or an agreement about
      // to be signed.
      for (final path in const [
        '/me/requirements',
        '/me/agreements',
        '/me/projects',
        '/me/notifications',
        '/vendor/leads',
        '/vendor/invoices',
        '/vendor/visits',
        '/me/services/ld-1/messages',
      ]) {
        expect(isCacheable(path), isFalse, reason: path);
      }
    });

    test('never the session', () {
      expect(isCacheable('/me'), isFalse);
      expect(isCacheable('/auth/otp/verify'), isFalse);
    });
  });

  group('serving stale data', () {
    test('a cold read with no signal returns the last good body', () async {
      final adapter = _FlakyAdapter([
        {'id': 'd1', 'name': 'Furniture Work'},
      ]);
      final dio = buildDio(adapter);

      final live = await dio.get<dynamic>('/domains');
      expect(live.statusCode, 200);
      expect(live.servedFromCacheAt, isNull, reason: 'came from the network');

      adapter.offline = true;
      final stale = await dio.get<dynamic>('/domains');

      expect(stale.statusCode, 200);
      expect(stale.data, live.data);
      // The stamp is how a screen knows to draw "as of". Without it the person
      // cannot tell a stale list from a live one, which is worse than the
      // spinner it replaced.
      expect(stale.servedFromCacheAt, isA<DateTime>());
    });

    test('a path that is not cacheable still fails offline', () async {
      final adapter = _FlakyAdapter(<Object>[]);
      final dio = buildDio(adapter);

      await dio.get<dynamic>('/me/agreements');
      adapter.offline = true;

      // The right answer is an error the screen can render honestly.
      expect(
        () => dio.get<dynamic>('/me/agreements'),
        throwsA(isA<DioException>()),
      );
    });

    test('a 404 is not replaced by yesterday’s body', () async {
      // The server's considered answer. Serving a cached list over it would be
      // a lie, and the person would act on a record that no longer exists.
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = _StatusAdapter(404)
        ..interceptors.add(OfflineCacheInterceptor(dir));

      expect(() => dio.get<dynamic>('/domains'), throwsA(isA<DioException>()));
    });

    test('nothing is served when nothing was ever cached', () async {
      final adapter = _FlakyAdapter(<Object>[])..offline = true;
      final dio = buildDio(adapter);

      expect(() => dio.get<dynamic>('/domains'), throwsA(isA<DioException>()));
    });
  });

  group('signing out', () {
    test('drops everything, because a dashboard is one person’s pipeline',
        () async {
      final adapter = _FlakyAdapter([
        {'id': 'd1'},
      ]);
      final cache = OfflineCacheInterceptor(dir);
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = adapter
        ..interceptors.add(cache);

      await dio.get<dynamic>('/vendor/dashboard');
      expect(dir.listSync().whereType<File>(), isNotEmpty);

      cache.clear();

      // The next person to sign in on this handset must not see the last one's
      // figures.
      expect(dir.listSync().whereType<File>(), isEmpty);

      adapter.offline = true;
      expect(
        () => dio.get<dynamic>('/vendor/dashboard'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('writes are never queued', () {
    test('a POST offline fails rather than being replayed later', () async {
      // MOBILE.md §7.4: a quote submitted from a basement two hours ago and
      // delivered now is worse than one that failed loudly at the time.
      // Versioning, ordering and the one-live-quote constraint are serialised
      // server-side and cannot absorb a time traveller.
      final adapter = _FlakyAdapter(<Object>[])..offline = true;
      final dio = buildDio(adapter);

      expect(
        () => dio.post<dynamic>('/vendor/leads/ld-1/quotes', data: {}),
        throwsA(isA<DioException>()),
      );
    });
  });
}

class _StatusAdapter implements HttpClientAdapter {
  _StatusAdapter(this.status);

  final int status;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode({'code': 'not_found', 'message': 'no'}),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
