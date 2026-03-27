#!/usr/bin/env bash

set -euo pipefail

echo "Checking OHOS prerequisite environment..."

check_var() {
  local name="$1"
  if [[ -n "${!name:-}" ]]; then
    echo "[ok] $name=${!name}"
  else
    echo "[missing] $name"
  fi
}

check_cmd() {
  local name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    echo "[ok] command: $name -> $(command -v "$name")"
  else
    echo "[missing] command: $name"
  fi
}

check_var FLUTTER_HOME
check_var OHPM_HOME
check_var HOS_SDK_HOME
check_var OHOS_SDK_HOME
check_var HDC_HOME
check_var SIGN_TOOL_HOME

check_cmd flutter
check_cmd ohpm
check_cmd hdc

echo
echo "Tip: the active Flutter SDK must be the OpenHarmony-SIG SDK for"
echo "'flutter create --platforms ohos' to work."
