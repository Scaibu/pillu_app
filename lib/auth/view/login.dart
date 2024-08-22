import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pillu_app/auth/login/login_bloc.dart';
import 'package:pillu_app/auth/login/login_event.dart';
import 'package:pillu_app/auth/login/login_state.dart';

import '../../register.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _login(BuildContext context) async {
    final loginBloc = context.read<LoginBloc>();
    FocusScope.of(context).unfocus();

    loginBloc.add(MakeLoginEvent(true));

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: loginBloc.usernameController.text,
        password: loginBloc.passwordController.text,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;

      loginBloc.add(MakeLoginEvent(false));

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          content: Text(e.toString()),
          title: const Text('Error'),
        ),
      );
    }
  }

  Null Function()? onPressed(bool loggingIn, BuildContext context) {
    return loggingIn
        ? null
        : () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const RegisterPage(),
            ));
          };
  }

  @override
  Widget build(BuildContext context) {
    final loginBloc = BlocProvider.of<LoginBloc>(context);

    final bool loggingIn = context.select(
      (LoginBloc value) {
        final currState = value.state;
        if (currState is LoginDataState) {
          return currState.loggingIn ?? false;
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
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                  labelText: 'Email',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () => loginBloc.usernameController.clear(),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  autocorrect: false,
                  autofillHints: loggingIn ? null : [AutofillHints.password],
                  controller: loginBloc.passwordController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        loginBloc.passwordController.clear();
                      },
                    ),
                  ),
                  focusNode: loginBloc.focusNode,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: true,
                  onEditingComplete: () {
                    _login(context);
                  },
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.done,
                ),
              ),
              TextButton(
                onPressed: () {
                  return loggingIn ? null : _login(context);
                },
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: onPressed(loggingIn, context),
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
