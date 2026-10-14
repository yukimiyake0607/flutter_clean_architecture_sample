import 'package:flutter_clean_architecture_sample/composition_root/providers.dart';
import 'package:flutter_clean_architecture_sample/presentation/add_task/add_task_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_task_repository.dart';

void main() {
  test('タイトルを空白にするとparseが失敗する', () async {
    final fake = FakeTaskRepository();
    final container = ProviderContainer.test(
      overrides: [taskRepositoryProvider.overrideWithValue(fake)],
    );
    container.listen(addTaskViewModelProvider, (_, _) {});

    await container.read(addTaskViewModelProvider.notifier).submit(title: ' ');

    final state = container.read(addTaskViewModelProvider).submit;
    expect(state.hasError, isTrue);
    expect(fake.createCount, 0);
  });
}
