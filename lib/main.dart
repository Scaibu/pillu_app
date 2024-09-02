import 'package:pillu_app/auth/user/bloc/user_bloc.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginBloc()),
        BlocProvider(create: (context) => RegisterBloc()),
        BlocProvider(create: (context) => UserBloc()),
      ],
      child: MaterialApp(
        title: 'Firebase Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const RoomsPage(),
      ),
    );
  }
}
