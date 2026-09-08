/// Catalogue and portfolio imagery.
///
/// A direct port of `packages/ui/src/media.tsx`, and the port has to be exact
/// rather than approximate. Both platforms render the same catalogue from the
/// same rows, so a product whose tile is a warm diagonal on the web and a cool
/// circle motif on the phone reads as two different products — and the tiles
/// are the only thing distinguishing most of the catalogue, because almost none
/// of it has been photographed yet.
///
/// **Most sources are not photographs.** A `ph:<domain>:<seed>` token means
/// "nobody has taken this picture", and the answer is a designed, deterministic
/// tile rather than a broken image or a grey rectangle. The web's home page puts
/// the reasoning better than a comment here could:
///
/// > Ruled cells rather than four image cards. The images here were
/// > placeholders standing in for photographs nobody has taken, and a trade is
/// > better identified by its name and a colour than by a gradient pretending
/// > to be a room.
///
/// When real photography lands it changes the URLs in the data layer and
/// nothing here: anything that is not a `ph:` token is fetched and cached.
library;

import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'theme.dart';
import 'tokens.dart';

/// The per-trade tints, matching `domainTint` in `media.tsx` exactly.
const _domainTint = <String, (Color, Color, Color)>{
  'interior': (Color(0xFF8A6B4F), Color(0xFFC9B49B), Color(0xFFEFE6DA)),
  'furniture': (Color(0xFF7A6A4A), Color(0xFFC2B189), Color(0xFFEEE8D8)),
  'fabrication': (Color(0xFF5A6472), Color(0xFFA3ADB9), Color(0xFFE4E8ED)),
  'painting': (Color(0xFF4B6B63), Color(0xFF9DBDB2), Color(0xFFE3EEEA)),
  'default': (Color(0xFF7C756A), Color(0xFFB7B0A4), Color(0xFFEAE6DE)),
};

/// Coerces to a signed 32-bit integer, as JavaScript does implicitly.
///
/// Dart's `int` is 64-bit, so without this the hash diverges from the web's on
/// the very first character and every tile in the catalogue comes out a
/// different colour and motif from its counterpart.
int _toInt32(int value) {
  final masked = value & 0xFFFFFFFF;
  return masked >= 0x80000000 ? masked - 0x100000000 : masked;
}

/// FNV-1a, matching `hash()` in `media.tsx`.
///
/// `media_test.dart` checks a handful of seeds against values computed by the
/// web's own function, because "looks about right" is not a comparison and the
/// two implementations drifting apart would be invisible until somebody put
/// the two catalogues side by side.
int mediaHash(String seed) {
  // Deliberately *not* coerced here. JavaScript narrows to int32 when an
  // operator runs, not on assignment, so an empty seed returns the raw
  // 2166136261 rather than its signed reading. Coercing up front made every
  // hash agree except that one — the case a caller reaches by passing `ph:`
  // with nothing after it.
  var h = 2166136261;
  for (final unit in seed.codeUnits) {
    // `h ^= c` is `ToInt32(h) ^ ToInt32(c)`.
    h = _toInt32(_toInt32(h) ^ unit);
    // `Math.imul` — a 32-bit multiply that discards the overflow.
    h = _toInt32(h * 16777619);
  }
  return h.abs();
}

/// The tile a `ph:` token describes, worked out once.
@immutable
class _Placeholder {
  const _Placeholder({
    required this.dark,
    required this.mid,
    required this.light,
    required this.angle,
    required this.bloom1,
    required this.bloom2,
    required this.variant,
  });

  factory _Placeholder.fromToken(String src) {
    final parts = src.split(':');
    final domain = parts.length > 1 && parts[1].isNotEmpty
        ? parts[1]
        : 'default';
    final seed = parts.length > 2 && parts[2].isNotEmpty ? parts[2] : 'x';

    final (dark, mid, light) = _domainTint[domain] ?? _domainTint['default']!;
    final h = mediaHash(seed);

    return _Placeholder(
      dark: dark,
      mid: mid,
      light: light,
      angle: 120 + (h % 110),
      bloom1: Offset((18 + (h % 46)) / 100, (12 + ((h >> 3) % 50)) / 100),
      bloom2: Offset(
        (55 + ((h >> 6) % 35)) / 100,
        (60 + ((h >> 9) % 30)) / 100,
      ),
      variant: h % 3,
    );
  }

  final Color dark;
  final Color mid;
  final Color light;
  final int angle;
  final Offset bloom1;
  final Offset bloom2;
  final int variant;
}

/// One image, however it happens to be sourced.
class AanganMedia extends StatelessWidget {
  const AanganMedia({
    super.key,
    required this.src,
    required this.alt,
    this.label,
    this.rounded = true,
    this.fit = BoxFit.cover,
  });

  /// A `ph:domain:seed` token, or an ordinary image URL.
  final String src;

  /// Announced to a screen reader. Required rather than optional: a catalogue
  /// of unlabelled tiles is unusable with TalkBack, and making it optional is
  /// how it ends up empty.
  final String alt;

  /// Drawn over a placeholder tile only, as on the web.
  final String? label;

  final bool rounded;
  final BoxFit fit;

  bool get _isPlaceholder => src.startsWith('ph:');

  @override
  Widget build(BuildContext context) {
    final radius = rounded ? Radii.panelRadius : BorderRadius.zero;

    return ClipRRect(
      borderRadius: radius,
      child: Semantics(
        image: true,
        label: alt,
        child: _isPlaceholder
            ? _Tile(placeholder: _Placeholder.fromToken(src), label: label)
            : CachedNetworkImage(
                imageUrl: src,
                fit: fit,
                width: double.infinity,
                height: double.infinity,
                // A flat wash of the surface tint while it arrives — not a
                // spinner. A grid of eight spinners is noisier than the images.
                placeholder: (context, _) =>
                    ColoredBox(color: context.colors.surfaceContainer),

                /// A failed fetch falls back to the designed tile.
                ///
                /// Never a broken-image glyph: on the connection this audience
                /// has, a photograph failing is ordinary, and a row of broken
                /// icons reads as an app that is itself broken.
                errorWidget: (context, url, error) => _Tile(
                  placeholder: _Placeholder.fromToken('ph:default:$url'),
                  label: label,
                ),
              ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.placeholder, this.label});

  final _Placeholder placeholder;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _TilePainter(placeholder)),
        if (label != null)
          Positioned(
            left: Space.sm,
            right: Space.sm,
            bottom: Space.sm,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.xs,
                  vertical: Space.xxs,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: Radii.pillRadius,
                ),
                child: Text(
                  label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Draws what the web draws with a gradient, two radials and an inline SVG.
class _TilePainter extends CustomPainter {
  const _TilePainter(this.tile);

  final _Placeholder tile;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // The base gradient. CSS measures its angle clockwise from "to top";
    // Flutter takes begin and end points, so the direction is derived rather
    // than guessed — 120°–230° all point down and across, as on the web.
    final radians = (tile.angle - 90) * math.pi / 180;
    final direction = Offset(math.cos(radians), math.sin(radians));
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(-direction.dx, -direction.dy),
          end: Alignment(direction.dx, direction.dy),
          colors: [tile.dark, tile.mid, tile.light],
          stops: const [0, 0.52, 1],
        ).createShader(rect),
    );

    // Soft light blooms — these are what keep a tile from reading as a flat
    // block of colour, and are the reason the placeholder passes as a design
    // choice rather than as a missing asset.
    _bloom(canvas, rect, tile.bloom1, 0.60, 0.55, Colors.white, 0.42);
    _bloom(canvas, rect, tile.bloom2, 0.45, 0.45, Colors.black, 0.20);

    _motif(canvas, size);
  }

  void _bloom(
    Canvas canvas,
    Rect rect,
    Offset at,
    double rx,
    double ry,
    Color colour,
    double alpha,
  ) {
    final centre = Offset(rect.width * at.dx, rect.height * at.dy);
    final radius = math.max(rect.width * rx, rect.height * ry);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            colour.withValues(alpha: alpha),
            colour.withValues(alpha: 0),
          ],
          stops: const [0, 0.7],
        ).createShader(Rect.fromCircle(center: centre, radius: radius)),
    );
  }

  /// The quiet geometric motif, on the web's own 200x140 viewBox.
  ///
  /// Scaled to cover rather than to fit, matching `xMidYMid slice`, so the
  /// spacing of the lines stays constant instead of stretching with the card.
  void _motif(Canvas canvas, Size size) {
    const view = Size(200, 140);
    final scale = math.max(size.width / view.width, size.height / view.height);

    canvas
      ..save()
      ..clipRect(Offset.zero & size)
      ..translate(
        (size.width - view.width * scale) / 2,
        (size.height - view.height * scale) / 2,
      )
      ..scale(scale);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = Colors.white.withValues(alpha: 0.28);

    switch (tile.variant) {
      case 0:
        for (var i = 0; i < 9; i++) {
          canvas.drawLine(
            Offset(i * 24 - 20, -10),
            Offset(i * 24 + 30, 150),
            stroke,
          );
        }
      case 1:
        for (var i = 0; i < 5; i++) {
          canvas.drawCircle(Offset(40 + i * 32, 70), 12 + (i % 3) * 9, stroke);
        }
      default:
        for (var i = 0; i < 6; i++) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(12 + i * 31, 30 + (i % 2) * 18, 22, 60),
              const Radius.circular(3),
            ),
            stroke,
          );
        }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_TilePainter old) => old.tile != tile;
}
