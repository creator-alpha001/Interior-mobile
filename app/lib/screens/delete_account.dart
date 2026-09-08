/// Closing an account.
///
/// **Both stores require this to exist** for any app with sign-in, and to be
/// reachable from within the app rather than by emailing support. That is why
/// it is here rather than on a help page.
///
/// It is not erasure, and the screen says so. `POST /me/account/delete` clears
/// personal detail and soft-deletes the row — which frees the mobile number for
/// reuse — while agreements, invoices and reviews stay, because they are
/// commercial records with a second party who did not ask for them to go. An
/// app that promised deletion and kept the invoices would be lying; one that
/// actually deleted them would be destroying a vendor's records.
///
/// The typed confirmation is not ceremony either. This is irreversible and
/// reachable from a settings screen on a phone, so a mis-tap must not do it.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({
    super.key,
    required this.api,
    required this.onClosed,
  });

  final AanganApi api;

  /// Called once the server has closed the account, so the app can sign out.
  final Future<void> Function() onClosed;

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _confirm = TextEditingController();
  final _reason = TextEditingController();

  bool _busy = false;
  String? _error;
  AccountClosure? _result;

  @override
  void dispose() {
    _confirm.dispose();
    _reason.dispose();
    super.dispose();
  }

  /// The exact word, matched exactly. The contract types it as a literal.
  bool get _confirmed => _confirm.text.trim() == 'DELETE';

  Future<void> _close() async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final closure = await widget.api.public
          .deleteAccount(
            body: DeleteAccountBody(
              confirm: DeleteAccountBodyConfirm.delete,
              reason: _reason.text.trim().isEmpty ? null : _reason.text.trim(),
            ),
          )
          .orThrow();

      if (!mounted) return;
      setState(() {
        _busy = false;
        _result = closure;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t('Close your account'))),
      body: SafeArea(
        child: _result == null ? _form(context) : _done(context, _result!),
      ),
    );
  }

  Widget _form(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
      children: [
        const SizedBox(height: Space.md),
        Text(context.t('Close your account'), style: context.text.displayLarge),
        const SizedBox(height: Space.sm),
        Text(
          context.t(
            'This cannot be undone. Your name, number and address are removed, '
            'and you are signed out everywhere.',
          ),
          style: context.text.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),

        /// Said before they act, not after.
        ///
        /// Somebody expecting total erasure and later finding an invoice with
        /// their agreement on it would reasonably feel misled. Better to be
        /// exact now.
        SectionHead(context.t('What stays'), eyebrow: context.t('And why')),
        AanganCard(
          padding: const EdgeInsets.all(Space.cardPaddingWide),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t('Agreements, invoices and reviews are kept.'),
                style: context.text.titleLarge,
              ),
              const SizedBox(height: Space.xs),
              Text(
                context.t(
                  'Each of these has a professional on the other side of it, and '
                  'they did not ask for their records to be destroyed. What is '
                  'kept no longer carries your name or your number.',
                ),
                style: context.text.bodyMedium,
              ),
            ],
          ),
        ),

        SectionHead(
          context.t('Why are you leaving?'),
          eyebrow: context.t('Optional'),
        ),
        TextField(
          controller: _reason,
          enabled: !_busy,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: context.t('It helps us, and it is not required.'),
          ),
        ),

        SectionHead(
          context.t('Confirm'),
          eyebrow: context.t('Type it exactly'),
        ),
        TextField(
          controller: _confirm,
          enabled: !_busy,
          autocorrect: false,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            /// DELETE stays in English inside the Hindi string too.
            ///
            /// [_confirmed] matches it character for character against the
            /// literal the contract types, so a translated word would never
            /// enable the button.
            labelText: context.t('Type DELETE to confirm'),
          ),
          onChanged: (_) => setState(() {}),
        ),

        if (_error != null) ...[
          const SizedBox(height: Space.xs),
          Text(
            _error!,
            style: context.text.bodySmall?.copyWith(
              color: context.palette.wrong,
            ),
          ),
        ],

        const SizedBox(height: Space.lg),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            // Burnt iron: this is the destructive path, and the button says so
            // rather than looking like every other primary action.
            style: FilledButton.styleFrom(
              backgroundColor: context.palette.wrong,
            ),
            onPressed: _confirmed && !_busy ? _close : null,
            child: _busy
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(context.t('Close my account permanently')),
          ),
        ),
        const SizedBox(height: Space.xs),
        Center(
          child: TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: Text(context.t('Keep my account')),
          ),
        ),
        const SizedBox(height: Space.xxxl),
      ],
    );
  }

  Widget _done(BuildContext context, AccountClosure closure) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
      children: [
        const SizedBox(height: Space.md),
        Text(context.t('Account closed'), style: context.text.displayLarge),
        const SizedBox(height: Space.sm),
        Text(
          context.t(
            'Your personal details have been removed, and your number is free to '
            'use again if you ever come back.',
          ),
          style: context.text.bodyLarge,
        ),

        SectionHead(
          context.t('What we kept'),
          eyebrow: context.t('As explained'),
        ),
        AanganCard(
          padding: const EdgeInsets.all(Space.cardPaddingWide),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Straight from the server, so the app cannot drift from what
              // was actually retained.
              for (final item in closure.retained)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.xxs),
                  child: Text('• $item', style: context.text.bodyMedium),
                ),
              const SizedBox(height: Space.xs),
              Text(
                context.t('These no longer carry your name or your number.'),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: Space.lg),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: widget.onClosed,
            child: Text(context.t('Done')),
          ),
        ),
        const SizedBox(height: Space.xxxl),
      ],
    );
  }
}
