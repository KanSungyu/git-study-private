export default function Home() {
  return (
    <main className="min-h-screen flex flex-col items-center justify-center p-8">
      <h1 className="text-4xl font-bold mb-4">
        Git Study - Next.js 16 Sample
      </h1>
      <p className="text-lg text-gray-600 mb-8">
        Git workflow勉強会用のサンプルアプリケーション
      </p>
      <div className="flex gap-4">
        <a
          href="https://nextjs.org"
          target="_blank"
          rel="noopener noreferrer"
          className="px-4 py-2 bg-black text-white rounded-lg hover:bg-gray-800 transition"
        >
          Next.js ドキュメント
        </a>
      </div>
    </main>
  );
}
