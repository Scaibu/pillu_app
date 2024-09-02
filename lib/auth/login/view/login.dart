import 'package:pillu_app/core/library/pillu_lib.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _login(BuildContext context, LoginBloc loginBloc) async {
    FocusScope.of(context).unfocus();

    try {
      loginBloc.login(authApi);
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      if (context.mounted) {
        loginBloc.add(MakeLoginEvent(false));
        alertDialog(context, e);
      }
    }
  }

  void onPressed(bool loggingIn, BuildContext context) {
    if (!loggingIn) Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterPage()));
  }

  @override
  Widget build(BuildContext context) {
    final loginBloc = BlocProvider.of<LoginBloc>(context);

    final bool loggingIn = context.select(
      (LoginBloc value) {
        final currState = value.state;
        return (currState is LoginDataState) ? currState.loggingIn : false;
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
                controller: loginBloc.usernameController,
                keyboardType: TextInputType.emailAddress,
                readOnly: loggingIn,
                textCapitalization: TextCapitalization.none,
                textInputAction: TextInputAction.next,
                onEditingComplete: () {
                  loginBloc.focusNode.requestFocus();
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                  suffixIcon: IconButton(icon: const Icon(Icons.cancel), onPressed: loginBloc.usernameController.clear),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  autocorrect: false,
                  autofillHints: loggingIn ? null : [AutofillHints.password],
                  controller: loginBloc.passwordController,
                  focusNode: loginBloc.focusNode,
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
                    suffixIcon: IconButton(icon: const Icon(Icons.cancel), onPressed: loginBloc.passwordController.clear),
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
