# flutter_clean_architecture_sample

Clean Architecture を自分なりの解釈で実装したリポジトリです。画面は [flutter_mvvm_sample](https://github.com/yukimiyake0607/flutter_mvvm_sample) の Task Inbox と同じにし、層の置き方の違いを比較します。

## Clean Architecture

Clean Architectureでは、大事なビジネスルールほど内側に置きます。円の外側（保存方法、APIの形、画面）が変わっても内側のルールは変わらないようにするためです。例えば、 `Task` の `complete()` は「すでに完了しているタスクは、もう一度完了にできない」というルールです。これを内側に置くことで、保存先が変わったりしても影響を受けません。これがClean Architectureの特徴です。

## ディレクトリ構造

```text
lib/
  main.dart                          # 起動入口。ProviderScope を付ける
  composition_root/
    providers.dart                   # 外側で具象を組み立て、ポートと Use Case として公開する
  presentation/                      # Interface Adapters
    command_state.dart               # 実行中と成功失敗を持つ画面状態
    task_list/
      task_list_screen.dart          # 一覧の表示と遷移。追加も詳細も、戻ると load
      task_list_view_model.dart      # 取得は TaskRepository.getTasks だけ。フィルタは保持リストの加工
    add_task/
      add_task_screen.dart           # タイトルとメモの入力。保存成功で pop して一覧へ戻る
      add_task_view_model.dart       # TaskTitle.parse のあと createTask。追加の Use Case は無い
    task_detail/
      task_detail_screen.dart        # タイトルと履歴件数。完了と削除。削除成功で pop
      task_detail_view_model.dart    # 取得は getTask と count。完了と削除は Use Case
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
  routing/
    app_router.dart                  # 一覧、追加、詳細のルート
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
  presentation/                      # ViewModel テストと、一覧の Widget test。ポートは Fake に差し替える
    task_list/
      task_list_screen_test.dart     # スピナーのあとリストが出る。失敗のあとリトライできる
      task_list_view_model_test.dart # load の成功と失敗。フィルタは filteredTasks だけが変わる
    add_task/
      add_task_view_model_test.dart  # createTask を呼ぶ。空タイトルでは呼ばない
    task_detail/
      task_detail_view_model_test.dart # 完了は Use Case を呼ぶ。updateTask と append は呼ばない
  fakes/                             # ポートの Fake と、ApiClient の Fake
    fake_activity_repository.dart    # ActivityRepository の Fake。Use Case テスト用
    fake_activity_api_client.dart    # ActivityApiClient の Fake。Repository テスト用
    fake_task_api_client.dart
    fake_task_repository.dart        # タスクのポートの Fake。取得の成功と失敗、呼び出し回数
    recording_complete_task_use_case.dart # 完了 Use Case の代役。call だけ記録する
```

詳細の ViewModel は family で、タスクの id ごとに状態を持つ。取得は Repository を直接呼び、完了と削除だけ Use Case を呼ぶ。`composition_root/` は外側で実装を組み立てる場所です。

## 依存性逆転

例えばUsecaseを素直に書くと外側の具象クラスをimportすることになります。Clean Architectureでは依存が外を向くのを規則違反としているので、依存は常に内側を向くようにします。<br>
抽象クラス（abstract）をポートとして置き、外側がabstractを実装します。そうすることで、外側は内側の約束に合わせることができ依存方向は内側を向くようになります。（依存性逆転）<br>

## UseCaseを置く時の判断

UseCaseはRepositoryのポートを2つ以上使う時に用意します。タスクを取得するだけの簡単な処理ではポートは1つしか使わないのでUseCaseは置きません。
