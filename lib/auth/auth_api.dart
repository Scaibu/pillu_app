import 'package:pillu_app/core/library/pillu_lib.dart';

final AuthApi authApi = AuthApi();

class AuthApi {
  static Future<UserCredential> registerUser({
    required final BuildContext context,
    required final String email,
    required final String password,
  }) async {
    try {
      return await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        try {
          return await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } on FirebaseAuthException catch (signInError) {
          throw Exception(signInError.message);
        }
      } else {
        throw Exception(e.message ?? 'Unknown Firebase Error');
      }
    } catch (e) {
      throw Exception('Something went wrong : $e');
    }
  }

  Future<void> login({
    required final String email,
    required final String password,
  }) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
