import 'package:pillu_app/auth/bloc/auth_bloc.dart';
import 'package:pillu_app/auth/bloc/auth_event.dart';
import 'package:pillu_app/auth/bloc/auth_state.dart';
import 'package:pillu_app/auth/view/register.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _login(
    final BuildContext context,
    final AuthBloc loginBloc,
  ) async {
    await handleAuthProcess(
      context: context,
      bloc: loginBloc,
      authOperation: () async => loginBloc.login(authApi),
      onSuccess: () => Navigator.of(context).pop(),
      onFailure: () => loginBloc.add(UpdateAuthStateEvent(loggingIn: false)),
    );
  }

  Future<void> onPressed(
    final BuildContext context, {
    required final bool loggingIn,
  }) async {
    if (!loggingIn) {
      await Navigator.of(context).push(
        MaterialPageRoute<RegisterPage>(
          builder: (final BuildContext context) => const RegisterPage(),
        ),
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    final AuthBloc loginBloc = BlocProvider.of<AuthBloc>(context);

    final bool loggingIn = context.select(
      (final AuthBloc value) {
        final AuthState currState = value.state;
        if (currState is AuthDataState) {
          return currState.loggingIn;
        } else {
          return false;
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
          child: Column(
            children: <Widget>[
              TextField(
                autocorrect: false,
                autofillHints: loggingIn ? null : <String>[AutofillHints.email],
                autofocus: true,
                controller: loginBloc.loginUsernameController,
                keyboardType: TextInputType.emailAddress,
                readOnly: loggingIn,
                textInputAction: TextInputAction.next,
                onEditingComplete: () {
                  loginBloc.loginFocusNode.requestFocus();
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: loginBloc.loginUsernameController.clear,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  autocorrect: false,
                  autofillHints:
                      loggingIn ? null : <String>[AutofillHints.password],
                  controller: loginBloc.loginPasswordController,
                  focusNode: loginBloc.loginFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () async {
                    await _login(context, loginBloc);
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: loginBloc.loginPasswordController.clear,
                    ),
                  ),
                ),
              ),
              TextButton(
                child: const Text('Login'),
                onPressed: () async =>
                    loggingIn ? null : _login(context, loginBloc),
              ),
              TextButton(
                child: const Text('Register'),
                onPressed: () async {
                  await onPressed(context, loggingIn: loggingIn);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
