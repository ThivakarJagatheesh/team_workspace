part of 'edit_task_cubit.dart';

enum EditStatus { idle, submitting, success, failure }

class EditTaskState extends Equatable {
  const EditTaskState({
    this.status = EditStatus.idle,
    this.updatedTask,
    this.message,
  });

  final EditStatus status;
  final TaskEntity? updatedTask;
  final String? message;

  bool get isSubmitting => status == EditStatus.submitting;

  EditTaskState copyWith({
    EditStatus? status,
    TaskEntity? updatedTask,
    String? message,
  }) {
    return EditTaskState(
      status: status ?? this.status,
      updatedTask: updatedTask ?? this.updatedTask,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, updatedTask, message];
}
