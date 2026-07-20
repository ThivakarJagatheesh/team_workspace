import 'bootstrap.dart';
import 'core/config/flavor.dart';
import 'core/constants/app_constants.dart';

/// Prod flavor entrypoint: `flutter run -t lib/main_prod.dart --release`.
Future<void> main() async {
  FlavorConfig(
    flavor: Flavor.prod,
    name: 'PROD',
    // Point this at the production API. Falls back to the demo base URL.
    baseUrl: AppConstants.baseUrl,
  );
  await bootstrap();
}
