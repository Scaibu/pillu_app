import 'package:equatable/equatable.dart';

sealed class LoginState extends Equatable {}

class LoginDataState extends LoginState {
  final bool? loggingIn;

  LoginDataState({this.loggingIn});

  @override
  List<Object?> get props => throw UnimplementedError();

  LoginDataState init() {
    return LoginDataState(loggingIn: false);
  }

  LoginDataState copyWith({bool? loggingIn}) {
    return LoginDataState(loggingIn: loggingIn ?? this.loggingIn);
  }
}
