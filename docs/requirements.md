# Task Inbox — Clean Architecture サンプル実装の前提（確定仕様）

このファイルは **実装・レビューの単一ソース** である。
実装に入る前に必ず読む。ここに無い機能・パッケージ・層は追加しない。

実装は手で行う。このファイルを書いたあと、Agent がアプリ本体を実装することはこの仕様の範囲外である。

比較対象は [flutter_mvvm_sample の確定仕様](https://github.com/yukimiyake0607/flutter_mvvm_sample/blob/main/docs/required.md) と、そのリポジトリの実装である。画面と操作は揃える。層の置き方が違う。

---

## 1. このプロジェクトの目的

アプリの完成度は二の次。最優先は次を **自分のコードを指して人に説明できる** こと。

- 依存規則。ソースコードの依存は内側だけを向く
- Entity に置くルールと Use Case に置くルールの違い
- 単純な取得は Use Case にしない理由
- Repository のポートを Domain に置き、実装を Data に置く理由（依存性逆転）
- [ゆめみのモバイルテンプレート](https://github.com/ymm-oss/flutter-mobile-project-template) の `domain_model` / `domain_logic` / `application` / `infrastructure` / `composition_root` が、この単一パッケージのどのフォルダか

教材:

- [The Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)（Robert C. Martin）
- 学習メモ `flutter-architecture-study/docs/04-clean-architecture.md`
- テンプレートの [ARCHITECTURE.md](https://github.com/ymm-oss/flutter-mobile-project-template/blob/main/docs/ARCHITECTURE.md)
- テンプレートの [MODELING.md](https://github.com/ymm-oss/flutter-mobile-project-template/blob/main/docs/MODELING.md)

Flutter の Presentation / Domain / Data は、元記事の円を畳んだ解釈として使う。円の名前との対応は §3 に書く。

対象は Clean Architecture の依存とモデルの置き方である。テンプレートのパッケージ分割、デザインシステム、flavor、多言語、CI、freezed は再現しない。README 自身が、小規模アプリにはそれらが過剰だと書いている。

---

## 2. アプリ概要

**名前:** Task Inbox
**ドメイン:** タスクと、その操作履歴
**画面:** 3（View と ViewModel は常に 1:1）

| ルート | 画面 | View | ViewModel |
|---|---|---|---|
| `/` | 一覧 | `TaskListScreen` | `TaskListViewModel` |
| `/tasks/new` | 追加 | `AddTaskScreen` | `AddTaskViewModel` |
| `/tasks/:id` | 詳細 | `TaskDetailScreen` | `TaskDetailViewModel` |

履歴専用の画面は作らない。

### ユーザー操作（これ以外の機能は作らない）

1. 起動すると一覧を読み込む（フェイク API に約 300ms 遅延を入れ、ローディングを目視できるようにする）
2. フィルタ切替: すべて / 未完了 / 完了。**Repository は叩かない。ViewModel が保持リストを加工して出す**
3. 「追加」へ遷移。タイトル必須・メモ任意。保存成功で一覧へ戻る
4. 行タップで詳細。完了トグルと削除ができる
5. 詳細で完了または削除に成功すると、操作履歴が 1 件増える。詳細画面にその件数を出す
6. 詳細で変更した内容が一覧に反映される（**同じ `TaskRepository` インスタンス = タスクの SSOT**）
7. 読み込み失敗時はエラー表示とリトライ。Service に失敗を仕込むスイッチを用意する

初期データ: フェイク API 起動時にタスクを 3〜5 件シードする。履歴の初期件数は 0。

完了にする、は未完了のタスクだけ成功する。すでに完了しているタスクへもう一度完了を押すと失敗し、履歴は増えない。削除は完了・未完了のどちらでもできる。削除成功後は一覧へ戻る。

---

## 3. 層と、円との対応

```
View ──► ViewModel ──► TaskRepository            … 一覧・取得・追加
              │
              └──► Use Case ──► TaskRepository
                           └──► ActivityRepository   … 完了・削除
```

| このアプリのフォルダ | 元記事の円 | テンプレートのパッケージ |
|---|---|---|
| `domain/model` | Entities | `packages/domain_model` |
| `domain/logic` | Use Cases が依存する内側のポート | `packages/domain_logic` |
| `application` | Use Cases | `packages/application` |
| `presentation` | Interface Adapters（View / Controller） | `apps/app` の `presentation` |
| `data` | Frameworks & Drivers と、その変換 | `packages/infrastructure` |
| `composition_root` | 外側で実装を組み立てる場所 | `apps/app/lib/composition_root` |
| `shared` | 層に属さない共通の戻り値 | `packages/shared` |

`domain/` と `application/` は Flutter、Riverpod、DTO、`data/` を import しない。
`presentation` は `data/` の具象クラスを import しない。見るのは Domain の型、Application の Use Case、`composition_root` が公開する Provider だけである。

### 3.1 呼び出しの分け方

テンプレートは「すべての操作に Use Case を用意するのは過剰な場合がある。単純な CRUD は Presentation から Repository を直接呼んでよい。複数 Repository や複雑なルールは Use Case」と書いている。このアプリもそれに合わせる。全部を Use Case で包まない。

| 操作 | 呼び先 | 理由 |
|---|---|---|
| 一覧の取得、1件取得、追加 | ViewModel → `TaskRepository` | 単一 Repository の読み書き。MVVM サンプルと同じ経路 |
| 一覧フィルタ | ViewModel 内の加工 | 表示用。Repository も Use Case も呼ばない |
| 履歴件数の取得 | 詳細 ViewModel → `ActivityRepository` | 単一 Repository の読み取り |
| 完了、削除 | ViewModel → Use Case | タスクと履歴の 2 ポートを指揮する |

### 3.2 ルールの置き場所

| ルール | 置き場所 |
|---|---|
| タイトルは空白だけでは作れない | `TaskTitle`（値オブジェクト） |
| すでに完了のタスクは完了にできない | `Task.complete()`（Entity） |
| 完了または削除のあと履歴を 1 件残す | `CompleteTaskUseCase` / `DeleteTaskUseCase` |
| フィルタ、画面状態、ナビゲーション | Presentation |

テンプレートの MODELING.md では、`UserName` が形式を拒否し、`User.changeName()` が新しい `User` を返す。複数集約にまたがる処理は Use Case 側に置く。このアプリの `TaskTitle` と `Task.complete()` はその縮小である。

MVVM サンプルの `Task` はフィールドと `copyWith` だけを持つ。同じ画面でも、ルールが Entity に入っている点が比較対象になる。

---

## 4. MVVM サンプルとの差分

揃えるもの:

- 3 画面、ルート、フィルタ、追加、詳細、約 300ms の遅延、失敗スイッチ、シード
- View : ViewModel = 1:1
- タスクの変更は `TaskRepository` のキャッシュだけが行う（SSOT）
- フィルタは保持リストからの導出
- `Result` と `CommandState`
- Riverpod の `Notifier`。`ChangeNotifier` と `package:provider` は使わない
- 手書きの不変モデル。freezed は使わない
- ナビゲーションは View。ViewModel は遷移しない

ずらすもの:

| 箇所 | MVVM サンプル | このリポジトリ |
|---|---|---|
| Repository の abstract | `lib/data/repositories/` | `lib/domain/logic/`。実装だけ `data/` |
| モデル | `Task.title` は `String` | `Task.title` は `TaskTitle`。空文字を型で拒否する |
| 完了 | Repository の `updateTask` を ViewModel が呼ぶ | `Task.complete()` のあと Use Case が保存し、履歴を書く |
| 削除 | ViewModel が `TaskRepository.deleteTask` を呼ぶ | `DeleteTaskUseCase` がタスク削除と履歴追加を行う |
| 履歴 | 無い | `Activity` と `ActivityRepository`。画面は件数だけ |
| DI の置き場 | `lib/data/providers/` | 具象の組み立ては `lib/composition_root/` |
| フォルダ名 | `lib/ui/` | `lib/presentation/` |

テンプレートとの差分（意図的）:

| 箇所 | テンプレート | このリポジトリ |
|---|---|---|
| パッケージ | melos の複数パッケージ | 単一パッケージのフォルダ |
| モデル生成 | freezed | 手書き。不変であることは同じ。生成コードでルールを隠さない |
| 失敗の伝え方 | Infrastructure が `DomainException` を投げ、Application が捕まえる | Service の例外を Data が `Result` にする。内側から Presentation へ例外を漏らさない。MVVM サンプルと同じ戻り値にして、比較軸を層に残す |
| デザイン、flavor、多言語、CI | あり | 作らない |

---

## 5. レイヤーとクラス契約

### 5.1 `shared`

`lib/shared/result.dart`

MVVM サンプルの `Result` / `Ok` / `Error` と同じ形。`Exception` を持つ。Domain も Presentation もこれを使ってよい。Flutter には依存しない。

```dart
sealed class Result<T> {
  const Result();
  factory Result.ok(T value) = Ok<T>;
  factory Result.error(Exception error) = Error<T>;
}
```

`CommandState` は Presentation の状態である。`lib/presentation/command_state.dart` に置く。形は MVVM サンプルと同じ不変値。`ChangeNotifier` にはしない。

### 5.2 `domain/model`

`lib/domain/model/task_title.dart`

- `TaskTitle` は識別子を持たない値オブジェクト。同じ文字列なら等しい
- 生成は `TaskTitle.parse(String raw)`。前後の空白を除き、空なら `Result.error`
- 中の文字列は `value` で読む。外から別の文字列でフィールドを書き換えない
- 長さの上限は付けない。拒否するのは空だけである

`lib/domain/model/task.dart`

```dart
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.note,
    required this.isCompleted,
    required this.createdAt,
  });

  final String id;
  final TaskTitle title;
  final String note;
  final bool isCompleted;
  final DateTime createdAt;

  Result<Task> complete();
}
```

- `complete()` は、未完了なら `isCompleted: true` の新しい `Task` を `Ok` で返す。元のインスタンスは変えない
- すでに完了なら `TaskAlreadyCompletedException` を持った `Error` を返す。この例外型は `domain/model` に置く
- `copyWith` は Data 層の組み立て用に置いてよい。完了のルールを迂回する `copyWith(isCompleted: true)` を ViewModel から呼ばない

`lib/domain/model/activity.dart`

```dart
enum ActivityKind { completed, deleted }

class Activity {
  const Activity({
    required this.id,
    required this.taskId,
    required this.kind,
    required this.occurredAt,
  });

  final String id;
  final String taskId;
  final ActivityKind kind;
  final DateTime occurredAt;
}
```

`Activity` に追加の振る舞いを足す必要はない。履歴の「いつ何をしたか」を表すだけである。

freezed / json_serializable は禁止。等価比較がテストで必要なら `==` / `hashCode` を手書きする。

### 5.3 `domain/logic`

ポートは abstract class。実装を import しない。

`lib/domain/logic/task_repository.dart`

```dart
abstract class TaskRepository {
  Future<Result<List<Task>>> getTasks();
  Future<Result<Task>> getTask(String id);
  Future<Result<Task>> createTask({
    required TaskTitle title,
    required String note,
  });
  Future<Result<Task>> updateTask(Task task);
  Future<Result<void>> deleteTask(String id);
}
```

`createTask` は `String title` を受け取らない。空タイトルは `TaskTitle.parse` を通過したあとだけ保存できる。

`lib/domain/logic/activity_repository.dart`

```dart
abstract class ActivityRepository {
  Future<Result<Activity>> append({
    required String taskId,
    required ActivityKind kind,
  });
  Future<Result<int>> count();
}
```

Repository 同士は呼び合わない。

### 5.4 `application`

Use Case は画面状態を持たない。Repository のポートだけに依存する。

`lib/application/complete_task_use_case.dart`

```dart
class CompleteTaskUseCase {
  const CompleteTaskUseCase({
    required this.taskRepository,
    required this.activityRepository,
  });

  Future<Result<CompleteTaskOutcome>> call(String taskId);
}

class CompleteTaskOutcome {
  const CompleteTaskOutcome({required this.task, required this.activityCount});
  final Task task;
  final int activityCount;
}
```

手順:

1. `getTask`
2. `task.complete()`。失敗ならここで返す。どちらも Repository の更新は呼ばない
3. `updateTask` に完了済みの `Task` を渡す
4. 成功したら `ActivityRepository.append(kind: completed)`
5. `count()` を取り、`CompleteTaskOutcome` を返す

タスク更新が失敗したら履歴は書かない。履歴の書き込みが失敗したら `Result.error` を返す。ロールバックはしない。トランザクションは今回の範囲外であり、Use Case は手順の指揮だけを持つ。

`lib/application/delete_task_use_case.dart`

手順:

1. `deleteTask`
2. 成功したら `append(kind: deleted)`
3. `count()` を返す。戻り値は件数だけでよい（`Result<int>`）

削除が失敗したら履歴は書かない。履歴の失敗時もロールバックしない。

一覧取得・追加の Use Case クラスは作らない。

### 5.5 `data`

`lib/data/services/task_api_client.dart`

- 状態（キャッシュ）を持たない
- メモリ + `Future.delayed`（約 300ms）
- `TaskDto` を返す
- 失敗スイッチ `bool shouldFail`。true の間は例外を投げる
- メソッドは MVVM サンプルと同じく fetch / fetch 1件 / create / update / delete
- 起動時にタスクを 3〜5 件入れる
- id の採番はインクリメントなど、追加パッケージ無しで行う

`lib/data/model/task_dto.dart`

- API 形。ドメインとフィールド名をずらす。`note` ↔ `body`、`isCompleted` ↔ `completed`
- `title` は DTO 上は `String`
- `toDomain()` では `TaskTitle.parse` が成功することを前提にして `Task` を作る。シードと保存は空タイトルを入れない
- `TaskDto.fromDomain(Task)` は `title.value` を書く
- 変換は Data 層に閉じる。ViewModel は DTO を見ない

`lib/data/repositories/task_repository_impl.dart`

- `implements TaskRepository`
- DTO 変換とメモリキャッシュ。get 成功後はキャッシュを返す。更新・削除でキャッシュを更新する
- Service の例外はここで `Result.error` にする

`lib/data/services/activity_api_client.dart`

- タスク用とは別のインメモリ。遅延はタスク側と同じ約 300ms でよい
- 失敗スイッチは置かない。失敗経路は Fake でテストする

`lib/data/model/activity_dto.dart`

- ドメインの `kind` を、API 側では `type` という別の名前の文字列または別 enum にしてよい
- 変換は Data 層

`lib/data/repositories/activity_repository_impl.dart`

- `append` 成功でキャッシュに足す
- `count` はキャッシュの件数。未取得なら Service から取り直す

### 5.6 `presentation`

Riverpod:

- `Notifier` + `NotifierProvider.autoDispose`
- 詳細だけ family（`String id`）
- `StateNotifier`、`riverpod_annotation`、`hooks_riverpod` は使わない

| ViewModel | 呼ぶ相手 | State |
|---|---|---|
| `TaskListViewModel` | `TaskRepository.getTasks` のみ | `tasks`, `filter`, `load` |
| `AddTaskViewModel` | `TaskTitle.parse` のあと `TaskRepository.createTask` | `submit` |
| `TaskDetailViewModel` | 取得は 2 つの Repository。完了と削除は Use Case | `task`, `activityCount`, `load`, `toggle`, `delete` |

規則:

- フィルタは getter `filteredTasks`。完了済みリストを別フィールドで持たない
- 追加画面のタイトル文字列は View の `TextEditingController`。`submit` の先頭で `TaskTitle.parse` する。失敗なら Repository を呼ばず `CommandState` の `Error` にする
- 詳細の `load` は `getTask` と `count`。件数表示は `activityCount`
- 完了成功で `task` と `activityCount` を outcome で更新する
- 削除成功の遷移は View の `context.pop`。ViewModel はナビゲーションしない
- `build()` 内で直接 `await` して初期ロードしない。`build()` の末尾で `load()` をスケジュールする。同じ Provider で二重 load しない
- 実行中のコマンドは再実行しない（`CommandState.running` なら return）
- `logging` で成功 / 失敗を log してよい

View:

- `ConsumerWidget` または `ConsumerStatefulWidget`
- Repository、Use Case、ApiClient を引数に取らない。`ref.watch` もしない
- ボタンは ViewModel のメソッドを呼ぶ
- 詳細の `id` は `go_router` の path parameter

`TaskFilter` enum: `all`, `active`, `completed`。Presentation に置く。

### 5.7 `composition_root`

具象クラスを `new` するのはこのフォルダの Provider だけ。

```dart
final taskApiClientProvider = Provider<TaskApiClient>(...);
final activityApiClientProvider = Provider<ActivityApiClient>(...);

final taskRepositoryProvider = Provider<TaskRepository>(...);
final activityRepositoryProvider = Provider<ActivityRepository>(...);

final completeTaskUseCaseProvider = Provider<CompleteTaskUseCase>(...);
final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>(...);
```

- Service と Repository と Use Case はアプリ寿命。`autoDispose` にしない
- 公開する型はポートと Use Case。Provider の型に `TaskRepositoryImpl` を使わない
- ViewModel の Provider は各画面の隣に置く。中で `ref.read` するのは上の Provider だけ
- `lib/main.dart` は `ProviderScope` を付ける
- テストで差し替えるのは `taskRepositoryProvider`、`activityRepositoryProvider`、および Use Case を通す操作では Use Case の Provider

`GoRouter` の定義は `lib/routing/app_router.dart`。Provider は `composition_root` に置き、`MaterialApp.router` に渡す。ルートで ViewModel を new しない。

View が `taskRepositoryProvider` や Use Case Provider を watch / read したら層違反である。

---

## 6. ディレクトリ

```
lib/
  main.dart
  composition_root/
  presentation/
    command_state.dart
    task_list/
      task_list_view_model.dart
      task_list_screen.dart
    add_task/
      add_task_view_model.dart
      add_task_screen.dart
    task_detail/
      task_detail_view_model.dart
      task_detail_screen.dart
  application/
    complete_task_use_case.dart
    delete_task_use_case.dart
  domain/
    model/
      task_title.dart
      task.dart
      activity.dart
    logic/
      task_repository.dart
      activity_repository.dart
  data/
    repositories/
    services/
    model/
  shared/
    result.dart
  routing/
    app_router.dart
test/
  domain/
  application/
  data/
  presentation/
```

Fake は `test/fakes/` に置く。

---

## 7. パッケージ

`pubspec.yaml` に足してよいものだけ:

| パッケージ | 用途 |
|---|---|
| `flutter_riverpod` | 状態管理と DI。`Notifier` API |
| `go_router` | ルーティング |
| `logging` | ViewModel / Repository のログ |
| `mocktail` | 必要なら。基本は手書き Fake |

禁止:

- `provider`（package:provider）
- `hooks_riverpod` / `flutter_hooks`
- `riverpod_annotation` / `riverpod_generator` / `build_runner`
- `freezed` / `json_serializable`
- `flutter_bloc`
- `dio` / `http`
- `shared_preferences`
- `uuid`（採番は Service 内で行う）

テンプレートは同じ不変性を freezed で書いている。このサンプルは手書きにする。

---

## 8. テスト

内側から書く。各テストは一つ外側の具象を使わず、一つ下のポートだけを Fake する。

1. **`TaskTitle`**
   - 空白だけの文字列は `Error`
   - 前後の空白は除いた `value` になる
2. **`Task.complete()`**
   - 未完了なら新しいインスタンスが完了になる。元の `isCompleted` は false のまま
   - 完了済みは `TaskAlreadyCompletedException`
3. **Use Case**（Fake の 2 Repository。Riverpod も Flutter も不要）
   - 完了成功で `updateTask` と `append(completed)` が起きる。戻り値の件数が増える
   - すでに完了ならどちらの更新も呼ばれない
   - タスク更新が失敗したら `append` は呼ばれない
   - 削除成功で `deleteTask` と `append(deleted)` が起きる
4. **Repository**
   - Fake の ApiClient。DTO の `body` / `completed` が `note` / `isCompleted` になる
   - キャッシュ。更新後の get が Service を再度呼ばなくても新しい値になる
5. **ViewModel**（`ProviderContainer` の overrides）
   - 一覧の load 成功と失敗
   - フィルタは `filteredTasks` だけが変わり、Repository の追加呼び出しはない
   - 追加は `TaskRepository.createTask` を呼ぶ。Use Case は無い
   - 空タイトルは Repository を呼ばない
   - 詳細の完了は `CompleteTaskUseCase` を呼ぶ。ViewModel が `updateTask` と `append` を個別に呼ばない
6. **Widget test は一覧 1 画面**
   - スピナーのあとリストが出る
   - エラーのあとリトライできる

Domain と Application のテストファイルは `flutter/material.dart` と `flutter_riverpod` を import しない。
integration_test と golden は作らない。

---

## 9. 手実装の順番

1. `Result`
2. `TaskTitle` と `Task.complete()` と、そのテスト
3. `Activity` と 2 つの Repository ポート
4. `CompleteTaskUseCase` と `DeleteTaskUseCase` と、Fake によるテスト
5. DTO、インメモリ Service、Repository 実装、Repository テスト
6. `composition_root` と `go_router`（空画面）
7. 一覧、追加、詳細
8. 一覧の Widget test と、説明チェック

ある段階のテストが通ってから次へ進む。

---

## 10. 作らないもの

- ログイン、ユーザー、タスク以外の画面
- 履歴の一覧画面
- 永続化、本物の REST、ページング、検索
- 一覧取得・追加・フィルタの Use Case
- パッケージ分割（melos）、デザインシステム、flavor、多言語、CI
- freezed、Riverpod のコード生成
- 完了と履歴追加をまたぐロールバック
- 見た目の作り込み
- Agent によるアプリ本体の実装

---

## 11. 完了時にコードを指して言えること

1. `domain/model` がテンプレートの `domain_model`、`domain/logic` が `domain_logic`、`application` が `application`、`data` が `infrastructure`、`composition_root` が同じ名前の組み立て場所である
2. `TaskTitle.parse` と `Task.complete()` は内側のルールであり、UI も DB も知らない
3. 完了と削除だけが Use Case である。2 つのポートを指揮するからであり、画面があるからではない
4. 一覧・追加・件数取得が Repository 直呼びである理由は、テンプレートが単純な CRUD を Use Case 必須にしていないからである
5. `TaskRepositoryImpl` を Domain が import しない。テストはポートを Fake に差し替える
6. DTO の `body` / `completed` を ViewModel が見ない
7. フィルタが Use Case に無い理由は、表示用の加工だからである
8. テンプレートの freezed、flavor、デザインシステムはこのサンプルに無い。依存の向きを読むこととは別の話題である
