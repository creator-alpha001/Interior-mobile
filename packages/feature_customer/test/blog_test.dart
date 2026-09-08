/// The blog, and the three choices that make it a reader rather than a
/// magazine.
///
/// MOBILE.md called this *"the largest piece of M11 with the least in-app
/// value; a native blog exists mainly for deep links from search"* — and
/// answering the open question yes does not make that framing wrong. It shapes
/// what got built:
///
///   * **No cover images in the list.** Twenty of them is the most expensive
///     screen this app could draw, on the connection this audience has.
///   * **A post is reachable by slug alone**, because a deep link from search
///     opens it cold with nothing in memory.
///   * **The pitch is at the end, once.** Somebody who has just read about
///     modular kitchens is the closest thing to an intent signal this app gets,
///     and interrupting the article to say so would cost more than it earns.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:aangan_feature_customer/aangan_feature_customer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _category = BlogCategory(
  createdAt: '2026-01-01T00:00:00.000Z',
  updatedAt: '2026-01-01T00:00:00.000Z',
  deletedAt: null,
  id: 'cat-1',
  name: 'Costs',
  slug: 'costs',
  description: 'What things actually cost',
);

const _post = BlogPost(
  createdAt: '2026-01-01T00:00:00.000Z',
  updatedAt: '2026-01-01T00:00:00.000Z',
  deletedAt: null,
  id: 'post-1',
  title: 'What a modular kitchen costs in Lucknow',
  slug: 'modular-kitchen-cost-lucknow',
  excerpt: 'Carcass, shutters, hardware and counter — where the money goes.',
  body:
      'The carcass is the box.\n\n'
      'The shutters are what you see.\n\n'
      'Hardware is where a quote quietly doubles.',
  coverImageUrl: 'https://example.test/kitchen.jpg',
  authorName: 'Kavita Bisht',
  authorRole: 'Coordinator',
  categoryId: 'cat-1',
  tagIds: ['kitchen'],
  domainId: null,
  status: BlogPostStatus.published,
  publishedAt: '2026-02-01T00:00:00.000Z',
  readingMinutes: 6,
  seoTitle: '',
  seoDescription: '',
  ogImageUrl: null,
  isFeatured: false,
);

const _view = BlogPostView(
  post: _post,
  category: _category,
  tags: ['kitchen'],
  domain: null,
);

Future<void> _pump(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(1200, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        blogPostsProvider.overrideWith(
          (ref) async => const GetPostsResponse(
            items: [_view],
            nextCursor: null,
            total: 1,
          ),
        ),
        blogCategoriesProvider.overrideWith((ref) async => [_category]),
        blogPostProvider.overrideWith((ref, slug) async => _view),
        relatedPostsProvider.overrideWith((ref, id) async => []),
      ],
      child: MaterialApp(theme: AanganTheme.light, home: home),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('the list', () {
    testWidgets('shows the title, the trade and the reading time', (
      tester,
    ) async {
      await _pump(tester, const BlogScreen());

      expect(
        find.text('What a modular kitchen costs in Lucknow'),
        findsOneWidget,
      );
      expect(find.text('6 min read'), findsOneWidget);
    });

    testWidgets('draws no cover images', (tester) async {
      // The deliberate omission, and the one most likely to be "fixed" by
      // somebody who has not thought about the connection.
      await _pump(tester, const BlogScreen());

      expect(find.byType(Image), findsNothing);
      expect(find.byType(FadeInImage), findsNothing);
    });

    testWidgets('offers the categories, with All selected first', (
      tester,
    ) async {
      await _pump(tester, const BlogScreen());

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Costs'), findsWidgets);
    });
  });

  group('a post', () {
    testWidgets('opens from a slug alone, as a deep link does', (tester) async {
      // No BlogPostView passed in — only the slug, exactly as a link from
      // search would arrive.
      await _pump(
        tester,
        const PostScreen(slug: 'modular-kitchen-cost-lucknow'),
      );

      expect(
        find.text('What a modular kitchen costs in Lucknow'),
        findsOneWidget,
      );
    });

    testWidgets('renders the body as separate paragraphs', (tester) async {
      await _pump(
        tester,
        const PostScreen(slug: 'modular-kitchen-cost-lucknow'),
      );

      // Three paragraphs, split on the blank lines the body is written with —
      // not one block with the newlines collapsed.
      expect(find.text('The carcass is the box.'), findsOneWidget);
      expect(find.text('The shutters are what you see.'), findsOneWidget);
      expect(
        find.text('Hardware is where a quote quietly doubles.'),
        findsOneWidget,
      );
    });

    testWidgets('attributes the author with their role', (tester) async {
      await _pump(
        tester,
        const PostScreen(slug: 'modular-kitchen-cost-lucknow'),
      );

      expect(
        find.text('Kavita Bisht, Coordinator · 6 min read'),
        findsOneWidget,
      );
    });

    testWidgets('makes its pitch once, at the end', (tester) async {
      await _pump(
        tester,
        const PostScreen(slug: 'modular-kitchen-cost-lucknow'),
      );

      expect(
        find.text('Thinking about this for your own place?'),
        findsOneWidget,
      );
    });

    testWidgets('says nothing at all when related posts fail', (tester) async {
      // A "related posts" error box under an article somebody just finished is
      // worse than no section. Overridden to throw rather than return empty.
      tester.view.physicalSize = const Size(1200, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            blogPostProvider.overrideWith((ref, slug) async => _view),
            relatedPostsProvider.overrideWith(
              (ref, id) async => throw const ApiException(
                failure: ApiFailure.serverError,
                code: 'internal_error',
                message: 'down',
              ),
            ),
          ],
          // The Aangan theme, like every other pump here. Without it
          // `context.palette` is absent and the screen throws a null-check
          // long before it gets anywhere near the failure under test.
          child: MaterialApp(
            theme: AanganTheme.light,
            home: const PostScreen(slug: 'modular-kitchen-cost-lucknow'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      /// Nothing is reported anywhere, and that is worth stating rather than
      /// assuming.
      ///
      /// `maybeWhen(orElse:)` handles the error arm, so Riverpod considers the
      /// failure observed and never surfaces it to the zone. Silence on the
      /// screen is the right presentation choice here; silence in the *logs*
      /// is a consequence of it, and means a related-posts endpoint could be
      /// down for a week without anybody noticing. When Sentry is wired
      /// (RELEASE.md), this is a place that needs an explicit report rather
      /// than an inherited one.
      expect(tester.takeException(), isNull);

      expect(find.text('Read next'), findsNothing);
      expect(find.text('Something went wrong'), findsNothing);
      // The article itself is unaffected.
      expect(
        find.text('What a modular kitchen costs in Lucknow'),
        findsOneWidget,
      );
    });
  });
}
