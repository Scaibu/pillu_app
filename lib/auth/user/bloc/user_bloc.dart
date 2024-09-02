import 'package:pillu_app/core/library/pillu_lib.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserDataState()) {
    on<InitUserEvent>(_init);
  }

  void _init(InitUserEvent event, Emitter<UserState> emit) async {
    _emitTheState(emit);
  }

  void _emitTheState(Emitter<UserState> emit, {bool? registering}) {
    final currState = state;
    if (currState is UserDataState) {
      emit(currState.copyWith(registering: registering));
    } else {
      emit(UserDataState());
    }
  }
}
