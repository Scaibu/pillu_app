import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

sealed class AuthEvent extends Equatable {
  @override
  List<Object?> get props => <Object?>[];
}

class AuthAuthenticated extends AuthEvent {
  AuthAuthenticated({this.user});

  final fire_auth.User? user;

  @override
  List<Object?> get props => <Object?>[user];
}

class UserLogOutEvent extends AuthEvent {}

class IsRestartEvent extends AuthEvent {}

class StartCurrentEvent extends AuthEvent {}

class AuthLoadingEvent extends AuthEvent {
  AuthLoadingEvent({required this.isLoading});

  final bool isLoading;

  @override
  List<Object?> get props => <Object?>[isLoading];
}
