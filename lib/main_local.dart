import 'config/environment.dart';
import 'main.dart' as app;

void main() {
  // Set environment to local
  EnvironmentConfig.setEnvironment(Environment.local);

  // Run the app
  app.main();
}
