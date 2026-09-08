/// The accessibility pass, as assertions.
///
/// M12's checklist includes an accessibility pass and `textScale` 1.3 goldens.
/// The goldens are blocked — Newsreader and Manrope are not bundled, so a
/// golden taken today would bake in Roboto and be thrown away the day the fonts
/// land (see README). Everything a golden *would* have caught about layout at
/// large text is checked here instead, without pixels.
library;

import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double textScale = 1.0,
  Size size = const Size(360, 640),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AanganTheme.light,
      builder: (context, widget) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: widget!,
      ),
      home: Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('touch targets', () {
    /// 48dp, not the renders' 44.
    ///
    /// DESIGN.md §3.3: the 44px control height in the reference renders is a
    /// web figure. Android wants 48dp and iOS 44pt, so 48 satisfies both.
    testWidgets('every button clears 48dp, even on a small phone', (
      tester,
    ) async {
      await _pump(
        tester,
        Column(
          children: [
            FilledButton(onPressed: () {}, child: const Text('Primary')),
            OutlinedButton(onPressed: () {}, child: const Text('Secondary')),
            TextButton(onPressed: () {}, child: const Text('Tertiary')),
          ],
        ),
      );

      for (final type in [FilledButton, OutlinedButton, TextButton]) {
        final size = tester.getSize(find.byType(type));
        expect(
          size.height,
          greaterThanOrEqualTo(48.0),
          reason: '$type is below the minimum tap target',
        );
      }
    });

    testWidgets('an input clears it too', (tester) async {
      await _pump(
        tester,
        const TextField(decoration: InputDecoration(labelText: 'Locality')),
      );

      expect(
        tester.getSize(find.byType(TextField)).height,
        greaterThanOrEqualTo(48.0),
      );
    });
  });

  group('text scaling', () {
    /// The case DESIGN.md §3.9 names: *"Newsreader at 30px with 1.3 scaling is
    /// where a headline breaks its box."*
    testWidgets('a card survives 1.3 on a 360dp phone', (tester) async {
      await _pump(
        tester,
        const SingleChildScrollView(
          child: AanganCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Compare quotes and choose a professional'),
                SizedBox(height: Space.xs),
                Text(
                  'Nothing moves until you do. The ratings beside each price '
                  'are for this trade only.',
                ),
              ],
            ),
          ),
        ),
        textScale: 1.3,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('the action panel survives 1.3', (tester) async {
      await _pump(
        tester,
        const SingleChildScrollView(
          child: ActionRequired(
            title: 'Three quotes are ready',
            body:
                'Compare them and choose a professional. Nothing moves '
                'until you do.',
          ),
        ),
        textScale: 1.3,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('a status pill does not clip its own label', (tester) async {
      await _pump(
        tester,
        const Align(
          alignment: Alignment.topLeft,
          child: StatusPill('Awaiting approval', tone: StatusTone.waiting),
        ),
        textScale: 1.3,
      );

      expect(tester.takeException(), isNull);
      // The pill grows with the text rather than cropping it.
      expect(tester.getSize(find.byType(StatusPill)).width, greaterThan(80));
    });

    testWidgets('a row of buttons wraps rather than overflowing', (
      tester,
    ) async {
      // The failure a golden would have caught: two buttons side by side at
      // 1.3 on a 360dp phone.
      await _pump(
        tester,
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () {},
                child: const Text('Camera'),
              ),
            ),
            const SizedBox(width: Space.xs),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Gallery'),
              ),
            ),
          ],
        ),
        textScale: 1.3,
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('semantics', () {
    testWidgets('an uppercased pill still reads as a word', (tester) async {
      // Uppercasing is a display choice. A screen reader should say
      // "verified", not spell it out.
      await _pump(
        tester,
        const StatusPill('Verified', tone: StatusTone.verified),
      );

      final text = tester.widget<Text>(find.text('VERIFIED'));
      expect(text.semanticsLabel, 'Verified');
    });

    testWidgets('a section eyebrow reads as a word too', (tester) async {
      await _pump(
        tester,
        const SectionHead('Status', eyebrow: 'Colour carries meaning'),
      );

      final text = tester.widget<Text>(find.text('COLOUR CARRIES MEANING'));
      expect(text.semanticsLabel, 'Colour carries meaning');
    });

    testWidgets('the code field is one field, so it is announced once', (
      tester,
    ) async {
      // Six boxes would be six unlabelled fields to a screen reader, which is
      // the accessibility half of the same argument that makes paste work.
      await _pump(tester, OtpField(autofocus: false, onCompleted: (_) {}));
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('contrast', () {
    /// The outline colour is for non-text only.
    ///
    /// DESIGN.md gives it 3.4:1 on limestone, which passes for a border and
    /// fails for anything readable. Body copy uses `onSurfaceVariant`.
    testWidgets('secondary body text uses the readable ink, not the outline', (
      tester,
    ) async {
      await _pump(
        tester,
        Builder(
          builder: (context) => Text(
            'Meta, timestamps, captions',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style?.color, AanganColors.inkMuted);
      expect(text.style?.color, isNot(AanganColors.outline));
    });

    test('the muted ink is materially darker than the outline', () {
      // A cheap proxy for the contrast ratio: relative luminance, which is what
      // the ratio is computed from.
      expect(
        AanganColors.inkMuted.computeLuminance(),
        lessThan(AanganColors.outline.computeLuminance()),
      );
    });
  });
}
