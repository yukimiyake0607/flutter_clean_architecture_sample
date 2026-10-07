import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture_sample/presentation/task_list/task_list_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// タスク一覧画面です。
///
/// アプリを起動するとこの画面に遷移します。
class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskListViewModelProvider);
    final viewModel = ref.read(taskListViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('タスク一覧')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => viewModel.setFilter(TaskFilter.all),
                child: Text('全て'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => viewModel.setFilter(TaskFilter.completed),
                child: Text('完了'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => viewModel.setFilter(TaskFilter.active),
                child: Text('未完了'),
              ),
            ],
          ),
          if (state.load.running || state.load.result == null)
            const Expanded(child: Center(child: CircularProgressIndicator())),
          if (state.load.hasError)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('読み込みに失敗しました'),
                    ElevatedButton(
                      onPressed: () => viewModel.load(),
                      child: Text('リトライ'),
                    ),
                  ],
                ),
              ),
            ),
          if (state.load.completed)
            Expanded(
              child: ListView.builder(
                itemCount: state.filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = state.filteredTasks[index];
                  return ListTile(
                    onTap: () => context.push('/tasks/${task.id}'),
                    title: Text(task.title.value),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/tasks/new');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
