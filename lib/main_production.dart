import 'config/environment.dart';
import 'main.dart' as app;

void main() {
  // Set environment to production
  EnvironmentConfig.setEnvironment(Environment.production);

  // Run the app
  app.main();
}
