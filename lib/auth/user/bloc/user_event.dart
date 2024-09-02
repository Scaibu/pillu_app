import 'package:equatable/equatable.dart';

sealed class UserEvent extends Equatable {}

class InitUserEvent extends UserEvent {
  @override
  List<Object?> get props => [];
}

class SetUserEvent extends UserEvent {
  SetUserEvent();

  @override
  List<Object?> get props => [];
}
