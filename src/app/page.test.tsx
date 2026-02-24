import React from "react";
import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { AuthProvider } from "@/contexts/AuthContext";
import Home from "./page";

const renderWithAuth = (ui: React.ReactElement) =>
  render(<AuthProvider>{ui}</AuthProvider>);

describe("Home", () => {
  it("タイトルが表示される", () => {
    renderWithAuth(<Home />);
    expect(
      screen.getByRole("heading", { name: /Git Study - Next.js 16 Sample/i })
    ).toBeInTheDocument();
  });

  it("説明文が表示される", () => {
    renderWithAuth(<Home />);
    expect(
      screen.getByText(/Git workflow勉強会用のサンプルアプリケーション/)
    ).toBeInTheDocument();
  });

  it("Next.jsドキュメントへのリンクが表示される", () => {
    renderWithAuth(<Home />);
    const link = screen.getByRole("link", { name: /Next.js ドキュメント/i });
    expect(link).toBeInTheDocument();
    expect(link).toHaveAttribute("href", "https://nextjs.org");
    expect(link).toHaveAttribute("target", "_blank");
  });

  it("main要素が存在する", () => {
    renderWithAuth(<Home />);
    expect(screen.getByRole("main")).toBeInTheDocument();
  });
});
