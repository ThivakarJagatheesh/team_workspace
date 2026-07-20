import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:team_workspace/features/tasks/domain/entities/task_entity.dart';
import 'package:team_workspace/features/tasks/presentation/widgets/task_card.dart';

import '../../helpers/fixtures.dart';

void main() {
  Future<void> pumpCard(WidgetTester tester, TaskEntity task) {
    return tester.pumpWidget(
      MaterialApp(home: Scaffold(body: TaskCard(task: task))),
    );
  }

  testWidgets('renders title, priority and status', (tester) async {
    await pumpCard(
      tester,
      tTask(title: 'Ship release', priority: TaskPriority.high),
    );

    expect(find.text('Ship release'), findsOneWidget);
    expect(find.text('High'), findsOneWidget); // priority badge
    expect(find.text('Pending'), findsOneWidget); // status chip
  });

  testWidgets('completed task shows the Completed status', (tester) async {
    await pumpCard(tester, tTask(status: TaskStatus.completed));
    expect(find.text('Completed'), findsOneWidget);
  });
}
