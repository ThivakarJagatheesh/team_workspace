part of 'task_bloc.dart';

/// List-level status. Named to avoid clashing with the entity's [TaskStatus].
enum TaskListStatus { initial, loading, success, failure }

/// Sentinel so [TaskState.copyWith] can set the nullable filters back to null
/// (a plain `null` default can't distinguish "clear" from "keep").
const Object _unset = Object();

class TaskState extends Equatable {
  const TaskState({
    this.status = TaskListStatus.initial,
    this.tasks = const [],
    this.hasReachedMax = false,
    this.errorMessage,
    this.query = '',
    this.statusFilter,
    this.priorityFilter,
  });

  final TaskListStatus status;
  final List<TaskEntity> tasks;
  final bool hasReachedMax;
  final String? errorMessage;

  // Stage 6 — search & filter
  final String query;
  final TaskStatus? statusFilter;
  final TaskPriority? priorityFilter;

  /// Tasks after applying the title search + status + priority filters
  /// (all combined). Filtering runs over the loaded pages.
  List<TaskEntity> get filteredTasks {
    final q = query.trim().toLowerCase();
    return tasks.where((t) {
      final matchesQuery = q.isEmpty || t.title.toLowerCase().contains(q);
      final matchesStatus = statusFilter == null || t.status == statusFilter;
      final matchesPriority =
          priorityFilter == null || t.priority == priorityFilter;
      return matchesQuery && matchesStatus && matchesPriority;
    }).toList();
  }

  bool get hasActiveFilters =>
      query.trim().isNotEmpty || statusFilter != null || priorityFilter != null;

  TaskState copyWith({
    TaskListStatus? status,
    List<TaskEntity>? tasks,
    bool? hasReachedMax,
    String? errorMessage,
    String? query,
    Object? statusFilter = _unset,
    Object? priorityFilter = _unset,
  }) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage,
      query: query ?? this.query,
      statusFilter: identical(statusFilter, _unset)
          ? this.statusFilter
          : statusFilter as TaskStatus?,
      priorityFilter: identical(priorityFilter, _unset)
          ? this.priorityFilter
          : priorityFilter as TaskPriority?,
    );
  }

  @override
  List<Object?> get props => [
        status,
        tasks,
        hasReachedMax,
        errorMessage,
        query,
        statusFilter,
        priorityFilter,
      ];
}
