/// The two things signup let a customer skip: a city and a confirmed number.
///
/// Reached from the highlighted strip on the home screen — the app's version of
/// the web's account page, where the same two questions live. Both are
/// optional and the screen says so: it is an invitation, never a gate, which is
/// why it ends in Done rather than Save.
///
/// Adding a number is [AuthController.requestMyMobileCode], not `requestCode`.
/// That one asks "who is this" and can create an account; this asks "is this
/// number yours" on behalf of a session, so it can never switch one.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart'
    show City, OtpChallenge, OtpChallengeChannel;
import 'package:interiobee_core_auth/interiobee_core_auth.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FinishSetupScreen extends StatefulWidget {
  const FinishSetupScreen({super.key, required this.auth});

  final AuthController auth;

  @override
  State<FinishSetupScreen> createState() => _FinishSetupScreenState();
}

class _FinishSetupScreenState extends State<FinishSetupScreen> {
  late final Future<List<City>> _cities = widget.auth.cities();
  final _mobile = TextEditingController();

  /// The code in flight. Null means the number is still being typed.
  OtpChallenge? _challenge;
  String _sentTo = '';

  bool _busy = false;
  String? _cityError;

  @override
  void dispose() {
    _mobile.dispose();
    super.dispose();
  }

  Future<void> _setCity(String? cityId) async {
    setState(() {
      _busy = true;
      _cityError = null;
    });
    final error = await widget.auth.setMyCity(cityId);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _cityError = error;
    });
  }

  /// Sends a code, or a fresh one on another channel, which retires the last.
  Future<void> _sendCode({OtpChallengeChannel? channel}) async {
    final number = _challenge == null ? _mobile.text.trim() : _sentTo;
    if (number.isEmpty) return;

    setState(() => _busy = true);
    final challenge = await widget.auth.requestMyMobileCode(
      number,
      channel: channel,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (challenge != null) {
        _challenge = challenge;
        _sentTo = number;
      }
    });
  }

  Future<void> _confirm(String code) async {
    final challenge = _challenge;
    if (challenge == null) return;

    setState(() => _busy = true);
    final confirmed = await widget.auth.confirmMyMobile(
      challengeId: challenge.challengeId,
      code: code,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (confirmed) _challenge = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.auth,
      builder: (context, _) {
        final me = widget.auth.user;
        final mobile = me?.mobile;
        final verified = mobile != null && (me?.mobileVerified ?? false);

        return Scaffold(
          appBar: AppBar(),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
              children: [
                Text(
                  context.t('Finish setting up'),
                  style: context.text.headlineLarge,
                ),
                const SizedBox(height: Space.xs),
                Text(
                  context.t(
                    'Both are optional, and neither is ever shared with '
                    'professionals.',
                  ),
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),

                SectionHead(
                  context.t('Your city'),
                  eyebrow: context.t('Prices follow the city'),
                ),
                FutureBuilder<List<City>>(
                  future: _cities,
                  builder: (context, snapshot) {
                    final cities = snapshot.data ?? const <City>[];
                    return DropdownButtonFormField<String?>(
                      // Rebuilt when the account's city changes, so the field
                      // shows what was saved rather than what was tapped.
                      key: ValueKey(me?.cityId),
                      initialValue: me?.cityId,
                      decoration: InputDecoration(
                        labelText: context.t('Choose your city'),
                        errorText: _cityError,
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(context.t('All cities')),
                        ),
                        for (final city in cities)
                          DropdownMenuItem<String?>(
                            value: city.id,
                            child: Text(city.name),
                          ),
                      ],
                      onChanged: _busy ? null : _setCity,
                    );
                  },
                ),
                const SizedBox(height: Space.xs),
                Text(
                  context.t(
                    'So prices and professionals match where you live.',
                  ),
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),

                SectionHead(
                  context.t('Mobile number'),
                  eyebrow: context.t('For calls about your quotes'),
                ),
                if (verified)
                  Row(
                    children: [
                      Expanded(
                        child: Text(mobile, style: context.text.titleLarge),
                      ),
                      StatusPill(
                        context.t('Verified'),
                        tone: StatusTone.verified,
                      ),
                    ],
                  )
                else if (_challenge == null) ...[
                  TextField(
                    controller: _mobile,
                    enabled: !_busy,
                    keyboardType: TextInputType.phone,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      labelText: context.t('Mobile number'),
                      helperText: context.t('We send the code on WhatsApp.'),
                      errorText: widget.auth.mobileError,
                      // The dialling code and a sample number are the same
                      // digits in every language.
                      prefixText: '+91  ',
                      hintText: '98765 43210',
                    ),
                    onSubmitted: _busy ? null : (_) => _sendCode(),
                  ),
                  const SizedBox(height: Space.md),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _busy ? null : () => _sendCode(),
                      child: Text(context.t('Send code')),
                    ),
                  ),
                ] else ...[
                  Text(switch (_challenge!.channel) {
                    OtpChallengeChannel.whatsapp => context.t(
                      'We sent a code on WhatsApp to {number}.',
                      {'number': _sentTo},
                    ),
                    OtpChallengeChannel.sms => context.t(
                      'We sent a code by SMS to {number}.',
                      {'number': _sentTo},
                    ),
                    _ => context.t('We sent a code to {number}.', {
                      'number': _sentTo,
                    }),
                  }, style: context.text.bodyMedium),
                  const SizedBox(height: Space.sm),
                  OtpField(
                    enabled: !_busy,
                    errorText: widget.auth.mobileError,
                    onCompleted: _confirm,
                  ),
                  const SizedBox(height: Space.sm),
                  Wrap(
                    spacing: Space.xs,
                    children: [
                      if (_challenge!.channel == OtpChallengeChannel.whatsapp)
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () =>
                                    _sendCode(channel: OtpChallengeChannel.sms),
                          child: Text(context.t('Send by SMS instead')),
                        )
                      else if (_challenge!.channel == OtpChallengeChannel.sms)
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => _sendCode(
                                  channel: OtpChallengeChannel.whatsapp,
                                ),
                          child: Text(context.t('Send on WhatsApp instead')),
                        ),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => setState(() => _challenge = null),
                        child: Text(context.t('Change number')),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: Space.xl),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.t('Done')),
                  ),
                ),
                const SizedBox(height: Space.xxxl),
              ],
            ),
          ),
        );
      },
    );
  }
}
