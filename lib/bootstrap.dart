import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'features/tasks/data/sync/task_sync_service.dart';

/// Shared startup used by every flavor entrypoint. Order matters:
///   1. Flutter bindings
///   2. Local storage (Hive)
///   3. Firebase (required for Auth)
///   4. Dependency injection
///   5. Offline sync service
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Reads native config (android/app/google-services.json, iOS plist) written
  // by `flutterfire configure`.
  await Firebase.initializeApp();

  await configureDependencies();

  // Replay any offline changes and keep watching connectivity.
  sl<TaskSyncService>().start();

  runApp(const TeamWorkspaceApp());
}
