part of 'create_task_cubit.dart';

enum FormStatus { idle, submitting, success, failure }

class CreateTaskState extends Equatable {
  const CreateTaskState({
    this.status = FormStatus.idle,
    this.createdTask,
    this.message,
  });

  final FormStatus status;
  final TaskEntity? createdTask;
  final String? message;

  bool get isSubmitting => status == FormStatus.submitting;

  CreateTaskState copyWith({
    FormStatus? status,
    TaskEntity? createdTask,
    String? message,
  }) {
    return CreateTaskState(
      status: status ?? this.status,
      createdTask: createdTask ?? this.createdTask,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, createdTask, message];
}
