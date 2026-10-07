import 'package:flutter_clean_architecture_sample/composition_root/providers.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task_title.dart';
import 'package:flutter_clean_architecture_sample/presentation/command_state.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddTaskState {
  const AddTaskState({this.submit = const CommandState()});
  final CommandState<void> submit;

  AddTaskState copyWith({CommandState<void>? submit}) {
    return AddTaskState(submit: submit ?? this.submit);
  }
}

class AddTaskViewModel extends Notifier<AddTaskState> {
  @override
  AddTaskState build() {
    return const AddTaskState();
  }

  Future<void> submit({required String title, String note = ''}) async {
    if (state.submit.running) return;
    state = state.copyWith(submit: CommandState(running: true));

    final taskTitle = TaskTitle.parse(title);
    switch (taskTitle) {
      case Ok(:final value):
        final result = await ref
            .read(taskRepositoryProvider)
            .createTask(title: value, note: note);
        if (!ref.mounted) return;
        switch (result) {
          case Ok():
            state = state.copyWith(
              submit: CommandState(result: Result.ok(null)),
            );
          case Error(:final error):
            state = state.copyWith(
              submit: CommandState(result: Result.error(error)),
            );
        }
      case Error(:final error):
        state = state.copyWith(
          submit: CommandState(result: Result.error(error)),
        );
    }
  }
}

final addTaskViewModelProvider =
    NotifierProvider.autoDispose<AddTaskViewModel, AddTaskState>(
      AddTaskViewModel.new,
    );
