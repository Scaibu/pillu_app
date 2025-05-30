import 'package:flutter/material.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/flutter_chat_ui-main/lib/src/conditional/conditional.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/models/bubble_rtl_alignment.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/models/emoji_enlargement_behavior.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/util.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/message/file_message.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/message/image_message.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/message/message_status.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/message/text_message.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/message/user_avatar.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/state/inherited_chat_theme.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/state/inherited_user.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Base widgets for all message types in the chat. Renders bubbles around
/// messages and status. Sets maximum width for a message for
/// a nice look on larger screens.
class Message extends StatelessWidget {
  /// Creates a particular message from any message type.
  const Message({
    required this.emojiEnlargementBehavior,
    required this.hideBackgroundOnEmojiMessages,
    required this.message,
    required this.messageWidth,
    required this.roundBorder,
    required this.showAvatar,
    required this.showName,
    required this.showStatus,
    required this.isLeftStatus,
    required this.showUserAvatars,
    required this.textMessageOptions,
    required this.usePreviewData,
    super.key,
    this.audioMessageBuilder,
    this.avatarBuilder,
    this.bubbleBuilder,
    this.bubbleRtlAlignment,
    this.customMessageBuilder,
    this.customStatusBuilder,
    this.fileMessageBuilder,
    this.imageHeaders,
    this.imageMessageBuilder,
    this.imageProviderBuilder,
    this.nameBuilder,
    this.onAvatarTap,
    this.onMessageDoubleTap,
    this.onMessageLongPress,
    this.onMessageStatusLongPress,
    this.onMessageStatusTap,
    this.onMessageTap,
    this.onMessageVisibilityChanged,
    this.onPreviewDataFetched,
    this.textMessageBuilder,
    this.userAgent,
    this.videoMessageBuilder,
  });

  /// Build an audio message inside predefined bubble.
  final Widget Function(types.AudioMessage, {required int messageWidth})?
      audioMessageBuilder;

  /// This is to allow custom user avatar builder
  /// By using this we can fetch newest user info based on id.
  final Widget Function(types.User author)? avatarBuilder;

  /// Customize the default bubble using this function. `child` is a content
  /// you should render inside your bubble, `message` is a current message
  /// (contains `author` inside) and `nextMessageInGroup` allows you to see
  /// if the message is a part of a group (messages are grouped when written
  /// in quick succession by the same author).
  final Widget Function(
    Widget child, {
    required types.Message message,
    required bool nextMessageInGroup,
  })? bubbleBuilder;

  /// Determine the alignment of the bubble for RTL languages. Has no effect
  /// for the LTR languages.
  final BubbleRtlAlignment? bubbleRtlAlignment;

  /// Build a custom message inside predefined bubble.
  final Widget Function(types.CustomMessage, {required int messageWidth})?
      customMessageBuilder;

  /// Build a custom status widgets.
  final Widget Function(types.Message message, {required BuildContext context})?
      customStatusBuilder;

  /// Controls the enlargement behavior of the emojis in the
  /// [types.TextMessage].
  /// Defaults to [EmojiEnlargementBehavior.multi].
  final EmojiEnlargementBehavior emojiEnlargementBehavior;

  /// Build a file message inside predefined bubble.
  final Widget Function(types.FileMessage, {required int messageWidth})?
      fileMessageBuilder;

  /// Hide background for messages containing only emojis.
  final bool hideBackgroundOnEmojiMessages;

  final Map<String, String>? imageHeaders;

  /// Build an image message inside predefined bubble.
  final Widget Function(types.ImageMessage, {required int messageWidth})?
      imageMessageBuilder;

  final ImageProvider Function({
    required String uri,
    required Map<String, String>? imageHeaders,
    required Conditional conditional,
  })? imageProviderBuilder;

  /// Any message type.
  final types.Message message;

  /// Maximum message width.
  final int messageWidth;

  /// See [TextMessage.nameBuilder].
  final Widget Function(types.User)? nameBuilder;

  /// See [UserAvatar.onAvatarTap].
  final void Function(types.User)? onAvatarTap;

  /// Called when user double taps on any message.
  final void Function(BuildContext context, types.Message)? onMessageDoubleTap;

  /// Called when user makes a long press on any message.
  final void Function(BuildContext context, types.Message)? onMessageLongPress;

  /// Called when user makes a long press on status icon in any message.
  final void Function(BuildContext context, types.Message)?
      onMessageStatusLongPress;

  /// Called when user taps on status icon in any message.
  final void Function(BuildContext context, types.Message)? onMessageStatusTap;

  /// Called when user taps on any message.
  final void Function(BuildContext context, types.Message)? onMessageTap;

  /// Called when the message's visibility changes.
  final void Function(types.Message, {bool visible})?
      onMessageVisibilityChanged;

  /// See [TextMessage.onPreviewDataFetched].
  final void Function(types.TextMessage, types.PreviewData)?
      onPreviewDataFetched;

  /// Rounds border of the message to visually group messages together.
  final bool roundBorder;

  /// Show user avatar for the received message. Useful for a group chat.
  final bool showAvatar;

  /// See [TextMessage.showName].
  final bool showName;

  /// Show message's status.
  final bool showStatus;

  /// This is used to determine if the status icon should be on the left or
  /// right side of the message.
  /// This is only used when [showStatus] is true.
  /// Defaults to false.
  final bool isLeftStatus;

  /// Show user avatars for received messages. Useful for a group chat.
  final bool showUserAvatars;

  /// Build a text message inside predefined bubble.
  final Widget Function(
    types.TextMessage, {
    required int messageWidth,
    required bool showName,
  })? textMessageBuilder;

  /// See [TextMessage.options].
  final TextMessageOptions textMessageOptions;

  /// See [TextMessage.usePreviewData].
  final bool usePreviewData;

  /// See [TextMessage.userAgent].
  final String? userAgent;

  /// Build an audio message inside predefined bubble.
  final Widget Function(types.VideoMessage, {required int messageWidth})?
      videoMessageBuilder;

  Widget _avatarBuilder() => showAvatar
      ? avatarBuilder?.call(message.author) ??
          UserAvatar(
            author: message.author,
            bubbleRtlAlignment: bubbleRtlAlignment,
            imageHeaders: imageHeaders,
            onAvatarTap: onAvatarTap,
          )
      : const SizedBox(width: 40);

  Widget _bubbleBuilder(
    final BuildContext context,
    final BorderRadius borderRadius,
    final bool currentUserIsAuthor,
    final bool enlargeEmojis,
  ) {
    final Widget defaultMessage =
        (enlargeEmojis && hideBackgroundOnEmojiMessages)
            ? _messageBuilder()
            : DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  color: !currentUserIsAuthor ||
                          message.type == types.MessageType.image
                      ? InheritedChatTheme.of(context).theme.secondaryColor
                      : InheritedChatTheme.of(context).theme.primaryColor,
                ),
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: _messageBuilder(),
                ),
              );
    return bubbleBuilder != null
        ? bubbleBuilder!(
            _messageBuilder(),
            message: message,
            nextMessageInGroup: roundBorder,
          )
        : defaultMessage;
  }

  Widget _messageBuilder() {
    switch (message.type) {
      case types.MessageType.audio:
        final types.AudioMessage audioMessage = message as types.AudioMessage;
        return audioMessageBuilder != null
            ? audioMessageBuilder!(audioMessage, messageWidth: messageWidth)
            : const SizedBox();
      case types.MessageType.custom:
        final types.CustomMessage customMessage =
            message as types.CustomMessage;
        return customMessageBuilder != null
            ? customMessageBuilder!(customMessage, messageWidth: messageWidth)
            : const SizedBox();
      case types.MessageType.file:
        final types.FileMessage fileMessage = message as types.FileMessage;
        return fileMessageBuilder != null
            ? fileMessageBuilder!(fileMessage, messageWidth: messageWidth)
            : FileMessage(message: fileMessage);
      case types.MessageType.image:
        final types.ImageMessage imageMessage = message as types.ImageMessage;
        return imageMessageBuilder != null
            ? imageMessageBuilder!(imageMessage, messageWidth: messageWidth)
            : ImageMessage(
                imageHeaders: imageHeaders,
                imageProviderBuilder: imageProviderBuilder,
                message: imageMessage,
                messageWidth: messageWidth,
              );
      case types.MessageType.text:
        final types.TextMessage textMessage = message as types.TextMessage;
        return textMessageBuilder != null
            ? textMessageBuilder!(
                textMessage,
                messageWidth: messageWidth,
                showName: showName,
              )
            : TextMessage(
                emojiEnlargementBehavior: emojiEnlargementBehavior,
                hideBackgroundOnEmojiMessages: hideBackgroundOnEmojiMessages,
                message: textMessage,
                nameBuilder: nameBuilder,
                onPreviewDataFetched: onPreviewDataFetched,
                options: textMessageOptions,
                showName: showName,
                usePreviewData: usePreviewData,
                userAgent: userAgent,
              );
      case types.MessageType.video:
        final types.VideoMessage videoMessage = message as types.VideoMessage;
        return videoMessageBuilder != null
            ? videoMessageBuilder!(videoMessage, messageWidth: messageWidth)
            : const SizedBox();

      case types.MessageType.system:
        // TODO: Handle this case.
        throw UnimplementedError();
      case types.MessageType.unsupported:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Widget _statusIcon(
    final BuildContext context,
  ) {
    if (!showStatus) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: InheritedChatTheme.of(context).theme.statusIconPadding,
      child: GestureDetector(
        onLongPress: () => onMessageStatusLongPress?.call(context, message),
        onTap: () => onMessageStatusTap?.call(context, message),
        child: customStatusBuilder != null
            ? customStatusBuilder!(message, context: context)
            : MessageStatus(status: message.status),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final MediaQueryData query = MediaQuery.of(context);
    final types.User user = InheritedUser.of(context).user;

    final bool currentUserIsAuthor = _isCurrentAuth(user);

    final bool enlargeEmojis =
        emojiEnlargementBehavior != EmojiEnlargementBehavior.never &&
            message is types.TextMessage &&
            isConsistsOfEmojis(
              emojiEnlargementBehavior,
              message as types.TextMessage,
            );
    final double messageBorderRadius =
        InheritedChatTheme.of(context).theme.messageBorderRadius;
    final BorderRadiusGeometry borderRadius =
        bubbleRtlAlignment == BubbleRtlAlignment.left
            ? BorderRadiusDirectional.only(
                bottomEnd: Radius.circular(
                  !currentUserIsAuthor || roundBorder ? messageBorderRadius : 0,
                ),
                bottomStart: Radius.circular(
                  currentUserIsAuthor || roundBorder ? messageBorderRadius : 0,
                ),
                topEnd: Radius.circular(messageBorderRadius),
                topStart: Radius.circular(messageBorderRadius),
              )
            : BorderRadius.only(
                bottomLeft: Radius.circular(
                  currentUserIsAuthor || roundBorder ? messageBorderRadius : 0,
                ),
                bottomRight: Radius.circular(
                  !currentUserIsAuthor || roundBorder ? messageBorderRadius : 0,
                ),
                topLeft: Radius.circular(messageBorderRadius),
                topRight: Radius.circular(messageBorderRadius),
              );

    final EdgeInsetsGeometry bubbleMargin =
        InheritedChatTheme.of(context).theme.bubbleMargin ??
            (bubbleRtlAlignment == BubbleRtlAlignment.left
                ? EdgeInsetsDirectional.only(
                    bottom: 4,
                    end: isMobile ? query.padding.right : 0,
                    start: 20 + (isMobile ? query.padding.left : 0),
                  )
                : EdgeInsets.only(
                    bottom: 4,
                    left: 20 + (isMobile ? query.padding.left : 0),
                    right: isMobile ? query.padding.right : 0,
                  ));

    return Container(
      alignment: bubbleRtlAlignment == BubbleRtlAlignment.left
          ? currentUserIsAuthor
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart
          : currentUserIsAuthor
              ? Alignment.centerRight
              : Alignment.centerLeft,
      margin: bubbleMargin,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        textDirection: bubbleRtlAlignment == BubbleRtlAlignment.left
            ? null
            : TextDirection.ltr,
        children: <Widget>[
          if (!currentUserIsAuthor && showUserAvatars) _avatarBuilder(),
          if (currentUserIsAuthor && isLeftStatus) _statusIcon(context),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: messageWidth.toDouble(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                GestureDetector(
                  onDoubleTap: () => onMessageDoubleTap?.call(context, message),
                  onLongPress: () => onMessageLongPress?.call(context, message),
                  onTap: () => onMessageTap?.call(context, message),
                  child: onMessageVisibilityChanged != null
                      ? VisibilityDetector(
                          key: Key(message.id),
                          onVisibilityChanged:
                              (final VisibilityInfo visibilityInfo) =>
                                  onMessageVisibilityChanged!(
                            message,
                            visible: visibilityInfo.visibleFraction > 0.1,
                          ),
                          child: _bubbleBuilder(
                            context,
                            borderRadius.resolve(Directionality.of(context)),
                            currentUserIsAuthor,
                            enlargeEmojis,
                          ),
                        )
                      : _bubbleBuilder(
                          context,
                          borderRadius.resolve(Directionality.of(context)),
                          currentUserIsAuthor,
                          enlargeEmojis,
                        ),
                ),
              ],
            ),
          ),
          if (currentUserIsAuthor && !isLeftStatus) _statusIcon(context),
        ],
      ),
    );
  }

  /// Checks whether the provided user is the author of the current message.
  ///
  /// This method compares the given user's unique identifier (`id`)
  /// against the author id of the current message. It returns `true`
  /// if the user is the author, and `false` otherwise. This is typically
  /// used to determine message alignment or permissions (e.g., editing/deleting).
  ///
  /// Parameters:
  /// - [user]: The user to compare against the message author.
  ///
  /// Returns:
  /// - A boolean indicating if the user is the message author.
  bool _isCurrentAuth(final types.User user) {
    /// Compare the provided user's id with the message author's id
    final bool currentUserIsAuthor = user.id == message.author.id;

    /// Return true if they match; false otherwise
    return currentUserIsAuthor;
  }
}
