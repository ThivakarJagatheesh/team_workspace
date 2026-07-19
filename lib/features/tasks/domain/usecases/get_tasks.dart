import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasks implements UseCase<List<TaskEntity>, TaskPageParams> {
  const GetTasks(this._repository);
  final TaskRepository _repository;

  @override
  Future<Either<Failure, List<TaskEntity>>> call(TaskPageParams params) =>
      _repository.getTasks(page: params.page, limit: params.limit);
}

class TaskPageParams extends Equatable {
  const TaskPageParams({required this.page, required this.limit});
  final int page;
  final int limit;

  @override
  List<Object?> get props => [page, limit];
}
