# flutter_clean_architecture_sample

Clean Architecture を自分なりの解釈で実装したリポジトリです。画面は [flutter_mvvm_sample](https://github.com/yukimiyake0607/flutter_mvvm_sample) の Task Inbox と同じにし、層の置き方の違いを比較します。

## 依存性逆転

素直に書くと内側が外側の具象クラスをimportすることになりますが、Clean Architectureでは依存が外を向くのを規則違反としているので、依存は常に内側を向くようにします。<br>
抽象クラス（abstract）をポートとして置き、外側がabstractを実装します。そうすることで、外側は内側の約束に合わせることができ依存方向は内側を向くようになります。（依存性逆転）<br>

ここに実際にこのリポジトリで実装している依存性逆転の例を載せる。
