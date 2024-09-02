import 'package:pillu_app/auth/bloc/auth_bloc.dart';
import 'package:pillu_app/auth/bloc/auth_event.dart';
import 'package:pillu_app/auth/bloc/auth_state.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  void _register(BuildContext context, AuthBloc bloc) {
    handleAuthProcess(
      context: context,
      bloc: bloc,
      authOperation: () => bloc.createAndRegisterUser(authApi),
      onSuccess: () {
        while (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      },
      onFailure: () => bloc.add(UpdateAuthStateEvent(registering: false)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<AuthBloc>(context);

    bloc.add(InitAuthEvent());

    final bool registering = context.select((AuthBloc value) {
      final currState = value.state;
      return (currState is AuthDataState) ? currState.registering : false;
    });

    return Scaffold(
      appBar: AppBar(systemOverlayStyle: SystemUiOverlayStyle.light, title: const Text('Register')),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
          child: Column(
            children: [
              TextField(
                autocorrect: false,
                autofillHints: registering ? null : [AutofillHints.email],
                autofocus: true,
                controller: bloc.registerUsernameController,
                keyboardType: TextInputType.emailAddress,
                readOnly: registering,
                textCapitalization: TextCapitalization.none,
                textInputAction: TextInputAction.next,
                onEditingComplete: () {
                  bloc.registerFocusNode.requestFocus();
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                  suffixIcon: IconButton(icon: const Icon(Icons.cancel), onPressed: bloc.registerUsernameController.clear),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  obscureText: true,
                  autocorrect: false,
                  autofillHints: registering ? null : [AutofillHints.password],
                  controller: bloc.registerPasswordController,
                  focusNode: bloc.registerFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () {
                    _register(context, bloc);
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                    suffixIcon: IconButton(icon: const Icon(Icons.cancel), onPressed: bloc.registerPasswordController.clear),
                  ),
                ),
              ),
              TextButton(
                child: const Text('Register'),
                onPressed: () {
                  if (!registering) _register(context, bloc);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
