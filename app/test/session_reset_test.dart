/// One person's data must not survive into the next person's session.
///
/// A `FutureProvider` holds its resolved value for the life of its container,
/// and the container lives as long as the process. Signing out cleared the
/// token and the HTTP cache and left the providers alone — so signing in as
/// somebody else on the same handset showed the previous person's jobs, by
/// reference number.
///
/// Found on a device, not by a test: a customer with no requirements at all was
/// shown two of another customer's, complete with their trades and references.
/// On a shared phone that is a privacy failure, not a staleness one.
///
/// **The scan is the point.** `resetCustomerSession` and `resetVendorSession`
/// invalidate a list, and a list is a thing somebody forgets to extend. This
/// reads both `providers.dart` files, finds every provider built on the
/// per-session client, and fails when one is missing from the list — so the
/// next provider is caught by a test rather than by a customer.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `final fooProvider = ...` up to the next top-level `final`.
final _declaration = RegExp(
  r'^final (\w+Provider) =(.*?)(?=^final |\Z)',
  multiLine: true,
  dotAll: true,
);

/// The list the reset walks.
final _list = RegExp(
  r'(\w+SessionProviders) = <ProviderOrFamily>\[(.*?)\];',
  dotAll: true,
);

/// Providers whose value is the same for everybody, so they may outlive a
/// session: the trades, the cities, the catalogue, the marketing strip. Public
/// reads, in other words — they are keyed by nothing the session decides.
///
/// A provider is per-session when it is built on the authenticated client, and
/// the code says which that is: `_me(ref)` on the customer side, `_vendor(ref)`
/// on the vendor's.
const _sessionClients = <String>['_me(ref)', '_vendor(ref)'];

({Set<String> perSession, Set<String> listed}) _scan(String path) {
  final source = File(path).readAsStringSync();

  final perSession = <String>{};
  for (final match in _declaration.allMatches(source)) {
    final name = match.group(1)!;
    final body = match.group(2)!;
    if (_sessionClients.any(body.contains)) perSession.add(name);
  }

  final listMatch = _list.firstMatch(source);
  final listed = <String>{
    if (listMatch != null)
      for (final line in listMatch.group(2)!.split(','))
        if (line.trim().isNotEmpty) line.trim(),
  };

  return (perSession: perSession, listed: listed);
}

void main() {
  const customer = '../packages/feature_customer/lib/src/providers.dart';
  const vendor = '../packages/feature_vendor/lib/src/providers.dart';

  test('the scan finds the files, not an empty string', () {
    // Guards against every check below passing because a path moved.
    expect(File(customer).existsSync(), isTrue);
    expect(File(vendor).existsSync(), isTrue);
    expect(_scan(customer).perSession, isNotEmpty);
    expect(_scan(vendor).perSession, isNotEmpty);
  });

  test('every per-session customer provider is reset', () {
    final scanned = _scan(customer);
    final missed = scanned.perSession.difference(scanned.listed).toList()
      ..sort();

    expect(
      missed,
      isEmpty,
      reason:
          'These read the signed-in customer’s own data but are not in '
          'customerSessionProviders, so they would survive into the next '
          'person’s session on this handset:\n  ${missed.join("\n  ")}',
    );
  });

  test('every per-session vendor provider is reset', () {
    final scanned = _scan(vendor);
    final missed = scanned.perSession.difference(scanned.listed).toList()
      ..sort();

    expect(
      missed,
      isEmpty,
      reason:
          'These read the signed-in professional’s own data but are not '
          'in vendorSessionProviders. A vendor’s leads carry masked '
          'client summaries and their invoices are their pipeline:\n  '
          '${missed.join("\n  ")}',
    );
  });

  test('the lists carry nothing that is not per-session', () {
    // The other direction, and it matters less but is still worth holding:
    // invalidating the trades list on every sign-in costs a request nobody
    // needed, and it hides the fact that somebody misunderstood the rule.
    for (final path in [customer, vendor]) {
      final scanned = _scan(path);
      expect(
        scanned.listed.difference(scanned.perSession),
        isEmpty,
        reason: 'Listed in $path but not built on the authenticated client.',
      );
    }
  });
}
