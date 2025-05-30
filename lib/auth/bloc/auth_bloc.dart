import 'dart:async';

import 'package:pillu_app/auth/model/image_model.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';

class PilluAuthBloc extends Bloc<AuthEvent, AuthLocalState> {
  PilluAuthBloc(this.authRepository) : super(AuthDataState()) {
    on<AuthAuthenticated>(_onAuthStarted);
    on<UserLogOutEvent>(_logOut);
    on<IsRestartEvent>(
      (final IsRestartEvent event, final Emitter<AuthLocalState> emit) {
        if (state is AuthDataState) {
          final AuthDataState currState = state as AuthDataState;
          emit(currState.copyWith(isRestartEvent: true));
        }
      },
    );

    on<StartCurrentEvent>(
      (final StartCurrentEvent event, final Emitter<AuthLocalState> emit) {
        if (state is AuthDataState) {
          final AuthDataState currState = state as AuthDataState;
          emit(currState.copyWith(isRestartEvent: false));
        }
      },
    );
    _listenToAuthStateChanges();
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    await _chatUserSubscription?.cancel();
    await _chatUserController.close();
    return super.close();
  }

  final PilluAuthRepository authRepository;
  StreamSubscription<User?>? _authSubscription;

  final StreamController<types.User?> _chatUserController =
      StreamController<types.User?>.broadcast();

  Stream<types.User?> get chatUserStream => _chatUserController.stream;

  void _listenToAuthStateChanges() {
    _authSubscription = authRepository.authStateChanges.listen(
      _listenAuthUser,
      onError: (final dynamic error) {
        _chatUserController.add(null);
        add(AuthAuthenticated());
      },
    );
  }

  void _listenAuthUser(final User? user) {
    if (user != null && user.uid.isNotEmpty) {
      _listenUser(user);
    } else {
      _chatUserController.add(null);
      add(AuthAuthenticated());
    }
  }

  static types.User? _cachedChatUser;
  StreamSubscription<types.User?>? _chatUserSubscription;

  void _listenUser(final User user) {
    if (_cachedChatUser != null && !_chatUserController.isClosed) {
      _chatUserController.add(_cachedChatUser);
      add(AuthAuthenticated(user: user));
    }

    _chatUserSubscription = FirebaseChatCore.instance.currentUser().listen(
      (final types.User? chatUser) {
        if (chatUser != null) {
          _cachedChatUser = chatUser;
          if (!_chatUserController.isClosed) {
            _chatUserController.add(chatUser);
          }
          if (!isClosed) {
            add(AuthAuthenticated(user: user));
          }
        } else {
          _cachedChatUser = null;
          if (!_chatUserController.isClosed) {
            _chatUserController.add(null);
          }
          if (!isClosed) {
            add(AuthAuthenticated());
          }
        }
      },
      onError: (final _) {
        _cachedChatUser = null;
        if (!_chatUserController.isClosed) {
          _chatUserController.add(null);
        }
        if (!isClosed) {
          add(AuthAuthenticated());
        }
      },
    );
  }

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
    _cachedChatUser = null;
    _chatUserController.add(null);
    await FirebaseAuth.instance.signOut();
    emit(AuthDataState());
  }
}
