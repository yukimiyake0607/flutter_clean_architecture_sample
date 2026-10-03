import 'package:flutter_clean_architecture_sample/data/services/activity_api_client.dart';
import 'package:flutter_clean_architecture_sample/domain/logic/activity_repository.dart';
import 'package:flutter_clean_architecture_sample/domain/model/activity.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';

/// [ActivityRepository] の実装です。
///
/// [ActivityApiClient] の [ActivityDto] を [Activity] に変換し、取得結果を [_cache] に覚えます。
/// Service の例外は [Result.error] にします。
/// 具象の [ActivityApiClientImpl] は知らず、ポートだけを受け取ります。
class ActivityRepositoryImpl implements ActivityRepository {
  ActivityRepositoryImpl({required ActivityApiClient activityApiClient})
    : _activityApiClient = activityApiClient;

  final ActivityApiClient _activityApiClient;

  /// 読み取りキャッシュです。未取得時はnullでOK
  /// 
  /// API（Serviceのこと）のリストとは別で[Activity]を覚えます。
  List<Activity>? _cache;

  @override
  Future<Result<Activity>> append({
    required String taskId,
    required ActivityKind kind,
  }) async {
    try {
      final activityDto = await _activityApiClient.append(
        taskId: taskId,
        type: kind.name,
      );
      final activity = activityDto.toDomain();
      if (_cache != null) {
        _cache!.add(activity);
      }
      return Result.ok(activity);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<int>> count() async {
    try {
      if (_cache != null) {
        return Result.ok(_cache!.length);
      }

      final activitiesDto = await _activityApiClient.fetchActivities();
      final activities = activitiesDto.map((a) => a.toDomain()).toList();
      _cache = activities;
      return Result.ok(activities.length);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
