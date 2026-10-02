import 'package:flutter_clean_architecture_sample/domain/model/activity.dart';

/// API がやり取りするタスクの形です。
///
/// ドメインの [Activity] とはフィールド名をずらします。
/// [type] は [Activity.kind]です。
/// このクラスは Data 層に閉じ、Use Case や ViewModel は import しません。
class ActivityDto {
  const ActivityDto({
    required this.id,
    required this.taskId,
    required this.type,
    required this.occurredAt,
  });

  final String id;
  final String taskId;
  final String type;
  final DateTime occurredAt;

  factory ActivityDto.fromDomain(Activity activity) {
    return ActivityDto(
      id: activity.id,
      taskId: activity.taskId,
      type: activity.kind.name,
      occurredAt: activity.occurredAt,
    );
  }

  Activity toDomain() {
    ActivityKind kind;
    if (type == 'completed') {
      kind = ActivityKind.completed;
    } else if (type == 'deleted') {
      kind = ActivityKind.deleted;
    } else {
      throw Exception('kindの変換に失敗しました');
    }
    return Activity(id: id, taskId: taskId, kind: kind, occurredAt: occurredAt);
  }
}
