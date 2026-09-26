import 'package:flutter_clean_architecture_sample/domain/model/task_title.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'TaskTitle.parse()の中が空白だった場合、Error<TaskTitle>で、中の例外がEmptyTaskTitleExceptionとなる',
    () {
      final result = TaskTitle.parse(' ');

      expect(result, isA<Error<TaskTitle>>());
      expect(
        (result as Error<TaskTitle>).error,
        isA<EmptyTaskTitleException>(),
      );
    },
  );
}
