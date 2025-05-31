import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  Widget _buildAvatar(final types.User user, final ThemeData theme) {
    final Color color = getUserAvatarNameColor(user);
    final bool hasImage = user.imageUrl != null;
    final String name = getUserName(user);

    return CircleAvatar(
      backgroundColor: hasImage ? Colors.transparent : color,
      backgroundImage: hasImage ? NetworkImage(user.imageUrl!) : null,
      radius: 26,
      child: !hasImage && name.isNotEmpty
          ? Text(
              name[0].toUpperCase(),
              style: buildJostTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  Future<void> _handlePressed(
    final types.User otherUser,
    final BuildContext context,
  ) async {
    final NavigatorState navigator = Navigator.of(context);
    final types.Room room =
        await FirebaseChatCore.instance.createRoom(otherUser);
    navigator.pop();
    await navigator.push(
      PageRouteBuilder<dynamic>(
        pageBuilder: (
          final BuildContext context,
          final Animation<double> animation,
          final Animation<double> secondaryAnimation,
        ) =>
            ChatPage(room: room),
        transitionsBuilder: (
          final BuildContext context,
          final Animation<double> animation,
          final Animation<double> secondaryAnimation,
          final Widget child,
        ) =>
            SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero)
              .animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: FadeTransition(opacity: animation, child: child),
        ),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ThemeWrapper(
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          centerTitle: true,
          title: Text(
            'Chat Users',
            style: buildJostTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
        body: StreamBuilder<List<types.User>>(
          stream: FirebaseChatCore.instance.friends(),
          initialData: const <types.User>[],
          builder: (
            final BuildContext context,
            final AsyncSnapshot<List<types.User>> snapshot,
          ) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No users',
                  style: buildJostTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: snapshot.data!.length,
              itemBuilder: (final BuildContext context, final int index) {
                final types.User user = snapshot.data![index];
                return listUserItemComponent(user, context, theme);
              },
            );
          },
        ),
      ),
    );
  }

  Widget listUserItemComponent(
    final types.User user,
    final BuildContext context,
    final ThemeData theme,
  ) =>
      CustomSelectionTapEffectButton(
        onTap: () {}, // No-op here to avoid duplicate navigation.
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              _buildAvatar(user, theme),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  getUserName(user),
                  style: buildJostTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => _handlePressed(user, context),
                style: ElevatedButton.styleFrom(
                  elevation: 3,
                  backgroundColor: theme.colorScheme.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Start Chat',
                  style: buildJostTextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
