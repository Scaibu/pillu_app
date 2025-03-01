import 'dart:async';

import 'package:pillu_app/auth/model/image_model.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';

class PilluAuthBloc extends Bloc<AuthEvent, AuthLocalState> {
  PilluAuthBloc(this.authRepository) : super(AuthDataState()) {
    on<AuthAuthenticated>(_onAuthStarted);
    on<UserLogOutEvent>(_logOut);
    _listenToAuthStateChanges();

  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  final PilluAuthRepository authRepository;

  StreamSubscription<User?>? _authSubscription;

  void _listenToAuthStateChanges() {
    _authSubscription = authRepository.authStateChanges.listen(
      (final User? user) async {
        if (user != null) {
          final types.User chatUser = types.User(
            id: user.uid,
            firstName: user.displayName ?? '',
            imageUrl: user.photoURL,
          );
          _chatUserController.add(chatUser);
        } else {
          _chatUserController.add(null);
        }
        add(AuthAuthenticated(user: user));
      },
      onError: (final dynamic error) {
        _chatUserController.add(null);
        add(AuthAuthenticated());
      },
    );
  }

  final StreamController<types.User?> _chatUserController =
      StreamController<types.User?>.broadcast();

  Stream<types.User?> get chatUserStream => _chatUserController.stream;

  Future<void> _onAuthStarted(
    final AuthAuthenticated event,
    final Emitter<AuthLocalState> emit,
  ) async {
    if (event.user != null) {
      emit(AuthDataState(user: event.user, unAuthenticated: false));
    } else {
      emit(AuthDataState());
    }
  }

  Future<void> createChatUser(
    final AuthApi api, {
    required final PilluUserModel pilluUser,
  }) async {
    final types.User user = types.User(
      imageUrl: pilluUser.imageUrl.isNotEmpty
          ? pilluUser.imageUrl
          : (await ImageModel.fetchRandomImage() ?? ''),
      firstName: pilluUser.firstName,
      lastName: pilluUser.lastName,
      id: pilluUser.id,
    );

    await api.createChatUser(user: user);
  }

  Future<void> _logOut(
    final UserLogOutEvent event,
    final Emitter<AuthLocalState> emit,
  ) async {
    await FirebaseAuth.instance.signOut();
    emit(AuthDataState());
  }
}
