import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:pillu_app/explore/explore_view.dart';
import 'package:pillu_app/friend/friend_view.dart';
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
          const Divider(height: 1, thickness: 1, indent: 72, endIndent: 16),
          DrawerItem(
            icon: Icons.explore,
            title: 'Explore',
            onTap: () async {
              await createPage(context, const ExplorePage());
            },
          ),
          const Divider(height: 1, thickness: 1, indent: 72, endIndent: 16),
          DrawerItem(
            icon: Icons.people,
            title: 'Discover & Community',
            onTap: () async {
              await createPage(context, const FriendPage());
            },
          ),
          const Divider(height: 1, thickness: 1, indent: 72, endIndent: 16),
          DrawerItem(icon: Icons.call, title: 'Call', onTap: () {}),
          const Divider(height: 1, thickness: 1, indent: 72, endIndent: 16),
          DrawerItem(
            icon: Icons.privacy_tip,
            title: 'Anonymous & Temporary Chats',
            onTap: () {},
          ),
          const Divider(height: 1, thickness: 1, indent: 72, endIndent: 16),
          DrawerItem(
            icon: Icons.business,
            title: 'Business & Work Chat',
            onTap: () {},
          ),
          const Divider(height: 1, thickness: 1, indent: 72, endIndent: 16),
          DrawerItem(
            icon: Icons.star,
            title: 'Special Features & Add-ons',
            onTap: () {},
          ),
          const Divider(height: 1, thickness: 1, indent: 72, endIndent: 16),
          DrawerItem(
            icon: Icons.lock,
            title: 'Secure & Encrypted Messaging',
            onTap: () {},
          ),
          const Divider(height: 1, thickness: 1, indent: 72, endIndent: 16),
          DrawerItem(icon: Icons.settings, title: 'Settings', onTap: () {}),
          const Divider(height: 1, thickness: 1, indent: 72, endIndent: 16),
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
          const Divider(height: 1, thickness: 1, indent: 72, endIndent: 16),
          const SizedBox(height: 50),
        ],
      );
}
