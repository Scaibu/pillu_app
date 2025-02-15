import 'package:pillu_app/auth/bloc/auth_bloc.dart';
import 'package:pillu_app/auth/bloc/auth_event.dart';
import 'package:pillu_app/auth/bloc/auth_state.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  Future<void> _register(
    final BuildContext context,
    final AuthBloc bloc,
  ) async {
    await handleAuthProcess(
      context: context,
      bloc: bloc,
      authOperation: () async => bloc.createAndRegisterUser(authApi),
      onSuccess: () {
        while (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      },
      onFailure: () => bloc.add(UpdateAuthStateEvent(registering: false)),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final AuthBloc bloc = BlocProvider.of<AuthBloc>(context)
      ..add(InitAuthEvent());

    final bool registering = context.select((final AuthBloc value) {
      final AuthState currState = value.state;
      if (currState is AuthDataState) {
        return currState.registering;
      } else {
        return false;
      }
    });

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
          child: Column(
            children: <Widget>[
              TextField(
                autocorrect: false,
                autofillHints:
                    registering ? null : <String>[AutofillHints.email],
                autofocus: true,
                controller: bloc.registerUsernameController,
                keyboardType: TextInputType.emailAddress,
                readOnly: registering,
                textInputAction: TextInputAction.next,
                onEditingComplete: bloc.registerFocusNode.requestFocus,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: bloc.registerUsernameController.clear,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  obscureText: true,
                  autocorrect: false,
                  autofillHints:
                      registering ? null : <String>[AutofillHints.password],
                  controller: bloc.registerPasswordController,
                  focusNode: bloc.registerFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () async {
                    await _register(context, bloc);
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
                      onPressed: bloc.registerPasswordController.clear,
                    ),
                  ),
                ),
              ),
              TextButton(
                child: const Text('Register'),
                onPressed: () async {
                  if (!registering) {
                    await _register(context, bloc);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
