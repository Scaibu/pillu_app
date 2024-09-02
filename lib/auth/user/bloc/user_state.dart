import 'package:equatable/equatable.dart';

sealed class UserState extends Equatable {}

class UserDataState extends UserState {
  final bool registering;

  UserDataState({this.registering = false});

  @override
  List<Object?> get props => [registering];

  UserDataState init({bool registering = false}) {
    return UserDataState(registering: registering);
  }

  UserDataState copyWith({bool? registering}) {
    return UserDataState(registering: registering ?? this.registering);
  }
}
