# 🚀 **Quick Reference Card**

## 🎯 **Essential Commands**

### **Deployment**
```bash
# Clone and deploy (one-time setup)
git clone https://github.com/JollyOscar/server-config-repo.git
cd server-config-repo
sudo ./deploy-complete.sh

# Test everything
sudo ./test-complete.sh
```

### **Service Management**
```bash
# Check all services
sudo systemctl status ssh bind9 kea-dhcp4 nftables

# Restart specific service
sudo systemctl restart bind9
sudo systemctl restart kea-dhcp4
sudo systemctl restart nftables

# View service logs
sudo journalctl -u bind9 -f
sudo journalctl -u kea-dhcp4 -f
```

### **Configuration Files**
```bash
# SSH (hardened, port 2222)
/etc/ssh/sshd_config

# DNS (BIND9)
/etc/bind/named.conf.local
/etc/bind/db.mycorp.lan

# DHCP (Kea)
/etc/kea/kea-dhcp4.conf

# Firewall (nftables)
/etc/nftables.conf
```

### **Network Diagnostics**
```bash
# Check interfaces
ip addr show

# Test DNS
dig @127.0.0.1 gateway.mycorp.lan
dig @127.0.0.1 google.com

# Check DHCP leases
sudo kea-lfc -c /etc/kea/kea-dhcp4.conf

# View firewall rules
sudo nft list ruleset
```

### **Security Checks**
```bash
# SSH connection test
ssh -p 2222 username@10.207.0.250

# Security scan
sudo rkhunter --check --sk

# Failed login attempts
sudo journalctl -u ssh | grep "Failed"
```

## 🌐 **Network Layout**

| Interface | Purpose | IP Range |
|-----------|---------|----------|
| `ens18` | WAN (Internet) | DHCP from ISP |
| `ens19` | LAN (Internal) | 10.207.0.0/24 |
| Gateway | This appliance | 10.207.0.250 |
| DHCP Pool | Client devices | 10.207.0.100-200 |

## 🔧 **Troubleshooting**

### **Service Won't Start**
```bash
# Check configuration syntax
sudo named-checkconf                    # DNS
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf  # DHCP
sudo nft -c -f /etc/nftables.conf         # Firewall
sudo sshd -t                            # SSH
```

### **No Internet Access**
```bash
# Check IP forwarding
cat /proc/sys/net/ipv4/ip_forward  # Should be 1

# Check firewall NAT
sudo nft list table inet filter | grep masquerade

# Test external connectivity
ping -c 3 8.8.8.8
```

### **DHCP Not Working**
```bash
# Check DHCP service
sudo systemctl status kea-dhcp4

# View DHCP logs
sudo journalctl -u kea-dhcp4 -n 20

# Test DHCP from client
sudo dhclient -v ens19  # On client machine
```

### **DNS Resolution Issues**
```bash
# Test DNS service
sudo systemctl status bind9

# Check zone files
sudo named-checkzone mycorp.lan /etc/bind/db.forward-dns.template

# Test resolution
nslookup gateway.mycorp.lan 127.0.0.1
```

## 📊 **Status Dashboard**

Run this one-liner for a quick status overview:

```bash
echo "🌐 NETWORK APPLIANCE STATUS"; \
echo "WAN: $(ip route get 8.8.8.8 2>/dev/null | grep -oP 'src \K\S+' || echo 'Not connected')"; \
echo "LAN: $(ip addr show ens19 2>/dev/null | grep -oP 'inet \K[\d.]+/\d+' || echo 'Not configured')"; \
echo "SSH: $(systemctl is-active ssh) (Port $(grep -oP 'Port \K\d+' /etc/ssh/sshd_config 2>/dev/null || echo '22'))"; \
echo "DNS: $(systemctl is-active bind9)"; \
echo "DHCP: $(systemctl is-active kea-dhcp4)"; \
echo "Firewall: $(systemctl is-active nftables)"; \
echo "Uptime: $(uptime -p)"
```

## 🆘 **Emergency Recovery**

### **Reset Network Configuration**
```bash
# Reset netplan
sudo cp /etc/netplan/00-installer-config.yaml.backup /etc/netplan/00-installer-config.yaml
sudo netplan apply
```

### **Restore SSH Access**
```bash
# Restore original SSH config
sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
sudo systemctl restart ssh
```

### **Disable Firewall (Emergency)**
```bash
# Temporarily disable firewall
sudo systemctl stop nftables
sudo nft flush ruleset
```

---

**📚 For complete deployment guide:** `STEP-BY-STEP-GUIDE.md`

**🔧 For troubleshooting:** `hardening/DEPLOYMENT.md`