import { describe, it, expect } from "vitest";
import { validateCredentials } from "./auth";

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
