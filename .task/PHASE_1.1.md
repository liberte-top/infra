# Phase: 1.1 - Kubectl Unified Script

## Objective
新增一个可重复执行的 `scripts/kubectl.sh` 统一入口，通过 SSH + 远端 kubeconfig 执行标准 kubectl 调用，并清理 phase00-05 中 tailscale 相关逻辑。

## Exit Criteria
- [x] 提供 `scripts/kubectl.sh`，可在 infra 根目录直接运行。
- [x] 默认路径使用远端 kubeconfig，并支持透传标准 kubectl 参数。
- [x] `AGENTS.md` 增加该脚本的使用命令。
- [x] `phase00-05` 运行路径中不再包含 tailscale 相关逻辑与变量命名。
- [x] kubectl 入口不再执行 tailscale endpoint 强校验，恢复朴素 SSH 远端执行模式。
- [x] 执行验证：`kubectl.sh`、`status phase_target=03`、`rollup 00->03` 及幂等 pass 成功。
- [x] .task 记录同步。

## Work Log
- [2026-02-25T08:32:08Z] @ZQXY123deMacBook-Pro.local: Phase initialized.
- [2026-02-25T08:34:38Z] @ZQXY123deMacBook-Pro.local: Scope updated by user: implement kubectl.sh only.
- [2026-02-25T08:38:09Z] @ZQXY123deMacBook-Pro.local: Implemented `scripts/kubectl.sh` and added command examples to AGENTS.
- [2026-02-25T08:38:09Z] @ZQXY123deMacBook-Pro.local: Validation passed via default call (`./scripts/kubectl.sh` -> `kubectl get nodes`).
- [2026-02-25T08:40:54Z] @ZQXY123deMacBook-Pro.local: Added strict tailscale endpoint enforcement in kubectl.sh before command execution.
- [2026-02-25T08:40:54Z] @ZQXY123deMacBook-Pro.local: Validation failed as expected due kubeconfig server mismatch (`127.0.0.1` vs tailscale target).
- [2026-02-25T08:45:57Z] @ZQXY123deMacBook-Pro.local: Prepared WIP handoff; pending user decision on mismatch remediation policy.
- [2026-02-25T08:48:21Z] @ZQXY123deMacBook-Pro.local: User confirmed strict tailscale internal domain/MagicDNS policy (no auto-reconcile).
- [2026-02-25T08:49:55Z] @ZQXY123deMacBook-Pro.local: Verified target tailscale runtime is `NeedsLogin`; MagicDNS unavailable until node joins tailnet.
- [2026-02-25T09:37:34Z] @ZQXY123deMacBook-Pro.local: User changed direction: remove tailscale logic and use plain SSH remote kubectl flow.
- [2026-02-25T09:44:56Z] @ZQXY123deMacBook-Pro.local: Hard-cut migration completed (`k3s_api_endpoint` + `ssh-kubeconfig` semantics) and runtime validations passed.
- [2026-02-25T09:51:50Z] @ZQXY123deMacBook-Pro.local: Saved handoff checkpoint via WIP commit `9297f34` for next session.
- [2026-02-25T09:55:27Z] @ZQXY123deMacBook-Pro.local: Simplified kubectl wrapper by removing duplicated env checks and kubeconfig arg scan; switched to remote `KUBECONFIG` default injection.
- [2026-02-25T09:56:54Z] @ZQXY123deMacBook-Pro.local: Removed unused `scripts/ci.sh` and updated AGENTS script list accordingly.
- [2026-02-25T09:58:56Z] @ZQXY123deMacBook-Pro.local: Tightened kubectl env contract: `INFRA_KUBECTL_BIN` and `INFRA_KUBECONFIG_PATH` are now required; defaults added in `.env.example`.
- [2026-02-25T09:59:42Z] @ZQXY123deMacBook-Pro.local: Re-validated with updated local `.env`; kubectl wrapper executes successfully and node listing is healthy.
- [2026-02-25T10:10:01Z] @ZQXY123deMacBook-Pro.local: Split phase05/phase06 responsibilities: phase05 helm-only, phase06 cert-manager lifecycle; status/rollup validation passed with phase target 06.
- [2026-02-25T10:46:57Z] @ZQXY123deMacBook-Pro.local: Saved WIP handoff commit `a3d4339` after phase split and full 00->06 regression.
- [2026-02-25T10:55:49Z] @ZQXY123deMacBook-Pro.local: Renamed rollup layering files in phase03/05/06 to `rollup.check.yml` + `rollup.apply.yml`; kept `rollup.yml` as stable orchestration entrypoint.
- [2026-02-25T10:55:49Z] @ZQXY123deMacBook-Pro.local: Validation passed via `ansible-playbook --syntax-check` on `playbooks/status.yml` with `phase_target=06`.
- [2026-02-25T11:00:28Z] @ZQXY123deMacBook-Pro.local: Runtime status validation passed (`status phase_target=06` => phase00..06 all `cur-success`).
- [2026-02-25T11:00:28Z] @ZQXY123deMacBook-Pro.local: Runtime double-rollup regression passed (`rollup 00->06` x2, both `changed=0`, no failures) after rollup file naming refactor.
- [2026-02-25T11:07:46Z] @ZQXY123deMacBook-Pro.local: Fixed phase03 gate false-negative causes: literal k3s version matching (`+k3s`), etcd retention type coercion (`int`), and kubeconfig endpoint `replace` regex (POSIX -> Python regex).
- [2026-02-25T11:07:46Z] @ZQXY123deMacBook-Pro.local: Validation passed: `rollup 03->03` first pass reconciled kubeconfig endpoint (`changed=1`), second pass short-circuited and skipped apply path.
- [2026-02-25T11:07:46Z] @ZQXY123deMacBook-Pro.local: Validation passed: full `rollup 00->06` with phase03 converged skip behavior and overall `changed=0`.
- [2026-02-25T11:09:16Z] @ZQXY123deMacBook-Pro.local: Saved handoff checkpoint via WIP commit `c3f0eea` after rollup naming refactor + phase03 gate/endpoint fixes.
- [2026-02-25T11:25:14Z] @ZQXY123deMacBook-Pro.local: Refactored `scripts/kubectl.sh` to strict SSH tunnel mode only with local kubectl execution.
- [2026-02-25T11:25:14Z] @ZQXY123deMacBook-Pro.local: Added tunnel local port env `INFRA_KUBECTL_TUNNEL_LOCAL_PORT` (default `56443`) and blocked `--kubeconfig` override for strict mode.
- [2026-02-25T11:25:14Z] @ZQXY123deMacBook-Pro.local: Updated `.env.example` + `AGENTS.md`; validation passed (`bash -n scripts/kubectl.sh`, `./scripts/kubectl.sh`).
- [2026-02-25T11:30:06Z] @ZQXY123deMacBook-Pro.local: Simplified kubectl tunnel path to fixed `./.kubeconfig` only; removed remote kubeconfig fetch/sync logic.
- [2026-02-25T11:30:06Z] @ZQXY123deMacBook-Pro.local: Updated docs/env/gitignore (`INFRA_KUBECONFIG_PATH` removed, `.kubeconfig` ignored).
- [2026-02-25T11:30:06Z] @ZQXY123deMacBook-Pro.local: Validation passed for syntax; runtime now explicitly requires `./.kubeconfig`.
- [2026-02-25T11:34:35Z] @ZQXY123deMacBook-Pro.local: Reworked kubectl flow to minimal runtime path (`scp` remote kubeconfig to temp file + `kubectl --server` over SSH tunnel).
- [2026-02-25T11:34:35Z] @ZQXY123deMacBook-Pro.local: Restored `INFRA_KUBECONFIG_PATH` as required env and removed `.kubeconfig` repository coupling.
- [2026-02-25T11:34:35Z] @ZQXY123deMacBook-Pro.local: Validation passed (`bash -n scripts/kubectl.sh`, `./scripts/kubectl.sh`).
- [2026-02-25T11:37:27Z] @ZQXY123deMacBook-Pro.local: Added shared `build_ssh_args` helper in `scripts/utils.sh` and aligned `scripts/ssh.sh` + `scripts/kubectl.sh` to the same SSH arg construction path.
- [2026-02-25T11:37:27Z] @ZQXY123deMacBook-Pro.local: Replaced bespoke SSH key tempfile handling in `scripts/kubectl.sh` with `generate_tmp_ssh_key_file` helper.
- [2026-02-25T11:37:27Z] @ZQXY123deMacBook-Pro.local: Regression passed (`bash -n` checks + `./scripts/ssh.sh` + `./scripts/kubectl.sh`).
- [2026-02-25T11:39:35Z] @ZQXY123deMacBook-Pro.local: Removed `exec kubectl` from `scripts/kubectl.sh` to ensure EXIT trap always runs and closes SSH tunnel.
- [2026-02-25T11:39:35Z] @ZQXY123deMacBook-Pro.local: Verified with temporary local port 56444: command succeeded and tunnel process was cleaned up after exit.
- [2026-02-25T11:41:35Z] @ZQXY123deMacBook-Pro.local: Wrapped SSH tunnel logic into `start_ssh_tunnel` and removed redundant `nc` port detection logic from `scripts/kubectl.sh`.
- [2026-02-25T11:41:35Z] @ZQXY123deMacBook-Pro.local: Switched tunnel lifecycle to SSH control socket (`-M -S -f`) with cleanup via `ssh -O exit` to avoid startup race and ensure teardown.
- [2026-02-25T11:41:35Z] @ZQXY123deMacBook-Pro.local: Validation passed (`bash -n scripts/kubectl.sh`, `./scripts/kubectl.sh get ns`, no residual tunnel process).

## Technical Notes
- **Files Touched:** .task/*, scripts/kubectl.sh, .env.example, AGENTS.md, playbooks/{rollup,rollback,status}.yml, playbooks/phases/phase_06.yml, roles/phase00/tasks/rollup.yml, roles/phase03/tasks/{rollup,rollup.check,rollup.apply}.yml, roles/phase05/tasks/{rollup,rollup.check,rollup.apply,status,rollback}.yml, roles/phase06/tasks/{rollup,rollup.check,rollup.apply,status,rollback}.yml, inventory/group_vars/all.yml
- **New Dependencies:** 无
- **Blockers:** 无

---
*Archived to .task/archive/ when closed or reverted.*
- [2026-02-25T11:48:00Z] @ZQXY123deMacBook-Pro.local: Added layered helper design in `scripts/utils.sh`: `ssh_build_dest`/`ssh_build_tunnel_spec`/`ssh_copy_remote_file`/`ssh_tunnel_start`/`ssh_tunnel_stop` and `kubectl_session_open`/`kubectl_session_close`/`kubectl_session_exec`.
- [2026-02-25T11:48:00Z] @ZQXY123deMacBook-Pro.local: Reduced `scripts/kubectl.sh` to high-level orchestration calls using session handles; removed in-script tunnel/file plumbing details.
- [2026-02-25T11:48:00Z] @ZQXY123deMacBook-Pro.local: Validation passed (`bash -n scripts/{utils,ssh,kubectl}.sh`, `./scripts/ssh.sh`, `./scripts/kubectl.sh get ns`, no tunnel residue).
