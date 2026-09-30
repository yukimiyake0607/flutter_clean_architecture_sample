import 'package:flutter_clean_architecture_sample/domain/logic/activity_repository.dart';
import 'package:flutter_clean_architecture_sample/domain/logic/task_repository.dart';
import 'package:flutter_clean_architecture_sample/domain/model/activity.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';

/// [taskId]のタスクを完了し、履歴を1件残して、完了後のタスクと件数を返します。
///
/// 取得、完了判定、保存、履歴追加、件数取得の順に進む。
/// 取得、完了判定、保存のいずれかが失敗したら、そこで戻る。履歴は追加しない。
/// すでに完了しているタスクも、保存と履歴追加は行わない。
/// 履歴の追加または件数の取得が失敗しても、保存済みの完了は取り消さない。
class CompleteTaskUseCase {
  final TaskRepository _taskRepository;
  final ActivityRepository _activityRepository;

  const CompleteTaskUseCase({
    required TaskRepository taskRepository,
    required ActivityRepository activityRepository,
  }) : _activityRepository = activityRepository,
       _taskRepository = taskRepository;

  Future<Result<CompleteTaskOutcome>> call(String taskId) async {
    final taskGetResult = await _taskRepository.getTask(taskId);

    // taskの取得の成功したか
    switch (taskGetResult) {
      case Ok(:final value):
        final taskCompletedResult = value.complete();
        // taskの完了状態を変更できたか
        switch (taskCompletedResult) {
          case Ok(:final value):
            final taskUpdatedTask = await _taskRepository.updateTask(value);
            // taskが保存できたか
            switch (taskUpdatedTask) {
              case Ok(:final value):
                final task = value;
                final activityResult = await _activityRepository.append(
                  taskId: taskId,
                  kind: ActivityKind.completed,
                );
                // 履歴を追加できたか
                switch (activityResult) {
                  case Ok():
                    final countResult = await _activityRepository.count();
                    // 履歴の件数を取得できたか
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
