import 'package:equatable/equatable.dart';

sealed class RegisterState extends Equatable {}

class RegisterDataState extends RegisterState {
  final bool registering;

  RegisterDataState({
    this.registering = false,
  });

  @override
  List<Object?> get props => [registering];

  RegisterDataState init({bool registering = false}) {
    return RegisterDataState(registering: registering);
  }

  RegisterDataState copyWith({bool? registering}) {
    return RegisterDataState(registering: registering ?? this.registering);
  }
}
