# 🚀 Step-by-Step Manual Deployment Guide

This guide provides a detailed, step-by-step walkthrough for manually deploying and configuring the network appliance.
For a faster, automated approach, see the main `README.md`.

## 1. Initial System Preparation

### 1.1. Connect to Your Server

Connect to your newly installed Ubuntu 24.04 server via SSH or direct console access.

### 1.2. Update System Packages

Ensure your system is up-to-date.

```bash
sudo apt update && sudo apt upgrade -y
```

### 1.3. Configure Network Interfaces (Netplan)

This is a critical step to ensure your server has the correct network configuration to function as a gateway.

**A. Edit the Netplan Configuration File:**

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

**B. Set Static and DHCP Interfaces:**

Replace the file's contents with the following, adjusting the interface names (`ens33`, `ens37`) to match your system.

```yaml
network:
  version: 2
  ethernets:
    ens33:  # ⚠️ Your WAN Interface
      dhcp4: true
    ens37:  # ⚠️ Your LAN Interface
      addresses:
        - 10.207.0.250/24
```

**C. Apply the Configuration:**

```bash
sudo netplan apply
```

**D. Verify Your Interface Names Match Your Configs:**

It's critical that the interface names in your Netplan config match those used in nftables and DHCP configs.

```bash
# Show all network interfaces
ip link show

# Common interface names:
# - ens18, ens19 (typical for VMs)
# - ens33, ens37 (VMware Workstation)
# - eth0, eth1 (older naming)
# - enp0s3, enp0s8 (VirtualBox)
```

**If your interface names are different, update them in these files:**

- `configs/fw/nftables.conf` (WAN_IF and LAN_IF)
- `configs/dhcp/kea-dhcp4.conf` (interfaces array)
- `/etc/netplan/00-installer-config.yaml` (this file)

### 1.4. Verify Network and Clone Repository

**A. Verify Connectivity:**

```bash
# Check that your interfaces have the correct IPs
ip addr show

# Test internet connectivity (should work via your WAN interface)
ping -c 3 8.8.8.8
```

**B. Install Git and Clone the Repository:**

```bash
sudo apt install -y git
cd /opt
sudo git clone https://github.com/JollyOscar/server-config-repo.git
cd server-config-repo
```

---

## 2. Replace Placeholders

Before deploying any configurations, you **must** replace all placeholder values.

> **📖 Refer to the complete guide for this step:**
> **[`docs/PLACEHOLDERS-GUIDE.md`](docs/PLACEHOLDERS-GUIDE.md)**

After replacing placeholders, run the verification script to check your work:

```bash
bash scripts/verify-placeholders.sh
```

---

## 3. Manual Service Deployment

Follow these steps to deploy each service one by one.

### 3.1. Install Core Packages

```bash
sudo apt install -y openssh-server bind9 kea-dhcp4-server nftables fail2ban aide rkhunter chkrootkit
```

### 3.2. Apply Security Hardening (Run First!)

Hardening should always be the first configuration step.

**A. Run the Hardening Script:**

This script configures `sysctl`, sets up AIDE, and more.

```bash
sudo bash scripts/hardening/security-setup.sh
```

**B. Deploy SSH Configuration:**

This configuration enforces key-only authentication and changes the default port.

```bash
# Backup the original config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Copy the new hardened config
sudo cp configs/hardening/sshd_config /etc/ssh/

# Test and restart SSH
sudo sshd -t && sudo systemctl restart sshd
```

> **🚨 CRITICAL:** Before restarting SSH, ensure you understand the `AllowUsers` configuration!

**C. Configure AllowUsers to Prevent Lockout:**

The hardened `sshd_config` contains a line like:

```text
AllowUsers yourusername@192.168.1.0/24
```

**You MUST replace `yourusername` with your actual Linux username.** Find your username with:

```bash
whoami
```

Then edit the config:

```bash
sudo nano /etc/ssh/sshd_config
# Find the AllowUsers line and replace 'yourusername' with your actual username
# Example: AllowUsers alice@192.168.1.0/24
```

**If you skip this step, you will be locked out after SSH restarts!**

If you do get locked out:
1. Access the server console directly (hypervisor console or physical keyboard)
2. Fix the `AllowUsers` line in `/etc/ssh/sshd_config`
3. Run `sudo systemctl restart sshd`

### 3.3. Configure DNS (BIND9)

This step sets up BIND9 to act as the internal DNS resolver.

**A. Disable `systemd-resolved` Stub Listener:**

`systemd-resolved` conflicts with BIND9 on port 53.

```bash
sudo systemctl disable --now systemd-resolved
sudo rm /etc/resolv.conf
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf
```

**B. Deploy BIND9 Configuration:**

```bash
# Backup original files
sudo cp /etc/bind/named.conf.local /etc/bind/named.conf.local.backup

# Copy new configuration files
sudo cp configs/dns/named.conf.local /etc/bind/
sudo cp configs/dns/db.forward-dns.template /etc/bind/
sudo cp configs/dns/db.reverse-dns.template /etc/bind/

# Set correct permissions
sudo chown bind:bind /etc/bind/db.*
sudo chmod 644 /etc/bind/db.*

# Test and restart BIND9
sudo named-checkconf
sudo systemctl restart bind9
sudo systemctl enable bind9
```

### 3.4. Configure DHCP (Kea)

This step configures Kea to manage IP address allocation for the LAN.

```bash
# Backup original config
sudo cp /etc/kea/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf.backup

# Copy new configuration
sudo cp configs/dhcp/kea-dhcp4.conf /etc/kea/

# Test and restart Kea
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
sudo systemctl restart kea-dhcp4-server
sudo systemctl enable kea-dhcp4-server
```

### 3.5. Configure Firewall (nftables)

This is the final step, which enables the firewall and NAT for the network.

**A. Enable IP Forwarding:**

```bash
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-ipforward.conf
sudo sysctl -p /etc/sysctl.d/99-ipforward.conf
```

**B. Deploy Firewall Rules:**

```bash
# Backup original rules
sudo cp /etc/nftables.conf /etc/nftables.conf.backup

# Copy new ruleset
sudo cp configs/fw/nftables.conf /etc/

# Test and restart nftables
sudo nft -c -f /etc/nftables.conf
sudo systemctl restart nftables
sudo systemctl enable nftables
```

---

## 4. Troubleshooting Common Issues

### Placeholder Verification Script Reports False Positives

If `scripts/verify-placeholders.sh` reports warnings about placeholders like `192.0.2.x`, `198.51.100.x`, or similar patterns, these may be **RFC documentation addresses** used as examples, not actual placeholders you need to replace.

**Common false positives:**
- `192.0.2.0/24` - RFC 5737 documentation prefix (TEST-NET-1)
- `198.51.100.0/24` - RFC 5737 documentation prefix (TEST-NET-2)
- `203.0.113.0/24` - RFC 5737 documentation prefix (TEST-NET-3)

**When to ignore these warnings:**
- If the address appears in a comment or documentation section
- If it's used as an example in a template file you're not deploying
- If you've already customized that config section with your real values

**When NOT to ignore:**
- If the address appears in an active configuration you're deploying
- If you're unsure whether it's documentation or production config

**How to verify:**
1. Check the file and line number reported by the script
2. Look at the context - is it in a comment or actual config?
3. If it's actual config, replace it with your production value
4. If it's a comment/example, you can safely ignore the warning

---

## 5. Final Verification

After deploying all services, run the comprehensive test script to ensure everything is working correctly.

```bash
sudo bash scripts/test-complete.sh
```

The script will validate:
- DNS resolution (internal and external).
- DHCP server responses.
- Firewall rules and NAT functionality.
- SSH hardening status.
- The status of all critical services.

**Congratulations! Your manual deployment is complete.**
