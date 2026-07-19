import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../network/network_info.dart';

/// Global service locator. One container for the whole app.
///
/// Registration convention:
///   • external + core singletons here (this file)
///   • each feature adds its own `registerXxx(sl)` in its data layer, called
///     from [configureDependencies] as features are built out stage by stage.
final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  // ── External ──────────────────────────────────────────────
  sl.registerLazySingleton<Connectivity>(Connectivity.new);

  // ── Core ─────────────────────────────────────────────────
  sl.registerLazySingleton<DioClient>(DioClient.new);
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // ── Features (wired in during stage-by-stage development) ──
  // await registerAuthFeature(sl);
  // await registerTasksFeature(sl);
}
