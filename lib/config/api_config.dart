class ApiConfig {
  // Base URL - Change this to your backend URL
  static const String baseUrl = 'http://localhost:8000';

  // API Endpoints
  static const String apiPrefix = '/api';

  // Auth endpoints
  static String get register => '$baseUrl$apiPrefix/auth/register';
  static String get login => '$baseUrl$apiPrefix/auth/login';
  static String get logout => '$baseUrl$apiPrefix/auth/logout';
  static String get me => '$baseUrl$apiPrefix/auth/me';

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
}
