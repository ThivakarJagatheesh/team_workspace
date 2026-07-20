import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// Updates a task (status toggle, or a full edit). The [TaskEntity] itself is
/// the parameter — build the desired end-state with `task.copyWith(...)`.
class UpdateTask implements UseCase<TaskEntity, TaskEntity> {
  const UpdateTask(this._repository);
  final TaskRepository _repository;

  @override
  Future<Either<Failure, TaskEntity>> call(TaskEntity params) =>
      _repository.updateTask(params);
}
