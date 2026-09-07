/// The type scale.
///
/// Two families with no overlap in job: Newsreader is the editorial serif and
/// carries display and headings only; Manrope carries everything else,
/// including every numeral.
///
/// These are DESIGN.md's `-mobile` sizes, not the desktop ones. `display-lg` at
/// 56px is a 1440px figure and will not fit a 360dp screen.
library;

import 'package:flutter/material.dart';

import 'tokens.dart';

abstract final class AanganFonts {
  /// Bundled as assets rather than fetched through `google_fonts`.
  ///
  /// A vendor standing on a site with no signal should not get a fallback-font
  /// first paint.
  static const serif = 'Newsreader';
  static const sans = 'Manrope';

  /// Neither family carries Devanagari.
  ///
  /// Left empty deliberately, and visibly. If Hindi is ever a target — and for
  /// home services in India it will be — headings fall back silently to the
  /// platform serif and the editorial character of the design is gone in that
  /// locale. Pairing Noto Serif/Sans Devanagari here is the fix, and it needs
  /// an optical check at heading sizes rather than just a working glyph.
  static const List<String> devanagariFallback = <String>[];
}

/// The Material text theme, in the platform's own role names.
///
/// Mapped so a stock Material widget picks the right family without being told:
/// `headlineSmall` on a card title is Newsreader because that is what a card
/// title is, not because the widget was overridden at the call site.
const aanganTextTheme = TextTheme(
  // ---- Newsreader. One display line per screen, at most. ----
  displayLarge: TextStyle(
    fontFamily: AanganFonts.serif,
    fontSize: 38,
    height: 46 / 38,
    fontWeight: FontWeight.w400,
  ),
  headlineLarge: TextStyle(
    fontFamily: AanganFonts.serif,
    fontSize: 30,
    height: 38 / 30,
    fontWeight: FontWeight.w400,
  ),
  headlineMedium: TextStyle(
    fontFamily: AanganFonts.serif,
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w500,
  ),
  headlineSmall: TextStyle(
    fontFamily: AanganFonts.serif,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w500,
  ),

  // ---- Manrope. Everything else. ----
  titleLarge: TextStyle(
    fontFamily: AanganFonts.sans,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
  ),
  titleMedium: TextStyle(
    fontFamily: AanganFonts.sans,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
  ),
  bodyLarge: TextStyle(
    fontFamily: AanganFonts.sans,
    fontSize: 16,
    height: 26 / 16,
    fontWeight: FontWeight.w400,
  ),
  bodyMedium: TextStyle(
    fontFamily: AanganFonts.sans,
    fontSize: 14,
    height: 22 / 14,
    fontWeight: FontWeight.w400,
  ),
  bodySmall: TextStyle(
    fontFamily: AanganFonts.sans,
    fontSize: 12,
    height: 18 / 12,
    fontWeight: FontWeight.w400,
  ),
  labelMedium: TextStyle(
    fontFamily: AanganFonts.sans,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.48, // +0.04em
  ),
  labelSmall: TextStyle(
    fontFamily: AanganFonts.sans,
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6, // +0.06em
  ),
);

/// Styles Material has no role for.
///
/// These hang off [AanganPalette] rather than the text theme, because inventing
/// a Material role would mean some stock widget eventually picks it up by
/// accident.
abstract final class AanganTextStyles {
  /// Every rupee figure on the platform.
  ///
  /// The tabular figures are not a refinement: without them a column of quotes
  /// does not align, and the quote-comparison screen is three prices in a
  /// column. Any screen that formats its own currency is how `₹450,000` ships
  /// instead of `₹4,50,000` — see `Rupees.format`.
  static const financialNum = TextStyle(
    fontFamily: AanganFonts.sans,
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.48,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// The uppercase eyebrow on a status pill.
  ///
  /// Uppercasing is done here, in the style's usage, rather than by
  /// transforming the string — a screen reader should still hear the word.
  static const eyebrow = TextStyle(
    fontFamily: AanganFonts.sans,
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );
}

/// Applies the ink colour to every role in one place.
TextTheme tintedTextTheme(TextTheme base) => base.apply(
      bodyColor: AanganColors.ink,
      displayColor: AanganColors.ink,
    );
