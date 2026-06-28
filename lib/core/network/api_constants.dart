class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );

  static const String uploadsUrl = String.fromEnvironment(
    'MANGADEX_UPLOADS_URL',
    defaultValue: 'https://uploads.mangadex.org',
  );
}
