/// The two boundaries this package must not cross.
///
/// Both are rules from MOBILE.md that a future change could break without
/// anything else noticing, which is exactly what a grep test is for.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Iterable<File> _sources() sync* {
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) yield entity;
  }
}

void main() {
  /// MOBILE.md §2: the two shells are separate packages over a shared core, so
  /// splitting into two binaries later is a build flavour and an entrypoint
  /// rather than a rewrite. That only stays true if they never import each
  /// other — and the document is explicit that the way it goes wrong is
  /// somebody doing it "temporarily".
  test('never imports the customer shell', () {
    final offenders = <String>[];

    for (final file in _sources()) {
      final source = file.readAsStringSync();
      if (source.contains('package:interiobee_feature_customer')) {
        offenders.add(file.path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'feature_vendor and feature_customer must stay independent',
    );
  });

  test('the dependency is absent from the manifest too', () {
    // An import is the symptom; the dependency is what makes it possible.
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec.contains('interiobee_feature_customer'), isFalse);
  });

  /// MOBILE.md §7.6: *"No dialer or SMS launcher anywhere in `feature_vendor`.
  /// Not for the customer, not 'just for the coordinator'."*
  ///
  /// The document asks for a grep over `tel:` **and `url_launcher`** — but it
  /// also asks, in §6.2, for a maps launcher on a released address, which needs
  /// `url_launcher`. Taken literally the two requirements contradict.
  ///
  /// So this bans the schemes that carry the actual risk, and the test below
  /// pins the one permitted use of the launcher. Banning the package instead
  /// would have meant dropping a feature the same document asks for.
  test('no dialer, SMS or messaging-app scheme anywhere', () {
    final offenders = <String>[];

    for (final file in _sources()) {
      final source = file.readAsStringSync();
      for (final scheme in const [
        'tel:',
        'sms:',
        'smsto:',
        'whatsapp:',
        'callto:',
      ]) {
        // Skip the prose in comments that explains the rule.
        final code = source
            .split('\n')
            .where((line) {
              final trimmed = line.trimLeft();
              return !trimmed.startsWith('//') && !trimmed.startsWith('///');
            })
            .join('\n');

        if (code.contains(scheme)) offenders.add('${file.path}: $scheme');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'a vendor must have no way to contact a customer directly',
    );
  });

  test('every launchUrl is a map, and there is only one', () {
    final uses = <String>[];

    for (final file in _sources()) {
      final source = file.readAsStringSync();
      if (source.contains('launchUrl(')) uses.add(file.path);
    }

    // If a second file starts launching URLs, this fails and somebody has to
    // justify it — which is the point.
    expect(uses.length, 1, reason: 'only the visit screen may launch a URL');
    expect(uses.single, endsWith('visits_screen.dart'));

    final source = File(uses.single).readAsStringSync();
    expect(
      source.contains('google.com/maps'),
      isTrue,
      reason: 'the only permitted launch is a map',
    );
  });

  /// The masking promise, restated at the layer that renders it.
  ///
  /// `MaskedClientSummary` has no field for a phone number, so a screen cannot
  /// print one. This catches the other direction: a screen reaching for the
  /// *unmasked* summary, which exists in the contract for the customer and ops
  /// surfaces and must never appear here.
  test('no screen reads an unmasked client', () {
    final offenders = <String>[];

    for (final file in _sources()) {
      final code = file
          .readAsStringSync()
          .split('\n')
          .where((line) {
            final trimmed = line.trimLeft();
            return !trimmed.startsWith('//') && !trimmed.startsWith('///');
          })
          .join('\n');

      // `ClientSummary` carries mobile and email. `MaskedClientSummary` does
      // not, and contains the former as a substring — so match on a word
      // boundary rather than a plain `contains`.
      if (RegExp(r'(?<!Masked)\bClientSummary\b').hasMatch(code)) {
        offenders.add(file.path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'the vendor shell may only ever see a MaskedClientSummary',
    );
  });
}
