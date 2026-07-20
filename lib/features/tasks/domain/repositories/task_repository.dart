import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';

/// Tasks contract. Paginated reads + updates; create is added in a later stage.
abstract class TaskRepository {
  /// Returns one page of tasks. `page` is 1-based.
  ///
  /// On a network failure for the first page, implementations should fall back
  /// to the cached list so the dashboard still renders offline.
  Future<Either<Failure, List<TaskEntity>>> getTasks({
    required int page,
    required int limit,
  });

  /// Persist changes to a task (status toggle in Stage 3, full edit in Stage 5)
  /// and mirror them into the local cache. Returns the updated task.
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task);

  /// Create a task. The implementation assigns an id and caches it. Returns the
  /// created task (with id + defaults filled in).
  Future<Either<Failure, TaskEntity>> createTask({
    required String title,
    required String description,
    required TaskPriority priority,
    required DateTime dueDate,
  });
}
