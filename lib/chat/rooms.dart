import 'dart:async';

import 'package:pillu_app/auth/auth_repository.dart';
import 'package:pillu_app/auth/bloc/auth_bloc.dart';
import 'package:pillu_app/auth/bloc/auth_event.dart';
import 'package:pillu_app/auth/bloc/auth_state.dart';
import 'package:pillu_app/chat/widget/app_drawer.dart';
import 'package:pillu_app/chat/widget/chat_room_list.dart';
import 'package:pillu_app/chat/widget/login_view_component.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:pillu_app/shared/widget/app_bars.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

  Future<void> _addUsers(final BuildContext context) async {
    final AuthDataState state = context.read<AuthBloc>().state as AuthDataState;

    if (state.user != null) {
      await Navigator.of(context).push(
        MaterialPageRoute<UsersPage>(
          fullscreenDialog: true,
          builder: (final BuildContext context) => BlocProvider<AuthBloc>(
            create: (final BuildContext context) => AuthBloc(AuthRepository()),
            child: const UsersPage(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(final BuildContext context) => SafeArea(
        child: Scaffold(
          appBar: buildAppBar(
            context,
            logOutTap: () async {
              context.read<AuthBloc>().add(UserLogOutEvent());
            },
            onAddTap: () async {
              await _addUsers(context);
            },
          ),
          drawer: const AppDrawer(),
          body: BlocBuilder<AuthBloc, AuthState>(
            builder: (final BuildContext context, final AuthState state) {
              if (state is AuthDataState) {
                final AuthDataState currDataState = state;
                if (currDataState.hasError) {
                  return Container();
                }

                if (currDataState.user == null &&
                    currDataState.unAuthenticated) {
                  return const LoginViewComponent();
                } else {
                  return const ChatRoomList();
                }
              }

              return const Offstage();
            },
          ),
        ),
      );
}
