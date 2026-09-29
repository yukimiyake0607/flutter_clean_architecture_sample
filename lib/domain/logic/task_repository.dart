import 'package:flutter_clean_architecture_sample/domain/model/task.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task_title.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';

/// タスクの取得と保存を頼めるポートです。
/// 
/// 依存性逆転を守るため実装はInterface Adapterが、
/// 呼び出しはApplication Business Rules（Usecase）が行います。
abstract class TaskRepository {
  Future<Result<List<Task>>> getTasks();
  Future<Result<Task>> getTask(String id);
  Future<Result<Task>> createTask({
    required TaskTitle title,
    required String note,
  });
  Future<Result<Task>> updateTask(Task task);
  Future<Result<void>> deleteTask(String id);
}
