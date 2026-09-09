/// The six-digit code input.
///
/// **One real field with six boxes drawn over it — never six fields.**
///
/// This is the shape MOBILE.md §5.2 insists on, and it is insisting because the
/// web already shipped the other version and lost people to it: SMS autofill
/// and a clipboard paste both deliver all six digits to whichever field has
/// focus, so an implementation with six one-character fields keeps the first
/// digit and silently drops five. The person sees a single digit appear, no
/// error, and no way to understand what happened.
///
/// So there is exactly one `TextField` here. It is transparent and stretched
/// across the whole row; the boxes are decoration painted underneath it from
/// the current value. Autofill, paste, hardware keyboards and screen readers
/// all address the one field, because there is only one thing to address.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'l10n/l10n.dart';

import 'theme.dart';
import 'tokens.dart';
import 'typography.dart';

class OtpField extends StatefulWidget {
  const OtpField({
    super.key,
    required this.onCompleted,
    this.length = 6,
    this.enabled = true,
    this.autofocus = true,
    this.errorText,
  });

  /// Fired once, when the last digit lands — including when all six arrive at
  /// once from autofill, which is the case that matters.
  final ValueChanged<String> onCompleted;

  final int length;
  final bool enabled;
  final bool autofocus;
  final String? errorText;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  String get _value => _controller.text;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
    if (_value.length == widget.length) {
      // Take focus away so the keyboard drops and the person sees the result of
      // what they just did, rather than a keyboard covering it.
      _focus.unfocus();
      widget.onCompleted(_value);
    }
  }

  /// Clears the field, for a rejected code.
  void clear() => _controller.clear();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colors = context.colors;
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            // The boxes. Decoration only — they take no input and hold no state.
            Row(
              children: [
                for (var i = 0; i < widget.length; i++) ...[
                  Expanded(
                    child: _Box(
                      digit: i < _value.length ? _value[i] : null,
                      focused: _focus.hasFocus && i == _value.length,
                      hasError: hasError,
                    ),
                  ),
                  if (i < widget.length - 1) const SizedBox(width: Space.xs),
                ],
              ],
            ),

            // The one real field, invisible and stretched across all of them.
            Positioned.fill(
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                enabled: widget.enabled,
                autofocus: widget.autofocus,
                keyboardType: TextInputType.number,

                /// The whole point.
                ///
                /// On iOS this is what makes the code appear above the keyboard;
                /// on Android it pairs with the SMS Retriever API. Either way
                /// the platform delivers all six characters in one edit, which
                /// only works because one field receives them.
                autofillHints: const [AutofillHints.oneTimeCode],

                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],

                // Invisible: the caret, the text and every border. What the
                // person sees is the boxes underneath.
                showCursor: false,
                cursorColor: Colors.transparent,
                style: const TextStyle(color: Colors.transparent, height: 0.01),
                decoration: const InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  counterText: '',
                ),

                // Announced as one field of N digits, because that is what it
                // is. Six boxes would be six unlabelled fields to a screen
                // reader.
                onTap: () => _focus.requestFocus(),
              ),
            ),
          ],
        ),
        if (hasError) ...[
          const SizedBox(height: Space.xs),
          Text(
            widget.errorText!,
            style: context.text.bodySmall?.copyWith(color: palette.wrong),
          ),
        ] else ...[
          const SizedBox(height: Space.xs),
          Text(
            context.t('Enter the {n}-digit code', {'n': widget.length}),
            style: context.text.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({
    required this.digit,
    required this.focused,
    required this.hasError,
  });

  final String? digit;
  final bool focused;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final palette = context.palette;

    final border = hasError
        ? palette.wrong
        : focused
        ? colors.primary
        : palette.inputBorder;

    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: InterioBeeColors.chalk,
        borderRadius: Radii.smallRadius,
        border: Border.all(color: border, width: focused ? 1.5 : 1),
      ),
      child: Text(
        digit ?? '',
        // Tabular, so the boxes do not shift as digits land.
        style: InterioBeeTextStyles.financialNum.copyWith(color: InterioBeeColors.ink),
      ),
    );
  }
}
