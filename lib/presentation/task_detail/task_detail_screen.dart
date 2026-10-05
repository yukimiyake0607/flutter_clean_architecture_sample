import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop('/'),
          icon: Icon(Icons.arrow_back),
        ),
        title: const Text('タスク詳細'),
      ),
      body: Center(child: Text(id)),
    );
  }
}
