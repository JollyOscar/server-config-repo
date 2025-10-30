# 🚨 Placeholder Replacement Guide

This guide explains how to customize the configuration files in this repository for your specific environment. **You must replace all placeholder values before deployment.**

## 1. How to Find Placeholders
Placeholders are marked in the configuration files in two ways:
1.  **`⚠️` Symbol:** A warning emoji is used in comments to highlight critical values that need to be changed.
2.  **Uppercase Strings:** Values like `YOUR_USERNAME` are used as obvious placeholders.

You can find all placeholders by running a search in your code editor or by using `grep` from the command line:
```bash
# Find all warning markers
grep -r "⚠️" .

# Find common placeholder patterns
grep -r -E "(YOUR_USERNAME|mycorp.lan|aa:bb:cc:dd:ee:ff|10\.207\.0)" .
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

### SSH User (`YOUR_USERNAME`)
To avoid getting locked out of your server, you must specify which user is allowed to connect via SSH.

| File | Placeholder | What to Change |
| :--- | :--- | :--- |
| `configs/hardening/sshd_config` | `AllowUsers JollyOscar` | Replace `JollyOscar` with your actual username. |
| `configs/hardening/security-setup.sh` | `YOUR_USERNAME` | Your GitHub username, used to fetch public keys. |

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

## 4. Pre-Deployment Syntax Checks
Before running the main deployment script, you can validate the syntax of the configuration files.

```bash
# Test Kea DHCP configuration
sudo kea-dhcp4 -t configs/dhcp/kea-dhcp4.conf

# Test BIND9 DNS configuration (after renaming files)
sudo named-checkconf configs/dns/named.conf.local
sudo named-checkzone yourdomain.com configs/dns/db.yourdomain.com

# Test nftables firewall rules
sudo nft -c -f configs/fw/nftables.conf
```

These commands will catch syntax errors before you apply the configurations and potentially break services.