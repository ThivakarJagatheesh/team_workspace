import '../../domain/entities/task_entity.dart';

/// Data model for a task. Bridges JSON (API + cache) and the domain entity.
///
/// The default demo API (jsonplaceholder `/todos`) only returns
/// `{userId, id, title, completed}`, so missing fields (description, priority,
/// due date, status, assignee) are **synthesized deterministically** from the
/// id — stable across reloads. When the JSON already carries the full fields
/// (our own cache/asset or a richer API), they are read as-is.
class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.priority,
    required super.dueDate,
    required super.status,
    super.assignedTo,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as num).toInt();
    final title = (json['title'] as String?)?.trim() ?? 'Untitled task';
    final completed = json['completed'] as bool? ?? false;

    return TaskModel(
      id: id,
      title: title,
      description: json['description'] as String? ?? _synthDescription(title),
      priority: json.containsKey('priority')
          ? TaskPriority.fromValue(json['priority'] as String?)
          : _synthPriority(id),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : _synthDueDate(id),
      status: json.containsKey('status')
          ? TaskStatus.fromValue(json['status'] as String?)
          : _synthStatus(id, completed),
      assignedTo: json['assignedTo'] as String? ?? _synthAssignee(id),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'priority': priority.value,
        'dueDate': dueDate.toIso8601String(),
        'status': status.value,
        'assignedTo': assignedTo,
      };

  factory TaskModel.fromEntity(TaskEntity t) => TaskModel(
        id: t.id,
        title: t.title,
        description: t.description,
        priority: t.priority,
        dueDate: t.dueDate,
        status: t.status,
        assignedTo: t.assignedTo,
      );

  // ── deterministic synthesis for the minimal demo API ──────
  static const List<String> _assignees = [
    'Aarav Mehta',
    'Diya Sharma',
    'Kabir Rao',
    'Ananya Iyer',
    'Vivaan Nair',
  ];

  static String _synthDescription(String title) =>
      'Follow up and complete: "$title". Coordinate with the team and update '
      'the status once done.';

  static TaskPriority _synthPriority(int id) =>
      TaskPriority.values[id % TaskPriority.values.length];

  static DateTime _synthDueDate(int id) {
    // Spread due dates deterministically around a fixed anchor.
    final anchor = DateTime(2025, 7, 1);
    return anchor.add(Duration(days: id % 30));
  }

  static TaskStatus _synthStatus(int id, bool completed) {
    if (completed) return TaskStatus.completed;
    return id.isEven ? TaskStatus.pending : TaskStatus.inProgress;
  }

  static String _synthAssignee(int id) => _assignees[id % _assignees.length];
}
