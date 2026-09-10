/// The Decora Shine API client.
///
/// Generated models and typed clients, plus the hand-written half: the dio
/// instance, the interceptors, and the error type every failure becomes.
///
/// Deliberately no Flutter dependency (MOBILE.md §4.1). That is what makes this
/// package generatable and testable without a widget tree, and it is enforced
/// by `test/no_flutter_test.dart`.
library;

export 'src/api.dart';
export 'src/api_exception.dart';
export 'src/interceptors.dart';
export 'src/offline_cache.dart';
export 'src/session.dart';

/// Every model, and the three clients the mobile app is allowed to call.
export 'src/generated/export.dart';
