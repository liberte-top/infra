# Phase: 1.1 - Baseline Snapshot & Simplification Scope

## Objective
建立 infra 仓库简化改造的初始基线：记录当前结构、明确可简化边界与后续重构输入。

## Exit Criteria
- [x] .task 已初始化并绑定当前任务分支。
- [x] 当前目录结构快照已写入 .task/resources/STRUCTURE_SNAPSHOT.txt。
- [ ] 与你确认简化优先级（scripts、playbooks、roles、docs）。

## Work Log
- [2026-02-25T03:37:46Z] STARTED: Phase initialized.
- [2026-02-25T03:37:46Z] COMPLETED: Created branch, initialized .task, captured baseline structure snapshot.
- [2026-02-25T03:48:43Z] COMPLETED: Initialized .env using ~/.ssh/config Host zhaoxi and passed SSH smoke (`./scripts/ssh.sh`).
- [2026-02-25T03:55:48Z] COMPLETED: Simplified scripts/ansible.sh and validated both ansible and ansible-playbook dispatch paths.
- [2026-02-25T03:59:06Z] COMPLETED: Removed dynamic docker TTY detection and kept minimal regular-use execution model.
- [2026-02-25T04:03:44Z] COMPLETED: Replaced no-arg interactive shell with ansible --version fallback and updated AGENTS.md contract.
- [2026-02-25T04:33:39Z] COMPLETED: Removed ansible/playbook auto-dispatch and switched ansible.sh to explicit command passthrough model.
- [2026-02-25T04:38:58Z] COMPLETED: Extracted arg normalization helper to scripts/utils.sh and simplified ansible.sh fallback handling.
- [2026-02-25T04:40:02Z] COMPLETED: Applied normalize_args pattern to scripts/ssh.sh and added upfront ssh command check.
- [2026-02-25T04:41:48Z] COMPLETED: Extracted temporary SSH key generation into scripts/utils.sh and reused it across ansible.sh/ssh.sh.
- [2026-02-25T04:47:37Z] COMPLETED: Audited live server status via status playbook (read-only) and verified phase artifacts under /var/lib/infra/phase.
- [2026-02-25T04:54:58Z] COMPLETED: Executed rollup verification (00->02) and confirmed phase01 success; phase02 failed on missing `community.general.ufw` module dependency.
- [2026-02-25T04:59:16Z] COMPLETED: Root-caused phase02 blocker by validating missing `community.general` in ansible image collection list.
- [2026-02-25T05:12:04Z] COMPLETED: Completed image research + runtime checks; no tested candidate image included `community.general` by default.
- [2026-02-25T05:16:34Z] COMPLETED: Performed local redundant docker image cleanup and verified post-cleanup capacity metrics.
- [2026-02-25T05:18:13Z] COMPLETED: Inspected build cache inventory and selected a conservative cleanup approach (time-filtered prune).
- [2026-02-25T05:24:22Z] COMPLETED: Finalized handoff notes for next session to start from phase02 dependency remediation.

## Technical Notes
- **Files Touched:**
  - .task/MAIN.md
  - .task/PHASE_1.1.md
  - .task/resources/STRUCTURE_SNAPSHOT.txt
  - .env
  - scripts/ansible.sh
  - scripts/ssh.sh
  - scripts/utils.sh
- **New Dependencies:**
  - None
- **Blockers:**
  - Waiting for scope confirmation.

---
*This phase will be popped/archived upon meeting exit criteria.*
