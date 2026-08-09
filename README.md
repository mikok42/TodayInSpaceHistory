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

Required GitHub secrets:

| Secret | Purpose |
|--------|---------|
| `FIREBASE_SERVICE_ACCOUNT` | JSON service account with App Distribution access |
| `FIREBASE_ANDROID_APP_ID` | `1:453196059:android:b7e1e9e27b6bf9cceefbbe` |
| `FIREBASE_IOS_APP_ID` | `1:453196059:ios:3ae822f995de3787eefbbe` |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API key id |
| `APP_STORE_CONNECT_API_ISSUER_ID` | App Store Connect issuer id |
| `APP_STORE_CONNECT_API_KEY` | Contents of the `.p8` key |
| `BUILD_CERTIFICATE_BASE64` | Base64-encoded signing `.p12` |
| `BUILD_PROVISION_PROFILE_BASE64` | Base64-encoded `.mobileprovision` (Ad Hoc) |
| `P12_PASSWORD` | Password for the `.p12` |
| `KEYCHAIN_PASSWORD` | Temporary CI keychain password |

Create a Firebase App Distribution tester group named **`qa`** in the Console.

Android CI uses a release APK signed with the debug keystore (installable by testers without Play App Signing). The iOS job fails with a clear error until the Apple signing secrets above are set.
