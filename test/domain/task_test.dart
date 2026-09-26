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
  test('未完了なら新しい Task が完了になり、元は未完了のまま', () {
    final task = buildTask(isCompleted: false);
    final result = task.complete();

    expect(result, isA<Ok<Task>>());
    final completed = (result as Ok<Task>).value;
    expect(completed.isCompleted, isTrue);
    expect(task.isCompleted, isFalse);
    expect(identical(task, completed), isFalse);
  });

  test('完了のTaskでcomplete()を呼ぶとError<TaskAlreadyCompletedException>が返ってくる', () {
    final result = buildTask(isCompleted: true);
    final task = result.complete();

    expect(task, isA<Error<Task>>());
    expect((task as Error<Task>).error, isA<TaskAlreadyCompletedException>());
  });
}
