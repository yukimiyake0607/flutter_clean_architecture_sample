import 'package:flutter_clean_architecture_sample/shared/result.dart';

class CommandState<T> {
  const CommandState({this.result, this.running = false});

  final Result<T>? result;
  final bool running;

  bool get hasError => result is Error<T>;
  bool get completed => result is Ok<T>;
}
