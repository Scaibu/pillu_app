import 'package:pillu_app/core/library/pillu_lib.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(final BuildContext context) => const Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeaderWidget(),
            Expanded(child: DrawerList()),
          ],
        ),
      );
}
