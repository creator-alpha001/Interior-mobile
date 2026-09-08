/// The professionals directory, and why its filters are not decoration.
///
/// The web's `/professionals` carries `domain` and `city` in the query string
/// and asks for verified professionals only. Mobile listed everybody, unsorted
/// and unfiltered, which looked like the same screen and was not:
///
///   * **`domain` is what populates `domainRating`.** Without it the API can
///     only return an average across every trade, so a card under "Carpentry"
///     would show a number earned mostly by painting. The platform's whole
///     claim is that approval and rating are per trade.
///   * **`verifiedOnly`** matches the pool a customer is actually choosing
///     from. An unverified professional is in no pool.
///
/// These assert the query that leaves the phone, not the widget tree, because
/// a query parameter that silently stops being sent looks identical on screen.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_feature_customer/aangan_feature_customer.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers every request with an empty page and keeps the query it was asked.
class _Recorder extends Interceptor {
  final queries = <Map<String, dynamic>>[];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    queries.add(Map<String, dynamic>.from(options.queryParameters));
    handler.resolve(
      Response<Map<String, dynamic>>(
        requestOptions: options,
        statusCode: 200,
        data: const {'items': <dynamic>[], 'nextCursor': null, 'total': 0},
      ),
    );
  }
}

({ProviderContainer container, _Recorder recorder}) _harness() {
  final recorder = _Recorder();
  final dio = Dio(BaseOptions(baseUrl: 'https://test'))
    ..interceptors.add(recorder);

  final container = ProviderContainer(
    overrides: [customerApiProvider.overrideWithValue(AanganApi.withDio(dio))],
  );
  addTearDown(container.dispose);

  return (container: container, recorder: recorder);
}

void main() {
  test('asks for verified professionals, as the web does', () async {
    final h = _harness();

    await h.container.read(professionalsProvider.future);

    expect(h.recorder.queries.single['verifiedOnly'], true);
  });

  test('sends neither filter until one is set', () async {
    final h = _harness();

    await h.container.read(professionalsProvider.future);

    final query = h.recorder.queries.single;
    expect(query.containsKey('domain'), isFalse);
    expect(query.containsKey('city'), isFalse);
  });

  test('sends the trade, which is what returns a per-trade rating', () async {
    final h = _harness();
    await h.container.read(professionalsProvider.future);

    h.container.read(professionalFiltersProvider.notifier).state =
        const ProfessionalFilters(domainSlug: 'carpentry');
    await h.container.read(professionalsProvider.future);

    expect(h.recorder.queries.last['domain'], 'carpentry');
  });

  test('sends both when both are set', () async {
    final h = _harness();
    await h.container.read(professionalsProvider.future);

    h.container.read(professionalFiltersProvider.notifier).state =
        const ProfessionalFilters(domainSlug: 'painting', cityId: 'city-1');
    await h.container.read(professionalsProvider.future);

    final query = h.recorder.queries.last;
    expect(query['domain'], 'painting');
    expect(query['city'], 'city-1');
  });

  test(
    'clearing a filter stops sending it, rather than sending null',
    () async {
      // A cleared filter that arrives as `domain=null` is not the same request
      // as one that omits it, and the difference is invisible on screen.
      final h = _harness();

      h.container.read(professionalFiltersProvider.notifier).state =
          const ProfessionalFilters(domainSlug: 'carpentry');
      await h.container.read(professionalsProvider.future);

      h.container.read(professionalFiltersProvider.notifier).state =
          const ProfessionalFilters();
      await h.container.read(professionalsProvider.future);

      expect(h.recorder.queries.last.containsKey('domain'), isFalse);
    },
  );

  test('an unchanged filter object does not refetch', () async {
    // Value equality on ProfessionalFilters is what stops a rebuild turning
    // into a request. Without it, every keystroke elsewhere on the tab costs
    // a round trip.
    final h = _harness();
    await h.container.read(professionalsProvider.future);

    h.container.read(professionalFiltersProvider.notifier).state =
        const ProfessionalFilters();
    await h.container.read(professionalsProvider.future);

    expect(h.recorder.queries, hasLength(1));
  });
}
