import 'package:flutter_clean_architecture_sample/data/model/task_dto.dart';
import 'package:flutter_clean_architecture_sample/data/services/task_api_client.dart';

class FakeTaskApiClient implements TaskApiClient {
  int fetchCount = 0;
  bool shouldFail = false;
  List<TaskDto> tasks = [
    TaskDto(
      id: '1',
      title: '仕事',
      body: 'MTG',
      completed: true,
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  @override
  Future<TaskDto> createTask({required String title, required String body}) {
    // TODO: implement createTask
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTask(String id) {
    // TODO: implement deleteTask
    throw UnimplementedError();
  }

  @override
  Future<TaskDto> fetchTask(String id) {
    // TODO: implement fetchTask
    throw UnimplementedError();
  }

  @override
  Future<List<TaskDto>> fetchTasks() async {
    if (shouldFail) {
      throw Exception('タスクの取得に失敗しました');
    }
    fetchCount++;
    return List<TaskDto>.from(tasks);
  }

  @override
  Future<TaskDto> updateTask(TaskDto dto) async {
    final index = tasks.indexWhere((t) => t.id == dto.id);
    tasks[index] = dto;
    return dto;
  }
}
