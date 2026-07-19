import '../constants/app_constants.dart';

enum Flavor { dev, prod }

/// Build flavor configuration (Dev / Prod). Set once from the flavor entrypoint
/// (`main_dev.dart` / `main_prod.dart`) before the app boots.
class FlavorConfig {
  FlavorConfig._({
    required this.flavor,
    required this.name,
    required this.baseUrl,
  });

  final Flavor flavor;
  final String name;
  final String baseUrl;

  static FlavorConfig? _instance;

  factory FlavorConfig({
    required Flavor flavor,
    required String name,
    required String baseUrl,
  }) {
    return _instance ??= FlavorConfig._(
      flavor: flavor,
      name: name,
      baseUrl: baseUrl,
    );
  }

  /// Falls back to Dev defaults if an entrypoint didn't set one (e.g. tests).
  static FlavorConfig get instance =>
      _instance ??
      FlavorConfig(
        flavor: Flavor.dev,
        name: 'DEV',
        baseUrl: AppConstants.baseUrl,
      );

  bool get isDev => flavor == Flavor.dev;
}
