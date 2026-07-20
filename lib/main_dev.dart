import 'bootstrap.dart';
import 'core/config/flavor.dart';
import 'core/constants/app_constants.dart';

/// Dev flavor entrypoint: `flutter run -t lib/main_dev.dart`.
Future<void> main() async {
  FlavorConfig(
    flavor: Flavor.dev,
    name: 'DEV',
    baseUrl: AppConstants.baseUrl,
  );
  await bootstrap();
}
