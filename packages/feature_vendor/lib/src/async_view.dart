/// How every screen in this shell renders a remote read.
///
/// One place, because the error copy is a product decision rather than a
/// per-screen one, and because two of the states are easy to render wrongly:
///
///   **404 does not mean "no access".** The API answers 404 for a record
///   belonging to somebody else, deliberately — a 403 would confirm it exists.
///   The app genuinely cannot tell the two apart, so it must not claim to.
///
///   **429 is not an error to retry.** It is the server asking for less
///   traffic, and it says for how long. Showing its number is the whole job.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.data,
    required this.onRetry,
    this.loading,
  });

  final AsyncValue<T> value;
  final Widget Function(T value) data;
  final VoidCallback onRetry;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => loading ?? const _Loading(),
      error: (error, _) => ErrorState(error: error, onRetry: onRetry),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(Space.xxl),
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final api = error is ApiException ? error as ApiException : null;

    final (String title, String body, bool retryable) = switch (api?.failure) {
      ApiFailure.network => (
          'No connection',
          'We could not reach Aangan. Check your signal and try again.',
          true,
        ),
      ApiFailure.notFound => (
          'Not found',
          // Never "you do not have access": the API answers 404 for somebody
          // else's record on purpose, and this side cannot tell which it was.
          'We could not find that. It may have been withdrawn.',
          false,
        ),
      ApiFailure.rateLimited => (
          'Too many requests',
          api?.retryAfter == null
              ? 'Please wait a moment and try again.'
              : 'Please try again in ${api!.retryAfter!.inSeconds} seconds.',
          false,
        ),
      ApiFailure.conflict => (
          'That has changed',
          'Someone updated this while you were looking at it. Pull to refresh.',
          true,
        ),
      ApiFailure.serverError => (
          'Something went wrong',
          'The problem is on our side. Try again in a moment.',
          true,
        ),
      _ => ('Something went wrong', api?.message ?? 'Please try again.', true),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Space.gutter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: context.text.headlineSmall),
            const SizedBox(height: Space.xs),
            Text(
              body,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            if (retryable) ...[
              const SizedBox(height: Space.md),
              OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
            ],
            // The one thing worth reading out to support. The API echoes it on
            // every response, so their screenshot and a server log are the
            // same story.
            if (api?.requestId != null) ...[
              const SizedBox(height: Space.md),
              Text(
                'Reference ${api!.requestId}',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Nothing here, and why that is fine.
///
/// Separate from [ErrorState] because an empty list is not a failure, and
/// styling it like one teaches people to distrust the app.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Space.gutter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: context.text.headlineSmall),
            const SizedBox(height: Space.xs),
            Text(
              body,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
