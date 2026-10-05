import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// タスク一覧画面です。
/// 
/// アプリを起動するとこの画面に遷移します。
class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('タスク一覧')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/tasks/new'),
              child: const Text('追加へ'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/tasks/1'),
              child: const Text('詳細へ'),
            ),
          ],
        ),
      ),
    );
  }
}