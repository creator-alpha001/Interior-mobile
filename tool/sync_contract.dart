/// Copies `openapi.json` from the API repository into `contract/`.
///
/// The document is committed here rather than fetched at build time. The two
/// repositories release on different cadences — a mobile build from three weeks
/// ago must keep generating the client it was written against, not whatever the
/// API looks like today — so the copy in `contract/` is this app's pinned view
/// of the contract, and updating it is a reviewable commit.
///
///   dart run tool/sync_contract.dart            # from ../Interior
///   dart run tool/sync_contract.dart --check    # CI: fail if it has drifted
///   INTERIOBEE_API_REPO=/path/to/repo dart run tool/sync_contract.dart
///
/// `--check` is only meaningful where both repositories are present. CI for
/// this repository does not run it: there is nothing to compare against, and
/// the committed document is the input by design.
library;

import 'dart:io';

const _defaultRepo = r'../Interior';

void main(List<String> args) {
  final repo = Platform.environment['INTERIOBEE_API_REPO'] ?? _defaultRepo;
  final source = File('$repo/openapi.json');
  final target = File('contract/openapi.json');

  if (!source.existsSync()) {
    stderr.writeln(
      'Could not find ${source.path}.\n'
      'Set INTERIOBEE_API_REPO to the web repository, and run `npm run openapi` there first.',
    );
    exitCode = 1;
    return;
  }

  final incoming = source.readAsStringSync();

  if (args.contains('--check')) {
    if (!target.existsSync()) {
      stderr.writeln('contract/openapi.json is missing.');
      exitCode = 1;
      return;
    }
    if (target.readAsStringSync() != incoming) {
      stderr.writeln(
        'contract/openapi.json has drifted from ${source.path}.\n'
        'Run `dart run tool/sync_contract.dart`, regenerate, and commit.',
      );
      exitCode = 1;
      return;
    }
    stdout.writeln('contract/openapi.json matches ${source.path}.');
    return;
  }

  final changed = !target.existsSync() || target.readAsStringSync() != incoming;
  target.parent.createSync(recursive: true);
  target.writeAsStringSync(incoming);

  stdout.writeln(
    changed
        ? 'contract/openapi.json updated from ${source.path}. '
            'Regenerate with `melos run contract`.'
        : 'contract/openapi.json was already up to date.',
  );
}
