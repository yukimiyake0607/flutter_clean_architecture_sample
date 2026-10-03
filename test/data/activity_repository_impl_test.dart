import 'package:flutter_clean_architecture_sample/data/repositories/activity_repository_impl.dart';
import 'package:flutter_clean_architecture_sample/domain/model/activity.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_activity_api_client.dart';

void main() {
  test('履歴を追加すると type は completed になり、件数は 0 から 1 になる', () async {
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
    final activityKind = (appendResult as Ok<Activity>).value.kind;
    expect(activityKind, ActivityKind.completed);
    final secondCountResult = await repository.count();
    final countAfterAppend = (secondCountResult as Ok<int>).value;
    expect(countAfterAppend, 1);
  });

  test('2回目の count は API を呼ばずキャッシュの件数を返す', () async {
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
    expect(fakeApiClient.fetchCount, 1);
    expect(appendResult, isA<Ok<Activity>>());
    final secondCountResult = await repository.count();
    final secondCount = (secondCountResult as Ok<int>).value;
    expect(secondCount, 1);
    expect(fakeApiClient.fetchCount, 1);
  });

  test('例外が投げられたらResult.errorに変換される', () async {
    final fakeApiClient = FakeActivityApiClient();
    fakeApiClient.shouldFail = true;
    final repository = ActivityRepositoryImpl(activityApiClient: fakeApiClient);

    final countResult = await repository.count();
    expect(countResult, isA<Error<int>>());
    expect(fakeApiClient.fetchCount, 0);
  });
}
