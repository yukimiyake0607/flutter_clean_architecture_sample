import 'package:flutter_clean_architecture_sample/domain/logic/task_repository.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task_title.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';

class FakeTaskRepository implements TaskRepository {
  int updateCount = 0;
  bool shouldFail = false;
  bool taskComplete = false;

  @override
  Future<Result<Task>> createTask({
    required TaskTitle title,
    required String note,
  }) async {
    return Result.error(Exception('未実装'));
  }

  @override
  Future<Result<void>> deleteTask(String id) async {
    return Result.error(Exception('未実装'));
  }

  @override
  Future<Result<Task>> getTask(String id) async {
    final title = TaskTitle.parse('仕事');
    switch (title) {
      case Ok(:final value):
        final task = Task(
          id: id,
          title: value,
          note: 'MTG',
          isCompleted: taskComplete,
          createdAt: DateTime(2026, 1, 1),
        );
        return Result.ok(task);
      case Error(:final error):
        return Result.error(error);
    }
  }

  @override
  Future<Result<List<Task>>> getTasks() async {
    return Result.error(Exception('未実装'));
  }

  @override
  Future<Result<Task>> updateTask(Task task) async {
    updateCount++;
    if (shouldFail) {
      return Result.error(Exception('保存に失敗'));
    }
    return Result.ok(task);
  }
}
