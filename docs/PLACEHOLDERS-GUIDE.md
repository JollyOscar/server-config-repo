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
| `configs/dns/db.mycorp.lan` | `mycorp.lan` | Your actual domain name |
| `configs/dns/db.mycorp.lan` | All IP addresses | Your actual server IPs |
| `configs/dns/db.mycorp.lan` | Hostnames | Your actual server names |
| `configs/dns/db.10.207.0` | All entries | Your actual reverse DNS entries |

**Required Actions:**
1. **Change filename:** Rename `db.mycorp.lan` to `db.yourdomain.com`
2. **Update zone references:** Edit `dns/named.conf.local` to match new filename
3. **Change subnet file:** If not using 10.207.0.x, rename `db.10.207.0` accordingly

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
sudo named-checkzone 10.207.0.in-addr.arpa configs/dns/db.10.207.0

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