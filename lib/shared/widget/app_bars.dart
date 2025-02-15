import 'package:pillu_app/core/library/pillu_lib.dart';

AppBar buildAppBar(
  final BuildContext context, {
  required final VoidCallback? logOutTap,
  final VoidCallback? onAddTap,
}) =>
    AppBar(
      actions: <Widget>[
        IconButton(icon: const Icon(Icons.add), onPressed: onAddTap),
      ],
      leading: IconButton(
        icon: const Icon(Icons.logout),
        onPressed: logOutTap,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: const Text('Rooms'),
    );
