import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  FocusNode focusNode = FocusNode();
  TextEditingController passwordController = TextEditingController(text: 'Qawsed1-');
  TextEditingController usernameController = TextEditingController(text: '');

  LoginBloc() : super(LoginDataState().init()) {
    on<InitLoginEvent>(_init);
    on<MakeLoginEvent>(_updateLoginEvent);
  }

  void _updateLoginEvent(MakeLoginEvent event, Emitter<LoginState> emit) {
    _emitTheState(emit, loggingIn: event.loggingIn);
  }

  void _init(InitLoginEvent event, Emitter<LoginState> emit) async {
    _emitTheState(emit);
  }

  @override
  Future<void> close() async {
    focusNode.dispose();
    passwordController.dispose();
    usernameController.dispose();
    return await super.close();
  }

  void _emitTheState(Emitter<LoginState> emit, {bool? loggingIn}) {
    final currState = state;
    if (currState is LoginDataState) {
      emit(currState.copyWith(loggingIn: loggingIn ?? currState.loggingIn));
    } else {
      emit(LoginDataState(loggingIn: loggingIn ?? false));
    }
  }
}
