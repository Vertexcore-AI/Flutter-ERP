import 'environment.dart';

class ApiConfig {
  // Base URL - automatically uses environment-specific URL
  static String get baseUrl => EnvironmentConfig.baseUrl;

  // API Endpoints
  static String get apiPrefix => EnvironmentConfig.apiPrefix;

  // Auth endpoints
  static String get register => '$baseUrl$apiPrefix/auth/register';
  static String get login => '$baseUrl$apiPrefix/auth/login';
  static String get logout => '$baseUrl$apiPrefix/auth/logout';
  static String get me => '$baseUrl$apiPrefix/auth/me';

  // Dashboard endpoints
  static String get farms => '$baseUrl$apiPrefix/farms';
  static String get dashboard => '$baseUrl$apiPrefix/dashboard';
  static String get weather => '$baseUrl$apiPrefix/weather';

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> getAuthHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Environment info
  static String get environmentName => EnvironmentConfig.name;
  static bool get isProduction => EnvironmentConfig.isProduction;
}
