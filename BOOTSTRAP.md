# BOOTSTRAP (Phase -1)

Purpose: minimal manual initialization so CI can connect via SSH key and run sudo.
Scope: one-time manual steps on a fresh server, before any phase rollup.

## Inputs (prepare locally)
- infra host: <IP or hostname>
- admin login method for initial access: password or console
- **Root SSH public key (must be provided manually by the user)**: <ROOT_PUBKEY>

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

3) Password login policy (bootstrap strategy)
- **Start with password login enabled**, verify key login works, then disable password login.
- Keep password login (initial bootstrap):
```sh
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config.d/99-bootstrap.conf
```
- Disable password login (after key login works):
```sh
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config.d/99-bootstrap.conf
```

4) Validate and reload SSHD
```sh
sshd -t
systemctl reload ssh
```

5) Upload private key to repo secrets (for CI)
```sh
# run locally (requires gh auth)
cd /path/to/infra
gh secret set INFRA_SSH_HOST --body "<host>"
gh secret set INFRA_SSH_USER --body "<user>"
gh secret set INFRA_SSH_PRIVATE_KEY --body "$(cat ~/.ssh/keys/zhaoxi)"
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

## Common Issues (FAQ)
1) Host key changed after rebuild
```sh
ssh-keygen -R <host>
```

2) `Permission denied (publickey)`
- Confirm the public key is in `/root/.ssh/authorized_keys`.
- Check permissions: `/root/.ssh` = 700, `/root/.ssh/authorized_keys` = 600.
- Ensure `PubkeyAuthentication yes` and `AllowUsers root` are set.

3) `Connection closed by <host> port 22`
- Validate config: `sshd -t`
- Check service: `systemctl status ssh`
- Verify no syntax errors in `/etc/ssh/sshd_config.d/99-bootstrap.conf`.

4) `sudo` prompts for password in CI
- Use root for the initial bootstrap.
- For non-root, ensure the user has passwordless sudo.
