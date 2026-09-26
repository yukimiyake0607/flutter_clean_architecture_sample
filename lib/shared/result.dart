/// 結果を返すときに使用するResultクラスです。
/// 
/// Clean Architectureのどの円にも属さないのでlib/sharedに保管。
sealed class Result<T> {
  const Result();
  factory Result.ok(T value) = Ok<T>;
  factory Result.error(Exception error) = Error<T>;
}

/// 成功したときに使用するResultのサブクラス
final class Ok<T> extends Result<T> {
  const Ok(this.value);
  
  // 成功したときに渡す値
  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

/// 失敗したときに使用するResultのサブクラス
final class Error<T> extends Result<T> {
  const Error(this.error);
  
  // 失敗したときに渡す例外
  final Exception error;

  @override
  String toString() => 'Result<$T>.error($error)';
}
