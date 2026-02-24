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
