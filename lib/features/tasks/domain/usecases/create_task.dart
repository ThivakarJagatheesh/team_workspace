import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class CreateTask implements UseCase<TaskEntity, CreateTaskParams> {
  const CreateTask(this._repository);
  final TaskRepository _repository;

  @override
  Future<Either<Failure, TaskEntity>> call(CreateTaskParams params) =>
      _repository.createTask(
        title: params.title,
        description: params.description,
        priority: params.priority,
        dueDate: params.dueDate,
      );
}

class CreateTaskParams extends Equatable {
  const CreateTaskParams({
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
  });

  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime dueDate;

  @override
  List<Object?> get props => [title, description, priority, dueDate];
}
