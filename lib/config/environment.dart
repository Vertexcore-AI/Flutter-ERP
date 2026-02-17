enum Environment {
  local,
  production,
}

class EnvironmentConfig {
  static Environment _environment = Environment.local;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static Environment get environment => _environment;

  static bool get isProduction => _environment == Environment.production;
  static bool get isLocal => _environment == Environment.local;

  static String get baseUrl {
    switch (_environment) {
      case Environment.local:
        return 'http://localhost:8000';
      case Environment.production:
        return 'https://vertexcoreai.com/govi_potha';
    }
  }

  static String get apiPrefix => '/api';

  static String get name {
    switch (_environment) {
      case Environment.local:
        return 'Local';
      case Environment.production:
        return 'Production';
    }
  }
}
