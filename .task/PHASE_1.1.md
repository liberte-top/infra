# Phase: 1.1 - Kubectl Unified Script

## Objective
新增一个可重复执行的 `scripts/kubectl.sh` 统一入口，通过 tailscale + kubeconfig 执行标准 kubectl 调用。

## Exit Criteria
- [x] 提供 `scripts/kubectl.sh`，可在 infra 根目录直接运行。
- [x] 默认路径使用远端 kubeconfig，并支持透传标准 kubectl 参数。
- [x] `AGENTS.md` 增加该脚本的使用命令。
- [ ] tailscale endpoint 策略确认并完成最终行为（严格失败或自动对齐）。
- [x] .task 记录同步。

## Work Log
- [2026-02-25T08:32:08Z] @ZQXY123deMacBook-Pro.local: Phase initialized.
- [2026-02-25T08:34:38Z] @ZQXY123deMacBook-Pro.local: Scope updated by user: implement kubectl.sh only.
- [2026-02-25T08:38:09Z] @ZQXY123deMacBook-Pro.local: Implemented `scripts/kubectl.sh` and added command examples to AGENTS.
- [2026-02-25T08:38:09Z] @ZQXY123deMacBook-Pro.local: Validation passed via default call (`./scripts/kubectl.sh` -> `kubectl get nodes`).
- [2026-02-25T08:40:54Z] @ZQXY123deMacBook-Pro.local: Added strict tailscale endpoint enforcement in kubectl.sh before command execution.
- [2026-02-25T08:40:54Z] @ZQXY123deMacBook-Pro.local: Validation failed as expected due kubeconfig server mismatch (`127.0.0.1` vs tailscale target).
- [2026-02-25T08:45:57Z] @ZQXY123deMacBook-Pro.local: Prepared WIP handoff; pending user decision on mismatch remediation policy.

## Technical Notes
- **Files Touched:** .task/*, scripts/kubectl.sh, AGENTS.md
- **New Dependencies:** 无
- **Blockers:** Remote kubeconfig currently points to `https://127.0.0.1:6443`; strict tailscale enforcement blocks execution until endpoint is reconciled.

---
*Archived to .task/archive/ when closed or reverted.*
