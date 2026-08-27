import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/src/core/config/app_config.dart';

void main() {
  test('production API base URL points directly to the Laravel API', () {
    expect(
      AppConfig.defaultApiBaseUrl,
      'https://lem3alam.ma/public/api/v1/',
    );
  });

  test('API base URL uses the compile-time configuration', () {
    const configured = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: AppConfig.defaultApiBaseUrl,
    );

    expect(AppConfig.apiBaseUrl, normalizeApiBaseUrl(configured));
  });

  test('API base URL normalization adds a trailing slash', () {
    expect(
      normalizeApiBaseUrl(' http://10.0.2.2/m3alam/public/api/v1 '),
      'http://10.0.2.2/m3alam/public/api/v1/',
    );
  });

  test('API base URL normalization preserves an existing trailing slash', () {
    expect(
      normalizeApiBaseUrl('https://example.com/api/v1/'),
      'https://example.com/api/v1/',
    );
  });
}
