# Agent instructions

All project rules for agents live in **one place**:

[`.cursor/rules/`](.cursor/rules/)

Do not duplicate policy here. Read and follow every rule under that directory (especially `ios-first.mdc`, `cross-platform-parity.mdc`, and `no-static-helpers.mdc`).

To compare platforms and plan sync work:

```bash
CURSOR_API_KEY=... node scripts/plan-platform-parity.mjs
```
