/// The professional's shell.
///
/// Deliberately has no dependency on `feature_customer` and never will —
/// MOBILE.md §2 keeps the two shells separate packages so splitting into two
/// binaries later is a build flavour and an entrypoint rather than a rewrite.
/// `test/boundaries_test.dart` asserts it.
library;

export 'src/agreements_screen.dart';
export 'src/async_view.dart';
export 'src/dashboard_screen.dart';
export 'src/lead_detail_screen.dart';
export 'src/leads_screen.dart';
export 'src/quote_builder.dart';
export 'src/stage_proof_screen.dart';
export 'src/more_screen.dart';
export 'src/projects_screen.dart';
export 'src/thread_screen.dart';
export 'src/vendor_shell.dart';
export 'src/visits_screen.dart';
export 'src/onboarding_gate.dart';
export 'src/partner_agreement.dart';
export 'src/providers.dart';
