import 'package:pillu_app/auth/register/bloc/register_bloc.dart';
import 'package:pillu_app/auth/register/bloc/register_event.dart';
import 'package:pillu_app/auth/register/bloc/register_state.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? _email;
  String? _firstName;
  FocusNode? _focusNode;
  String? _lastName;
  TextEditingController? _passwordController;
  TextEditingController? _usernameController;

  @override
  void initState() {
    super.initState();
    final faker = Faker();
    _firstName = faker.person.firstName();
    _lastName = faker.person.lastName();
    _email = '${_firstName!.toLowerCase()}.${_lastName!.toLowerCase()}@${faker.internet.domainName()}';
    _focusNode = FocusNode();
    _passwordController = TextEditingController(text: 'Qawsed1-');
    _usernameController = TextEditingController(
      text: _email,
    );
  }

  void _register() async {
    FocusScope.of(context).unfocus();

    BlocProvider.of<RegisterBloc>(context).add(SetRegisterEvent(registering: true));

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _usernameController!.text,
        password: _passwordController!.text,
      );
      types.User _user = types.User(
        firstName: _firstName,
        id: credential.user!.uid,
        imageUrl: 'https://i.pravatar.cc/300?u=$_email',
        lastName: _lastName,
      );

      await FirebaseChatCore.instance.createUserInFirestore(_user);

      if (!mounted) return;
      Navigator.of(context)
        ..pop()
        ..pop();
    } catch (e) {
      if (!mounted) return;
      BlocProvider.of<RegisterBloc>(context).add(SetRegisterEvent(registering: false));

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
          content: Text(
            e.toString(),
          ),
          title: const Text('Error'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _passwordController?.dispose();
    _usernameController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<RegisterBloc>(context).add(InitRegisterEvent());

    final bool registering = context.select(
      (RegisterBloc value) {
        final currState = value.state;
        if (currState is RegisterDataState) {
          return currState.registering;
        } else {
          return false;
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
          child: Column(
            children: [
              TextField(
                autocorrect: false,
                autofillHints: registering ? null : [AutofillHints.email],
                autofocus: true,
                controller: _usernameController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  labelText: 'Email',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () => _usernameController?.clear(),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                onEditingComplete: () {
                  _focusNode?.requestFocus();
                },
                readOnly: registering,
                textCapitalization: TextCapitalization.none,
                textInputAction: TextInputAction.next,
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  autocorrect: false,
                  autofillHints: registering ? null : [AutofillHints.password],
                  controller: _passwordController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () => _passwordController?.clear(),
                    ),
                  ),
                  focusNode: _focusNode,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: true,
                  onEditingComplete: _register,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.done,
                ),
              ),
              TextButton(
                onPressed: registering ? null : _register,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
