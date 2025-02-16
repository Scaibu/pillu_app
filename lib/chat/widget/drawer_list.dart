import 'package:pillu_app/core/library/pillu_lib.dart';

class DrawerList extends StatelessWidget {
  const DrawerList({super.key});

  @override
  Widget build(final BuildContext context) => ListView(
        children: <Widget>[
          DrawerItem(icon: Icons.person, title: 'Profile', onTap: () {}),
          DrawerItem(
            icon: Icons.swap_horiz,
            title: 'Switch Chat Profile',
            onTap: () {},
          ),
          DrawerItem(icon: Icons.call, title: 'Call', onTap: () {}),
          DrawerItem(
            icon: Icons.people,
            title: 'Discover & Community',
            onTap: () {},
          ),
          DrawerItem(
            icon: Icons.privacy_tip,
            title: 'Anonymous & Temporary Chats',
            onTap: () {},
          ),
          DrawerItem(
            icon: Icons.business,
            title: 'Business & Work Chat',
            onTap: () {},
          ),
          DrawerItem(
            icon: Icons.star,
            title: 'Special Features & Add-ons',
            onTap: () {},
          ),
          DrawerItem(
            icon: Icons.lock,
            title: 'Secure & Encrypted Messaging',
            onTap: () {},
          ),
          DrawerItem(icon: Icons.settings, title: 'Settings', onTap: () {}),
          const Divider(),
          BlocBuilder<AuthBloc, AuthLocalState>(
            builder: (final BuildContext context, final Object? state) =>
                DrawerItem(
              icon: Icons.logout,
              title: 'Log Out',
              onTap: () {
                context.read<AuthBloc>().add(UserLogOutEvent());
              },
            ),
          ),
          const SizedBox(height: 50)
        ],
      );
}
