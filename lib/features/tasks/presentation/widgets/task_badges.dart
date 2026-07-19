import 'package:flutter/material.dart';

import '../../domain/entities/task_entity.dart';

/// Small colored badge for a task's priority.
class PriorityBadge extends StatelessWidget {
  const PriorityBadge(this.priority, {super.key});
  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors(context, priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority.label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  (Color, Color) _colors(BuildContext context, TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return (Colors.red.withValues(alpha: 0.12), Colors.red.shade700);
      case TaskPriority.medium:
        return (Colors.orange.withValues(alpha: 0.12), Colors.orange.shade800);
      case TaskPriority.low:
        return (Colors.green.withValues(alpha: 0.12), Colors.green.shade700);
    }
  }
}

/// Chip for a task's status.
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, color) = switch (status) {
      TaskStatus.completed => (Icons.check_circle, Colors.green.shade600),
      TaskStatus.inProgress => (Icons.timelapse, scheme.primary),
      TaskStatus.pending => (Icons.radio_button_unchecked, scheme.outline),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(status.label, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}
