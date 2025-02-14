import 'package:pillu_app/auth/view/login.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  bool _error = false;
  bool _initialized = false;
  User? _user;

  @override
  Future<void> initState() async {
    await initializeFlutterFire();
    super.initState();
  }

  Future<void> initializeFlutterFire() async {
    try {
      FirebaseAuth.instance.authStateChanges().listen((final User? user) {
        _user = user;
        setState(() {});
      });

      _initialized = true;
      setState(() {});
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(final BuildContext context) {
    if (_error) {
      return Container();
    }

    if (!_initialized) {
      return Container();
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      body: _user == null ? const LoginComponent() : const ChatRoomList(),
    );
  }

  AppBar _buildAppBar(final BuildContext context) => AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              if (_user != null) {
                await Navigator.of(context).push(
                  MaterialPageRoute<UsersPage>(
                    fullscreenDialog: true,
                    builder: (final BuildContext context) => const UsersPage(),
                  ),
                );
              }
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            if (_user != null) {
              await logout();
            }
          },
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text('Rooms'),
      );
}

class LoginComponent extends StatelessWidget {
  const LoginComponent({super.key});

  Future<void> _goToLoginPage(final BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<LoginPage>(
        fullscreenDialog: true,
        builder: (final BuildContext context) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) => Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(bottom: 200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Not authenticated'),
            TextButton(
              onPressed: () async {
                await _goToLoginPage(context);
              },
              child: const Text('Login'),
            ),
          ],
        ),
      );
}

class ChatRoomList extends StatelessWidget {
  const ChatRoomList({super.key, final User? user}) : _user = user;

  final User? _user;

  Future<void> _goToChatPage(
    final BuildContext context,
    final types.Room room,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<ChatPage>(
        builder: (final BuildContext context) => ChatPage(room: room),
      ),
    );
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
        radius: 20,
        child: child,
      ),
    );
  }

  Widget _buildEmptyState() => Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(bottom: 200),
        child: const Text('No rooms'),
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
      GestureDetector(
        onTap: () async => _goToChatPage(context, room),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: <Widget>[
              _buildAvatar(room),
              Text(room.name ?? ''),
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
