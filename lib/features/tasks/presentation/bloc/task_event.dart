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

/// Insert a locally-created task at the top of the list (no reload needed).
class TaskInserted extends TaskEvent {
  const TaskInserted(this.task);
  final TaskEntity task;
  @override
  List<Object?> get props => [task];
}

/// Replace an edited task in the list (already persisted by the edit flow).
class TaskUpdated extends TaskEvent {
  const TaskUpdated(this.task);
  final TaskEntity task;
  @override
  List<Object?> get props => [task];
}

/// Search-by-title text changed.
class TaskSearchChanged extends TaskEvent {
  const TaskSearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

/// Status / priority filter changed (null = "All").
class TaskFilterChanged extends TaskEvent {
  const TaskFilterChanged({this.status, this.priority});
  final TaskStatus? status;
  final TaskPriority? priority;
  @override
  List<Object?> get props => [status, priority];
}
