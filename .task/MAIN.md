# Task: 增加 kubectl 统一调用脚本

- **Branch:** feat/add-kubeconfig-smoke-check
- **Status:** Active
- **Last-Sync:** 2026-02-25T11:37:27Z (on ZQXY123deMacBook-Pro.local)
- **Current Context:** Script style alignment pass: kubectl/ssh wrappers now share SSH args builder and temp SSH key helper from utils.

## Phase Stack
> Current execution depth (Top is active)
  - 1.1: Kubectl Unified Script

## Timeline
- [2026-02-25T08:32:08Z] INITIALIZED: Task started on ZQXY123deMacBook-Pro.local.
- [2026-02-25T08:32:08Z] PHASE PUSH: Begin Phase 1.1 (add kubectl unified script + AGENTS command reference).
- [2026-02-25T08:32:51Z] UPDATE: Created .task from ~/.agent-task/templates and initialized Phase 1.1 records.
- [2026-02-25T08:34:38Z] UPDATE: Scope narrowed by user to `scripts/kubectl.sh` only; removed standalone smoke script direction.
- [2026-02-25T08:38:09Z] UPDATE: Added `scripts/kubectl.sh` with kubeconfig defaulting and remote kubectl passthrough via ssh.sh.
- [2026-02-25T08:38:09Z] UPDATE: Updated AGENTS common commands and validated default run (`kubectl get nodes`) successfully.
- [2026-02-25T08:40:54Z] UPDATE: Updated kubectl.sh to enforce tailscale kubeconfig server endpoint before execution.
- [2026-02-25T08:40:54Z] UPDATE: Validation now fails by design: expected `https://43.251.225.184:6443`, actual is `https://127.0.0.1:6443`.
- [2026-02-25T08:45:57Z] UPDATE: Session handoff checkpoint: `scripts/kubectl.sh` implemented and blocking correctly on endpoint mismatch; next step is to confirm remediation strategy with user.
- [2026-02-25T08:48:21Z] UPDATE: User confirmed endpoint policy: strict tailscale internal domain/MagicDNS only; no auto-reconcile fallback.
- [2026-02-25T08:49:55Z] UPDATE: Runtime check shows target tailscale state is `NeedsLogin` with empty `DNSName`/`MagicDNSSuffix`; must establish tailnet/MagicDNS before kubeconfig endpoint can be validated.
- [2026-02-25T09:37:34Z] UPDATE: User changed strategy to remove tailscale logic and return to plain SSH + remote kubectl path.
- [2026-02-25T09:44:56Z] UPDATE: Completed hard-cut cleanup in phase00/03, inventory/status vars, kubectl.sh, and AGENTS docs (`k3s_tailscale_fqdn` -> `k3s_api_endpoint`, `tailscale-kubeconfig` -> `ssh-kubeconfig`).
- [2026-02-25T09:44:56Z] UPDATE: Validated runtime: `./scripts/kubectl.sh` succeeds; `status phase_target=03` succeeds; `rollup 00->03` succeeds and idempotency pass returns `changed=0`.
- [2026-02-25T09:50:18Z] UPDATE: Full regression passed: `status phase_target=05` all `cur-success`; `rollup 00->05` succeeded; second `rollup 00->05` idempotency pass returned `changed=0`.
- [2026-02-25T09:51:50Z] UPDATE: Created WIP commit `9297f34` (`WIP: hard-cut tailscale path and validate phase 00-05`) for next-session continuation.
- [2026-02-25T09:55:27Z] UPDATE: Simplified `scripts/kubectl.sh`: removed duplicated `require_env` checks and `--kubeconfig` arg scanning; now passes `KUBECONFIG` env to remote kubectl by default.
- [2026-02-25T09:55:27Z] UPDATE: Validation passed after simplification (`bash -n scripts/kubectl.sh` and `./scripts/kubectl.sh`).
- [2026-02-25T09:56:54Z] UPDATE: Removed `scripts/ci.sh` per user request and updated AGENTS repository map; grep check confirms no residual `ci.sh` references.
- [2026-02-25T09:58:56Z] UPDATE: Updated `scripts/kubectl.sh` to require `INFRA_KUBECTL_BIN` and `INFRA_KUBECONFIG_PATH` as mandatory env vars.
- [2026-02-25T09:58:56Z] UPDATE: Added kubectl defaults to `.env.example` and documented both vars in AGENTS runtime parameters.
- [2026-02-25T09:58:56Z] UPDATE: Validation: syntax passed; runtime intentionally fails on current local `.env` because required kubectl vars are not yet configured.
- [2026-02-25T09:59:42Z] UPDATE: Re-validation after user `.env` update passed; both kubectl env vars are present and `./scripts/kubectl.sh` returns healthy node list.
- [2026-02-25T10:10:01Z] UPDATE: Refactored phase model: extracted cert-manager lifecycle from phase05 into new phase06; phase05 now owns helm binary lifecycle only.
- [2026-02-25T10:10:01Z] UPDATE: Validation passed: `status phase_target=06` all `cur-success`; first `rollup 00->06` converged; second `rollup 00->06` idempotency pass returned `changed=0`.
- [2026-02-25T10:46:57Z] UPDATE: Created WIP commit `a3d4339` (`WIP: split phase05 helm-only and add phase06 cert-manager`) for session handoff.
- [2026-02-25T10:55:49Z] UPDATE: Renamed phase03/05/06 rollup layering files to `rollup.check.yml` + `rollup.apply.yml` and kept `rollup.yml` as orchestration entrypoint.
- [2026-02-25T10:55:49Z] UPDATE: Validation passed: `./scripts/ansible.sh ansible-playbook playbooks/status.yml --syntax-check -e phase_target=06`.
- [2026-02-25T11:00:28Z] UPDATE: Runtime validation passed: `status phase_target=06` reported all phases `cur-success`.
- [2026-02-25T11:00:28Z] UPDATE: Double regression passed: both `rollup 00->06` runs succeeded with `changed=0` and no failures after naming refactor.
- [2026-02-25T11:07:46Z] UPDATE: Optimized phase03 gate checks: fixed version matching for literal `+k3s` strings, normalized etcd retention comparison to int, and corrected kubeconfig `replace` regex to Python-compatible pattern.
- [2026-02-25T11:07:46Z] UPDATE: Validation passed: `rollup 03->03` first run reconciled kubeconfig endpoint (`changed=1`), second run short-circuited with `phase03 already converged; skip apply path`.
- [2026-02-25T11:07:46Z] UPDATE: Full regression passed: `rollup 00->06` succeeded with `changed=0`, and phase03 apply path remained skipped when converged.
- [2026-02-25T11:09:16Z] UPDATE: Created WIP commit `c3f0eea` (`WIP: rename rollup check/apply layering and optimize phase03 gate`) for next-session continuation.
- [2026-02-25T11:25:14Z] UPDATE: Updated `scripts/kubectl.sh` to strict tunnel mode only; removed remote kubectl execution path.
- [2026-02-25T11:25:14Z] UPDATE: Added env-driven local tunnel port (`INFRA_KUBECTL_TUNNEL_LOCAL_PORT`, default `56443`) and disallowed `--kubeconfig` override.
- [2026-02-25T11:25:14Z] UPDATE: Updated `.env.example` and `AGENTS.md` runtime parameters to reflect strict tunnel workflow.
- [2026-02-25T11:25:14Z] UPDATE: Validation passed: `bash -n scripts/kubectl.sh` and default `./scripts/kubectl.sh` returned healthy node list.
- [2026-02-25T11:30:06Z] UPDATE: Simplified strict tunnel workflow further: `scripts/kubectl.sh` now reads fixed `./.kubeconfig` directly and no longer fetches/syncs remote kubeconfig.
- [2026-02-25T11:30:06Z] UPDATE: Removed `INFRA_KUBECONFIG_PATH` from `.env.example`/`AGENTS.md`; added `.kubeconfig` to `.gitignore`.
- [2026-02-25T11:30:06Z] UPDATE: Validation: syntax passed; runtime now intentionally fails when `./.kubeconfig` is absent.
- [2026-02-25T11:34:35Z] UPDATE: Switched `scripts/kubectl.sh` to minimal strategy: per-run `scp` from `INFRA_KUBECONFIG_PATH` to temp file, then run local kubectl with `--server https://127.0.0.1:<port> --kubeconfig <tmpfile>`.
- [2026-02-25T11:34:35Z] UPDATE: Restored `INFRA_KUBECONFIG_PATH` in `.env.example`/`AGENTS.md`; removed `.kubeconfig` ignore entry.
- [2026-02-25T11:34:35Z] UPDATE: Validation passed: `bash -n scripts/kubectl.sh` and `./scripts/kubectl.sh` both succeeded.
- [2026-02-25T11:37:27Z] UPDATE: Refactored script internals to reuse shared helpers: added `build_ssh_args` in `scripts/utils.sh` and switched `scripts/ssh.sh`/`scripts/kubectl.sh` to consume it.
- [2026-02-25T11:37:27Z] UPDATE: Updated `scripts/kubectl.sh` to reuse `generate_tmp_ssh_key_file` instead of bespoke key-file decode path.
- [2026-02-25T11:37:27Z] UPDATE: Regression passed: `bash -n scripts/{utils,ssh,kubectl}.sh`, `./scripts/ssh.sh`, and `./scripts/kubectl.sh`.
- [2026-02-25T11:39:35Z] UPDATE: Fixed tunnel cleanup in `scripts/kubectl.sh` by removing `exec kubectl` path; command now exits normally and triggers trap cleanup.
- [2026-02-25T11:39:35Z] UPDATE: Validation passed with temporary port 56444: kubectl call succeeded and no residual tunnel process matched that port after command exit.
- [2026-02-25T11:41:35Z] UPDATE: Encapsulated SSH tunnel startup in `start_ssh_tunnel` and removed `nc`-based local port probe/readiness loop from `scripts/kubectl.sh`.
- [2026-02-25T11:41:35Z] UPDATE: Tunnel startup now uses SSH control socket with `-f` + `ExitOnForwardFailure` to avoid readiness race while keeping script path simple.
- [2026-02-25T11:41:35Z] UPDATE: Validation passed: syntax ok, `./scripts/kubectl.sh get ns` success, and no residual local tunnel process after exit.

## Global References
- **Docs:** .task/MAIN.md
- **Scripts:** scripts/kubectl.sh
- **Assets:** N/A
---
*Generated by .task Convention - Synchronized via Git*
- [2026-02-25T11:48:00Z] UPDATE: Refactored `scripts/utils.sh` with layered helpers: added `ssh_*` atomic functions and `kubectl_session_*` business functions with explicit session handles.
- [2026-02-25T11:48:00Z] UPDATE: Simplified `scripts/kubectl.sh` to core flow (`build_ssh_args` + `ssh_build_dest` + `kubectl_session_open` + `kubectl_session_exec` + cleanup).
- [2026-02-25T11:48:00Z] UPDATE: Updated `scripts/ssh.sh` to reuse `ssh_build_dest`; regression passed (`bash -n`, `./scripts/ssh.sh`, `./scripts/kubectl.sh get ns`) and no residual tunnel process.
