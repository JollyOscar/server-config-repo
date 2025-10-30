# 🚨 PLACEHOLDER REPLACEMENT GUIDE

**⚠️  CRITICAL: You MUST replace all placeholders before deployment!**

This repository contains placeholder values that must be customized for your environment. All placeholders are marked with `⚠️` symbols and comments.

## 🎯 Quick Replacement Checklist

Before running any deployment scripts, replace these critical placeholders:

### 1. 🌐 Network Configuration

| File | Placeholder | What to Replace |
|------|------------|-----------------|
| `configs/dhcp/kea-dhcp4.conf` | `"ens37"` | Your actual LAN interface name |
| `configs/fw/nftables.conf` | `ens33`, `ens37` | Your actual WAN/LAN interface names |
| `configs/fw/nftables.conf` | `10.207.0.0/24` | Your internal network subnet |
| `configs/fw/nftables.conf` | `10.207.0.250` | Your appliance/gateway IP |

**How to find your interface names:**
```bash
ip -br addr show
```

### 2. 🔧 DNS Configuration

| File | Placeholder | What to Replace |
|------|------------|-----------------|
| `configs/dns/db.forward-dns.template` | `mycorp.lan` | Your actual domain name |
| `configs/dns/db.forward-dns.template` | All IP addresses | Your actual server IPs |
| `configs/dns/db.forward-dns.template` | Hostnames | Your actual server names |
| `configs/dns/db.reverse-dns.template` | All entries | Your actual reverse DNS entries |

> [!IMPORTANT]
> When you change these filenames (e.g., `db.mycorp.lan` to `db.yourdomain.com`), you **must** also update the corresponding `file` path in `configs/dns/named.conf.local` to match. The deployment script **does not** do this for you.
>
> **Example Workflow:**
> 1. **Change filename:** Rename `db.forward-dns.template` to `db.yourdomain.com`
> 2. **Update `named.conf.local`:** Change the `file` path in the `zone "yourdomain.com"` block to point to your newly named file.
> 3. **Change subnet file:** If not using 10.207.0.x, rename `db.reverse-dns.template` accordingly and update the corresponding `file` path in `named.conf.local`.

### 3. 🔒 Security Configuration

| File | Placeholder | What to Replace |
|------|------------|-----------------|
| `configs/hardening/sshd_config` | `JollyOscar` | Your actual username |
| `configs/hardening/security-setup.sh` | `YOUR_USERNAME` | Your GitHub username |
| `configs/hardening/security-setup.sh` | `admin@mycorp.lan` | Your actual email |
| `configs/hardening/security-setup.sh` | `"admin"` | Your actual admin username |

### 4. 📍 DHCP Reservations

| File | Placeholder | What to Replace |
|------|------------|-----------------|
| `configs/dhcp/kea-dhcp4.conf` | `aa:bb:cc:dd:ee:ff` | Actual MAC addresses |
| `configs/dhcp/kea-dhcp4.conf` | `server.mycorp.lan` | Your actual hostnames |
| `configs/dhcp/kea-dhcp4.conf` | `mycorp.lan` | Your actual domain |

**How to find MAC addresses:**
```bash
ip link show        # On each device
arp -a             # From DHCP server
```

---

## ⚠️  Understanding False Positives

The verification script may report placeholders that are **actually OK**:

### ✅ **These Are NOT Problems:**

1. **Comments and Documentation**
   - `# ⚠️  REPLACE: Your username` - These are instructions, not config
   - Warning markers in config files are helpful reminders
   - Comments explaining what to change are documentation

2. **Verification Scripts Themselves**
   - `verify-placeholders.sh` contains search patterns
   - `verify-placeholders.ps1` contains the same patterns
   - These scripts LOOK FOR placeholders, they don't USE them

3. **GitHub Workflows**
   - `.github/workflows/*.yml` files for CI/CD
   - These test placeholder detection, not actual config

4. **Default Domain Names**
   - `mycorp.lan` is a valid test domain
   - OK to deploy with this and change later
   - Customize when you have a real internal domain

5. **Example Values in Comments**
   - `"hw-address": "aa:bb:cc:dd:ee:ff",  // Example - replace with actual MAC`
   - These are documentation showing the format

### ❌ **These ARE Real Problems:**

1. **Uncommented Placeholders in Config Files**
   - `SSH_PUBLIC_KEY_URL="https://github.com/YOUR_USERNAME.keys"` (not in a comment)
   - `"hw-address": "aa:bb:cc:dd:ee:ff"` (not commented out or in a comment line)
   - `AllowUsers YOUR_USERNAME_HERE` (not in a comment)

2. **Interface Name Mismatches**
   - nftables says `ens33` but your system has `eth0`
   - DHCP says `ens37` but your system has `eth1`
   - These MUST match your actual interface names from `ip link show`

3. **Wrong Username in SSH Config**
   - You're user `alice` but SSH allows only `bob`
   - Will lock you out after deployment!
   - SSH username must match an actual user on the system

4. **Placeholder Email Addresses**
   - `admin@mycorp.lan` won't receive fail2ban alerts
   - Should be changed to a real monitored email

## 🔍 **How to Verify:**

Run the verification script:
```bash
sudo ./scripts/verify-placeholders.sh
```

**Read the output carefully:**
- ❌ Red X = Must fix before deployment
- ⚠️  Warning triangle = Review, might be OK
- ✅ Green check = All good!
- ℹ️  Info = Explanation about false positives

The improved script now filters out false positives automatically!

### **Example of Good Output:**

```
✅ No 'YOUR_USERNAME' placeholders in config files
✅ No placeholder MAC addresses in DHCP config
⚠️  Found 'mycorp.lan' in 16 files
   ℹ️  This is OK for testing! Change later if needed.
✅ Interface names consistent: ens37
✅ SSH username configured: alice
```

### **Example of Issues to Fix:**

```
❌ Found 'YOUR_USERNAME' in actual configuration:
hardening/security-setup.sh:SSH_PUBLIC_KEY_URL="https://github.com/YOUR_USERNAME.keys"

❌ Interface mismatch:
   nftables LAN_IF: ens37
   DHCP interface: eth1
```

---

## 🔍 Finding All Placeholders

Search for placeholders using these patterns:

### Command Line Search
```bash
# Find all warning markers
grep -r "⚠️" .

# Find placeholder patterns
grep -r -E "(YOUR_|REPLACE|aa:bb:cc|mycorp\.lan|10\.207\.0)" .

# Find interface references
grep -r -E "(ens33|ens37|ens18|ens19)" .
```

### Common Placeholder Patterns

| Pattern | Meaning | Example |
|---------|---------|---------|
| `⚠️` | Warning marker | `⚠️  REPLACE: Your domain` |
| `YOUR_USERNAME` | GitHub username | `https://github.com/YOUR_USERNAME.keys` |
| `mycorp.lan` | Domain name | `server.mycorp.lan` |
| `aa:bb:cc:dd:ee:ff` | MAC address | DHCP reservations |
| `10.207.0.x` | IP addresses | Internal network |
| `ens33`/`ens37` | Interface names | Network interfaces |

## 📋 Pre-Deployment Verification

Run these commands to verify placeholder replacement:

### 1. Check for Unreplaced Placeholders
```bash
# Should return nothing if all placeholders are replaced
grep -r "⚠️.*REPLACE" .
grep -r "YOUR_USERNAME" .
grep -r "aa:bb:cc:dd:ee:ff" .
```

### 2. Verify Interface Names
```bash
# Compare with your actual interfaces
ip -br addr show
grep -r "ens33\|ens37" configs/dhcp/ configs/fw/
```

### 3. Test Configuration Syntax
```bash
# Test DHCP config
sudo kea-dhcp4 -t configs/dhcp/kea-dhcp4.conf

# Test DNS zones (after customization)
sudo named-checkzone yourdomain.com configs/dns/db.yourdomain.com
sudo named-checkzone 10.207.0.in-addr.arpa configs/dns/db.reverse-dns.template

# Test nftables config
sudo nft -c -f configs/fw/nftables.conf
```

## 🚀 Deployment Order

After replacing all placeholders:

1. **Verify Prerequisites** (see README.md)
2. **Run Replacement Verification** (commands above)
3. **Update SSH Configuration** (`configs/hardening/sshd_config`)
4. **Execute Deployment** (`sudo ./scripts/deploy-complete.sh`)
5. **Run Tests** (`sudo ./scripts/test-complete.sh`)

## ⚠️  Common Mistakes

### Interface Name Confusion
- **Wrong:** Using example interfaces (`ens18`/`ens19`) from documentation
- **Right:** Using your actual interfaces found with `ip -br addr show`

### Domain Name Issues
- **Wrong:** Leaving `mycorp.lan` in configurations
- **Right:** Using your actual domain throughout all files

### MAC Address Problems
- **Wrong:** Leaving placeholder `aa:bb:cc:dd:ee:ff`
- **Right:** Using actual MAC addresses from your devices

### SSH Access Lockout
- **Wrong:** Not updating username in `sshd_config`
- **Right:** Using your actual username that you'll connect with

## 🆘 Emergency Recovery

If you get locked out or services fail:

### SSH Access Issues
```bash
# Boot from rescue media or console access
sudo nano /etc/ssh/sshd_config
# Fix AllowUsers line with correct username
sudo systemctl restart sshd
```

### Service Failures
```bash
# Check service status
sudo systemctl status bind9 kea-dhcp4-server nftables

# View logs
sudo journalctl -u bind9 -f
sudo journalctl -u kea-dhcp4-server -f
```

### Network Issues
```bash
# Reset to basic networking
sudo systemctl stop nftables
sudo iptables -F
sudo ip route add default via [upstream_gateway]
```

---

**Remember:** Always test configurations in a non-production environment first!