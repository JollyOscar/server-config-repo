# 🔐 SSH Hardening Deployment Guide

This guide provides detailed SSH hardening procedures following Ubuntu's official recommendations.

> ⚠️ **For complete system deployment**, see [`STEP-BY-STEP-GUIDE.md`](../../docs/STEP-BY-STEP-GUIDE.md) in the repository root.

## Pre-Deployment Checklist

### 1. Backup Current Configuration

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.factory-defaults
sudo chmod a-w /etc/ssh/sshd_config.factory-defaults
```

### 2. Install Required Packages

```bash
sudo apt-get update
sudo apt-get install openssh-server ufw
```

## Deployment Steps

### 1. Deploy SSH Configuration

```bash
# Copy the hardened configuration
sudo cp /opt/server-config-repo/hardening/sshd_config /etc/ssh/

# Optional: Enable login banner
sudo cp /opt/server-config-repo/hardening/issue.net /etc/
# Then uncomment the Banner line in /etc/ssh/sshd_config
```

### 2. Configure SSH Keys (REQUIRED)

**CRITICAL: Set up SSH keys BEFORE disabling password authentication!**

```bash
# On your client machine, generate SSH key pair
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy public key to server
ssh-copy-id -p 2222 username@server_ip
```

### 3. Test Configuration

**Before restarting SSH, test the configuration:**

```bash
# Test configuration syntax
sudo sshd -t

# If no errors, restart SSH
sudo systemctl restart ssh
```

## Troubleshooting

### Check SSH Daemon Status

```bash
# Verify SSH daemon is running
ps -A | grep sshd

# Check if SSH is listening on correct port
sudo ss -lnp | grep sshd
```

### 3. Deploy Fail2ban Custom Rules

The `user.rules` file contains enhanced intrusion detection patterns:

```bash
# Deploy custom fail2ban rules
sudo cp /opt/server-config-repo/configs/hardening/user.rules /etc/fail2ban/filter.d/
sudo chown root:root /etc/fail2ban/filter.d/user.rules
sudo chmod 644 /etc/fail2ban/filter.d/user.rules

# Restart fail2ban to load new rules
sudo systemctl restart fail2ban

# Verify custom rules are loaded
sudo fail2ban-client status
```

### Test Connection

```bash
# Test SSH connection
ssh -p 2222 username@server_ip

# Check SSH logs for issues
sudo tail -f /var/log/auth.log

# Monitor fail2ban activity
sudo fail2ban-client status sshd
sudo fail2ban-client status custom-ssh
```

## Recovery Procedures

### If Locked Out

```bash
# From console/physical access, restore defaults
sudo cp /etc/ssh/sshd_config.factory-defaults /etc/ssh/sshd_config
sudo systemctl restart ssh
```

## References

- Ubuntu Server Guide: SSH Configuration
- OpenSSH Manual Pages
