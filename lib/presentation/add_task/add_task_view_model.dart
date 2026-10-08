import 'package:flutter_clean_architecture_sample/composition_root/providers.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task_title.dart';
import 'package:flutter_clean_architecture_sample/presentation/command_state.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 追加画面の状態です。
///
/// 保存したタスクの一覧は持ちません。タスクの正本は Repository のキャッシュで、
/// 一覧へ戻ったときに `getTasks` が読み直します。この状態が知るのは保存の進み具合だけ。
class AddTaskState {
  const AddTaskState({this.submit = const CommandState()});

  /// 保存の実行中・成功・失敗。成功しても作ったタスクは入れません。
  final CommandState<void> submit;

  AddTaskState copyWith({CommandState<void>? submit}) {
    return AddTaskState(submit: submit ?? this.submit);
  }
}

/// タスク追加の ViewModel です。
///
/// 追加は `TaskRepository` というポートを1つだけ使います。ポートが1つの読み書きは
/// ViewModel が直接呼び、Use Case は置きません。完了や削除はタスクと履歴の
/// 2つのポートを順番に指揮するので、そちらだけ Use Case があります。
///
/// 依存するのはポートです。`ref.read(taskRepositoryProvider)` が返す型は
/// `TaskRepository` で、実装クラスは `composition_root` が組み立てます。
class AddTaskViewModel extends Notifier<AddTaskState> {
  @override
  AddTaskState build() {
    return const AddTaskState();
  }

  /// タイトルとメモを保存します。
  ///
  /// [title] は画面の入力そのものです。空かどうかはまだ分からないので [String] で受け取り、
  /// 先頭で [TaskTitle.parse] します。失敗したときは Repository を呼びません。
  /// [note] は任意で、空文字のままで保存できます。
  Future<void> submit({required String title, String note = ''}) async {
    // 保存中の連打で createTask を二重に呼ばない。
    if (state.submit.running) return;
    state = state.copyWith(submit: CommandState(running: true));

    // 空や空白だけの拒否は値オブジェクトのルール。画面の if では止めない。
    final taskTitle = TaskTitle.parse(title);
    switch (taskTitle) {
      case Ok(:final value):
        final result = await ref
            .read(taskRepositoryProvider)
            .createTask(title: value, note: note);
        // await のあいだに画面が閉じていることがある。
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
        // parse が失敗したので、ここから createTask には進まない。
        state = state.copyWith(
          submit: CommandState(result: Result.error(error)),
        );
    }
  }
}

/// 追加画面を開いているあいだだけの ViewModel です。
///
/// 画面を閉じると捨てます。保存されたタスクは Repository のキャッシュに残ります。
final addTaskViewModelProvider =
    NotifierProvider.autoDispose<AddTaskViewModel, AddTaskState>(
      AddTaskViewModel.new,
    );
