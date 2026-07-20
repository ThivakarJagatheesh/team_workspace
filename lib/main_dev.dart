import 'bootstrap.dart';
import 'core/config/flavor.dart';
import 'core/env/env.dart';

/// Dev flavor entrypoint: `flutter run -t lib/main_dev.dart`.
Future<void> main() async {
  await Env.load('.env.example'); // Load .env file for dev/prod config

  FlavorConfig(
    flavor: Flavor.dev,
    name: 'DEV',
    baseUrl: Env.devBaseUrl,
  );
  await bootstrap();
}
