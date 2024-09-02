import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  FocusNode loginFocusNode = FocusNode();
  final loginPasswordController = TextEditingController(text: 'Pillu@123');
  final registerPasswordController = TextEditingController();
  final loginUsernameController = TextEditingController(text: '');
  final registerUsernameController = TextEditingController();
  final registerFocusNode = FocusNode();

  AuthBloc() : super(AuthDataState()) {
    on<InitAuthEvent>(_initAll);
    on<UpdateAuthStateEvent>(_updateAuthState);
  }

  @override
  Future<void> close() async {
    loginFocusNode.dispose();
    loginPasswordController.dispose();
    loginUsernameController.dispose();
    registerPasswordController.dispose();
    registerUsernameController.dispose();
    registerFocusNode.dispose();
    return await super.close();
  }

  void _initAll(AuthEvent event, Emitter<AuthState> emit) async {
    if (event is InitAuthEvent) {
      final faker = Faker();
      final _firstName = faker.person.firstName();
      final _lastName = faker.person.lastName();
      registerUsernameController.text = '${_firstName.toLowerCase()} ${_lastName.toLowerCase()}';
      registerPasswordController.text = 'Pillu@123';
    }
    emit(AuthDataState());
  }

  void _updateAuthState(UpdateAuthStateEvent event, Emitter<AuthState> emit) {
    final currState = state as AuthDataState;
    emit(currState.copyWith(
      loggingIn: event.loggingIn,
      registering: event.registering,
    ));
  }

  Future<void> login(AuthApi api) async {
    add(UpdateAuthStateEvent(loggingIn: true));
    await api.login(email: loginUsernameController.text, password: loginPasswordController.text);
  }

  Future<void> createAndRegisterUser(AuthApi api) async {
    final firstName = registerUsernameController.text.split(' ').first;
    final lastName = registerUsernameController.text.split(' ').last;
    final imageUrl = 'https://i.pravatar.cc/300?u=${faker.internet.domainName()}';

    add(UpdateAuthStateEvent(registering: true));

    final uid = await api.createRegisterUser(email: registerUsernameController.text, password: registerPasswordController.text);
    types.User user = types.User(imageUrl: imageUrl, firstName: firstName, lastName: lastName, id: uid);
    await api.createUser(user: user);
  }
}
