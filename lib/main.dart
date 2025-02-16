import 'package:pillu_app/core/library/pillu_lib.dart';

final AppConfig config = AppConfig();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await config.configure(isConfigureFirebase: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(final BuildContext context) => const MaterialApp(
        title: 'Firebase Chat',
        debugShowCheckedModeBanner: false,
        home: RoomsPage(),
      );
}
