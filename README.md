# Today In Space History

Monorepo setup for a sample app for both iOS and Android, setup to support agentic workflows.

| Path | Platform |
|------|----------|
| [`ios/`](ios/) | SwiftUI / Xcode — open `ios/TodayInSpaceHistory.xcodeproj` |
| [`android/`](android/) | Kotlin / Jetpack Compose — open **`android/`** in Android Studio (not the repo root) |

### Run Android (Android Studio)

1. **File → Open…** → select the `android/` folder (so Gradle syncs the app module).
2. Wait for Gradle sync to finish (JDK: embedded **jbr-21**).
3. In the toolbar, choose run configuration **app** and device **Pixel_7_API_35** (AVD uses host GPU).
4. Press **Run** (green triangle) — Studio builds, starts the emulator if needed, installs, and launches.

Agent rules: [`.cursor/rules/`](.cursor/rules/) (see [`AGENTS.md`](AGENTS.md)).

## Platform parity agent

```bash
cd /path/to/TodayInSpaceHistory
npm install
CURSOR_API_KEY=... npm run parity
# or: CURSOR_API_KEY=... node scripts/plan-platform-parity.mjs "analytics"
```

Writes `parity-plan.md` at the repo root.

## Firebase App Distribution (CI)

Workflow: [`.github/workflows/firebase-distribute.yml`](.github/workflows/firebase-distribute.yml)

Runs on push to `main` and via **Actions → Firebase App Distribution → Run workflow**.

Tests run first per platform. The Android distribution job starts only after `test-android` succeeds; iOS distribution starts only after `test-ios` succeeds. One platform failing does not block the other.

| Job | What it does |
|-----|----------------|
| **test-android** | `./gradlew :app:testDebugUnitTest` then Compose UI tests on an API 34 emulator |
| **test-ios** | `xcodebuild test` (unit + UI, `-UITestStub`) on an iPhone simulator |
| **android** | Release APK on Firebase App Distribution (debug-keystore signed, installable) |
| **ios** | Always built. Firebase upload happens only for a **signed Ad Hoc IPA**. Without Apple signing secrets CI keeps an **unsigned IPA** as a GitHub artifact; Firebase rejects it (no provisioning profile). A paid Apple Developer Program is required to distribute to testers' iPhones. |

Create a Firebase App Distribution tester group named **`qa`** in the Console.

Required GitHub secret:

| Secret | Purpose |
|--------|---------|
| `FIREBASE_SERVICE_ACCOUNT` | JSON service account with App Distribution access |

Optional (defaults are the IDs already in `google-services.json` / `GoogleService-Info.plist`):

| Secret | Purpose |
|--------|---------|
| `FIREBASE_ANDROID_APP_ID` | `1:453196059:android:b7e1e9e27b6bf9cceefbbe` |
| `FIREBASE_IOS_APP_ID` | `1:453196059:ios:3ae822f995de3787eefbbe` |

iOS signing secrets (leave unset for an unsigned GitHub artifact; set all of them to upload a real Ad Hoc build to Firebase):

| Secret | Purpose |
|--------|---------|
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API key id |
| `APP_STORE_CONNECT_API_ISSUER_ID` | App Store Connect issuer id |
| `APP_STORE_CONNECT_API_KEY` | Contents of the `.p8` key |
| `BUILD_CERTIFICATE_BASE64` | Base64-encoded signing `.p12` |
| `BUILD_PROVISION_PROFILE_BASE64` | Base64-encoded `.mobileprovision` (Ad Hoc) |
| `P12_PASSWORD` | Password for the `.p12` |
| `KEYCHAIN_PASSWORD` | Temporary CI keychain password |
