/// Translation, keyed by the English sentence.
///
/// **Why not ARB and `flutter gen-l10n`.** The generated approach wants every
/// string named — `closeAccountConfirmLabel` — and the name is then the only
/// thing visible at the call site. In a codebase where the prose *is* the
/// design work, that trade is bad twice over: the screen files stop reading
/// like the screens, and a reviewer comparing copy against DESIGN.md has to
/// hold a second file open. It also gives no help at all with the failure that
/// actually happens, which is a string somebody forgot to externalise.
///
/// So the English sentence is the key, gettext-style. `context.t('Sign in')`
/// reads as what it draws, a missing translation degrades to English rather
/// than to `null` or a key name, and `l10n_test.dart` can scan the sources and
/// fail on both halves of the real problem: a wrapped string with no Hindi, and
/// a user-facing string nobody wrapped.
///
/// The cost is no compile-time key checking. The test buys that back, and buys
/// more besides — the compiler could never have told us about the second case.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'hi.dart';

/// The locales the app ships.
///
/// Hindi is not a nice-to-have here. The vendor half of this app is carpenters,
/// painters and fabricators, and English-only would be a functional barrier for
/// a large share of them — not a polish item.
const interiobeeSupportedLocales = <Locale>[Locale('en'), Locale('hi')];

/// A lookup, and nothing else.
///
/// Deliberately not a generated class with one getter per string: adding copy
/// to a screen should not mean touching a code generator, and a translator
/// should be able to work from one table rather than from a Dart API.
@immutable
class InterioBeeL10n {
  const InterioBeeL10n({
    required this.locale,
    required Map<String, String> table,
  }) : _table = table;

  /// English, which needs no table: the key is already the string.
  static const english = InterioBeeL10n(
    locale: Locale('en'),
    table: <String, String>{},
  );

  final Locale locale;
  final Map<String, String> _table;

  bool get isHindi => locale.languageCode == 'hi';

  /// Translates [source], substituting `{name}` placeholders from [args].
  ///
  /// Placeholders rather than Dart interpolation because word order moves
  /// between languages: "3 added so far" and "अब तक 3 जोड़े गए" do not put the
  /// number in the same place, and a pre-interpolated string cannot be
  /// translated at all — it would need one table entry per possible value.
  String call(String source, [Map<String, Object?> args = const {}]) {
    var out = _table[source] ?? source;
    if (args.isEmpty) return out;
    for (final entry in args.entries) {
      out = out.replaceAll('{${entry.key}}', '${entry.value}');
    }
    return out;
  }

  /// Picks the singular or the plural form, then translates.
  ///
  /// Hindi and English agree on having exactly two forms, which is the only
  /// reason this can be two arguments instead of a CLDR category table. If a
  /// third locale ever arrives this becomes the wrong shape — noted here so it
  /// is a decision rather than a discovery.
  String plural(int count, String one, String other) =>
      call(count == 1 ? one : other, {'n': '$count'});

  static InterioBeeL10n of(BuildContext context) =>
      Localizations.of<InterioBeeL10n>(context, InterioBeeL10n) ?? english;

  static InterioBeeL10n forLocale(Locale locale) =>
      switch (locale.languageCode) {
        'hi' => const InterioBeeL10n(locale: Locale('hi'), table: hindi),
        _ => english,
      };
}

class InterioBeeL10nDelegate extends LocalizationsDelegate<InterioBeeL10n> {
  const InterioBeeL10nDelegate();

  @override
  bool isSupported(Locale locale) => interiobeeSupportedLocales.any(
    (l) => l.languageCode == locale.languageCode,
  );

  /// Synchronous, because the table is compiled in.
  ///
  /// Loading translations over the wire would mean a first frame in the wrong
  /// language on every cold start, which is exactly the flicker the bundled
  /// fonts exist to avoid.
  @override
  Future<InterioBeeL10n> load(Locale locale) =>
      SynchronousFuture(InterioBeeL10n.forLocale(locale));

  @override
  bool shouldReload(InterioBeeL10nDelegate old) => false;
}

extension InterioBeeL10nContext on BuildContext {
  InterioBeeL10n get l10n => InterioBeeL10n.of(this);

  /// The workhorse. `context.t('Sign in')`.
  String t(String source, [Map<String, Object?> args = const {}]) =>
      InterioBeeL10n.of(this)(source, args);
}
