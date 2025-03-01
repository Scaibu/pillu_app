import 'package:flutter/material.dart';
import 'package:pillu_app/config/app_config.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/state/inherited_chat_theme.dart';

/// A class that represents a message status.
class MessageStatus extends StatelessWidget {
  /// Creates a message status widgets.
  const MessageStatus({
    required this.status,
    super.key,
  });

  /// Status of the message.
  final types.Status? status;

  @override
  Widget build(final BuildContext context) {
    switch (status) {
      case types.Status.delivered:
      case types.Status.sent:
        return InheritedChatTheme.of(context).theme.deliveredIcon != null
            ? InheritedChatTheme.of(context).theme.deliveredIcon!
            : ((AppConfig.isPackage)
                ? Image.asset(
                    'packages/pillu_app/flutter_chat_ui-main/lib/assets/icon-delivered.png',
                    color: InheritedChatTheme.of(context).theme.inputTextColor,
                  )
                : Image.asset(
                    'lib/flutter_chat_ui-main/lib/assets/icon-delivered.png',
                    color: InheritedChatTheme.of(context).theme.inputTextColor,
                  ));
      case types.Status.error:
        return InheritedChatTheme.of(context).theme.errorIcon != null
            ? InheritedChatTheme.of(context).theme.errorIcon!
            : ((AppConfig.isPackage)
                ? Image.asset(
                    'packages/pillu_app/flutter_chat_ui-main/lib/assets/icon-error.png',
                    color: InheritedChatTheme.of(context).theme.inputTextColor,
                  )
                : Image.asset(
                    'lib/flutter_chat_ui-main/lib/assets/icon-error.png',
                    color: InheritedChatTheme.of(context).theme.inputTextColor,
                  ));
      case types.Status.seen:
        return InheritedChatTheme.of(context).theme.seenIcon != null
            ? InheritedChatTheme.of(context).theme.seenIcon!
            : ((AppConfig.isPackage)
                ? Image.asset(
                    'packages/pillu_app/flutter_chat_ui-main/lib/assets/icon-seen.png',
                    color: InheritedChatTheme.of(context).theme.inputTextColor,
                  )
                : Image.asset(
                    'lib/flutter_chat_ui-main/lib/assets/icon-seen.png',
                    color: InheritedChatTheme.of(context).theme.inputTextColor,
                  ));
      case types.Status.sending:
        return InheritedChatTheme.of(context).theme.sendingIcon != null
            ? InheritedChatTheme.of(context).theme.sendingIcon!
            : Center(
                child: SizedBox(
                  height: 10,
                  width: 10,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      InheritedChatTheme.of(context).theme.primaryColor,
                    ),
                  ),
                ),
              );
      default:
        return const SizedBox(width: 8);
    }
  }
}
