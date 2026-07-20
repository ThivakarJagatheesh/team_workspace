import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/task_model.dart';

enum OutboxOpType { create, update }

/// A task change made while offline, queued to replay against the API once
/// connectivity returns.
class OutboxOperation {
  const OutboxOperation({
    required this.id,
    required this.type,
    required this.task,
    required this.enqueuedAt,
  });

  final String id;
  final OutboxOpType type;
  final TaskModel task;
  final int enqueuedAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'task': task.toJson(),
        'enqueuedAt': enqueuedAt,
      };

  factory OutboxOperation.fromMap(Map<String, dynamic> map) => OutboxOperation(
        id: map['id'] as String,
        type: OutboxOpType.values.firstWhere((t) => t.name == map['type']),
        task: TaskModel.fromJson(map['task'] as Map<String, dynamic>),
        enqueuedAt: map['enqueuedAt'] as int,
      );
}

/// Persists the offline change queue in its own Hive box.
abstract class TaskOutboxDataSource {
  Future<void> enqueue(OutboxOperation op);
  List<OutboxOperation> pending(); // oldest first
  Future<void> remove(String id);
  int get count;
}

class TaskOutboxDataSourceImpl implements TaskOutboxDataSource {
  TaskOutboxDataSourceImpl(this._box);

  final Box<dynamic> _box;

  @override
  Future<void> enqueue(OutboxOperation op) =>
      _box.put(op.id, jsonEncode(op.toMap()));

  @override
  List<OutboxOperation> pending() {
    final ops = _box.values
        .cast<String>()
        .map((raw) =>
            OutboxOperation.fromMap(jsonDecode(raw) as Map<String, dynamic>),)
        .toList()
      ..sort((a, b) => a.enqueuedAt.compareTo(b.enqueuedAt));
    return ops;
  }

  @override
  Future<void> remove(String id) => _box.delete(id);

  @override
  int get count => _box.length;
}
