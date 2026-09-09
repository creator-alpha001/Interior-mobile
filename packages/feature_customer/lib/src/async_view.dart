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

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_design/interiobee_design.dart';
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

    /// Says what actually went wrong, in debug builds only.
    ///
    /// This screen is deliberately vague — a customer does not need a stack
    /// trace, and "Something went wrong · Please try again" is the right thing
    /// to *show*. But it is also the last thing that sees the error, and being
    /// vague to the developer as well cost two long debugging sessions: an
    /// un-overridden Riverpod provider and a decode failure both rendered as
    /// that same sentence, with nothing anywhere to distinguish them.
    ///
    /// Inside `assert` so it compiles out of release entirely, and printing the
    /// runtime type because that alone separates the three cases that matter:
    /// an `ApiException` (the server said no), a `TypeError` (the contract
    /// moved), or anything else (a bug on this side).
    assert(() {
      // Only when the error is not one the switch below has copy for.
      // A 404 rendering as "Not found" needs no explanation; anything
      // reaching the default arm does.
      if (api == null) {
        debugPrint('AsyncView error — ${error.runtimeType}: $error');
      }
      return true;
    }());

    final (String title, String body, bool retryable) = switch (api?.failure) {
      ApiFailure.network => (
        context.t('No connection'),
        context.t(
          context.t(
            'We could not reach InterioBee. Check your signal and try again.',
          ),
        ),
        true,
      ),
      ApiFailure.notFound => (
        context.t('Not found'),
        // Never "you do not have access": the API answers 404 for somebody
        // else's record on purpose, and this side cannot tell which it was.
        context.t('We could not find that. It may have been withdrawn.'),
        false,
      ),
      ApiFailure.rateLimited => (
        context.t('Too many requests'),
        api?.retryAfter == null
            ? context.t('Please wait a moment and try again.')
            : context.t('Please try again in {n} seconds.', {
                'n': api!.retryAfter!.inSeconds,
              }),
        false,
      ),
      ApiFailure.conflict => (
        context.t('That has changed'),
        context.t(
          context.t(
            'Someone updated this while you were looking at it. Pull to refresh.',
          ),
        ),
        true,
      ),
      ApiFailure.serverError => (
        context.t('Something went wrong'),
        context.t('The problem is on our side. Try again in a moment.'),
        true,
      ),
      // `api.message` is the server's sentence and stays as it came — see the
      // note in sign_in.dart for why translating it here would be worse.
      _ => (
        context.t('Something went wrong'),
        api?.message ?? context.t('Please try again.'),
        true,
      ),
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
              OutlinedButton(
                onPressed: onRetry,
                child: Text(context.t('Try again')),
              ),
            ],
            // The one thing worth reading out to support. The API echoes it on
            // every response, so their screenshot and a server log are the
            // same story.
            if (api?.requestId != null) ...[
              const SizedBox(height: Space.md),
              Text(
                context.t('Reference {id}', {'id': api!.requestId}),
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
