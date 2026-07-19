part of 'task_bloc.dart';

/// List-level status. Named to avoid clashing with the entity's [TaskStatus].
enum TaskListStatus { initial, loading, success, failure }

class TaskState extends Equatable {
  const TaskState({
    this.status = TaskListStatus.initial,
    this.tasks = const [],
    this.hasReachedMax = false,
    this.errorMessage,
  });

  final TaskListStatus status;
  final List<TaskEntity> tasks;
  final bool hasReachedMax;
  final String? errorMessage;

  TaskState copyWith({
    TaskListStatus? status,
    List<TaskEntity>? tasks,
    bool? hasReachedMax,
    String? errorMessage,
  }) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tasks, hasReachedMax, errorMessage];
}
