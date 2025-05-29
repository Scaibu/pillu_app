import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:pillu_app/explore/explore_view.dart';
import 'package:pillu_app/profile/profile_view.dart';
import 'package:pillu_app/shared/navigation.dart';

class DrawerList extends StatelessWidget {
  const DrawerList({super.key});

  @override
  Widget build(final BuildContext context) => ListView(
        children: <Widget>[
          DrawerItem(
            icon: Icons.person,
            title: 'Profile',
            onTap: () async {
              await createPage(context, const ProfilePage());
            },
          ),
          DrawerItem(
            icon: Icons.explore,
            title: 'Explore',
            onTap: () async {
              await createPage(context, const ExplorePage());
            },
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
          BlocBuilder<PilluAuthBloc, AuthLocalState>(
            builder: (final BuildContext context, final Object? state) =>
                DrawerItem(
              icon: Icons.logout,
              title: 'Log Out',
              onTap: () {
                context.read<PilluAuthBloc>().add(UserLogOutEvent());
              },
            ),
          ),
          const SizedBox(height: 50),
        ],
      );
}
