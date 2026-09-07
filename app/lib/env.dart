/// Which backend this build talks to.
///
/// Read from `--dart-define` rather than from a file, so the value is baked
/// into the binary at build time and cannot be changed by anything on the
/// device. `flutter run --dart-define=AANGAN_ENV=staging`.
///
/// There is no default that points at production. A build that forgets to say
/// where it is going talks to localhost and fails loudly on a device, which is
/// the failure you want — the alternative is a developer build quietly writing
/// to real customer data.
library;

enum Flavour {
  dev('http://10.0.2.2:4000', 'Aangan (dev)'),

  /// `10.0.2.2` is the host machine as seen from the Android emulator. On a
  /// physical device this needs the machine's LAN address instead, which is why
  /// the value is a define rather than a constant.
  staging('https://staging-api.aangan.example', 'Aangan (staging)'),

  production('https://api.aangan.example', 'Aangan');

  const Flavour(this.defaultBaseUrl, this.appName);

  final String defaultBaseUrl;
  final String appName;
}

abstract final class Env {
  static const _name = String.fromEnvironment('AANGAN_ENV', defaultValue: 'dev');

  /// An explicit override, for pointing a build at a laptop on the same wifi.
  static const _baseUrlOverride = String.fromEnvironment('AANGAN_API_URL');

  static Flavour get flavour => switch (_name) {
        'production' => Flavour.production,
        'staging' => Flavour.staging,
        _ => Flavour.dev,
      };

  static String get baseUrl =>
      _baseUrlOverride.isEmpty ? flavour.defaultBaseUrl : _baseUrlOverride;

  static bool get isProduction => flavour == Flavour.production;

  /// The component gallery ships only in non-production builds.
  ///
  /// It is a development surface, and a store reviewer finding it would
  /// reasonably ask what it is.
  static bool get showsGallery => !isProduction;
}
