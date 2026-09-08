/// The customer's shell.
///
/// Deliberately has no dependency on `feature_vendor` and never will —
/// MOBILE.md §2 keeps the two shells separate packages so splitting into two
/// binaries later is a build flavour and an entrypoint rather than a rewrite.
/// `test/boundaries_test.dart` asserts it.
library;

export 'src/agreements_screen.dart';
export 'src/async_view.dart';
export 'src/blog_screen.dart';
export 'src/catalogue.dart';
export 'src/estimator.dart';
export 'src/estimator_screen.dart';
export 'src/customer_shell.dart';
export 'src/home_screen.dart';
export 'src/packages_screen.dart';
export 'src/product_screen.dart';
export 'src/professional_screen.dart';
export 'src/projects_screen.dart';
export 'src/providers.dart';
export 'src/quote_comparison.dart';
export 'src/search_screen.dart';
export 'src/requirement_draft.dart';
export 'src/requirement_flow.dart';
export 'src/requirements_screen.dart';
