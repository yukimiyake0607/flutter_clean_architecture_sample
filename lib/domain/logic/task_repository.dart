import 'package:flutter_clean_architecture_sample/domain/model/task.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task_title.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';

/// 外側のUsecaseが実装するポート（TaskRepository）です。
/// 
/// 依存性逆転を守るため、このポートは一番内側のEntitiesに配置します。
abstract class TaskRepository {
  Future<Result<List<Task>>> getTasks();
  Future<Result<Task>> getTask();
  Future<Result<Task>> createTask({
    required TaskTitle title,
    required String note,
  });
  Future<Result<Task>> updateTask(Task task);
  Future<Result<void>> deleteTask(String id);
}
