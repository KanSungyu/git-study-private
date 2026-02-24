#!/bin/bash
# git bisect デモ用のシナリオを作成するスクリプト
# ログイン画面の「不正なパスワードでもログインできてしまう」バグを題材にします
# 実行後、docs/bisect-demo.md の手順で bisect を試せます

set -e
cd "$(dirname "$0")/.."

if [ -n "$(git status --porcelain)" ]; then
  echo "エラー: 作業ツリーがクリーンではありません。変更をコミットまたは stash してください。"
  exit 1
fi

if git show-ref --verify --quiet refs/heads/bisect-demo; then
  echo "エラー: bisect-demo ブランチが既に存在します。削除してから再実行してください:"
  echo "  git branch -D bisect-demo"
  exit 1
fi

echo "bisect-demo ブランチを作成し、ログイン不正バグのデモ用履歴を構築します..."

# ブランチ作成
git checkout -b bisect-demo

# コミット1: 認証のテストを追加
# ※ 親ブランチと同一だと commit できないため、コメントを追加
cat > src/lib/auth.test.ts << 'EOF'
import { describe, it, expect } from "vitest";
import { validateCredentials } from "./auth";

// bisect デモ用
describe("validateCredentials", () => {
  it("正しいパスワードではログインできる", () => {
    const user = validateCredentials("admin", "password123");
    expect(user).not.toBeNull();
    expect(user?.username).toBe("admin");
  });

  it("間違ったパスワードではログインできない", () => {
    const user = validateCredentials("admin", "wrongpassword");
    expect(user).toBeNull();
  });

  it("存在しないユーザーではログインできない", () => {
    const user = validateCredentials("unknown", "anything");
    expect(user).toBeNull();
  });
});
EOF
git add src/lib/auth.test.ts
git commit -m "test: 認証のテストを追加"

# コミット2: コメント追加（まだバグなし）
# ※ 親ブランチと内容が同じだと commit できないため、説明コメントを追加
cat > src/lib/auth.ts << 'EOF'
/**
 * サンプル用の簡易認証ユーティリティ
 * 本番環境では適切な認証バックエンドを使用してください
 * (bisect デモ用コミット2)
 */

const AUTH_STORAGE_KEY = "git-study-auth";

export interface User {
  username: string;
  email: string;
}

// サンプル用の認証情報（本番では使用しないこと）
const MOCK_USERS: Record<string, { password: string; email: string }> = {
  admin: { password: "password123", email: "admin@example.com" },
  user: { password: "user1234", email: "user@example.com" },
};

export function validateCredentials(
  username: string,
  password: string
): User | null {
  const user = MOCK_USERS[username.toLowerCase()];
  if (user && user.password === password) {
    return { username: username.toLowerCase(), email: user.email };
  }
  return null;
}

export function getStoredUser(): User | null {
  if (typeof window === "undefined") return null;
  try {
    const stored = localStorage.getItem(AUTH_STORAGE_KEY);
    return stored ? (JSON.parse(stored) as User) : null;
  } catch {
    return null;
  }
}

export function storeUser(user: User): void {
  if (typeof window === "undefined") return;
  localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(user));
}

export function clearUser(): void {
  if (typeof window === "undefined") return;
  localStorage.removeItem(AUTH_STORAGE_KEY);
}
EOF
git add src/lib/auth.ts
git commit -m "docs: 認証モジュールにコメントを追加"

# コミット3: ★ バグ導入（パスワードチェックを誤って削除 → 不正ログイン可能に）
cat > src/lib/auth.ts << 'EOF'
/**
 * サンプル用の簡易認証ユーティリティ
 * 本番環境では適切な認証バックエンドを使用してください
 */

const AUTH_STORAGE_KEY = "git-study-auth";

export interface User {
  username: string;
  email: string;
}

// サンプル用の認証情報（本番では使用しないこと）
const MOCK_USERS: Record<string, { password: string; email: string }> = {
  admin: { password: "password123", email: "admin@example.com" },
  user: { password: "user1234", email: "user@example.com" },
};

export function validateCredentials(
  username: string,
  password: string
): User | null {
  const user = MOCK_USERS[username.toLowerCase()];
  // ← バグ: パスワードチェックを誤って削除。どんなパスワードでもログインできてしまう
  if (user) {
    return { username: username.toLowerCase(), email: user.email };
  }
  return null;
}

export function getStoredUser(): User | null {
  if (typeof window === "undefined") return null;
  try {
    const stored = localStorage.getItem(AUTH_STORAGE_KEY);
    return stored ? (JSON.parse(stored) as User) : null;
  } catch {
    return null;
  }
}

export function storeUser(user: User): void {
  if (typeof window === "undefined") return;
  localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(user));
}

export function clearUser(): void {
  if (typeof window === "undefined") return;
  localStorage.removeItem(AUTH_STORAGE_KEY);
}
EOF
git add src/lib/auth.ts
git commit -m "refactor: 認証ロジックを簡素化"

# コミット4: 別の変更（バグはそのまま）
cat > src/lib/auth.ts << 'EOF'
/**
 * サンプル用の簡易認証ユーティリティ
 * 本番環境では適切な認証バックエンドを使用してください
 * Git bisect デモ用のサンプルモジュール
 */

const AUTH_STORAGE_KEY = "git-study-auth";

export interface User {
  username: string;
  email: string;
}

// サンプル用の認証情報（本番では使用しないこと）
const MOCK_USERS: Record<string, { password: string; email: string }> = {
  admin: { password: "password123", email: "admin@example.com" },
  user: { password: "user1234", email: "user@example.com" },
};

export function validateCredentials(
  username: string,
  password: string
): User | null {
  const user = MOCK_USERS[username.toLowerCase()];
  // ← バグ: パスワードチェックを誤って削除。どんなパスワードでもログインできてしまう
  if (user) {
    return { username: username.toLowerCase(), email: user.email };
  }
  return null;
}

export function getStoredUser(): User | null {
  if (typeof window === "undefined") return null;
  try {
    const stored = localStorage.getItem(AUTH_STORAGE_KEY);
    return stored ? (JSON.parse(stored) as User) : null;
  } catch {
    return null;
  }
}

export function storeUser(user: User): void {
  if (typeof window === "undefined") return;
  localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(user));
}

export function clearUser(): void {
  if (typeof window === "undefined") return;
  localStorage.removeItem(AUTH_STORAGE_KEY);
}
EOF
git add src/lib/auth.ts
git commit -m "docs: モジュール説明を追加"

echo ""
echo "✅ セットアップ完了！"
echo ""
echo "【動作確認】"
if grep -q "user.password === password" src/lib/auth.ts; then
  echo "⚠️ 警告: auth.ts にパスワードチェックが含まれています。想定と異なります。"
else
  echo "✓ バグありの実装です。admin / wrongpassword でログインできるはずです。"
  echo "  npm run dev を起動し、http://localhost:3000/login で確認してください。"
  echo "  ※ 既に dev サーバーが動いている場合は再起動してください。"
fi
echo ""
echo "【GUIで確認する方法】"
echo "  npm run dev で起動し、http://localhost:3000/login にアクセス"
echo "  - 良いコミット: admin / wrongpassword → エラー表示（正しい動作）"
echo "  - 悪いコミット: admin / wrongpassword → ログイン成功してしまう（バグ）"
echo ""
echo "【bisect を開始】"
echo "  git bisect start"
echo "  git bisect bad                 # 現在の HEAD はバグあり"
echo "  git bisect good HEAD~3         # 3つ前のコミットはバグなし"
echo "  git bisect run npm test        # 自動で bisect"
echo ""
echo "詳細は docs/bisect-demo.md を参照してください。"
