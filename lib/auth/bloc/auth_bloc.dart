import 'dart:async';

import 'package:faker/faker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';

class PilluAuthBloc extends Bloc<AuthEvent, AuthLocalState> {
  PilluAuthBloc(this.authRepository) : super(AuthDataState()) {
    on<InitAuthEvent>(_initAll);
    on<UpdateAuthStateEvent>(_updateAuthState);
    on<AuthAuthenticated>(_onAuthStarted);
    on<UserLogOutEvent>(_logOut);
  }

  final PilluAuthRepository authRepository;

  Future<void> _onAuthStarted(
    final AuthAuthenticated event,
    final Emitter<AuthLocalState> emit,
  ) async {
    await emit.forEach<User?>(
      authRepository.authStateChanges,
      onData: (final User? user) {
        if (user != null) {
          return AuthDataState(user: user, unAuthenticated: false);
        } else {
          return AuthDataState();
        }
      },
      onError: (final _, final __) => AuthDataState(hasError: true),
    );
  }

  Future<void> _initAll(
    final AuthEvent event,
    final Emitter<AuthLocalState> emit,
  ) async {
    if (event is InitAuthEvent) {
      emit(AuthDataState());
    }
    emit(AuthDataState());
  }

  void _updateAuthState(
    final UpdateAuthStateEvent event,
    final Emitter<AuthLocalState> emit,
  ) {
    final AuthDataState currState = state as AuthDataState;
    emit(
      currState.copyWith(
        loggingIn: event.loggingIn,
        registering: event.registering,
        unAuthenticated: false,
      ),
    );
  }

  Future<void> login(
    final AuthApi api, {
    final PilluUserModel? pilluUser,
  }) async {
    add(UpdateAuthStateEvent(loggingIn: true));
    await createAndRegisterUser(authApi, pilluUser: pilluUser);
  }

  Future<UserCredential> signInWithGoogle() async {

    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> createAndRegisterUser(
    final AuthApi api, {
    final PilluUserModel? pilluUser,
  }) async {
    if (pilluUser == null) {
      await _registerWithGoogle(api);
    } else {
      await _registerWithPilluUser(api, pilluUser);
    }
  }

  Future<void> _registerWithGoogle(final AuthApi api) async {
    final UserCredential cred = await signInWithGoogle();
    if (cred.user != null) {
      final types.User user = await _createUserFromGoogleCredential(cred);
      await api.createUser(user: user);
    }
  }

  Future<types.User> _createUserFromGoogleCredential(
    final UserCredential cred,
  ) async {
    final String firstName = cred.user?.displayName?.split(' ').first ?? '-';
    final String lastName = cred.user?.displayName?.split(' ').last ?? '-';
    final String imageUrl =
        'https://i.pravatar.cc/300?u=${faker.internet.domainName()}';

    add(UpdateAuthStateEvent(registering: true));

    return types.User(
      imageUrl: imageUrl,
      firstName: firstName,
      lastName: lastName,
      id: cred.user?.uid ?? '',
    );
  }

  Future<void> _registerWithPilluUser(
    final AuthApi api,
    final PilluUserModel pilluUser,
  ) async {
    add(UpdateAuthStateEvent(registering: true, loggingIn: true));
    final types.User user = types.User(
      imageUrl: pilluUser.imageUrl,
      firstName: pilluUser.firstName,
      lastName: pilluUser.lastName,
      id: pilluUser.id,
    );
    await api.createUser(user: user);
  }

  Future<void> _logOut(
    final UserLogOutEvent event,
    final Emitter<AuthLocalState> emit,
  ) async {
    if (state is AuthDataState) {
      final AuthDataState currDataState = state as AuthDataState;

      if (currDataState.user == null) {
        await FirebaseAuth.instance.signOut();
      }
    }
  }
}
