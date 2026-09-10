/// Reconciles swagger_parser's output with freezed 3 and with our unions.
///
/// It runs between `swagger_parser` and `build_runner`, and it exists because
/// two things are true at once and neither is going to change:
///
///  1. **swagger_parser emits freezed-2 syntax.** Freezed 3 makes the generated
///     `_$X` mixin abstract, so a plain `class X with _$X` no longer satisfies
///     it — all 170 models fail with
///     `non_abstract_class_inherits_abstract_member`. Freezed 2 is not an
///     option: retrofit_generator 10 requires freezed 3, and retrofit 9 wants a
///     `json_annotation` older than json_serializable will accept.
///
///  2. **Our discriminated unions are modelled twice.** `openapi.json`
///     describes `Actor` as `oneOf` + `discriminator`, whose `mapping` must
///     point at `$ref`s — so `ActorClient` has to exist as a component. That is
///     what makes swagger_parser emit the union as a proper Dart `sealed class`
///     with `@FreezedUnionValue`, which is exactly what MOBILE.md §4.2 wants:
///     a compiler-checked `switch` on role. But swagger_parser *also* emits
///     each variant as a standalone model, and the union already defines those
///     names — so the two collide in `export.dart`.
///
/// The union's own definition wins. The standalone variant files are deleted,
/// along with the imports and exports that reach for them.
///
/// This is a transform over generated code, not a patch: it is re-run from
/// scratch on every regeneration, and `melos run contract` does exactly that.
library;

import 'dart:io';

/// A model file that merely repeats a union variant the union already declares.
final _variantOf = <String, String>{
  'actor_client.dart': 'actor.dart',
  'actor_professional.dart': 'actor.dart',
  'actor_sales_agent.dart': 'actor.dart',
  'actor_admin.dart': 'actor.dart',
  'auth_session_client.dart': 'auth_session.dart',
  'auth_session_professional.dart': 'auth_session.dart',
  'auth_session_sales_agent.dart': 'auth_session.dart',
  'auth_session_admin.dart': 'auth_session.dart',
  // The reviewer's decision on an application to become a vendor. Same shape
  // as the two above: `oneOf` + a discriminator on `action`, so the variants
  // have to exist as components for the mapping to point at, and swagger_parser
  // emits them twice.
  'ops_decide_professional_application_body_start_review.dart':
      'ops_decide_professional_application_body.dart',
  'ops_decide_professional_application_body_request_changes.dart':
      'ops_decide_professional_application_body.dart',
  'ops_decide_professional_application_body_reject.dart':
      'ops_decide_professional_application_body.dart',
  'ops_decide_professional_application_body_approve.dart':
      'ops_decide_professional_application_body.dart',
};

void main() {
  final generated = Directory('lib/src/generated');
  if (!generated.existsSync()) {
    stderr.writeln(
      'lib/src/generated does not exist — run swagger_parser first.',
    );
    exitCode = 1;
    return;
  }

  final models = Directory('${generated.path}/models');
  var abstracted = 0;
  var deleted = 0;

  // 1. Delete the redundant variant models.
  for (final name in _variantOf.keys) {
    final file = File('${models.path}/$name');
    if (file.existsSync()) {
      file.deleteSync();
      deleted++;
    }
  }

  // 2. Delete the staff client.
  //
  // `openapi.json` documents the whole API, ops included, because it is the
  // API's document and not the mobile app's. But MOBILE.md §1 is explicit that
  // admin has no mobile surface, now or planned — and the ops responses are
  // where commission figures, vendor margins and unmasked customer phone
  // numbers live.
  //
  // Removing the generated client is a structural guarantee rather than a
  // convention: a screen in this binary cannot call `/ops/*`, because there is
  // no method to call. Leaving it generated and merely unexported would rely on
  // nobody importing it directly.
  for (final name in const ['staff_client.dart', 'staff_client.g.dart']) {
    final file = File('${generated.path}/clients/$name');
    if (file.existsSync()) {
      file.deleteSync();
      deleted++;
    }
  }

  // 3. Make every freezed data class abstract, and drop dangling imports.
  for (final entity in generated.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (entity.path.contains('.freezed.') || entity.path.contains('.g.'))
      continue;

    final original = entity.readAsStringSync();
    var updated = original;

    // `class X with _$X {` -> `abstract class X with _$X {`.
    // `sealed class` is already valid in freezed 3 and is left alone.
    updated = updated.replaceAllMapped(
      RegExp(r'^class (\w+) with \$?_\$', multiLine: true),
      (m) => 'abstract class ${m[1]} with _\$',
    );

    for (final gone in [..._variantOf.keys, 'staff_client.dart']) {
      updated = updated
          .replaceAll("import '$gone';\n", '')
          .replaceAll("export '$gone';\n", '')
          .replaceAll("export 'models/$gone';\n", '')
          .replaceAll("export 'clients/$gone';\n", '');
    }

    // swagger_parser's enum `toJson` casts a value the analyser can already see
    // is the right type. Harmless, 56 of them, and not ours to fix — but left
    // alone they bury a real warning in generated code under noise. Suppressed
    // in the generated files themselves rather than repo-wide, so the same
    // warning still surfaces in hand-written code.
    updated = updated.replaceFirst(
      '// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import',
      '// ignore_for_file: type=lint, unused_import, invalid_annotation_target, '
          'unnecessary_import, unnecessary_cast',
    );

    if (updated != original) {
      entity.writeAsStringSync(updated);
      if (original.contains(RegExp(r'^class \w+ with', multiLine: true)))
        abstracted++;
    }
  }

  stdout.writeln(
    'fix_generated: $abstracted models made abstract for freezed 3, '
    '$deleted duplicate union variants removed.',
  );
}
