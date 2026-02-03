#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
infra_root="$(cd "${script_dir}/.." && pwd)"
compose_file="${infra_root}/docker-compose.yml"
container_name="liberte-ansible"
default_cmd=(ansible)
exec_tty=(-i)
if [[ -t 0 ]]; then
  exec_tty=(-it)
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

docker compose -f "${compose_file}" up -d ansible

if [[ $# -eq 0 ]]; then
  docker exec "${exec_tty[@]}" \
    -e INFRA_SSH_HOST \
    -e INFRA_SSH_USER \
    -e INFRA_SSH_PRIVATE_KEY_B64 \
    "${container_name}" /bin/sh -lc '
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

docker exec "${exec_tty[@]}" \
  -e INFRA_SSH_HOST \
  -e INFRA_SSH_USER \
  -e INFRA_SSH_PRIVATE_KEY_B64 \
  "${container_name}" /bin/sh -lc '
    if [ -n "${INFRA_SSH_PRIVATE_KEY_B64:-}" ]; then
      umask 077
      key_file=/tmp/infra_ssh_key
      echo "$INFRA_SSH_PRIVATE_KEY_B64" | base64 -d > "$key_file"
      export INFRA_SSH_PRIVATE_KEY_FILE="$key_file"
    fi
    exec "$@"
  ' -- "${default_cmd[@]}" "$@"
