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

## Technical Notes
- **Files Touched:** .task/*, scripts/kubectl.sh, .env.example, AGENTS.md, playbooks/{rollup,rollback,status}.yml, playbooks/phases/phase_06.yml, roles/phase00/tasks/rollup.yml, roles/phase03/tasks/{rollup,rollup_apply}.yml, roles/phase05/tasks/{rollup,rollup_apply,status,rollback}.yml, roles/phase06/tasks/{rollup,rollup_apply,status,rollback}.yml, inventory/group_vars/all.yml
- **New Dependencies:** 无
- **Blockers:** 无

---
*Archived to .task/archive/ when closed or reverted.*
