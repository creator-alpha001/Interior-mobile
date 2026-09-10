/// Where a customer is, in one line.
///
/// Exists because the city can be absent. Signing up no longer requires one —
/// somebody may have come in through Google and not yet said where they are —
/// and three screens each built `'$locality, ${city.name}'` on the assumption
/// that it could not be. One of those would have printed
/// "Gomti Nagar, null" on a lead card.
///
/// Where a lead or a visit is in context the city is the *job's* and is always
/// present, so this reads exactly as it did before. It is the screens with no
/// job in context, which fall back to the account, where the missing half has
/// to be dropped rather than shown.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart';

String whereClientIs(MaskedClientSummary client, {String separator = ', '}) {
  final city = client.city?.name;
  if (city == null || city.isEmpty) return client.locality;
  if (client.locality.isEmpty) return city;
  return '${client.locality}$separator$city';
}
