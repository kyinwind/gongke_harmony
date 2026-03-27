# OHOS NEXT Setup

## Current Status

This project has been simplified toward an OHOS-only target:

- share flow removed from the main app flow
- TTS and foreground-service based reading removed
- import flow migrated to `file_selector`
- platform branches reduced to capability-style checks

The current local Flutter toolchain is still the official stable SDK, not the
OpenHarmony-compatible SDK. As a result, the local `flutter create` command
does not support the `ohos` platform yet.

## Verified Local Constraint

Local toolchain on this machine:

```text
Flutter 3.38.5
Dart 3.10.4
```

Observed behavior:

- `flutter create --help` does not list `ohos` in `--platforms`

That means this workspace cannot generate `ohos/` with the currently active
Flutter SDK.

## Required Toolchain Switch

To generate and build HarmonyOS NEXT projects, switch to the
OpenHarmony-SIG-maintained Flutter SDK.

Reference:

- OpenHarmony-SIG Flutter README:
  https://gitee.com/openharmony-sig/flutter_flutter/blob/master/README.en.md

Important commands from the OHOS-compatible toolchain:

```bash
flutter create --platforms ohos .
flutter build hap --release
flutter build app --release
```

## Environment Prerequisites

Before generating `ohos/`, prepare:

- OpenHarmony-SIG Flutter SDK
- HarmonyOS / OpenHarmony SDK
- `ohpm`
- `hdc`
- signing tool

The upstream README also documents environment variables such as:

- `FLUTTER_HOME`
- `OHPM_HOME`
- `HOS_SDK_HOME`
- `OHOS_SDK_HOME`
- `HDC_HOME`
- `SIGN_TOOL_HOME`

## Recommended Migration Order

1. Install and activate the OpenHarmony-SIG Flutter SDK.
2. Run `flutter doctor` under that SDK until OHOS-related checks are healthy.
3. In this project root, run:
   `flutter create --platforms ohos .`
4. Run `flutter pub get`.
5. Build a minimal package first:
   `flutter build hap --release`
6. Validate the four core flows on device:
   - database open and write
   - file import
   - PDF read
   - shake counter

## App-Level Validation Checklist

After `ohos/` is generated, validate these areas first:

- app starts and initializes Drift database
- welcome flow and tab navigation work
- import page can select multiple PDF/JSON files
- imported files are persisted and listed correctly
- PDF page can open asset and imported files
- wake lock related pages do not crash
- shake counter works on phone hardware

## Known High-Risk Area

The biggest remaining technical risk is still PDF rendering on OHOS because the
current app depends on `pdfx`. The app has already been simplified so PDF
rendering can be validated independently from TTS and foreground-service logic.
