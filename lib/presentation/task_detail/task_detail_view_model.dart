import 'package:flutter_clean_architecture_sample/composition_root/providers.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task.dart';
import 'package:flutter_clean_architecture_sample/presentation/command_state.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class TaskDetailViewModel extends Notifier<TaskDetailState> {
  TaskDetailViewModel(this.id);
  final String id;
  bool _loadScheduled = false;

  @override
  TaskDetailState build() {
    if (!_loadScheduled) {
      _loadScheduled = true;
      Future.microtask(load);
    }
    return const TaskDetailState();
  }

  Future<void> load() async {
    if (state.load.running) return;
    state = state.copyWith(load: CommandState(running: true));

    final result = await ref.read(taskRepositoryProvider).getTask(id);

    if (!ref.mounted) return;
    switch (result) {
      case Ok(:final value):
        final task = value;
        final count = await ref.read(activityRepositoryProvider).count();
        if (!ref.mounted) return;
        switch (count) {
          case Ok(:final value):
            state = state.copyWith(
              task: task,
              activityCount: value,
              load: CommandState(result: Result.ok(null)),
            );
          case Error(:final error):
            state = state.copyWith(
              load: CommandState(result: Result.error(error)),
            );
        }
      case Error(:final error):
        state = state.copyWith(load: CommandState(result: Result.error(error)));
    }
  }

  Future<void> toggle() async {
    if (state.toggle.running) return;
    state = state.copyWith(toggle: CommandState(running: true));

    final result = await ref.read(completeTaskUseCaseProvider).call(id);

    if (!ref.mounted) return;
    switch (result) {
      case Ok(:final value):
        state = state.copyWith(
          task: value.task,
          activityCount: value.activityCount,
          toggle: CommandState(result: Result.ok(null)),
        );
      case Error(:final error):
        state = state.copyWith(
          toggle: CommandState(result: Result.error(error)),
        );
    }
  }
}

final taskDetailViewModelProvider = NotifierProvider.autoDispose
    .family<TaskDetailViewModel, TaskDetailState, String>(
      TaskDetailViewModel.new,
    );
