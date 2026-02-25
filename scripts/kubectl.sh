#!/usr/bin/env bash
set -euo pipefail

# Usage: run from infra/ directory so relative paths resolve (./scripts, ./.env).
# Examples:
#   ./scripts/kubectl.sh
#   ./scripts/kubectl.sh get nodes -o wide
# Behavior:
#   - no args: execute "kubectl get nodes --request-timeout=15s"
#   - args: pass through to remote kubectl while defaulting kubeconfig when not provided
#   - always enforce kubeconfig server endpoint matches tailscale target
# shellcheck source=./scripts/utils.sh
source "./scripts/utils.sh" && __infra_utils_guard__

load_env_file

require_env INFRA_SSH_HOST
require_env INFRA_SSH_USER
require_env INFRA_SSH_PRIVATE_KEY_B64

remote_kubectl_bin="${INFRA_KUBECTL_BIN:-/usr/local/bin/kubectl}"
remote_kubeconfig_path="${INFRA_KUBECONFIG_PATH:-/etc/rancher/k3s/k3s.yaml}"
tailscale_host="${INFRA_K3S_TAILSCALE_FQDN:-${INFRA_SSH_HOST}}"
expected_server="https://${tailscale_host}:6443"

default_args=("get" "nodes" "--request-timeout=15s")
normalize_args "${default_args[@]}" -- "$@"

has_kubeconfig_arg=false
for arg in "${NORMALIZED_ARGS[@]}"; do
  case "${arg}" in
    --kubeconfig|--kubeconfig=*)
      has_kubeconfig_arg=true
      break
      ;;
  esac
done

kubectl_args=("${NORMALIZED_ARGS[@]}")
if [[ "${has_kubeconfig_arg}" != "true" ]]; then
  kubectl_args=(--kubeconfig "${remote_kubeconfig_path}" "${kubectl_args[@]}")
fi

# Enforce tailscale kubeconfig endpoint before running any kubectl command.
actual_server="$(
  ./scripts/ssh.sh "${remote_kubectl_bin}" --kubeconfig "${remote_kubeconfig_path}" config view --raw -o 'jsonpath={.clusters[0].cluster.server}'
)"
[[ -n "${actual_server}" ]] || error "Failed to read kubeconfig server endpoint from ${remote_kubeconfig_path}."
if [[ "${actual_server}" != "${expected_server}" ]]; then
  error "Kubeconfig server mismatch: expected ${expected_server}, got ${actual_server}"
fi

exec ./scripts/ssh.sh "${remote_kubectl_bin}" "${kubectl_args[@]}"
