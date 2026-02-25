# Phase: 1.3 - Root-Only + Tailscale Kubeconfig Refactor

## Objective
按最新设计改造 phase00-05：建立 tailscale 基础能力、移除 `k8s-admin` 运行时依赖，并统一 k3s/cert-manager 的 tailscale 内建域名 kubeconfig 连接标准。

## Exit Criteria
- [x] phase00 纳入 tailscale 基础安装（不包含一次性手工迁移逻辑）。
- [x] phase01 切换为 root-only SSH 体系，移除 `k3s_admin_user` 相关状态与检查。
- [x] phase03 移除 admin kubeconfig 分发，改为 tailscale FQDN + kubeconfig 标准路径模型。
- [x] phase04/05 清理 `k8s-admin` 路径耦合并保持可回归执行。
- [x] 关键文档与变量定义完成同步（inventory/AGENTS/状态输出）。
- [x] phase01-05 状态持久化统一为仅保留 facts.json（status 不落盘）。

## Work Log
- [2026-02-25T05:46:22Z] STARTED: Phase initialized from user-confirmed architecture decisions.
- [2026-02-25T05:52:29Z] COMPLETED: Updated phase00 rollup to include tailscale baseline package path.
- [2026-02-25T05:52:41Z] COMPLETED: Verified phase00 rollup idempotency (second rollup short-circuited with zero change).
- [2026-02-25T05:52:57Z] COMPLETED: Verified phase00 rollback path after tailscale inclusion.
- [2026-02-25T05:53:08Z] COMPLETED: Verified post-rollback status returns `phase=00 status=pre-ready`.
- [2026-02-25T05:53:15Z] UPDATED: User clarified phase01-05 should keep only facts.json persistence; next edits will apply this rule incrementally.
- [2026-02-25T06:01:30Z] COMPLETED: Refactored phase01 rollup/status/rollback to root-only model and switched phase01 state persistence from `state.json` to `facts.json`.
- [2026-02-25T06:01:30Z] COMPLETED: Removed phase01 `status.json` read/write path; status play now computes live state and only updates `phase_status_map`.
- [2026-02-25T06:04:13Z] COMPLETED: Passed scoped validation for phase00-01 (`status -> rollup -> rollup(idempotency) -> status`), with second rollup reporting zero changes.
- [2026-02-25T06:08:03Z] COMPLETED: Refactored phase02 rollup/status/rollback to `facts.json` persistence and removed `status.json` read/write.
- [2026-02-25T06:08:03Z] COMPLETED: Passed scoped validation for phase00-02 (`status -> rollup -> rollup -> status`) with final status `00/01/02=cur-success`.
- [2026-02-25T06:20:49Z] COMPLETED: Simplified phase02 rollup control flow by wrapping mutable tasks in a `when: not phase02_ready` block.
- [2026-02-25T06:20:49Z] COMPLETED: Fixed phase02 UFW logging readiness pattern to match `ufw status verbose`, making rollup short-circuit deterministic.
- [2026-02-25T06:20:49Z] COMPLETED: Re-validated phase00-02 double rollup with both runs `changed=0` and no phase02 mutate-path execution.
- [2026-02-25T06:25:47Z] COMPLETED: Refactored phase01 facts loading from `ignore_errors` pattern to `stat + conditional slurp`, aligning with phase00 style.
- [2026-02-25T06:25:47Z] COMPLETED: Unified phase00/phase01 rollup control flow with guarded apply blocks (`when: not ready`) for consistent behavior across phases.
- [2026-02-25T06:25:47Z] COMPLETED: Re-validated phase00-01 (`rollup -> rollup -> status`) with both rollups `changed=0` and final status `00/01=cur-success`.
- [2026-02-25T06:27:05Z] UPDATED: Prepared handoff for next session; phase03 is the next incremental target.
- [2026-02-25T06:34:26Z] STARTED: Resumed implementation for phase03-05 refactor batch (k8s-admin decoupling + tailscale kubeconfig + facts-only status model).
- [2026-02-25T06:34:26Z] COMPLETED: Refactored phase03 rollup/status/rollback to facts-only and removed admin kubeconfig copy/removal flow.
- [2026-02-25T06:34:26Z] COMPLETED: Standardized phase03 kubeconfig endpoint/server to `https://{{ k3s_tailscale_fqdn | default(ansible_host) }}:6443` with k3s `--tls-san`.
- [2026-02-25T06:34:26Z] COMPLETED: Refactored phase04/05 rollup/status/rollback to facts-only (`facts.json`) and removed status-file persistence.
- [2026-02-25T06:34:26Z] COMPLETED: Decoupled phase04 release-prune root default from `/home/k8s-admin/releases` to `/var/lib/infra/releases` (root-owned).
- [2026-02-25T06:34:26Z] COMPLETED: Synced inventory/status/AGENTS docs (`k3s_tailscale_fqdn`, root-only allow users, phase ownership text).
- [2026-02-25T06:47:38Z] COMPLETED: Live regression passed (`status 05 -> rollup 03-05 -> rollup 03-05 -> status 05`) with final `00..05=cur-success`.
- [2026-02-25T06:47:38Z] COMPLETED: Verified rollup idempotency convergence at steady state (`changed=0`) and cleared loop-var collision warnings.
- [2026-02-25T06:51:06Z] COMPLETED: Phase 1.3 deliverables finalized and synchronized before single-commit consolidation.

## Technical Notes
- **Migration Strategy:**
  - One-off dirty migration stays manual by user.
  - IaC keeps simple/clean desired state without compatibility branches for legacy user cleanup.

---
*This phase will be popped/archived upon meeting exit criteria.*
