import 'dart:io';

class ApiConfig {
  /// Override at run time:
  /// `flutter run --dart-define=API_HOST=192.168.1.39`
  static const String _host = String.fromEnvironment(
    'API_HOST',
    defaultValue: '192.168.1.39',
  );

  static String get baseUrl {
    // Physical Android devices cannot use localhost/10.0.2.2 for the host Mac.
    // Emulator: pass --dart-define=API_HOST=10.0.2.2
    if (Platform.isAndroid || Platform.isIOS) {
      return 'http://$_host:3000/api/v1';
    }
    return 'http://localhost:3000/api/v1';
  }
}
