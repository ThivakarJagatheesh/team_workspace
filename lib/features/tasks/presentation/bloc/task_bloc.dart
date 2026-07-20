import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/update_task.dart';

part 'task_event.dart';
part 'task_state.dart';

/// Owns the dashboard task list: pagination (infinite scroll) + refresh.
///
/// `droppable()` ignores scroll events that arrive while a fetch is already
/// running, so we never double-load the same page.
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc({required GetTasks getTasks, required UpdateTask updateTask})
      : _getTasks = getTasks,
        _updateTask = updateTask,
        super(const TaskState()) {
    on<TasksFetched>(_onFetched, transformer: droppable());
    on<TasksRefreshed>(_onRefreshed, transformer: droppable());
    on<TaskStatusToggled>(_onStatusToggled);
    on<TaskInserted>(_onInserted);
    on<TaskUpdated>(_onUpdated);
    on<TaskSearchChanged>(_onSearchChanged);
    on<TaskFilterChanged>(_onFilterChanged);
  }

  final GetTasks _getTasks;
  final UpdateTask _updateTask;
  static const int _limit = AppConstants.pageSize;

  Future<void> _onFetched(TasksFetched event, Emitter<TaskState> emit) async {
    if (state.hasReachedMax) return;

    final isFirstLoad = state.status == TaskListStatus.initial;
    if (isFirstLoad) emit(state.copyWith(status: TaskListStatus.loading));

    final page = (state.tasks.length ~/ _limit) + 1;
    final result = await _getTasks(TaskPageParams(page: page, limit: _limit));

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TaskListStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (fetched) => emit(
        state.copyWith(
          status: TaskListStatus.success,
          tasks: [...state.tasks, ...fetched],
          hasReachedMax: fetched.length < _limit,
        ),
      ),
    );
  }

  /// Optimistically flips the task's status in the list, then persists it.
  /// Reverts if the update fails, so the UI never lies.
  Future<void> _onStatusToggled(
    TaskStatusToggled event,
    Emitter<TaskState> emit,
  ) async {
    final original = event.task;
    final updated = original.copyWith(
      status: original.status.isCompleted
          ? TaskStatus.pending // reopen
          : TaskStatus.completed, // mark complete
    );

    emit(state.copyWith(tasks: _replace(state.tasks, updated)));

    final result = await _updateTask(updated);
    result.fold(
      (failure) => emit(
        state.copyWith(
          tasks: _replace(state.tasks, original), // revert
          errorMessage: failure.message,
        ),
      ),
      (_) {}, // already reflected
    );
  }

  List<TaskEntity> _replace(List<TaskEntity> tasks, TaskEntity t) =>
      tasks.map((e) => e.id == t.id ? t : e).toList();

  void _onInserted(TaskInserted event, Emitter<TaskState> emit) {
    emit(
      state.copyWith(
        status: TaskListStatus.success,
        tasks: [event.task, ...state.tasks],
      ),
    );
  }

  void _onUpdated(TaskUpdated event, Emitter<TaskState> emit) {
    emit(state.copyWith(tasks: _replace(state.tasks, event.task)));
  }

  void _onSearchChanged(TaskSearchChanged event, Emitter<TaskState> emit) {
    emit(state.copyWith(query: event.query));
  }

  void _onFilterChanged(TaskFilterChanged event, Emitter<TaskState> emit) {
    emit(state.copyWith(
      statusFilter: event.status,
      priorityFilter: event.priority,
    ),);
  }

  Future<void> _onRefreshed(
    TasksRefreshed event,
    Emitter<TaskState> emit,
  ) async {
    final result = await _getTasks(
      const TaskPageParams(page: 1, limit: _limit),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TaskListStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (fetched) => emit(
        TaskState(
          status: TaskListStatus.success,
          tasks: fetched,
          hasReachedMax: fetched.length < _limit,
        ),
      ),
    );
  }
}
