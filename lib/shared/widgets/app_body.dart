import 'package:pillu_app/auth/bloc/auth_state.dart';
import 'package:pillu_app/chat/widget/chat_room_list.dart';
import 'package:pillu_app/chat/widget/login_view_component.dart';
import 'package:pillu_app/config/bloc_config.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';

class AppBody extends StatelessWidget {
  const AppBody({super.key, this.pilluUser});

  final PilluUserModel? pilluUser;

  @override
  Widget build(final BuildContext context) => CustomBlocBuilder<PilluAuthBloc>(
        create: (final BuildContext context) => PilluAuthBloc(PilluAuthRepository()),
        init: (final PilluAuthBloc bloc) {
          if (pilluUser == null) {
            bloc.add(AuthAuthenticated());
          }
        },
        builder: (final BuildContext context, final PilluAuthBloc bloc) =>
            ThemeWrapper(
          child: BlocBuilder<PilluAuthBloc, AuthLocalState>(
            builder: (final BuildContext context, final AuthLocalState state) {
              if (state is AuthDataState) {
                final AuthDataState currDataState = state;
                if (currDataState.hasError) {
                  return Container();
                }

                if (currDataState.user == null &&
                    currDataState.unAuthenticated) {
                  return LoginViewComponent(pilluUser: pilluUser);
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
