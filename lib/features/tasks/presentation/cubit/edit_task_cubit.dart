import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/update_task.dart';

part 'edit_task_state.dart';

/// Handles the edit-task form submission (Stage 5). Owns the form lifecycle;
/// the dashboard bloc replaces the task in the list on success.
class EditTaskCubit extends Cubit<EditTaskState> {
  EditTaskCubit(this._updateTask) : super(const EditTaskState());

  final UpdateTask _updateTask;

  Future<void> submit({
    required TaskEntity original,
    required String title,
    required String description,
    required TaskPriority priority,
    required DateTime dueDate,
    required TaskStatus status,
  }) async {
    emit(state.copyWith(status: EditStatus.submitting));

    final updated = original.copyWith(
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      status: status,
    );

    final result = await _updateTask(updated);
    result.fold(
      (failure) => emit(
        state.copyWith(status: EditStatus.failure, message: failure.message),
      ),
      (task) => emit(
        state.copyWith(status: EditStatus.success, updatedTask: task),
      ),
    );
  }
}
