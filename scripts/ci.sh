#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/ci.sh rollup   --from <phase> --to <phase> [--ref <branch>]
  scripts/ci.sh rollback --from <phase> --to <phase> [--ref <branch>]
  scripts/ci.sh apply    [--ref <branch>]

Examples:
  scripts/ci.sh rollup --from 00 --to 02 --ref main
  scripts/ci.sh rollback --from 00 --to 02 --ref main
  scripts/ci.sh apply --ref main
USAGE
}

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

cmd="$1"
shift

ref="main"
phase_from=""
phase_to=""

while [ $# -gt 0 ]; do
  case "$1" in
    --ref)
      ref="$2"
      shift 2
      ;;
    --from)
      phase_from="$2"
      shift 2
      ;;
    --to)
      phase_to="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
 done

infra_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -d "$infra_root/.git" ]; then
  echo "infra repo not found at $infra_root" >&2
  exit 1
fi

ensure_clean_worktree() {
  if [ -n "$(git -C "$infra_root" status --porcelain)" ]; then
    echo "infra working tree is dirty" >&2
    git -C "$infra_root" status --porcelain >&2
    exit 1
  fi
}

ensure_ref_synced() {
  if ! git -C "$infra_root" fetch --quiet origin "$ref"; then
    echo "Failed to fetch origin/$ref" >&2
    exit 1
  fi

  local_sha=$(git -C "$infra_root" rev-parse "$ref" 2>/dev/null || true)
  remote_sha=$(git -C "$infra_root" rev-parse "origin/$ref" 2>/dev/null || true)

  if [ -z "$local_sha" ] || [ -z "$remote_sha" ]; then
    echo "Unable to resolve ref or origin ref for '$ref'" >&2
    exit 1
  fi

  if [ "$local_sha" != "$remote_sha" ]; then
    echo "Ref mismatch: local $ref=$local_sha != origin/$ref=$remote_sha" >&2
    exit 1
  fi
}

run_workflow() {
  local workflow="$1"
  local start
  local run_id

  start="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  (cd "$infra_root" && gh workflow run "$workflow" --ref "$ref" "$@")

  run_id=""
  for _ in {1..30}; do
    run_id=$(cd "$infra_root" && gh run list -w "$workflow" -b "$ref" -e workflow_dispatch \
      --json databaseId,createdAt -L 10 \
      -q "map(select(.createdAt >= \"$start\")) | .[0].databaseId")
    if [ -n "$run_id" ] && [ "$run_id" != "null" ]; then
      break
    fi
    sleep 2
  done

  if [ -z "$run_id" ] || [ "$run_id" = "null" ]; then
    echo "Failed to resolve run id for $workflow" >&2
    exit 1
  fi

  (cd "$infra_root" && gh run watch "$run_id" --exit-status)
}

ensure_clean_worktree
ensure_ref_synced

case "$cmd" in
  rollup)
    if [ -z "$phase_from" ] || [ -z "$phase_to" ]; then
      echo "rollup requires --from and --to" >&2
      exit 1
    fi
    run_workflow "ci.rollup" -f phase_from="$phase_from" -f phase_to="$phase_to"
    ;;
  rollback)
    if [ -z "$phase_from" ] || [ -z "$phase_to" ]; then
      echo "rollback requires --from and --to" >&2
      exit 1
    fi
    run_workflow "ci.rollback" -f phase_from="$phase_from" -f phase_to="$phase_to"
    ;;
  apply)
    run_workflow "ci.apply"
    ;;
  *)
    echo "Unknown command: $cmd" >&2
    usage
    exit 1
    ;;
esac
