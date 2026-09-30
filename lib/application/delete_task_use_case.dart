import 'package:flutter_clean_architecture_sample/domain/logic/activity_repository.dart';
import 'package:flutter_clean_architecture_sample/domain/logic/task_repository.dart';
import 'package:flutter_clean_architecture_sample/domain/model/activity.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';

class DeleteTaskUseCase {
  DeleteTaskUseCase({
    required TaskRepository taskRepository,
    required ActivityRepository activityRepository,
  }) : _activityRepository = activityRepository,
       _taskRepository = taskRepository;

  final TaskRepository _taskRepository;
  final ActivityRepository _activityRepository;

  Future<Result<int>> call(String taskId) async {
    final deleteTask = await _taskRepository.deleteTask(taskId);

    switch (deleteTask) {
      case Ok():
        final append = await _activityRepository.append(
          taskId: taskId,
          kind: ActivityKind.deleted,
        );
        switch (append) {
          case Ok():
            final count = await _activityRepository.count();
            switch (count) {
              case Ok(:final value):
                return Result.ok(value);
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
