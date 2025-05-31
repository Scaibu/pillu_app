import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:pillu_app/shared/navigation.dart';

class ChatRoomList extends StatelessWidget {
  const ChatRoomList({super.key, final User? user}) : _user = user;

  final User? _user;

  Future<void> _goToChatPage(
    final BuildContext context,
    final types.Room room,
  ) async {
    await createPage(context, ChatPage(room: room));
  }

  Widget _buildAvatar(final types.Room room) {
    Color color = Colors.transparent;

    if (room.type == types.RoomType.direct) {
      try {
        final types.User otherUser = room.users.firstWhere(
          (final types.User u) => u.id != _user?.uid,
        );

        color = getUserAvatarNameColor(otherUser);
      } catch (e) {
        /// Do nothing if other user is not found.
      }
    }

    final bool hasImage = room.imageUrl != null;
    final String name = room.name ?? '';

    final NetworkImage? backgroundImage;
    if (hasImage) {
      backgroundImage = NetworkImage(room.imageUrl!);
    } else {
      backgroundImage = null;
    }

    final Widget? child;
    if (!hasImage) {
      final String data;
      if (name.isEmpty) {
        data = '';
      } else {
        data = name[0].toUpperCase();
      }

      child = Text(data, style: const TextStyle(color: Colors.white));
    } else {
      child = const Offstage();
    }

    final Color backgroundColor = hasImage ? Colors.transparent : color;

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: backgroundColor,
        backgroundImage: backgroundImage,
        radius: 30,
        child: child,
      ),
    );
  }

  Widget _buildEmptyState() => Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(bottom: 200),
        child: Text('No rooms', style: buildJostTextStyle()),
      );

  Widget _buildRoomList(
    final List<types.Room> rooms,
    final BuildContext context,
  ) =>
      ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (final BuildContext context, final int index) =>
            _buildRoomItem(rooms[index], context),
      );

  Widget _buildRoomItem(final types.Room room, final BuildContext context) =>
      CustomSelectionTapEffectButton(
        onTap: () async => _goToChatPage(context, room),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              _buildAvatar(room),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  room.name ?? '',
                  style: buildJostTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Theme.of(context).iconTheme.color),
            ],
          ),
        ),
      );

  @override
  Widget build(final BuildContext context) => StreamBuilder<List<types.Room>>(
        stream: FirebaseChatCore.instance.rooms(),
        initialData: const <types.Room>[],
        builder: (
          final BuildContext context,
          final AsyncSnapshot<List<types.Room>> snapshot,
        ) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }
          return _buildRoomList(snapshot.data!, context);
        },
      );
}
