import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfig {
  static String supabaseUrl = '';
  static String supabaseKey = '';
  static String baseUrl = '';
  static bool debugShowChecked = false;

  final bool isConfigureFirebase = false;
  final bool isConfigureSupabase = false;

  static Color primary = Colors.white;
  static Color background = Colors.white;
  static Color card = Colors.white;
  static Color textPrimary = Colors.white;
  static Color hint = Colors.white;
  static Color label = Colors.white;

  void _environmentVariables(final FirebaseRemoteConfig remoteConfig) {
    supabaseUrl = remoteConfig.getString('supabase_url');
    supabaseKey = remoteConfig.getString('supabase_key');
    baseUrl = remoteConfig.getString('base_url');
    debugShowChecked = remoteConfig.getBool('debug_show_checked');
    primary = _getColor(remoteConfig.getString('primary_color'));
    background = _getColor(remoteConfig.getString('background_color'));
    card = _getColor(remoteConfig.getString('card_color'));
    textPrimary = _getColor(remoteConfig.getString('text_primary_color'));
    hint = _getColor(remoteConfig.getString('hint_color'));
    label = _getColor(remoteConfig.getString('label_color'));
  }

  Future<void> _fetchRemoteConfig() async {
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(minutes: 30),
      ),
    );

    await remoteConfig.fetchAndActivate();
    _environmentVariables(remoteConfig);
  }

  Future<void> configure({required final bool isConfigureFirebase}) async {
    if (isConfigureFirebase) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    await _fetchRemoteConfig();

    if (isConfigureSupabase && supabaseUrl.isNotEmpty) {
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
    }
  }

  static Color _getColor(final String value) => Color(int.parse('0xFF$value'));
}
