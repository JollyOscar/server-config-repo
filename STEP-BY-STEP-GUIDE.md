# 🚀 **Complete Step-by-Step Deployment Walkthrough**

This guide walks you through the complete deployment of the server-config-repo network appliance from start to finish.

## 📋 **Prerequisites Checklist**

### 🖥️ **Hardware Requirements**

- [ ] **Server**: Ubuntu Server LTS 24.04 installed
- [ ] **RAM**: Minimum 2GB (4GB recommended)
- [ ] **Storage**: Minimum 20GB free space
- [ ] **Network**: Two network interfaces available
- [ ] **Access**: Console or SSH access with sudo privileges

### 🌐 **Network Configuration**

- [ ] **WAN Interface** (`ens18`): Connected to upstream router/internet
- [ ] **LAN Interface** (`ens19`): Connected to internal network
- [ ] **IP Planning**: Internal network will use `10.207.0.0/24`
- [ ] **Gateway**: This appliance will be `10.207.0.250`

---

## 🎯 **STEP 1: Initial System Preparation**

### 1.1 Connect to Your Server

```bash
# If using SSH from another machine:
ssh username@your-server-ip

# Or use console access directly
```

### 1.2 Update System Packages

```bash
# Update package lists and upgrade system
sudo apt update && sudo apt upgrade -y

# Reboot if kernel was updated
sudo reboot  # (only if needed)
```

### 1.3 Configure Network Interfaces

Edit the netplan configuration:

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

Configure like this:

```yaml
network:
  version: 2
  ethernets:
    ens18:  # WAN Interface
      dhcp4: true
      dhcp6: false
    ens19:  # LAN Interface
      addresses:
        - 10.207.0.250/24
      dhcp4: false
      dhcp6: false
```

Apply the configuration:

```bash
sudo netplan apply
```

### 1.4 Verify Network Configuration

```bash
# Check interface status
ip addr show

# Test connectivity
ping -c 3 8.8.8.8  # Should work via ens18
```

---

## 🎯 **STEP 2: Repository Deployment**

### 2.1 Install Git and Clone Repository

```bash
# Install git
sudo apt install -y git

# Clone the repository
cd /opt
sudo git clone https://github.com/JollyOscar/server-config-repo.git
cd server-config-repo

# Switch to the enhanced branch with beautiful documentation
sudo git checkout markdown-customization

# Set proper permissions
sudo chown -R $USER:$USER /opt/server-config-repo
```

### 2.2 Make Scripts Executable

```bash
# Make deployment scripts executable
chmod +x deploy-complete.sh
chmod +x test-complete.sh
chmod +x hardening/security-setup.sh
```

---

## 🎯 **STEP 3: Automated Deployment (Recommended)**

### 3.1 Run Complete Deployment Script

```bash
# Run the comprehensive deployment script
sudo ./deploy-complete.sh
```

**What this script does:**
- ✅ Installs all required packages
- ✅ Applies security hardening first
- ✅ Configures DNS (BIND9)
- ✅ Configures DHCP (Kea)
- ✅ Configures Firewall (nftables)
- ✅ Enables all services
- ✅ Runs validation tests

### 3.2 Monitor Deployment Progress

The script will:
1. Show progress for each phase
2. Pause for confirmation at critical steps
3. Display test results for each service
4. Provide final status summary

---

## 🎯 **STEP 4: Manual Deployment (Alternative)**

If you prefer manual control, follow these steps:

### 4.1 Install Core Packages

```bash
# Install network services
sudo apt install -y openssh-server bind9 kea-dhcp4 nftables fail2ban

# Install security tools
sudo apt install -y ufw aide rkhunter chkrootkit

# Stop legacy services
sudo systemctl stop isc-dhcp-server 2>/dev/null || true
sudo systemctl disable isc-dhcp-server 2>/dev/null || true
```

### 4.2 Apply Security Hardening

```bash
# Run security hardening (CRITICAL - do this first!)
sudo ./hardening/security-setup.sh

# Apply SSH configuration
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
sudo cp ./hardening/sshd_config /etc/ssh/

# Test and restart SSH
sudo sshd -t && sudo systemctl restart ssh
```

### 4.3 Configure DNS Service

```bash
# Backup original configuration
sudo cp /etc/bind/named.conf.local /etc/bind/named.conf.local.backup

# Deploy new configuration
sudo cp ./dns/named.conf.local /etc/bind/
sudo cp ./dns/db.mycorp.lan /etc/bind/
sudo cp ./dns/db.10.207.0 /etc/bind/

# Set permissions
sudo chown bind:bind /etc/bind/db.*
sudo chmod 644 /etc/bind/db.*

# Test and restart
sudo named-checkconf
sudo named-checkzone mycorp.lan /etc/bind/db.mycorp.lan
sudo systemctl restart bind9
sudo systemctl enable bind9
```

### 4.4 Configure DHCP Service

```bash
# Backup original configuration
sudo cp /etc/kea/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf.backup

# Deploy new configuration
sudo cp ./dhcp/kea-dhcp4.conf /etc/kea/

# Test and restart
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
sudo systemctl restart kea-dhcp4
sudo systemctl enable kea-dhcp4
```

### 4.5 Configure Firewall

```bash
# Enable IP forwarding (critical!)
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-ipforward.conf
sudo sysctl -p /etc/sysctl.d/99-ipforward.conf

# Backup original configuration
sudo cp /etc/nftables.conf /etc/nftables.conf.backup

# Deploy new configuration
sudo cp ./fw/nftables.conf /etc/nftables.conf

# Test and restart
sudo nft -c -f /etc/nftables.conf
sudo systemctl restart nftables
sudo systemctl enable nftables
```

---

## 🎯 **STEP 5: Comprehensive Testing**

### 5.1 Run Complete Test Suite

```bash
# Run comprehensive testing
sudo ./test-complete.sh
```

### 5.2 Manual Service Verification

```bash
# Check all service status
sudo systemctl status ssh bind9 kea-dhcp4 nftables

# Test DNS resolution
dig @127.0.0.1 gateway.mycorp.lan
dig @127.0.0.1 google.com

# Check DHCP service
sudo journalctl -u kea-dhcp4 -n 10

# Verify firewall rules
sudo nft list ruleset | head -20
```

### 5.3 Network Connectivity Tests

```bash
# Test internal connectivity
ping -c 3 10.207.0.250  # Self
ping -c 3 10.207.0.1    # Gateway (if exists)

# Test external connectivity
ping -c 3 8.8.8.8       # External DNS
nslookup google.com     # DNS resolution
```

---

## 🎯 **STEP 6: Client Device Testing**

### 6.1 Connect a Client Device

Connect a laptop or device to the LAN interface (ens19) network.

### 6.2 Verify DHCP Assignment

On the client device:

```bash
# Release and request new DHCP lease
sudo dhclient -r  # Release
sudo dhclient     # Request new lease

# Check assigned IP (should be in 10.207.0.100-200 range)
ip addr show
```

### 6.3 Test DNS Resolution

From the client device:

```bash
# Test internal domain resolution
nslookup gateway.mycorp.lan

# Test external resolution
nslookup google.com

# Test reverse DNS
nslookup 10.207.0.250
```

### 6.4 Test Internet Connectivity

```bash
# Test internet access through the appliance
ping -c 3 8.8.8.8
curl -I https://www.google.com
```

---

## 🎯 **STEP 7: SSH Security Testing**

⚠️ **IMPORTANT**: Set up SSH keys BEFORE testing SSH configuration!

### 7.1 Generate SSH Key Pair (on your client)

```bash
# Generate ED25519 key pair
ssh-keygen -t ed25519 -C "your-email@example.com"

# Copy public key to server (use current SSH session)
ssh-copy-id -p 22 username@10.207.0.250  # Use current port first
```

### 7.2 Test SSH Access on New Port

```bash
# Test SSH on hardened port 2222
ssh -p 2222 username@10.207.0.250

# Verify password authentication is disabled
ssh -o PreferredAuthentications=password -p 2222 username@10.207.0.250
# Should fail with "Permission denied"
```

---

## 🎯 **STEP 8: Production Readiness**

### 8.1 Final Security Check

```bash
# Run security validation
sudo ./test-complete.sh | grep -E "(✅|❌|⚠️)"

# Check for any security issues
sudo rkhunter --check --sk  # Skip for now, just verify it runs
```

### 8.2 Set Up Monitoring

```bash
# Enable UFW for additional protection
sudo ufw enable
sudo ufw limit 2222/tcp  # Allow SSH with rate limiting

# Set up log monitoring
sudo journalctl --vacuum-time=30d  # Rotate old logs
```

### 8.3 Create Backup

```bash
# Create configuration backup
sudo tar czf /opt/network-appliance-backup-$(date +%Y%m%d).tar.gz \
  /etc/ssh/sshd_config \
  /etc/bind/ \
  /etc/kea/ \
  /etc/nftables.conf \
  /opt/server-config-repo/
```

---

## 🎉 **STEP 9: Deployment Complete!**

### ✅ **What You Now Have**

- **🛡️ Hardened SSH**: Port 2222, key-only authentication
- **🌐 DNS Server**: Internal domain `mycorp.lan` + external forwarding  
- **📡 DHCP Server**: Automatic IP assignment (10.207.0.100-200)
- **🔥 Firewall**: NAT + stateful filtering with rate limiting
- **🔒 Security**: fail2ban, AIDE monitoring, kernel hardening

### 📊 **Final Status Check**

```bash
# Verify all services are running
sudo systemctl status ssh bind9 kea-dhcp4 nftables --no-pager

# Show network appliance summary
echo "🌐 Network Appliance Ready!"
echo "WAN: $(ip route get 8.8.8.8 | grep -oP 'src \K\S+')"
echo "LAN: 10.207.0.250/24"
echo "SSH: Port 2222 (key-only)"
echo "DNS: Internal + External forwarding"
echo "DHCP: 10.207.0.100-200"
```

### 🔧 **Troubleshooting Resources**

- **Deployment Issues**: Check `/opt/server-config-repo/hardening/DEPLOYMENT.md`
- **Service Logs**: `sudo journalctl -u <service-name>`
- **Configuration Files**: Located in `/opt/server-config-repo/`
- **Test Scripts**: Run `sudo ./test-complete.sh` anytime

---

## 🚀 **Next Steps**

1. **Monitor Logs**: Check service logs regularly for issues
2. **Client Testing**: Connect multiple devices to test DHCP/DNS
3. **Performance Tuning**: Adjust configurations based on usage
4. **Regular Updates**: Keep system and configurations updated
5. **Backup Schedule**: Set up automated configuration backups

**🎊 Congratulations! Your enterprise-grade network appliance is operational!**
 
 