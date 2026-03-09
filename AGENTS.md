# Infra AGENTS Guide

## Document Index
- `AGENTS.md`: infra collaboration and execution conventions.
- `BOOTSTRAP.md`: Phase -1 manual bootstrap runbook for first-time server initialization.

## First-Time Flow
- On a brand-new server, complete `BOOTSTRAP.md` first.
- On an existing managed environment, start with local `.env` setup, then validate access with `scripts/ssh.sh`, then run `status` before any change.
- After bootstrap is verified, use `scripts/ansible.sh` for phase rollup/rollback/status operations.

## 60-Second Local Start
- Copy `.env.example` to `.env` and fill in the SSH host, user, and local base64 private key.
- Validate direct connectivity with `./scripts/ssh.sh`.
- Validate the ansible runtime with `./scripts/ansible.sh`.
- Inspect current managed state with `./scripts/ansible.sh ansible-playbook playbooks/status.yml -e phase_target=06`.
- Use `./scripts/kubectl.sh` only after phase03 is healthy.

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
│   └── phases/phase_00.yml..phase_06.yml  # Per-phase role dispatch
├── roles/                    # Desired state implementation by phase
│   ├── phase00..phase06/
│   │   ├── tasks/{rollup,rollback,status}.yml
│   │   └── templates/        # Present in phase02/phase04
├── scripts/                  # Operational entrypoints and local tooling
│   ├── ansible.sh            # Single ansible runtime wrapper (containerized)
│   ├── ssh.sh                # Direct SSH connectivity helper
│   ├── utils.sh              # Shared shell helpers for scripts
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
- `phase05`: helm binary lifecycle.
- `phase06`: cert-manager lifecycle.

## Phase Runtime Files
- Persist phase facts in `/var/lib/infra/phase/<id>/facts.json`.
- `status` playbook computes and prints live status; do not persist per-phase `status.json` going forward.

## Runtime Parameters
- `ANSIBLE_IMAGE`: execution environment image for ansible commands.
- `INFRA_SSH_HOST`: target host/IP for ansible inventory host.
- `INFRA_SSH_USER`: SSH user for target host.
- `INFRA_SSH_PRIVATE_KEY_B64` (required): base64-encoded private key, decoded at runtime.
- `INFRA_KUBECONFIG_PATH` (required by `scripts/kubectl.sh`): remote kubeconfig path copied to a temp file for each kubectl invocation.
- `INFRA_KUBECTL_TUNNEL_LOCAL_PORT` (optional by `scripts/kubectl.sh`, default `56443`): local loopback port used for SSH tunnel to remote apiserver `127.0.0.1:6443`.

## Local vs CI SSH Key Format
- Local `.env` uses `INFRA_SSH_PRIVATE_KEY_B64` because the helper scripts decode it into a temporary key file at runtime.
- CI secrets use raw private key text as `INFRA_SSH_PRIVATE_KEY`; workflows write it to a temporary file before invoking Ansible.
- CI also requires `INFRA_SSH_KNOWN_HOSTS`; use the exact `known_hosts` line for `INFRA_SSH_HOST` so workflow SSH uses strict host key checking.
- `inventory/group_vars/all.yml` `root_pubkey` should match the private key material used locally and in CI.
- Example local conversion: `base64 < ~/.ssh/keys/zhaoxi | tr -d '\n'`

## Core Inventory Variables
- `root_pubkey`: SSH key allowed for `root`.
- `k3s_api_endpoint`: endpoint used in k3s kubeconfig server URL (default `ansible_host`).

## Execution Entry
- Always run ansible through `scripts/ansible.sh`.
- Behavior:
  - No arguments: execute `ansible --version`.
  - With arguments: pass through directly to the container command.
- `scripts/ssh.sh`: direct SSH connectivity check or one-off remote commands.
- `scripts/kubectl.sh`: cluster access through the managed SSH tunnel workflow after k3s is ready.

## Common Commands
- `./scripts/ansible.sh`
- `./scripts/ssh.sh`
- `./scripts/ssh.sh uname -a`
- `./scripts/ansible.sh ansible infra -m ping`
- `./scripts/kubectl.sh`
- `./scripts/kubectl.sh get nodes -o wide`
- `./scripts/ansible.sh ansible-playbook playbooks/status.yml -e phase_target=06`
- `./scripts/ansible.sh ansible-playbook playbooks/rollup.yml -e phase_from=00 -e phase_to=06`
- `./scripts/ansible.sh ansible-playbook playbooks/rollback.yml -e phase_from=00 -e phase_to=06`

## Operation Semantics
- `status`: inspect the managed state up to `phase_target`; it is intended to be read-only and should be the first command when taking over an environment.
- `rollup`: converge phases forward from `phase_from` to `phase_to`.
- `rollback`: reverse phases from `phase_to` back toward `phase_from`.
- `phase_from` is inclusive in both directions; `rollback -e phase_from=03 -e phase_to=06` removes phases `06`, `05`, `04`, and `03`.
- Use `phase_from <= phase_to` only; both playbooks reject inverted ranges.
- Prefer `status -> rollup/rollback -> status` as the default operator sequence.

## Rollback Guidance
- Prefer rollback only after `status` confirms the current phase window and you have a clear target recovery point.
- Roll back to the lowest phase you still want to keep; that phase is included in the rollback window.
- Example: `rollback -e phase_from=03 -e phase_to=06` tears down `cert-manager`, `helm`, maintenance timers, and k3s, then validate with `status -e phase_target=03`.
- Example: `rollback -e phase_from=00 -e phase_to=00` removes only phase00-managed state for the regression checklist.
- After every rollback, rerun `status` at the retained boundary and confirm higher phases are no longer expected to be healthy.

## Phase Map
- `00 base`: base OS packages and phase state bootstrap.
- `01 ssh`: root SSH baseline and access policy.
- `02 network`: UFW and sysctl hardening.
- `03 k3s`: cluster install and API readiness.
- `04 maint`: logrotate, image GC, and release pruning.
- `05 helm`: helm binary lifecycle.
- `06 cert-manager`: cert-manager lifecycle.

## Kubectl Tunnel Workflow
- `scripts/kubectl.sh` is strict tunnel mode only.
- Each invocation copies remote kubeconfig from `INFRA_KUBECONFIG_PATH` to a temporary local file, opens SSH local-forward `127.0.0.1:${INFRA_KUBECTL_TUNNEL_LOCAL_PORT:-56443} -> 127.0.0.1:6443`, then executes local kubectl via `--server` + `--kubeconfig`.
- Tunnel and temp files are cleaned up automatically after command exit.
- Treat `scripts/kubectl.sh` as a post-phase03 tool; if k3s is not healthy yet, use `status` and `ssh.sh` first.

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

## Troubleshooting
- Missing `.env`: copy from `.env.example` and fill in SSH settings before running any helper script.
- SSH works in CI but not locally: confirm local `.env` uses `INFRA_SSH_PRIVATE_KEY_B64`, not raw private key text.
- `Permission denied (publickey)`: confirm local private key matches `root_pubkey` in `inventory/group_vars/all.yml`.
- CI host key verification failure: refresh `INFRA_SSH_KNOWN_HOSTS` from a trusted local `known_hosts` entry for `INFRA_SSH_HOST`.
- `status` output too terse: rerun the ansible command with `-v` for additional context.
