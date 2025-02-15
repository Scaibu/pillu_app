import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:pillu_app/core/theme/app_theme.dart';
import 'package:pillu_app/shared/text_styles.dart';
import 'package:pillu_app/shared/widgets/connect_user_component.dart';

AppBar buildAppBar(final BuildContext context) => AppBar(
      actions: const <Widget>[ThemeWrapper(child: ConnectUserComponent())],
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: ThemeWrapper(
        child: Text(
          'Chat Connect',
          style: buildJostTextStyle(fontSize: 14),
        ),
      ),
      centerTitle: true,
    );
