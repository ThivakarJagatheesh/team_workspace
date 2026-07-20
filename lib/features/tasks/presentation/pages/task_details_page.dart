import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_navigator.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../widgets/task_badges.dart';

/// Full task view. Reads the live task from [TaskBloc] by id, so a status
/// toggle here (or on the list) is reflected immediately and consistently.
class TaskDetailsPage extends StatelessWidget {
  const TaskDetailsPage({super.key, required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task details'),
        actions: [
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              final matches = state.tasks.where((t) => t.id == taskId);
              if (matches.isEmpty) return const SizedBox.shrink();
              final task = matches.first;
              return IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  final bloc = context.read<TaskBloc>();
                  final updated = await AppNavigator.push<TaskEntity?>(
                    context,
                    '/tasks/${task.id}/edit',
                    extra: task,
                  );
                  if (updated != null) bloc.add(TaskUpdated(updated));
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          final matches = state.tasks.where((t) => t.id == taskId);
          if (matches.isEmpty) {
            return const Center(child: Text('Task not found'));
          }
          return _Details(task: matches.first);
        },
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.task});
  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final completed = task.status.isCompleted;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(task.title, style: text.headlineSmall),
        const SizedBox(height: 12),
        Row(
          children: [
            PriorityBadge(task.priority),
            const SizedBox(width: 12),
            StatusChip(task.status),
          ],
        ),
        const Divider(height: 32),
        _Field(
          icon: Icons.notes_outlined,
          label: 'Description',
          value: task.description,
        ),
        _Field(
          icon: Icons.event_outlined,
          label: 'Due date',
          value: Formatters.due(task.dueDate),
        ),
        _Field(
          icon: Icons.person_outline,
          label: 'Assigned to',
          value: task.assignedTo ?? 'Unassigned',
        ),
        _Field(
          icon: Icons.flag_outlined,
          label: 'Priority',
          value: task.priority.label,
        ),
        _Field(
          icon: Icons.timelapse,
          label: 'Status',
          value: task.status.label,
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () =>
              context.read<TaskBloc>().add(TaskStatusToggled(task)),
          icon: Icon(completed ? Icons.refresh : Icons.check),
          label: Text(completed ? 'Reopen task' : 'Mark as completed'),
          style: completed
              ? FilledButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onSecondaryContainer,
                )
              : null,
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: text.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: text.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
