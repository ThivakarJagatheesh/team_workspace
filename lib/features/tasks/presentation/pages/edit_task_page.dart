import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/task_entity.dart';
import '../cubit/edit_task_cubit.dart';
import '../widgets/task_form.dart';

/// Edit-task screen. Pops with the updated [TaskEntity] on success so the
/// caller can replace it in the list.
class EditTaskPage extends StatelessWidget {
  const EditTaskPage({super.key, required this.task});

  final TaskEntity task;

  static Route<TaskEntity?> route(TaskEntity task) {
    return MaterialPageRoute<TaskEntity?>(
      builder: (_) => BlocProvider(
        create: (_) => sl<EditTaskCubit>(),
        child: EditTaskPage(task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit task')),
      body: BlocConsumer<EditTaskCubit, EditTaskState>(
        listener: (context, state) {
          if (state.status == EditStatus.success) {
            Navigator.of(context).pop(state.updatedTask);
          } else if (state.status == EditStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.message ?? 'Could not save')),
              );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: TaskForm(
              initial: task,
              showStatus: true,
              submitting: state.isSubmitting,
              submitLabel: 'Save changes',
              onSubmit: (data) => context.read<EditTaskCubit>().submit(
                    original: task,
                    title: data.title,
                    description: data.description,
                    priority: data.priority,
                    dueDate: data.dueDate,
                    status: data.status,
                  ),
            ),
          );
        },
      ),
    );
  }
}
