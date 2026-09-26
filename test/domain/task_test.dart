import 'package:flutter_clean_architecture_sample/domain/model/task.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task_title.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';
import 'package:flutter_test/flutter_test.dart';

Task buildTask({required bool isCompleted}) {
  return Task(
    id: '1',
    title: (TaskTitle.parse('牛乳を買う') as Ok<TaskTitle>).value,
    note: 'memo',
    isCompleted: isCompleted,
    createdAt: DateTime.utc(2026, 1, 1),
  );
}

void main() {
  test('未完了のTaskでcomplete()を呼ぶとOk<Task>が返ってくる', () {
    final result = buildTask(isCompleted: false);
    final task = result.complete();

    expect(task, isA<Ok<Task>>());
    expect((task as Ok<Task>).value.isCompleted, true);
  });

  test('完了のTaskでcomplete()を呼ぶとError<TaskAlreadyCompletedException>が返ってくる', () {
    final result = buildTask(isCompleted: true);
    final task = result.complete();

    expect(task, isA<Error<Task>>());
    expect((task as Error<Task>).error, isA<TaskAlreadyCompletedException>());
  });
}
