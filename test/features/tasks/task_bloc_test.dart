import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:team_workspace/core/error/failures.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';
import 'package:team_workspace/features/tasks/domain/usecases/get_tasks.dart';
import 'package:team_workspace/features/tasks/domain/usecases/update_task.dart';
import 'package:team_workspace/features/tasks/presentation/bloc/task_bloc.dart';

import '../../helpers/fixtures.dart';

class MockGetTasks extends Mock implements GetTasks {}

class MockUpdateTask extends Mock implements UpdateTask {}

void main() {
  late MockGetTasks getTasks;
  late MockUpdateTask updateTask;

  setUpAll(() {
    registerFallbackValue(const TaskPageParams(page: 1, limit: 15));
    registerFallbackValue(tTask());
  });

  setUp(() {
    getTasks = MockGetTasks();
    updateTask = MockUpdateTask();
  });

  TaskBloc build() => TaskBloc(getTasks: getTasks, updateTask: updateTask);

  group('TasksFetched', () {
    blocTest<TaskBloc, TaskState>(
      'emits [loading, success] with the fetched page',
      build: () {
        when(() => getTasks(any())).thenAnswer(
          (_) async => Right<Failure, List<TaskEntity>>(
            List.generate(5, (i) => tTask(id: i + 1)),
          ),
        );
        return build();
      },
      act: (bloc) => bloc.add(const TasksFetched()),
      expect: () => [
        isA<TaskState>()
            .having((s) => s.status, 'status', TaskListStatus.loading),
        isA<TaskState>()
            .having((s) => s.status, 'status', TaskListStatus.success)
            .having((s) => s.tasks.length, 'count', 5)
            .having((s) => s.hasReachedMax, 'hasReachedMax', true),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'emits failure when the use case returns a Failure',
      build: () {
        when(() => getTasks(any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return build();
      },
      act: (bloc) => bloc.add(const TasksFetched()),
      expect: () => [
        isA<TaskState>()
            .having((s) => s.status, 'status', TaskListStatus.loading),
        isA<TaskState>()
            .having((s) => s.status, 'status', TaskListStatus.failure),
      ],
    );
  });

  group('TaskStatusToggled', () {
    final pending = tTask(id: 7, status: TaskStatus.pending);

    blocTest<TaskBloc, TaskState>(
      'optimistically flips a task to completed',
      build: () {
        when(() => updateTask(any()))
            .thenAnswer((_) async => Right<Failure, TaskEntity>(pending));
        return build();
      },
      seed: () => TaskState(status: TaskListStatus.success, tasks: [pending]),
      act: (bloc) => bloc.add(TaskStatusToggled(pending)),
      expect: () => [
        isA<TaskState>().having(
          (s) => s.tasks.first.status,
          'status',
          TaskStatus.completed,
        ),
      ],
    );
  });

  group('search & filter', () {
    final tasks = [
      tTask(id: 1, title: 'Design login', priority: TaskPriority.high),
      tTask(id: 2, title: 'Write tests', priority: TaskPriority.low),
    ];

    blocTest<TaskBloc, TaskState>(
      'filteredTasks respects the title query',
      build: build,
      seed: () => TaskState(status: TaskListStatus.success, tasks: tasks),
      act: (bloc) => bloc.add(const TaskSearchChanged('login')),
      verify: (bloc) {
        expect(bloc.state.filteredTasks.length, 1);
        expect(bloc.state.filteredTasks.first.id, 1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'filteredTasks respects the priority filter',
      build: build,
      seed: () => TaskState(status: TaskListStatus.success, tasks: tasks),
      act: (bloc) =>
          bloc.add(const TaskFilterChanged(priority: TaskPriority.low)),
      verify: (bloc) {
        expect(bloc.state.filteredTasks.length, 1);
        expect(bloc.state.filteredTasks.first.id, 2);
      },
    );
  });
}
