/// The design tokens, and the only place in the application a hex value appears.
///
/// These are the resolutions recorded in `warm_architectural_minimalism/
/// DESIGN.md` §1.3 — the theme shipped two descriptions of itself that did not
/// agree, and every pixel of the five reference renders was counted to settle
/// it. The front matter won almost everywhere; three values came from the prose
/// and one (warm ochre) from neither, because the state it marks does not occur
/// in any of the five screens.
///
/// Nothing outside this file writes a colour literal. Screens read
/// `Theme.of(context).colorScheme` and `InterioBeePalette`, which is what keeps the
/// promise in DESIGN.md §3.8 that dark mode is later a single file rather than
/// a sweep through every widget.
library;

import 'package:flutter/widgets.dart';

/// Raw colour values. Prefer the `ColorScheme` and `InterioBeePalette` over these:
/// they carry the *role*, which is what a screen should be choosing by.
abstract final class InterioBeeColors {
  /// Terracotta. The action colour — "your turn".
  ///
  /// `#944927`, not the prose's `#C06C47`. The lighter value appears in no
  /// render and is 3.9:1 on white, below AA for the small label text these
  /// buttons carry, where this one is 6.4:1.
  static const terracotta = Color(0xFF944927);

  /// The peach "action required" panel. The strongest device in the prototype.
  static const attention = Color(0xFFFFDBCD);
  static const onAttention = Color(0xFF360F00);

  /// Espresso ink. Type is never pure black — "carbonized oak warmth".
  static const ink = Color(0xFF1E1B18);
  static const inkMuted = Color(0xFF4C4640);
  static const onSurface = Color(0xFF1B1C1A);

  /// Deep sage. Verified, signed, or approved *by a person*. Never decoration.
  ///
  /// `#2D6A4F` rather than the `~#007E53` measured in the renders: nothing
  /// draws it at text size, and this is 5.9:1 on limestone where that is 4.8:1.
  static const sage = Color(0xFF2D6A4F);
  static const sageContainer = Color(0xFFEBF3EF);
  static const onSageContainer = Color(0xFF0E5138);

  /// Warm ochre. Waiting on somebody else.
  ///
  /// From the prose. Nothing in the five renders needed it, because the
  /// prototype had no "submitted, awaiting a human" state — which is the single
  /// most important transition in this product.
  static const ochre = Color(0xFFD97706);

  /// Burnt iron. Wrong: overdue, lost, declined, suspended.
  static const burntIron = Color(0xFF991B1B);
  static const errorContainer = Color(0xFFFDF2F2);

  /// Travertine. Neutral metadata — trade tags, material source, spec chips.
  static const travertine = Color(0xFFEAE4DC);

  // ---- The surface ramp, lightest first ----

  /// Pure chalk. Overlays only — never a page background.
  static const chalk = Color(0xFFFFFFFF);

  /// Pale limestone. The ground, and the dominant colour of every screen.
  static const limestone = Color(0xFFFBF9F6);

  /// The card fill, most often.
  static const card = Color(0xFFF5F3F0);

  /// A panel nested inside a card.
  static const panel = Color(0xFFEFEEEB);

  static const chip = Color(0xFFEAE8E5);
  static const chipStrong = Color(0xFFE4E2DF);

  /// Mortar line. Hairline rules, and the only border on a level-1 surface.
  ///
  /// The one place the prose beat the front matter: `#CEC5BD` is barely drawn.
  static const mortar = Color(0xFFE6E0DB);

  /// The overlay border. Level 2 only.
  static const overlayBorder = Color(0xFFD8D1C7);

  /// Non-text only — 3.4:1 on limestone, so it fails AA for anything readable.
  static const outline = Color(0xFF7D766F);

  static const inverseSurface = Color(0xFF30312F);
  static const onInverseSurface = Color(0xFFF2F0ED);
  static const inversePrimary = Color(0xFFCCC5C0);
}

/// The spacing scale. Nothing between these steps.
///
/// The macro rhythm is what makes this read as editorial rather than as a
/// dashboard — 32 to 48 above a section head, a dense 4-to-12 inside a figures
/// block. DESIGN.md notes it is the first thing lost under delivery pressure.
abstract final class Space {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  static const xxxl = 64.0;

  /// The screen gutter on mobile (`margin-mobile`). Not the desktop 24.
  static const gutter = 20.0;

  /// Card padding is 16 or 24; these name both so neither is a bare number.
  static const cardPadding = 16.0;
  static const cardPaddingWide = 24.0;
}

/// Corner radii.
///
/// The pill is reserved *exclusively* for status chips and badges. That
/// reservation is the system's one strong signal that a thing is metadata
/// rather than structure, and it is destroyed the moment a pill-shaped button
/// appears. Nothing else goes above 6 — this is dressed stone, not a rounded
/// consumer app.
abstract final class Radii {
  /// Buttons, inputs, images, small cards.
  static const small = 4.0;

  /// Large panels and dossiers.
  static const panel = 6.0;

  /// Status chips and badges. Nothing else.
  static const pill = 9999.0;

  static const smallRadius = BorderRadius.all(Radius.circular(small));
  static const panelRadius = BorderRadius.all(Radius.circular(panel));
  static const pillRadius = BorderRadius.all(Radius.circular(pill));
}

/// Depth, such as it is.
///
/// DESIGN.md §4 is explicit that artificial drop shadows are strictly avoided:
/// depth is tonal layering plus hairline borders, in exactly three levels.
/// Flutter fights this in several places, which `InterioBeeTheme` handles centrally
/// rather than per widget.
abstract final class Layering {
  /// The one permitted shadow, on level 2 only.
  ///
  /// A mineral diffusion rather than a Material drop shadow — very large blur,
  /// pulled back by a negative spread, at 6% opacity.
  static const overlayShadow = BoxShadow(
    blurRadius: 48,
    offset: Offset(0, 24),
    spreadRadius: -12,
    color: Color(0x0F1E1B18),
  );

  /// The frosted header: limestone at 88%, over a 12px backdrop blur.
  ///
  /// Scrolling content screens only. It costs a full-screen blur every frame
  /// and earns nothing on a form.
  static const frostedFill = Color(0xE0FBF9F6);
  static const frostedBlur = 12.0;
}

/// Touch targets.
///
/// The renders use a 44px control height, which is a web figure. Android wants
/// 48dp and iOS 44pt; 48 satisfies both, and an icon button gets the full box
/// even where the glyph is 20.
abstract final class TapTarget {
  static const minimum = 48.0;
  static const glyph = 20.0;
}
