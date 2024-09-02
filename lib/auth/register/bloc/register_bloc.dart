import 'package:bloc/bloc.dart';
import 'package:pillu_app/auth/register/bloc/register_state.dart';

import 'register_event.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterDataState()) {
    on<InitRegisterEvent>(_init);
    on<SetRegisterEvent>(_setRegister);
  }

  void _init(InitRegisterEvent event, Emitter<RegisterState> emit) async {
    emit(RegisterDataState());
  }

  void _setRegister(SetRegisterEvent event, Emitter<RegisterState> emit) {
    _emitTheState(emit, registering: event.registering);
  }

  void _emitTheState(Emitter<RegisterState> emit, {bool? registering}) {
    final currState = state;
    if (currState is RegisterDataState) {
      emit(currState.copyWith(registering: registering));
    } else {
      emit(RegisterDataState());
    }
  }
}
