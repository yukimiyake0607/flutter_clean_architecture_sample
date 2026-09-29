enum ActivityKind { completed, deleted }

class Activity {
  final String id;
  final String taskId;
  final ActivityKind kind;
  final DateTime occurredAt;

  const Activity({
    required this.id,
    required this.taskId,
    required this.kind,
    required this.occurredAt,
  });
}
