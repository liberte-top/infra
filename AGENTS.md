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

## Repository Structure (Refactor Map)
Use this as the baseline module map before refactoring.

```text
infra/
├── .github/workflows/        # CI entrypoints (rollup / rollback workflow dispatch)
├── inventory/                # Ansible inventory + group/host vars
│   ├── hosts.ini
│   ├── group_vars/all.yml
│   └── host_vars/prod-control-01.yml
├── playbooks/                # Top-level orchestration playbooks
│   ├── rollup.yml
│   ├── rollback.yml
│   ├── status.yml
│   └── phases/phase_00.yml..phase_05.yml  # Per-phase role dispatch
├── roles/                    # Desired state implementation by phase
│   ├── phase00..phase05/
│   │   ├── tasks/{rollup,rollback,status}.yml
│   │   └── templates/        # Present in phase02/phase04
├── scripts/                  # Operational entrypoints and local tooling
│   ├── ansible.sh            # Single ansible runtime wrapper (containerized)
│   ├── ssh.sh                # Direct SSH connectivity helper
│   ├── utils.sh              # Shared shell helpers for scripts
│   └── ci.sh                 # GitHub Actions workflow trigger helper
├── ansible.cfg               # Local ansible defaults
├── .env(.example)            # Runtime parameters
├── BOOTSTRAP.md              # Phase -1 manual server bootstrap
└── AGENTS.md                 # Collaboration and execution conventions
```

## Phase Ownership Snapshot
- `phase00`: base OS packages and phase state bootstrap.
- `phase01`: root-only SSH hardening baseline.
- `phase02`: UFW + sysctl hardening.
- `phase03`: k3s install/verify + kubeconfig endpoint standardization.
- `phase04`: maintenance timers (image GC, logrotate, release prune).
- `phase05`: helm + cert-manager lifecycle.

## Phase Runtime Files
- Persist phase facts in `/var/lib/infra/phase/<id>/facts.json`.
- `status` playbook computes and prints live status; do not persist per-phase `status.json` going forward.

## Runtime Parameters
- `ANSIBLE_IMAGE`: execution environment image for ansible commands.
- `INFRA_SSH_HOST`: target host/IP for ansible inventory host.
- `INFRA_SSH_USER`: SSH user for target host.
- `INFRA_SSH_PRIVATE_KEY_B64` (required): base64-encoded private key, decoded at runtime.

## Core Inventory Variables
- `root_pubkey`: SSH key allowed for `root`.
- `k3s_api_endpoint`: endpoint used in k3s kubeconfig server URL (default `ansible_host`).

## Execution Entry
- Always run ansible through `scripts/ansible.sh`.
- Behavior:
  - No arguments: execute `ansible --version`.
  - With arguments: pass through directly to the container command.

## Common Commands
- `./scripts/ssh.sh`
- `./scripts/ssh.sh uname -a`
- `./scripts/kubectl.sh`
- `./scripts/kubectl.sh get nodes -o wide`
- `./scripts/ansible.sh ansible-playbook playbooks/status.yml -e phase_target=03`
- `./scripts/ansible.sh ansible-playbook playbooks/rollup.yml -e phase_from=00 -e phase_to=03`
- `./scripts/ansible.sh ansible-playbook playbooks/rollback.yml -e phase_from=00 -e phase_to=03`

## Phase00 Regression Checklist
- `./scripts/ansible.sh ansible-playbook playbooks/status.yml -e phase_target=00`
- `./scripts/ansible.sh ansible-playbook playbooks/rollup.yml -e phase_from=00 -e phase_to=00`
- `./scripts/ansible.sh ansible-playbook playbooks/rollup.yml -e phase_from=00 -e phase_to=00` (idempotency pass)
- `./scripts/ansible.sh ansible-playbook playbooks/rollback.yml -e phase_from=00 -e phase_to=00`
- `./scripts/ansible.sh ansible-playbook playbooks/status.yml -e phase_target=00`

## Change Policy
- Update ansible image version in `.env` (or `.env.example` default), not in playbooks.
- Keep `scripts/ansible.sh` as the single operational entrypoint.
- If multi-container orchestration is required in the future, add a dedicated compose file intentionally; do not reintroduce hidden dual entrypoints.

## Main Branch Guard
- `.task/` is allowed during feature work but must not exist on `main`.
- Promote useful task insights to permanent docs (for example `AGENTS.md`/`BOOTSTRAP.md`) before merge.
- `main` is protected by required check `forbid-task-dir-on-main` from workflow `.github/workflows/ci.guard.yml`.
