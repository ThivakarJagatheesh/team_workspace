import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/create_task.dart';

part 'create_task_state.dart';

/// Handles the create-task form submission. Kept separate from [TaskBloc]:
/// this owns the *form* lifecycle; the dashboard bloc owns the *list*. On
/// success the page pops with the created task and the dashboard inserts it.
class CreateTaskCubit extends Cubit<CreateTaskState> {
  CreateTaskCubit(this._createTask) : super(const CreateTaskState());

  final CreateTask _createTask;

  Future<void> submit({
    required String title,
    required String description,
    required TaskPriority priority,
    required DateTime dueDate,
  }) async {
    emit(state.copyWith(status: FormStatus.submitting));
    final result = await _createTask(
      CreateTaskParams(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(status: FormStatus.failure, message: failure.message),
      ),
      (task) => emit(
        state.copyWith(status: FormStatus.success, createdTask: task),
      ),
    );
  }
}
