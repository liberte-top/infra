#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
infra_root="$(cd "${script_dir}/.." && pwd)"
ansible_image_default="ghcr.io/ansible-community/community-ee-base:2.19.5-1"
default_cmd=(ansible)
docker_tty=(-i)
if [[ -t 0 ]]; then
  docker_tty=(-it)
fi

env_file="${infra_root}/.env"
if [[ ! -f "${env_file}" ]]; then
  echo "Missing ${env_file}. Create it from ${infra_root}/.env.example." >&2
  exit 1
fi

set -a
# shellcheck source=/dev/null
source "${env_file}"
set +a

if [[ -z "${INFRA_SSH_HOST:-}" ]]; then
  INFRA_SSH_HOST="${INFRA_HOST:-}"
fi
if [[ -z "${INFRA_SSH_USER:-}" ]]; then
  INFRA_SSH_USER="${INFRA_USER:-root}"
fi

ANSIBLE_IMAGE="${ANSIBLE_IMAGE:-$ansible_image_default}"

docker_args=(
  "${docker_tty[@]}"
  --rm
  -v "${infra_root}:/work"
  -w /work
  -e "ANSIBLE_CONFIG=/work/ansible.cfg"
  -e "INFRA_SSH_HOST=${INFRA_SSH_HOST:-}"
  -e "INFRA_SSH_USER=${INFRA_SSH_USER:-}"
  -e "INFRA_SSH_PRIVATE_KEY_B64=${INFRA_SSH_PRIVATE_KEY_B64:-}"
)

if [[ $# -eq 0 ]]; then
  docker run "${docker_args[@]}" "${ANSIBLE_IMAGE}" /bin/sh -lc '
      if [ -n "${INFRA_SSH_PRIVATE_KEY_B64:-}" ]; then
        umask 077
        key_file=/tmp/infra_ssh_key
        echo "$INFRA_SSH_PRIVATE_KEY_B64" | base64 -d > "$key_file"
        export INFRA_SSH_PRIVATE_KEY_FILE="$key_file"
      fi
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
    if [ -n "${INFRA_SSH_PRIVATE_KEY_B64:-}" ]; then
      umask 077
      key_file=/tmp/infra_ssh_key
      echo "$INFRA_SSH_PRIVATE_KEY_B64" | base64 -d > "$key_file"
      export INFRA_SSH_PRIVATE_KEY_FILE="$key_file"
    fi
    exec "$@"
  ' -- "${default_cmd[@]}" "$@"
