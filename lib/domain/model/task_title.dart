import 'package:flutter_clean_architecture_sample/shared/result.dart';

/// TaskTitleが空だった場合にResult.errorに載せる例外。
class EmptyTaskTitleException implements Exception {}

/// TaskTitle（値オブジェクト）
/// 
/// Taskのタイトルに関するビジネスルールをここでカプセル化する。
class TaskTitle {
  // インスタンスを作れるのはparseだけにするため
  const TaskTitle._(this.value);

  final String value;

  static Result<TaskTitle> parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return Result.error(EmptyTaskTitleException());
    }
    return Result.ok(TaskTitle._(trimmed));
  }
}
