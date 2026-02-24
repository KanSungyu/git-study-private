"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { useAuth } from "@/contexts/AuthContext";

export default function DashboardPage() {
  const { user, isLoading, logout } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!isLoading && !user) {
      router.push("/login");
    }
  }, [user, isLoading, router]);

  const handleLogout = () => {
    logout();
    router.push("/login");
    router.refresh();
  };

  if (isLoading || !user) {
    return (
      <main className="min-h-screen flex items-center justify-center">
        <div className="animate-pulse text-gray-500">読み込み中...</div>
      </main>
    );
  }

  return (
    <main className="min-h-screen bg-gray-50">
      <header className="bg-white border-b border-gray-200">
        <div className="max-w-4xl mx-auto px-4 py-4 flex justify-between items-center">
          <h1 className="text-xl font-bold text-gray-900">Git Study</h1>
          <div className="flex items-center gap-4">
            <span className="text-sm text-gray-600">
              {user.username} ({user.email})
            </span>
            <button
              onClick={handleLogout}
              className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition"
            >
              ログアウト
            </button>
          </div>
        </div>
      </header>

      <div className="max-w-4xl mx-auto px-4 py-12">
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-8">
          <h2 className="text-2xl font-bold text-gray-900 mb-2">
            ようこそ、{user.username} さん！
          </h2>
          <p className="text-gray-600 mb-8">
            ログイン認証が成功しました。これはサンプルアプリケーションのダッシュボードです。
          </p>

          <div className="grid gap-4 sm:grid-cols-2">
            <div className="p-4 rounded-xl bg-blue-50 border border-blue-100">
              <h3 className="font-semibold text-blue-900 mb-1">ユーザー情報</h3>
              <p className="text-sm text-blue-700">
                ユーザー名: {user.username}
                <br />
                メール: {user.email}
              </p>
            </div>
            <div className="p-4 rounded-xl bg-green-50 border border-green-100">
              <h3 className="font-semibold text-green-900 mb-1">認証状態</h3>
              <p className="text-sm text-green-700">
                認証済み ✓
                <br />
                localStorage でセッションを保持
              </p>
            </div>
          </div>

          <div className="mt-8 pt-8 border-t border-gray-100">
            <Link
              href="/"
              className="text-blue-600 hover:text-blue-700 text-sm font-medium"
            >
              ← トップページへ
            </Link>
          </div>
        </div>
      </div>
    </main>
  );
}
