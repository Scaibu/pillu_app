import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:pillu_app/shared/text_styles.dart';

AppBar buildAppBar(
  final BuildContext context, {
  required final VoidCallback? logOutTap,
  final VoidCallback? onAddTap,
}) =>
    AppBar(
      actions: <Widget>[
        IconButton(icon: const Icon(Icons.add), onPressed: onAddTap),
      ],
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Text(
        'Chat Connect',
        style: buildJostTextStyle(fontSize: 14),
      ),
      centerTitle: true,
    );
