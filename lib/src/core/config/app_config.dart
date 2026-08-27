class AppConfig {
  static const String defaultApiBaseUrl = 'https://lem3alam.ma/public/api/v1/';

  static const String _configuredApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: defaultApiBaseUrl,
  );

  static String get apiBaseUrl => normalizeApiBaseUrl(_configuredApiBaseUrl);

  static const String appLocale = 'ar';
}

String normalizeApiBaseUrl(String value) {
  final normalized = value.trim();
  return normalized.endsWith('/') ? normalized : '$normalized/';
}
