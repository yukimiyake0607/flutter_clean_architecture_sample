import 'package:flutter_clean_architecture_sample/domain/model/task_title.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';

/// TaskのisCompletedがすでにtrueの場合にResult.errorに載せる例外
class TaskAlreadyCompletedException implements Exception {}

/// 1件のタスクを表すEntity。
///
/// 未完了のタスクだけを完了にできる。画面やDBのことは知らない。
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

  /// 未完了なら、完了済みの新しい Task を Ok で返す。
  /// すでに完了なら TaskAlreadyCompletedException を載せた Error を返す。
  /// このインスタンスは変えない。
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
