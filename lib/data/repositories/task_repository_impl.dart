import 'package:flutter_clean_architecture_sample/data/model/task_dto.dart';
import 'package:flutter_clean_architecture_sample/data/services/task_api_client.dart';
import 'package:flutter_clean_architecture_sample/domain/logic/task_repository.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task_title.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({required TaskApiClient taskApiClient})
    : _taskApiClient = taskApiClient;

  final TaskApiClient _taskApiClient;
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
      if (_cache != null) {
        final index = _cache!.indexWhere((t) => t.id == task.id);
        if (index == -1) {
          return Result.error(Exception('タスクがありませんでした'));
        }
        _cache![index] = task;
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
    if (_cache != null) {
      final cacheTask = _cache!.firstWhere((t) => t.id == id);
      return Result.ok(cacheTask);
    }

    try {
      final tasksDto = await _taskApiClient.fetchTasks();
      final tasks = tasksDto.map((t) => t.toDomain()).toList();
      _cache = tasks;
      final task = _cache!.firstWhere((t) => t.id == id);
      return Result.ok(task);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<List<Task>>> getTasks() async {
    if (_cache != null) {
      return Result.ok(List<Task>.from(_cache!));
    }
    try {
      final tasksDto = await _taskApiClient.fetchTasks();
      final tasks = tasksDto.map((t) => t.toDomain()).toList();
      _cache = tasks;
      return Result.ok(tasks);
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
        }
        _cache![index] = result;
      }
      return Result.ok(result);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
