---
name: migrate
description: Plans and executes an iOS-to-Android parity port in the TodayInSpaceHistory monorepo. Detects iOS commits not yet reflected in android/, writes a file-level migration plan, applies it, and verifies with Gradle. Use when the user asks to migrate, port, or sync iOS changes to Android, or to check what parity work is outstanding.
disable-model-invocation: true
---

# Migrate iOS changes to Android

Ports committed `ios/` work to `android/` per [cross-platform-parity](../../rules/cross-platform-parity.mdc) and [ios-first](../../rules/ios-first.mdc).

## Workflow

Copy this checklist and track progress:

```
- [ ] 1. Detect unported iOS commits
- [ ] 2. Map changes to Android seams
- [ ] 3. Write the plan
- [ ] 4. Apply the port
- [ ] 5. Verify with Gradle
- [ ] 6. Commit
```

### 1. Detect unported iOS commits

```bash
LAST_ANDROID=$(git log -1 --format=%H -- android/)
git log --oneline "$LAST_ANDROID"..HEAD -- ios/
git diff --stat "$LAST_ANDROID"..HEAD -- ios/
```

This is a heuristic, not proof. Confirm by reading the paired files in the seam table below: a commit may have already been ported by hand, and a shared contract may have drifted without any recent commit.

Only port work that is **already committed on iOS**. If `git status` shows uncommitted `ios/` changes, stop and tell the user, per `ios-first`.

### 2. Map changes to Android seams

| Concern | iOS | Android |
|---|---|---|
| Networking | `Tools/NetworkClient.swift` | `data/network/NetworkClient.kt` |
| Endpoints | `Tools/Endpoints.swift` | `data/network/Endpoints.kt` |
| API constants | `Tools/APIConstants.swift` | `data/network/ApiConstants.kt` |
| Models | `DataModels/APIResponse.swift` | `data/model/ApiResponse.kt` |
| Errors | `DataModels/Errors.swift` | `data/Errors.kt` |
| Image provider | `DataModels/ImageProviderService.swift` | `data/ImageProviderService.kt` |
| UI test stub | `Tools/UITestStubImageProvider.swift` | `data/UITestStubImageProvider.kt` |
| View model | `Views/MainViewViewModel.swift` | `ui/main/MainViewModel.kt` |
| Screen | `Views/MainView.swift` | `ui/main/MainScreen.kt` |
| Subviews | `Views/Subviews/*.swift` | `ui/subviews/*.kt` |
| Style constants | `Tools/StyleConstants.swift` | `util/StyleConstants.kt` |
| Accessibility ids | `Tools/AccessibilityIdentifiers.swift` | `util/AccessibilityIdentifiers.kt` |
| Analytics | `Tools/Analytics.swift` | `util/AnalyticsTimer.kt` |
| String extensions | `Tools/String+Extensions.swift` | `util/StringExtensions.kt` |
| Date extensions | `Tools/DateExtension.swift` | `util/DateExtensions.kt` |
| Coordinator | `Tools/MainCoordinator.swift` | `coordinator/MainCoordinator.kt` |
| Unit tests | `TodayInSpaceHistoryTests/` | `app/src/test/java/miko/todayinspacehistory/` |
| UI tests | `TodayInSpaceHistoryUITests/` | `app/src/androidTest/java/miko/todayinspacehistory/` |

iOS roots at `ios/TodayInSpaceHistory/`, Android at `android/app/src/main/java/miko/todayinspacehistory/`.

Keep names aligned across the seam: a new `Photo.swift` becomes `Photo.kt`, `unacceptableStatusCode` becomes `UnacceptableStatusCode`.

### 3. Write the plan

State, per change: the iOS source, the Android target file, and whether it is behavior, UI, or test. Call out anything you intend **not** to port, with the reason. The parity rule demands either a matching change or an explicit note.

### 4. Apply the port

Translate idioms rather than transliterating code:

| iOS | Android |
|---|---|
| SwiftUI `View` struct | `@Composable fun` taking `modifier: Modifier = Modifier` |
| `#Preview` | `@Preview @Composable private fun` |
| Kingfisher `KFImage` | Coil `AsyncImage` |
| `.clipShape(RoundedRectangle(cornerRadius: N))` | `Modifier.clip(RoundedCornerShape(N.dp))` |
| `.scaledToFill()` | `ContentScale.Crop` |
| `.accessibilityIdentifier` | `Modifier.testTag` |
| `@Observable` + `@State` | `StateFlow` + `collectAsStateWithLifecycle` |
| protocol + default concrete | interface + `Impl` class with a default constructor argument |
| XCTest | JUnit4 (`runTest`, `org.junit.Assert`) |
| `URLProtocol` stub | Ktor `MockEngine` |

A SwiftUI view that carries no styling maps to a composable that takes a `modifier` and applies no size, shape, or clipping of its own. The caller owns layout on both sides.

### 5. Verify with Gradle

```bash
cd android
./gradlew :app:testDebugUnitTest
./gradlew :app:assembleRelease
```

`BUILD SUCCESSFUL` alone does not prove new tests ran. Confirm counts:

```bash
python3 -c "
import glob, xml.etree.ElementTree as ET
for f in glob.glob('app/build/test-results/testDebugUnitTest/*.xml'):
    r = ET.parse(f).getroot()
    print(r.get('name').split('.')[-1], r.get('tests'), 'failures', r.get('failures'), 'skipped', r.get('skipped'))
"
```

Emulator UI tests are slow (~25 min) and normally left to CI. Run them only when the port changed `testTag`s or screen structure:

```bash
./gradlew :app:connectedDebugAndroidTest
```

### 6. Commit

One commit per concern, matching the repo style: imperative subject ending in a period, body explaining why. Commit only when the user asks.

## Gotchas

These cost time before; do not rediscover them.

- **Compose icon set is small.** `material-icons-core` ships roughly 40 glyphs and has no `Icons.Filled.Image`. Use a plain `ColorPainter` or background placeholder rather than pulling in `material-icons-extended` for one icon.
- **Coil resolves `file://` natively.** An iOS branch that special-cases local files exists to work around Kingfisher; on Android it collapses into a single `AsyncImage`.
- **Ktor already rejects non-2xx.** `defaultClient` sets `expectSuccess = true`. Map `ResponseException` to a typed error; do not hand-roll a status check.
- **Android test sources need no registration.** New Kotlin tests are picked up by the source set, unlike iOS where every new test file must be hand-wired into `project.pbxproj`.
- **`assembleRelease` needs a debug keystore** at `~/.android/debug.keystore`; the `ci` signing config points there.
- **`ImageProviderService.kt` returns `TodaysImage`**, not a tuple. Swift's `(item:imageURLs:)` maps onto that data class.

## Product contracts that must stay identical

Verify these survive any port:

- NASA search: `description={day} {MonthName}` with English month names, `media_type=image`
- Client-side anniversary filter on `date_created` (month and day)
- Random pick from the filtered set, falling back to all items
- Image URL: first containing `large`, `medium`, or `original`
- `http` to `https` rewrite on asset URLs, scheme prefix only
- HTML entity decoding on title and description
- Firebase Analytics event `downloading` with param `duration_ms`
- Accessibility ids: `main.title`, `main.refresh`, `main.dayLabel`, `main.imageTitle`, `main.description`, `main.loading`

## Broader diff

For a full behavioral comparison rather than a commit-driven port:

```bash
CURSOR_API_KEY=... node scripts/plan-platform-parity.mjs "optional focus"
```

Writes `parity-plan.md` at the repo root.
