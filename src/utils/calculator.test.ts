import { describe, it, expect } from "vitest";
import { add, multiply } from "./calculator";

describe("calculator", () => {
  describe("add", () => {
    it("2つの数を正しく足し算する", () => {
      expect(add(2, 3)).toBe(5);
      expect(add(0, 0)).toBe(0);
      expect(add(-1, 1)).toBe(0);
    });
  });

  describe("multiply", () => {
    it("2つの数を正しく掛け算する", () => {
      expect(multiply(2, 3)).toBe(6);
      expect(multiply(0, 100)).toBe(0);
    });
  });
});
