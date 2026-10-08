import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task_title.dart';
import 'package:flutter_clean_architecture_sample/presentation/add_task/add_task_view_model.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// タスク追加画面です。
class AddTaskScreen extends ConsumerStatefulWidget {
  const AddTaskScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final titleTextController = TextEditingController();
  final noteTextController = TextEditingController();

  @override
  void dispose() {
    titleTextController.dispose();
    noteTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addTaskViewModelProvider);
    final viewModel = ref.read(addTaskViewModelProvider.notifier);

    ref.listen(addTaskViewModelProvider, (previous, next) {
      if (next.submit.completed) {
        context.go('/');
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/'),
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
            if (state.submit.result case Error(:final error))
              Text(
                error is EmptyTaskTitleException ? 'タイトルを入力して下さい' : '保存に失敗しました',
              ),
            TextFormField(controller: titleTextController),
            TextFormField(controller: noteTextController),
            const SizedBox(height: 20),
            ElevatedButton(
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
