import 'package:pillu_app/config/bloc_config.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:pillu_app/friend/bloc/friend_bloc.dart';
import 'package:pillu_app/friend/bloc/friend_event.dart';
import 'package:pillu_app/friend/component/blocked_users_tab.dart';
import 'package:pillu_app/friend/component/friend_requests_tab.dart';
import 'package:pillu_app/friend/component/friends_tab.dart';
import 'package:pillu_app/friend/component/sent_requests_tab.dart';
import 'package:pillu_app/friend/component/users_tab.dart';
import 'package:pillu_app/friend/repository/friend_repository.dart';

class FriendPage extends StatelessWidget {
  const FriendPage({super.key});

  @override
  Widget build(final BuildContext context) => BlocProvider<FriendBloc>(
        create: (final BuildContext context) =>
            FriendBloc(repository: FriendRepository())..add(FriendInitEvent()),
        child: Builder(builder: _buildPage),
      );

  Widget _buildPage(final BuildContext context) {
    BlocProvider.of<FriendBloc>(context);

    return CustomBlocBuilder<PilluAuthBloc>(
      create: (final BuildContext context) =>
          PilluAuthBloc(PilluAuthRepository()),
      builder: (final BuildContext context, final PilluAuthBloc bloc) =>
          ThemeWrapper(
        child: SafeArea(
          child: DefaultTabController(
            length: 5,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Friends', style: buildJostTextStyle(fontSize: 14)),
                bottom: TabBar(
                  isScrollable: true,
                  labelStyle: buildJostTextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  unselectedLabelStyle: buildJostTextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary.withAlpha(90),
                  ),
                  tabs: const <Widget>[
                    Tab(text: 'Users'),
                    Tab(text: 'Sent Requests'),
                    Tab(text: 'Friend Requests'),
                    Tab(text: 'Friends'),
                    Tab(text: 'Blocked Users'),
                  ],
                ),
              ),
              body: const TabBarView(
                children: <Widget>[
                  UsersTab(),
                  SentRequestsTab(),
                  FriendRequestsTab(),
                  FriendsTab(),
                  BlockedUsersTab(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
