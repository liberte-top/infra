# infra

Ansible is the source of truth for base system dependencies and machine setup.

## Layout
- playbooks/: top-level playbooks
- inventories/: environment inventories
- roles/: reusable roles

## Quick start
1) Update `inventories/production/hosts.yml`
2) Adjust `group_vars/all.yml`
3) Run:
   ansible-playbook playbooks/base.yml
