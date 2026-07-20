import 'package:equatable/equatable.dart';

/// Task priority. `value` is the stable string used for API/cache serialization.
enum TaskPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High');

  const TaskPriority(this.value, this.label);
  final String value;
  final String label;

  static TaskPriority fromValue(String? v) => TaskPriority.values.firstWhere(
        (p) => p.value == v,
        orElse: () => TaskPriority.medium,
      );
}

/// Task lifecycle status.
enum TaskStatus {
  pending('pending', 'Pending'),
  inProgress('in_progress', 'In Progress'),
  completed('completed', 'Completed');

  const TaskStatus(this.value, this.label);
  final String value;
  final String label;

  static TaskStatus fromValue(String? v) => TaskStatus.values.firstWhere(
        (s) => s.value == v,
        orElse: () => TaskStatus.pending,
      );

  bool get isCompleted => this == TaskStatus.completed;
}

/// A project task — the core domain entity.
class TaskEntity extends Equatable {
  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.status,
    this.assignedTo,
  });

  final int id;
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime dueDate;
  final TaskStatus status;
  final String? assignedTo;

  TaskEntity copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? dueDate,
    TaskStatus? status,
    String? assignedTo,
  }) {
    return TaskEntity(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, description, priority, dueDate, status, assignedTo];
}
