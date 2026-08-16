#!/usr/bin/env python3
"""Validate FIREBASE_SERVICE_ACCOUNT and write ADC JSON. Exit 1 with ::error:: on bad input."""

from __future__ import annotations

import json
import os
import pathlib
import sys


def main() -> int:
    raw = os.environ.get("FIREBASE_SERVICE_ACCOUNT", "").strip()
    if not raw:
        print("::error::FIREBASE_SERVICE_ACCOUNT is empty")
        return 1
    try:
        data = json.loads(raw)
    except json.JSONDecodeError as error:
        print(
            f"::error::FIREBASE_SERVICE_ACCOUNT is not valid JSON ({error}). "
            "Paste the IAM service-account private key file, not google-services.json."
        )
        return 1
    if not isinstance(data, dict):
        print("::error::FIREBASE_SERVICE_ACCOUNT JSON must be an object")
        return 1

    keys = ", ".join(sorted(data.keys()))
    print(f"JSON keys: {keys}")

    missing = [key for key in ("type", "project_id", "client_email", "private_key") if key not in data]
    if data.get("type") != "service_account" or missing:
        print(
            "::error::FIREBASE_SERVICE_ACCOUNT is not a GCP IAM service account key "
            "(need type=service_account, project_id, client_email, private_key). "
            "google-services.json / GoogleService-Info.plist will not work."
        )
        return 1

    print(f"project_id={data.get('project_id')}")
    print(f"client_email={data.get('client_email')}")
    path = pathlib.Path(os.environ["RUNNER_TEMP"]) / "firebase-sa.json"
    path.write_text(json.dumps(data))
    print(f"Wrote {path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
