import 'package:flutter_clean_architecture_sample/data/model/activity_dto.dart';

/// 履歴 API の約束です。
///
/// 戻り値は [ActivityDto] です。失敗は例外で知らせ、[Result] にはしません。
/// [ActivityRepositoryImpl] はこの型だけを受け取り、メモリ実装の名前は知りません。
abstract class ActivityApiClient {
  Future<List<ActivityDto>> fetchActivities();
  Future<ActivityDto> append({required String taskId, required String type});
}

/// [ActivityApiClient] のメモリ実装です。
///
/// 約 300ms 待ってから処理します。
/// [_activities] は API の中身です。Repository の読み取りキャッシュではありません。
/// 履歴の初期件数は 0 なので、リストは空から始めます。
class ActivityApiClientImpl implements ActivityApiClient {
  final List<ActivityDto> _activities = [];
  int _nextId = 1;

  @override
  Future<ActivityDto> append({
    required String taskId,
    required String type,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final dto = ActivityDto(
      id: '$_nextId',
      taskId: taskId,
      type: type,
      occurredAt: DateTime.now(),
    );
    _nextId++;
    _activities.add(dto);
    return dto;
  }

  @override
  Future<List<ActivityDto>> fetchActivities() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List<ActivityDto>.from(_activities);
  }
}
