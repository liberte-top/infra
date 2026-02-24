#!/usr/bin/env bash
set -euo pipefail

# Usage: run from infra/ directory so relative paths resolve (./scripts, ./.env).
# Examples:
#   ./scripts/ansible.sh
#   ./scripts/ansible.sh playbooks/status.yml -e phase_target=00
# shellcheck source=./scripts/utils.sh
source "./scripts/utils.sh" && __infra_utils_guard__

ansible_image_default="ghcr.io/ansible-community/community-ee-base:2.19.5-1"
default_cmd=(ansible)
docker_tty=(-i)
if [[ -t 0 ]]; then
  docker_tty=(-it)
fi

load_env_file

require_env INFRA_SSH_HOST
require_env INFRA_SSH_USER
require_env INFRA_SSH_PRIVATE_KEY_B64

ANSIBLE_IMAGE="${ANSIBLE_IMAGE:-$ansible_image_default}"

docker_args=(
  "${docker_tty[@]}"
  --rm
  -v "${PWD}:/work"
  -w /work
  -e "ANSIBLE_CONFIG=/work/ansible.cfg"
  -e "INFRA_SSH_HOST=${INFRA_SSH_HOST:-}"
  -e "INFRA_SSH_USER=${INFRA_SSH_USER:-}"
  -e "INFRA_SSH_PRIVATE_KEY_B64=${INFRA_SSH_PRIVATE_KEY_B64:-}"
)

if [[ $# -eq 0 ]]; then
  docker run "${docker_args[@]}" "${ANSIBLE_IMAGE}" /bin/sh -lc '
      umask 077
      key_file=/tmp/infra_ssh_key
      echo "$INFRA_SSH_PRIVATE_KEY_B64" | base64 -d > "$key_file"
      export INFRA_SSH_PRIVATE_KEY_FILE="$key_file"
      exec /bin/sh
    '
  exit 0
fi

for arg in "$@"; do
  case "$arg" in
    *.yml|*.yaml)
      default_cmd=(ansible-playbook)
      break
      ;;
  esac
done

docker run "${docker_args[@]}" "${ANSIBLE_IMAGE}" /bin/sh -lc '
    umask 077
    key_file=/tmp/infra_ssh_key
    echo "$INFRA_SSH_PRIVATE_KEY_B64" | base64 -d > "$key_file"
    export INFRA_SSH_PRIVATE_KEY_FILE="$key_file"
    exec "$@"
  ' -- "${default_cmd[@]}" "$@"
