/// The blog: a list, a filter, and a post.
///
/// MOBILE.md's open question 3 called this *"the largest piece of M11 with the
/// least in-app value; a native blog exists mainly for deep links from search"*
/// — and that framing shapes what is built here rather than being an argument
/// against building it. The answer came back yes, so this is a reader, not a
/// magazine:
///
///   * **The list is the index.** No hero, no featured carousel, no infinite
///     grid of cover images on a metered connection. A title, the trade it is
///     about, and how long it takes to read.
///   * **The post is the point.** One column, generous measure, and the body
///     rendered as the prose it is.
///   * **It ends where the product begins.** Somebody who has just read about
///     modular kitchens is closer to a requirement than anybody else on the
///     app, and the post says so once, at the bottom, rather than interrupting.
///
/// Cover images are deliberately absent from the list and present on the post.
/// A list of twenty covers is the single most expensive screen the app could
/// draw, and on the connection this audience actually has it would be the
/// slowest thing here by an order of magnitude.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'providers.dart';

/// The chosen category slug, or null for everything.
final blogCategoryProvider = StateProvider<String?>((ref) => null);

final blogCategoriesProvider = FutureProvider<List<BlogCategory>>(
  (ref) => ref.watch(customerApiProvider).public.listPostCategories().orThrow(),
);

final blogPostsProvider = FutureProvider<GetPostsResponse>((ref) {
  final category = ref.watch(blogCategoryProvider);
  return ref
      .watch(customerApiProvider)
      .public
      .listPosts(category: category, limit: 24)
      .orThrow();
});

final blogPostProvider = FutureProvider.family<BlogPostView, String>(
  (ref, slug) =>
      ref.watch(customerApiProvider).public.getPost(slug: slug).orThrow(),
);

final relatedPostsProvider = FutureProvider.family<List<BlogPostView>, String>(
  (ref, id) =>
      ref.watch(customerApiProvider).public.listRelatedPosts(id: id).orThrow(),
);

class BlogScreen extends ConsumerWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(blogPostsProvider);
    final categories = ref.watch(blogCategoriesProvider);
    final selected = ref.watch(blogCategoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.t('Guides'))),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.gutter,
                Space.sm,
                Space.gutter,
                0,
              ),
              child: Text(
                context.t(
                  'What things cost, how long they take, and what to ask '
                  'before you agree to any of it.',
                ),
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),

            /// The filter degrades rather than blocking.
            ///
            /// If categories cannot be fetched the list still works, because
            /// "everything" is the default and the only one most people use.
            categories.maybeWhen(
              data: (list) => _Categories(
                categories: list,
                selected: selected,
                onSelect: (slug) =>
                    ref.read(blogCategoryProvider.notifier).state = slug,
              ),
              orElse: () => const SizedBox(height: Space.sm),
            ),

            Expanded(
              child: AsyncView(
                value: posts,
                onRetry: () => ref.invalidate(blogPostsProvider),
                data: (page) => page.items.isEmpty
                    ? EmptyState(
                        title: context.t('Nothing here yet'),
                        body: context.t(
                          'No guides in this section. Try another, or come '
                          'back — we add to these.',
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async =>
                            ref.invalidate(blogPostsProvider),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Space.gutter,
                            vertical: Space.xs,
                          ),
                          itemCount: page.items.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: Space.sm),
                          itemBuilder: (context, i) =>
                              PostCard(view: page.items[i]),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Categories extends StatelessWidget {
  const _Categories({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  final List<BlogCategory> categories;
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TapTarget.minimum + Space.sm,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: Space.gutter,
          vertical: Space.xs,
        ),
        children: [
          _Chip(
            label: context.t('All'),
            selected: selected == null,
            onTap: () => onSelect(null),
          ),
          for (final category in categories) ...[
            const SizedBox(width: Space.xs),
            _Chip(
              // Category names are the API's words, like trade names.
              label: category.name,
              selected: selected == category.slug,
              onTap: () => onSelect(category.slug),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.smallRadius,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: Space.md),
          decoration: BoxDecoration(
            color: selected
                ? context.colors.primaryContainer
                : context.colors.surfaceContainer,
            borderRadius: Radii.smallRadius,
            border: Border.all(
              color: selected
                  ? context.colors.primary
                  : context.palette.hairline,
            ),
          ),
          child: Text(
            label,
            style: context.text.titleMedium?.copyWith(
              color: selected
                  ? context.colors.onPrimaryContainer
                  : context.colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.view});

  final BlogPostView view;

  @override
  Widget build(BuildContext context) {
    return InterioBeeCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PostScreen(slug: view.post.slug)),
      ),
      padding: const EdgeInsets.all(Space.cardPaddingWide),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Travertine: this is metadata, not a status.
              StatusPill(view.category.name, tone: StatusTone.neutral),
              if (view.domain != null) ...[
                const SizedBox(width: Space.xxs),
                StatusPill(view.domain!.name, tone: StatusTone.neutral),
              ],
            ],
          ),
          const SizedBox(height: Space.xs),
          Text(view.post.title, style: context.text.headlineSmall),
          const SizedBox(height: Space.xxs),
          Text(
            view.post.excerpt,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Space.xs),
          Text(
            context.t('{n} min read', {'n': view.post.readingMinutes}),
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// One post.
///
/// Reached by tap from the list, and by deep link from search — which is why it
/// takes a slug rather than a loaded view. A notification or a link opens this
/// screen cold, with nothing in memory.
class PostScreen extends ConsumerWidget {
  const PostScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(blogPostProvider(slug));

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: AsyncView(
          value: post,
          onRetry: () => ref.invalidate(blogPostProvider(slug)),
          data: (view) => ListView(
            padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
            children: [
              const SizedBox(height: Space.sm),
              StatusPill(view.category.name, tone: StatusTone.neutral),
              const SizedBox(height: Space.sm),
              Text(view.post.title, style: context.text.displayLarge),
              const SizedBox(height: Space.sm),
              Text(
                // The author's name and role are records, not copy.
                context.t('{author}, {role} · {n} min read', {
                  'author': view.post.authorName,
                  'role': view.post.authorRole,
                  'n': view.post.readingMinutes,
                }),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),

              /// The cover, on the post and not in the list.
              ///
              /// Twenty covers is the most expensive screen in the app, and
              /// the list is better as a column of headlines. One cover, on
              /// the post somebody chose to open, costs one request.
              if (view.post.coverImageUrl.isNotEmpty) ...[
                const SizedBox(height: Space.md),
                AspectRatio(
                  aspectRatio: 3 / 2,
                  child: InterioBeeMedia(
                    src: view.post.coverImageUrl,
                    alt: view.post.title,
                  ),
                ),
              ],

              const SizedBox(height: Space.lg),
              Text(
                view.post.excerpt,
                style: context.text.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Space.md),
              const InterioBeeDivider(inset: 0),
              const SizedBox(height: Space.md),

              /// The body, as prose.
              ///
              /// Rendered as text rather than through a Markdown package on
              /// purpose: adding a renderer means adding its whole styling
              /// surface, and the first thing it would do is ignore the type
              /// scale. Paragraph breaks are what the body actually uses.
              for (final paragraph in _paragraphs(view.post.body))
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.md),
                  child: Text(paragraph, style: context.text.bodyLarge),
                ),

              if (view.tags.isNotEmpty) ...[
                const SizedBox(height: Space.xs),
                Wrap(
                  spacing: Space.xxs,
                  runSpacing: Space.xxs,
                  children: [
                    for (final tag in view.tags)
                      StatusPill(tag, tone: StatusTone.neutral),
                  ],
                ),
              ],

              /// Said once, at the end.
              ///
              /// Somebody who has read a guide about this trade is the closest
              /// thing the app has to an intent signal, and interrupting the
              /// article to say so would cost more than it earns.
              const SizedBox(height: Space.lg),
              InterioBeeCard(
                padding: const EdgeInsets.all(Space.cardPaddingWide),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t('Thinking about this for your own place?'),
                      style: context.text.titleLarge,
                    ),
                    const SizedBox(height: Space.xxs),
                    Text(
                      context.t(
                        'Tell us what you need and we will find you three '
                        'verified professionals. It costs nothing to ask.',
                      ),
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              _Related(id: view.post.id),
              const SizedBox(height: Space.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  /// Splits the body on blank lines, which is how it is written.
  static List<String> _paragraphs(String body) => body
      .split(RegExp(r'\n\s*\n'))
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();
}

class _Related extends ConsumerWidget {
  const _Related({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final related = ref.watch(relatedPostsProvider(id));

    /// Absent rather than broken when it fails.
    ///
    /// A "related posts" section that renders an error box under an article
    /// somebody just finished is worse than one that quietly is not there.
    return related.maybeWhen(
      data: (list) => list.isEmpty
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHead(
                  context.t('Read next'),
                  eyebrow: context.t('Related'),
                ),
                for (final view in list.take(3)) ...[
                  PostCard(view: view),
                  const SizedBox(height: Space.xs),
                ],
              ],
            ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}
