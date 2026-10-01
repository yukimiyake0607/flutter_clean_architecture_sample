import 'package:flutter_clean_architecture_sample/data/model/task_dto.dart';

abstract class TaskApiClient {
  Future<List<TaskDto>> fetchTasks();
  Future<TaskDto> fetchTask(String id);
  Future<TaskDto> createTask({required String title, required String body});
  Future<TaskDto> updateTask(TaskDto dto);
  Future<void> deleteTask(String id);
}

class TaskApiClientImpl implements TaskApiClient {
  bool shouldFail = false;
  int _nextId = 6;

  final List<TaskDto> _tasks = [
    TaskDto(
      id: '1',
      title: '仕事',
      body: 'MTG',
      completed: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    TaskDto(
      id: '2',
      title: 'ランニング',
      body: '30分',
      completed: true,
      createdAt: DateTime(2026, 1, 1),
    ),
    TaskDto(
      id: '3',
      title: '買い物',
      body: '牛乳',
      completed: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    TaskDto(
      id: '4',
      title: '仕事',
      body: '請求書作成',
      completed: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    TaskDto(
      id: '5',
      title: 'ギター',
      body: '1時間',
      completed: true,
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  @override
  Future<TaskDto> createTask({
    required String title,
    required String body,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (shouldFail) {
      throw Exception('タスクの作成に失敗しました');
    }
    final taskDto = TaskDto(
      id: '$_nextId',
      title: title,
      body: body,
      completed: false,
      createdAt: DateTime.now(),
    );
    _nextId++;
    _tasks.add(taskDto);

    return taskDto;
  }

  @override
  Future<void> deleteTask(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (shouldFail) {
      throw Exception('タスクの削除に失敗しました');
    }
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      throw Exception('タスクが見つかりません');
    }
    _tasks.removeAt(index);
  }

  @override
  Future<TaskDto> fetchTask(String id) {
    // TODO: implement fetchTask
    throw UnimplementedError();
  }

  @override
  Future<List<TaskDto>> fetchTasks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (shouldFail) {
      throw Exception('タスクの取得に失敗しました');
    }

    return List<TaskDto>.from(_tasks);
  }

  @override
  Future<TaskDto> updateTask(TaskDto dto) {
    // TODO: implement updateTask
    throw UnimplementedError();
  }
}
