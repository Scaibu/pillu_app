import 'dart:async';

import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';

class PilluAuthBloc extends Bloc<AuthEvent, AuthDataState> {
  PilluAuthBloc(this.authRepository) : super(const AuthDataState()) {
    on<AuthAuthenticated>(_onAuthStarted);
    on<UserLogOutEvent>(_logOut);
    on<AuthLoadingEvent>(
        (final AuthLoadingEvent event, final Emitter<AuthDataState> emit) {
      emit(state.copyWith(isLoading: event.isLoading));
    });

    on<IsRestartEvent>(
      (final IsRestartEvent event, final Emitter<AuthDataState> emit) {
        final AuthDataState currState = state;
        emit(currState.copyWith(isRestartEvent: true));
      },
    );

    on<StartCurrentEvent>(
      (final StartCurrentEvent event, final Emitter<AuthDataState> emit) {
        final AuthDataState currState = state;
        emit(currState.copyWith(isRestartEvent: false));
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
    final Emitter<AuthDataState> emit,
  ) async {
    if (event.user != null) {
      emit(AuthDataState(user: event.user, unAuthenticated: false));
    } else {
      emit(const AuthDataState());
    }
  }

  Future<void> _logOut(
    final UserLogOutEvent event,
    final Emitter<AuthDataState> emit,
  ) async {
    _cachedChatUser = null;
    _chatUserController.add(null);
    await FirebaseAuth.instance.signOut();
    emit(const AuthDataState());
  }
}
