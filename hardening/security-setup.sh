#!/bin/bash
# Security Hardening Script for Network Appliance
# Run with sudo privileges
# Replace placeholders with your actual configuration

set -euo pipefail

echo "🔒 Starting security hardening process..."

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root (use sudo)"
   exit 1
fi

# Variables - REPLACE THESE WITH YOUR ACTUAL VALUES
ADMIN_USER="admin"                    # Replace with your admin username
SSH_PUBLIC_KEY_URL="https://github.com/YOUR_USERNAME.keys"  # Replace with your GitHub keys URL
FAIL2BAN_EMAIL="admin@mycorp.lan"     # Replace with your email

echo "📋 Hardening checklist:"
echo "  - Update system packages"
echo "  - Configure automatic security updates"
echo "  - Install and configure fail2ban"
echo "  - Set up SSH key authentication"
echo "  - Apply kernel security parameters"
echo "  - Configure log monitoring"

# Update system
echo "🔄 Updating system packages..."
apt update && apt upgrade -y

# Install security packages
echo "📦 Installing security packages..."
apt install -y fail2ban ufw logwatch rkhunter chkrootkit aide

# Configure fail2ban
echo "🛡️  Configuring fail2ban..."
cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
destemail = ${FAIL2BAN_EMAIL}
sendername = Fail2Ban-$(hostname)
mta = sendmail

[sshd]
enabled = true
port = 2222
logpath = /var/log/auth.log
maxretry = 3
bantime = 7200
EOF

systemctl enable fail2ban
systemctl restart fail2ban

# Create admin user if it doesn't exist
if ! id "$ADMIN_USER" &>/dev/null; then
    echo "👤 Creating admin user: $ADMIN_USER"
    useradd -m -s /bin/bash -G sudo "$ADMIN_USER"
    echo "⚠️  Please set password for $ADMIN_USER:"
    passwd "$ADMIN_USER"
fi

# Set up SSH key authentication
echo "🔑 Setting up SSH key authentication..."
USER_HOME="/home/$ADMIN_USER"
SSH_DIR="$USER_HOME/.ssh"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Download SSH keys (replace URL with your actual keys)
echo "📥 Downloading SSH public keys..."
echo "⚠️  Replace SSH_PUBLIC_KEY_URL with your actual GitHub keys URL"
# curl -s "$SSH_PUBLIC_KEY_URL" > "$SSH_DIR/authorized_keys" || echo "⚠️  Manual key setup required"

# Create example authorized_keys file
cat > "$SSH_DIR/authorized_keys" << EOF
# Add your SSH public keys here
# Example: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB... user@hostname
# You can get your keys from: https://github.com/YOUR_USERNAME.keys
EOF

chmod 600 "$SSH_DIR/authorized_keys"
chown -R "$ADMIN_USER:$ADMIN_USER" "$SSH_DIR"

# Apply sysctl security settings
echo "⚙️  Applying kernel security parameters..."
cp /opt/server-config-repo/hardening/sysctl-security.conf /etc/sysctl.d/99-security.conf
sysctl -p /etc/sysctl.d/99-security.conf

# Configure log rotation and monitoring
echo "📝 Configuring log monitoring..."
cat > /etc/logrotate.d/security-logs << EOF
/var/log/auth.log /var/log/syslog /var/log/kern.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    copytruncate
}
EOF

# Initialize AIDE database
echo "🔍 Initializing file integrity monitoring..."
aideinit
mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Schedule security checks
echo "⏰ Setting up automated security checks..."
cat > /etc/cron.daily/security-check << 'EOF'
#!/bin/bash
# Daily security checks

echo "Daily Security Report - $(date)" > /var/log/security-report.log
echo "=======================================" >> /var/log/security-report.log

# Check for rootkits
rkhunter --check --skip-keypress --report-warnings-only >> /var/log/security-report.log 2>&1

# Check file integrity
aide --check >> /var/log/security-report.log 2>&1

# Check for failed login attempts
echo "Recent failed login attempts:" >> /var/log/security-report.log
grep "Failed password" /var/log/auth.log | tail -10 >> /var/log/security-report.log

# Email report if sendmail is configured
# mail -s "Security Report $(hostname)" admin@mycorp.lan < /var/log/security-report.log
EOF

chmod +x /etc/cron.daily/security-check

echo "✅ Security hardening completed!"
echo ""
echo "🔧 Manual steps required:"
echo "1. Add your SSH public keys to /home/$ADMIN_USER/.ssh/authorized_keys"
echo "2. Test SSH access with key authentication"
echo "3. Configure email for security notifications"
echo "4. Review and customize fail2ban settings"
echo "5. Set up proper backup procedures"
echo ""
echo "⚠️  IMPORTANT: Test SSH access before logging out!"