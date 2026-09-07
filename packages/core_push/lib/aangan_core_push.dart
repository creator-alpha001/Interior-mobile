/// Push: registering this handset, and where a tap should land.
///
/// Deliberately has no `firebase_messaging` dependency yet — see the note in
/// `pubspec.yaml`. Everything downstream of the token is built and tested; the
/// Firebase implementation is one class conforming to [PushTokenSource].
library;

export 'src/deep_links.dart';
export 'src/device_registrar.dart';
