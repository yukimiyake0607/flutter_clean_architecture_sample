import 'package:flutter_clean_architecture_sample/application/complete_task_use_case.dart';
import 'package:flutter_clean_architecture_sample/domain/model/activity.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_activity_repository.dart';
import '../fakes/fake_task_repository.dart';

void main() {
  test('完了に成功する', () async {
    final taskRepository = FakeTaskRepository();
    final activityRepository = FakeActivityRepository();
    final usecase = CompleteTaskUseCase(
      taskRepository: taskRepository,
      activityRepository: activityRepository,
    );
    final result = await usecase.call('1');

    expect(result, isA<Ok<CompleteTaskOutcome>>());
    final outcome = (result as Ok<CompleteTaskOutcome>).value;
    expect(outcome.task.isCompleted, isTrue);
    expect(outcome.activityCount, 1);
    expect(taskRepository.updateCount, 1);
    expect(activityRepository.appendCount, 1);
    expect(activityRepository.activityKind, ActivityKind.completed);
  });

  test('すでにタスクは完了している', () async {
    final taskRepository = FakeTaskRepository();
    final activityRepository = FakeActivityRepository();
    final usecase = CompleteTaskUseCase(
      taskRepository: taskRepository,
      activityRepository: activityRepository,
    );
    taskRepository.taskComplete = true;
    final result = await usecase.call('1');

    expect(result, isA<Error<CompleteTaskOutcome>>());
    final error = (result as Error<CompleteTaskOutcome>).error;
    expect(error, isA<TaskAlreadyCompletedException>());
    expect(taskRepository.updateCount, 0);
    expect(activityRepository.appendCount, 0);
    expect(activityRepository.activityKind, null);
  });

  test('更新に失敗する', () async {
    final taskRepository = FakeTaskRepository();
    final activityRepository = FakeActivityRepository();
    final usecase = CompleteTaskUseCase(
      taskRepository: taskRepository,
      activityRepository: activityRepository,
    );
    taskRepository.shouldFail = true;
    final result = await usecase.call('1');

    expect(result, isA<Error<CompleteTaskOutcome>>());
    expect(taskRepository.updateCount, 1);
    expect(activityRepository.appendCount, 0);
    expect(activityRepository.activityKind, null);
  });
}
