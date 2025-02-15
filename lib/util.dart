import 'package:pillu_app/auth/bloc/auth_bloc.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';

const List<Color> colors = <Color>[
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

Color getUserAvatarNameColor(final types.User user) {
  final int index = user.id.hashCode % colors.length;
  return colors[index];
}

String getUserName(final types.User user) =>
    '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();

Future<void> alertDialog(final BuildContext context, final String e) async =>
    showDialog(
      context: context,
      builder: (final BuildContext context) => AlertDialog(
        actions: <Widget>[
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
      ),
    );

Future<void> handleAuthProcess({
  required final BuildContext context,
  required final AuthBloc bloc,
  required final Future<void> Function() authOperation,
  required final void Function() onSuccess,
  required final void Function() onFailure,
}) async {
  FocusScope.of(context).unfocus();

  try {
    await authOperation();
    if (context.mounted) {
      onSuccess();
    }
  } catch (e) {
    if (context.mounted) {
      onFailure();
      await alertDialog(context, e.toString());
    }
  }
}
