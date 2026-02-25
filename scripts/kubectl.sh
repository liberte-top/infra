#!/usr/bin/env bash
set -euo pipefail

# Usage: run from infra/ directory so relative paths resolve (./scripts, ./.env).
# Examples:
#   ./scripts/kubectl.sh
#   ./scripts/kubectl.sh get nodes -o wide
# Behavior:
#   - no args: execute "kubectl get nodes --request-timeout=15s"
#   - args: pass through to remote kubectl while defaulting kubeconfig when not provided
# shellcheck source=./scripts/utils.sh
source "./scripts/utils.sh" && __infra_utils_guard__

load_env_file

require_env INFRA_KUBECTL_BIN
require_env INFRA_KUBECONFIG_PATH

remote_kubectl_bin="${INFRA_KUBECTL_BIN}"
remote_kubeconfig_path="${INFRA_KUBECONFIG_PATH}"

default_args=("get" "nodes" "--request-timeout=15s")
normalize_args "${default_args[@]}" -- "$@"

exec ./scripts/ssh.sh "KUBECONFIG=${remote_kubeconfig_path}" "${remote_kubectl_bin}" "${NORMALIZED_ARGS[@]}"
