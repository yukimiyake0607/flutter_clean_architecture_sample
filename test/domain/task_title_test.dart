import 'package:flutter_clean_architecture_sample/domain/model/task_title.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('空白だけのタイトルは作れない', () {
    final result = TaskTitle.parse(' ');

    expect(result, isA<Error<TaskTitle>>());
    expect((result as Error<TaskTitle>).error, isA<EmptyTaskTitleException>());
  });

  test('前後の空白は除いた文字列になる', () {
    final result = TaskTitle.parse(' hello ');

    expect(result, isA<Ok<TaskTitle>>());
    expect((result as Ok<TaskTitle>).value.value, 'hello');
  });
}
