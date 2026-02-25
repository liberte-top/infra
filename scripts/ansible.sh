#!/usr/bin/env bash
set -euo pipefail

# Usage: run from infra/ directory so relative paths resolve (./scripts, ./.env).
# Examples:
#   ./scripts/ansible.sh
#   ./scripts/ansible.sh ansible-playbook playbooks/status.yml -e phase_target=00
# Behavior:
#   - no args: execute ansible --version
#   - args: pass through directly to container command
# shellcheck source=./scripts/utils.sh
source "./scripts/utils.sh" && __infra_utils_guard__

load_env_file
require_command docker

require_env ANSIBLE_IMAGE
require_env INFRA_SSH_HOST
require_env INFRA_SSH_USER
require_env INFRA_SSH_PRIVATE_KEY_B64

generate_tmp_ssh_key_file "${INFRA_SSH_PRIVATE_KEY_B64}"
ssh_key_file="${GENERATED_SSH_KEY_FILE}"

container_args=(
  --rm
  -v "${PWD}:/work"
  -v "${ssh_key_file}:/tmp/infra_ssh_key:ro"
  -w /work
  -e "ANSIBLE_CONFIG=/work/ansible.cfg"
  -e "INFRA_SSH_HOST=${INFRA_SSH_HOST}"
  -e "INFRA_SSH_USER=${INFRA_SSH_USER}"
  -e "INFRA_SSH_PRIVATE_KEY_FILE=/tmp/infra_ssh_key"
)

default_args=("ansible" "--version")
normalize_args "${default_args[@]}" -- "$@"

exec docker run "${container_args[@]}" "${ANSIBLE_IMAGE}" "${NORMALIZED_ARGS[@]}"
