import 'package:pillu_app/auth/bloc/auth_state.dart';
import 'package:pillu_app/chat/widget/app_drawer.dart';
import 'package:pillu_app/chat/widget/login_view_component.dart';
import 'package:pillu_app/config/bloc_config.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';

class AppDrawerData extends StatelessWidget {
  const AppDrawerData({super.key});

  @override
  Widget build(final BuildContext context) => CustomBlocBuilder<AuthBloc>(
        create: (final BuildContext context) => AuthBloc(AuthRepository()),
        init: (final AuthBloc bloc) {
          bloc.add(AuthAuthenticated());
        },
        builder: (final BuildContext context, final AuthBloc bloc) =>
            ThemeWrapper(
          child: BlocSelector<AuthBloc, AuthLocalState, User?>(
            selector: (final AuthLocalState state) =>
                (state as AuthDataState).user,
            builder: (final BuildContext context, final User? state) {
              if (state == null) {
                return const Drawer(child: LoginViewComponent());
              }
              return const AppDrawer();
            },
          ),
        ),
      );
}
