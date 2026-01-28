# infra Index

## Core Principle
- Ansible playbooks must be:
  - Idempotent (repeat runs converge to the same final state)
  - Observable (explicit validation and checks)
  - Prefer automatic rollback; when rollback is impossible, document the risk and manual recovery steps

## Common Troubleshooting
- Add entries as issues recur (e.g., SSH auth, Python/apt, Ansible facts, idempotency).
- Recent apply succeeded: run `21426564766` (2026-01-28).

## Project Structure Details
- Inventory layout
- Roles layout
- Playbooks
- CI workflows

# SSH (P0) Notes
- Managed via GitHub Secrets:
  - `PROD_SSH_PRIVATE_KEY` (SSH connect)
  - `INFRA_K8S_ADMIN_PUBKEY` (authorized_keys for k8s_admin)
- `ci.apply` runs `playbooks/ssh.yml` with the pubkey secret.

## Playbook Risk Notes (Potential Principle Violations)
- Record any risk that could break idempotency, observability, or auto-rollback.
- `playbooks/ssh.yml`: if `wait_for_connection` is disabled or key mismatch, verify step can be skipped; ensure validate-on-write remains enabled.
- `playbooks/ssh.yml`: sudoers drop-in uses `NOPASSWD: ALL`; reduce scope later if needed.

# Notes
- Keep this file low-frequency. Reference from top-level playbook only.
