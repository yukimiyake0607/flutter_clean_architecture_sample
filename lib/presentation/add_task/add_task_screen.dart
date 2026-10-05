import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// タスク追加画面です。
class AddTaskScreen extends ConsumerWidget {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop('/'),
          icon: Icon(Icons.arrow_back),
        ),
        title: const Text('追加画面'),
      ),
      body: Center(child: Text('タスクを追加します')),
    );
  }
}
