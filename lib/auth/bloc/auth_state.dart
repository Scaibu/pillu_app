import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth show User;

sealed class AuthState extends Equatable {
  @override
  List<Object?> get props => <Object?>[];
}

class AuthDataState extends AuthState {
  AuthDataState({
    this.loggingIn = false,
    this.registering = false,
    this.user,
    this.message,
    this.unAuthenticated = true,
    this.hasError = false,
  });

  final bool loggingIn;
  final bool registering;
  final bool unAuthenticated;
  final bool hasError;
  final fire_auth.User? user;
  final String? message;

  @override
  List<Object?> get props => <Object?>[
        loggingIn,
        registering,
        user,
        message,
        unAuthenticated,
        hasError,
      ];

  AuthDataState copyWith({
    final fire_auth.User? user,
    final bool? loggingIn,
    final bool? registering,
    final String? message,
    final bool? unAuthenticated,
    final bool? hasError,
  }) =>
      AuthDataState(
        loggingIn: loggingIn ?? this.loggingIn,
        registering: registering ?? this.registering,
        user: user ?? this.user,
        message: message ?? this.message,
        unAuthenticated: unAuthenticated ?? this.unAuthenticated,
        hasError: hasError ?? this.hasError,
      );
}
