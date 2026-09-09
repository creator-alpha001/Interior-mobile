/// A row of photographs, and the viewer behind it.
///
/// Used wherever the platform's evidence lives: stage proof on both sides of a
/// project, and a professional's portfolio. The web draws the same strip; the
/// tap-to-open viewer is the part that only makes sense on a phone, where a
/// 96dp thumbnail of a wardrobe carcass tells nobody anything.
///
/// **Why this exists at all is the platform's central claim.** Work counts as
/// done when somebody has looked at the evidence. Before this, the vendor's app
/// uploaded photographs and then showed neither side a single one — the
/// customer's progress screen said "3 photographs" where the photographs should
/// have been, which is a receipt, not evidence.
library;

import 'package:flutter/material.dart';

import 'l10n/l10n.dart';
import 'media.dart';
import 'theme.dart';
import 'tokens.dart';

/// One item in a strip. Deliberately not the generated `MediaAsset`: `design`
/// depends on Flutter and nothing else, which is what lets the gallery render
/// every state with no server.
@immutable
class MediaItem {
  const MediaItem({required this.url, required this.caption});

  final String url;

  /// What a screen reader announces, and the caption in the viewer.
  final String caption;
}

class MediaStrip extends StatelessWidget {
  const MediaStrip({
    super.key,
    required this.items,
    this.height = 96,
    this.width = 128,
  });

  final List<MediaItem> items;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: Space.xs),
        itemBuilder: (context, i) => SizedBox(
          width: width,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => showMediaViewer(context, items: items, initial: i),
              borderRadius: Radii.smallRadius,
              child: InterioBeeMedia(
                src: items[i].url,
                alt: items[i].caption,
                rounded: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens the photographs full screen, starting at [initial].
Future<void> showMediaViewer(
  BuildContext context, {
  required List<MediaItem> items,
  int initial = 0,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => _MediaViewer(items: items, initial: initial),
    ),
  );
}

class _MediaViewer extends StatefulWidget {
  const _MediaViewer({required this.items, required this.initial});

  final List<MediaItem> items;
  final int initial;

  @override
  State<_MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<_MediaViewer> {
  late final _controller = PageController(initialPage: widget.initial);
  late int _page = widget.initial;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Black, and the one place in the app that is.
      ///
      /// DESIGN.md's ground is lime-washed plaster, and every other screen
      /// honours it. A photograph judged against a warm off-white is a
      /// photograph judged against a colour cast, and this screen exists to
      /// let somebody judge whether a stage is finished.
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          context.t('{n} of {total}', {
            'n': _page + 1,
            'total': widget.items.length,
          }),
          style: context.text.titleMedium?.copyWith(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.items.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => InteractiveViewer(
                // Pinch to zoom. A stage photograph is often a joint or a
                // finish, and the detail being argued about is small.
                minScale: 1,
                maxScale: 4,
                child: InterioBeeMedia(
                  src: widget.items[i].url,
                  alt: widget.items[i].caption,
                  rounded: false,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          if (widget.items[_page].caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(Space.gutter),
              child: Text(
                widget.items[_page].caption,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ),
        ],
      ),
    );
  }
}
