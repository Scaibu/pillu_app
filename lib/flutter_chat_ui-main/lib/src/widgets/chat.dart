import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart' show PhotoViewComputedScale;
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/flutter_chat_ui-main/lib/src/chat_l10n.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/chat_theme.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/conditional/conditional.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/models/bubble_rtl_alignment.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/models/date_header.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/models/emoji_enlargement_behavior.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/models/message_spacer.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/models/preview_image.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/models/unread_header_data.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/util.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/chat_list.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/image_gallery.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/input/input.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/message/message.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/message/system_message.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/message/text_message.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/state/inherited_chat_theme.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/state/inherited_l10n.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/state/inherited_user.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/typing_indicator.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/unread_header.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

/// Keep track of all the auto scroll indices by their respective message's id
/// to allow animating to them.
final Map<String, int> chatMessageAutoScrollIndexById = <String, int>{};

/// Entry widgets, represents the complete chat. If you wrap it in [SafeArea]
/// and
/// it should be full screen, set [SafeArea]'s `bottom` to `false`.
class Chat extends StatefulWidget {
  /// Creates a chat widgets.
  const Chat({
    super.key,
    this.audioMessageBuilder,
    this.avatarBuilder,
    this.bubbleBuilder,
    this.bubbleRtlAlignment = BubbleRtlAlignment.right,
    this.customBottomWidget,
    this.customDateHeaderText,
    this.customMessageBuilder,
    this.customStatusBuilder,
    this.dateFormat,
    this.dateHeaderBuilder,
    this.dateHeaderThreshold = 900000,
    this.dateIsUtc = false,
    this.dateLocale,
    this.disableImageGallery,
    this.emojiEnlargementBehavior = EmojiEnlargementBehavior.multi,
    this.emptyState,
    this.fileMessageBuilder,
    this.groupMessagesThreshold = 60000,
    this.hideBackgroundOnEmojiMessages = true,
    this.imageGalleryOptions = const ImageGalleryOptions(
      maxScale: PhotoViewComputedScale.covered,
      minScale: PhotoViewComputedScale.contained,
    ),
    this.imageHeaders,
    this.imageMessageBuilder,
    this.imageProviderBuilder,
    this.inputOptions = const InputOptions(),
    this.isAttachmentUploading,
    this.isLastPage,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.l10n = const ChatL10nEn(),
    this.listBottomWidget,
    required this.messages,
    this.nameBuilder,
    this.onAttachmentPressed,
    this.onAvatarTap,
    this.onBackgroundTap,
    this.onEndReached,
    this.onEndReachedThreshold,
    this.onMessageDoubleTap,
    this.onMessageLongPress,
    this.onMessageStatusLongPress,
    this.onMessageStatusTap,
    required this.onMessageTap,
    this.onMessageVisibilityChanged,
    this.onPreviewDataFetched,
    required this.onSendPressed,
    this.scrollController,
    this.scrollPhysics,
    this.scrollToUnreadOptions = const ScrollToUnreadOptions(),
    this.showUserAvatars = false,
    this.showUserNames = false,
    this.systemMessageBuilder,
    this.textMessageBuilder,
    this.textMessageOptions = const TextMessageOptions(),
    this.theme = const DefaultChatTheme(),
    this.timeFormat,
    this.typingIndicatorOptions = const TypingIndicatorOptions(),
    this.usePreviewData = true,
    required this.user,
    this.userAgent,
    this.useTopSafeAreaInset,
    this.videoMessageBuilder,
    this.slidableMessageBuilder,
    this.isLeftStatus = false,
    this.messageWidthRatio = 0.72,
  });

  /// See [Message.audioMessageBuilder].
  final Widget Function(types.AudioMessage, {required int messageWidth})?
      audioMessageBuilder;

  /// See [Message.avatarBuilder].
  final Widget Function(types.User author)? avatarBuilder;

  /// See [Message.bubbleBuilder].
  final Widget Function(
    Widget child, {
    required types.Message message,
    required bool nextMessageInGroup,
  })? bubbleBuilder;

  /// See [Message.bubbleRtlAlignment].
  final BubbleRtlAlignment? bubbleRtlAlignment;

  /// Allows you to replace the default Input widgets e.g. if you want to
  /// create a channel view. If you're looking for the bottom widgets added
  /// to the chat list, see [listBottomWidget] instead.
  final Widget? customBottomWidget;

  /// If [dateFormat], [dateLocale] and/or [timeFormat] is not enough to customize date headers in your case, use this to return an arbitrary string based on a [DateTime] of a particular message. Can be helpful to return "Today" if [DateTime] is today. IMPORTANT: this will replace all default date headers, so you must handle all cases yourself, like for example today, yesterday and before. Or you can just return the same date header for any message.
  final String Function(DateTime)? customDateHeaderText;

  /// See [Message.customMessageBuilder].
  final Widget Function(types.CustomMessage, {required int messageWidth})?
      customMessageBuilder;

  /// See [Message.customStatusBuilder].
  final Widget Function(types.Message message, {required BuildContext context})?
      customStatusBuilder;

  /// Allows you to customize the date format. IMPORTANT: only for the date,
  /// do not return time here. See [timeFormat] to customize the time format.
  /// [dateLocale] will be ignored if you use this, so if you want a localized
  /// date make sure you initialize your [DateFormat] with a locale. See
  /// [customDateHeaderText] for more customization.
  final DateFormat? dateFormat;

  /// Custom date header builder gives ability to customize date header widgets.
  final Widget Function(DateHeader)? dateHeaderBuilder;

  /// Time (in ms) between two messages when we will render a date header.
  /// Default value is 15 minutes, 900000 ms. When time between two messages
  /// is higher than this threshold, date header will be rendered. Also,
  /// not related to this value, date header will be rendered on every new day.
  final int dateHeaderThreshold;

  /// Use utc time to convert message milliseconds to date.
  final bool dateIsUtc;

  /// Locale will be passed to the `Intl` package. Make sure you initialized
  /// date formatting in your app before passing any locale here, otherwise
  /// an error will be thrown. Also see [customDateHeaderText], [dateFormat],
  /// [timeFormat].
  final String? dateLocale;

  /// Disable automatic image preview on tap.
  final bool? disableImageGallery;

  /// See [Message.emojiEnlargementBehavior].
  final EmojiEnlargementBehavior emojiEnlargementBehavior;

  /// Allows you to change what the user sees when there are no messages.
  /// `emptyChatPlaceholder` and `emptyChatPlaceholderTextStyle` are ignored
  /// in this case.
  final Widget? emptyState;

  /// See [Message.fileMessageBuilder].
  final Widget Function(types.FileMessage, {required int messageWidth})?
      fileMessageBuilder;

  /// Time (in ms) between two messages when we will visually group them.
  /// Default value is 1 minute, 60000 ms. When time between two messages
  /// is lower than this threshold, they will be visually grouped.
  final int groupMessagesThreshold;

  /// See [Message.hideBackgroundOnEmojiMessages].
  final bool hideBackgroundOnEmojiMessages;

  /// See [ImageGallery.options].
  final ImageGalleryOptions imageGalleryOptions;

  /// Headers passed to all network images used in the chat.
  final Map<String, String>? imageHeaders;

  /// See [Message.imageMessageBuilder].
  final Widget Function(types.ImageMessage, {required int messageWidth})?
      imageMessageBuilder;

  /// This feature allows you to use a custom image provider.
  /// This is useful if you want to manage image loading yourself, or
  /// if you need to cache images.
  /// You can also use the `cached_network_image` feature, but when it comes
  /// to caching, you might want to decide on a per-message basis.
  /// Plus, by using this provider, you can choose whether or not to send
  /// specific headers based on the URL.
  final ImageProvider Function({
    required String uri,
    required Map<String, String>? imageHeaders,
    required Conditional conditional,
  })? imageProviderBuilder;

  /// See [Input.options].
  final InputOptions inputOptions;

  /// See [Input.isAttachmentUploading].
  final bool? isAttachmentUploading;

  /// See [ChatList.isLastPage].
  final bool? isLastPage;

  /// See [ChatList.keyboardDismissBehavior].
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Localized copy. Extend [ChatL10n] class to create your own copy or use
  /// existing one, like the default [ChatL10nEn]. You can customize only
  /// certain properties, see more here [ChatL10nEn].
  final ChatL10n l10n;

  /// See [ChatList.bottomWidget]. For a custom chat input
  /// use [customBottomWidget] instead.
  final Widget? listBottomWidget;

  /// List of [types.Message] to render in the chat widgets.
  final List<types.Message> messages;

  /// See [Message.nameBuilder].
  final Widget Function(types.User)? nameBuilder;

  /// See [Input.onAttachmentPressed].
  final VoidCallback? onAttachmentPressed;

  /// See [Message.onAvatarTap].
  final void Function(types.User)? onAvatarTap;

  /// Called when user taps on background.
  final VoidCallback? onBackgroundTap;

  /// See [ChatList.onEndReached].
  final Future<void> Function()? onEndReached;

  /// See [ChatList.onEndReachedThreshold].
  final double? onEndReachedThreshold;

  /// See [Message.onMessageDoubleTap].
  final void Function(BuildContext context, types.Message)? onMessageDoubleTap;

  /// See [Message.onMessageLongPress].
  final void Function(BuildContext context, types.Message)? onMessageLongPress;

  /// See [Message.onMessageStatusLongPress].
  final void Function(BuildContext context, types.Message)?
      onMessageStatusLongPress;

  /// See [Message.onMessageStatusTap].
  final void Function(BuildContext context, types.Message)? onMessageStatusTap;

  /// See [Message.onMessageTap].
  final void Function(BuildContext context, types.Message) onMessageTap;

  /// See [Message.onMessageVisibilityChanged].
  final void Function(types.Message, {bool visible})?
      onMessageVisibilityChanged;

  /// See [Message.onPreviewDataFetched].
  final void Function(types.TextMessage, types.PreviewData)?
      onPreviewDataFetched;

  /// See [Input.onSendPressed].
  final void Function(types.PartialText) onSendPressed;

  /// See [ChatList.scrollController].
  /// If provided, you cannot use the scroll to message functionality.
  final AutoScrollController? scrollController;

  /// See [ChatList.scrollPhysics].
  final ScrollPhysics? scrollPhysics;

  /// Controls if and how the chat should scroll to the newest unread message.
  final ScrollToUnreadOptions scrollToUnreadOptions;

  /// See [Message.showUserAvatars].
  final bool showUserAvatars;

  /// Show user names for received messages. Useful for a group chat. Will be
  /// shown only on text messages.
  final bool showUserNames;

  /// Builds a system message outside of any bubble.
  final Widget Function(types.SystemMessage)? systemMessageBuilder;

  /// See [Message.textMessageBuilder].
  final Widget Function(
    types.TextMessage, {
    required int messageWidth,
    required bool showName,
  })? textMessageBuilder;

  /// See [Message.textMessageOptions].
  final TextMessageOptions textMessageOptions;

  /// Chat theme. Extend [ChatTheme] class to create your own theme or use
  /// existing one, like the [DefaultChatTheme]. You can customize only certain
  /// properties, see more here [DefaultChatTheme].
  final ChatTheme theme;

  /// Allows you to customize the time format. IMPORTANT: only for the time,
  /// do not return date here. See [dateFormat] to customize the date format.
  /// [dateLocale] will be ignored if you use this, so if you want a localized
  /// time make sure you initialize your [DateFormat] with a locale. See
  /// [customDateHeaderText] for more customization.
  final DateFormat? timeFormat;

  /// Used to show typing users with indicator. See [TypingIndicatorOptions].
  final TypingIndicatorOptions typingIndicatorOptions;

  /// See [Message.usePreviewData].
  final bool usePreviewData;

  /// See [InheritedUser.user].
  final types.User user;

  /// See [Message.userAgent].
  final String? userAgent;

  /// See [ChatList.useTopSafeAreaInset].
  final bool? useTopSafeAreaInset;

  /// See [Message.videoMessageBuilder].
  final Widget Function(types.VideoMessage, {required int messageWidth})?
      videoMessageBuilder;

  final Widget Function(types.Message, Widget msgWidget)?
      slidableMessageBuilder;

  /// See [Message.isLeftStatus].
  /// If true, status will be shown on the left side of the message.
  /// If false, status will be shown on the right side of the message.
  /// Default value is false.
  final bool isLeftStatus;

  /// Width ratio for message bubble.
  final double messageWidthRatio;

  @override
  State<Chat> createState() => ChatState();
}

/// [Chat] widgets state.
class ChatState extends State<Chat> {
  /// Used to get the correct auto scroll index from .
  static const String _unreadHeaderId = 'unread_header_id';

  List<Object> _chatMessages = <Object>[];
  List<PreviewImage> _gallery = <PreviewImage>[];
  PageController? _galleryPageController;
  bool _hadScrolledToUnreadOnOpen = false;
  bool _isImageViewVisible = false;

  late final AutoScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = widget.scrollController ?? AutoScrollController();

    didUpdateWidget(widget);
  }

  /// Scroll to the unread header.
  Future<void> scrollToUnreadHeader() async {
    final int? unreadHeaderIndex =
        chatMessageAutoScrollIndexById[_unreadHeaderId];
    if (unreadHeaderIndex != null) {
      await _scrollController.scrollToIndex(
        unreadHeaderIndex,
        duration: widget.scrollToUnreadOptions.scrollDuration,
      );
    }
  }

  /// Scroll to the message with the specified [id].
  Future<void> scrollToMessage(
    final String id, {
    final Duration? scrollDuration,
    final bool withHighlight = false,
    final Duration? highlightDuration,
    final AutoScrollPosition? preferPosition,
  }) async {
    await _scrollController.scrollToIndex(
      chatMessageAutoScrollIndexById[id]!,
      duration: scrollDuration ?? scrollAnimationDuration,
      preferPosition: preferPosition ?? AutoScrollPosition.middle,
    );
    if (withHighlight) {
      await _scrollController.highlight(
        chatMessageAutoScrollIndexById[id]!,
        highlightDuration: highlightDuration ?? const Duration(seconds: 3),
      );
    }
  }

  /// Highlight the message with the specified [id].
  Future<void> highlightMessage(final String id,
          {final Duration? duration}) async =>
      _scrollController.highlight(
        chatMessageAutoScrollIndexById[id]!,
        highlightDuration: duration ?? const Duration(seconds: 3),
      );

  Widget _emptyStateBuilder() =>
      widget.emptyState ??
      Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Text(
          widget.l10n.emptyChatPlaceholder,
          style: widget.theme.emptyChatPlaceholderTextStyle,
          textAlign: TextAlign.center,
        ),
      );

  /// Only scroll to first unread if there are messages and it is the first
  /// open.
  void _maybeScrollToFirstUnread() {
    if (widget.scrollToUnreadOptions.scrollOnOpen &&
        _chatMessages.isNotEmpty &&
        !_hadScrolledToUnreadOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((final _) async {
        if (mounted) {
          await Future<dynamic>.delayed(
              widget.scrollToUnreadOptions.scrollDelay);
          await scrollToUnreadHeader();
        }
      });
      _hadScrolledToUnreadOnOpen = true;
    }
  }

  /// We need the index for auto scrolling because it will scroll until it
  /// reaches an index higher or equal that what it is scrolling towards.
  /// Index will be null for removed messages. Can just set to
  /// -1 for auto scroll.
  Widget _messageBuilder(
    final Object object,
    final BoxConstraints constraints,
    final int? index,
  ) {
    if (object is DateHeader) {
      return widget.dateHeaderBuilder?.call(object) ??
          Container(
            alignment: Alignment.center,
            margin: widget.theme.dateDividerMargin,
            child: Text(
              object.text,
              style: widget.theme.dateDividerTextStyle,
            ),
          );
    } else if (object is MessageSpacer) {
      return SizedBox(
        height: object.height,
      );
    } else if (object is UnreadHeaderData) {
      return AutoScrollTag(
        controller: _scrollController,
        index: index ?? -1,
        key: const Key('unread_header'),
        child: UnreadHeader(
          marginTop: object.marginTop,
        ),
      );
    } else {
      final Map<String, Object> map = object as Map<String, Object>;
      final types.Message message = map['message']! as types.Message;

      final Widget messageWidget;

      if (message is types.SystemMessage) {
        messageWidget = widget.systemMessageBuilder?.call(message) ??
            SystemMessage(message: message.text);
      } else {
        final double maxWidth = widget.theme.messageMaxWidth;
        final int messageWidth =
            widget.showUserAvatars && message.author.id != widget.user.id
                ? min(constraints.maxWidth * widget.messageWidthRatio, maxWidth)
                    .floor()
                : min(
                    constraints.maxWidth * (widget.messageWidthRatio + 0.06),
                    maxWidth,
                  ).floor();
        final Widget msgWidget = Message(
          audioMessageBuilder: widget.audioMessageBuilder,
          avatarBuilder: widget.avatarBuilder,
          bubbleBuilder: widget.bubbleBuilder,
          bubbleRtlAlignment: widget.bubbleRtlAlignment,
          customMessageBuilder: widget.customMessageBuilder,
          customStatusBuilder: widget.customStatusBuilder,
          emojiEnlargementBehavior: widget.emojiEnlargementBehavior,
          fileMessageBuilder: widget.fileMessageBuilder,
          hideBackgroundOnEmojiMessages: widget.hideBackgroundOnEmojiMessages,
          imageHeaders: widget.imageHeaders,
          imageMessageBuilder: widget.imageMessageBuilder,
          imageProviderBuilder: widget.imageProviderBuilder,
          message: message,
          messageWidth: messageWidth,
          nameBuilder: widget.nameBuilder,
          onAvatarTap: widget.onAvatarTap,
          onMessageDoubleTap: widget.onMessageDoubleTap,
          onMessageLongPress: widget.onMessageLongPress,
          onMessageStatusLongPress: widget.onMessageStatusLongPress,
          onMessageStatusTap: widget.onMessageStatusTap,
          onMessageTap:
              (final BuildContext context, final types.Message tappedMessage) {
            if (tappedMessage is types.ImageMessage &&
                widget.disableImageGallery != true) {
              _onImagePressed(tappedMessage);
            }

            widget.onMessageTap.call(context, tappedMessage);
          },
          onMessageVisibilityChanged: widget.onMessageVisibilityChanged,
          onPreviewDataFetched: _onPreviewDataFetched,
          roundBorder: map['nextMessageInGroup'] == true,
          showAvatar: map['nextMessageInGroup'] == false,
          showName: map['showName'] == true,
          showStatus: map['showStatus'] == true,
          isLeftStatus: widget.isLeftStatus,
          showUserAvatars: widget.showUserAvatars,
          textMessageBuilder: widget.textMessageBuilder,
          textMessageOptions: widget.textMessageOptions,
          usePreviewData: widget.usePreviewData,
          userAgent: widget.userAgent,
          videoMessageBuilder: widget.videoMessageBuilder,
        );
        messageWidget = widget.slidableMessageBuilder == null
            ? msgWidget
            : widget.slidableMessageBuilder!(message, msgWidget);
      }

      return AutoScrollTag(
        controller: _scrollController,
        index: index ?? -1,
        key: Key('scroll-${message.id}'),
        highlightColor: widget.theme.highlightMessageColor,
        child: messageWidget,
      );
    }
  }

  void _onCloseGalleryPressed() {
    setState(() {
      _isImageViewVisible = false;
    });
    _galleryPageController?.dispose();
    _galleryPageController = null;
  }

  void _onImagePressed(final types.ImageMessage message) {
    final int initialPage = _gallery.indexWhere(
      (final PreviewImage element) =>
          element.id == message.id && element.uri == message.uri,
    );
    _galleryPageController = PageController(initialPage: initialPage);
    setState(() {
      _isImageViewVisible = true;
    });
  }

  void _onPreviewDataFetched(
    final types.TextMessage message,
    final types.PreviewData previewData,
  ) {
    widget.onPreviewDataFetched?.call(message, previewData);
  }

  /// Updates the [chatMessageAutoScrollIndexById] mapping with the latest
  /// messages.
  void _refreshAutoScrollMapping() {
    chatMessageAutoScrollIndexById.clear();
    int i = 0;
    for (final Object object in _chatMessages) {
      if (object is UnreadHeaderData) {
        chatMessageAutoScrollIndexById[_unreadHeaderId] = i;
      } else if (object is Map<String, Object>) {
        final types.Message message = object['message']! as types.Message;
        chatMessageAutoScrollIndexById[message.id] = i;
      }
      i++;
    }
  }

  @override
  void didUpdateWidget(covariant final Chat oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.messages.isNotEmpty) {
      final List<Object> result = calculateChatMessages(
        widget.messages,
        widget.user,
        customDateHeaderText: widget.customDateHeaderText,
        dateFormat: widget.dateFormat,
        dateHeaderThreshold: widget.dateHeaderThreshold,
        dateIsUtc: widget.dateIsUtc,
        dateLocale: widget.dateLocale,
        groupMessagesThreshold: widget.groupMessagesThreshold,
        lastReadMessageId: widget.scrollToUnreadOptions.lastReadMessageId,
        showUserNames: widget.showUserNames,
        timeFormat: widget.timeFormat,
      );

      _chatMessages = result[0] as List<Object>;
      _gallery = result[1] as List<PreviewImage>;

      _refreshAutoScrollMapping();
      _maybeScrollToFirstUnread();
    }
  }

  @override
  void dispose() {
    _galleryPageController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => InheritedUser(
        user: widget.user,
        child: InheritedChatTheme(
          theme: widget.theme,
          child: InheritedL10n(
            l10n: widget.l10n,
            child: Stack(
              children: <Widget>[
                Container(
                  color: widget.theme.backgroundColor,
                  child: Column(
                    children: <Widget>[
                      Flexible(
                        child: widget.messages.isEmpty
                            ? SizedBox.expand(
                                child: _emptyStateBuilder(),
                              )
                            : GestureDetector(
                                onTap: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  widget.onBackgroundTap?.call();
                                },
                                child: LayoutBuilder(
                                  builder: (
                                    final BuildContext context,
                                    final BoxConstraints constraints,
                                  ) =>
                                      ChatList(
                                    bottomWidget: widget.listBottomWidget,
                                    bubbleRtlAlignment:
                                        widget.bubbleRtlAlignment!,
                                    isLastPage: widget.isLastPage,
                                    itemBuilder:
                                        (final Object item, final int? index) =>
                                            _messageBuilder(
                                      item,
                                      constraints,
                                      index,
                                    ),
                                    items: _chatMessages,
                                    keyboardDismissBehavior:
                                        widget.keyboardDismissBehavior,
                                    onEndReached: widget.onEndReached,
                                    onEndReachedThreshold:
                                        widget.onEndReachedThreshold,
                                    scrollController: _scrollController,
                                    scrollPhysics: widget.scrollPhysics,
                                    typingIndicatorOptions:
                                        widget.typingIndicatorOptions,
                                    useTopSafeAreaInset:
                                        widget.useTopSafeAreaInset ?? isMobile,
                                  ),
                                ),
                              ),
                      ),
                      widget.customBottomWidget ??
                          Input(
                            isAttachmentUploading: widget.isAttachmentUploading,
                            onAttachmentPressed: widget.onAttachmentPressed,
                            onSendPressed: widget.onSendPressed,
                            options: widget.inputOptions,
                          ),
                    ],
                  ),
                ),
                if (_isImageViewVisible)
                  ImageGallery(
                    imageHeaders: widget.imageHeaders,
                    imageProviderBuilder: widget.imageProviderBuilder,
                    images: _gallery,
                    pageController: _galleryPageController!,
                    onClosePressed: _onCloseGalleryPressed,
                    options: widget.imageGalleryOptions,
                  ),
              ],
            ),
          ),
        ),
      );
}
