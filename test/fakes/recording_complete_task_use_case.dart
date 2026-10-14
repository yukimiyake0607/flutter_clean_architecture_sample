import 'package:flutter_clean_architecture_sample/application/complete_task_use_case.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task_title.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';

class RecordingCompleteTaskUseCase extends CompleteTaskUseCase {
  RecordingCompleteTaskUseCase({
    required super.taskRepository,
    required super.activityRepository,
  });

  int callCount = 0;
  String? calledTaskId;
  final task = Task(
    id: '1',
    title: (TaskTitle.parse('買い物') as Ok<TaskTitle>).value,
    note: '牛乳を買う',
    isCompleted: true,
    createdAt: DateTime(2026, 1, 1),
  );

  @override
  Future<Result<CompleteTaskOutcome>> call(String taskId) async {
    callCount++;
    calledTaskId = taskId;

    final outcome = CompleteTaskOutcome(task: task, activityCount: 1);
    return Result.ok(outcome);
  }
}
