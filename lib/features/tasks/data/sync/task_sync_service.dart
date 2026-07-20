import 'dart:async';

import '../../../../core/network/network_info.dart';
import '../datasources/task_outbox_data_source.dart';
import '../datasources/task_remote_data_source.dart';

/// Replays queued offline changes to the API when connectivity returns.
///
/// - Subscribes to connectivity; on going online it drains the outbox.
/// - Each operation is removed only after a successful replay, so a failure
///   simply leaves it queued for the next attempt (at-least-once delivery).
class TaskSyncService {
  TaskSyncService({
    required NetworkInfo networkInfo,
    required TaskOutboxDataSource outbox,
    required TaskRemoteDataSource remote,
  })  : _networkInfo = networkInfo,
        _outbox = outbox,
        _remote = remote;

  final NetworkInfo _networkInfo;
  final TaskOutboxDataSource _outbox;
  final TaskRemoteDataSource _remote;

  StreamSubscription<bool>? _sub;
  bool _syncing = false;

  /// Begin watching connectivity. Also attempts an initial drain.
  void start() {
    _sub ??= _networkInfo.onConnectivityChanged.listen((online) {
      if (online) syncNow();
    });
    syncNow();
  }

  Future<void> syncNow() async {
    if (_syncing) return;
    if (!await _networkInfo.isConnected) return;
    _syncing = true;
    try {
      for (final op in _outbox.pending()) {
        try {
          switch (op.type) {
            case OutboxOpType.create:
              await _remote.createTask(op.task);
            case OutboxOpType.update:
              await _remote.updateTask(op.task);
          }
          await _outbox.remove(op.id); // only on success
        } catch (_) {
          // Leave this op queued; retry on the next connectivity event.
        }
      }
    } finally {
      _syncing = false;
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}
