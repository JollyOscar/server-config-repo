# 🚀 Quick Reference Guide

A cheat sheet for essential commands and configuration details.

## 1. Core Commands

### Deployment & Verification

```bash
# Clone the repository (first-time setup)
cd /opt
sudo git clone https://github.com/JollyOscar/server-config-repo.git
cd server-config-repo

# Verify placeholders before deployment
sudo bash scripts/verify-placeholders.sh

# Run the complete, non-blocking deployment check
sudo bash scripts/deploy-complete.sh

# Run the post-deployment test suite
sudo bash scripts/test-complete.sh
```

### Service Management

```bash
# Check status of all key services
sudo systemctl status sshd bind9 kea-dhcp4-server nftables

# Restart a specific service
sudo systemctl restart bind9
sudo systemctl restart kea-dhcp4-server
sudo systemctl restart nftables

# View live logs for a service
sudo journalctl -u bind9 -f
sudo journalctl -u kea-dhcp4-server -f
```

### Security & Auditing

```bash
# Test the hardened SSH configuration (from a client machine)
ssh -p 2222 your_user@10.207.0.250

# Run a rootkit hunter scan
sudo rkhunter --checkall --skip-keypress

# Check for failed login attempts
sudo journalctl -u sshd | grep "Failed"
```

## 2. Configuration & File Locations

### Core Configuration Files

All primary configuration templates are located in the `configs/` directory.
- **SSH Hardening**: `configs/hardening/sshd_config`
- **Sysctl Security**: `configs/hardening/sysctl-security.conf`
- **DNS (BIND9)**: `configs/dns/named.conf.local`
- **DNS Forward Zone**: `configs/dns/db.forward-dns.template`
- **DNS Reverse Zone**: `configs/dns/db.reverse-dns.template`
- **DHCP (Kea)**: `configs/dhcp/kea-dhcp4.conf`
- **Firewall (nftables)**: `configs/fw/nftables.conf`

### Scripts

- **Verification**: `scripts/verify-placeholders.sh`
- **Deployment Check**: `scripts/deploy-complete.sh`
- **Full System Test**: `scripts/test-complete.sh`
- **Security Setup**: `configs/hardening/security-setup.sh`

## 3. Network Layout

| Interface | Purpose | IP Address / Range | Notes |
|-----------|---------|--------------------|-------|
| **WAN**   | Internet Facing | DHCP from ISP      | Connects to your modem/router. |
| **LAN**   | Internal Network| `10.207.0.250/24`  | The static IP of this appliance. |
| **DHCP Pool** | For LAN Clients | `10.207.0.100-200` | Managed by the Kea DHCP server. |

## 4. Troubleshooting

### Validating Configurations

Before restarting a service, always test its configuration first.
```bash
# Test DNS configuration
sudo named-checkconf

# Test DHCP configuration
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf

# Test Firewall ruleset
sudo nft -c -f /etc/nftables.conf

# Test SSH server configuration
sudo sshd -t
```

### No Internet on LAN?

1. **Check IP Forwarding**:
    ```bash
    cat /proc/sys/net/ipv4/ip_forward  # Expected output: 1
    ```
2. **Verify NAT Rule**:
    ```bash
    sudo nft list ruleset | grep 'oifname "ens33" masquerade' # Replace ens33 with your WAN interface
    ```
3. **Test DNS Resolution**:
    ```bash
    # From a client on the LAN
    nslookup google.com 10.207.0.250
    ```
4. **Check Service Status**: Ensure `bind9`, `kea-dhcp4-server`, and `nftables` are all active.