/// The Flutter theme, and the three places Flutter fights this design.
library;

import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

/// What a colour *means* on this platform.
///
/// DESIGN.md §1.4 is the rule, and it is load-bearing rather than decorative:
///
///   sage       verified, signed, or approved **by a person at Aangan**
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
class AanganPalette extends ThemeExtension<AanganPalette> {
  const AanganPalette({
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

  static const light = AanganPalette(
    verified: AanganColors.sage,
    verifiedContainer: AanganColors.sageContainer,
    onVerifiedContainer: AanganColors.onSageContainer,
    waiting: AanganColors.ochre,
    wrong: AanganColors.burntIron,
    metadata: AanganColors.travertine,
    hairline: AanganColors.mortar,
    inputBorder: AanganColors.overlayBorder,
    overlayShadow: Layering.overlayShadow,
    financialNum: AanganTextStyles.financialNum,
  );

  @override
  AanganPalette copyWith({
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
    return AanganPalette(
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
  AanganPalette lerp(ThemeExtension<AanganPalette>? other, double t) {
    if (other is! AanganPalette) return this;
    return AanganPalette(
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
extension AanganPaletteAccess on BuildContext {
  AanganPalette get palette => Theme.of(this).extension<AanganPalette>()!;
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
const aanganLightScheme = ColorScheme(
  brightness: Brightness.light,

  primary: AanganColors.terracotta,
  onPrimary: AanganColors.chalk,
  primaryContainer: AanganColors.attention,
  onPrimaryContainer: AanganColors.onAttention,

  secondary: AanganColors.ink,
  onSecondary: AanganColors.limestone,
  secondaryContainer: AanganColors.chipStrong,
  onSecondaryContainer: AanganColors.inkMuted,

  tertiary: AanganColors.sage,
  onTertiary: AanganColors.chalk,
  tertiaryContainer: AanganColors.sageContainer,
  onTertiaryContainer: AanganColors.onSageContainer,

  error: AanganColors.burntIron,
  onError: AanganColors.chalk,
  errorContainer: AanganColors.errorContainer,
  onErrorContainer: AanganColors.burntIron,

  surface: AanganColors.limestone,
  onSurface: AanganColors.onSurface,
  onSurfaceVariant: AanganColors.inkMuted,

  surfaceContainerLowest: AanganColors.chalk,
  surfaceContainerLow: AanganColors.card,
  surfaceContainer: AanganColors.panel,
  surfaceContainerHigh: AanganColors.chip,
  surfaceContainerHighest: AanganColors.chipStrong,

  outline: AanganColors.outline,
  outlineVariant: AanganColors.mortar,

  inverseSurface: AanganColors.inverseSurface,
  onInverseSurface: AanganColors.onInverseSurface,
  inversePrimary: AanganColors.inversePrimary,

  // See `AanganTheme.light`. This one matters.
  surfaceTint: Color(0x00000000),
);

abstract final class AanganTheme {
  /// The light theme. There is deliberately no dark one yet.
  ///
  /// DESIGN.md §3.8: ship light-only at v1, on the record. The palette is warm
  /// lime-washed plaster and the whole emotional argument is daylight on stone;
  /// a mechanical inversion gives a muddy brown-grey app that reads as a bug.
  /// Deferring costs exactly one discipline — every screen reads
  /// `colorScheme` and `AanganPalette`, never a literal — and that discipline
  /// is what makes dark mode later a single file.
  static ThemeData get light {
    const scheme = aanganLightScheme;
    final text = tintedTextTheme(aanganTextTheme);

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
      fontFamily: AanganFonts.sans,
      fontFamilyFallback: AanganFonts.devanagariFallback,
      splashFactory: InkSparkle.splashFactory,
      extensions: const [AanganPalette.light],

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: AanganColors.ink,
        surfaceTintColor: noTint,
        shadowColor: noTint,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.headlineSmall,
      ),

      cardTheme: const CardThemeData(
        color: AanganColors.card,
        surfaceTintColor: noTint,
        shadowColor: noTint,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.panelRadius,
          side: BorderSide(color: AanganColors.mortar),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AanganColors.chalk,
        surfaceTintColor: noTint,
        shadowColor: noTint,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Radii.panel),
          ),
          side: BorderSide(color: AanganColors.overlayBorder),
        ),
      ),

      dialogTheme: const DialogThemeData(
        backgroundColor: AanganColors.chalk,
        surfaceTintColor: noTint,
        shadowColor: noTint,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.panelRadius,
          side: BorderSide(color: AanganColors.overlayBorder),
        ),
      ),

      popupMenuTheme: const PopupMenuThemeData(
        color: AanganColors.chalk,
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
          (states) => AanganTextStyles.eyebrow.copyWith(
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
          foregroundColor: AanganColors.ink,
          side: const BorderSide(color: AanganColors.overlayBorder),
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
        fillColor: AanganColors.chalk,
        constraints: const BoxConstraints(minHeight: TapTarget.minimum),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Space.sm,
          vertical: Space.sm,
        ),
        labelStyle: text.labelMedium,
        border: const OutlineInputBorder(
          borderRadius: Radii.smallRadius,
          borderSide: BorderSide(color: AanganColors.overlayBorder),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: Radii.smallRadius,
          borderSide: BorderSide(color: AanganColors.overlayBorder),
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
      /// edge to edge — see `AanganDivider`.
      dividerTheme: const DividerThemeData(
        color: AanganColors.mortar,
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
