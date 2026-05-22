#!/usr/bin/env bash
# Compatibility entry point for the default test runner. The canonical
# originality denylist lives in scripts/validate_originality.sh.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec bash "$ROOT/scripts/validate_originality.sh"
