"use client";

import { useEffect } from "react";
import Link from "next/link";
import { useAuth } from "@/contexts/AuthContext";

export default function Home() {
  const { user, isLoading } = useAuth();

  if (isLoading) {
    return (
      <main className="min-h-screen flex items-center justify-center">
        <div className="animate-pulse text-gray-500">読み込み中...</div>
      </main>
    );
  }

  return (
    <main className="min-h-screen flex flex-col items-center justify-center p-8 bg-gray-50">
      <h1 className="text-4xl font-bold mb-4 text-gray-900">
        Git Study - Next.js 16 Sample
      </h1>
      <p className="text-lg text-gray-600 mb-8">
        Git workflow勉強会用のサンプルアプリケーション
      </p>

      <div className="flex flex-col sm:flex-row gap-4 items-center">
        {user ? (
          <Link
            href="/dashboard"
            className="px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition"
          >
            ダッシュボードへ ({user.username})
          </Link>
        ) : (
          <Link
            href="/login"
            className="px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition"
          >
            ログイン
          </Link>
        )}
        <a
          href="https://nextjs.org"
          target="_blank"
          rel="noopener noreferrer"
          className="px-6 py-3 bg-gray-200 text-gray-800 font-medium rounded-lg hover:bg-gray-300 transition"
        >
          Next.js ドキュメント
        </a>
      </div>
    </main>
  );
}
