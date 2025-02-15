import 'package:pillu_app/auth/auth_repository.dart';
import 'package:pillu_app/auth/bloc/auth_bloc.dart';
import 'package:pillu_app/auth/bloc/auth_event.dart';
import 'package:pillu_app/auth/bloc/auth_state.dart';
import 'package:pillu_app/config/bloc_config.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:pillu_app/shared/bottomSheet/bottom_sheets.dart';

class ConnectUserComponent extends StatelessWidget {
  const ConnectUserComponent({super.key});

  @override
  Widget build(final BuildContext context) => CustomBlocBuilder<AuthBloc>(
        create: (final BuildContext context) => AuthBloc(AuthRepository()),
        init: (final AuthBloc bloc) {
          bloc.add(AuthAuthenticated());
        },
        builder: (final BuildContext context, final AuthBloc bloc) =>
            IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            await _addUser(context);
          },
        ),
      );

  Future<void> _addUser(final BuildContext context) async {
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
    } else {
      showToast(
        context,
        message: 'Please connect first to chat with others',
      );
    }
  }
}
