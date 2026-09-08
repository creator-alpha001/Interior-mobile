/// "You are seeing what we had earlier."
///
/// MOBILE.md §7.4 asks for a cold launch on bad signal to show the last state
/// **with an explicit "as of" timestamp** rather than a spinner. The timestamp
/// is the part that makes the cache honest: without it somebody cannot tell a
/// stale dashboard from a live one, and acting on the wrong one is worse than
/// having waited.
///
/// Drawn once at the top of the app rather than per screen, because staleness
/// is a property of the connection and not of any particular list.
library;

import 'package:flutter/material.dart';

import 'l10n/l10n.dart';
import 'theme.dart';
import 'tokens.dart';

class StaleBanner extends StatelessWidget {
  const StaleBanner({super.key, required this.since});

  /// When the data on screen was last fetched. Null hides the banner.
  final DateTime? since;

  @override
  Widget build(BuildContext context) {
    final at = since;
    if (at == null) return const SizedBox.shrink();

    return Material(
      color: context.colors.surfaceContainerHigh,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.gutter,
            vertical: Space.xs,
          ),
          child: Row(
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: TapTarget.glyph,
                // Ochre: waiting on something that is not the person's fault
                // and not their job to fix. Not iron — nothing is wrong.
                color: context.palette.waiting,
              ),
              const SizedBox(width: Space.xs),
              Expanded(
                child: Text(
                  context.t(
                    'Showing what we had {when}. We will refresh when you are '
                    'back online.',
                    {'when': _ago(context, at)},
                  ),
                  style: context.text.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Deliberately vague at the top end.
  ///
  /// "3 days ago" is more useful than a date somebody has to subtract from
  /// today, and precision beyond a minute implies a freshness the cache does
  /// not have.
  static String _ago(BuildContext context, DateTime at) {
    final gap = DateTime.now().difference(at);
    final l10n = context.l10n;

    if (gap.inMinutes < 1) return context.t('a moment ago');
    if (gap.inMinutes < 60) {
      return l10n.plural(gap.inMinutes, '{n} minute ago', '{n} minutes ago');
    }
    if (gap.inHours < 24) {
      return l10n.plural(gap.inHours, '{n} hour ago', '{n} hours ago');
    }
    return l10n.plural(gap.inDays, '{n} day ago', '{n} days ago');
  }
}
