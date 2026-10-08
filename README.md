# flutter_clean_architecture_sample

Clean Architecture を自分なりの解釈で実装したリポジトリです。画面は [flutter_mvvm_sample](https://github.com/yukimiyake0607/flutter_mvvm_sample) の Task Inbox と同じにし、層の置き方の違いを比較します。

## Clean Architecture

Clean Architectureでは、大事なビジネスルールほど内側に置きます。円の外側（保存方法、APIの形、画面）が変わっても内側のルールは変わらないようにするためです。例えば、 `Task` の `complete()` は「すでに完了しているタスクは、もう一度完了にできない」というルールです。これを内側に置くことで、保存先が変わったりしても影響を受けません。これがClean Architectureの特徴です。

## ディレクトリ構造

```text
lib/
  main.dart                          # 起動入口。層の組み立てはまだしない
  presentation/                      # Interface Adapters
    task_list/
      task_list_screen.dart          # 一覧の表示と遷移。追加は /tasks/new、戻ると load。行は /tasks/:id
      task_list_view_model.dart      # 取得は TaskRepository.getTasks だけ。フィルタは保持リストの加工
    add_task/
      add_task_screen.dart           # タイトルとメモの入力。保存成功で pop して一覧へ戻る
      add_task_view_model.dart       # TaskTitle.parse のあと createTask。追加の Use Case は無い
  application/                       # Application Business Rules
    complete_task_use_case.dart      # 完了のあと履歴を 1 件残す Use Case
    delete_task_use_case.dart        # 削除のあと履歴を 1 件残す Use Case
  domain/
    model/                           # Entities
      task_title.dart                # 空タイトルを拒否する値オブジェクト
      task.dart                      # 1件のタスクの完了ルールを持つ Entity
      activity.dart                  # 操作履歴の記録。ルールのメソッドは持たない
    logic/                           # Use Case より内側のポート
      task_repository.dart           # タスクの取得と保存を頼めるポート
      activity_repository.dart       # 履歴の追加と件数取得を頼めるポート
  data/                              # Frameworks & Drivers とその変換。タスクと履歴は別
    model/
      task_dto.dart                  # API の形。note は body、isCompleted は completed
      activity_dto.dart              # API の形。kind は type
    repositories/
      task_repository_impl.dart      # TaskRepository の実装。DTO 変換と読み取りキャッシュ
      activity_repository_impl.dart  # ActivityRepository の実装。DTO 変換と読み取りキャッシュ
    services/
      task_api_client.dart           # タスク API のポートと、メモリ上の実装
      activity_api_client.dart       # 履歴 API のポートと、空から始まるメモリ実装
  shared/
    result.dart                      # 層に属さない。成功か失敗かを返す共通の型
test/
  application/                       # Use Case のテスト。ポートは Fake に差し替える
    complete_task_use_case_test.dart
    delete_task_use_case_test.dart
  domain/                            # Entities のテスト
    task_title_test.dart
    task_test.dart
  data/                              # Repository 実装のテスト。ApiClient は Fake
    task_repository_impl_test.dart
    activity_repository_impl_test.dart
  fakes/                             # ポートの Fake と、ApiClient の Fake
    fake_activity_repository.dart    # ActivityRepository の Fake。Use Case テスト用
    fake_activity_api_client.dart    # ActivityApiClient の Fake。Repository テスト用
    fake_task_api_client.dart
    fake_task_repository.dart
```

詳細の ViewModel はまだ置かない。`composition_root/` は外側で実装を組み立てる場所です。

## 依存性逆転

例えばUsecaseを素直に書くと外側の具象クラスをimportすることになります。Clean Architectureでは依存が外を向くのを規則違反としているので、依存は常に内側を向くようにします。<br>
抽象クラス（abstract）をポートとして置き、外側がabstractを実装します。そうすることで、外側は内側の約束に合わせることができ依存方向は内側を向くようになります。（依存性逆転）<br>

## UseCaseを置く時の判断

UseCaseはRepositoryのポートを2つ以上使う時に用意します。タスクを取得するだけの簡単な処理ではポートは1つしか使わないのでUseCaseは置きません。
