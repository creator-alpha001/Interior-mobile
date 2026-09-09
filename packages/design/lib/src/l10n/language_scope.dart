/// Reaching the language setting from anywhere.
///
/// The switcher belongs on the customer's account screen *and* on the vendor's
/// More tab, and those live in two different feature packages that do not know
/// about each other or about the app. Threading a callback down from `main` to
/// both would mean a parameter on every shell, tab and screen in between, and
/// the one that gets forgotten is always the one somebody needed.
///
/// So the app publishes an interface at the root and the screens look it up.
/// `design` owns the interface and the widget; the app owns the storage — which
/// is what keeps `design` free of `shared_preferences`, and free of any
/// dependency that would stop the component gallery rendering offline.
library;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../tokens.dart';
import '../widgets.dart';
import 'l10n.dart';

/// What a screen needs from the language setting, and nothing more.
///
/// `null` is "follow the device", and is deliberately distinct from having
/// chosen English — see `LanguageController` in the app for why that
/// distinction has to survive down here.
abstract class LanguageSwitch implements Listenable {
  Locale? get locale;
  Future<void> set(Locale? locale);
}

class InterioBeeLanguageScope extends InheritedNotifier<Listenable> {
  const InterioBeeLanguageScope({
    super.key,
    required this.language,
    required super.child,
  }) : super(notifier: language);

  final LanguageSwitch language;

  /// Null when no scope is above — a test, or the component gallery.
  ///
  /// Nullable on purpose rather than asserting: a widget test pumping one
  /// screen should not have to build the app's whole preference stack to see
  /// that screen.
  static LanguageSwitch? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<InterioBeeLanguageScope>()
      ?.language;

  @override
  bool updateShouldNotify(InterioBeeLanguageScope oldWidget) =>
      language != oldWidget.language;
}

/// The row that opens the picker. Renders nothing when there is no scope.
class LanguageSetting extends StatelessWidget {
  const LanguageSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final language = InterioBeeLanguageScope.maybeOf(context);
    if (language == null) return const SizedBox.shrink();

    return InterioBeeCard(
      onTap: () => showLanguagePicker(context),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.t('Language'), style: context.text.titleLarge),
                Text(
                  _currentLabel(context, language.locale),
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: context.colors.onSurfaceVariant),
        ],
      ),
    );
  }

  static String _currentLabel(BuildContext context, Locale? locale) =>
      switch (locale?.languageCode) {
        'hi' => 'हिन्दी',
        'en' => 'English',
        _ => context.t('Same as your phone'),
      };
}

Future<void> showLanguagePicker(BuildContext context) async {
  final language = InterioBeeLanguageScope.maybeOf(context);
  if (language == null) return;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.colors.surface,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.gutter,
              Space.lg,
              Space.gutter,
              Space.sm,
            ),
            child: Text(
              context.t('Language'),
              style: context.text.headlineSmall,
            ),
          ),

          /// Every option is written in its own language, always.
          ///
          /// A picker that labels Hindi as "Hindi" is unusable by the one
          /// person who most needs it: somebody stuck in a language they
          /// cannot read has to recognise their own, not translate into it.
          _Option(
            label: 'English',
            selected: language.locale?.languageCode == 'en',
            onTap: () => language.set(const Locale('en')),
          ),
          _Option(
            label: 'हिन्दी',
            selected: language.locale?.languageCode == 'hi',
            onTap: () => language.set(const Locale('hi')),
          ),
          _Option(
            label: context.t('Same as your phone'),
            selected: language.locale == null,
            onTap: () => language.set(null),
          ),
          const SizedBox(height: Space.md),
        ],
      ),
    ),
  );
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
        Navigator.of(context).pop();
      },
      child: Container(
        // The full 48dp, because this is a list somebody scrolls and taps
        // without looking closely.
        constraints: const BoxConstraints(minHeight: TapTarget.minimum),
        padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
        child: Row(
          children: [
            Expanded(child: Text(label, style: context.text.bodyLarge)),
            if (selected)
              // Sage: this is a settled fact, not an action.
              Icon(Icons.check, color: context.palette.verified),
          ],
        ),
      ),
    );
  }
}
