# git bisect デモ

`git bisect` は、どのコミットでバグが混入したかを二分探索で特定するためのコマンドです。このデモでは、**ログイン画面で不正なパスワードでもログインできてしまう**セキュリティバグを題材にします。

## シナリオ概要

いつの間にか、間違ったパスワードを入力してもログインできてしまうバグが入ってしまいました。どのコミットでバグが入ったか、`git bisect` で特定します。

**GUI で確認できる**: `npm run dev` で起動し、ログイン画面で `admin` / `wrongpassword` を入力すると、バグがあるコミットではダッシュボードに遷移してしまいます。

## セットアップ

作業ツリーをクリーンな状態にしてから、以下を実行してください。

```bash
# bisect-demo が既にある場合は削除してから実行
git branch -D bisect-demo
./scripts/setup-bisect-demo.sh
```

> ⚠️ **重要**: 既存の `bisect-demo` ブランチがあると、スクリプトは実行されません。以前デモしたことがある場合は `git branch -D bisect-demo` で削除してから再実行してください。

これにより `bisect-demo` ブランチが作成され、以下のようなコミット履歴が作られます。

| コミット | 内容 | テスト | ログイン動作 |
|----------|------|--------|--------------|
| 1 | 認証のテストを追加 | ✅ | 正しい |
| 2 | コメントを追加 | ✅ | 正しい |
| 3 | **★ バグ導入**（パスワードチェック削除） | ❌ | 不正ログイン可能 |
| 4 | モジュール説明を追加 | ❌ | 不正ログイン可能 |

**バグが入ったコミット**: 3番目（refactor: 認証ロジックを簡素化）

## GUI で動作確認

勉強会でデモする際は、bisect の各ステップでブラウザで確認すると分かりやすいです。

```bash
npm run dev
# http://localhost:3000/login にアクセス
```

- **良いコミット**: `admin` / `wrongpassword` → 「ユーザー名またはパスワードが正しくありません」と表示
- **悪いコミット**: `admin` / `wrongpassword` → ログイン成功し、ダッシュボードに遷移してしまう

## デモ手順

### 1. bisect を開始

```bash
git checkout bisect-demo
git bisect start
```

### 2. 良いコミットと悪いコミットを指定

- **bad**: 現在の HEAD（バグあり）
- **good**: バグが入る前のコミット（3つ前）

```bash
git bisect bad                 # 現在の HEAD はバグあり
git bisect good HEAD~3         # 3つ前のコミットはバグなし
```

### 3. 各ステップでテストを実行

bisect が自動で中間のコミットにチェックアウトします。各ステップで以下を実行してください。

```bash
npm test
```

- **テスト成功** → `git bisect good`
- **テスト失敗** → `git bisect bad`

### 4. 自動化（推奨）

```bash
git bisect start
git bisect bad
git bisect good HEAD~3
git bisect run npm test
```

`git bisect run` は、指定したコマンドの終了コードで good（0）/ bad（非0）を自動判定します。

### 5. 終了

バグを導入したコミットが特定されたら、bisect を終了します。

```bash
git bisect reset
```

## 期待される結果

bisect は「refactor: 認証ロジックを簡素化」というコミット（3番目）を特定します。このコミットで `validateCredentials` からパスワードチェックが誤って削除され、どんなパスワードでもログインできてしまう状態になっています。

## 元のブランチに戻る

```bash
git bisect reset
git checkout main   # または develop
git branch -D bisect-demo   # デモ用ブランチを削除
```

## 再度デモを行う場合

勉強会などで何度もデモする場合は、以下で毎回クリーンな状態からやり直せます。

```bash
git bisect reset                    # bisect 中なら終了
git checkout main                   # 元のブランチに戻る
git branch -D bisect-demo           # デモ用ブランチを削除
./scripts/setup-bisect-demo.sh     # 再度セットアップ
```
