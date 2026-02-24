# git bisect デモ

`git bisect` は、どのコミットでバグが混入したかを二分探索で特定するためのコマンドです。このドキュメントでは、サンプルシナリオを使ってデモを行います。

## シナリオ概要

`src/utils/calculator.ts` の `add` 関数に、いつの間にか「+1 しすぎる」バグが入ってしまったとします。どのコミットでバグが入ったか、`git bisect` で特定します。

## セットアップ

作業ツリーをクリーンな状態にしてから、以下を実行してください。

```bash
./scripts/setup-bisect-demo.sh
```

これにより `bisect-demo` ブランチが作成され、以下のようなコミット履歴が作られます。

| コミット | 内容 | テスト |
|----------|------|--------|
| 1 | add 関数を追加 | - |
| 2 | add のテストを追加 | ✅ |
| 3 | multiply 関数を追加 | ✅ |
| 4 | **★ バグ導入**（add が +1 してしまう） | ❌ |
| 5 | コメントを追加 | ❌ |

**バグが入ったコミット**: 4番目

## デモ手順

### 1. bisect を開始

```bash
git checkout bisect-demo
git bisect start
```

### 2. 良いコミットと悪いコミットを指定

- **bad**: 現在の HEAD（バグあり）
- **good**: バグが入る前のコミット（例: 4つ前）

```bash
git bisect bad                 # 現在の HEAD はバグあり
git bisect good HEAD~4         # 4つ前（コミット1）はバグなし
```

### 3. 各ステップでテストを実行

bisect が自動で中間のコミットにチェックアウトします。各ステップで以下を実行してください。

```bash
npm test
```

- **テスト成功** → `git bisect good`
- **テスト失敗** → `git bisect bad`

### 4. 自動化（オプション）

毎回 `npm test` の結果で good/bad を判断するのは手間なので、次のように自動化できます。

```bash
git bisect start
git bisect bad
git bisect good HEAD~4
git bisect run npm test
```

`git bisect run` は、指定したコマンドの終了コードで good（0）/ bad（非0）を自動判定します。

### 5. 終了

バグを導入したコミットが特定されたら、bisect を終了します。

```bash
git bisect reset
```

## 期待される結果

bisect は「refactor: add の実装を調整」というコミット（4番目）を特定します。このコミットで `add` 関数に誤って `+ 1` が追加されていることがわかります。

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
