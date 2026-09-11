/// Signing in, and what the app knows about who is signed in.
///
/// The flow is MOBILE.md §5.2, and the two decisions that shape it are worth
/// restating because they are easy to undo by accident:
///
///   **Signing up and signing in are one action.** An unrecognised number
///   creates a customer account. There is no "Sign up" button anywhere, and
///   nothing asks for a name until a code has verified for a number the server
///   has not seen — which is why [needsProfile] exists as a state rather than a
///   separate screen reached by a different route.
///
///   **Staff are refused here.** Ops and admin have no mobile surface. They are
///   told so, and told where to go, rather than being dropped somewhere empty.
library;

import 'dart:async';

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'secure_session.dart';

/// Which shell the app should show. Derived, never set by a screen.
enum Shell {
  /// `GET /me` has not answered yet. Hold the splash.
  resolving,
  signedOut,
  customer,
  vendor,

  /// Signed in as a professional who has not signed the partner agreement.
  ///
  /// A separate shell rather than a flag, because they must not reach the
  /// dashboard: an unsigned vendor is in no lead pool however verified they
  /// are, so "0 leads" is true and tells them nothing about why.
  vendorOnboarding,

  /// Signed in as staff. Refused, with an explanation.
  staffRefused,
}

/// Where the sign-in screens are in the flow.
enum SignInStage {
  /// Asking for a mobile number.
  phone,

  /// A code has been sent; waiting for six digits.
  code,

  /// The code verified, the number was new, and the account needs a name.
  profile,

  /// Google said who they are, and there is no account here yet.
  ///
  /// Asks for a name and a city — and takes "not now" for an answer on the
  /// city. It used to send them to [phone] instead, with a link token and no
  /// way out: the server's `users.mobile` was NOT NULL, so somebody who had
  /// just authenticated with Google was shown a phone field they could not get
  /// past. The number is optional now and is asked for after the account
  /// exists, where declining costs nothing.
  welcome,
}

@immutable
class SignInState {
  const SignInState({
    this.stage = SignInStage.phone,
    this.mobile = '',
    this.challengeId,
    this.expiresInSeconds,
    this.channel,
    this.devCode,
    this.busy = false,
    this.error,
    this.retryAfter,
    this.googleLinkToken,
    this.googleEmail,
    this.googleName,
  });

  final SignInStage stage;
  final String mobile;
  final String? challengeId;
  final int? expiresInSeconds;

  /// Where the code went: WhatsApp, unless SMS was asked for or the server
  /// swapped a channel that is not live on it. Null from an API too old to say,
  /// in which case the screen names no channel rather than guessing the app.
  final OtpChallengeChannel? channel;

  /// Only ever present in development: the API echoes the code when
  /// `OTP_DEV_ECHO` is on, and its config refuses to allow that in production.
  final String? devCode;

  final bool busy;
  final String? error;

  /// Set on a 429. Shown as-is; see [AuthController.requestCode].
  final Duration? retryAfter;

  /// A verified Google account waiting for its first mobile number.
  ///
  /// Google gives a verified email and a name, never a phone, and `users.mobile`
  /// on the server is NOT NULL because ops ring every customer about their
  /// lead. So the first Google sign-in falls into the ordinary code stage
  /// carrying this, and after that one code it is never asked for again.
  final String? googleLinkToken;
  final String? googleEmail;
  final String? googleName;

  bool get linkingGoogle => googleLinkToken != null;

  SignInState copyWith({
    SignInStage? stage,
    String? mobile,
    String? challengeId,
    int? expiresInSeconds,
    OtpChallengeChannel? channel,
    String? devCode,
    bool? busy,
    String? error,
    Duration? retryAfter,
    String? googleLinkToken,
    String? googleEmail,
    String? googleName,
    bool clearError = false,
    bool clearRetry = false,
  }) {
    return SignInState(
      stage: stage ?? this.stage,
      mobile: mobile ?? this.mobile,
      challengeId: challengeId ?? this.challengeId,
      expiresInSeconds: expiresInSeconds ?? this.expiresInSeconds,
      channel: channel ?? this.channel,
      devCode: devCode ?? this.devCode,
      busy: busy ?? this.busy,
      error: clearError ? null : (error ?? this.error),
      retryAfter: clearRetry ? null : (retryAfter ?? this.retryAfter),
      googleLinkToken: googleLinkToken ?? this.googleLinkToken,
      googleEmail: googleEmail ?? this.googleEmail,
      googleName: googleName ?? this.googleName,
    );
  }
}

class AuthController extends ChangeNotifier {
  AuthController({
    required InterioBeeApi api,
    required AuthSessionStore session,
    this.googleServerClientId = '',
    this.onSignedIn,
    this.onSigningOut,
  }) : _api = api,
       _session = session {
    _session.onLost = _handleSessionLost;
  }

  final InterioBeeApi _api;
  final AuthSessionStore _session;

  /// Called once a session exists. Where device registration happens.
  /// The Google OAuth **web** client id. Empty means Google sign-in is off.
  ///
  /// Injected rather than read from a define here, because this package cannot
  /// see the app's `Env` and should not learn how the app is configured.
  final String googleServerClientId;

  /// Whether to offer the Google button at all.
  bool get googleAvailable => googleServerClientId.isNotEmpty;

  final Future<void> Function()? onSignedIn;

  /// Called *before* the session is cleared, and awaited.
  ///
  /// The order is the point: deregistering this handset for push is an
  /// authenticated call, so a token cleared first leaves the row behind and
  /// the phone keeps receiving somebody else's job alerts. Same for the read
  /// cache — a vendor's dashboard is their pipeline, and it must not survive
  /// into the next person's session on the same device.
  final Future<void> Function()? onSigningOut;

  Shell _shell = Shell.resolving;
  Shell get shell => _shell;

  SessionUser? _user;
  SessionUser? get user => _user;

  SignInState _signIn = const SignInState();
  SignInState get signIn => _signIn;

  /// Set when a session ends unexpectedly, so the sign-in screen can say why.
  String? _notice;
  String? get notice => _notice;

  void clearNotice() {
    if (_notice == null) return;
    _notice = null;
    notifyListeners();
  }

  /// Resolve who is signed in, at launch.
  ///
  /// A 401 here is not an error — it is the ordinary signed-out case, and the
  /// interceptor has already cleared the token. Anything else leaves the app
  /// signed out too, because guessing is worse: a network failure at launch
  /// must not present as a valid session.
  Future<void> resolve() async {
    final token = await _session.read();
    if (token == null) {
      _set(Shell.signedOut);
      return;
    }

    try {
      final me = await _api.public.me().orThrow();
      _adopt(me);
    } on ApiException catch (error) {
      if (error.failure != ApiFailure.notAuthenticated) {
        _notice = error.message;
      }
      _set(Shell.signedOut);
    }
  }

  /// Sends a six-digit code.
  ///
  /// The rate limits are the server's — five per mobile per hour, twenty per
  /// IP. A client-side counter would eventually disagree with them, and the
  /// disagreement always favours the client, so there is none: a 429 is
  /// rendered honestly with the time the server gave.
  ///
  /// `channel` omitted means WhatsApp. The screen passes the channel the last
  /// code went on to resend it, and the other one to switch.
  Future<void> requestCode(
    String mobile, {
    OtpChallengeChannel? channel,
  }) async {
    _signIn = _signIn.copyWith(
      busy: true,
      mobile: mobile,
      clearError: true,
      clearRetry: true,
    );
    notifyListeners();

    try {
      final challenge = await _api.public
          .requestOtp(
            body: RequestOtpBody(
              mobile: mobile,
              channel: _requestChannel(channel),
            ),
          )
          .orThrow();

      _signIn = _signIn.copyWith(
        stage: SignInStage.code,
        challengeId: challenge.challengeId,
        expiresInSeconds: challenge.expiresInSeconds.toInt(),
        channel: challenge.channel,
        devCode: challenge.devCode,
        busy: false,
      );
    } on ApiException catch (error) {
      _signIn = _signIn.copyWith(
        busy: false,
        error: error.message,
        retryAfter: error.retryAfter,
      );
    }
    notifyListeners();
  }

  /// Exchanges the code for a session.
  ///
  /// `name` and `cityId` are sent only when the account is new. The server
  /// treats them as optional and creates a customer for an unrecognised
  /// number, which is the intended flow rather than a fallback.
  Future<void> verifyCode(String code, {String? name, String? cityId}) async {
    final challengeId = _signIn.challengeId;
    if (challengeId == null) return;

    _signIn = _signIn.copyWith(busy: true, clearError: true, clearRetry: true);
    notifyListeners();

    try {
      final session = await _api.public
          .verifyOtp(
            body: VerifyOtpBody(
              challengeId: challengeId,
              code: code,
              // What they typed wins over the Google profile name.
              name: name ?? _signIn.googleName,
              cityId: cityId,
              // Present only on the one code that finishes a Google sign-in.
              linkToken: _signIn.googleLinkToken,
            ),
          )
          .orThrow();

      final token = _tokenOf(session);
      if (token == null) {
        // The API only returns a token when it sees `X-Client: mobile`, which
        // AuthInterceptor always sends. Reaching here means that header was
        // lost, and continuing would leave the app "signed in" with nothing to
        // authenticate the next request.
        _signIn = _signIn.copyWith(
          busy: false,
          error: 'Sign-in did not return a session. Please try again.',
        );
        notifyListeners();
        return;
      }

      await _session.save(token);

      final me = await _api.public.me().orThrow();
      _signIn = const SignInState();
      _adopt(me);
    } on ApiException catch (error) {
      _signIn = _signIn.copyWith(
        busy: false,
        error: error.message,
        retryAfter: error.retryAfter,
      );
      notifyListeners();
    }
  }

  /// Turns a proved Google identity into an account.
  ///
  /// `cityId` is optional and the button that omits it is a real button, not
  /// small print. Skipping is the same call with one argument missing rather
  /// than a separate path, so it cannot rot into a second-class route that
  /// quietly stops working while the happy path stays green.
  ///
  /// No mobile number anywhere in here. That is the whole point: the account
  /// exists after this call, and the number is asked for afterwards by
  /// [requestMyMobileCode], where closing the app costs nothing.
  Future<void> completeGoogleSignUp({String? name, String? cityId}) async {
    final linkToken = _signIn.googleLinkToken;
    if (linkToken == null) return;

    _signIn = _signIn.copyWith(busy: true, clearError: true, clearRetry: true);
    notifyListeners();

    try {
      final session = await _api.public
          .completeGoogleSignUp(
            body: CompleteGoogleSignUpBody(
              linkToken: linkToken,
              // What they typed wins over the Google profile name.
              name: name ?? _signIn.googleName,
              cityId: cityId,
            ),
          )
          .orThrow();

      final token = _tokenOf(session);
      if (token == null) {
        // Same reasoning as verifyCode: the API only returns a token when it
        // sees `X-Client: mobile`, and without one the app would be "signed in"
        // with nothing to authenticate the next request.
        _signIn = _signIn.copyWith(
          busy: false,
          error: 'Sign-in did not return a session. Please try again.',
        );
        notifyListeners();
        return;
      }

      await _session.save(token);

      final me = await _api.public.me().orThrow();
      _signIn = const SignInState();
      _adopt(me);
    } on ApiException catch (error) {
      _signIn = _signIn.copyWith(
        busy: false,
        error: error.message,
        retryAfter: error.retryAfter,
      );
      notifyListeners();
    }
  }

  /* ---------------- filling in what signup did not ask ---------------- */

  /// The cities somebody can pick from.
  ///
  /// On this controller rather than a catalogue provider because the sign-in
  /// screen's only dependency is this object, and the welcome stage has to ask
  /// where somebody is before there is a session or a shell to hang a provider
  /// off. Active cities only — offering one the platform does not serve would
  /// collect an answer that has to be taken away again.
  Future<List<City>> cities() async {
    try {
      return await _api.public.listCities().orThrow();
    } on ApiException {
      // A city list that will not load must not block a signup. The screen
      // renders the skip path alone, which is a supported answer anyway.
      return const [];
    }
  }


  /// Sets or clears the city on the signed-in account.
  ///
  /// `null` clears it, and that direction matters as much as the other: a
  /// person who picked a city to see its prices and then moved should be able
  /// to go back to seeing everything. A setting that can only narrow is one
  /// people stop touching.
  ///
  /// Returns the error to show, or null on success.
  Future<String?> setMyCity(String? cityId) async {
    try {
      final me = await _api.public
          .updateProfile(body: UpdateProfileBody(cityId: cityId))
          .orThrow();
      _user = me;
      notifyListeners();
      return null;
    } on ApiException catch (error) {
      return error.message;
    }
  }

  /// Sends a code to a number the signed-in person wants to add.
  ///
  /// Deliberately not [requestCode]. That one asks "who is this", and an
  /// unknown number becomes an account; this asks "is this number yours", on
  /// behalf of a session — so it can never create or switch one. A number
  /// already on another account is refused here, before the SMS goes out,
  /// rather than after six digits have been typed back in.
  Future<OtpChallenge?> requestMyMobileCode(
    String mobile, {
    OtpChallengeChannel? channel,
  }) async {
    _mobileError = null;
    try {
      final challenge = await _api.public
          .requestMobileVerification(
            body: RequestOtpBody(
              mobile: mobile,
              channel: _requestChannel(channel),
            ),
          )
          .orThrow();
      notifyListeners();
      return challenge;
    } on ApiException catch (error) {
      _mobileError = error.message;
      notifyListeners();
      return null;
    }
  }

  /// Proves that number and attaches it to the signed-in account.
  Future<bool> confirmMyMobile({
    required String challengeId,
    required String code,
  }) async {
    _mobileError = null;
    try {
      final me = await _api.public
          .confirmMobileVerification(
            body: ConfirmMobileVerificationBody(
              challengeId: challengeId,
              code: code,
            ),
          )
          .orThrow();
      _user = me;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _mobileError = error.message;
      notifyListeners();
      return false;
    }
  }

  /// Whatever went wrong the last time a number was offered, for the screen.
  String? _mobileError;
  String? get mobileError => _mobileError;

  /// True when there is still something signup was allowed to skip.
  ///
  /// Read by the customer shell to decide whether to offer the prompts at all.
  /// Both are genuinely optional, so this is an invitation and never a gate.
  bool get setupIncomplete {
    final me = _user;
    if (me == null) return false;
    return me.cityId == null || me.mobile == null || !me.mobileVerified;
  }

  /// Signs in with Google, or falls through to the welcome stage.
  ///
  /// Two outcomes, and the second is the interesting one. A Google account that
  /// somebody has already linked is a complete sign-in. One that nobody has
  /// linked has no account here yet, so it arrives back with a link token and
  /// the state moves to [SignInStage.welcome] — a name, a city, and a button
  /// that skips the city.
  ///
  /// It used to move to the phone stage instead and demand a verified number,
  /// because the server's `users.mobile` was NOT NULL. That cost the signup of
  /// anyone unwilling to hand a phone number to an app they were still deciding
  /// about, to buy a number ops confirm on the scoping call anyway.
  ///
  /// `serverClientId` is the **web** OAuth client id, not the Android one. It
  /// is what makes Google mint an ID token addressed to the backend; without it
  /// the plugin returns an access token the server has no way to verify, which
  /// fails in a way that looks like a server bug.
  Future<void> signInWithGoogle() async {
    _signIn = _signIn.copyWith(busy: true, clearError: true, clearRetry: true);
    notifyListeners();

    final String? idToken;
    try {
      idToken = await _googleIdToken();
    } catch (error) {
      _signIn = _signIn.copyWith(
        busy: false,
        error: 'Google sign-in did not work. Please use your mobile number.',
      );
      notifyListeners();
      return;
    }

    if (idToken == null) {
      // Dismissed the sheet. Not an error, and saying so would be wrong.
      _signIn = _signIn.copyWith(busy: false);
      notifyListeners();
      return;
    }

    try {
      final result = await _api.public
          .googleSignIn(body: GoogleSignInBody(idToken: idToken))
          .orThrow();

      if (result.status == GoogleSignInResultStatus.profileRequired) {
        _signIn = _signIn.copyWith(
          stage: SignInStage.welcome,
          busy: false,
          googleLinkToken: result.linkToken,
          googleEmail: result.email,
          googleName: result.name,
        );
        notifyListeners();
        return;
      }

      final session = result.session;
      final token = session == null ? null : _tokenOf(session);
      if (token == null) {
        // Same reasoning as verifyCode: without a token the app would be
        // "signed in" with nothing to authenticate the next request.
        _signIn = _signIn.copyWith(
          busy: false,
          error: 'Sign-in did not return a session. Please try again.',
        );
        notifyListeners();
        return;
      }

      await _session.save(token);
      final me = await _api.public.me().orThrow();
      _signIn = const SignInState();
      _adopt(me);
    } on ApiException catch (error) {
      _signIn = _signIn.copyWith(
        busy: false,
        error: error.message,
        retryAfter: error.retryAfter,
      );
      notifyListeners();
    }
  }

  /// Asks Google for an ID token, or null if the person backed out.
  Future<String?> _googleIdToken() async {
    final signIn = GoogleSignIn.instance;
    await signIn.initialize(serverClientId: googleServerClientId);

    final account = await signIn.authenticate();
    return account.authentication.idToken;
  }

  /// The number verified but the account is new and has no name yet.
  void needsProfile() {
    _signIn = _signIn.copyWith(stage: SignInStage.profile, clearError: true);
    notifyListeners();
  }

  void restart() {
    _signIn = const SignInState();
    notifyListeners();
  }

  Future<void> signOut() async {
    // Before anything is revoked, while the session is still usable.
    await onSigningOut?.call();

    try {
      // Revoke the row server-side next. A token cleared only on the handset
      // is still a live session everywhere else.
      await _api.public.logout().orThrow();
    } on ApiException {
      // Already invalid, or offline. Clearing locally is still right.
    }
    _user = null;
    await _session.clear();
  }

  /// The request's channel from the response's.
  ///
  /// The contract names the field on each object separately, so it generates
  /// two enums for one vocabulary. Mapped case by case rather than by string, so
  /// a third channel added to the contract stops this compiling instead of
  /// quietly sending nothing.
  RequestOtpBodyChannel? _requestChannel(OtpChallengeChannel? channel) =>
      switch (channel) {
        OtpChallengeChannel.whatsapp => RequestOtpBodyChannel.whatsapp,
        OtpChallengeChannel.sms => RequestOtpBodyChannel.sms,
        OtpChallengeChannel.$unknown || null => null,
      };

  /// `sessionToken` lives on each variant of the union rather than on a shared
  /// base, so it is read per-branch. The `switch` is exhaustive, so a fifth
  /// role added to the contract would stop this compiling.
  String? _tokenOf(AuthSession session) => switch (session) {
    AuthSessionClient(:final sessionToken) => sessionToken,
    AuthSessionProfessional(:final sessionToken) => sessionToken,
    AuthSessionSalesAgent(:final sessionToken) => sessionToken,
    AuthSessionAdmin(:final sessionToken) => sessionToken,
  };

  void _adopt(SessionUser me) {
    _user = me;
    _set(_shellFor(me.actor));
    // Registration is fire-and-forget: push is an enhancement, and nothing
    // about the shell should wait on it.
    onSignedIn?.call();
  }

  /// The role decides the shell. One place, resolved once.
  Shell _shellFor(Actor actor) => switch (actor) {
    ActorClient() => Shell.customer,

    // Whether they have signed the partner agreement is a separate call —
    // `GET /vendor/onboarding` — so the vendor lands on the gate first and
    // the gate decides. Assuming "signed" here would show a dashboard to
    // somebody in no pool.
    ActorProfessional() => Shell.vendorOnboarding,

    ActorSalesAgent() || ActorAdmin() => Shell.staffRefused,
  };

  void _set(Shell shell) {
    if (_shell == shell) return;
    _shell = shell;
    notifyListeners();
  }

  void _handleSessionLost(SessionLostReason reason) {
    _user = null;
    _notice = switch (reason) {
      SessionLostReason.revoked =>
        'You were signed out. This happens if your account was suspended, or '
            'you signed in on another device.',
      SessionLostReason.signedOut => null,
    };
    _set(Shell.signedOut);
    notifyListeners();
  }

  @override
  void dispose() {
    _session.onLost = null;
    super.dispose();
  }
}

/// Note on where these live.
///
/// `requestOtp`, `verifyOtp`, `logout` and `me` are all on the *public* client,
/// which reads oddly until you look at the manifest: they are declared
/// `audience: "public"` because they are not route-guarded. `GET /me` answers
/// 401 rather than being refused before the handler runs, which is exactly what
/// makes it usable as "who, if anyone, is signed in".
