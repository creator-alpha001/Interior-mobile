/// The relay thread — with Decora Shine, never with the customer.
///
/// Every message here has the platform on one side of it. That is not a
/// limitation of the app; it is the platform's proposition, and the schema
/// enforces it: a check constraint makes a message crossing the client/vendor
/// channel unrepresentable, and a vendor's thread carries their id while the
/// customer's does not.
///
/// The header says so plainly, because a vendor's first instinct is to look for
/// the customer and they should understand why there isn't one.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'providers.dart';

class ThreadScreen extends ConsumerStatefulWidget {
  const ThreadScreen({
    super.key,
    required this.leadDomainId,
    required this.title,
  });

  final String leadDomainId;
  final String title;

  @override
  ConsumerState<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends ConsumerState<ThreadScreen> {
  final _body = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _body.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);
    try {
      await ref
          .read(vendorApiProvider)
          .vendor
          .sendVendorMessage(
            id: widget.leadDomainId,
            body: SendServiceMessageBody(body: text),
          )
          .orThrow();

      _body.clear();
      ref.invalidate(threadProvider(widget.leadDomainId));
      refreshAfterWriteFrom(ref);
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final thread = ref.watch(threadProvider(widget.leadDomainId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Decora Shine'),
            Text(
              context.t('about {title}', {'title': widget.title}),
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: context.colors.surfaceContainer,
              padding: const EdgeInsets.symmetric(
                horizontal: Space.gutter,
                vertical: Space.xs,
              ),
              child: Text(
                context.t(
                  'You are talking to Decora Shine, not the customer. We carry your '
                  'questions to them and bring their answers back.',
                ),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: AsyncView(
                value: thread,
                onRetry: () =>
                    ref.invalidate(threadProvider(widget.leadDomainId)),
                data: (messages) {
                  if (messages.isEmpty) {
                    return EmptyState(
                      title: context.t('Nothing yet'),
                      body: context.t(
                        'Ask the coordinator anything about the scope, the '
                        'site or the timeline.',
                      ),
                    );
                  }

                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Space.gutter,
                      vertical: Space.sm,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final message = messages[messages.length - 1 - i];
                      return _Bubble(message: message);
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Space.sm),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _body,
                      enabled: !_sending,
                      maxLines: 4,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: context.t('Message the coordinator'),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: Space.xs),
                  FilledButton(
                    onPressed: _body.text.trim().isEmpty || _sending
                        ? null
                        : _send,
                    child: const Icon(Icons.send, size: TapTarget.glyph),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final mine = message.senderRole == MessageSenderRole.professional;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: Space.xs),
        padding: const EdgeInsets.all(Space.sm),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: mine
              ? context.colors.surfaceContainerHighest
              : InterioBeeColors.chalk,
          borderRadius: Radii.panelRadius,
          border: Border.all(color: context.palette.hairline),
        ),
        child: Column(
          crossAxisAlignment: mine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              mine ? context.t('You') : 'Decora Shine',
              style: context.text.labelMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Space.xxs),
            Text(message.body, style: context.text.bodyMedium),
          ],
        ),
      ),
    );
  }
}
