import 'package:pillu_app/chat/widget/app_drawer.dart';
import 'package:pillu_app/config/bloc_config.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';

class AppDrawerData extends StatelessWidget {
  const AppDrawerData({super.key});

  @override
  Widget build(final BuildContext context) => CustomBlocBuilder<PilluAuthBloc>(
        create: (final BuildContext context) =>
            PilluAuthBloc(PilluAuthRepository()),
        builder: (final BuildContext context, final PilluAuthBloc bloc) =>
            ThemeWrapper(
          child: BlocSelector<PilluAuthBloc, AuthDataState, User?>(
            selector: (final AuthDataState state) => state.user,
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
