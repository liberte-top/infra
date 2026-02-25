# Phase: 1.3 - Root-Only + Tailscale Kubeconfig Refactor

## Objective
按最新设计改造 phase00-05：建立 tailscale 基础能力、移除 `k8s-admin` 运行时依赖，并统一 k3s/cert-manager 的 tailscale 内建域名 kubeconfig 连接标准。

## Exit Criteria
- [x] phase00 纳入 tailscale 基础安装（不包含一次性手工迁移逻辑）。
- [ ] phase01 切换为 root-only SSH 体系，移除 `k3s_admin_user` 相关状态与检查。
- [ ] phase03 移除 admin kubeconfig 分发，改为 tailscale FQDN + kubeconfig 标准路径模型。
- [ ] phase04/05 清理 `k8s-admin` 路径耦合并保持可回归执行。
- [ ] 关键文档与变量定义完成同步（inventory/AGENTS/状态输出）。
- [ ] phase01-05 状态持久化统一为仅保留 facts.json（status 不落盘）。

## Work Log
- [2026-02-25T05:46:22Z] STARTED: Phase initialized from user-confirmed architecture decisions.
- [2026-02-25T05:52:29Z] COMPLETED: Updated phase00 rollup to include tailscale baseline package path.
- [2026-02-25T05:52:41Z] COMPLETED: Verified phase00 rollup idempotency (second rollup short-circuited with zero change).
- [2026-02-25T05:52:57Z] COMPLETED: Verified phase00 rollback path after tailscale inclusion.
- [2026-02-25T05:53:08Z] COMPLETED: Verified post-rollback status returns `phase=00 status=pre-ready`.
- [2026-02-25T05:53:15Z] UPDATED: User clarified phase01-05 should keep only facts.json persistence; next edits will apply this rule incrementally.

## Technical Notes
- **Migration Strategy:**
  - One-off dirty migration stays manual by user.
  - IaC keeps simple/clean desired state without compatibility branches for legacy user cleanup.

---
*This phase will be popped/archived upon meeting exit criteria.*
