import 'package:flutter/material.dart';
import 'package:pillu_app/core/library/flutter_chat_ui.dart';
import 'package:pillu_app/shared/text_styles.dart';

DefaultChatTheme buildChatTheme(final BuildContext context) => DefaultChatTheme(
      // Base colors

      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      primaryColor: Theme.of(context).primaryColor,
      secondaryColor: Theme.of(context).colorScheme.secondary,
      errorColor: Colors.red,

      // Input styling
      inputBackgroundColor: Theme.of(context).cardColor,
      inputSurfaceTintColor: Theme.of(context).cardColor,
      inputTextColor: Theme.of(context).textTheme.bodyLarge!.color!,
      inputTextStyle: buildJostTextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontSize: 12,
      ),
      inputPadding: const EdgeInsets.all(16),

      // Received message styling
      messageInsetsHorizontal: 12,
      messageInsetsVertical: 8,
      receivedMessageBodyTextStyle: buildJostTextStyle(
        color: Theme.of(context).cardColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      receivedMessageCaptionTextStyle: buildJostTextStyle(
        color: Theme.of(context).hintColor,
        fontSize: 10,
      ),
      receivedMessageLinkTitleTextStyle: buildJostTextStyle(
        color: Theme.of(context).cardColor,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
      receivedMessageLinkDescriptionTextStyle: buildJostTextStyle(
        color: Theme.of(context).cardColor,
      ),

      // Sent message styling
      sentMessageBodyTextStyle: buildJostTextStyle(
        color: Theme.of(context).cardColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      sentMessageCaptionTextStyle: buildJostTextStyle(
        color: Theme.of(context).hintColor..withAlpha(75),
        fontSize: 10,
      ),
      sentMessageLinkTitleTextStyle: buildJostTextStyle(
        color: Theme.of(context).cardColor,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
      emptyChatPlaceholderTextStyle: buildJostTextStyle(
        color: Theme.of(context).dividerColor,
      ),
      sentMessageLinkDescriptionTextStyle: buildJostTextStyle(
        color: Theme.of(context).cardColor,
      ),

      // Date divider styling
      dateDividerTextStyle: buildJostTextStyle(
        fontSize: 10,
        color: Theme.of(context).hintColor,
        fontWeight: FontWeight.w800,
      ),

      // User styling
      userNameTextStyle: buildJostTextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
      userAvatarTextStyle: buildJostTextStyle(
        color: Theme.of(context).cardColor,
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),

      // System message styling
      systemMessageTheme: SystemMessageTheme(
        margin: const EdgeInsets.only(
          bottom: 24,
          top: 8,
          left: 8,
          right: 8,
        ),
        textStyle: buildJostTextStyle(
          color: Theme.of(context).hintColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),

      // Typing indicator styling
      typingIndicatorTheme: TypingIndicatorTheme(
        bubbleColor: Theme.of(context).cardColor,
        animatedCirclesColor: Theme.of(context).hintColor.withAlpha(50),
        bubbleBorder: const BorderRadius.all(Radius.circular(27)),
        animatedCircleSize: 5,
        countAvatarColor: Theme.of(context).primaryColor,
        countTextColor: Theme.of(context).colorScheme.secondary,
        multipleUserTextStyle: buildJostTextStyle(
          fontSize: 10,
          color: Theme.of(context).hintColor,
        ),
      ),
    );
