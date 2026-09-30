import 'package:flutter_clean_architecture_sample/domain/logic/activity_repository.dart';
import 'package:flutter_clean_architecture_sample/domain/model/activity.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';

class FakeActivityRepository implements ActivityRepository {
  int appendCount = 0;
  late ActivityKind activityKind;

  @override
  Future<Result<Activity>> append({
    required String taskId,
    required ActivityKind kind,
  }) async {
    appendCount++;
    activityKind = kind;
    final activity = Activity(
      id: '1',
      taskId: taskId,
      kind: kind,
      occurredAt: DateTime(2026, 1, 1),
    );
    return Result.ok(activity);
  }

  @override
  Future<Result<int>> count() async {
    return Result.ok(appendCount);
  }
}
