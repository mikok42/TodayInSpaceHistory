#!/usr/bin/env node
/**
 * Compares ios/ vs android/ and asks a Cursor agent to summarize
 * behavioral diffs + produce a concrete parity plan.
 *
 * Usage (from repo root):
 *   CURSOR_API_KEY=... node scripts/plan-platform-parity.mjs [optional focus]
 */
import { writeFileSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { Agent, CursorAgentError } from "@cursor/sdk";

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(__dirname, "..");
const focus = process.argv.slice(2).join(" ").trim();

const apiKey = process.env.CURSOR_API_KEY;
if (!apiKey) {
  console.error("Missing CURSOR_API_KEY. Export it before running this script.");
  process.exit(1);
}

const prompt = `
You are working in the TodayInSpaceHistory monorepo (cwd is the repo root).

Compare the \`ios/\` and \`android/\` apps.

Focus area (if any): ${focus || "(full product parity)"}

Instructions:
1. Inspect both trees. Ignore build-system noise (Xcode vs Gradle).
2. Summarize **behavioral / functional** differences (networking, filtering, image selection, analytics, UI capabilities, errors).
3. Produce a **concrete plan** to bring the lagging side up to parity, with file-level todos.
4. Follow project rules under \`.cursor/rules/\` (especially cross-platform-parity).
5. Output markdown only: Summary of diffs, then Plan with checkboxes.
`.trim();

try {
  const result = await Agent.prompt(prompt, {
    apiKey,
    model: { id: "composer-2.5" },
    local: { cwd: repoRoot },
  });

  if (result.status === "error") {
    console.error("Agent run failed:", result.id ?? result);
    process.exit(2);
  }

  const text =
    typeof result.result === "string"
      ? result.result
      : JSON.stringify(result.result, null, 2);

  console.log(text);
  const outPath = resolve(repoRoot, "parity-plan.md");
  writeFileSync(outPath, text + "\n", "utf8");
  console.error(`\nWrote ${outPath}`);
} catch (err) {
  if (err instanceof CursorAgentError) {
    console.error("Agent startup failed:", err.message, "retryable=", err.isRetryable);
    process.exit(1);
  }
  throw err;
}
