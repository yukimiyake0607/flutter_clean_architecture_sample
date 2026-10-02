import 'package:flutter_clean_architecture_sample/data/repositories/task_repository_impl.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_task_api_client.dart';

void main() {
  test('タスクを取得してTaskに変換できる', () async {
    final fakeTaskApiClient = FakeTaskApiClient();
    final repository = TaskRepositoryImpl(taskApiClient: fakeTaskApiClient);
    final tasks = await repository.getTasks();
    final task = (tasks as Ok<List<Task>>).value.first;

    expect(task.note, 'MTG');
    expect(task.isCompleted, true);
    expect(fakeTaskApiClient.fetchCount, 1);
  });

  test('タスクの更新ができる', () async {
    final fakeTaskApiClient = FakeTaskApiClient();
    final repository = TaskRepositoryImpl(taskApiClient: fakeTaskApiClient);
    final tasks = await repository.getTasks();
    final task = (tasks as Ok<List<Task>>).value.first;
    final updateTask = Task(
      id: task.id,
      title: task.title,
      note: '変更後',
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
    );
    await repository.updateTask(updateTask);
    final updateTasks = await repository.getTasks();
    final resultTask = (updateTasks as Ok<List<Task>>).value.first;

    expect(resultTask.note, '変更後');
    expect(fakeTaskApiClient.fetchCount, 1);
  });

  test('例外が投げられたらResult.errorに変換できる', () async {
    final fakeTaskApiClient = FakeTaskApiClient();
    final repository = TaskRepositoryImpl(taskApiClient: fakeTaskApiClient);
    fakeTaskApiClient.shouldFail = true;
    final result = await repository.getTasks();

    expect(result, isA<Error<List<Task>>>());
  });
}
