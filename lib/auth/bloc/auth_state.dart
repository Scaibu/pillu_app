import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth show User;
class AuthDataState extends Equatable {
  const AuthDataState({
    this.loggingIn = false,
    this.registering = false,
    this.user,
    this.message,
    this.unAuthenticated = true,
    this.hasError = false,
    this.isRestartEvent = false,
    this.isLoading = false,
  });

  final bool loggingIn;
  final bool registering;
  final bool unAuthenticated;
  final bool hasError;
  final bool isRestartEvent;
  final bool isLoading;
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
    isRestartEvent,
    isLoading,
  ];

  AuthDataState copyWith({
    final fire_auth.User? user,
    final bool? loggingIn,
    final bool? registering,
    final String? message,
    final bool? unAuthenticated,
    final bool? hasError,
    final bool? isRestartEvent,
    final bool? isLoading,
  }) =>
      AuthDataState(
        loggingIn: loggingIn ?? this.loggingIn,
        registering: registering ?? this.registering,
        user: user ?? this.user,
        message: message ?? this.message,
        unAuthenticated: unAuthenticated ?? this.unAuthenticated,
        hasError: hasError ?? this.hasError,
        isRestartEvent: isRestartEvent ?? this.isRestartEvent,
        isLoading: isLoading ?? this.isLoading, // NEW
      );
}
