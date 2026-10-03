import 'package:flutter_clean_architecture_sample/data/model/activity_dto.dart';
import 'package:flutter_clean_architecture_sample/data/services/activity_api_client.dart';

class FakeActivityApiClient implements ActivityApiClient {
  bool shouldFail = false;
  int fetchCount = 0;
  String? typeOpen;
  final List<ActivityDto> _activities = [];

  @override
  Future<ActivityDto> append({
    required String taskId,
    required String type,
  }) async {
    if (shouldFail) {
      throw Exception('履歴追加に失敗しました');
    }
    typeOpen = type;
    final dto = ActivityDto(
      id: '1',
      taskId: taskId,
      type: type,
      occurredAt: DateTime.now(),
    );
    _activities.add(dto);
    return dto;
  }

  @override
  Future<List<ActivityDto>> fetchActivities() async {
    if (shouldFail) {
      throw Exception('履歴取得に失敗しました');
    }
    fetchCount++;
    return List<ActivityDto>.from(_activities);
  }
}
