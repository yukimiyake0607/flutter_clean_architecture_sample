import 'package:flutter_clean_architecture_sample/domain/model/activity.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';

abstract class ActivityRepository {
  Future<Result<Activity>> append({
    required String taskId,
    required ActivityKind kind,
  });
  Future<Result<int>> count();
}
