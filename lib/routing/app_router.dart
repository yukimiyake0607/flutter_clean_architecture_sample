import 'package:flutter_clean_architecture_sample/presentation/add_task/add_task_screen.dart';
import 'package:flutter_clean_architecture_sample/presentation/task_detail/task_detail_screen.dart';
import 'package:flutter_clean_architecture_sample/presentation/task_list/task_list_screen.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const TaskListScreen(),
        routes: [
          GoRoute(
            path: 'tasks/new',
            builder: (context, state) => const AddTaskScreen(),
          ),
          GoRoute(
            path: 'tasks/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return TaskDetailScreen(id: id);
            },
          ),
        ],
      ),
    ],
  );
}
