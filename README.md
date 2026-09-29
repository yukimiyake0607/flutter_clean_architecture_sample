# flutter_clean_architecture_sample

Clean Architecture を自分なりの解釈で実装したリポジトリです。画面は [flutter_mvvm_sample](https://github.com/yukimiyake0607/flutter_mvvm_sample) の Task Inbox と同じにし、層の置き方の違いを比較します。

## 依存性逆転

素直に書くと内側が外側の具象クラスをimportすることになりますが、Clean Architectureでは依存が外を向くのを規則違反としているので、依存は常に内側を向くようにします。<br>
抽象クラス（abstract）をポートとして置き、外側がabstractを実装します。そうすることで、外側は内側の約束に合わせることができ依存方向は内側を向くようになります。（依存性逆転）<br>

ここに実際にこのリポジトリで実装している依存性逆転の例を載せる。

## ディレクトリ構造

```text
lib/
  main.dart                          # 起動入口。層の組み立てはまだしない
  domain/
    model/                           # Entities
      task_title.dart                # 空タイトルを拒否する値オブジェクト
      task.dart                      # 1件のタスクの完了ルールを持つ Entity
      activity.dart                  # 操作履歴の記録。ルールのメソッドは持たない
    logic/                           # Use Case より内側のポート
      task_repository.dart           # タスクの取得と保存を頼めるポート
      activity_repository.dart       # 履歴の追加と件数取得を頼めるポート
  shared/
    result.dart                      # 層に属さない。成功か失敗かを返す共通の型
test/
  domain/                            # Entities のテスト
```

これから置くフォルダは、`application/` が Application Business Rules、`presentation/` が Interface Adapters、`data/` が Frameworks & Drivers とその変換、`composition_root/` が外側で実装を組み立てる場所です。