import 'package:flutter_clean_architecture_sample/composition_root/providers.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task.dart';
import 'package:flutter_clean_architecture_sample/presentation/command_state.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TaskFilter { all, active, completed }

class TaskListState {
  const TaskListState({
    this.filter = TaskFilter.all,
    this.load = const CommandState(),
    this.tasks = const [],
  });

  final List<Task> tasks;
  final TaskFilter filter;
  final CommandState<void> load;

  List<Task> get filteredTasks {
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

  TaskListState copyWith({
    List<Task>? tasks,
    TaskFilter? filter,
    CommandState<void>? load,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      load: load ?? this.load,
    );
  }
}

class TaskListViewModel extends Notifier<TaskListState> {
  bool _loadScheduled = false;

  @override
  TaskListState build() {
    if (!_loadScheduled) {
      _loadScheduled = true;
      Future.microtask(load);
    }
    return const TaskListState();
  }

  Future<void> load() async {
    if (state.load.running) return;
    state = state.copyWith(load: const CommandState(running: true));

    final result = await ref.read(taskRepositoryProvider).getTasks();

    if (!ref.mounted) return;
    switch (result) {
      case Ok(:final value):
        state = state.copyWith(
          tasks: value,
          load: CommandState(result: Result<void>.ok(null)),
        );
      case Error(:final error):
        state = state.copyWith(load: CommandState(result: Result.error(error)));
    }
  }

  void setFilter(TaskFilter filter) {
    state = state.copyWith(filter: filter);
  }
}

final taskListViewModelProvider =
    NotifierProvider.autoDispose<TaskListViewModel, TaskListState>(
      TaskListViewModel.new,
    );
