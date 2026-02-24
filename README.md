# Git Study - Git Workflow 勉強会

Git workflow勉強会用のリポジトリです。Next.js 16のサンプルアプリケーションを含みます。

## サンプルアカウント

ログイン認証の動作確認用に以下のアカウントが利用できます。

| ユーザー名 | パスワード |
|-----------|-----------|
| admin | password123 |
| user | user1234 |

## ブランチ構成

- **main**: 本番用メインブランチ
- **develop**: 開発用ブランチ

## 開発ワークフロー

1. **main** から修正用ブランチをチェックアウト
   ```bash
   git checkout main
   git pull origin main
   git checkout -b fix/your-feature-name
   ```

2. ローカルで開発を進める

3. 実装が完了したら **develop** にプッシュ
   ```bash
   git add .
   git commit -m "feat: 実装内容"
   git push origin fix/your-feature-name
   ```

4. GitHubで **develop** へのPull Requestを作成（`.github/PULL_REQUEST_TEMPLATE.md` のテンプレートが表示されます）

5. PRが作成されると、`pr-checks.yml` が実行：
   - **1. Body check**（必須項目）→ 失敗すると以降は実行されない
   - **2. Conventional Commits** チェック
   - **3. Docker ビルド**（develop への PR 時）：ブランチ名タグで Docker Hub にプッシュ

6. **develop にマージ**されると、`docker-build-push.yml` が `kansungyu/git-study:stg` タグでイメージをビルド・プッシュ

7. **main への PR** 時は、Body check 通過後に `green` タグでイメージをビルド（Blue/Green 検証環境用）

### GitHub Actions（workflow一覧）

| ファイル | 用途 |
|----------|------|
| `pr-checks.yml` | **PR 時・真っ先に実行**。Body check → Conventional Commits チェックのみ（チェック専用） |
| `docker-build-push.yml` | develop への **push**（マージ時）= stg タグ。**PR Checks 通過後**の develop への PR = ブランチ名タグ |
| `docker-green.yml` | **PR Checks 通過後**の main への PR 時のみ、`green` タグでビルド |
| `release-please.yml` | main への push 時に [release-please](https://github.com/googleapis/release-please) が Release PR を作成。マージでタグ・GitHub Release を自動作成 |

> PR Checks が失敗すると、Docker ビルド（docker-build-push, docker-green）は実行されません（`workflow_run` で連携）

### リリースフロー（release-please）

1. develop を main にマージ（feat/fix コミットを含む）
2. release-please が Release PR（例: `chore(main): release 1.1.0`）を自動作成
3. Release PR をマージすると、タグと GitHub Release が作成される

**バージョンルール（SemVer）**: fix=patch, feat=minor, BREAKING CHANGE=major

PR タイトルは `feat: 説明` や `fix(auth): 説明` のような形式にしてください。

## セットアップ

### 必要な環境

- Node.js 20.9以上
- npm または pnpm

### ローカル開発

```bash
npm install
npm run dev
```

http://localhost:3000 でアプリケーションが起動します。

### ユニットテスト

```bash
# テストを1回実行
npm test

# ウォッチモード（ファイル変更時に自動再実行）
npm run test:watch

# カバレッジ付きで実行
npm run test:coverage
```

**push 前に自動でテスト実行**: [husky](https://typicode.github.io/husky/) の pre-push フックで、`git push` の直前に `npm test` が自動実行されます。テストが失敗すると push はブロックされます。

> フックが動かない場合: `npm install` または `npm run prepare` を実行して husky を初期化してください。`core.hooksPath` が `.husky/_` に設定されます。

### Dockerで実行

```bash
docker build -t git-study .
docker run -p 3000:3000 git-study
```

## GitHub Actions セットアップ

PR to develop時のDocker image pushで「Username and password required」エラーが出る場合、以下の手順でGitHub Secretsを設定してください。

### 1. Docker Hub でアクセストークンを作成

1. [Docker Hub](https://hub.docker.com/) にログイン
2. 右上のアカウントメニュー → **Account Settings** → **Security** → **New Access Token**
3. トークン名（例: `github-actions`）を入力し、**Read & Write** 権限で作成
4. 表示されたトークンをコピー（再表示できないため、この時点で控えておく）

> ⚠️ **注意**: `DOCKERHUB_TOKEN` には **パスワードではなくアクセストークン** を使用してください。

### 2. GitHub に Secrets を追加

1. リポジトリの **Settings** → **Secrets and variables** → **Actions**
2. **New repository secret** をクリック
3. 以下を追加：

| Secret 名 | 値 |
|-----------|-----|
| `DOCKERHUB_TOKEN` | 上記で作成したアクセストークン |

※ ユーザー名（`kansungyu`）は workflow 内で指定済みのため、Secrets への登録は不要です。

### 3. フォークからの PR について

**同じリポジトリ内のブランチ**からの PR では Secrets が利用されますが、**フォーク（他リポジトリ）からの PR** ではセキュリティのため Secrets が渡されません。その場合、この workflow の Docker push は失敗します。フォークからの PR を想定する場合は、workflow のトリガーを `push` に変更するなどの対応が必要です。
