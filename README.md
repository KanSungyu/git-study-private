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

4. GitHubで **develop** へのPull Requestを作成

5. PRが作成されると、GitHub Actionsが自動で以下を実行：
   - 修正ブランチのDockerイメージをビルド
   - Docker Hub (`kansungyu/git-study`) にプッシュ
   - タグはブランチ名をスラッシュ→ハイフンに変換したもの（例: `fix/ui-error` → `fix-ui-error`）

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

### ログイン認証サンプル

簡易ログイン認証のサンプル機能が含まれています。

- **ログインページ**: `/login`
- **ダッシュボード**: `/dashboard`（ログイン後のみアクセス可能）
- **サンプルアカウント**: 上記の表を参照

※ クライアントサイドのモック認証です。本番環境では適切な認証バックエンドを使用してください。

### Dockerで実行

```bash
docker build -t git-study .
docker run -p 3000:3000 git-study
```

## GitHub Actions セットアップ

PR to develop時のDocker image pushには、以下のGitHub Secretsの設定が必要です：

- `DOCKERHUB_USERNAME`: Docker Hubのユーザー名
- `DOCKERHUB_TOKEN`: Docker Hubのアクセストークン（Personal Access Token）

[Docker Hub](https://hub.docker.com/settings/security) でアクセストークンを作成し、GitHubリポジトリの Settings → Secrets and variables → Actions に追加してください。
