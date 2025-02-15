import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

sealed class AuthEvent extends Equatable {
  @override
  List<Object?> get props => <Object?>[];
}

class InitAuthEvent extends AuthEvent {}

class AuthAuthenticated extends AuthEvent {
  AuthAuthenticated({this.user});

  final fire_auth.User? user;

  @override
  List<Object?> get props => <Object?>[user];
}

class UpdateAuthStateEvent extends AuthEvent {
  UpdateAuthStateEvent({this.loggingIn, this.registering});

  final bool? loggingIn;
  final bool? registering;

  @override
  List<Object?> get props => <Object?>[loggingIn, registering];
}

class SetUserEvent extends AuthEvent {}

class UserLogOutEvent extends AuthEvent {}
