import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Git Study - Next.js Sample",
  description: "Git workflow勉強会用のNext.jsサンプルアプリ",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ja">
      <body className="antialiased">{children}</body>
    </html>
  );
}
