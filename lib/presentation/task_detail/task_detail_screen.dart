import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task.dart';
import 'package:flutter_clean_architecture_sample/presentation/task_detail/task_detail_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';

/// タスク詳細画面です。
///
/// idはコンストラクタで受け取り、ルートが渡します。
class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = taskDetailViewModelProvider(id);
    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);

    ref.listen(provider, (previous, next) {
      if (next.delete.completed) {
        context.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back),
        ),
        title: const Text('タスク詳細'),
      ),
      body: Column(
        children: [
          if (state.load.running || state.load.result == null)
            const Expanded(child: Center(child: CircularProgressIndicator())),
          if (state.load.hasError)
            Center(
              child: Column(
                children: [
                  Text('取得に失敗しました'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.load();
                    },
                    child: Text('リトライ'),
                  ),
                ],
              ),
            ),
          if (state.load.completed)
            Center(
              child: Column(
                children: [
                  Text(state.task?.title.value ?? 'タスク名なし'),
                  const SizedBox(height: 4),
                  Text('履歴 ${state.activityCount.toString()}件'),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.toggle();
                    },
                    child: Text('完了'),
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.delete();
                    },
                    child: Text('削除'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
