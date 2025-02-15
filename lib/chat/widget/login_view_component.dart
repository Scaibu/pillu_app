import 'package:pillu_app/auth/view/login.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';

class LoginViewComponent extends StatelessWidget {
  const LoginViewComponent({super.key});

  Future<void> _goToLoginPage(final BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<LoginPage>(
        fullscreenDialog: true,
        builder: (final BuildContext context) => const LoginPage(),
      ),
    );
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
