import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';

class AppConfig {
  static String _supabaseUrl = '';
  static String _supabaseKey = '';
  static String _baseUrl = '';
  static bool _debugShowChecked = false;
  static bool isConfigureFirebase = false;
  static bool _useGoogleSignIn = false;
  static bool _isConfigureSupabase = false;
  static Color _primary = Colors.white;
  static Color _background = Colors.white;
  static Color _card = Colors.white;
  static Color _textPrimary = Colors.white;
  static Color _hint = Colors.white;
  static Color _label = Colors.white;
  static bool _isPackage = false;

  static String get supabaseUrl => _supabaseUrl;

  static String get supabaseKey => _supabaseKey;

  static String get baseUrl => _baseUrl;

  static bool get debugShowChecked => _debugShowChecked;

  static bool get useGoogleSignIn => _useGoogleSignIn;

  static bool get isConfigureSupabase => _isConfigureSupabase;

  static Color get primary => _primary;

  static Color get background => _background;

  static Color get card => _card;

  static Color get textPrimary => _textPrimary;

  static Color get hint => _hint;

  static Color get label => _label;

  static bool get isPackage => _isPackage;

  void _environmentVariables(final FirebaseRemoteConfig remoteConfig) {
    _supabaseUrl = remoteConfig.getString('supabase_url');
    _useGoogleSignIn = remoteConfig.getBool('use_google_sign_in');
    _supabaseKey = remoteConfig.getString('supabase_key');
    _isConfigureSupabase = remoteConfig.getBool('is_configure_supabase');
    _baseUrl = remoteConfig.getString('base_url');
    _debugShowChecked = remoteConfig.getBool('debug_show_checked');
    _primary = _getColor(remoteConfig.getString('primary_color'));
    _background = _getColor(remoteConfig.getString('background_color'));
    _card = _getColor(remoteConfig.getString('card_color'));
    _textPrimary = _getColor(remoteConfig.getString('text_primary_color'));
    _hint = _getColor(remoteConfig.getString('hint_color'));
    _label = _getColor(remoteConfig.getString('label_color'));
    _isPackage = remoteConfig.getBool('is_package');
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
