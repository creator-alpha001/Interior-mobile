/// Which backend this build talks to.
///
/// Read from `--dart-define` rather than from a file, so the value is baked
/// into the binary at build time and cannot be changed by anything on the
/// device. `flutter run --dart-define=INTERIOBEE_ENV=staging`.
///
/// There is no default that points at production. A build that forgets to say
/// where it is going talks to localhost and fails loudly on a device, which is
/// the failure you want — the alternative is a developer build quietly writing
/// to real customer data.
library;

enum Flavour {
  dev('http://10.0.2.2:4000', 'Decora Shine (dev)'),

  /// `10.0.2.2` is the host machine as seen from the Android emulator. On a
  /// physical device this needs the machine's LAN address instead, which is why
  /// the value is a define rather than a constant.
  staging('https://staging-api.decorashine.example', 'Decora Shine (staging)'),

  production('https://api.decorashine.com', 'Decora Shine');

  const Flavour(this.defaultBaseUrl, this.appName);

  final String defaultBaseUrl;
  final String appName;
}

abstract final class Env {
  /// **Production unless told otherwise.**
  ///
  /// This defaulted to `dev` while nothing was live, so a build that forgot to
  /// say where it was going failed loudly against localhost rather than
  /// writing to real data. With decorashine.com serving customers, a plain
  /// `flutter run` on a phone showed an empty app with nothing to look at, so
  /// the default is now the real platform. Local work names itself:
  /// `--dart-define=INTERIOBEE_ENV=dev`, or `INTERIOBEE_API_URL` for a laptop.
  static const _name = String.fromEnvironment(
    'INTERIOBEE_ENV',
    defaultValue: 'production',
  );

  /// An explicit override, for pointing a build at a laptop on the same wifi.
  static const _baseUrlOverride = String.fromEnvironment('INTERIOBEE_API_URL');

  static Flavour get flavour => switch (_name) {
    'production' => Flavour.production,
    'staging' => Flavour.staging,
    _ => Flavour.dev,
  };

  static String get baseUrl =>
      _baseUrlOverride.isEmpty ? flavour.defaultBaseUrl : _baseUrlOverride;

  static bool get isProduction => flavour == Flavour.production;

  /// The website's origin, which serves the stock photographs `ph:` tokens
  /// stand for.
  ///
  /// The public site in every flavour, and deliberately so: these are static,
  /// read-only files identical everywhere, unlike the API, where a dev build
  /// must never reach production data. A laptop on the same wifi can be named
  /// instead with `--dart-define=INTERIOBEE_WEB_URL=http://192.168.1.20:3001`.
  ///
  /// **`www`, not the bare domain.** `decorashine.com` answers with a 308 to
  /// `www.decorashine.com`, and that redirect carries no CORS header — so the
  /// browser build refused every photograph, though the file it redirects to
  /// allows any origin. Naming the final host skips the hop on phones too.
  static const _webUrlOverride = String.fromEnvironment('INTERIOBEE_WEB_URL');

  static String get webBaseUrl =>
      _webUrlOverride.isEmpty ? 'https://www.decorashine.com' : _webUrlOverride;

  /// The Google OAuth **web** client id, not the Android or iOS one.
  ///
  /// Counter-intuitive but correct: passed as `serverClientId`, it is what
  /// makes Google mint an ID token addressed to our backend, which is the only
  /// thing the backend can verify. Give it the Android client id instead and
  /// the plugin returns a token for the app itself, and the server rejects
  /// every sign-in with a message about the wrong audience.
  ///
  /// **The web client id, even on Android.** The Android client id is never
  /// named anywhere: Google matches it by package name and signing
  /// fingerprint, and an app that passes it as `serverClientId` gets a token
  /// addressed to itself, which the backend refuses as the wrong audience.
  ///
  /// **Committed, because a client id is not a secret.** It is handed to
  /// Google by every app and every page that signs anybody in — this is the
  /// same id the website's button already uses — and it grants nothing on its
  /// own: the token it produces is checked against Google's public keys by our
  /// API, which trusts only the ids in `GOOGLE_CLIENT_IDS`. Left in a define,
  /// a build that forgot the flag shipped with no Google button and no error.
  ///
  /// An override remains, for a build pointed at another project. Empty turns
  /// Google sign-in off; the OTP path does not depend on it.
  static const googleServerClientId = String.fromEnvironment(
    'INTERIOBEE_GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '247345102590-v1jnsfk40aio6gihm957n2j1nljq2fgb'
        '.apps.googleusercontent.com',
  );

  /// The component gallery ships only in non-production builds.
  ///
  /// It is a development surface, and a store reviewer finding it would
  /// reasonably ask what it is.
  static bool get showsGallery => !isProduction;
}
