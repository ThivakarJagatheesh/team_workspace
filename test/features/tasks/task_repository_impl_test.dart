import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:team_workspace/core/error/failures.dart';
import 'package:team_workspace/core/network/network_info.dart';
import 'package:team_workspace/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:team_workspace/features/tasks/data/datasources/task_outbox_data_source.dart';
import 'package:team_workspace/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:team_workspace/features/tasks/data/models/task_model.dart';
import 'package:team_workspace/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';

import '../../helpers/fixtures.dart';

class MockRemote extends Mock implements TaskRemoteDataSource {}

class MockLocal extends Mock implements TaskLocalDataSource {}

class MockOutbox extends Mock implements TaskOutboxDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockRemote remote;
  late MockLocal local;
  late MockOutbox outbox;
  late MockNetworkInfo networkInfo;
  late TaskRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(<TaskModel>[]);
    registerFallbackValue(tTaskModel());
    registerFallbackValue(
      OutboxOperation(
        id: 'x',
        type: OutboxOpType.create,
        task: tTaskModel(),
        enqueuedAt: 0,
      ),
    );
  });

  setUp(() {
    remote = MockRemote();
    local = MockLocal();
    outbox = MockOutbox();
    networkInfo = MockNetworkInfo();
    repo = TaskRepositoryImpl(
      remote: remote,
      local: local,
      outbox: outbox,
      networkInfo: networkInfo,
    );
  });

  group('getTasks', () {
    test('fetches from remote and caches page 1 when online', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remote.getTasks(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),).thenAnswer((_) async => tTaskModels(3));
      when(() => local.cacheTasks(any())).thenAnswer((_) async {});

      final result = await repo.getTasks(page: 1, limit: 15);

      expect(result.isRight(), true);
      expect(result.getOrElse(() => <TaskEntity>[]).length, 3);
      verify(() => local.cacheTasks(any())).called(1);
    });

    test('returns cached tasks for page 1 when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => local.getCachedTasks()).thenReturn(tTaskModels(2));

      final result = await repo.getTasks(page: 1, limit: 15);

      expect(result.isRight(), true);
      verifyNever(() => remote.getTasks(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),);
    });

    test('returns NetworkFailure when offline with no cache (page 2)',
        () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repo.getTasks(page: 2, limit: 15);

      expect(result, const Left(NetworkFailure()));
    });
  });

  group('createTask offline', () {
    test('caches and enqueues an outbox op when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => local.getCachedTasks()).thenReturn(const []);
      when(() => local.upsertTask(any())).thenAnswer((_) async {});
      when(() => outbox.enqueue(any())).thenAnswer((_) async {});

      final result = await repo.createTask(
        title: 'Offline task',
        description: 'made while offline',
        priority: tTask().priority,
        dueDate: DateTime(2025, 7, 20),
      );

      expect(result.isRight(), true);
      verify(() => local.upsertTask(any())).called(1);
      verify(() => outbox.enqueue(any())).called(1);
      verifyNever(() => remote.createTask(any()));
    });
  });
}
