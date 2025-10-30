# 🚨 Placeholder Replacement Guide

This guide explains how to customize the configuration files in this repository for your specific environment. **You must replace all placeholder values before deployment.**

## 1. How to Find Placeholders
Placeholders are marked in the configuration files in these ways:
1.  **WARNING Comments:** Text comments containing "WARNING:" highlight critical values that need to be changed.
2.  **Uppercase Strings:** Values like `YOUR_USERNAME` are used as obvious placeholders.
3.  **Example Values:** Generic values like `mycorp.lan`, `aa:bb:cc:dd:ee:ff` that should be replaced with real values.

You can find all placeholders by running a search in your code editor or by using `grep` from the command line:
```bash
# Find all warning markers in config files
grep -r "WARNING:" configs/

# Find common placeholder patterns
grep -r -E "(YOUR_USERNAME|mycorp.lan|aa:bb:cc:dd:ee:ff|10\.207\.0)" configs/

# Use the built-in verification script
bash scripts/verify-placeholders.sh
```

---

## 2. Critical Placeholders to Replace

### Network Interfaces (`ens33`, `ens37`)
The default configuration assumes your **WAN** (internet-facing) interface is `ens33` and your **LAN** (internal network) interface is `ens37`.

**A. Find Your Actual Interface Names:**
```bash
ip -br addr show
```
*Example output:*
```
lo               UNKNOWN        127.0.0.1/8
enp0s3           UP             192.168.1.100/24  <-- This is your WAN
enp0s8           UP             10.207.0.250/24   <-- This is your LAN
```

**B. Update These Files:**
| File | Placeholder | What to Change |
| :--- | :--- | :--- |
| `configs/dhcp/kea-dhcp4.conf` | `"ens37"` | Your actual **LAN** interface name. |
| `configs/fw/nftables.conf` | `define WAN_IF = ens33` | Your actual **WAN** interface name. |
| `configs/fw/nftables.conf` | `define LAN_IF = ens37` | Your actual **LAN** interface name. |
| `scripts/test-complete.sh` | `ens33`, `ens37` | Your interface names in test commands. |

### SSH User and Security Settings (`YOUR_USERNAME`)

To avoid getting locked out of your server, you must specify which user is allowed to connect via SSH and configure the security automation script.

| File | Placeholder | What to Change |
| :--- | :--- | :--- |
| `configs/hardening/sshd_config` | `AllowUsers YOUR_USERNAME` | Replace `YOUR_USERNAME` with your actual username. |
| `configs/hardening/security-setup.sh` | `ADMIN_USER="admin"` | Replace `admin` with your actual username. |
| `configs/hardening/security-setup.sh` | `YOUR_USERNAME.keys` | Replace `YOUR_USERNAME` with your GitHub username for SSH key fetching. |
| `configs/hardening/security-setup.sh` | `FAIL2BAN_EMAIL="admin@mycorp.lan"` | Replace with your actual email address for security alerts. |

### Domain Name (`mycorp.lan`)
The default internal domain is `mycorp.lan`. You should replace this with your own domain.

| File | What to Change |
| :--- | :--- |
| `configs/dns/db.forward-dns.template` | Replace all instances of `mycorp.lan`. |
| `configs/dns/db.reverse-dns.template` | Replace `mycorp.lan`. |
| `configs/dns/named.conf.local` | Update the zone name if you change the filename. |
| `configs/dhcp/kea-dhcp4.conf` | Update the `domain-name` option. |

> **Note:** If you rename the DNS zone files (e.g., `db.forward-dns.template` to `db.yourdomain.com`), you **must** also update the `file` path in `configs/dns/named.conf.local` to match.

### MAC Address (`aa:bb:cc:dd:ee:ff`)
The DHCP server configuration contains an example static IP reservation. You must replace the placeholder MAC address with the actual MAC address of a device on your network.

| File | Placeholder | What to Change |
| :--- | :--- | :--- |
| `configs/dhcp/kea-dhcp4.conf` | `aa:bb:cc:dd:ee:ff` | The hardware MAC address of a client device. |

---

## 3. Verification
After replacing placeholders, run the verification script to check your work.

**First, make the scripts executable:**

```bash
# On Linux/WSL:
chmod +x scripts/*.sh
```

**Then run the verification:**

```bash
# On Linux/WSL:
bash scripts/verify-placeholders.sh

# On Windows PowerShell:
.\scripts\verify-placeholders.ps1
```

The script will report any remaining placeholders. It is smart enough to ignore comments and documentation, so any errors it reports are likely real issues that need to be fixed.

> For a detailed explanation of the script's output, see the **[`docs/FALSE-POSITIVES.md`](docs/FALSE-POSITIVES.md)** guide.

---

## 4. Critical Steps Before Deployment

### 4.1. Pre-Deployment Syntax Checks

Before running the main deployment script, you can validate the syntax of the configuration files.

```bash
# Test Kea DHCP configuration
sudo kea-dhcp4 -t configs/dhcp/kea-dhcp4.conf

# Test BIND9 DNS configuration
sudo named-checkconf configs/dns/named.conf.local

# Test nftables firewall rules
sudo nft -c -f configs/fw/nftables.conf

# Test SSH configuration (syntax only)
sudo sshd -t -f configs/hardening/sshd_config
```

### 4.2. DNS Zone File Preparation

**IMPORTANT:** The DNS zone files are templates that must be renamed and customized:

```bash
# Rename the template files to match your domain
cp configs/dns/db.forward-dns.template configs/dns/db.mycorp.lan
cp configs/dns/db.reverse-dns.template configs/dns/db.10.207.0

# Then edit the files to replace all instances of "mycorp.lan" with your domain
# After customization, test the zone files:
sudo named-checkzone mycorp.lan configs/dns/db.mycorp.lan
sudo named-checkzone 0.207.10.in-addr.arpa configs/dns/db.10.207.0
```

### 4.3. Deploy with Automated Script

After completing placeholder replacement and validation:

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run the complete deployment
sudo bash scripts/deploy-complete.sh
```

The deployment script includes built-in placeholder verification and will warn you if critical values haven't been replaced.

## 5. Common Placeholder Locations Quick Reference

| Configuration Area | Files to Check | Key Placeholders |
|:---|:---|:---|
| **Network Interfaces** | `configs/dhcp/kea-dhcp4.conf`, `configs/fw/nftables.conf` | `ens33`, `ens37` |
| **SSH Security** | `configs/hardening/sshd_config`, `configs/hardening/security-setup.sh` | `YOUR_USERNAME`, `admin` |
| **Domain Names** | `configs/dns/*.template`, `configs/dhcp/kea-dhcp4.conf` | `mycorp.lan` |
| **MAC Addresses** | `configs/dhcp/kea-dhcp4.conf` | `aa:bb:cc:dd:ee:ff` |
| **Email Alerts** | `configs/hardening/security-setup.sh` | `admin@mycorp.lan` |
| **IP Addresses** | All config files | `10.207.0.*` network |
| **Fail2Ban Email** | `configs/hardening/security-setup.sh` | `FAIL2BAN_EMAIL` |

**Remember:** Use `bash scripts/verify-placeholders.sh` to catch any missed placeholders before deployment!