import 'package:equatable/equatable.dart';

sealed class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthDataState extends AuthState {
  final bool loggingIn;
  final bool registering;

  AuthDataState({
    this.loggingIn = false,
    this.registering = false,
  });

  @override
  List<Object?> get props => [loggingIn, registering];

  AuthDataState copyWith({bool? loggingIn, bool? registering}) {
    return AuthDataState(
      loggingIn: loggingIn ?? this.loggingIn,
      registering: registering ?? this.registering,
    );
  }
}
