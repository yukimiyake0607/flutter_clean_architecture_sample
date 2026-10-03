import 'package:flutter_clean_architecture_sample/data/repositories/activity_repository_impl.dart';
import 'package:flutter_clean_architecture_sample/domain/model/activity.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_activity_api_client.dart';

void main() {
  test('履歴追加に成功するとcountが1になる', () async {
    final fakeApiClient = FakeActivityApiClient();
    final repository = ActivityRepositoryImpl(activityApiClient: fakeApiClient);
    final initialCountResult = await repository.count();

    expect(initialCountResult, isA<Ok<int>>());
    final initialCount = (initialCountResult as Ok<int>).value;
    expect(initialCount, 0);

    final appendResult = await repository.append(
      taskId: '1',
      kind: ActivityKind.completed,
    );
    expect(fakeApiClient.lastAppendedType, 'completed');
    expect(appendResult, isA<Ok<Activity>>());
    final activity = (appendResult as Ok<Activity>).value.kind;
    expect(activity, ActivityKind.completed);
    final secondCountResult = await repository.count();
    final secondResult = (secondCountResult as Ok<int>).value;
    expect(secondResult, 1);
  });
}
