import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture_sample/presentation/task_detail/task_detail_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final viewModel = ref.read(provider);

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
      body: Center(child: Text(id)),
    );
  }
}
