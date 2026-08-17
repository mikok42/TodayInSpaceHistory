# Portfolio review summary (2026-08-09)

Honest mid-level hiring-bar take for the **Today In Space History** monorepo (`ios/` + `android/`).  
Return here tomorrow for fixes.

## Verdict

Solid, readable cross-platform sample with intentional seams and modern stacks — **not** a “recruiter loses their mind” portfolio nuke.  
Rough scores: **iOS ~6–6.5/10**, **Android ~6/10**, **monorepo story ~7/10** (process/agents/CI).  
Signals “knows the vocabulary and can port cleanly,” not yet “ships production-minded apps with proof.”

## What’s good

- Clear seams both sides: NetworkClient → ImageProvider → ViewModel → UI + thin Coordinator + AnalyticsTimer + Errors
- Modern UI/data: SwiftUI + `@Observable` + async; Compose + StateFlow + Ktor + Coil; Firebase `downloading` / `duration_ms`
- Product logic present: English NASA month query (Android), anniversary filter, random + fallback, large/medium/original pick, HTML decode
- Monorepo hygiene: parity rules, `ios-first`, parity script, Firebase App Distribution workflow
- Injectable protocols/interfaces with default concretes (testable *in theory*)

## What’s weak (priority)

| Pri | Issue | Where |
|-----|--------|--------|
| P0 | **No tests** (unit/UI) | both platforms |
| P0 | **Errors silent** — only print/Log, no UI error/empty state | ViewModels + Main screens |
| P0 | **`http` → `https` rewrite bugs** (`httpss://` on already-https URLs) | ImageProvider both sides |
| P1 | **iOS NASA month may use device locale** (PL month names break query) | iOS `DateExtension` / Endpoints |
| P1 | **Coordinator is ceremonial** for one screen | both Coordinators |
| P1 | **iOS ignores HTTP status** on URLSession | `NetworkClient.swift` |
| P1 | **Android AGP 9 half-migrated** (`builtInKotlin=false`, `newDsl=false`, suppress leftovers) | `gradle.properties` / AGP 9.3.x |
| P2 | Dead/empty files, leftover headers, unused endpoints/HttpMethod | iOS `Collection`/`Links`, Android stubs |
| P2 | No cancel/coalesce on rapid refresh | both ViewModels |
| P2 | Weak ship polish (debug signing for release CI, stock Android icon) | CI / Android manifest |

## What a sharp interviewer will ask

- “What happens offline / on API failure?” → today: blank UI + log
- “Where are the tests for anniversary filter / URL pick?” → nowhere
- “Why Coordinator for one screen?” → need a better answer or delete it
- “Show me the https rewrite” → they will spot `httpss` in under a minute
- Android: “Did you choose AGP 9 on purpose?” → looks Studio-upgrade-then-silence

## Top 3 for tomorrow (highest hiring-signal ROI)

1. **Tests** for ImageProvider (anniversary + fallback + href) + URL preference + decoding; fix `http://`→`https://` properly (both platforms, ios-first then port after commit).
2. **Error / empty UI** + optional cancel in-flight refresh.
3. **Cleanup judgment**: fix iOS locale for NASA query; either finish or deliberately pin AGP story; drop or justify ceremonial Coordinator / dead files.

## Process reminder

Per `ios-first.mdc`: implement on **iOS first**, port to Android **after commit** (or explicit ask).
