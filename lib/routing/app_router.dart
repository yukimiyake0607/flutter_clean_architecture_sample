import 'package:flutter_clean_architecture_sample/presentation/add_task/add_task_screen.dart';
import 'package:flutter_clean_architecture_sample/presentation/task_detail/task_detail_screen.dart';
import 'package:flutter_clean_architecture_sample/presentation/task_list/task_list_screen.dart';
import 'package:go_router/go_router.dart';

/// `/`、`/tasks/new`、`/tasks/:id` を空の画面へ割り当てる。
///
/// この関数は画面の対応表だけを返す。Provider は作らず、具象クラスの組み立ては
/// composition_root が行う。子ルートの path は `/` で始めない。親の `/` と
/// つながって `/tasks/new` になる。`tasks/new` は `tasks/:id` より前に置く。
/// 逆だと `new` という文字列が id として詳細画面へ渡される。
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
              // URL の :id を画面へ渡す。Repository からは取らない。
              final id = state.pathParameters['id']!;
              return TaskDetailScreen(id: id);
            },
          ),
        ],
      ),
    ],
  );
}
