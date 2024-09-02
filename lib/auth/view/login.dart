import 'package:pillu_app/auth/bloc/auth_bloc.dart';
import 'package:pillu_app/auth/bloc/auth_event.dart';
import 'package:pillu_app/auth/bloc/auth_state.dart';
import 'package:pillu_app/auth/view/register.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});



  void _login(BuildContext context, AuthBloc loginBloc) {
    handleAuthProcess(
      context: context,
      bloc: loginBloc,
      authOperation: () => loginBloc.login(authApi),
      onSuccess: () => Navigator.of(context).pop(),
      onFailure: () => loginBloc.add(UpdateAuthStateEvent(loggingIn: false)),
    );
  }


  void onPressed(bool loggingIn, BuildContext context) {
    if (!loggingIn) Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterPage()));
  }

  @override
  Widget build(BuildContext context) {
    final loginBloc = BlocProvider.of<AuthBloc>(context);

    final bool loggingIn = context.select(
      (AuthBloc value) {
        final currState = value.state;
        return (currState is AuthDataState) ? currState.loggingIn : false;
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
            children: [
              TextField(
                autocorrect: false,
                autofillHints: loggingIn ? null : [AutofillHints.email],
                autofocus: true,
                controller: loginBloc.loginUsernameController,
                keyboardType: TextInputType.emailAddress,
                readOnly: loggingIn,
                textCapitalization: TextCapitalization.none,
                textInputAction: TextInputAction.next,
                onEditingComplete: () {
                  loginBloc.loginFocusNode.requestFocus();
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                  suffixIcon: IconButton(icon: const Icon(Icons.cancel), onPressed: loginBloc.loginUsernameController.clear),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  autocorrect: false,
                  autofillHints: loggingIn ? null : [AutofillHints.password],
                  controller: loginBloc.loginPasswordController,
                  focusNode: loginBloc.loginFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: true,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () {
                    _login(context, loginBloc);
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                    suffixIcon: IconButton(icon: const Icon(Icons.cancel), onPressed: loginBloc.loginPasswordController.clear),
                  ),
                ),
              ),
              TextButton(
                child: const Text('Login'),
                onPressed: () {
                  return loggingIn ? null : _login(context, loginBloc);
                },
              ),
              TextButton(
                child: const Text('Register'),
                onPressed: () {
                  onPressed(loggingIn, context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
