/// The forced upgrade.
///
/// `GET /app/version` returns `minBuild` and a message, and MOBILE.md is direct
/// about why it exists: *"once a bad build is on somebody's phone, raising the
/// minimum is the only lever there is."* No store release reaches everybody,
/// and a version that corrupts a form or loops on a request cannot be recalled.
///
/// Two rules keep the lever from becoming a liability:
///
///   **The check never blocks launch.** If `/app/version` cannot be reached,
///   the app opens. An upgrade gate that locks people out because the *server*
///   is unreachable is a worse outage than the bug it was guarding against.
///
///   **The block is absolute once it applies.** No dismiss, no "later". A
///   build below the floor is one the platform has decided must not talk to the
///   API, and offering a way past it would defeat the only lever there is.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';

/// The build number this binary was compiled as.
///
/// From `--dart-define=INTERIOBEE_BUILD`, which CI sets from the same number it
/// gives the store. Zero in a development build, which is below every floor —
/// so the default is *deliberately* not "assume current": a developer build
/// that ignored the gate would be the one place the gate is never exercised.
/// [VersionGate] treats zero as "unknown" and lets it through, but a release
/// build with no define is caught by the CI check rather than at runtime.
const kBuildNumber = int.fromEnvironment('INTERIOBEE_BUILD');

class VersionGate extends ChangeNotifier {
  VersionGate({required InterioBeeApi api, int build = kBuildNumber})
    : _api = api,
      _build = build;

  final InterioBeeApi _api;
  final int _build;

  bool _blocked = false;
  String _message = '';

  bool get isBlocked => _blocked;
  String get message => _message;

  /// Asks the server whether this build may still talk to it.
  ///
  /// Failure is silence: any error at all leaves the app open. See the note at
  /// the top of the file.
  Future<void> check() async {
    // A build with no number is a developer build. It is not the version the
    // gate exists to stop.
    if (_build == 0) return;

    try {
      final version = await _api.public.appVersion().orThrow();
      if (_build >= version.minBuild) return;

      _blocked = true;
      // The server's words, not ours. It knows why the floor was raised.
      _message = version.message;
      notifyListeners();
    } on ApiException {
      // Unreachable, rate limited, anything. The app opens.
    }
  }
}

/// What a blocked build shows, and nothing else.
class UpgradeRequiredScreen extends StatelessWidget {
  const UpgradeRequiredScreen({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(Space.gutter),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('Update InterioBee'),
                  style: context.text.displayLarge,
                ),
                const SizedBox(height: Space.sm),
                Text(
                  /// Not translated, and it cannot be: this is the server's
                  /// sentence, written when somebody raised the floor, and it
                  /// says *why* this particular build was cut off. A canned
                  /// local string would lose the only useful part.
                  message,
                  style: context.text.bodyLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Space.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    // Opening the store is the only action. There is
                    // deliberately no "continue anyway".
                    onPressed: () => _openStore(context),
                    child: Text(context.t('Open the app store')),
                  ),
                ),
                const SizedBox(height: Space.md),
                Text(
                  context.t(
                    'Your account and anything in progress are safe. This build '
                    'just cannot talk to InterioBee any more.',
                  ),
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openStore(BuildContext context) {
    // Wired when the store listings exist and the bundle ids are fixed — see
    // RELEASE.md. Until then, saying so is better than a dead button that
    // looks like a bug.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.t('Search for "InterioBee" in your app store to update.'),
        ),
      ),
    );
  }
}
