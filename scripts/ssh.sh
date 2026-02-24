#!/usr/bin/env bash
set -euo pipefail

# Usage: run from infra/ directory so relative paths resolve (./scripts, ./.env).
# Examples:
#   ./scripts/ssh.sh
#   ./scripts/ssh.sh uname -a
# shellcheck source=./scripts/utils.sh
source "./scripts/utils.sh" && __infra_utils_guard__

load_env_file

require_env INFRA_SSH_HOST
require_env INFRA_SSH_USER
require_env INFRA_SSH_PRIVATE_KEY_B64

generate_tmpdir
temp_dir="${GENERATED_TMPDIR}"
ssh_key_file="${temp_dir}/infra_ssh_key"
generate_base64_file "${ssh_key_file}" "${INFRA_SSH_PRIVATE_KEY_B64}"

ssh_args=(
  -o BatchMode=yes
  -o LogLevel=ERROR
  -o StrictHostKeyChecking=no
  -o UserKnownHostsFile=/dev/null
  -o ConnectTimeout=8
  -i "${ssh_key_file}"
)

dest="${INFRA_SSH_USER}@${INFRA_SSH_HOST}"

[[ $# -gt 0 ]] || set -- "echo" "connection-ok"
exec ssh "${ssh_args[@]}" "${dest}" "$@"
