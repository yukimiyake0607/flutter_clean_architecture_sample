import 'package:flutter_clean_architecture_sample/composition_root/providers.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task_title.dart';
import 'package:flutter_clean_architecture_sample/presentation/task_list/task_list_view_model.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_task_repository.dart';

void main() {
  test('getTasksの成功結果をstate.tasksに置く', () async {
    final fake = FakeTaskRepository();
    final task = Task(
      id: '1',
      title: (TaskTitle.parse('牛乳を買う') as Ok<TaskTitle>).value,
      note: 'memo',
      isCompleted: false,
      createdAt: DateTime.utc(2026, 1, 1),
    );
    fake.tasks = [task];

    final container = ProviderContainer.test(
      overrides: [taskRepositoryProvider.overrideWithValue(fake)],
    );
    container.listen(taskListViewModelProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);

    expect(container.read(taskListViewModelProvider).load.completed, isTrue);
    final state = container.read(taskListViewModelProvider);
    expect(identical(state.tasks, fake.tasks), isTrue);
    expect(fake.getTasksCount, 1);
  });

  test('getTasksが失敗してもtasksは空のまま', () async {
    final fake = FakeTaskRepository();
    final task = Task(
      id: '1',
      title: (TaskTitle.parse('牛乳を買う') as Ok<TaskTitle>).value,
      note: 'memo',
      isCompleted: false,
      createdAt: DateTime.utc(2026, 1, 1),
    );
    fake.tasks = [task];
    fake.failGetTasks = true;

    final container = ProviderContainer.test(
      overrides: [taskRepositoryProvider.overrideWithValue(fake)],
    );
    container.listen(taskListViewModelProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);

    final state = container.read(taskListViewModelProvider);
    expect(state.load.hasError, isTrue);
    expect(state.tasks, isEmpty);
    expect(fake.getTasksCount, 1);
  });

  test('フィルタでは追加のRepositoryの呼び出しがない', () async {
    final fake = FakeTaskRepository();
    final task1 = Task(
      id: '1',
      title: (TaskTitle.parse('牛乳を買う') as Ok<TaskTitle>).value,
      note: 'memo',
      isCompleted: false,
      createdAt: DateTime.utc(2026, 1, 1),
    );
    final task2 = Task(
      id: '1',
      title: (TaskTitle.parse('仕事') as Ok<TaskTitle>).value,
      note: 'memo',
      isCompleted: true,
      createdAt: DateTime.utc(2026, 1, 1),
    );
    fake.tasks = [task1, task2];

    final container = ProviderContainer.test(
      overrides: [taskRepositoryProvider.overrideWithValue(fake)],
    );
    container.listen(taskListViewModelProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);

    expect(fake.getTasksCount, 1);
    final state = container.read(taskListViewModelProvider);
    expect(identical(state.tasks, fake.tasks), isTrue);
    expect(state.filteredTasks.length, 2);

    container
        .read(taskListViewModelProvider.notifier)
        .setFilter(TaskFilter.active);
    final filtered = container.read(taskListViewModelProvider);
    expect(fake.getTasksCount, 1);
    expect(identical(filtered.tasks, fake.tasks), isTrue);
    expect(filtered.filteredTasks.length, 1);
  });
}
