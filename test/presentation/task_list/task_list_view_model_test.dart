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
    expect(fake.getTasksCount, 1);
  });
}
