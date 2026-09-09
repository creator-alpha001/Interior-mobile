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
}

@immutable
class SignInState {
  const SignInState({
    this.stage = SignInStage.phone,
    this.mobile = '',
    this.challengeId,
    this.expiresInSeconds,
    this.devCode,
    this.busy = false,
    this.error,
    this.retryAfter,
  });

  final SignInStage stage;
  final String mobile;
  final String? challengeId;
  final int? expiresInSeconds;

  /// Only ever present in development: the API echoes the code when
  /// `OTP_DEV_ECHO` is on, and its config refuses to allow that in production.
  final String? devCode;

  final bool busy;
  final String? error;

  /// Set on a 429. Shown as-is; see [AuthController.requestCode].
  final Duration? retryAfter;

  SignInState copyWith({
    SignInStage? stage,
    String? mobile,
    String? challengeId,
    int? expiresInSeconds,
    String? devCode,
    bool? busy,
    String? error,
    Duration? retryAfter,
    bool clearError = false,
    bool clearRetry = false,
  }) {
    return SignInState(
      stage: stage ?? this.stage,
      mobile: mobile ?? this.mobile,
      challengeId: challengeId ?? this.challengeId,
      expiresInSeconds: expiresInSeconds ?? this.expiresInSeconds,
      devCode: devCode ?? this.devCode,
      busy: busy ?? this.busy,
      error: clearError ? null : (error ?? this.error),
      retryAfter: clearRetry ? null : (retryAfter ?? this.retryAfter),
    );
  }
}

class AuthController extends ChangeNotifier {
  AuthController({
    required InterioBeeApi api,
    required AuthSessionStore session,
    this.onSignedIn,
    this.onSigningOut,
  }) : _api = api,
       _session = session {
    _session.onLost = _handleSessionLost;
  }

  final InterioBeeApi _api;
  final AuthSessionStore _session;

  /// Called once a session exists. Where device registration happens.
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
  Future<void> requestCode(String mobile) async {
    _signIn = _signIn.copyWith(
      busy: true,
      mobile: mobile,
      clearError: true,
      clearRetry: true,
    );
    notifyListeners();

    try {
      final challenge = await _api.public
          .requestOtp(body: RequestOtpBody(mobile: mobile))
          .orThrow();

      _signIn = _signIn.copyWith(
        stage: SignInStage.code,
        challengeId: challenge.challengeId,
        expiresInSeconds: challenge.expiresInSeconds.toInt(),
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
              name: name,
              cityId: cityId,
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
