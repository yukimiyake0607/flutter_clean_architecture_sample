import 'package:flutter_clean_architecture_sample/domain/logic/activity_repository.dart';
import 'package:flutter_clean_architecture_sample/domain/logic/task_repository.dart';
import 'package:flutter_clean_architecture_sample/domain/model/activity.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';

/// [taskId] のタスクを削除し、履歴を 1 件残して件数を返します。
///
/// 削除、履歴追加、件数取得の順に進む。
/// 削除が失敗したら、そこで戻る。履歴は追加しない。
/// すでに完了しているタスクも削除する。完了判定は行わない。
/// 履歴の追加または件数の取得が失敗しても、削除は取り消さない。
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
