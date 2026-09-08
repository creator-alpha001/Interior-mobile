/// One readable local time, in the reader's language.
///
/// The visits screen carried a twelve-entry `const months` list of English
/// abbreviations. Hand-translating those into Devanagari would be inventing
/// data the platform already ships — `intl` knows what September is called in
/// Hindi, and it knows it for every other locale this app might add.
///
/// Kept here rather than in the vendor package because a customer's visit is
/// the same moment as the vendor's, and two formatters drift.
library;

import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Loads the date symbols. Await once, before `runApp`.
///
/// Without it `DateFormat` throws for any locale but the process default, so
/// the call is not optional — but [formatWhen] survives its absence rather
/// than taking a screen down over a timestamp.
Future<void> loadDateFormats() => initializeDateFormatting();

/// `8 Sep, 3:30 pm`, in the current locale.
///
/// Day before month, which is what this audience reads, and no year: every
/// visit this screen shows is within a few weeks either way, and a year on
/// each row is noise that pushes the time off the edge.
String formatWhen(BuildContext context, String isoTimestamp) {
  final parsed = DateTime.tryParse(isoTimestamp)?.toLocal();

  /// The API's own string, unchanged, rather than an empty cell or a throw.
  /// A timestamp we cannot parse is still information.
  if (parsed == null) return isoTimestamp;

  final locale = Localizations.localeOf(context).toLanguageTag();
  try {
    return DateFormat('d MMM, h:mm a', locale).format(parsed);
  } on Exception {
    // Symbols not loaded, or a locale intl does not carry. English is a worse
    // answer than Hindi and a much better one than a red screen.
    return DateFormat('d MMM, h:mm a').format(parsed);
  }
}
