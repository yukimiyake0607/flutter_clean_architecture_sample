import 'package:flutter_clean_architecture_sample/application/delete_task_use_case.dart';
import 'package:flutter_clean_architecture_sample/domain/model/activity.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_activity_repository.dart';
import '../fakes/fake_task_repository.dart';

void main() {
  test('削除に成功する', () async {
    final taskRepository = FakeTaskRepository();
    final activityRepository = FakeActivityRepository();
    final usecase = DeleteTaskUseCase(
      taskRepository: taskRepository,
      activityRepository: activityRepository,
    );
    final result = await usecase.call('1');

    expect(result, isA<Ok<int>>());
    final count = (result as Ok<int>).value;
    expect(count, 1);
    expect(taskRepository.deleteCount, 1);
    expect(activityRepository.appendCount, 1);
    expect(activityRepository.activityKind, ActivityKind.deleted);
  });
}
