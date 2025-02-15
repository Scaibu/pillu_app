import 'package:pillu_app/auth/auth_repository.dart';
import 'package:pillu_app/auth/bloc/auth_bloc.dart';
import 'package:pillu_app/auth/bloc/auth_event.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl = 'https://yyvijfzeiucgfdgexooh.supabase.co';
const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
    'eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl5d'
    'mlqZnplaXVjZ2ZkZ2V4b29oIiwicm9sZSI6Im'
    'Fub24iLCJpYXQiOjE3Mzk2MTQ4MzgsImV4cCI'
    '6MjA1NTE5MDgzOH0.weKFksh67ODJjhAZS2URn'
    '37evX3K7tasudTNWxiUF88';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(final BuildContext context) => MaterialApp(
        title: 'Firebase Chat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          cardColor: Colors.deepPurple.shade50,
          textTheme: TextTheme(
            bodyLarge: TextStyle(
              color: Colors.deepPurple.shade900,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.deepPurple.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // Rounded edges
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            hintStyle: TextStyle(
              color: Colors.deepPurple.shade300,
            ),
            labelStyle: TextStyle(
              color: Colors.deepPurple.shade800,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        home: BlocProvider<AuthBloc>(
          create: (final BuildContext context) =>
              AuthBloc(AuthRepository())..add(AuthAuthenticated()),
          child: const RoomsPage(),
        ),
      );
}
