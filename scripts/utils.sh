#!/usr/bin/env bash

__infra_utils_guard__() {
  return 0
}

error() {
  echo "$*" >&2
  exit 1
}

require_file() {
  local file_path="$1"
  local hint="${2:-}"
  if [[ -f "${file_path}" ]]; then
    return 0
  fi
  if [[ -n "${hint}" ]]; then
    error "Missing ${file_path}. ${hint}"
  fi
  error "Missing ${file_path}."
}

require_env() {
  local name="$1"
  local scope="${2:-environment}"
  [[ -n "${!name:-}" ]] || error "${name} is required in ${scope}"
}

load_env_file() {
  local file_path="${1:-./.env}"
  require_file "${file_path}" "Create it from ./.env.example."
  set -a
  # shellcheck source=/dev/null
  source "${file_path}"
  set +a
}

generate_tmpdir() {
  GENERATED_TMPDIR="$(mktemp -d)"
  trap "rm -rf '${GENERATED_TMPDIR}'" EXIT
}

generate_base64_file() {
  local file_path="$1"
  local b64_payload="$2"
  umask 077
  printf '%s' "${b64_payload}" | base64 -d > "${file_path}"
}
