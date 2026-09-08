/// The placeholder tiles have to match the web's, exactly.
///
/// Almost nothing in the catalogue has been photographed, so these generated
/// tiles *are* the catalogue's visual identity. If the two implementations
/// drift, the same product is a warm diagonal on the web and a cool circle
/// motif on the phone — and nobody notices until the two are put side by side,
/// because each looks perfectly reasonable on its own.
///
/// The expected values below were produced by running the web's own `hash()`
/// from `packages/ui/src/media.tsx` under Node. They are not derived from the
/// Dart implementation, which would make this test a tautology.
library;

import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// seed -> the web's `hash(seed)`.
const _fromTheWeb = <String, int>{
  'x': 49524601,
  'wardrobe': 1335769669,
  'kitchen-modular': 1258003364,
  'p1': 1605446022,
  'Sri Balaji': 1641923050,
  'दरवाज़ा': 2062241714,
};

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AanganTheme.light,
      home: Scaffold(body: SizedBox(width: 300, height: 200, child: child)),
    ),
  );
}

void main() {
  group('the hash agrees with the web', () {
    _fromTheWeb.forEach((seed, expected) {
      test('hash(${seed.isEmpty ? "empty" : seed})', () {
        expect(mediaHash(seed), expected);
      });
    });

    test('an empty seed, which JavaScript treats specially', () {
      // `h` is only narrowed to int32 when an operator runs. With no characters
      // no operator runs, so the web returns the raw initial value rather than
      // its signed reading. Coercing on assignment made every other seed agree
      // and this one wrong by 37,305,226.
      expect(mediaHash(''), 2166136261);
    });

    test('the derived tile properties follow from it', () {
      // angle = 120 + h % 110, variant = h % 3, straight from media.tsx.
      expect(120 + (_fromTheWeb['wardrobe']! % 110), 189);
      expect(_fromTheWeb['wardrobe']! % 3, 1);
      expect(120 + (_fromTheWeb['p1']! % 110), 212);
      expect(_fromTheWeb['p1']! % 3, 0);
    });

    test('is stable, because tiles must not change between builds', () {
      expect(mediaHash('wardrobe'), mediaHash('wardrobe'));
    });

    test('separates seeds that differ by one character', () {
      expect(mediaHash('p1'), isNot(mediaHash('p2')));
    });
  });

  group('the widget', () {
    testWidgets('draws a tile for a ph: token, and fetches nothing', (
      tester,
    ) async {
      await _pump(
        tester,
        const AanganMedia(src: 'ph:furniture:wardrobe', alt: 'A wardrobe'),
      );

      expect(find.byType(CustomPaint), findsWidgets);
      // No network image widget at all — a placeholder must not cost a request.
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('a malformed token still draws rather than throwing', (
      tester,
    ) async {
      // `ph:` with nothing after it reaches the empty-seed path above.
      await _pump(tester, const AanganMedia(src: 'ph:', alt: 'Nothing'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('an unknown domain falls back to the neutral tint', (
      tester,
    ) async {
      await _pump(
        tester,
        const AanganMedia(src: 'ph:plumbing:x', alt: 'A trade we do not have'),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('is announced to a screen reader', (tester) async {
      // A catalogue of unlabelled tiles is unusable with TalkBack, which is
      // why `alt` is required rather than optional.
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const AanganMedia(src: 'ph:interior:kitchen', alt: 'Modular kitchen'),
      );

      expect(find.bySemanticsLabel('Modular kitchen'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('draws the label over a placeholder', (tester) async {
      await _pump(
        tester,
        const AanganMedia(
          src: 'ph:painting:p1',
          alt: 'Painting',
          label: 'Two-coat emulsion',
        ),
      );

      expect(find.text('Two-coat emulsion'), findsOneWidget);
    });
  });
}
