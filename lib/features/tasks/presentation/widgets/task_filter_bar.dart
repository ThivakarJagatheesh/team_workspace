import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';

/// Search field + status/priority filters. They combine: the list shows tasks
/// matching the title query AND the selected status AND the selected priority.
class TaskFilterBar extends StatelessWidget {
  const TaskFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TaskBloc>();
    return BlocBuilder<TaskBloc, TaskState>(
      buildWhen: (p, c) =>
          p.query != c.query ||
          p.statusFilter != c.statusFilter ||
          p.priorityFilter != c.priorityFilter,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by title…',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  suffixIcon: state.query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () =>
                              bloc.add(const TaskSearchChanged('')),
                        ),
                ),
                onChanged: (v) => bloc.add(TaskSearchChanged(v)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _StatusDropdown(
                      value: state.statusFilter,
                      onChanged: (s) => bloc.add(
                        TaskFilterChanged(
                          status: s,
                          priority: state.priorityFilter,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PriorityDropdown(
                      value: state.priorityFilter,
                      onChanged: (p) => bloc.add(
                        TaskFilterChanged(
                          status: state.statusFilter,
                          priority: p,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.value, required this.onChanged});
  final TaskStatus? value;
  final ValueChanged<TaskStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<TaskStatus?>(
      value: value,
      isDense: true,
      decoration: const InputDecoration(labelText: 'Status', isDense: true),
      items: [
        const DropdownMenuItem(value: null, child: Text('All statuses')),
        ...TaskStatus.values.map(
          (s) => DropdownMenuItem(value: s, child: Text(s.label)),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _PriorityDropdown extends StatelessWidget {
  const _PriorityDropdown({required this.value, required this.onChanged});
  final TaskPriority? value;
  final ValueChanged<TaskPriority?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<TaskPriority?>(
      value: value,
      isDense: true,
      decoration: const InputDecoration(labelText: 'Priority', isDense: true),
      items: [
        const DropdownMenuItem(value: null, child: Text('All priorities')),
        ...TaskPriority.values.map(
          (p) => DropdownMenuItem(value: p, child: Text(p.label)),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
