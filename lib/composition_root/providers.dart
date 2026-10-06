/// 具象クラスを作り、ポートと Use Case として公開する。
///
/// このファイル以外の lib は実装クラスを作らない。公開する型は `TaskRepository` のように
/// 約束の型であり、`TaskRepositoryImpl` ではない。`autoDispose` は付けない。
/// ApiClient のリストと Repository のキャッシュが、アプリ生存中のタスクそのものだからである。
library;

import 'package:flutter_clean_architecture_sample/application/complete_task_use_case.dart';
import 'package:flutter_clean_architecture_sample/application/delete_task_use_case.dart';
import 'package:flutter_clean_architecture_sample/data/repositories/activity_repository_impl.dart';
import 'package:flutter_clean_architecture_sample/data/repositories/task_repository_impl.dart';
import 'package:flutter_clean_architecture_sample/data/services/activity_api_client.dart';
import 'package:flutter_clean_architecture_sample/data/services/task_api_client.dart';
import 'package:flutter_clean_architecture_sample/domain/logic/activity_repository.dart';
import 'package:flutter_clean_architecture_sample/domain/logic/task_repository.dart';
import 'package:flutter_clean_architecture_sample/routing/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final taskApiClientProvider = Provider<TaskApiClient>((ref) {
  return TaskApiClientImpl();
});

final activityApiClientProvider = Provider<ActivityApiClient>((ref) {
  return ActivityApiClientImpl();
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final client = ref.watch(taskApiClientProvider);
  return TaskRepositoryImpl(taskApiClient: client);
});

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final client = ref.watch(activityApiClientProvider);
  return ActivityRepositoryImpl(activityApiClient: client);
});

final completeTaskUseCaseProvider = Provider<CompleteTaskUseCase>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  final activityRepository = ref.watch(activityRepositoryProvider);
  return CompleteTaskUseCase(
    taskRepository: taskRepository,
    activityRepository: activityRepository,
  );
});

final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  final activityRepository = ref.watch(activityRepositoryProvider);
  return DeleteTaskUseCase(
    taskRepository: taskRepository,
    activityRepository: activityRepository,
  );
});

final routerProvider = Provider<GoRouter>((ref) {
  return createAppRouter();
});
