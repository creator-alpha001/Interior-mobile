/// The test that makes the gettext-style approach safe.
///
/// `context.t('…')` has no compile-time key checking: a typo, a string nobody
/// translated, and a table entry for a screen that changed all compile
/// perfectly and all ship. `l10n.dart` argues that the trade is worth making
/// because a test can check *more* than the compiler could. This is that test,
/// and it has to actually do it.
///
/// It scans the sources rather than the running app, which is what lets it see
/// the failure the compiler never can: a user-facing sentence somebody forgot
/// to wrap at all.
library;

import 'dart:io';

import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every package with screens in it, relative to `app/`.
const _sourceRoots = <String>[
  'lib',
  '../packages/design/lib',
  '../packages/feature_customer/lib',
  '../packages/feature_vendor/lib',
];

/// The component gallery is a development surface, shipped only in non-release
/// builds. It renders components rather than anybody's data, and translating it
/// would mean carrying a table for screens no customer reaches.
const _excluded = <String>['gallery.dart'];

final _call = RegExp(r"""context\.t\(\s*((?:'(?:[^'\\]|\\.)*'\s*)+)""");

/// The separator after the plural form is `,` when the call is spread over
/// several lines and `)` when it fits on one. Both appear in the app, and
/// accepting only the first under-reports what the app asks for — which then
/// surfaces as four *orphaned* translations rather than as a missing scan, and
/// sends you looking in the wrong file.
final _plural = RegExp(
  r"""\.plural\(\s*[^,]+,\s*((?:'(?:[^'\\]|\\.)*'\s*)+),\s*((?:'(?:[^'\\]|\\.)*'\s*)+)[,)]""",
);
final _literal = RegExp(r"""'((?:[^'\\]|\\.)*)'""");

/// Dart concatenates adjacent string literals, so a sentence written across
/// four lines is four literals and one key.
String _join(String run) =>
    _literal.allMatches(run).map((m) => m.group(1)!).join();

Iterable<File> _sources() sync* {
  for (final root in _sourceRoots) {
    final directory = Directory(root);
    if (!directory.existsSync()) continue;
    for (final entity in directory.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final name = entity.uri.pathSegments.last;
      if (_excluded.contains(name)) continue;
      // The generated client, and the tables themselves.
      if (entity.path.contains('generated') || name.startsWith('hi')) continue;
      if (name.endsWith('.g.dart') || name.endsWith('.freezed.dart')) continue;
      // `l10n.dart` documents the mechanism, and its examples are not screens.
      if (name == 'l10n.dart') continue;
      yield entity;
    }
  }
}

/// Copy that reaches `context.t()` as a value rather than as a literal.
///
/// Two screens are table-driven: the estimator's rates and the "how it works"
/// steps both pass `context.t(someField)`, where the call site has no literal
/// for the scan below to find. The literals live in a const table in one file
/// each, so they are collected from there directly.
///
/// If this hole is ever left open the symptom is specific and quiet — that one
/// screen stays English in a Hindi app while every other screen looks finished.
/// A third table-driven screen must be added here, and the compiler will not
/// say so.
const _tables = <(String, String)>[
  (
    '../packages/feature_customer/lib/src/estimator.dart',
    'const estimatorConfigs',
  ),
  ('../packages/feature_customer/lib/src/about_screens.dart', 'const _steps'),
  (
    '../packages/feature_customer/lib/src/about_screens.dart',
    'const _requirements',
  ),
];

final _configLiteral = _literal;

/// Fields that are identifiers or API vocabulary, not copy.
const _notCopy = <String>['domainSlug:', 'domainName:'];

Set<String> _tableCopy() {
  final keys = <String>{};
  for (final (path, marker) in _tables) {
    keys.addAll(_collect(File(path), marker));
  }
  return keys;
}

Set<String> _collect(File file, String marker) {
  if (!file.existsSync()) return {};

  final keys = <String>{};
  var inTable = false;
  var pending = <String>[];

  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trimLeft();
    if (trimmed.startsWith(marker)) {
      inTable = true;
      continue;
    }
    if (!inTable) continue;

    // The table ends at a `];` in the first column. Without this the scan runs
    // to the end of the file and collects the widgets below it — which is how
    // `'$index'` from a row's leading number ended up demanding a translation.
    if (line.startsWith('];')) break;
    if (trimmed.startsWith('//')) continue;
    if (_notCopy.any(trimmed.startsWith)) continue;

    final found = _configLiteral
        .allMatches(line)
        .map((m) => m.group(1)!)
        .where((s) => s.length > 1);
    if (found.isEmpty) {
      if (pending.isNotEmpty) {
        keys.add(pending.join());
        pending = <String>[];
      }
      continue;
    }
    // Adjacent literals across lines are one sentence, as everywhere else.
    pending.addAll(found);
    if (trimmed.endsWith(',') || trimmed.endsWith('),')) {
      keys.add(pending.join());
      pending = <String>[];
    }
  }
  if (pending.isNotEmpty) keys.add(pending.join());
  return keys;
}

/// Comments are stripped before scanning.
///
/// A doc comment explaining the mechanism naturally contains an example call,
/// and that example is not a string the app asks for. `about_screens.dart`
/// carried one and this test demanded a Hindi translation of `…`.
///
/// Line comments only. A `/* */` block containing a `context.t(` would slip
/// through, and if that ever happens the answer is to stop writing example
/// calls in block comments rather than to write a Dart parser here.
final _lineComment = RegExp(r'^\s*///?.*$', multiLine: true);

/// Every string the app asks to translate.
Set<String> _requestedKeys() {
  final keys = <String>{};
  for (final file in _sources()) {
    final source = file.readAsStringSync().replaceAll(_lineComment, '');
    for (final m in _call.allMatches(source)) {
      keys.add(_join(m.group(1)!));
    }
    for (final m in _plural.allMatches(source)) {
      keys
        ..add(_join(m.group(1)!))
        ..add(_join(m.group(2)!));
    }
  }
  return keys..addAll(_tableCopy());
}

void main() {
  final requested = _requestedKeys();

  test('the scan finds the app, not an empty directory', () {
    // Guards against the whole suite passing because a path moved and every
    // check below became vacuous.
    expect(_sources().length, greaterThan(20));
    expect(requested.length, greaterThan(250));
  });

  test('every string the app asks for has Hindi', () {
    final missing = requested.where((k) => !hindi.containsKey(k)).toList()
      ..sort();

    expect(
      missing,
      isEmpty,
      reason:
          'These are wrapped in context.t() but have no entry in any hi_*.dart '
          'table, so a Hindi reader sees English:\n  ${missing.join("\n  ")}',
    );
  });

  test('every Hindi entry is asked for by a screen', () {
    // The other direction, and the one that rots quietly: copy changes, the
    // old sentence stays in the table, and a translator reviewing the file is
    // reading strings the app cannot show.
    final orphaned = hindi.keys.where((k) => !requested.contains(k)).toList()
      ..sort();

    expect(
      orphaned,
      isEmpty,
      reason:
          'These are translated but no screen asks for them — the copy has '
          'moved on:\n  ${orphaned.join("\n  ")}',
    );
  });

  test('no Hindi entry is left as its English', () {
    // An entry copied in as a placeholder and never translated is worse than a
    // missing one: the missing one is reported by the test above, and this one
    // looks done.
    final untranslated =
        hindi.entries
            .where((e) => e.key == e.value)
            // Written the same in both languages on purpose.
            .where((e) => e.key != 'हिन्दी')
            .map((e) => e.key)
            .toList()
          ..sort();

    expect(untranslated, isEmpty);
  });

  test('a translation keeps every placeholder its English has', () {
    // `'{n} new leads'` translated without its `{n}` loses the number
    // silently: nothing throws, and the screen just reads oddly.
    final placeholder = RegExp(r'\{(\w+)\}');
    final broken = <String>[];

    for (final entry in hindi.entries) {
      final wanted = placeholder
          .allMatches(entry.key)
          .map((m) => m.group(1)!)
          .toSet();
      final got = placeholder
          .allMatches(entry.value)
          .map((m) => m.group(1)!)
          .toSet();
      if (!setEquals(wanted, got)) {
        broken.add('${entry.key}\n    wanted $wanted, got $got');
      }
    }

    expect(broken, isEmpty, reason: broken.join('\n  '));
  });

  test('the section tables do not shadow one another', () {
    /// Checked against the *sections*, never against `hindi` itself.
    ///
    /// A Dart const map with a duplicate key builds fine and then throws on
    /// every lookup — an assertion inside `dart:_compact_hash` with no key
    /// named and no file named. Touching `hindi` here would make this test one
    /// more casualty of the bug rather than the thing that reports it, which
    /// is exactly what happened: `'Overall'` appeared in two tables and eight
    /// unrelated assertions failed with the same unreadable message.
    final sections = <String, Map<String, String>>{
      'hiCommon': hiCommon,
      'hiAbout': hiAbout,
      'hiAccount': hiAccount,
      'hiApp': hiApp,
      'hiCatalogue': hiCatalogue,
      'hiCustomer': hiCustomer,
      'hiGuides': hiGuides,
      'hiVendor': hiVendor,
    };

    final homes = <String, List<String>>{};
    sections.forEach((name, table) {
      for (final key in table.keys) {
        homes.putIfAbsent(key, () => []).add(name);
      }
    });

    final shared = homes.entries.where((e) => e.value.length > 1).toList();
    expect(
      shared.map((e) => '${e.key} — in ${e.value.join(" and ")}').toList(),
      isEmpty,
      reason: 'One key, one home. A duplicate breaks every lookup in the app.',
    );

    // And the arithmetic, which catches a section nobody merged into `hindi`.
    final counted = sections.values
        .map((table) => table.length)
        .reduce((a, b) => a + b);

    expect(
      hindi.length,
      counted,
      reason: 'A key appears in more than one hi_*.dart, and one copy is dead.',
    );
  });

  group('the lookup itself', () {
    test('falls back to English rather than to a key name or null', () {
      const l10n = AanganL10n.english;
      expect(
        l10n('Something nobody translated'),
        'Something nobody translated',
      );
    });

    test('substitutes placeholders', () {
      final l10n = AanganL10n.forLocale(const Locale('hi'));
      expect(l10n('{n} new leads', {'n': 3}), contains('3'));
    });

    test('picks the singular and the plural apart', () {
      const l10n = AanganL10n.english;
      expect(
        l10n.plural(
          1,
          '{n} quote ready to compare',
          '{n} quotes ready to compare',
        ),
        '1 quote ready to compare',
      );
      expect(
        l10n.plural(
          4,
          '{n} quote ready to compare',
          '{n} quotes ready to compare',
        ),
        '4 quotes ready to compare',
      );
    });

    test('resolves Hindi for a locale with a country attached', () {
      // A phone set to Hindi reports `hi_IN`, not `hi`.
      final l10n = AanganL10n.forLocale(const Locale('hi', 'IN'));
      expect(l10n.isHindi, isTrue);
      expect(l10n('Sign out'), isNot('Sign out'));
    });

    test('an unsupported locale gets English, not an empty screen', () {
      final l10n = AanganL10n.forLocale(const Locale('ta'));
      expect(l10n('Sign out'), 'Sign out');
    });
  });
}
