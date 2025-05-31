import 'package:pillu_app/config/bloc_config.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';

class AppBody extends StatelessWidget {
  const AppBody({super.key});

  @override
  Widget build(final BuildContext context) => CustomBlocBuilder<PilluAuthBloc>(
        create: (final BuildContext context) =>
            PilluAuthBloc(PilluAuthRepository()),
        builder: (final BuildContext context, final PilluAuthBloc bloc) =>
            ThemeWrapper(
          child: BlocBuilder<PilluAuthBloc, AuthDataState>(
            builder: (final BuildContext context, final AuthDataState state) {
              if (state.user != null) {
                return const ChatRoomList();
              }
              return const LoginViewComponent();
            },
          ),
        ),
      );
}
