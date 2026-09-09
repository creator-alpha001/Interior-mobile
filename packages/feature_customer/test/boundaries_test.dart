/// The boundaries this package must not cross.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Iterable<File> _sources() sync* {
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) yield entity;
  }
}

/// Source with comment lines removed, so prose explaining a rule does not trip
/// the check for that rule.
String _code(File file) => file
    .readAsStringSync()
    .split('\n')
    .where((line) {
      final trimmed = line.trimLeft();
      return !trimmed.startsWith('//') && !trimmed.startsWith('///');
    })
    .join('\n');

void main() {
  /// MOBILE.md §2: the two shells are separate packages over a shared core, so
  /// splitting into two binaries later is a build flavour and an entrypoint
  /// rather than a rewrite. That only holds if they never import each other —
  /// and the document is explicit that the way it goes wrong is somebody doing
  /// it "temporarily".
  test('never imports the vendor shell', () {
    final offenders = [
      for (final file in _sources())
        if (file.readAsStringSync().contains('package:interiobee_feature_vendor'))
          file.path,
    ];

    expect(
      offenders,
      isEmpty,
      reason: 'feature_customer and feature_vendor must stay independent',
    );
  });

  test('the dependency is absent from the manifest too', () {
    // An import is the symptom; the dependency is what makes it possible.
    expect(
      File('pubspec.yaml').readAsStringSync().contains('interiobee_feature_vendor'),
      isFalse,
    );
  });

  /// The customer sees their own contact details and nobody else's.
  ///
  /// `MaskedClientSummary` is the *vendor*-facing shape. Its appearance here
  /// would mean a customer screen had started rendering somebody else's job.
  test('never renders a masked client', () {
    final offenders = [
      for (final file in _sources())
        if (_code(file).contains('MaskedClientSummary')) file.path,
    ];

    expect(offenders, isEmpty);
  });

  /// Nothing in this app arranges a payment, and nothing may imply one.
  ///
  /// Payments are off-platform: terms are recorded, not enforced. This matters
  /// more here than anywhere, because the prototype the whole design language
  /// came from was built around an escrow service — money held in a vault,
  /// tranches released by the client, a mediator on call. Every one of those
  /// devices was deliberately not drawn. A screen promising escrow would be the
  /// single most damaging sentence in the product.
  test('promises no payment handling', () {
    final offenders = <String>[];

    for (final file in _sources()) {
      final code = _code(file).toLowerCase();
      for (final claim in const [
        'escrow',
        'we hold your',
        'release funds',
        'pay now',
        'held in trust',
      ]) {
        if (code.contains(claim)) offenders.add('${file.path}: $claim');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'payments are off-platform; the app must not imply otherwise',
    );
  });

  /// A stage is done when somebody at InterioBee checked it.
  ///
  /// The progress screen is read-only by design, and an absence is easy to
  /// erode: an "approve" button looks like an obvious improvement to anybody
  /// who has not read why it is missing.
  test('the progress screen offers no approval control', () {
    /// Ops approve stages; the customer watches. That is the platform rule and
    /// this is the screen most likely to be handed an "Approve" button by
    /// somebody who has not read it.
    ///
    /// The check used to be "no FilledButton anywhere in the file", which was
    /// a fair proxy while the screen was purely read-only and became a false
    /// positive the moment it grew a legitimate primary action — leaving a
    /// review on a *finished* project, which is not an approval of anything.
    ///
    /// So it now tests the rule rather than a proxy for it: no approval verb
    /// anywhere, and no button at all inside the stage row, which is where an
    /// approve control would actually be put.
    final code = _code(File('lib/src/projects_screen.dart')).toLowerCase();

    for (final verb in const [
      'approvestage',
      'approvemilestone',
      'markapproved',
      'verifymilestone',
      'accepstage',
      'signoff',
    ]) {
      expect(code.contains(verb), isFalse, reason: 'found $verb');
    }

    final stage = code.substring(code.indexOf('class _stage'));
    for (final control in const [
      'filledbutton',
      'elevatedbutton',
      'outlinedbutton',
      'textbutton',
      'checkbox',
      'switch(',
    ]) {
      expect(
        stage.contains(control),
        isFalse,
        reason: 'found $control inside the stage row, where approval would go',
      );
    }
  });
}
