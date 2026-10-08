import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task_title.dart';
import 'package:flutter_clean_architecture_sample/presentation/add_task/add_task_view_model.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// タスク追加画面です。
///
/// 入力中の文字列は View が持ち、保存は [AddTaskViewModel.submit] だけを呼びます。
/// この画面は Repository を見ません。保存に成功して一覧へ戻るのも View の仕事です。
///
/// 入力欄の [TextEditingController] を画面と一緒に捨てるため、
/// [ConsumerStatefulWidget] にしています。
class AddTaskScreen extends ConsumerStatefulWidget {
  const AddTaskScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  /// タイトルの入力。空の判定は ViewModel に渡してから行います。
  final titleTextController = TextEditingController();

  /// メモの入力。空のままで保存できます。
  final noteTextController = TextEditingController();

  @override
  void dispose() {
    // 画面が破棄されたあとにコントローラが残らないようにする。
    titleTextController.dispose();
    noteTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 表示の更新は watch。ボタンからメソッドを呼ぶだけなら read。
    final state = ref.watch(addTaskViewModelProvider);
    final viewModel = ref.read(addTaskViewModelProvider.notifier);

    // 遷移は状態が変わったときの一度きりの処理。成功したときだけ閉じる。
    ref.listen(addTaskViewModelProvider, (previous, next) {
      if (next.submit.completed) {
        context.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back),
        ),
        title: const Text('追加画面'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (state.submit.running)
              Center(child: const CircularProgressIndicator()),
            // result.dart の Error。import しないと Dart 標準の Error を指してしまう。
            if (state.submit.result case Error(:final error))
              Text(
                // 拒否は TaskTitle が行う。画面は、その失敗をどの文言で見せるかだけを決める。
                error is EmptyTaskTitleException
                    ? 'タイトルを入力して下さい'
                    : '保存に失敗しました',
              ),
            TextFormField(controller: titleTextController),
            TextFormField(controller: noteTextController),
            const SizedBox(height: 20),
            ElevatedButton(
              // 空でも押せるようにする。空白だけの拒否は submit の先頭の parse に任せる。
              onPressed: () {
                viewModel.submit(
                  title: titleTextController.text,
                  note: noteTextController.text,
                );
              },
              child: Text('追加'),
            ),
          ],
        ),
      ),
    );
  }
}
