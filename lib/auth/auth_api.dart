import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';

final AuthApi authApi = AuthApi();

class AuthApi {
  Future<String> createRegisterUser({
    required final String email,
    required final String password,
  }) async {
    final UserCredential credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user == null) {
      return '';
    }
    return credential.user!.uid;
  }

  Future<void> createUser({required final types.User user}) async {
    await FirebaseChatCore.instance.createUserInFirestore(user);
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
