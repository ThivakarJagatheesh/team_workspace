import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/task_model.dart';

/// Caches the last loaded task list in Hive so the dashboard renders offline.
/// Stored as a single JSON string to avoid Hive type-adapter codegen.
abstract class TaskLocalDataSource {
  Future<void> cacheTasks(List<TaskModel> tasks);
  List<TaskModel> getCachedTasks();

  /// Insert or replace a single task in the cached list (by id).
  Future<void> upsertTask(TaskModel task);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  TaskLocalDataSourceImpl(this._box);

  final Box<dynamic> _box;
  static const String _key = 'cached_tasks';

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    try {
      final raw = jsonEncode(tasks.map((t) => t.toJson()).toList());
      await _box.put(_key, raw);
    } catch (_) {
      throw CacheException('Could not cache tasks');
    }
  }

  @override
  List<TaskModel> getCachedTasks() {
    final raw = _box.get(_key) as String?;
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .cast<Map<String, dynamic>>()
          .map(TaskModel.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> upsertTask(TaskModel task) async {
    final tasks = getCachedTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      tasks[index] = task;
    } else {
      tasks.insert(0, task);
    }
    await cacheTasks(tasks);
  }
}
