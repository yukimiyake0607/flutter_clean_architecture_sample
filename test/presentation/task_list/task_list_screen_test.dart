import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture_sample/composition_root/providers.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task.dart';
import 'package:flutter_clean_architecture_sample/presentation/task_list/task_list_screen.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_task_repository.dart';

void main() {
  testWidgets('タスクの取得に成功する', (WidgetTester tester) async {
    final fake = FakeTaskRepository();
    final result = await fake.getTask('1');
    final task = (result as Ok<Task>).value;
    fake.tasks = [task];

    // テスト対象のウィジェットをビルドする
    await tester.pumpWidget(
      ProviderScope(
        overrides: [taskRepositoryProvider.overrideWithValue(fake)],
        child: MaterialApp(home: TaskListScreen()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('仕事'), findsOneWidget);
  });
}
