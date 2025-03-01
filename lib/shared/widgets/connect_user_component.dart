import 'package:pillu_app/config/bloc_config.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';

class ConnectUserComponent extends StatelessWidget {
  const ConnectUserComponent({super.key});

  @override
  Widget build(final BuildContext context) => CustomBlocBuilder<PilluAuthBloc>(
        create: (final BuildContext context) =>
            PilluAuthBloc(PilluAuthRepository()),
        init: (final PilluAuthBloc bloc) {
          bloc.add(AuthAuthenticated());
        },
        builder: (final BuildContext context, final PilluAuthBloc bloc) =>
            IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            await _addUser(context);
          },
        ),
      );

  Future<void> _addUser(final BuildContext context) async {
    final AuthDataState state =
        context.read<PilluAuthBloc>().state as AuthDataState;

    if (state.user != null) {
      await Navigator.of(context).push(
        MaterialPageRoute<UsersPage>(
          fullscreenDialog: true,
          builder: (final BuildContext context) => BlocProvider<PilluAuthBloc>(
            create: (final BuildContext context) =>
                PilluAuthBloc(PilluAuthRepository()),
            child: const UsersPage(),
          ),
        ),
      );
    } else {
      toast(
        context,
        message: 'Please connect first to chat with others',
      );
    }
  }
}
