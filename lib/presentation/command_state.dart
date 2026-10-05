import 'package:flutter_clean_architecture_sample/shared/result.dart';

/// ViewModelで使用する画面の状態を表現するクラス。
/// 
/// runningがtrueのときは実行中で、二重処理をしないようにする。
/// hasError, completedはそれぞれ処理が失敗したか成功したかを知るためのgetterです。
class CommandState<T> {
  const CommandState({this.result, this.running = false});

  final Result<T>? result;
  final bool running;

  bool get hasError => result is Error<T>;
  bool get completed => result is Ok<T>;
}
