# 🔐 SSH Hardening Deployment Guide

This guide provides detailed SSH hardening procedures following Ubuntu's official recommendations.

> ⚠️ **For complete system deployment**, see [`STEP-BY-STEP-GUIDE.md`](../STEP-BY-STEP-GUIDE.md) in the repository root.

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

### Test Connection

```bash
# Test SSH connection
ssh -p 2222 username@server_ip

# Check SSH logs for issues
sudo tail -f /var/log/auth.log
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
