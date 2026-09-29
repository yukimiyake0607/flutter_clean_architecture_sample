import 'package:flutter_clean_architecture_sample/domain/model/activity.dart';
import 'package:flutter_clean_architecture_sample/shared/result.dart';

/// 操作履歴の追加と、その件数の取得を頼めるポートです。
///
/// 実装は data/ が行います。
/// 件数の取得は詳細の ViewModel（Interface Adapters）が直接呼び、
/// 追加は完了と削除の Use Case（Application Business Rules）が呼びます。
/// TaskRepository とは呼び合いません。
abstract class ActivityRepository {
  Future<Result<Activity>> append({
    required String taskId,
    required ActivityKind kind,
  });
  Future<Result<int>> count();
}
