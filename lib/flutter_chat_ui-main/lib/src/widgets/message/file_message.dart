import 'package:flutter/material.dart';
import 'package:pillu_app/config/app_config.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/flutter_chat_ui-main/lib/src/util.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/state/inherited_chat_theme.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/state/inherited_l10n.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/state/inherited_user.dart';

/// A class that represents file message widgets.
class FileMessage extends StatelessWidget {
  /// Creates a file message widgets based on a [types.FileMessage].
  const FileMessage({
    required this.message,
    super.key,
  });

  /// [types.FileMessage].
  final types.FileMessage message;

  @override
  Widget build(final BuildContext context) {
    final types.User user = InheritedUser.of(context).user;
    final Color color = user.id == message.author.id
        ? InheritedChatTheme.of(context).theme.sentMessageDocumentIconColor
        : InheritedChatTheme.of(context).theme.receivedMessageDocumentIconColor;

    return Semantics(
      label: InheritedL10n.of(context).l10n.fileButtonAccessibilityLabel,
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(
          InheritedChatTheme.of(context).theme.messageInsetsVertical,
          InheritedChatTheme.of(context).theme.messageInsetsVertical,
          InheritedChatTheme.of(context).theme.messageInsetsHorizontal,
          InheritedChatTheme.of(context).theme.messageInsetsVertical,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(21),
              ),
              height: 42,
              width: 42,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  if (message.isLoading ?? false)
                    Positioned.fill(
                      child: CircularProgressIndicator(
                        color: color,
                        strokeWidth: 2,
                      ),
                    ),
                  if (InheritedChatTheme.of(context).theme.documentIcon != null)
                    InheritedChatTheme.of(context).theme.documentIcon!
                  else
                    ((AppConfig.isPackage)
                        ? Image.asset(
                            'pillu_assets/icon-document.png',
                            color: InheritedChatTheme.of(context)
                                .theme
                                .inputTextColor,
                          )
                        : Image.asset(
                            'lib/flutter_chat_ui-main/lib/pillu_assets/icon-document.png',
                            color: InheritedChatTheme.of(context)
                                .theme
                                .inputTextColor,
                          )),
                ],
              ),
            ),
            Flexible(
              child: Container(
                margin: const EdgeInsetsDirectional.only(
                  start: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      message.name,
                      style: user.id == message.author.id
                          ? InheritedChatTheme.of(context)
                              .theme
                              .sentMessageBodyTextStyle
                          : InheritedChatTheme.of(context)
                              .theme
                              .receivedMessageBodyTextStyle,
                      textWidthBasis: TextWidthBasis.longestLine,
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 4,
                      ),
                      child: Text(
                        formatBytes(message.size.truncate()),
                        style: user.id == message.author.id
                            ? InheritedChatTheme.of(context)
                                .theme
                                .sentMessageCaptionTextStyle
                            : InheritedChatTheme.of(context)
                                .theme
                                .receivedMessageCaptionTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
