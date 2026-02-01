# infra playbook (skeleton)

## Run
```sh
set -a
source .env
set +a

ansible-playbook -i inventory/hosts.ini playbooks/rollup.yml -e phase_from=00 -e phase_to=00
ansible-playbook -i inventory/hosts.ini playbooks/status.yml -e phase_target=00
ansible-playbook -i inventory/hosts.ini playbooks/rollback.yml -e phase_from=00 -e phase_to=00
```
