#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
: "${CAPTURE_URL:?Set CAPTURE_URL to the exact preview URL}"
: "${CAPTURE_DIR:?Set CAPTURE_DIR to the evidence output directory}"
: "${RUNTIME_DIR:?RUNTIME_DIR is required for the browser capture runtime}"

case "$(cd "$(dirname "$CAPTURE_DIR")" && pwd -P)/$(basename "$CAPTURE_DIR")/" in
  "$PROJECT_DIR/"|"$PROJECT_DIR"/*)
    echo "CAPTURE_DIR must be outside the project source tree." >&2
    exit 1
    ;;
esac

run_timed() {
  /usr/bin/time -p "$@"
}

run_timed mkdir -p "$CAPTURE_DIR"
export CAPTURE_READY_SELECTOR="${CAPTURE_READY_SELECTOR:-canvas#game}"
export CAPTURE_START_SELECTOR="${CAPTURE_START_SELECTOR:-#skip}"
export CAPTURE_AUTO_START="${CAPTURE_AUTO_START:-true}"
run_timed node "${RUNTIME_DIR}/scripts/default-capture.mjs"
