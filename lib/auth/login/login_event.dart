import 'package:equatable/equatable.dart';

sealed class LoginEvent extends Equatable {}

class InitLoginEvent extends LoginEvent {
  @override
  List<Object?> get props => [];
}

class MakeLoginEvent extends LoginEvent {
  final bool loggingIn;

  MakeLoginEvent(this.loggingIn);

  @override
  List<Object?> get props => [loggingIn];
}
