/// Both shells get an API client, or neither half of the app works.
///
/// This exists because the failure it guards against actually shipped, and was
/// invisible in three separate ways at once.
///
/// Both feature packages declared a provider called `apiProvider`. `main.dart`
/// imported both packages and overrode *the name*, which resolved to whichever
/// import won — the vendor's. Every customer screen then threw
/// `UnimplementedError: apiProvider must be overridden` on its first read.
///
/// Why nothing caught it:
///
///   * The analyzer was happy. One name, one import, no ambiguity to report.
///   * The screen swallowed it. `AsyncView` maps `ApiFailure` values to copy,
///     and an `UnimplementedError` is not an `ApiException` at all, so it fell
///     to the default arm and rendered "Something went wrong · Please try
///     again" — indistinguishable from the server being down.
///   * The router test passed. It asserted on the tab bar, which is shell
///     chrome and renders whether or not the tabs can load anything.
///
/// It took running the app against a live API and printing the error to see.
/// So the check here is not "does a provider exist" but the specific thing that
/// went wrong: **is every provider a screen reads actually overridden by the
/// scope the app builds.**
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_feature_customer/aangan_feature_customer.dart';
import 'package:aangan_feature_vendor/aangan_feature_vendor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late AanganApi api;

  setUp(() => api = apiWith(StubApi(), const NoSession()));

  test('an un-overridden provider throws rather than returning null', () {
    // The precondition for everything below. If the default were a silent
    // fallback, none of these tests could tell overridden from not.
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(() => container.read(customerApiProvider), throwsUnimplementedError);
    expect(() => container.read(vendorApiProvider), throwsUnimplementedError);
  });

  test('the app scope overrides both, not one', () {
    // The exact list `main.dart` builds. Kept here rather than reaching into
    // main() because main() also opens the keychain and the filesystem.
    final container = ProviderContainer(
      overrides: [
        customerApiProvider.overrideWithValue(api),
        vendorApiProvider.overrideWithValue(api),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(customerApiProvider), same(api));
    expect(container.read(vendorApiProvider), same(api));
  });

  test('overriding only one leaves the other half broken', () {
    // Asserting the bug's shape, so the test above is not passing by accident.
    final container = ProviderContainer(
      overrides: [vendorApiProvider.overrideWithValue(api)],
    );
    addTearDown(container.dispose);

    expect(container.read(vendorApiProvider), same(api));
    expect(
      () => container.read(customerApiProvider),
      throwsUnimplementedError,
      reason:
          'This is precisely what shipped, and what the app showed as '
          '"Please try again".',
    );
  });

  test('the two providers are distinct objects', () {
    // If the packages ever converge on one shared provider this test should be
    // deleted deliberately, not silently satisfied.
    expect(identical(customerApiProvider, vendorApiProvider), isFalse);
  });
}
