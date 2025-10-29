# 🚀 Complete Step-by-Step Deployment Walkthrough

This guide walks you through the complete deployment of the server-config-repo network appliance from start to finish.

## 📋 Prerequisites Checklist

### 🖥️ Hardware Requirements

- [ ] **Server**: Ubuntu Server LTS 24.04 installed
- [ ] **RAM**: Minimum 2GB (4GB recommended)
- [ ] **Storage**: Minimum 20GB free space
- [ ] **Network**: Two network interfaces available
- [ ] **Access**: Console or SSH access with sudo privileges

### 🌐 Network Configuration

- [ ] **WAN Interface** (`ens18`): Connected to upstream router/internet
- [ ] **LAN Interface** (`ens19`): Connected to internal network
- [ ] **IP Planning**: Internal network will use `10.207.0.0/24`
- [ ] **Gateway**: This appliance will be `10.207.0.250`

---

## 🎯 STEP 1: Initial System Preparation

### 1.1 Connect to Your Server

``bash
# If using SSH from another machine:
ssh username@your-server-ip

# Or use console access directly
``

### 1.2 Update System Packages

``bash
# Update package lists and upgrade system
sudo apt update && sudo apt upgrade -y

# Reboot if kernel was updated
sudo reboot  # (only if needed)
``

### 1.3 Configure Network Interfaces

Edit the netplan configuration:

``bash
sudo nano /etc/netplan/00-installer-config.yaml
``

Configure like this:

``yaml
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
``

Apply the configuration:

``bash
sudo netplan apply
``

### 1.4 Verify Network Configuration

``bash
# Check interface status
ip addr show

# Test connectivity
ping -c 3 8.8.8.8  # Should work via ens18
``

---

## 🎯 STEP 2: Repository Deployment

### 2.1 Install Git and Clone Repository

``bash
# Install git
sudo apt install -y git

# Clone the repository
cd /opt
sudo git clone https://github.com/JollyOscar/server-config-repo.git
cd server-config-repo

# Set proper permissions
sudo chown -R $USER:$USER /opt/server-config-repo
``

### 2.2 Make Scripts Executable

``bash
# Make deployment scripts executable
chmod +x deploy-complete.sh
chmod +x test-complete.sh
chmod +x hardening/security-setup.sh
``

---

## 🎯 STEP 3: Automated Deployment (Recommended)

### 3.1 Run Complete Deployment Script

``bash
# Run the comprehensive deployment script
sudo ./deploy-complete.sh
``

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

**🎊 Congratulations! Your enterprise-grade network appliance is operational!**
