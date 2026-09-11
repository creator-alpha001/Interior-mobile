/// The professionals directory, and why its filters are not decoration.
///
/// The web's `/professionals` carries trade, city, verification, a rating
/// floor, an experience floor and the sort in its query string. Mobile once
/// listed everybody, unsorted and unfiltered, which looked like the same screen
/// and was not:
///
///   * **`domain` is what populates `domainRating`.** Without it the API can
///     only return an average across every trade, so a card under "Carpentry"
///     would show a number earned mostly by painting. The platform's whole
///     claim is that approval and rating are per trade.
///   * **`verifiedOnly`** is the customer's choice, never the default. Every
///     listed professional is approved; the badge says which are verified.
///
/// These assert the query that leaves the phone, not the widget tree, because
/// a query parameter that silently stops being sent looks identical on screen.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_feature_customer/interiobee_feature_customer.dart';
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
    overrides: [
      customerApiProvider.overrideWithValue(InterioBeeApi.withDio(dio)),
    ],
  );
  addTearDown(container.dispose);

  return (container: container, recorder: recorder);
}

void main() {
  test(
    'lists every approved professional unless asked for verified only',
    () async {
      final h = _harness();

      await h.container.read(professionalsProvider.future);
      expect(h.recorder.queries.single.containsKey('verifiedOnly'), isFalse);

      h.container.read(professionalFiltersProvider.notifier).state =
          const ProfessionalFilters(verifiedOnly: true);
      await h.container.read(professionalsProvider.future);

      expect(h.recorder.queries.last['verifiedOnly'], true);
    },
  );

  test('sends the rating floor, the experience floor and the sort', () async {
    final h = _harness();

    h.container
        .read(professionalFiltersProvider.notifier)
        .state = const ProfessionalFilters(
      minRating: 4.5,
      minExperience: 10,
      sort: Sort2.experience,
    );
    await h.container.read(professionalsProvider.future);

    final query = h.recorder.queries.last;
    expect(query['minRating'], 4.5);
    expect(query['minExperience'], 10);
    expect('${query['sort']}', 'experience');
  });

  test('the Filter button counts what is in the sheet, not trade or sort', () {
    expect(const ProfessionalFilters().activeCount, 0);
    expect(
      const ProfessionalFilters(
        domainSlug: 'painting',
        sort: Sort2.projects,
      ).activeCount,
      0,
    );
    expect(
      const ProfessionalFilters(
        cityId: 'city-1',
        verifiedOnly: true,
        minRating: 4,
      ).activeCount,
      3,
    );
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
