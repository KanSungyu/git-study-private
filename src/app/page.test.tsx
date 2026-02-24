import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import Home from "./page";

describe("Home", () => {
  it("タイトルが表示される", () => {
    render(<Home />);
    expect(
      screen.getByRole("heading", { name: /Git Study - Next.js 16 Sample/i })
    ).toBeInTheDocument();
  });

  it("説明文が表示される", () => {
    render(<Home />);
    expect(
      screen.getByText(/Git workflow勉強会用のサンプルアプリケーション/)
    ).toBeInTheDocument();
  });

  it("Next.jsドキュメントへのリンクが表示される", () => {
    render(<Home />);
    const link = screen.getByRole("link", { name: /Next.js ドキュメント/i });
    expect(link).toBeInTheDocument();
    expect(link).toHaveAttribute("href", "https://nextjs.org");
    expect(link).toHaveAttribute("target", "_blank");
  });

  it("main要素が存在する", () => {
    render(<Home />);
    expect(screen.getByRole("main")).toBeInTheDocument();
  });
});
