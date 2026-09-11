/// The Decora Shine logo.
///
/// The same artwork the website shows, cut into its two halves: the house mark
/// and the wordmark. Side by side rather than the stacked original, which at
/// app-bar height would shrink the name past reading.
library;

import 'package:flutter/material.dart';

class DecoraShineLogo extends StatelessWidget {
  const DecoraShineLogo({
    super.key,
    this.height = 36,
    this.showWordmark = true,
  });

  /// The height of the house mark. The wordmark is sized from it.
  final double height;

  /// False for the mark alone, where there is no room for the name.
  final bool showWordmark;

  static const _package = 'interiobee_design';

  @override
  Widget build(BuildContext context) {
    // One image to a screen reader, named, rather than two unlabelled ones.
    return Semantics(
      image: true,
      label: 'Decora Shine',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/brand/decora-shine-mark.png',
              package: _package,
              height: height,
              fit: BoxFit.contain,
            ),
            if (showWordmark) ...[
              SizedBox(width: height * 0.22),
              // The artwork's own proportions: the name at a little over half
              // the mark's height reads as one lockup, as in the web header.
              Image.asset(
                'assets/brand/decora-shine-wordmark.png',
                package: _package,
                height: height * 0.56,
                fit: BoxFit.contain,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
