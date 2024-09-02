import 'package:pillu_app/core/library/pillu_lib.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  FocusNode focusNode = FocusNode();
  TextEditingController passwordController = TextEditingController(text: 'Pillu@123');
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

  Future<void> login(AuthApi api) async {
    add(MakeLoginEvent(true));
    await api.login(email: usernameController.text, password: passwordController.text);
  }
}
