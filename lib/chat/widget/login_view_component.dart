import 'package:pillu_app/auth/bloc/auth_bloc.dart';
import 'package:pillu_app/auth/bloc/auth_event.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:pillu_app/shared/bottomSheet/bottom_sheets.dart';
import 'package:pillu_app/shared/text_styles.dart';

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
        showToast(context, message: 'Done');
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
            Text('Not Connected Yet', style: buildJostTextStyle()),
            TextButton(
              onPressed: () async {
                await _goToLoginPage(context);
              },
              child: Text(
                'Continue',
                style:
                    buildJostTextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      );
}
