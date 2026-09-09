/// Session, sign-in and role resolution.
///
/// Depends on Flutter, unlike `core_api`, because the session lives in Keychain
/// and Keystore and the resume gate is a platform biometric prompt. The API
/// client's `SessionStore` interface is the seam between the two: `core_api`
/// declares what it needs, this package provides it.
library;

export 'src/auth_controller.dart';
export 'src/biometric_gate.dart';
export 'src/secure_session.dart';
