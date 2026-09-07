/// Money, formatted once.
///
/// Whole rupees, Indian grouping, no paise anywhere on the platform. A screen
/// that formats its own currency is how `₹450,000` gets shipped instead of
/// `₹4,50,000`, so this is the only formatter and every figure goes through it.
library;

import 'package:intl/intl.dart';

/// Amounts are integers. Never a `double`.
///
/// Money in a floating-point type is how ₹1 goes missing, and the server treats
/// `Rupees` as an `int` for exactly that reason.
extension type const Rupees(int paisaFree) implements int {
  /// `₹4,50,000` — the `en_IN` locale groups by lakh and crore, not by thousand.
  String get formatted => _rupees.format(paisaFree);

  /// `₹4.5L`, for a card where the full figure would wrap.
  ///
  /// Deliberately separate from [formatted]: an abbreviated figure is a display
  /// choice for a constrained space, never the default, and never right on a
  /// quote or an invoice where the person needs the actual number.
  String get short {
    if (paisaFree >= 10000000) return '₹${_trim(paisaFree / 10000000)}Cr';
    if (paisaFree >= 100000) return '₹${_trim(paisaFree / 100000)}L';
    if (paisaFree >= 1000) return '₹${_trim(paisaFree / 1000)}K';
    return formatted;
  }

  static String _trim(double value) {
    final fixed = value.toStringAsFixed(1);
    return fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
  }
}

final _rupees = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);
