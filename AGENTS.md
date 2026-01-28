# infra Index

## Core Principles
- Idempotent (repeat runs converge to the same final state)
- Observable (explicit validation and checks)
- Prefer automatic rollback; if impossible, document risk + manual recovery steps

## Structure
- install.sh: single source of truth; calls scripts in strict order
- scripts/: executable ops (shell)
- resources/: static files/templates

## Script Index
- scripts/00-ssh-hardening.sh: placeholder, not implemented

## Risk Notes (Potential Principle Violations)
- Record any risk that could break idempotency, observability, or auto-rollback.
- scripts/00-ssh-hardening.sh: not implemented (no guarantees yet)
