import 'package:flutter_clean_architecture_sample/domain/model/task.dart';
import 'package:flutter_clean_architecture_sample/domain/model/task_title.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';

/// API がやり取りするタスクの形です。
///
/// ドメインの [Task] とはフィールド名をずらします。
/// [body] は [Task.note]、[completed] は [Task.isCompleted] です。
/// [title] はここでは [String] です。空タイトルを拒否するルールは [TaskTitle] にあります。
/// このクラスは Data 層に閉じ、Use Case や ViewModel は import しません。
class TaskDto {
  const TaskDto({
    required this.id,
    required this.title,
    required this.body,
    required this.completed,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final bool completed;
  final DateTime createdAt;

  /// [Task] を API の形にします。
  ///
  /// [TaskTitle] は [TaskTitle.value] の文字列に戻します。
  factory TaskDto.fromDomain(Task task) {
    return TaskDto(
      id: task.id,
      title: task.title.value,
      body: task.note,
      completed: task.isCompleted,
      createdAt: task.createdAt,
    );
  }

  /// API の形を [Task] にします。
  ///
  /// タイトルは [TaskTitle.parse] に渡します。空チェックはここでは書き直しません。
  /// シードと保存は空タイトルを入れないので、通常は成功します。
  /// [Error] のときは、保存してはいけないデータが API から来ています。
  /// 戻り値は [Task] なので [Result] にはせず、parse が返した例外を投げます。
  Task toDomain() {
    final taskTitle = TaskTitle.parse(title);
    switch (taskTitle) {
      case Ok(:final value):
        return Task(
          id: id,
          title: value,
          note: body,
          isCompleted: completed,
          createdAt: createdAt,
        );
      case Error(:final error):
        // parse の例外を包み直さない。EmptyTaskTitleException のまま止める。
        throw error;
    }
  }
}
