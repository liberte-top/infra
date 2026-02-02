# BOOTSTRAP (Phase -1)

Purpose: minimal manual initialization so CI can connect via SSH key and run sudo.
Scope: one-time manual steps on a fresh server, before any phase rollup.

## Inputs (prepare locally)
- infra host: <IP or hostname>
- admin login method for initial access: password or console
- root SSH public key for CI: <ROOT_PUBKEY>

## Target State (minimum)
- root SSH public key installed.
- SSHD allows key auth; password auth policy decided.
- AllowUsers includes root (and optionally other admins).

## Manual Steps (run on server)

1) Install root public key
```sh
mkdir -p /root/.ssh
chmod 700 /root/.ssh
cat <<'KEY' > /root/.ssh/authorized_keys
<ROOT_PUBKEY>
KEY
chmod 600 /root/.ssh/authorized_keys
```

2) SSHD hardening baseline (key auth on)
```sh
# Prefer to use a drop-in file
mkdir -p /etc/ssh/sshd_config.d
cat <<'EOF' > /etc/ssh/sshd_config.d/99-bootstrap.conf
PubkeyAuthentication yes
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
AllowUsers root
EOF
```

3) Password login policy (choose one)
- Keep password login (less secure):
```sh
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config.d/99-bootstrap.conf
```
- Disable password login (recommended after key login works):
```sh
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config.d/99-bootstrap.conf
```

4) Validate and reload SSHD
```sh
sshd -t
systemctl reload ssh
```

## Verification
```sh
# from local machine
ssh root@<host> 'whoami'
ssh root@<host> 'sudo -n true'
```

## Notes
- This Phase -1 is required if password login is disabled; otherwise CI cannot connect.
- After CI is working, prefer disabling password login and relying on keys.
