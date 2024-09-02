import 'package:bloc/bloc.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:pillu_app/auth/auth_api.dart';
import 'package:pillu_app/auth/register/bloc/register_state.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;

import 'register_event.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final focusNode = FocusNode();

  RegisterBloc() : super(RegisterDataState()) {
    on<InitRegisterEvent>(_init);
    on<SetRegisterEvent>(_setRegister);
  }

  @override
  Future<void> close() async {
    passwordController.dispose();
    usernameController.dispose();
    focusNode.dispose();
    return await super.close();
  }

  void _init(InitRegisterEvent event, Emitter<RegisterState> emit) async {
    final faker = Faker();
    final _firstName = faker.person.firstName();
    final _lastName = faker.person.lastName();

    usernameController.text = '${_firstName.toLowerCase()} ${_lastName.toLowerCase()}';
    passwordController.text = 'Pillu@123';

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

  Future<void> createAndRegisterUser(AuthApi api) async {

    final firstName = usernameController.text.split(' ').first;
    final lastName = usernameController.text.split(' ').last;
    final imageUrl = 'https://i.pravatar.cc/300?u=${faker.internet.domainName()}';

    add(SetRegisterEvent(registering: true));

    add(SetRegisterEvent(registering: true));
    final uid = await api.createRegisterUser(email: usernameController.text, password: passwordController.text);
    types.User user = types.User(imageUrl: imageUrl, firstName: firstName, lastName: lastName, id: uid);
    await api.createUser(user: user);
  }
}
