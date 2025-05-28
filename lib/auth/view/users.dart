import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  Widget _buildAvatar(final types.User user) {
    final Color color = getUserAvatarNameColor(user);
    final bool hasImage = user.imageUrl != null;
    final String name = getUserName(user);

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: hasImage ? Colors.transparent : color,
        backgroundImage: hasImage ? NetworkImage(user.imageUrl!) : null,
        minRadius: 40,
        child: !hasImage
            ? Text(
                name.isEmpty ? '' : name[0].toUpperCase(),
                style: buildJostTextStyle(color: Colors.white),
              )
            : null,
      ),
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
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) => ThemeWrapper(
        child: Scaffold(
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            centerTitle: true,
            title: ThemeWrapper(
              child: Text(
                'Chat Users',
                style: buildJostTextStyle(fontSize: 14),
              ),
            ),
          ),
          body: StreamBuilder<List<types.User>>(
            stream: FirebaseChatCore.instance.users(),
            initialData: const <types.User>[],
            builder: (
              final BuildContext context,
              final AsyncSnapshot<List<types.User>> snapshot,
            ) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 200),
                  child: Text(
                    'No users',
                    style: buildJostTextStyle(fontSize: 14),
                  ),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (final BuildContext context, final int index) {
                  final types.User user = snapshot.data![index];
                  return listUserItemComponent(user, context);
                },
              );
            },
          ),
        ),
      );

  Widget listUserItemComponent(
    final types.User user,
    final BuildContext context,
  ) =>
      CustomSelectionTapEffectButton(
        onTap: () async {
          await _handlePressed(user, context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: <Widget>[
              _buildAvatar(user),
              Text(getUserName(user), style: buildJostTextStyle(fontSize: 14)),
            ],
          ),
        ),
      );
}
