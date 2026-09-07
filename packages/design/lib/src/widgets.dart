/// The shared widgets.
///
/// Everything here exists because a stock Material widget gets this design
/// wrong in a way a call-site override would have to keep re-fixing. Where the
/// theme can handle it centrally it does; these are the cases it cannot.
library;

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'theme.dart';
import 'tokens.dart';
import 'typography.dart';

/// Level 1: a raised surface.
///
/// Replaces `Card`, which paints its own margin and radius regardless of the
/// theme and reintroduces a shadow the moment anybody passes `elevation`.
/// DESIGN.md §4 allows exactly one shadow in the whole system and it is not
/// this one. Raw `Card` should fail review.
class AanganCard extends StatelessWidget {
  const AanganCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Space.cardPadding),
    this.nested = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// A panel *inside* a card steps one level darker, rather than gaining a
  /// border or a shadow. This is the whole of "depth" in this system.
  final bool nested;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final decorated = Container(
      decoration: BoxDecoration(
        color: nested ? colors.surfaceContainer : colors.surfaceContainerLow,
        border: Border.all(color: context.palette.hairline),
        borderRadius: Radii.panelRadius,
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) return decorated;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.panelRadius,
        child: decorated,
      ),
    );
  }
}

/// Level 2: an overlay. The only place a shadow is permitted.
class AanganOverlay extends StatelessWidget {
  const AanganOverlay({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Space.cardPaddingWide),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: AanganColors.chalk,
        border: Border.all(color: palette.inputBorder),
        borderRadius: Radii.panelRadius,
        boxShadow: [palette.overlayShadow],
      ),
      padding: padding,
      child: child,
    );
  }
}

/// What a status pill means. The colour is not a choice at the call site.
///
/// This enum *is* DESIGN.md §1.4. Passing a tone rather than a colour is what
/// stops sage becoming decorative: a caller has to claim the thing was checked
/// by a person in order to get the green.
enum StatusTone {
  /// Verified, signed, or approved by a person at Aangan. Never decoration.
  verified,

  /// Your turn. The one thing on this screen to act on.
  yours,

  /// Submitted, and waiting on somebody else.
  waiting,

  /// Overdue, lost, declined, suspended.
  wrong,

  /// Neutral metadata — a trade tag, a material source, a spec.
  neutral,
}

/// A status chip. The one place a pill radius is allowed.
class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key, required this.tone});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colors = context.colors;

    final (Color background, Color foreground) = switch (tone) {
      StatusTone.verified => (palette.verifiedContainer, palette.onVerifiedContainer),
      StatusTone.yours => (colors.primaryContainer, colors.onPrimaryContainer),
      StatusTone.waiting => (const Color(0xFFFDF3E3), palette.waiting),
      StatusTone.wrong => (colors.errorContainer, palette.wrong),
      StatusTone.neutral => (palette.metadata, colors.onSurfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.xs, vertical: Space.xxs),
      decoration: BoxDecoration(color: background, borderRadius: Radii.pillRadius),
      child: Text(
        // Uppercased for display only. The semantics label keeps the original
        // so a screen reader says "verified", not "V-E-R-I-F-I-E-D".
        label.toUpperCase(),
        style: AanganTextStyles.eyebrow.copyWith(color: foreground),
        semanticsLabel: label,
      ),
    );
  }
}

/// A rupee figure, in the one style that carries tabular numerals.
class MoneyText extends StatelessWidget {
  const MoneyText(this.formatted, {super.key, this.tone});

  final String formatted;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    return Text(
      formatted,
      style: context.palette.financialNum.copyWith(color: tone ?? AanganColors.ink),
    );
  }
}

/// A divider that respects its card's inset.
///
/// Never edge to edge. `height` is pinned because Flutter's default of 16 adds
/// invisible vertical space that breaks the rhythm on every card it appears in.
class AanganDivider extends StatelessWidget {
  const AanganDivider({super.key, this.inset = Space.cardPadding});

  final double inset;

  @override
  Widget build(BuildContext context) {
    return Divider(
      indent: inset,
      endIndent: inset,
      thickness: 1,
      height: 1,
      color: context.palette.hairline,
    );
  }
}

/// The peach "action required" panel.
///
/// The strongest device in the prototype and the one most worth keeping: a
/// quote waiting to be chosen, an agreement ready to sign, a stage sent back
/// for rework. It should appear when the *person* is the blocker, and not
/// otherwise — if it is on every screen it stops meaning anything.
class ActionRequired extends StatelessWidget {
  const ActionRequired({
    super.key,
    required this.title,
    required this.body,
    this.action,
  });

  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Space.cardPaddingWide),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: Radii.panelRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.text.headlineSmall?.copyWith(color: colors.onPrimaryContainer),
          ),
          const SizedBox(height: Space.xs),
          Text(
            body,
            style: context.text.bodyMedium?.copyWith(color: colors.onPrimaryContainer),
          ),
          if (action != null) ...[
            const SizedBox(height: Space.md),
            action!,
          ],
        ],
      ),
    );
  }
}

/// A section head, with the macro rhythm built in.
///
/// The 32-to-48 above a heading is what makes the design read as editorial. It
/// lives here so it is not re-typed — and quietly compressed — on every screen.
class SectionHead extends StatelessWidget {
  const SectionHead(this.title, {super.key, this.eyebrow, this.trailing});

  final String title;
  final String? eyebrow;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Space.xl, bottom: Space.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null) ...[
                  Text(
                    eyebrow!.toUpperCase(),
                    style: AanganTextStyles.eyebrow
                        .copyWith(color: context.colors.onSurfaceVariant),
                    semanticsLabel: eyebrow,
                  ),
                  const SizedBox(height: Space.xxs),
                ],
                Text(title, style: context.text.headlineMedium),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// The frosted header.
///
/// Scrolling content screens only. It costs a full-screen blur every frame and
/// earns nothing on a form, so it is a deliberate opt-in rather than the
/// default app bar.
class FrostedHeader extends StatelessWidget implements PreferredSizeWidget {
  const FrostedHeader({super.key, required this.title, this.actions});

  final Widget title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: Layering.frostedBlur,
          sigmaY: Layering.frostedBlur,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Layering.frostedFill,
            border: Border(bottom: BorderSide(color: context.palette.hairline)),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            title: title,
            actions: actions,
          ),
        ),
      ),
    );
  }
}
