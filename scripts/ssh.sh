#!/usr/bin/env bash
set -euo pipefail

# Usage: run from infra/ directory so relative paths resolve (./scripts, ./.env).
# Examples:
#   ./scripts/ssh.sh
#   ./scripts/ssh.sh uname -a
# shellcheck source=./scripts/utils.sh
source "./scripts/utils.sh" && __infra_utils_guard__

load_env_file
require_command ssh

require_env INFRA_SSH_HOST
require_env INFRA_SSH_USER
require_env INFRA_SSH_PRIVATE_KEY_B64

generate_tmp_ssh_key_file "${INFRA_SSH_PRIVATE_KEY_B64}"
ssh_key_file="${GENERATED_SSH_KEY_FILE}"
build_ssh_args "${ssh_key_file}" default
ssh_build_dest "${INFRA_SSH_USER}" "${INFRA_SSH_HOST}"

default_args=("echo" "connection-ok")
normalize_args "${default_args[@]}" -- "$@"
exec ssh "${SSH_ARGS[@]}" "${SSH_DEST}" "${NORMALIZED_ARGS[@]}"
