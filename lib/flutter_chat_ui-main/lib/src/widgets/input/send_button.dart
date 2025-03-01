import 'package:flutter/material.dart';
import 'package:pillu_app/config/app_config.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/state/inherited_chat_theme.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/state/inherited_l10n.dart';

/// A class that represents send button widgets.
class SendButton extends StatelessWidget {
  /// Creates send button widgets.
  const SendButton({
    required this.onPressed,
    super.key,
    this.padding = EdgeInsets.zero,
  });

  /// Callback for send button tap event.
  final VoidCallback onPressed;

  /// Padding around the button.
  final EdgeInsets padding;

  @override
  Widget build(final BuildContext context) => Container(
        margin: InheritedChatTheme.of(context).theme.sendButtonMargin ??
            const EdgeInsetsDirectional.fromSTEB(0, 0, 8, 0),
        child: Semantics(
          label: InheritedL10n.of(context).l10n.sendButtonAccessibilityLabel,
          child: IconButton(
            constraints: const BoxConstraints(
              minHeight: 24,
              minWidth: 24,
            ),
            icon: InheritedChatTheme.of(context).theme.sendButtonIcon ??
                ((AppConfig.isPackage)
                    ? Image.asset(
                        'packages/pillu_app/flutter_chat_ui-main/lib/assets/icon-send.png',
                        color:
                            InheritedChatTheme.of(context).theme.inputTextColor,
                      )
                    : Image.asset(
                        'lib/flutter_chat_ui-main/lib/assets/icon-send.png',
                        color:
                            InheritedChatTheme.of(context).theme.inputTextColor,
                      )),
            onPressed: onPressed,
            padding: padding,
            splashRadius: 24,
            tooltip:
                InheritedL10n.of(context).l10n.sendButtonAccessibilityLabel,
          ),
        ),
      );
}
