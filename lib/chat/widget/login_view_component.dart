import 'package:pillu_app/auth/bloc/auth_bloc.dart';
import 'package:pillu_app/auth/bloc/auth_event.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';

class LoginViewComponent extends StatelessWidget {
  const LoginViewComponent({super.key});

  static Future<void> _login(
    final BuildContext context,
  ) async {
    await handleAuthProcess(
      context: context,
      bloc: BlocProvider.of<AuthBloc>(context),
      authOperation: () async =>
          BlocProvider.of<AuthBloc>(context).login(authApi),
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Done'),
          ),
        );
      },
      onFailure: () => BlocProvider.of<AuthBloc>(context)
          .add(UpdateAuthStateEvent(loggingIn: false)),
    );
  }

  Future<void> _goToLoginPage(final BuildContext context) async {
    await _login(context);
  }

  @override
  Widget build(final BuildContext context) => Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(bottom: 200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Not authenticated'),
            TextButton(
              onPressed: () async {
                await _goToLoginPage(context);
              },
              child: const Text('Login'),
            ),
          ],
        ),
      );
}
