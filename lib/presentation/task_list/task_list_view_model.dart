import 'package:flutter_clean_architecture_sample/domain/model/task.dart';
import 'package:flutter_clean_architecture_sample/presentation/command_state.dart';

enum TaskFilter { all, active, completed }

class TaskListState {
  TaskListState({
    this.filter = TaskFilter.all,
    this.load = const CommandState(),
    this.tasks = const [],
  });

  final List<Task> tasks;
  final TaskFilter filter;
  final CommandState<void> load;

  List<Task> get filteredTask {
    if (filter == TaskFilter.all) {
      return tasks;
    } else if (filter == TaskFilter.active) {
      final notCompletedTasks = tasks
          .where((task) => task.isCompleted == false)
          .toList();
      return notCompletedTasks;
    } else {
      final completedTasks = tasks
          .where((task) => task.isCompleted == true)
          .toList();
      return completedTasks;
    }
  }
}
