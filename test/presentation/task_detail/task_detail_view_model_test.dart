import 'package:flutter_clean_architecture_sample/composition_root/providers.dart';
import 'package:flutter_clean_architecture_sample/presentation/task_detail/task_detail_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_activity_repository.dart';
import '../../fakes/fake_task_repository.dart';
import '../../fakes/recording_complete_task_use_case.dart';

void main() {
  test('詳細の完了はUsecaseを呼ぶ', () async {
    final fakeTaskRepository = FakeTaskRepository();
    final fakeActivityRepository = FakeActivityRepository();
    final fakeUsecase = RecordingCompleteTaskUseCase(
      taskRepository: fakeTaskRepository,
      activityRepository: fakeActivityRepository,
    );

    final container = ProviderContainer.test(
      overrides: [
        taskRepositoryProvider.overrideWithValue(fakeTaskRepository),
        activityRepositoryProvider.overrideWithValue(fakeActivityRepository),
        completeTaskUseCaseProvider.overrideWithValue(fakeUsecase),
      ],
    );
    container.listen(taskDetailViewModelProvider('1'), (_, _) {});
    await Future<void>.delayed(Duration.zero);

    await container.read(taskDetailViewModelProvider('1').notifier).toggle();

    final state = container.read(taskDetailViewModelProvider('1'));
    expect(fakeUsecase.callCount, 1);
    expect(fakeUsecase.calledTaskId, '1');
    expect(fakeTaskRepository.updateCount, 0);
    expect(fakeActivityRepository.appendCount, 0);
    expect(identical(state.task, fakeUsecase.task), isTrue);
    expect(state.activityCount, 1);
  });
}
