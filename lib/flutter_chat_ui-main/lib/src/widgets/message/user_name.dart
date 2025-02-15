import 'package:flutter/material.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/flutter_chat_ui-main/lib/src/chat_theme.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/util.dart';
import 'package:pillu_app/flutter_chat_ui-main/lib/src/widgets/state/inherited_chat_theme.dart';

/// Renders user's name as a message heading according to the theme.
class UserName extends StatelessWidget {
  /// Creates user name.
  const UserName({
    required this.author,
    super.key,
  });

  /// Author to show name from.
  final types.User author;

  @override
  Widget build(final BuildContext context) {
    final ChatTheme theme = InheritedChatTheme.of(context).theme;
    final Color color =
        getUserAvatarNameColor(author, theme.userAvatarNameColors);
    final String name = getUserName(author);

    return name.isEmpty
        ? const SizedBox()
        : Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.userNameTextStyle.copyWith(color: color),
            ),
          );
  }
}
