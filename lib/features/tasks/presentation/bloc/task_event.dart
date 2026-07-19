part of 'task_bloc.dart';

sealed class TaskEvent extends Equatable {
  const TaskEvent();
  @override
  List<Object?> get props => [];
}

/// Load the next page (also used for the very first load).
class TasksFetched extends TaskEvent {
  const TasksFetched();
}

/// Pull-to-refresh: reset to page 1.
class TasksRefreshed extends TaskEvent {
  const TasksRefreshed();
}

/// Toggle a task between completed and reopened (pending).
class TaskStatusToggled extends TaskEvent {
  const TaskStatusToggled(this.task);
  final TaskEntity task;
  @override
  List<Object?> get props => [task];
}
