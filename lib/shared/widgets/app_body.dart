import 'package:pillu_app/auth/auth_repository.dart';
import 'package:pillu_app/auth/bloc/auth_bloc.dart';
import 'package:pillu_app/auth/bloc/auth_event.dart';
import 'package:pillu_app/auth/bloc/auth_state.dart';
import 'package:pillu_app/chat/widget/chat_room_list.dart';
import 'package:pillu_app/chat/widget/login_view_component.dart';
import 'package:pillu_app/config/bloc_config.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:pillu_app/core/theme/app_theme.dart';

class AppBody extends StatelessWidget {
  const AppBody({super.key});

  @override
  Widget build(final BuildContext context) => CustomBlocBuilder<AuthBloc>(
        create: (final BuildContext context) => AuthBloc(AuthRepository()),
        init: (final AuthBloc bloc) {
          bloc.add(AuthAuthenticated());
        },
        builder: (final BuildContext context, final AuthBloc bloc) =>
            ThemeWrapper(
          child: BlocBuilder<AuthBloc, AuthState>(
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
