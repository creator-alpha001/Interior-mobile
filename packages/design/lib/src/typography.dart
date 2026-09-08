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

  /// Neither family carries Devanagari, and the app ships Hindi.
  ///
  /// Without these, every Hindi string falls through to whatever the platform
  /// happens to have — Noto on Android, Nirmala UI on Windows, Devanagari
  /// Sangam MN on iOS — which means the app looks like a different piece of
  /// software in Hindi than it does in English. Naming the fallback pins it to
  /// one pair chosen to sit with Newsreader and Manrope.
  ///
  /// **A name here is a request, not a guarantee.** Flutter looks for a
  /// bundled family first and silently continues down the list, so listing a
  /// family that is not in `pubspec.yaml` costs nothing and breaks nothing —
  /// it just does not take effect yet. The `.ttf` files are still outstanding;
  /// RELEASE.md tracks them alongside Newsreader and Manrope themselves, which
  /// are equally unbundled today.
  ///
  /// Devanagari also sits taller than Latin: the शिरोरेखा and the vowel marks
  /// above it want more line height than the same size in English. The scale
  /// below is generous enough at body sizes, but the display and headline
  /// roles need an optical check once the files land, rather than a check that
  /// the glyphs merely appear.
  static const List<String> serifFallback = <String>['Noto Serif Devanagari'];

  static const List<String> sansFallback = <String>['Noto Sans Devanagari'];

  /// Kept for callers that want "whatever renders Devanagari", regardless of
  /// which half of the pairing they are in.
  static const List<String> devanagariFallback = <String>[
    ...serifFallback,
    ...sansFallback,
  ];
}

/// The Material text theme, in the platform's own role names.
///
/// Mapped so a stock Material widget picks the right family without being told:
/// `headlineSmall` on a card title is Newsreader because that is what a card
/// title is, not because the widget was overridden at the call site.
/// **Sized against the web, which is where these roles came from.**
///
/// The first version took MOBILE.md §3.4's table literally and shipped a
/// 38/30/28/22 heading ramp. On a 360dp screen that is enormous: "Compare
/// quotes" filled a third of the viewport before a single quote appeared, and
/// a card title was 22 where the same card on the web is **15**. The whole
/// ramp ran about 1.4x the web's for identical roles, which is backwards — a
/// phone is held closer than a monitor, so headings can be *smaller* relative
/// to body text, not larger.
///
/// Body sizes are left alone. 14 is the readable default at arm's length and
/// dropping it to the web's 13.5 buys nothing; the problem was never the
/// prose. Everything changed below is a heading or a figure.
const aanganTextTheme = TextTheme(
  // ---- Newsreader. One display line per screen, at most. ----
  displayLarge: TextStyle(
    fontFamily: AanganFonts.serif,
    fontFamilyFallback: AanganFonts.serifFallback,
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w400,
  ),
  headlineLarge: TextStyle(
    fontFamily: AanganFonts.serif,
    fontFamilyFallback: AanganFonts.serifFallback,
    fontSize: 23,
    height: 30 / 23,
    fontWeight: FontWeight.w400,
  ),
  headlineMedium: TextStyle(
    fontFamily: AanganFonts.serif,
    fontFamilyFallback: AanganFonts.serifFallback,
    fontSize: 20,
    height: 27 / 20,
    fontWeight: FontWeight.w500,
  ),
  headlineSmall: TextStyle(
    fontFamily: AanganFonts.serif,
    fontFamilyFallback: AanganFonts.serifFallback,
    fontSize: 17,
    height: 23 / 17,
    fontWeight: FontWeight.w500,
  ),

  // ---- Manrope. Everything else. ----
  titleLarge: TextStyle(
    fontFamily: AanganFonts.sans,
    fontFamilyFallback: AanganFonts.sansFallback,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
  ),
  titleMedium: TextStyle(
    fontFamily: AanganFonts.sans,
    fontFamilyFallback: AanganFonts.sansFallback,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
  ),
  bodyLarge: TextStyle(
    fontFamily: AanganFonts.sans,
    fontFamilyFallback: AanganFonts.sansFallback,
    fontSize: 16,
    height: 26 / 16,
    fontWeight: FontWeight.w400,
  ),
  bodyMedium: TextStyle(
    fontFamily: AanganFonts.sans,
    fontFamilyFallback: AanganFonts.sansFallback,
    fontSize: 14,
    height: 22 / 14,
    fontWeight: FontWeight.w400,
  ),
  bodySmall: TextStyle(
    fontFamily: AanganFonts.sans,
    fontFamilyFallback: AanganFonts.sansFallback,
    fontSize: 12,
    height: 18 / 12,
    fontWeight: FontWeight.w400,
  ),
  labelMedium: TextStyle(
    fontFamily: AanganFonts.sans,
    fontFamilyFallback: AanganFonts.sansFallback,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.48, // +0.04em
  ),
  labelSmall: TextStyle(
    fontFamily: AanganFonts.sans,
    fontFamilyFallback: AanganFonts.sansFallback,
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
    fontFamilyFallback: AanganFonts.sansFallback,
    fontSize: 20,
    height: 26 / 20,
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
    fontFamilyFallback: AanganFonts.sansFallback,
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );
}

/// Applies the ink colour to every role in one place.
TextTheme tintedTextTheme(TextTheme base) =>
    base.apply(bodyColor: AanganColors.ink, displayColor: AanganColors.ink);
