#!/usr/bin/env bash
set -euo pipefail

# Usage: run from infra/ directory so relative paths resolve (./scripts, ./.env).
# Examples:
#   ./scripts/kubectl.sh
#   ./scripts/kubectl.sh get nodes -o wide
# Behavior:
#   - strict tunnel mode only
#   - local port from INFRA_KUBECTL_TUNNEL_LOCAL_PORT (default: 56443)
#   - fetch remote kubeconfig to a temp file via scp for each invocation
#   - no args: execute "kubectl get nodes --request-timeout=15s"
# shellcheck source=./scripts/utils.sh
source "./scripts/utils.sh" && __infra_utils_guard__

load_env_file

require_command kubectl
require_command ssh
require_command scp

require_env INFRA_SSH_HOST
require_env INFRA_SSH_USER
require_env INFRA_SSH_PRIVATE_KEY_B64
require_env INFRA_KUBECONFIG_PATH

local_port="${INFRA_KUBECTL_TUNNEL_LOCAL_PORT:-56443}"

generate_tmp_ssh_key_file "${INFRA_SSH_PRIVATE_KEY_B64}"
ssh_key_file="${GENERATED_SSH_KEY_FILE}"
cleanup() {
  kubectl_session_close
  rm -rf "${GENERATED_TMPDIR}"
}
trap cleanup EXIT

build_ssh_args "${ssh_key_file}" tunnel
ssh_build_dest "${INFRA_SSH_USER}" "${INFRA_SSH_HOST}"

kubectl_session_open "${local_port}" "${INFRA_KUBECONFIG_PATH}"

default_args=("get" "nodes" "--request-timeout=15s")
normalize_args "${default_args[@]}" -- "$@"

kubectl_session_exec "${NORMALIZED_ARGS[@]}"
