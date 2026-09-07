/// The design system's rules, asserted rather than written down.
///
/// These are not golden tests. Goldens come with the fonts (see
/// `packages/design/README.md` — Newsreader and Manrope are not bundled yet, so
/// a golden taken today would bake in Roboto and have to be thrown away). What
/// is here is the half that does not need pixels: the rules from DESIGN.md that
/// can be checked as values.
library;

import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('money', () {
    test('groups by lakh, not by thousand', () {
      // The failure MOBILE.md §7.7 names explicitly. A `NumberFormat` with the
      // wrong locale produces ₹450,000 here, which is wrong in a way an Indian
      // customer notices immediately and a European reviewer does not.
      expect(const Rupees(450000).formatted, '₹4,50,000');
      expect(const Rupees(1128000).formatted, '₹11,28,000');
      expect(const Rupees(96500).formatted, '₹96,500');
      expect(const Rupees(10000000).formatted, '₹1,00,00,000');
    });

    test('shows whole rupees, never paise', () {
      expect(const Rupees(450000).formatted, isNot(contains('.')));
      expect(const Rupees(1).formatted, '₹1');
      expect(const Rupees(0).formatted, '₹0');
    });

    test('abbreviates in lakh and crore, not in millions', () {
      expect(const Rupees(450000).short, '₹4.5L');
      expect(const Rupees(10000000).short, '₹1Cr');
      expect(const Rupees(96500).short, '₹96.5K');
      // Below a thousand there is nothing to abbreviate, so it stays exact.
      expect(const Rupees(940).short, '₹940');
    });

    test('is an int, so no amount can arrive fractional', () {
      // `Rupees` is an extension type over `int`. If this ever compiles against
      // a double, ₹1 can go missing in a rounding step nobody sees.
      const amount = Rupees(450000);
      expect(amount, isA<int>());
    });
  });

  group('the theme holds the no-shadow rule', () {
    final theme = AanganTheme.light;

    test('kills Material 3 surface tinting everywhere it can appear', () {
      // The scheme's `surfaceTint` covers most of it, but these components read
      // their own property first and would tint regardless.
      expect(theme.colorScheme.surfaceTint.a, 0);
      expect(theme.appBarTheme.surfaceTintColor, Colors.transparent);
      expect(theme.cardTheme.surfaceTintColor, Colors.transparent);
      expect(theme.bottomSheetTheme.surfaceTintColor, Colors.transparent);
      expect(theme.dialogTheme.surfaceTintColor, Colors.transparent);
      expect(theme.navigationBarTheme.surfaceTintColor, Colors.transparent);
      expect(theme.popupMenuTheme.surfaceTintColor, Colors.transparent);
    });

    test('leaves no component with an elevation', () {
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.appBarTheme.scrolledUnderElevation, 0);
      expect(theme.cardTheme.elevation, 0);
      expect(theme.bottomSheetTheme.elevation, 0);
      expect(theme.dialogTheme.elevation, 0);
      expect(theme.navigationBarTheme.elevation, 0);
    });

    test('pins the divider height, which defaults to 16', () {
      // Left alone, Flutter adds fifteen invisible pixels around every divider
      // and the vertical rhythm on every card quietly goes.
      expect(theme.dividerTheme.space, 1);
      expect(theme.dividerTheme.thickness, 1);
    });
  });

  group('the action colour is not ink', () {
    test('terracotta is primary, so framework defaults land correctly', () {
      // Loading the theme's own front matter verbatim puts ink in `primary` and
      // the action colour in `secondary`, and every FilledButton comes out
      // black. This asserts the remap survived.
      expect(AanganTheme.light.colorScheme.primary, AanganColors.terracotta);
      expect(AanganTheme.light.colorScheme.secondary, AanganColors.ink);
    });

    test('type is espresso, never pure black', () {
      expect(AanganColors.ink, isNot(const Color(0xFF000000)));
      expect(AanganTheme.light.textTheme.bodyMedium?.color, AanganColors.ink);
    });
  });

  group('shape', () {
    test('reserves the pill radius for status chips', () {
      // The system's one strong signal that a thing is metadata rather than
      // structure. A pill-shaped button destroys it.
      expect(Radii.small, 4.0);
      expect(Radii.panel, 6.0);
      expect(Radii.pill, greaterThan(1000));
    });

    testWidgets('a status pill is a pill and a card is not', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AanganTheme.light,
          home: const Scaffold(
            body: Column(
              children: [
                StatusPill('Verified', tone: StatusTone.verified),
                AanganCard(child: Text('structure')),
              ],
            ),
          ),
        ),
      );

      final pill = tester.widget<Container>(
        find.ancestor(of: find.text('VERIFIED'), matching: find.byType(Container)).first,
      );
      final pillShape = pill.decoration! as BoxDecoration;
      expect(pillShape.borderRadius, Radii.pillRadius);
      // A pill carries no border: it is a fill, not a surface.
      expect(pillShape.border, isNull);
    });
  });

  group('touch targets', () {
    testWidgets('controls are at least 48dp, not the renders 44', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AanganTheme.light,
          home: Scaffold(
            body: Center(
              child: FilledButton(onPressed: () {}, child: const Text('Tap')),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(FilledButton));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });
  });

  group('semantics', () {
    testWidgets('an uppercased pill still reads as a word', (tester) async {
      // Uppercasing is a display choice. A screen reader should say "verified",
      // not spell it out, so the original string stays in the semantics label.
      await tester.pumpWidget(
        MaterialApp(
          theme: AanganTheme.light,
          home: const Scaffold(
            body: StatusPill('Awaiting approval', tone: StatusTone.waiting),
          ),
        ),
      );

      expect(find.text('AWAITING APPROVAL'), findsOneWidget);
      final text = tester.widget<Text>(find.text('AWAITING APPROVAL'));
      expect(text.semanticsLabel, 'Awaiting approval');
    });
  });

  group('the gallery renders every state', () {
    testWidgets('every status tone builds', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AanganTheme.light,
          home: Scaffold(
            body: Wrap(
              children: [
                for (final tone in StatusTone.values) StatusPill(tone.name, tone: tone),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(StatusPill), findsNWidgets(StatusTone.values.length));
    });
  });
}
