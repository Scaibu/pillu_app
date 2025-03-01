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
                style: const TextStyle(color: Colors.white),
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
      MaterialPageRoute<ChatPage>(
        builder: (final BuildContext context) => ChatPage(room: room),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: const Text('Users'),
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
                child: const Text('No users'),
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
      );

  Widget listUserItemComponent(
    final types.User user,
    final BuildContext context,
  ) =>
      GestureDetector(
        onTap: () async {
          await _handlePressed(user, context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: <Widget>[
              _buildAvatar(user),
              Text(getUserName(user)),
            ],
          ),
        ),
      );
}
