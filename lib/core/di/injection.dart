import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/sign_up.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/tasks/data/datasources/task_local_data_source.dart';
import '../../features/tasks/data/datasources/task_remote_data_source.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/get_tasks.dart';
import '../../features/tasks/domain/usecases/update_task.dart';
import '../../features/tasks/presentation/bloc/task_bloc.dart';
import '../constants/app_constants.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';

/// Global service locator. One container for the whole app.
final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  // ── External ──────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  final tasksBox = await Hive.openBox<dynamic>(AppConstants.tasksBox);
  sl.registerSingleton<Box<dynamic>>(tasksBox);

  sl.registerLazySingleton<Connectivity>(Connectivity.new);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // ── Core ─────────────────────────────────────────────────
  sl.registerLazySingleton<DioClient>(DioClient.new);
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // ── Features ─────────────────────────────────────────────
  _registerAuth();
  _registerTasks();
}

void _registerAuth() {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl(), local: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // Bloc (factory — a fresh bloc per injection)
  sl.registerFactory(
    () => AuthBloc(
      signUp: sl(),
      login: sl(),
      logout: sl(),
      getCurrentUser: sl(),
    ),
  );
}

void _registerTasks() {
  // Data sources
  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(remote: sl(), local: sl(), networkInfo: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTasks(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));

  // Bloc
  sl.registerFactory(() => TaskBloc(getTasks: sl(), updateTask: sl()));
}
