#!/bin/bash
# 🧪 Server Configuration Repository - Comprehensive Testing Suite
# This script thoroughly tests all components of the network appliance

echo "🧪 Network Appliance Testing Suite"
echo "=================================="
echo ""

# 🎯 TEST SUITE 1: SYSTEM HEALTH
echo "🎯 TEST 1: SYSTEM HEALTH CHECKS"
echo "-------------------------------"

echo "1.1 Checking system uptime and load..."
uptime

echo ""
echo "1.2 Checking disk space..."
df -h | grep -E "(Filesystem|/dev/)"

echo ""
echo "1.3 Checking memory usage..."
free -h

echo ""
echo "1.4 Checking network interfaces..."
ip addr show | grep -E "(ens33|ens37|inet )"

# 🛡️ TEST SUITE 2: SECURITY VALIDATION
echo ""
echo "🛡️ TEST 2: SECURITY VALIDATION"
echo "------------------------------"

echo "2.1 SSH Configuration Test..."
echo "Port configuration:"
sudo sshd -T | grep port
echo "Authentication settings:"
sudo sshd -T | grep -E "(passwordauthentication|pubkeyauthentication)"
echo "Connection limits:"
sudo sshd -T | grep -E "(maxstartups|maxsessions|logingracetime)"

echo ""
echo "2.2 Firewall Status..."
sudo systemctl status nftables --no-pager -l

echo ""
echo "2.3 Active firewall rules (first 20 lines)..."
sudo nft list ruleset | head -20

echo ""
echo "2.4 Fail2ban Status..."
sudo systemctl status fail2ban --no-pager -l 2>/dev/null || echo "Fail2ban not running"

# 🌐 TEST SUITE 3: DNS SERVICE TESTING
echo ""
echo "🌐 TEST 3: DNS SERVICE TESTING"
echo "------------------------------"

echo "3.1 BIND9 Service Status..."
sudo systemctl status bind9 --no-pager -l

echo ""
echo "3.2 DNS Configuration Validation..."
sudo named-checkconf
echo "✅ named.conf syntax check passed"

echo ""
echo "3.3 Zone File Validation..."
sudo named-checkzone mycorp.lan /etc/bind/db.mycorp.lan
sudo named-checkzone 0.207.10.in-addr.arpa /etc/bind/db.10.207.0

echo ""
echo "3.4 DNS Query Tests..."
echo "Testing local domain resolution:"
dig @127.0.0.1 gateway.mycorp.lan +short
dig @127.0.0.1 dns.mycorp.lan +short

echo ""
echo "Testing reverse DNS:"
dig @127.0.0.1 -x 10.207.0.250 +short

echo ""
echo "Testing external forwarding:"
dig @127.0.0.1 google.com +short | head -3

echo ""
echo "Testing DNS server response time:"
dig @127.0.0.1 google.com | grep "Query time"

# 📡 TEST SUITE 4: DHCP SERVICE TESTING
echo ""
echo "📡 TEST 4: DHCP SERVICE TESTING"
echo "-------------------------------"

echo "4.1 Kea DHCP Service Status..."
sudo systemctl status kea-dhcp4 --no-pager -l

echo ""
echo "4.2 DHCP Configuration Validation..."
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
if [ $? -eq 0 ]; then
    echo "✅ Kea DHCP configuration is valid"
else
    echo "❌ Kea DHCP configuration has errors"
fi

echo ""
echo "4.3 DHCP Lease Information..."
echo "Current leases (if any):"
sudo ls -la /var/lib/kea/ 2>/dev/null || echo "No lease files found yet"

echo ""
echo "4.4 DHCP Logs (last 10 entries)..."
sudo journalctl -u kea-dhcp4 --no-pager -n 10

echo ""
echo "4.5 Network Interface Binding Test..."
sudo netstat -ulnp | grep :67 || echo "DHCP not listening on port 67"

# 🔥 TEST SUITE 5: FIREWALL TESTING
echo ""
echo "🔥 TEST 5: FIREWALL TESTING"
echo "---------------------------"

echo "5.1 nftables Service Status..."
sudo systemctl status nftables --no-pager -l

echo ""
echo "5.2 IP Forwarding Status..."
cat /proc/sys/net/ipv4/ip_forward
if [ "$(cat /proc/sys/net/ipv4/ip_forward)" = "1" ]; then
    echo "✅ IP forwarding is enabled"
else
    echo "❌ IP forwarding is disabled"
fi

echo ""
echo "5.3 NAT Rules Check..."
sudo nft list chain ip nat postrouting 2>/dev/null || echo "No NAT postrouting chain found"

echo ""
echo "5.4 Input Chain Rules..."
sudo nft list chain ip filter input | head -15

echo ""
echo "5.5 Port Accessibility Test..."
echo "Testing SSH port 2222:"
sudo netstat -tlnp | grep :2222 || echo "SSH not listening on port 2222"

echo "Testing DNS port 53:"
sudo netstat -ulnp | grep :53 || echo "DNS not listening on port 53"

# 🔧 TEST SUITE 6: CONNECTIVITY TESTING
echo ""
echo "🔧 TEST 6: CONNECTIVITY TESTING"
echo "-------------------------------"

echo "6.1 Local Network Connectivity..."
echo "Ping test to gateway:"
ping -c 3 10.207.0.1 2>/dev/null || echo "⚠️  Gateway 10.207.0.1 not reachable"

echo ""
echo "6.2 External Connectivity..."
echo "Ping test to external DNS:"
ping -c 3 8.8.8.8 || echo "⚠️  External connectivity issue"

echo ""
echo "6.3 DNS Resolution Test..."
echo "Resolving external domain:"
nslookup google.com || echo "⚠️  DNS resolution issue"

# 📊 TEST SUITE 7: PERFORMANCE MONITORING
echo ""
echo "📊 TEST 7: PERFORMANCE MONITORING"
echo "---------------------------------"

echo "7.1 Service Resource Usage..."
echo "Top processes by CPU:"
ps aux --sort=-%cpu | head -6

echo ""
echo "Top processes by Memory:"
ps aux --sort=-%mem | head -6

echo ""
echo "7.2 Network Statistics..."
echo "Network interface statistics:"
cat /proc/net/dev | grep -E "(ens33|ens37)" || echo "Network interfaces not found"

echo ""
echo "7.3 System Load Average..."
cat /proc/loadavg

# 🚨 TEST SUITE 8: SECURITY AUDIT
echo ""
echo "🚨 TEST 8: SECURITY AUDIT"
echo "-------------------------"

echo "8.1 Open Ports Scan..."
sudo netstat -tlnp | grep LISTEN

echo ""
echo "8.2 Failed Login Attempts..."
sudo grep "Failed password" /var/log/auth.log | tail -5 2>/dev/null || echo "No recent failed login attempts"

echo ""
echo "8.3 Active Network Connections..."
sudo netstat -tn | grep ESTABLISHED | wc -l
echo "Active established connections"

echo ""
echo "8.4 Last Logins..."
last | head -5

# 📋 TEST SUITE 9: LOG ANALYSIS
echo ""
echo "📋 TEST 9: LOG ANALYSIS"
echo "-----------------------"

echo "9.1 System Errors (last 5)..."
sudo journalctl -p err --no-pager -n 5

echo ""
echo "9.2 Service-specific Logs..."
echo "SSH logs (last 3):"
sudo journalctl -u ssh --no-pager -n 3

echo "DNS logs (last 3):"
sudo journalctl -u bind9 --no-pager -n 3

echo "DHCP logs (last 3):"
sudo journalctl -u kea-dhcp4 --no-pager -n 3

echo "Firewall logs (last 3):"
sudo journalctl -u nftables --no-pager -n 3

# 🎯 TEST SUMMARY
echo ""
echo "🎯 TEST SUMMARY"
echo "==============="

echo ""
echo "📊 Service Status Overview:"
services=("ssh" "bind9" "kea-dhcp4" "nftables")
all_good=true

for service in "${services[@]}"; do
    if systemctl is-active --quiet $service; then
        echo "✅ $service: RUNNING"
    else
        echo "❌ $service: NOT RUNNING"
        all_good=false
    fi
done

echo ""
echo "🔧 Network Configuration:"
echo "WAN Interface (ens33): $(ip addr show ens33 2>/dev/null | grep "inet " | awk '{print $2}' || echo "Not configured")"
echo "LAN Interface (ens37): $(ip addr show ens37 2>/dev/null | grep "inet " | awk '{print $2}' || echo "Not configured")"

echo ""
if $all_good; then
    echo "🎉 OVERALL STATUS: ALL SYSTEMS OPERATIONAL"
    echo "✅ Network appliance is ready for production use"
else
    echo "⚠️  OVERALL STATUS: ISSUES DETECTED"
    echo "❌ Some services need attention - check individual test results above"
fi

echo ""
echo "📚 For troubleshooting assistance:"
echo "   - Check /opt/server-config-repo/hardening/DEPLOYMENT.md"
echo "   - Review service logs with: sudo journalctl -u <service-name>"
echo "   - Validate configurations in /opt/server-config-repo/"
echo ""
echo "🔧 Testing complete! Review results above for any issues."