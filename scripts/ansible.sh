#!/usr/bin/env bash
set -euo pipefail

# Usage: can run from any directory.
# Examples:
#   ./scripts/ansible.sh
#   ./scripts/ansible.sh ansible-playbook playbooks/status.yml -e phase_target=00
# Behavior:
#   - no args: execute ansible --version
#   - args: pass through directly to container command
#   - `status.yml` output is filtered to the operator-facing summary
# shellcheck source=./scripts/utils.sh
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/utils.sh" && __infra_utils_guard__

load_env_file "${REPO_ROOT}/.env"
require_command docker

require_env ANSIBLE_IMAGE
require_env INFRA_SSH_HOST
require_env INFRA_SSH_USER
require_env INFRA_SSH_PRIVATE_KEY_B64

generate_tmp_ssh_key_file "${INFRA_SSH_PRIVATE_KEY_B64}"
ssh_key_file="${GENERATED_SSH_KEY_FILE}"

container_args=(
  --rm
  -v "${REPO_ROOT}:/work"
  -v "${ssh_key_file}:/tmp/infra_ssh_key:ro"
  -w /work
  -e "ANSIBLE_CONFIG=/work/ansible.cfg"
  -e "INFRA_SSH_HOST=${INFRA_SSH_HOST}"
  -e "INFRA_SSH_USER=${INFRA_SSH_USER}"
  -e "INFRA_SSH_PRIVATE_KEY_FILE=/tmp/infra_ssh_key"
)

default_args=("ansible" "--version")
normalize_args "${default_args[@]}" -- "$@"

if [[ "${NORMALIZED_ARGS[0]}" == "ansible-playbook" ]]; then
  status_verbose=false
  for arg in "${NORMALIZED_ARGS[@]:1}"; do
    if [[ "${arg}" == "-v" || "${arg}" == "-vv" || "${arg}" == "-vvv" || "${arg}" == "-vvvv" ]]; then
      status_verbose=true
      break
    fi
  done

  for arg in "${NORMALIZED_ARGS[@]:1}"; do
    if [[ "${arg}" == "playbooks/status.yml" || "${arg}" == "/work/playbooks/status.yml" ]]; then
      if [[ "${status_verbose}" == "true" ]]; then
        break
      fi

      docker run "${container_args[@]}" "${ANSIBLE_IMAGE}" "${NORMALIZED_ARGS[@]}" 2>&1 | python3 -c '
import re
import sys

keep = [
    re.compile(r"^PLAY "),
    re.compile(r"^TASK \[Output phase status\]"),
    re.compile(r"^TASK \[Output non-success reasons\]"),
    re.compile(r"^TASK \[Output status summary\]"),
    re.compile(r"^\s+\"msg\":"),
    re.compile(r"phase=.*status="),
    re.compile(r"phase=.*reason="),
    re.compile(r"phase_target=.*healthy="),
    re.compile(r"^PLAY RECAP "),
    re.compile(r"^[A-Za-z0-9_.-]+\s+:\s+ok="),
    re.compile(r"^fatal:"),
    re.compile(r"^ERROR!"),
    re.compile(r"^FAILED!"),
    re.compile(r"^prod-control-01 .*FAILED"),
]

for raw in sys.stdin:
    line = raw.rstrip("\n")
    if any(pattern.search(line) for pattern in keep):
        print(line)
'
      exit_code=${PIPESTATUS[0]}
      exit "${exit_code}"
    fi
  done
fi

exec docker run "${container_args[@]}" "${ANSIBLE_IMAGE}" "${NORMALIZED_ARGS[@]}"
