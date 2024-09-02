import 'package:pillu_app/core/library/pillu_lib.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static void _register(BuildContext context, RegisterBloc bloc) async {
    FocusScope.of(context).unfocus();

    try {
      await bloc.createAndRegisterUser(authApi);
      if (!context.mounted) return;

      while (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!context.mounted) return;
      bloc.add(SetRegisterEvent(registering: false));
      await alertDialog(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<RegisterBloc>(context);

    bloc.add(InitRegisterEvent());

    final bool registering = context.select((RegisterBloc value) {
      final currState = value.state;
      return (currState is RegisterDataState) ? currState.registering : false;
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
                controller: bloc.usernameController,
                keyboardType: TextInputType.emailAddress,
                readOnly: registering,
                textCapitalization: TextCapitalization.none,
                textInputAction: TextInputAction.next,
                onEditingComplete: () {
                  bloc.focusNode.requestFocus();
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                  suffixIcon: IconButton(icon: const Icon(Icons.cancel), onPressed: bloc.usernameController.clear),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  obscureText: true,
                  autocorrect: false,
                  autofillHints: registering ? null : [AutofillHints.password],
                  controller: bloc.passwordController,
                  focusNode: bloc.focusNode,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () {
                    _register(context, bloc);
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                    suffixIcon: IconButton(icon: const Icon(Icons.cancel), onPressed: bloc.passwordController.clear),
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
