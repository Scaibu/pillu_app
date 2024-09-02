import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'core/library/pillu_lib.dart';

const colors = [
  Color(0xffff6767),
  Color(0xff66e0da),
  Color(0xfff5a2d9),
  Color(0xfff0c722),
  Color(0xff6a85e5),
  Color(0xfffd9a6f),
  Color(0xff92db6e),
  Color(0xff73b8e5),
  Color(0xfffd7590),
  Color(0xffc78ae5),
];

Color getUserAvatarNameColor(types.User user) {
  final index = user.id.hashCode % colors.length;
  return colors[index];
}

String getUserName(types.User user) => '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();

Future<void> alertDialog(BuildContext context, e) async {
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              while (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
        content: Text(e.toString()),
        title: const Text('Error'),
      );
    },
  );
}
