class AppConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://hamza-rmb.onrender.com/api/v1',
  );

  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static String googleMapsApiKey = const String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static void setGoogleMapsApiKey(String key) {
    googleMapsApiKey = key;
  }

  /// Default coordinates (Abuja, Nigeria)
  static const double defaultLatitude = 9.0765;
  static const double defaultLongitude = 7.3986;
  static const String defaultCityName = 'Abuja';
  static const String defaultCountryName = 'Nigeria';

  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
}
