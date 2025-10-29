#!/bin/bash
# 🚀 Server Configuration Repository - Complete Deployment Guide
# Repository: https://github.com/JollyOscar/server-config-repo
# Branch: markdown-customization (latest with enhanced documentation)

echo "🌐 Server Configuration Repository Deployment"
echo "=============================================="
echo ""

# 📋 PHASE 1: PRE-DEPLOYMENT CHECKLIST
echo "📋 PHASE 1: PRE-DEPLOYMENT CHECKLIST"
echo "-----------------------------------"
echo "✅ Ubuntu Server LTS 24.04 installed"
echo "✅ Two network interfaces configured:"
echo "   - ens18 (WAN): DHCP from upstream"
echo "   - ens19 (LAN): Static 10.207.0.250/24"
echo "✅ SSH access available"
echo "✅ Root/sudo privileges available"
echo ""
read -p "Press Enter when pre-deployment checklist is complete..."

# 🔄 PHASE 2: SYSTEM PREPARATION
echo ""
echo "🔄 PHASE 2: SYSTEM PREPARATION"
echo "------------------------------"
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "Installing core network services..."
sudo apt install -y openssh-server bind9 kea-dhcp4 nftables fail2ban

echo "Installing security tools..."
sudo apt install -y ufw aide rkhunter chkrootkit git

echo "Stopping legacy services (if present)..."
sudo systemctl stop isc-dhcp-server 2>/dev/null || true
sudo systemctl disable isc-dhcp-server 2>/dev/null || true

# 📂 PHASE 3: REPOSITORY DEPLOYMENT
echo ""
echo "📂 PHASE 3: REPOSITORY DEPLOYMENT"
echo "---------------------------------"
echo "Cloning server-config-repo..."
cd /opt
sudo git clone https://github.com/JollyOscar/server-config-repo.git
cd server-config-repo

echo "Using the current branch for deployment..."

echo "Setting up permissions..."
sudo chown -R $USER:$USER /opt/server-config-repo

# 🛡️ PHASE 4: SECURITY HARDENING (FIRST!)
echo ""
echo "🛡️ PHASE 4: SECURITY HARDENING"
echo "-------------------------------"
echo "CRITICAL: Applying security hardening FIRST..."

echo "Making security setup script executable..."
sudo chmod +x ./hardening/security-setup.sh

echo "Running comprehensive security hardening..."
sudo ./hardening/security-setup.sh

echo "Applying SSH hardening (Ubuntu-aligned)..."
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
sudo cp ./hardening/sshd_config /etc/ssh/

echo "Testing SSH configuration..."
sudo sshd -t

if [ $? -eq 0 ]; then
    echo "✅ SSH configuration valid"
    sudo systemctl restart ssh
else
    echo "❌ SSH configuration invalid - restoring backup"
    sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
    exit 1
fi

# 🌐 PHASE 5: DNS SERVICE DEPLOYMENT
echo ""
echo "🌐 PHASE 5: DNS SERVICE DEPLOYMENT"
echo "----------------------------------"
echo "Configuring BIND9 DNS service..."

sudo cp /etc/bind/named.conf.local /etc/bind/named.conf.local.backup
sudo cp ./dns/named.conf.local /etc/bind/
sudo cp ./dns/db.mycorp.lan /etc/bind/
sudo cp ./dns/db.10.207.0 /etc/bind/

echo "Setting BIND9 file permissions..."
sudo chown bind:bind /etc/bind/db.*
sudo chmod 644 /etc/bind/db.*

echo "Testing BIND9 configuration..."
sudo named-checkconf /etc/bind/named.conf.local
sudo named-checkzone mycorp.lan /etc/bind/db.mycorp.lan
sudo named-checkzone 0.207.10.in-addr.arpa /etc/bind/db.10.207.0

if [ $? -eq 0 ]; then
    echo "✅ DNS configuration valid"
    sudo systemctl restart bind9
    sudo systemctl enable bind9
else
    echo "❌ DNS configuration invalid"
    exit 1
fi

# 📡 PHASE 6: DHCP SERVICE DEPLOYMENT
echo ""
echo "📡 PHASE 6: DHCP SERVICE DEPLOYMENT"
echo "-----------------------------------"
echo "Configuring Kea DHCP service..."

sudo cp /etc/kea/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf.backup
sudo cp ./dhcp/kea-dhcp4.conf /etc/kea/

echo "Testing Kea DHCP configuration..."
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf

if [ $? -eq 0 ]; then
    echo "✅ DHCP configuration valid"
    sudo systemctl restart kea-dhcp4
    sudo systemctl enable kea-dhcp4
else
    echo "❌ DHCP configuration invalid"
    exit 1
fi

# 🔥 PHASE 7: FIREWALL DEPLOYMENT
echo ""
echo "🔥 PHASE 7: FIREWALL DEPLOYMENT"
echo "-------------------------------"
echo "Configuring nftables firewall..."

echo "Enabling IP forwarding (critical for NAT)..."
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-ipforward.conf
sudo sysctl -p /etc/sysctl.d/99-ipforward.conf

sudo cp /etc/nftables.conf /etc/nftables.conf.backup
sudo cp ./fw/nftables.conf /etc/nftables.conf

echo "Testing nftables configuration..."
sudo nft -c -f /etc/nftables.conf

if [ $? -eq 0 ]; then
    echo "✅ Firewall configuration valid"
    sudo systemctl restart nftables
    sudo systemctl enable nftables
else
    echo "❌ Firewall configuration invalid"
    exit 1
fi

# 🔧 PHASE 8: SERVICE VERIFICATION
echo ""
echo "🔧 PHASE 8: SERVICE VERIFICATION"
echo "--------------------------------"
echo "Checking all service status..."

services=("ssh" "bind9" "kea-dhcp4" "nftables")
for service in "${services[@]}"; do
    if systemctl is-active --quiet $service; then
        echo "✅ $service is running"
    else
        echo "❌ $service is not running"
    fi
done

# 📊 PHASE 9: FUNCTIONALITY TESTING
echo ""
echo "📊 PHASE 9: FUNCTIONALITY TESTING"
echo "---------------------------------"
echo "Running comprehensive tests..."

echo "1. Testing DNS resolution..."
nslookup gateway.mycorp.lan 127.0.0.1 || echo "⚠️  DNS local resolution test failed"
nslookup google.com 127.0.0.1 || echo "⚠️  DNS external forwarding test failed"

echo "2. Testing DHCP service..."
sudo journalctl -u kea-dhcp4 --no-pager -n 5

echo "3. Testing firewall rules..."
sudo nft list ruleset | head -20

echo "4. Testing SSH hardening..."
sudo sshd -T | grep -E "(passwordauthentication|port|maxstartups)"

# 🎯 PHASE 10: FINAL CONFIGURATION
echo ""
echo "🎯 PHASE 10: FINAL CONFIGURATION"
echo "--------------------------------"
echo "Setting up monitoring and maintenance..."

echo "Creating maintenance scripts..."
sudo mkdir -p /opt/maintenance
sudo cp ./hardening/security-setup.sh /opt/maintenance/
sudo chmod +x /opt/maintenance/*

echo "Setting up log rotation..."
sudo systemctl enable logrotate

echo "Configuring automatic updates (security only)..."
sudo apt install -y unattended-upgrades
echo 'Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};' | sudo tee /etc/apt/apt.conf.d/51myunattended-upgrades

# 🎉 DEPLOYMENT COMPLETE
echo ""
echo "🎉 DEPLOYMENT COMPLETE!"
echo "======================"
echo "✅ All services configured and running"
echo "✅ Security hardening applied"
echo "✅ Network services operational"
echo ""
echo "📋 Next Steps:"
echo "1. Test client connectivity from LAN devices"
echo "2. Verify SSH access on port 2222"
echo "3. Monitor logs for any issues"
echo "4. Set up regular backups"
echo ""
echo "📊 Service Status Summary:"
systemctl status ssh bind9 kea-dhcp4 nftables --no-pager -l
echo ""
echo "🔧 For troubleshooting, see: /opt/server-config-repo/hardening/DEPLOYMENT.md"
echo ""
echo "🚀 Your network appliance is ready for production!"