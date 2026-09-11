/// The Flutter theme, and the three places Flutter fights this design.
library;

import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

/// What a colour *means* on this platform.
///
/// DESIGN.md §1.4 is the rule, and it is load-bearing rather than decorative:
///
///   sage       verified, signed, or approved **by a person at Decora Shine**
///   terracotta your turn — the one thing on this screen to act on
///   ochre      waiting on somebody else
///   burntIron  wrong
///   travertine neutral metadata
///
/// The rule that keeps it meaningful: **sage is never decorative.** A stage the
/// vendor has uploaded proof for is ochre; it turns sage the moment ops approve
/// it. That single transition is the most important piece of colour in the
/// product, because it is "a stage is done when somebody checked" made visible.
@immutable
class InterioBeePalette extends ThemeExtension<InterioBeePalette> {
  const InterioBeePalette({
    required this.verified,
    required this.verifiedContainer,
    required this.onVerifiedContainer,
    required this.waiting,
    required this.wrong,
    required this.metadata,
    required this.hairline,
    required this.inputBorder,
    required this.overlayShadow,
    required this.financialNum,
  });

  /// Sage. Something was checked by a human.
  final Color verified;
  final Color verifiedContainer;
  final Color onVerifiedContainer;

  /// Ochre. Submitted, and waiting on somebody who is not you.
  final Color waiting;

  /// Burnt iron. Overdue, lost, declined, suspended.
  final Color wrong;

  /// Travertine. Trade tags, material source, spec chips.
  final Color metadata;

  /// The mortar line. Every level-1 border.
  final Color hairline;

  /// The overlay border, level 2 only. Material has no role for it.
  final Color inputBorder;

  final BoxShadow overlayShadow;

  /// Every rupee figure. Tabular, so a column of quotes aligns.
  final TextStyle financialNum;

  static final light = InterioBeePalette(
    verified: InterioBeeColors.sage,
    verifiedContainer: InterioBeeColors.sageContainer,
    onVerifiedContainer: InterioBeeColors.onSageContainer,
    waiting: InterioBeeColors.ochre,
    wrong: InterioBeeColors.burntIron,
    metadata: InterioBeeColors.travertine,
    hairline: InterioBeeColors.mortar,
    inputBorder: InterioBeeColors.overlayBorder,
    overlayShadow: Layering.overlayShadow,
    financialNum: InterioBeeTextStyles.financialNum,
  );

  @override
  InterioBeePalette copyWith({
    Color? verified,
    Color? verifiedContainer,
    Color? onVerifiedContainer,
    Color? waiting,
    Color? wrong,
    Color? metadata,
    Color? hairline,
    Color? inputBorder,
    BoxShadow? overlayShadow,
    TextStyle? financialNum,
  }) {
    return InterioBeePalette(
      verified: verified ?? this.verified,
      verifiedContainer: verifiedContainer ?? this.verifiedContainer,
      onVerifiedContainer: onVerifiedContainer ?? this.onVerifiedContainer,
      waiting: waiting ?? this.waiting,
      wrong: wrong ?? this.wrong,
      metadata: metadata ?? this.metadata,
      hairline: hairline ?? this.hairline,
      inputBorder: inputBorder ?? this.inputBorder,
      overlayShadow: overlayShadow ?? this.overlayShadow,
      financialNum: financialNum ?? this.financialNum,
    );
  }

  @override
  InterioBeePalette lerp(ThemeExtension<InterioBeePalette>? other, double t) {
    if (other is! InterioBeePalette) return this;
    return InterioBeePalette(
      verified: Color.lerp(verified, other.verified, t)!,
      verifiedContainer: Color.lerp(
        verifiedContainer,
        other.verifiedContainer,
        t,
      )!,
      onVerifiedContainer: Color.lerp(
        onVerifiedContainer,
        other.onVerifiedContainer,
        t,
      )!,
      waiting: Color.lerp(waiting, other.waiting, t)!,
      wrong: Color.lerp(wrong, other.wrong, t)!,
      metadata: Color.lerp(metadata, other.metadata, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      overlayShadow: BoxShadow.lerp(overlayShadow, other.overlayShadow, t)!,
      financialNum: TextStyle.lerp(financialNum, other.financialNum, t)!,
    );
  }
}

/// Reads the palette without the ceremony.
extension InterioBeePaletteAccess on BuildContext {
  InterioBeePalette get palette =>
      Theme.of(this).extension<InterioBeePalette>()!;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
}

/// The light scheme.
///
/// Terracotta is remapped onto `primary`. The theme's own front matter puts ink
/// there and the action colour in `secondary`, which is backwards for Flutter:
/// loaded verbatim, every `FilledButton` comes out black. Remapping on the way
/// in means the framework defaults land correctly and espresso ink stays where
/// it belongs, on text.
const interiobeeLightScheme = ColorScheme(
  brightness: Brightness.light,

  primary: InterioBeeColors.terracotta,
  onPrimary: InterioBeeColors.chalk,
  primaryContainer: InterioBeeColors.attention,
  onPrimaryContainer: InterioBeeColors.onAttention,

  secondary: InterioBeeColors.ink,
  onSecondary: InterioBeeColors.limestone,
  secondaryContainer: InterioBeeColors.chipStrong,
  onSecondaryContainer: InterioBeeColors.inkMuted,

  tertiary: InterioBeeColors.sage,
  onTertiary: InterioBeeColors.chalk,
  tertiaryContainer: InterioBeeColors.sageContainer,
  onTertiaryContainer: InterioBeeColors.onSageContainer,

  error: InterioBeeColors.burntIron,
  onError: InterioBeeColors.chalk,
  errorContainer: InterioBeeColors.errorContainer,
  onErrorContainer: InterioBeeColors.burntIron,

  surface: InterioBeeColors.limestone,
  onSurface: InterioBeeColors.onSurface,
  onSurfaceVariant: InterioBeeColors.inkMuted,

  surfaceContainerLowest: InterioBeeColors.chalk,
  surfaceContainerLow: InterioBeeColors.card,
  surfaceContainer: InterioBeeColors.panel,
  surfaceContainerHigh: InterioBeeColors.chip,
  surfaceContainerHighest: InterioBeeColors.chipStrong,

  outline: InterioBeeColors.outline,
  outlineVariant: InterioBeeColors.mortar,

  inverseSurface: InterioBeeColors.inverseSurface,
  onInverseSurface: InterioBeeColors.onInverseSurface,
  inversePrimary: InterioBeeColors.inversePrimary,

  // See `InterioBeeTheme.light`. This one matters.
  surfaceTint: Color(0x00000000),
);

abstract final class InterioBeeTheme {
  /// The light theme. There is deliberately no dark one yet.
  ///
  /// DESIGN.md §3.8: ship light-only at v1, on the record. The palette is warm
  /// lime-washed plaster and the whole emotional argument is daylight on stone;
  /// a mechanical inversion gives a muddy brown-grey app that reads as a bug.
  /// Deferring costs exactly one discipline — every screen reads
  /// `colorScheme` and `InterioBeePalette`, never a literal — and that discipline
  /// is what makes dark mode later a single file.
  static ThemeData get light {
    const scheme = interiobeeLightScheme;
    final text = tintedTextTheme(interiobeeTextTheme);

    /// Material 3 tints surfaces by elevation and paints its own shadows.
    ///
    /// `surfaceTint: transparent` in the scheme kills most of it, but several
    /// components read their *own* property first and would tint anyway. This
    /// is the "handle it globally, not per widget" of DESIGN.md §4.
    const noTint = Colors.transparent;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text,
      fontFamily: InterioBeeFonts.family,
      package: InterioBeeFonts.package,
      fontFamilyFallback: InterioBeeFonts.fallback,
      splashFactory: InkSparkle.splashFactory,
      extensions: [InterioBeePalette.light],

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: InterioBeeColors.ink,
        surfaceTintColor: noTint,
        shadowColor: noTint,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.headlineSmall,
      ),

      cardTheme: const CardThemeData(
        color: InterioBeeColors.card,
        surfaceTintColor: noTint,
        shadowColor: noTint,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.panelRadius,
          side: BorderSide(color: InterioBeeColors.mortar),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: InterioBeeColors.chalk,
        surfaceTintColor: noTint,
        shadowColor: noTint,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Radii.panel),
          ),
          side: BorderSide(color: InterioBeeColors.overlayBorder),
        ),
      ),

      dialogTheme: const DialogThemeData(
        backgroundColor: InterioBeeColors.chalk,
        surfaceTintColor: noTint,
        shadowColor: noTint,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.panelRadius,
          side: BorderSide(color: InterioBeeColors.overlayBorder),
        ),
      ),

      popupMenuTheme: const PopupMenuThemeData(
        color: InterioBeeColors.chalk,
        surfaceTintColor: noTint,
        shadowColor: noTint,
        elevation: 0,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: noTint,
        shadowColor: noTint,
        elevation: 0,
        height: 64,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => InterioBeeTextStyles.eyebrow.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: TapTarget.glyph,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
      ),

      /// 48dp, not the renders' 44. That is a web figure; Android wants 48 and
      /// iOS 44, so 48 satisfies both.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, TapTarget.minimum),
          padding: const EdgeInsets.symmetric(horizontal: Space.lg),
          textStyle: text.titleMedium,
          shape: const RoundedRectangleBorder(borderRadius: Radii.smallRadius),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, TapTarget.minimum),
          padding: const EdgeInsets.symmetric(horizontal: Space.lg),
          textStyle: text.titleMedium,
          foregroundColor: InterioBeeColors.ink,
          side: const BorderSide(color: InterioBeeColors.overlayBorder),
          shape: const RoundedRectangleBorder(borderRadius: Radii.smallRadius),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, TapTarget.minimum),
          textStyle: text.titleMedium,
          foregroundColor: scheme.primary,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: InterioBeeColors.chalk,
        constraints: const BoxConstraints(minHeight: TapTarget.minimum),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Space.sm,
          vertical: Space.sm,
        ),
        labelStyle: text.labelMedium,
        border: const OutlineInputBorder(
          borderRadius: Radii.smallRadius,
          borderSide: BorderSide(color: InterioBeeColors.overlayBorder),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: Radii.smallRadius,
          borderSide: BorderSide(color: InterioBeeColors.overlayBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Radii.smallRadius,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: Radii.smallRadius,
          borderSide: BorderSide(color: scheme.error),
        ),
      ),

      /// `height` defaults to 16, which quietly breaks the vertical rhythm on
      /// every card. Dividers also respect a card's inset rather than running
      /// edge to edge — see `InterioBeeDivider`.
      dividerTheme: const DividerThemeData(
        color: InterioBeeColors.mortar,
        thickness: 1,
        space: 1,
      ),

      listTileTheme: const ListTileThemeData(
        minVerticalPadding: Space.sm,
        contentPadding: EdgeInsets.symmetric(horizontal: Space.md),
      ),
    );
  }
}
