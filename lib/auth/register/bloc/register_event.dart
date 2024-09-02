import 'package:equatable/equatable.dart';

sealed class RegisterEvent extends Equatable {}

class InitRegisterEvent extends RegisterEvent {
  @override
  List<Object?> get props => [];
}

class SetRegisterEvent extends RegisterEvent {
  final bool registering;

  SetRegisterEvent({required this.registering});

  @override
  List<Object?> get props => [registering];
}
