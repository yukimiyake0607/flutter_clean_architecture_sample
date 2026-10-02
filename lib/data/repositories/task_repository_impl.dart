import 'package:flutter_clean_architecture_sample/data/model/task_dto.dart';
import 'package:flutter_clean_architecture_sample/data/services/task_api_client.dart';
import 'package:flutter_clean_architecture_sample/domain/logic/task_repository.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task_title.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';

/// [TaskRepository] の実装です。
///
/// [TaskApiClient] の [TaskDto] を [Task] に変換し、取得結果を [_cache] に覚えます。
/// Service の例外は [Result.error] にします。
/// 具象の [TaskApiClientImpl] は知らず、ポートだけを受け取ります。
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({required TaskApiClient taskApiClient})
    : _taskApiClient = taskApiClient;

  final TaskApiClient _taskApiClient;
  /// 読み取りキャッシュです。未取得のときは null です。
  /// API のリストとは別で、[Task] を覚えます。
  List<Task>? _cache;

  @override
  Future<Result<Task>> createTask({
    required TaskTitle title,
    required String note,
  }) async {
    try {
      final taskDto = await _taskApiClient.createTask(
        title: title.value,
        body: note,
      );
      final task = taskDto.toDomain();
      // まだ取得していなければキャッシュは作らない。次の getTasks が Service から取り直す。
      if (_cache != null) {
        _cache!.add(task);
      }
      return Result.ok(task);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> deleteTask(String id) async {
    try {
      await _taskApiClient.deleteTask(id);
      if (_cache != null) {
        final index = _cache!.indexWhere((t) => t.id == id);
        if (index == -1) {
          return Result.error(Exception('タスクがありませんでした'));
        }
        _cache!.removeAt(index);
      }
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<Task>> getTask(String id) async {
    // 1件だけを全件のキャッシュにしない。全件を取り、そのリストをキャッシュする。
    if (_cache != null) {
      final index = _cache!.indexWhere((t) => t.id == id);
      if (index == -1) {
        return Result.error(Exception('タスクが見つかりませんでした'));
      }
      return Result.ok(_cache![index]);
    }

    try {
      final tasksDto = await _taskApiClient.fetchTasks();
      final tasks = tasksDto.map((t) => t.toDomain()).toList();
      _cache = tasks;
      final index = _cache!.indexWhere((t) => t.id == id);
      if (index == -1) {
        return Result.error(Exception('タスクが見つかりませんでした'));
      }
      final task = _cache![index];
      return Result.ok(task);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<List<Task>>> getTasks() async {
    if (_cache != null) {
      // 呼び出し側が add してもキャッシュ本体は変わらないように、コピーを返す。
      return Result.ok(List<Task>.from(_cache!));
    }
    try {
      final tasksDto = await _taskApiClient.fetchTasks();
      final tasks = tasksDto.map((t) => t.toDomain()).toList();
      _cache = tasks;
      // 呼び出し側が add してもキャッシュ本体は変わらないように、コピーを返す。
      return Result.ok(List<Task>.from(tasks));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<Task>> updateTask(Task task) async {
    try {
      final taskDto = await _taskApiClient.updateTask(TaskDto.fromDomain(task));
      final result = taskDto.toDomain();
      if (_cache != null) {
        final index = _cache!.indexWhere((t) => t.id == result.id);
        if (index == -1) {
          _cache!.add(result);
          return Result.ok(result);
        }
        // Service へ渡したあと、キャッシュも同じ値にする。次の get は Service を呼ばない。
        _cache![index] = result;
      }
      return Result.ok(result);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
