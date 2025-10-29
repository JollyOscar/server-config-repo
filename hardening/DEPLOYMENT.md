# SSH Configuration Deployment Guide

This guide follows Ubuntu's official SSH configuration recommendations and troubleshooting procedures.

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

### 3. Implement Ubuntu's Rate Limiting

```bash
# Enable UFW firewall
sudo ufw enable

# Apply Ubuntu's recommended SSH rate limiting
sudo ufw limit ssh
sudo ufw limit 2222/tcp
```

### 4. Test Configuration

**Before restarting SSH, test the configuration:**

```bash
# Test configuration syntax
sudo sshd -t

# If no errors, restart SSH
sudo systemctl restart ssh
```

## Troubleshooting (Ubuntu's Official Procedures)

### Check SSH Daemon Status

```bash
# Verify SSH daemon is running
ps -A | grep sshd
# Should show: <number> ?  00:00:00 sshd

# Check if SSH is listening on correct port
sudo ss -lnp | grep sshd
# Should show: 0  128  *:2222  *:*  users:(("sshd",<pid>,3))
```

### Test Local Connection

```bash
# Test from localhost (will show detailed debug info)
ssh -v -p 2222 localhost

# Exit the test session
exit
```

### Test Remote Connection

1. **From Local Network:**
   ```bash
   ssh -p 2222 username@server_local_ip
   ```

2. **From Internet:**
   ```bash
   ssh -p 2222 username@server_public_ip
   ```

### Common Issues and Solutions

#### "Connection refused" errors

1. **Check firewall rules:**
   ```bash
   sudo ufw status
   sudo iptables -L INPUT -v -n | grep 2222
   ```

2. **Verify SSH is listening:**
   ```bash
   sudo netstat -tlnp | grep :2222
   ```

#### "Permission denied" errors

1. **Check SSH key permissions:**
   ```bash
   ls -la ~/.ssh/
   # authorized_keys should be 600
   # .ssh directory should be 700
   ```

2. **Check SSH logs:**
   ```bash
   sudo tail -f /var/log/auth.log
   ```

#### Router/NAT Issues

- Configure port forwarding on router: External port 2222 → Internal port 2222
- Check if ISP blocks port 2222

## Security Validation

### Verify Current Settings

```bash
# Check key-only authentication is enforced
sudo sshd -T | grep passwordauthentication
# Should show: passwordauthentication no

# Verify connection limits
sudo sshd -T | grep maxstartups
# Should show: maxstartups 2:30:10

# Check logging level
sudo sshd -T | grep loglevel
# Should show: loglevel VERBOSE
```

### Monitor Security

```bash
# View SSH connection attempts
sudo tail -f /var/log/auth.log | grep sshd

# Check for brute force attempts
sudo grep "Failed password" /var/log/auth.log | tail -10
```

## Recovery Procedures

### If Locked Out

1. **Physical/Console Access:**
   ```bash
   sudo cp /etc/ssh/sshd_config.factory-defaults /etc/ssh/sshd_config
   sudo systemctl restart ssh
   ```

2. **Emergency SSH Key Setup:**
   ```bash
   # From console/physical access
   mkdir -p ~/.ssh
   chmod 700 ~/.ssh
   echo "your-public-key-here" >> ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```

### Rollback Configuration

```bash
# Restore factory defaults
sudo cp /etc/ssh/sshd_config.factory-defaults /etc/ssh/sshd_config
sudo systemctl restart ssh

# Re-enable password auth temporarily
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh
```

## Performance Considerations

For high-traffic servers, adjust these settings in `/etc/ssh/sshd_config`:

```bash
# Increase connection limits for busy servers
MaxStartups 10:30:60
MaxSessions 10

# Reduce login grace time for faster turnover
LoginGraceTime 15
```

## Additional Security Measures

### Install and Configure fail2ban

```bash
sudo apt-get install fail2ban

# Create custom jail for SSH on port 2222
sudo tee /etc/fail2ban/jail.d/ssh-custom.conf << EOF
[sshd]
enabled = true
port = 2222
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
EOF

sudo systemctl restart fail2ban
```

### Monitor with AIDE (File Integrity)

```bash
sudo apt-get install aide
sudo aideinit
sudo cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Add to crontab for daily checks
echo "0 6 * * * root /usr/bin/aide --check" | sudo tee -a /etc/crontab
```