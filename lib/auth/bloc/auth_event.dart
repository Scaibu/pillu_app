import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitAuthEvent extends AuthEvent {}

class UpdateAuthStateEvent extends AuthEvent {
  final bool? loggingIn;
  final bool? registering;

  UpdateAuthStateEvent({this.loggingIn, this.registering});

  @override
  List<Object?> get props => [loggingIn, registering];
}

class SetUserEvent extends AuthEvent {}
