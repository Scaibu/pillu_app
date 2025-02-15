import 'dart:async';

import 'package:faker/faker.dart';
import 'package:pillu_app/auth/auth_repository.dart';
import 'package:pillu_app/auth/bloc/auth_event.dart';
import 'package:pillu_app/auth/bloc/auth_state.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this.authRepository) : super(AuthDataState()) {
    on<InitAuthEvent>(_initAll);
    on<UpdateAuthStateEvent>(_updateAuthState);
    on<AuthAuthenticated>(_onAuthStarted);
    on<UserLogOutEvent>(_logOut);
  }

  final AuthRepository authRepository;
  StreamSubscription<User?>? _authSubscription;

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
    final Emitter<AuthState> emit,
  ) async {
    await _authSubscription?.cancel();

    authRepository.authStateChanges.listen((final User? user) {
      if (user != null) {
        emit(AuthDataState(user: user));
      } else {
        emit(AuthDataState());
      }
    });
    _authSubscription = authRepository.authStateChanges.listen(
      (final User? user) {
        if (user != null) {
          emit(AuthDataState(user: user, unAuthenticated: false));
        } else {
          emit(AuthDataState());
        }
      },
      onError: (final _) {
        emit(AuthDataState(hasError: true));
      },
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
    await _authSubscription?.cancel();
    return super.close();
  }

  Future<void> _initAll(
    final AuthEvent event,
    final Emitter<AuthState> emit,
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
    final Emitter<AuthState> emit,
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
    await api.login(
      email: loginUsernameController.text,
      password: loginPasswordController.text,
    );
  }

  Future<void> createAndRegisterUser(final AuthApi api) async {
    final String firstName = registerUsernameController.text.split(' ').first;
    final String lastName = registerUsernameController.text.split(' ').last;
    final String imageUrl =
        'https://i.pravatar.cc/300?u=${faker.internet.domainName()}';

    add(UpdateAuthStateEvent(registering: true));

    final String uid = await api.createRegisterUser(
      email: registerUsernameController.text,
      password: registerPasswordController.text,
    );
    final types.User user = types.User(
      imageUrl: imageUrl,
      firstName: firstName,
      lastName: lastName,
      id: uid,
    );
    await api.createUser(user: user);
  }

  Future<void> _logOut(
    final UserLogOutEvent event,
    final Emitter<AuthState> emit,
  ) async {
    if (state is AuthDataState) {
      final AuthDataState currDataState = state as AuthDataState;

      if (currDataState.user == null) {
        await FirebaseAuth.instance.signOut();
      }
    }
  }
}
