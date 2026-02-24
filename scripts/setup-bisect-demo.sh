#!/bin/bash
# git bisect デモ用のシナリオを作成するスクリプト
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

echo "bisect-demo ブランチを作成し、デモ用のコミット履歴を構築します..."

# ブランチ作成
git checkout -b bisect-demo

# コミット1: add 関数のみ（正しい実装）
mkdir -p src/utils
cat > src/utils/calculator.ts << 'EOF'
/**
 * シンプルな計算ユーティリティ（git bisect デモ用）
 */
export function add(a: number, b: number): number {
  return a + b;
}
EOF
git add src/utils/calculator.ts
git commit -m "feat: add 関数を追加"

# コミット2: テスト追加
cat > src/utils/calculator.test.ts << 'EOF'
import { describe, it, expect } from "vitest";
import { add } from "./calculator";

describe("calculator", () => {
  describe("add", () => {
    it("2つの数を正しく足し算する", () => {
      expect(add(2, 3)).toBe(5);
      expect(add(0, 0)).toBe(0);
      expect(add(-1, 1)).toBe(0);
    });
  });
});
EOF
git add src/utils/calculator.test.ts
git commit -m "test: add のテストを追加"

# コミット3: multiply 関数追加（まだバグなし）
cat > src/utils/calculator.ts << 'EOF'
/**
 * シンプルな計算ユーティリティ（git bisect デモ用）
 */
export function add(a: number, b: number): number {
  return a + b;
}

export function multiply(a: number, b: number): number {
  return a * b;
}
EOF
git add src/utils/calculator.ts
git commit -m "feat: multiply 関数を追加"

# コミット4: ★ バグ導入（add が +1 してしまう）
cat > src/utils/calculator.ts << 'EOF'
/**
 * シンプルな計算ユーティリティ（git bisect デモ用）
 */
export function add(a: number, b: number): number {
  return a + b + 1;  // ← バグ: 誤って +1 している
}

export function multiply(a: number, b: number): number {
  return a * b;
}
EOF
git add src/utils/calculator.ts
git commit -m "refactor: add の実装を調整"

# コミット5: 別の変更（バグはそのまま）
cat > src/utils/calculator.ts << 'EOF'
/**
 * シンプルな計算ユーティリティ（git bisect デモ用）
 * 四則演算の基本機能を提供
 */
export function add(a: number, b: number): number {
  return a + b + 1;  // ← バグ: 誤って +1 している
}

export function multiply(a: number, b: number): number {
  return a * b;
}
EOF
git add src/utils/calculator.ts
git commit -m "docs: コメントを追加"

echo ""
echo "✅ セットアップ完了！"
echo ""
echo "次のコマンドで git bisect デモを開始できます:"
echo "  git bisect start"
echo "  git bisect bad                 # 現在の HEAD はバグあり"
echo "  git bisect good HEAD~4         # 4つ前のコミットはバグなし"
echo "  npm test                       # 各ステップで実行し、結果に応じて good/bad を入力"
echo ""
echo "詳細は docs/bisect-demo.md を参照してください。"
