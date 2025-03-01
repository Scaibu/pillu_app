import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';

final AuthApi authApi = AuthApi();

class AuthApi {
  Future<UserCredential> registerUser({
    required final BuildContext context,
    required final String email,
    required final String password,
  }) async {
    try {
      return await _fireAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        try {
          return await _fireAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } on FirebaseAuthException catch (signInError) {
          if (context.mounted) {
            toast(context, message: signInError.message ?? 'Sign-in failed');
            await alertDialog(context, signInError.message ?? 'Sign-in failed');
          }
          throw Exception(signInError.message); // Throw after UI feedback
        }
      } else {
        if (context.mounted) {
          toast(context, message: e.message ?? 'Unknown Firebase Error');
          await alertDialog(context, e.message ?? 'Unknown Firebase Error');
        }
        throw Exception(e.message); // Throw after UI feedback
      }
    } catch (e) {
      if (context.mounted) {
        toast(context, message: e.toString());
        await alertDialog(context, e.toString());
      }
      throw Exception('Something went wrong'); // Throw after UI feedback
    }
  }

  FirebaseAuth get _fireAuth => FirebaseAuth.instance;

  Future<void> createChatUser({required final types.User user}) async {
    await FirebaseChatCore.instance.createUserInFirestore(user);
  }

  Future<void> login({
    required final String email,
    required final String password,
  }) async {
    await _fireAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
