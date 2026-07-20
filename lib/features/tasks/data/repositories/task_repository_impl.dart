import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../datasources/task_outbox_data_source.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

/// Remote-first with an offline fallback: page 1 is cached on success and
/// served from cache when the network is unavailable. Offline create/update
/// operations are queued in the outbox and replayed by [TaskSyncService].
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({
    required this.remote,
    required this.local,
    required this.outbox,
    required this.networkInfo,
  });

  final TaskRemoteDataSource remote;
  final TaskLocalDataSource local;
  final TaskOutboxDataSource outbox;
  final NetworkInfo networkInfo;

  int _opSeq = 0;
  String _opId(int taskId) {
    _opSeq++;
    return '${DateTime.now().microsecondsSinceEpoch}_${taskId}_$_opSeq';
  }

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
        await local.upsertTask(model);
      } else {
        await _saveOffline(model, OutboxOpType.update);
      }
      return Right(task);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      await _saveOffline(model, OutboxOpType.update);
      return Right(task);
    } catch (_) {
      return const Left(ServerFailure('Could not update the task.'));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> createTask({
    required String title,
    required String description,
    required TaskPriority priority,
    required DateTime dueDate,
  }) async {
    final model = TaskModel(
      id: _nextId(),
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      status: TaskStatus.pending,
      assignedTo: 'You',
    );
    try {
      if (await networkInfo.isConnected) {
        await remote.createTask(model);
        await local.upsertTask(model);
      } else {
        await _saveOffline(model, OutboxOpType.create);
      }
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      await _saveOffline(model, OutboxOpType.create);
      return Right(model);
    } catch (_) {
      return const Left(ServerFailure('Could not create the task.'));
    }
  }

  /// Cache the change locally and queue it for replay when back online.
  Future<void> _saveOffline(TaskModel model, OutboxOpType type) async {
    await local.upsertTask(model);
    await outbox.enqueue(
      OutboxOperation(
        id: _opId(model.id),
        type: type,
        task: model,
        enqueuedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// New id above the API's id range (1–200) and any cached id, so created
  /// tasks never collide with fetched ones.
  int _nextId() {
    final cached = local.getCachedTasks();
    final maxCached = cached.isEmpty
        ? 0
        : cached.map((t) => t.id).reduce((a, b) => a > b ? a : b);
    return (maxCached < 1000 ? 1000 : maxCached) + 1;
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
