import 'package:flutter_clean_architecture_sample/domain/model/task_title.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';

class TaskAlreadyCompletedException implements Exception {}

class Task {
  final String id;
  final TaskTitle title;
  final String note;
  final bool isCompleted;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    required this.note,
    required this.isCompleted,
    required this.createdAt,
  });

  Result<Task> complete() {
    if (isCompleted) {
      return Result.error(TaskAlreadyCompletedException());
    }
    return Result.ok(
      Task(
        id: id,
        title: title,
        note: note,
        isCompleted: true,
        createdAt: createdAt,
      ),
    );
  }
}
