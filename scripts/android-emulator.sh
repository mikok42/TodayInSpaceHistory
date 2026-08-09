#!/usr/bin/env bash
# Ensure the Pixel_7_API_35 emulator is up, then optionally build/install/launch the app.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID_DIR="$ROOT/android"
SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
export ANDROID_HOME="$SDK"
export ANDROID_SDK_ROOT="$SDK"
export PATH="$SDK/emulator:$SDK/platform-tools:$SDK/cmdline-tools/latest/bin:$PATH"

AVD_NAME="${ANDROID_AVD_NAME:-Pixel_7_API_35}"
PACKAGE_ID="miko.todayinspacehistory"
ACTIVITY=".MainActivity"
JAVA_HOME_DEFAULT="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
export JAVA_HOME="${JAVA_HOME:-$JAVA_HOME_DEFAULT}"

usage() {
  echo "Usage: $0 ensure | run [--build]"
}

device_online() {
  adb devices | awk 'NR>1 && $2=="device" {print $1; exit}'
}

wait_for_boot() {
  local serial="$1"
  adb -s "$serial" wait-for-device
  # Boot completed property
  until [[ "$(adb -s "$serial" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; do
    sleep 2
  done
}

ensure_emulator() {
  local serial
  serial="$(device_online || true)"
  if [[ -n "${serial:-}" ]]; then
    echo "Using device: $serial"
    echo "$serial"
    return 0
  fi

  if ! emulator -list-avds | grep -qx "$AVD_NAME"; then
    echo "Missing AVD '$AVD_NAME'. Create it with:" >&2
    echo "  avdmanager create avd -n $AVD_NAME -k 'system-images;android-35;google_apis;arm64-v8a' -d pixel_7" >&2
    exit 1
  fi

  echo "Starting emulator $AVD_NAME..."
  nohup emulator -avd "$AVD_NAME" -netdelay none -netspeed full >/tmp/tish-emulator.log 2>&1 &
  # Wait until adb sees a device
  for _ in $(seq 1 90); do
    serial="$(device_online || true)"
    if [[ -n "${serial:-}" ]]; then
      wait_for_boot "$serial"
      echo "Emulator ready: $serial"
      echo "$serial"
      return 0
    fi
    sleep 2
  done
  echo "Timed out waiting for emulator. See /tmp/tish-emulator.log" >&2
  exit 1
}

run_app() {
  local do_build=0
  if [[ "${1:-}" == "--build" ]]; then
    do_build=1
  fi

  local serial
  serial="$(ensure_emulator | tail -n 1)"

  if [[ "$do_build" -eq 1 ]]; then
    (
      cd "$ANDROID_DIR"
      ./gradlew :app:assembleDebug
    )
  fi

  local apk="$ANDROID_DIR/app/build/outputs/apk/debug/app-debug.apk"
  if [[ ! -f "$apk" ]]; then
    (
      cd "$ANDROID_DIR"
      ./gradlew :app:assembleDebug
    )
  fi

  adb -s "$serial" install -r "$apk"
  adb -s "$serial" shell am start -n "${PACKAGE_ID}/${ACTIVITY}"
  echo "Launched $PACKAGE_ID on $serial"
}

cmd="${1:-}"
case "$cmd" in
  ensure) ensure_emulator >/dev/null ;;
  run) shift || true; run_app "${1:-}" ;;
  *) usage; exit 1 ;;
esac
