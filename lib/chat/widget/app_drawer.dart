import 'package:flutter/material.dart';
import 'package:pillu_app/chat/widget/drawer_header.dart';
import 'package:pillu_app/chat/widget/drawer_list.dart';

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
