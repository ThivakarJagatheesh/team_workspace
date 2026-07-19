import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

/// Remote-first with an offline fallback: page 1 is cached on success and
/// served from cache when the network is unavailable.
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({
    required this.remote,
    required this.local,
    required this.networkInfo,
  });

  final TaskRemoteDataSource remote;
  final TaskLocalDataSource local;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks({
    required int page,
    required int limit,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final tasks = await remote.getTasks(page: page, limit: limit);
        if (page == 1) {
          await local.cacheTasks(tasks); // keep the first page for offline
        }
        return Right(tasks);
      } on NetworkException {
        return _cachedOr(page, const NetworkFailure());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (_) {
        return const Left(ServerFailure());
      }
    }
    // Offline: only the first page is available from cache.
    return _cachedOr(page, const NetworkFailure());
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    try {
      if (await networkInfo.isConnected) {
        await remote.updateTask(model);
      }
      // Always mirror into the cache so the change survives offline and a
      // restart. (Stage 6 adds an outbox to replay offline edits to the API.)
      await local.upsertTask(model);
      return Right(task);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      await local.upsertTask(model); // keep the change locally
      return Right(task);
    } catch (_) {
      return const Left(ServerFailure('Could not update the task.'));
    }
  }

  /// Serve cached tasks for page 1; otherwise surface [fallback].
  Either<Failure, List<TaskEntity>> _cachedOr(int page, Failure fallback) {
    if (page == 1) {
      final cached = local.getCachedTasks();
      if (cached.isNotEmpty) return Right(cached);
    }
    return Left(fallback);
  }
}
