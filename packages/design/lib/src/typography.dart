/// The type scale.
///
/// One family, Inter, on the phone and the website alike. Headings used to be
/// an editorial serif (Newsreader) over a separate sans (Manrope); neither was
/// ever bundled, so the app actually rendered in whatever the platform had, and
/// the website has since moved to Inter throughout. Headings are told apart by
/// weight now, not by a second typeface.
///
/// These are DESIGN.md's `-mobile` sizes, not the desktop ones. `display-lg` at
/// 56px is a 1440px figure and will not fit a 360dp screen.
library;

import 'package:flutter/material.dart';

import 'tokens.dart';

abstract final class InterioBeeFonts {
  /// Bundled in this package's `pubspec.yaml`, so a text style names the
  /// package as well as the family — otherwise Flutter looks for an app-level
  /// font of that name and silently falls back to the platform's.
  static const family = 'Inter';
  static const package = 'interiobee_design';

  /// Inter carries no Devanagari, and the app ships Hindi.
  ///
  /// Without a named fallback every Hindi string falls through to whatever the
  /// platform happens to have — Noto on Android, Nirmala UI on Windows,
  /// Devanagari Sangam MN on iOS. **A name here is a request, not a
  /// guarantee**: the `.ttf` is not bundled yet (RELEASE.md), and Flutter
  /// silently continues down the list when a family is missing.
  static const List<String> fallback = <String>['Noto Sans Devanagari'];
}

/// Inter at a given size, line height and weight, with the Hindi fallback.
///
/// `package` is set on every style rather than once on the theme, because a
/// style copied out of this theme into a widget that is not under it would
/// otherwise lose the family.
const _inter = TextStyle(
  fontFamily: InterioBeeFonts.family,
  package: InterioBeeFonts.package,
  fontFamilyFallback: InterioBeeFonts.fallback,
);

/// The Material text theme, in the platform's own role names.
///
/// **Sized against the web, which is where these roles came from.** The first
/// version took MOBILE.md §3.4's table literally and shipped a 38/30/28/22
/// heading ramp; on a 360dp screen "Compare quotes" filled a third of the
/// viewport before a single quote appeared. A phone is held closer than a
/// monitor, so headings can be *smaller* relative to body text, not larger.
///
/// Body sizes are left alone. 14 is the readable default at arm's length.
final interiobeeTextTheme = TextTheme(
  // ---- Headings: semibold, tightened a little, as the website sets them. ----
  displayLarge: _inter.copyWith(
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.6,
  ),
  headlineLarge: _inter.copyWith(
    fontSize: 23,
    height: 29 / 23,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
  ),
  headlineMedium: _inter.copyWith(
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  ),
  headlineSmall: _inter.copyWith(
    fontSize: 17,
    height: 23 / 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  ),

  // ---- Everything else. ----
  titleLarge: _inter.copyWith(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
  ),
  titleMedium: _inter.copyWith(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
  ),
  bodyLarge: _inter.copyWith(
    fontSize: 16,
    height: 26 / 16,
    fontWeight: FontWeight.w400,
  ),
  bodyMedium: _inter.copyWith(
    fontSize: 14,
    height: 22 / 14,
    fontWeight: FontWeight.w400,
  ),
  bodySmall: _inter.copyWith(
    fontSize: 12,
    height: 18 / 12,
    fontWeight: FontWeight.w400,
  ),
  labelMedium: _inter.copyWith(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.48, // +0.04em
  ),
  labelSmall: _inter.copyWith(
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6, // +0.06em
  ),
);

/// Styles Material has no role for.
///
/// These hang off [InterioBeePalette] rather than the text theme, because inventing
/// a Material role would mean some stock widget eventually picks it up by
/// accident.
abstract final class InterioBeeTextStyles {
  /// Every rupee figure on the platform.
  ///
  /// The tabular figures are not a refinement: without them a column of quotes
  /// does not align, and the quote-comparison screen is three prices in a
  /// column. Any screen that formats its own currency is how `₹450,000` ships
  /// instead of `₹4,50,000` — see `Rupees.format`.
  static final financialNum = _inter.copyWith(
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.48,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// The uppercase eyebrow on a status pill.
  ///
  /// Uppercasing is done here, in the style's usage, rather than by
  /// transforming the string — a screen reader should still hear the word.
  static final eyebrow = _inter.copyWith(
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );
}

/// Applies the ink colour to every role in one place.
TextTheme tintedTextTheme(TextTheme base) => base.apply(
  bodyColor: InterioBeeColors.ink,
  displayColor: InterioBeeColors.ink,
);
