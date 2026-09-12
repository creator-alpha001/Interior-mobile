/// What a vendor wrote about a job, rendered on the phone.
///
/// Their details are HTML: the website's editor produces it, and the API
/// sanitises it to a small allowlist — paragraphs, bold, italic, two kinds of
/// list, a subheading, a blockquote and links — before it is ever stored. So
/// the phone renders those tags and nothing else exists to render.
///
/// The styling is the app's own rather than the package's defaults, because a
/// vendor's description sits inside our cards: body text in the app's size and
/// colour, and a subheading that does not shout over the card's own title.
library;

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import 'theme.dart';
import 'tokens.dart';

class InterioBeeHtml extends StatelessWidget {
  const InterioBeeHtml(this.html, {super.key});

  final String html;

  @override
  Widget build(BuildContext context) {
    final body = context.text.bodyMedium?.copyWith(
      color: context.colors.onSurfaceVariant,
    );

    return HtmlWidget(
      html,
      textStyle: body,
      customStylesBuilder: (element) => switch (element.localName) {
        // The allowlist's two heading levels. Ink rather than muted, and only
        // a little larger: this is a heading inside somebody's card.
        'h3' || 'h4' => const {'font-size': '15px', 'font-weight': '600'},
        'blockquote' => const {'margin': '0', 'padding-left': '12px'},
        'ul' || 'ol' => const {'margin': '4px 0', 'padding-left': '20px'},
        _ => null,
      },

      /// Links open outside the app, and only the schemes the API allows can
      /// reach here — `javascript:` is stripped on the way in.
      onTapUrl: (url) async => false,

      // No images: photographs are media rows with their own uploads, and the
      // allowlist has no `img` for exactly that reason.
      rebuildTriggers: [html],
    );
  }
}

/// The short lines under a job, as the bulleted list they are.
class InterioBeeHighlights extends StatelessWidget {
  const InterioBeeHighlights(this.lines, {super.key});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.xxs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // A bullet, not copy: the same character in both languages.
                  '•',
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(width: Space.xs),
                Expanded(child: Text(line, style: context.text.bodyMedium)),
              ],
            ),
          ),
      ],
    );
  }
}
