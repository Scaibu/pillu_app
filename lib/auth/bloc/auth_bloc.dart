import 'dart:async';

import 'package:faker/faker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pillu_app/auth/bloc/auth_state.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';

class AuthBloc extends Bloc<AuthEvent, AuthLocalState> {
  AuthBloc(this.authRepository) : super(AuthDataState()) {
    on<InitAuthEvent>(_initAll);
    on<UpdateAuthStateEvent>(_updateAuthState);
    on<AuthAuthenticated>(_onAuthStarted);
    on<UserLogOutEvent>(_logOut);
  }

  final AuthRepository authRepository;

  FocusNode loginFocusNode = FocusNode();
  final TextEditingController loginPasswordController =
      TextEditingController(text: 'Pillu@123');
  final TextEditingController registerPasswordController =
      TextEditingController();
  final TextEditingController loginUsernameController =
      TextEditingController(text: '');
  final TextEditingController registerUsernameController =
      TextEditingController();
  final FocusNode registerFocusNode = FocusNode();

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

  @override
  Future<void> close() async {
    loginFocusNode.dispose();
    loginPasswordController.dispose();
    loginUsernameController.dispose();
    registerPasswordController.dispose();
    registerUsernameController.dispose();
    registerFocusNode.dispose();

    return super.close();
  }

  Future<void> _initAll(
    final AuthEvent event,
    final Emitter<AuthLocalState> emit,
  ) async {
    if (event is InitAuthEvent) {
      final Faker faker = Faker();
      final String firstName = faker.person.firstName();
      final String lastName = faker.person.lastName();
      registerUsernameController.text =
          '${firstName.toLowerCase()} ${lastName.toLowerCase()}';
      registerPasswordController.text = 'Pillu@123';
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
      ),
    );
  }

  Future<void> login(final AuthApi api) async {
    add(UpdateAuthStateEvent(loggingIn: true));
    await createAndRegisterUser(authApi);
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

  Future<void> createAndRegisterUser(final AuthApi api) async {
    final UserCredential cred = await signInWithGoogle();
    if (cred.user != null) {
      final String firstName = cred.user?.displayName?.split(' ').first ?? '-';
      final String lastName = cred.user?.displayName?.split(' ').last ?? '-';
      final String imageUrl =
          'https://i.pravatar.cc/300?u=${faker.internet.domainName()}';

      add(UpdateAuthStateEvent(registering: true));

      if (cred.user?.email != null) {
        final types.User user = types.User(
          imageUrl: imageUrl,
          firstName: firstName,
          lastName: lastName,
          id: cred.user?.uid ?? '',
        );
        await api.createUser(user: user);
      }
    }
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
