import 'package:flutter_clean_architecture_sample/domain/model/task.dart';
import 'package:flutter_clean_architecture_sample/presentation/command_state.dart';

class TaskDetailState {
  const TaskDetailState({
    this.task,
    this.activityCount = 0,
    this.load = const CommandState(),
    this.toggle = const CommandState(),
    this.delete = const CommandState(),
  });

  final Task? task;
  final int activityCount;
  final CommandState<void> load;
  final CommandState<void> toggle;
  final CommandState<void> delete;

  TaskDetailState copyWith({
    Task? task,
    int? activityCount,
    CommandState<void>? load,
    CommandState<void>? toggle,
    CommandState<void>? delete,
  }) {
    return TaskDetailState(
      task: task ?? this.task,
      activityCount: activityCount ?? this.activityCount,
      load: load ?? this.load,
      toggle: toggle ?? this.toggle,
      delete: delete ?? this.delete,
    );
  }
}
