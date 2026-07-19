import 'package:team_workspace/features/auth/domain/entities/user_entity.dart';
import 'package:team_workspace/features/tasks/data/models/task_model.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';

const tUser = UserEntity(id: 'u1', email: 'test@example.com');

TaskEntity tTask({
  int id = 1,
  TaskStatus status = TaskStatus.pending,
  TaskPriority priority = TaskPriority.medium,
  String title = 'Test task',
}) =>
    TaskEntity(
      id: id,
      title: title,
      description: 'A test task',
      priority: priority,
      dueDate: DateTime(2025, 7, 10),
      status: status,
      assignedTo: 'Tester',
    );

TaskModel tTaskModel({int id = 1}) => TaskModel.fromEntity(tTask(id: id));

List<TaskModel> tTaskModels(int n) =>
    List.generate(n, (i) => tTaskModel(id: i + 1));
