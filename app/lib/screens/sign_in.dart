/// Signing in.
///
/// One screen, three stages, because it is one action. MOBILE.md §5.2 is
/// explicit that signing up and signing in are the same thing here: an
/// unrecognised number creates a customer account, so there is no "Sign up"
/// button and nothing asks for a name until a code has verified for a number
/// the server has not seen before.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart' show City;
import 'package:interiobee_core_auth/interiobee_core_auth.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.auth, this.dismissible = false});

  final AuthController auth;

  /// Pushed over the app rather than standing in for it.
  ///
  /// The router used to be the only way here: signed out meant this screen and
  /// nothing else. Now most of the app is readable without an account, so this
  /// is also raised *from* somewhere — the Jobs tab, the last step of the
  /// requirement form, the Account tab's own button — and has to close itself
  /// and give the caller back control.
  ///
  /// It closes on success, and it closes on a back press. There is no third
  /// outcome: whoever raised it asks the controller who is signed in.
  final bool dismissible;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _mobile = TextEditingController();
  final _name = TextEditingController();

  /// Google's name, copied in once when the welcome stage first appears.
  ///
  /// Guarded by a flag rather than written on every build: the field is
  /// editable, and re-seeding it would undo what somebody was in the middle of
  /// typing on the next rebuild — of which there is one per keystroke.
  bool _seededGoogleName = false;

  void _seedName(SignInState state) {
    if (_seededGoogleName || state.stage != SignInStage.welcome) return;
    final fromGoogle = state.googleName;
    if (fromGoogle != null && fromGoogle.isNotEmpty && _name.text.isEmpty) {
      _name.text = fromGoogle;
    }
    _seededGoogleName = true;
  }

  @override
  void dispose() {
    _mobile.dispose();
    _name.dispose();
    super.dispose();
  }

  /// Closes itself once a session exists.
  ///
  /// Done from a post-frame callback rather than inside `build`, because
  /// popping a route during a build is what produces "setState() or
  /// markNeedsBuild() called during build".
  void _closeOnSuccess() {
    if (!widget.dismissible) return;
    if (widget.auth.shell == Shell.signedOut) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final navigator = Navigator.of(context);
      if (navigator.canPop()) navigator.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.auth,
      builder: (context, _) {
        final state = widget.auth.signIn;
        _seedName(state);
        _closeOnSuccess();

        return Scaffold(
          /// Only when raised over something. As the signed-out root there is
          /// nothing behind it to go back to, and an inert arrow reads as a
          /// broken screen.
          appBar: widget.dismissible ? AppBar() : null,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Space.xxl),
                  Text('InterioBee', style: context.text.displayLarge),
                  const SizedBox(height: Space.xs),
                  Text(
                    switch (state.stage) {
                      SignInStage.phone => context.t(
                        'Interior design, furniture, fabrication and painting — '
                        'with one person who answers.',
                      ),
                      // A placeholder rather than interpolation: the number
                      // does not sit in the same place in both languages.
                      SignInStage.code => context.t(
                        'We sent a code to {number}.',
                        {'number': state.mobile},
                      ),
                      SignInStage.profile => context.t(
                        'Your number is verified. Two things and you are in.',
                      ),
                      // A placeholder rather than interpolation: the address
                      // does not sit in the same place in both languages.
                      SignInStage.welcome => context.t(
                        'Google confirmed {email}. Two questions and your '
                        'account is ready.',
                        {'email': state.googleEmail ?? ''},
                      ),
                    },
                    style: context.text.bodyLarge?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),

                  // Why they were signed out, when they did not do it
                  // themselves. Silence here invites a support call.
                  if (widget.auth.notice != null) ...[
                    const SizedBox(height: Space.lg),
                    ActionRequired(
                      title: context.t('You were signed out'),

                      /// The server's sentence, deliberately. It knows which of
                      /// several reasons applied — expiry, revocation, a
                      /// password change elsewhere — and a canned local string
                      /// would flatten all of them into one.
                      body: widget.auth.notice!,
                    ),
                  ],

                  const SizedBox(height: Space.xl),

                  switch (state.stage) {
                    SignInStage.phone => _PhoneStage(
                      controller: _mobile,
                      state: state,
                      onSubmit: (value) => widget.auth.requestCode(value),
                      googleAvailable: widget.auth.googleAvailable,
                      onGoogle: widget.auth.signInWithGoogle,
                    ),
                    SignInStage.code => _CodeStage(
                      state: state,
                      onSubmit: widget.auth.verifyCode,
                      onResend: () => widget.auth.requestCode(state.mobile),
                      onChangeNumber: widget.auth.restart,
                    ),
                    SignInStage.profile => _ProfileStage(
                      name: _name,
                      state: state,
                      onSubmit: (name) =>
                          widget.auth.verifyCode('', name: name),
                    ),
                    SignInStage.welcome => _WelcomeStage(
                      name: _name,
                      state: state,
                      cities: widget.auth.cities,
                      onSubmit: (name, cityId) => widget.auth
                          .completeGoogleSignUp(name: name, cityId: cityId),
                    ),
                  },

                  const SizedBox(height: Space.xxl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PhoneStage extends StatelessWidget {
  const _PhoneStage({
    required this.controller,
    required this.state,
    required this.onSubmit,
    required this.googleAvailable,
    required this.onGoogle,
  });

  final TextEditingController controller;
  final SignInState state;
  final ValueChanged<String> onSubmit;

  /// False when the build carries no Google client id, which is the default.
  final bool googleAvailable;
  final Future<void> Function() onGoogle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // There is deliberately no "signed in with Google, now give us a
        // number" banner here any more. A Google sign-in with no account
        // behind it goes to SignInStage.welcome, which asks for a city and
        // takes no for an answer — this stage is only ever reached by somebody
        // who chose to sign in with a number in the first place.
        TextField(
          controller: controller,
          enabled: !state.busy,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: InputDecoration(
            labelText: context.t('Mobile number'),
            // Neither of these is copy. The dialling code and a sample number
            // are the same digits in every language.
            prefixText: '+91  ',
            hintText: '98765 43210',
          ),
          onSubmitted: state.busy ? null : onSubmit,
        ),

        if (state.error != null) ...[
          const SizedBox(height: Space.xs),
          _ErrorLine(state: state),
        ],

        const SizedBox(height: Space.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: state.busy ? null : () => onSubmit(controller.text),
            child: state.busy ? const _Spinner() : Text(context.t('Send code')),
          ),
        ),

        // Hidden once a Google sign-in is already waiting on a number:
        // offering the same button again invites going round in a circle
        // rather than finishing the one step left.
        if (googleAvailable && !state.linkingGoogle) ...[
          const SizedBox(height: Space.md),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.sm),
                child: Text(
                  context.t('or'),
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: Space.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: state.busy ? null : () => onGoogle(),
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: Text(context.t('Continue with Google')),
            ),
          ),
        ],

        const SizedBox(height: Space.md),
        Text(
          // No "Sign up" anywhere. Saying this plainly is what replaces it.
          context.t(
            'New here? Entering your number is all it takes — we will set the '
            'account up as you go.',
          ),
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CodeStage extends StatefulWidget {
  const _CodeStage({
    required this.state,
    required this.onSubmit,
    required this.onResend,
    required this.onChangeNumber,
  });

  final SignInState state;
  final void Function(String code, {String? name, String? cityId}) onSubmit;
  final VoidCallback onResend;
  final VoidCallback onChangeNumber;

  @override
  State<_CodeStage> createState() => _CodeStageState();
}

class _CodeStageState extends State<_CodeStage> {
  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OtpField(
          enabled: !state.busy,
          errorText: state.error,
          onCompleted: (code) => widget.onSubmit(code),
        ),

        if (state.retryAfter != null) ...[
          const SizedBox(height: Space.xs),
          _ErrorLine(state: state),
        ],

        // Development only. The API echoes the code when OTP_DEV_ECHO is on,
        // and its config refuses to allow that in production — so this can
        // never render against a real deployment.
        if (state.devCode != null) ...[
          const SizedBox(height: Space.md),
          InterioBeeCard(
            nested: true,
            child: Row(
              children: [
                const StatusPill('dev', tone: StatusTone.neutral),
                const SizedBox(width: Space.xs),
                // Untranslated on purpose. This can only ever render against a
                // development API — the config refuses OTP_DEV_ECHO in
                // production — so it is a developer's affordance, not copy.
                Text(
                  'Code is ${state.devCode}',
                  style: context.text.bodyMedium,
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: Space.lg),
        Row(
          children: [
            TextButton(
              onPressed: state.busy ? null : widget.onResend,
              child: Text(context.t('Send again')),
            ),
            const Spacer(),
            TextButton(
              onPressed: state.busy ? null : widget.onChangeNumber,
              child: Text(context.t('Change number')),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileStage extends StatelessWidget {
  const _ProfileStage({
    required this.name,
    required this.state,
    required this.onSubmit,
  });

  final TextEditingController name;
  final SignInState state;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: name,
          enabled: !state.busy,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.name],
          decoration: InputDecoration(labelText: context.t('Your name')),
        ),
        if (state.error != null) ...[
          const SizedBox(height: Space.xs),
          _ErrorLine(state: state),
        ],
        const SizedBox(height: Space.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: state.busy ? null : () => onSubmit(name.text),
            child: state.busy ? const _Spinner() : Text(context.t('Continue')),
          ),
        ),
      ],
    );
  }
}

/// Name and city, before there is an account.
///
/// The screen that replaced a phone field somebody could not get past. What it
/// asks for now is one dropdown, and even that has a button beside it that
/// declines — because a city genuinely changes what the app can show, and a
/// phone number genuinely does not need to be handed over to find that out.
///
/// The reason is the point of the copy, not the requirement. "Your city" with
/// an asterisk teaches somebody that this app collects things; the actual
/// consequence — that every price and every professional is per city, so
/// without one they are looking at all of them at once — is a reason to answer,
/// and it stays true whether or not they do.
class _WelcomeStage extends StatefulWidget {
  const _WelcomeStage({
    required this.name,
    required this.state,
    required this.cities,
    required this.onSubmit,
  });

  final TextEditingController name;
  final SignInState state;
  final Future<List<City>> Function() cities;

  /// `cityId` is null when they skipped. Deliberately the same callback as
  /// Continue, so skipping cannot become a second-class path that quietly stops
  /// working while the happy one stays green.
  final void Function(String name, String? cityId) onSubmit;

  @override
  State<_WelcomeStage> createState() => _WelcomeStageState();
}

class _WelcomeStageState extends State<_WelcomeStage> {
  late final Future<List<City>> _cities = widget.cities();
  String? _cityId;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<List<City>>(
          future: _cities,
          builder: (context, snapshot) {
            final cities = snapshot.data ?? const <City>[];

            // No list yet, or none arrived. Either way the city question cannot
            // be asked, and it was never the thing standing between somebody
            // and an account — so the rest of the form carries on without it.
            if (cities.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String?>(
                  initialValue: _cityId,
                  decoration: InputDecoration(
                    labelText: context.t('Where are you?'),
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(context.t('Choose your city')),
                    ),
                    for (final city in cities)
                      DropdownMenuItem<String?>(
                        value: city.id,
                        child: Text('${city.name}, ${city.state}'),
                      ),
                  ],
                  onChanged: state.busy
                      ? null
                      : (value) => setState(() => _cityId = value),
                ),
                const SizedBox(height: Space.xs),
                Text(
                  context.t(
                    'Prices, professionals and availability are all set per '
                    'city. Tell us yours and the app shows rates that apply to '
                    'your job and vendors who can come out to it.',
                  ),
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Space.md),
              ],
            );
          },
        ),

        TextField(
          controller: widget.name,
          enabled: !state.busy,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.name],
          decoration: InputDecoration(labelText: context.t('Your name')),
        ),

        if (state.error != null) ...[
          const SizedBox(height: Space.xs),
          _ErrorLine(state: state),
        ],

        const SizedBox(height: Space.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: state.busy
                ? null
                : () => widget.onSubmit(widget.name.text, _cityId),
            child: state.busy ? const _Spinner() : Text(context.t('Continue')),
          ),
        ),

        // A real second option, not small print. If skipping is allowed it
        // should look allowed — a greyed-out link under a full-width button
        // reads as the thing you are not supposed to press.
        if (_cityId == null) ...[
          const SizedBox(height: Space.xs),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: state.busy
                  ? null
                  : () => widget.onSubmit(widget.name.text, null),
              child: Text(context.t('Skip — show me every city')),
            ),
          ),
        ],
      ],
    );
  }
}

/// The error, plus the retry time when the server gave one.
///
/// The rate limits are the server's. Rendering its number rather than a
/// client-side countdown is what keeps the two from disagreeing — and when they
/// disagree, it is always the client that is wrong and always the customer who
/// is confused.
class _ErrorLine extends StatelessWidget {
  const _ErrorLine({required this.state});

  final SignInState state;

  @override
  Widget build(BuildContext context) {
    final retry = state.retryAfter;

    /// `state.error` is the server's own sentence and stays as it came.
    ///
    /// Translating it here would mean keeping a copy of every error string the
    /// API can produce, in sync, forever — and getting it wrong would show
    /// somebody a *different* reason than the one that actually applied. The
    /// wrapper around it is ours, so that part translates.
    final text = retry == null
        ? state.error ?? ''
        : context.t('{error} Try again in {n}s.', {
            'error': state.error ?? context.t('Too many attempts.'),
            'n': retry.inSeconds,
          });

    return Text(
      text,
      style: context.text.bodySmall?.copyWith(color: context.palette.wrong),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 18,
      width: 18,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }
}
