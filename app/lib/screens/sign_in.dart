/// Signing in.
///
/// One screen, three stages, because it is one action. MOBILE.md §5.2 is
/// explicit that signing up and signing in are the same thing here: an
/// unrecognised number creates a customer account, so there is no "Sign up"
/// button and nothing asks for a name until a code has verified for a number
/// the server has not seen before.
library;

import 'package:aangan_core_auth/aangan_core_auth.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.auth});

  final AuthController auth;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _mobile = TextEditingController();
  final _name = TextEditingController();

  @override
  void dispose() {
    _mobile.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.auth,
      builder: (context, _) {
        final state = widget.auth.signIn;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Space.xxl),
                  Text('Aangan', style: context.text.displayLarge),
                  const SizedBox(height: Space.xs),
                  Text(
                    switch (state.stage) {
                      SignInStage.phone =>
                        'Interior design, furniture, fabrication and painting — '
                            'with one person who answers.',
                      SignInStage.code => 'We sent a code to ${state.mobile}.',
                      SignInStage.profile =>
                        'Your number is verified. Two things and you are in.',
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
                      title: 'You were signed out',
                      body: widget.auth.notice!,
                    ),
                  ],

                  const SizedBox(height: Space.xl),

                  switch (state.stage) {
                    SignInStage.phone => _PhoneStage(
                        controller: _mobile,
                        state: state,
                        onSubmit: (value) => widget.auth.requestCode(value),
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
                        onSubmit: (name) => widget.auth.verifyCode('', name: name),
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
  });

  final TextEditingController controller;
  final SignInState state;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          enabled: !state.busy,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: const InputDecoration(
            labelText: 'Mobile number',
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
            child: state.busy
                ? const _Spinner()
                : const Text('Send code'),
          ),
        ),

        const SizedBox(height: Space.md),
        Text(
          // No "Sign up" anywhere. Saying this plainly is what replaces it.
          'New here? Entering your number is all it takes — we will set the '
          'account up as you go.',
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
          AanganCard(
            nested: true,
            child: Row(
              children: [
                const StatusPill('dev', tone: StatusTone.neutral),
                const SizedBox(width: Space.xs),
                Text('Code is ${state.devCode}', style: context.text.bodyMedium),
              ],
            ),
          ),
        ],

        const SizedBox(height: Space.lg),
        Row(
          children: [
            TextButton(
              onPressed: state.busy ? null : widget.onResend,
              child: const Text('Send again'),
            ),
            const Spacer(),
            TextButton(
              onPressed: state.busy ? null : widget.onChangeNumber,
              child: const Text('Change number'),
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
          decoration: const InputDecoration(labelText: 'Your name'),
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
            child: state.busy ? const _Spinner() : const Text('Continue'),
          ),
        ),
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
    final text = retry == null
        ? state.error ?? ''
        : '${state.error ?? 'Too many attempts.'} Try again in ${retry.inSeconds}s.';

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
