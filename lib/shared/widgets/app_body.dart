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
          child: BlocBuilder<PilluAuthBloc, AuthLocalState>(
            builder: (
              final BuildContext context,
              final AuthLocalState state,
            ) {
              if (state is AuthDataState) {
                final AuthDataState currDataState = state;
                if (currDataState.hasError) {
                  return Container();
                }

                if (currDataState.user == null) {
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
