import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/task_entity.dart';
import '../cubit/create_task_cubit.dart';
import '../widgets/task_form.dart';

/// Create-task screen. Pops with the created [TaskEntity] on success so the
/// dashboard can insert it without a reload.
class CreateTaskPage extends StatelessWidget {
  const CreateTaskPage({super.key});

  static Route<TaskEntity?> route() {
    return MaterialPageRoute<TaskEntity?>(
      builder: (_) => BlocProvider(
        create: (_) => sl<CreateTaskCubit>(),
        child: const CreateTaskPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New task'), leading: const CloseButton()),
      body: BlocConsumer<CreateTaskCubit, CreateTaskState>(
        listener: (context, state) {
          if (state.status == FormStatus.success) {
            Navigator.of(context).pop(state.createdTask);
          } else if (state.status == FormStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message ?? 'Could not create task'),
                ),
              );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: TaskForm(
              showStatus: false,
              submitting: state.isSubmitting,
              submitLabel: 'Create task',
              onSubmit: (data) => context.read<CreateTaskCubit>().submit(
                    title: data.title,
                    description: data.description,
                    priority: data.priority,
                    dueDate: data.dueDate,
                  ),
            ),
          );
        },
      ),
    );
  }
}
