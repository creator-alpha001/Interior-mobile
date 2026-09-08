/// Search across everything.
///
/// The web's `/search`. `search` and `searchSuggest` were both unreachable
/// from the app, which meant the only way to find a product was to scroll to
/// it.
///
/// **Type-ahead has to stay fast, and staying fast is mostly about not
/// asking.** Every keystroke firing a request gives the server eight calls for
/// "wardrobe" and gives the reader the answer to "wardro" — so the query is
/// debounced, the in-flight one is abandoned when a newer one starts, and a
/// late response for a query nobody is typing any more is dropped rather than
/// rendered.
library;

import 'dart:async';

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'blog_screen.dart';
import 'catalogue.dart';
import 'packages_screen.dart';
import 'professional_screen.dart';
import 'providers.dart';

/// MOBILE.md §6.1: *"debounce 250ms and cancel in flight"*.
const _debounce = Duration(milliseconds: 250);

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.onStart});

  final VoidCallback? onStart;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  Timer? _timer;

  /// Bumped on every request. A response whose sequence is not the current one
  /// is stale and is thrown away — otherwise a slow "war" can land after a
  /// fast "wardrobe" and replace the right results with the wrong ones.
  int _sequence = 0;

  SearchResults? _results;
  List<SearchSuggestion> _suggestions = const [];
  bool _busy = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    // The keyboard, immediately. Somebody who opened search wants to type.
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged() {
    _timer?.cancel();
    final query = _controller.text.trim();

    if (query.length < 2) {
      // One character matches most of the catalogue. Clearing rather than
      // searching keeps the screen from flashing everything on the way in.
      setState(() {
        _results = null;
        _suggestions = const [];
        _busy = false;
      });
      return;
    }

    setState(() => _busy = true);
    _timer = Timer(_debounce, () => _run(query));
  }

  Future<void> _run(String query) async {
    final sequence = ++_sequence;
    final api = ref.read(customerApiProvider).public;
    final city = ref.read(catalogueFiltersProvider).cityId;

    try {
      final results = await api.search(q: query, city: city).orThrow();
      final suggestions = await api.searchSuggest(q: query).orThrow();
      if (!mounted || sequence != _sequence) return;
      setState(() {
        _results = results;
        _suggestions = suggestions;
        _busy = false;
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted || sequence != _sequence) return;
      setState(() {
        _busy = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          focusNode: _focus,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: context.t('Search everything'),
            border: InputBorder.none,
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _controller.clear,
                    tooltip: context.t('Clear'),
                  ),
          ),
        ),
      ),
      body: SafeArea(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    if (_error != null) {
      return ErrorState(
        error: _error!,
        onRetry: () => _run(_controller.text.trim()),
      );
    }

    if (_controller.text.trim().length < 2) {
      return _Prompt();
    }

    // The old results stay on screen while a new query runs. Blanking to a
    // spinner on every keystroke is how a search feels slower than it is.
    final results = _results;
    if (results == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (results.total == 0 && !_busy) {
      return EmptyState(
        title: context.t('Nothing found'),
        body: context.t(
          'Nothing matches that. Tell us what you need in your own words '
          'instead — most of what we do is made to order anyway.',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
      children: [
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: Space.sm),
          Wrap(
            spacing: Space.xxs,
            runSpacing: Space.xxs,
            children: [
              for (final suggestion in _suggestions)
                ActionChip(
                  label: Text(suggestion.label),
                  onPressed: () {
                    _controller.text = suggestion.label;
                    _controller.selection = TextSelection.collapsed(
                      offset: suggestion.label.length,
                    );
                  },
                ),
            ],
          ),
        ],

        if (results.products.isNotEmpty) ...[
          SectionHead(
            context.t('Products'),
            eyebrow: context.l10n.plural(
              results.products.length,
              '{n} match',
              '{n} matches',
            ),
          ),
          SizedBox(
            height: 290,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: results.products.length,
              separatorBuilder: (context, i) => const SizedBox(width: Space.sm),
              itemBuilder: (context, i) => SizedBox(
                width: 200,
                child: ProductCard(view: results.products[i]),
              ),
            ),
          ),
        ],

        if (results.packages.isNotEmpty) ...[
          SectionHead(context.t('Packages'), eyebrow: context.t('Fixed scope')),
          for (final view in results.packages) ...[
            PackageCard(view: view, onStart: widget.onStart),
            const SizedBox(height: Space.sm),
          ],
        ],

        if (results.professionals.isNotEmpty) ...[
          SectionHead(
            context.t('Professionals'),
            eyebrow: context.t('Verified'),
          ),
          for (final professional in results.professionals) ...[
            AanganCard(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfessionalScreen(id: professional.id),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          professional.companyName,
                          style: context.text.titleLarge,
                        ),
                        Text(
                          professional.city.name,
                          style: context.text.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: context.colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.xs),
          ],
        ],

        if (results.posts.isNotEmpty) ...[
          SectionHead(context.t('Guides'), eyebrow: context.t('Reading')),
          for (final post in results.posts) ...[
            PostCard(view: post),
            const SizedBox(height: Space.xs),
          ],
        ],

        const SizedBox(height: Space.xxxl),
      ],
    );
  }
}

/// What the screen says before anybody has typed.
///
/// Not an empty state — the person has done nothing wrong. It says what is
/// searchable, because "search" over an unknown corpus is a guess.
class _Prompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Space.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('Search everything'),
            style: context.text.headlineSmall,
          ),
          const SizedBox(height: Space.xs),
          Text(
            context.t(
              'Products, packages, professionals and guides — all at once. '
              'Two letters is enough to start.',
            ),
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
