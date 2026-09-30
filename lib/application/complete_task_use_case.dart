import 'package:flutter_clean_architecture_sample/domain/logic/activity_repository.dart';
import 'package:flutter_clean_architecture_sample/domain/logic/task_repository.dart';
import 'package:flutter_clean_architecture_sample/domain/model/activity.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';

class CompleteTaskUseCase {
  final TaskRepository _taskRepository;
  final ActivityRepository _activityRepository;
  late Task task;

  CompleteTaskUseCase({
    required TaskRepository taskRepository,
    required ActivityRepository activityRepository,
  }) : _activityRepository = activityRepository,
       _taskRepository = taskRepository;

  Future<Result<CompleteTaskOutcome>> call(String taskId) async {
    final taskGetResult = await _taskRepository.getTask(taskId);

    switch (taskGetResult) {
      case Ok(:final value):
        final taskCompletedResult = value.complete();
        switch (taskCompletedResult) {
          case Ok(:final value):
            final taskUpdatedTask = await _taskRepository.updateTask(value);
            switch (taskUpdatedTask) {
              case Ok(:final value):
                task = value;
                final activityResult = await _activityRepository.append(
                  taskId: taskId,
                  kind: ActivityKind.completed,
                );
                switch (activityResult) {
                  case Ok():
                    final countResult = await _activityRepository.count();
                    switch (countResult) {
                      case Ok(:final value):
                        return Result.ok(
                          CompleteTaskOutcome(task: task, activityCount: value),
                        );
                      case Error(:final error):
                        return Result.error(error);
                    }
                  case Error(:final error):
                    return Result.error(error);
                }
              case Error(:final error):
                return Result.error(error);
            }
          case Error(:final error):
            return Result.error(error);
        }
      case Error(:final error):
        return Result.error(error);
    }
  }
}

class CompleteTaskOutcome {
  const CompleteTaskOutcome({required this.task, required this.activityCount});

  final Task task;
  final int activityCount;
}
