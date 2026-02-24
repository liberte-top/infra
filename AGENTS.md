# Infra AGENTS Guide

## Document Index
- `AGENTS.md`: infra collaboration and execution conventions.
- `BOOTSTRAP.md`: Phase -1 manual bootstrap runbook for first-time server initialization.

## First-Time Flow
- On a brand-new server, complete `BOOTSTRAP.md` first.
- After bootstrap is verified, use `scripts/ansible.sh` for phase rollup/rollback/status operations.

## Single Source of Truth
- Runtime parameters live in `.env`.
- Execution entry is `scripts/ansible.sh`.
- Infrastructure desired state lives in `playbooks/` and `roles/`.

## Runtime Parameters
- `ANSIBLE_IMAGE`: execution environment image for ansible commands.
- `INFRA_SSH_HOST`: target host/IP for ansible inventory host.
- `INFRA_SSH_USER`: SSH user for target host.
- `INFRA_SSH_PRIVATE_KEY_B64` (required): base64-encoded private key, decoded at runtime.

## Execution Entry
- Always run ansible through `scripts/ansible.sh`.
- Behavior:
  - No arguments: open interactive shell inside the ansible image.
  - Any `*.yml`/`*.yaml` argument: execute via `ansible-playbook`.
  - Otherwise: execute via `ansible`.

## Common Commands
- `./scripts/ssh.sh`
- `./scripts/ssh.sh uname -a`
- `./scripts/ansible.sh playbooks/status.yml -e phase_target=03`
- `./scripts/ansible.sh playbooks/rollup.yml -e phase_from=00 -e phase_to=03`
- `./scripts/ansible.sh playbooks/rollback.yml -e phase_from=00 -e phase_to=03`

## Change Policy
- Update ansible image version in `.env` (or `.env.example` default), not in playbooks.
- Keep `scripts/ansible.sh` as the single operational entrypoint.
- If multi-container orchestration is required in the future, add a dedicated compose file intentionally; do not reintroduce hidden dual entrypoints.
