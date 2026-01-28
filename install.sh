#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$ROOT_DIR/scripts"

# Single source of truth for infra install flow (idempotent)
STEPS=(
  "00-ssh-hardening.sh"
)

for step in "${STEPS[@]}"; do
  script="$SCRIPTS_DIR/$step"
  if [[ ! -x "$script" ]]; then
    echo "missing executable: $script" >&2
    exit 1
  fi
  echo "==> running $step"
  "$script"
done

echo "==> install complete"
