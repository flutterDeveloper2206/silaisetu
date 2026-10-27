class ApiConfig {
  static const String liveBaseUrl = 'https://silaisetu.onrender.com/api/v1';

  /// Override full base URL:
  /// `flutter run --dart-define=API_BASE_URL=http://192.168.1.39:3000/api/v1`
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// Local Nest only when set:
  /// `flutter run --dart-define=API_HOST=192.168.1.39`
  static const String _host = String.fromEnvironment(
    'API_HOST',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_baseUrl.isNotEmpty) return _baseUrl;
    if (_host.isNotEmpty) return 'http://$_host:3000/api/v1';
    return liveBaseUrl;
  }

  /// Origin for static uploads (`/uploads/...`).
  static String get origin {
    final api = baseUrl;
    return api.replaceAll(RegExp(r'/api/v1/?$'), '');
  }

  static String mediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final p = path.startsWith('/') ? path : '/$path';
    return '$origin$p';
  }
}
