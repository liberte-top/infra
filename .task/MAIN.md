# Task: 简化 infra 层代码

- **Branch:** feat/simplify-infra-layer
- **Status:** Active
- **Last-Sync:** 2026-02-25T06:27:05Z (on ZQXY123deMacBook-Pro.local)
- **Current Context:** phase00-02 的 facts-only 与短路控制流统一已完成并回归通过；下一会话从 phase03（tailscale kubeconfig 标准化 + k8s-admin 解耦）继续。

## Phase Stack
> Current execution depth (Top is active)
  - 1.3: Root-Only + Tailscale Kubeconfig Refactor
  - 1.2: Phase02 Dependency-Free Remediation
  - 1.1: Baseline Snapshot & Simplification Scope

## Timeline
- [2026-02-25T03:37:46Z] INITIALIZED: Task started on ZQXY123deMacBook-Pro.local.
- [2026-02-25T03:37:46Z] PHASE PUSH: Begin Phase 1.1 (baseline snapshot + simplification scope alignment).
- [2026-02-25T03:48:43Z] UPDATE: Initialized .env from Host zhaoxi (host/user/key) and ran SSH smoke test successfully.
- [2026-02-25T03:55:48Z] UPDATE: Refactored scripts/ansible.sh to simplify flow and validated ansible/ansible-playbook dispatch paths.
- [2026-02-25T03:59:06Z] UPDATE: Removed dynamic TTY detection; keep fixed -it only for no-arg shell and regular execution path without -t.
- [2026-02-25T04:03:44Z] UPDATE: Switched no-arg behavior to ansible --version fallback and aligned AGENTS.md behavior docs.
- [2026-02-25T04:33:39Z] UPDATE: Removed command prediction in ansible.sh, switched to direct passthrough, and updated AGENTS.md examples to explicit ansible-playbook usage.
- [2026-02-25T04:38:58Z] UPDATE: Extracted default-args normalization into scripts/utils.sh (normalize_args) and wired ansible.sh to use it.
- [2026-02-25T04:40:02Z] UPDATE: Applied the same simplification to scripts/ssh.sh using normalize_args and require_command ssh.
- [2026-02-25T04:41:48Z] UPDATE: Extracted temporary SSH key file generation into shared utils function and reused it in ansible.sh/ssh.sh.
- [2026-02-25T04:47:37Z] UPDATE: Performed read-only server status audit (phase_target=05) and collected on-host phase files to verify real progress.
- [2026-02-25T04:54:58Z] UPDATE: Ran deployment verification (rollup 00->02 + status 02). Phase01 reached cur-success; phase02 blocked by missing ansible collection for ufw module.
- [2026-02-25T04:59:16Z] UPDATE: Confirmed root cause by inspecting phase02 tasks and ansible-galaxy collections list; community.general is missing from current execution image.
- [2026-02-25T05:12:04Z] UPDATE: Researched and tested common EE images; none provided community.general out-of-box in this environment.
- [2026-02-25T05:16:34Z] UPDATE: Cleaned local redundant docker images via image prune and captured before/after disk usage.
- [2026-02-25T05:18:13Z] UPDATE: Audited docker build cache state (builder du/verbose) and prepared selective prune strategy.
- [2026-02-25T05:24:22Z] UPDATE: Prepared handoff context for next session; next focus is phase02 dependency fix and redeploy validation.
- [2026-02-25T05:25:10Z] UPDATE: Confirmed remediation direction with user: remove phase02 `ufw` module dependency and use CLI commands.
- [2026-02-25T05:25:11Z] PHASE PUSH: Begin Phase 1.2 (phase02 dependency-free remediation + validation).
- [2026-02-25T05:31:24Z] UPDATE: Replaced phase02 rollup/rollback `ufw` module tasks with `ufw` CLI command tasks.
- [2026-02-25T05:34:10Z] UPDATE: Ran phase02 rollback validation successfully after dependency-free refactor.
- [2026-02-25T05:34:39Z] UPDATE: Verified status flow post-rollback (`phase=02 status=pre-ready`).
- [2026-02-25T05:35:18Z] UPDATE: Added explicit `loop_var` for phase02 UFW loops and re-validated rollup without loop-collision warnings.
- [2026-02-25T05:46:22Z] UPDATE: Confirmed new target with user: phase00 includes tailscale baseline; phase01+ uses root-only model and tailscale built-in-domain kubeconfig.
- [2026-02-25T05:46:22Z] PHASE PUSH: Begin Phase 1.3 (phase00-05 refactor for root-only + tailscale kubeconfig standardization).
- [2026-02-25T05:53:15Z] UPDATE: Completed phase00 refactor by adding tailscale baseline package path and passed status/rollup/idempotency/rollback/status regression chain.
- [2026-02-25T05:53:15Z] UPDATE: Aligned implementation direction with user reminder: phase01-05 should persist only facts.json; status remains read-only validation.
- [2026-02-25T05:56:33Z] UPDATE: Prepared session handoff checkpoint; next session starts from phase01 root-only + facts-only persistence refactor.
- [2026-02-25T06:01:30Z] UPDATE: Started incremental phase01 refactor to root-only SSH model and facts-only persistence.
- [2026-02-25T06:04:13Z] UPDATE: Completed phase01 rollup/status/rollback refactor (remove k3s_admin_user checks, switch to root key + facts.json, drop status.json writes).
- [2026-02-25T06:04:13Z] UPDATE: Verified scoped regression for phase00-01 with status + rollup + idempotency rollup + status; all runs succeeded and second rollup stayed unchanged.
- [2026-02-25T06:08:03Z] UPDATE: Completed phase02 rollup/status/rollback refactor to facts-only persistence (`facts.json`), and removed `status.json` read/write path.
- [2026-02-25T06:08:03Z] UPDATE: Verified scoped regression for phase00-02 (`status -> rollup -> rollup -> status`); status remains `cur-success` for 00/01/02.
- [2026-02-25T06:20:49Z] UPDATE: Simplified phase02 rollup control flow by guarding mutable tasks with `when: not phase02_ready`, preventing unnecessary apply path when already converged.
- [2026-02-25T06:20:49Z] UPDATE: Aligned phase02 UFW logging readiness check with actual `ufw status verbose` format (`Logging: on (<level>)`) to make short-circuit effective.
- [2026-02-25T06:20:49Z] UPDATE: Verified phase00-02 double rollup now both `changed=0`; final status remains `00/01/02=cur-success`.
- [2026-02-25T06:25:47Z] UPDATE: Refactored phase01 rollup to use `stat + slurp when exists` for facts loading (removed error-driven control flow).
- [2026-02-25T06:25:47Z] UPDATE: Unified phase00/phase01 rollup short-circuit style to guarded apply blocks (`when: not ready`) for clearer and consistent control flow.
- [2026-02-25T06:25:47Z] UPDATE: Verified phase00-01 regression (`rollup -> rollup -> status`) with both rollups `changed=0` and final status `00/01=cur-success`.
- [2026-02-25T06:27:05Z] UPDATE: Session handoff checkpoint prepared; next implementation target is phase03 refactor.

## Global References
- **Docs:** .task/MAIN.md
- **Scripts:** scripts/ansible.sh
- **Assets:** .task/resources/STRUCTURE_SNAPSHOT.txt
---
*Generated by .task Convention - Synchronized via Git*
