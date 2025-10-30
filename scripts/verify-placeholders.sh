#!/bin/bash
# 🔍 Placeholder Verification Script (Improved - No False Positives)
# Run this before deployment to check for unreplaced placeholders

# Auto-detect script directory and change to repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT" || { echo "❌ Failed to change to repository root"; exit 1; }

echo "🔍 Checking for unreplaced placeholders..."
echo "Repository root: $REPO_ROOT"
echo "========================================"

FOUND_ISSUES=0

echo ""
echo "🚨 Critical Placeholders Check:"
echo "------------------------------"

# Check for YOUR_USERNAME in actual config files (not documentation or scripts)
echo "Checking for 'YOUR_USERNAME' in configuration files..."
YOUR_USERNAME_FILES=$(grep -r "YOUR_USERNAME" \
    --include="*.sh" \
    --include="*.conf" \
    --include="*.config" \
    --exclude="verify-placeholders.sh" \
    --exclude="verify-placeholders.ps1" \
    --exclude-dir=.git \
    --exclude-dir=.github \
    . 2>/dev/null | grep -v "^#" | grep -v "⚠️" | grep -v "REPLACE:" | grep -v "echo")

if [ -n "$YOUR_USERNAME_FILES" ]; then
    echo "❌ Found 'YOUR_USERNAME' in actual configuration:"
    echo "$YOUR_USERNAME_FILES" | head -5
    FOUND_ISSUES=$((FOUND_ISSUES + 1))
else
    echo "✅ No 'YOUR_USERNAME' placeholders in config files"
fi

echo ""
echo "Checking for placeholder MAC address in DHCP config..."
MAC_IN_DHCP=$(grep "aa:bb:cc:dd:ee:ff" configs/dhcp/kea-dhcp4.conf 2>/dev/null | grep -v "^//" | grep -v "^#" | grep -v "⚠️")

if [ -n "$MAC_IN_DHCP" ]; then
    echo "❌ Found placeholder MAC address in DHCP config:"
    echo "$MAC_IN_DHCP"
    echo "   ⚠️  Use 'ip link' to find actual MAC addresses"
    FOUND_ISSUES=$((FOUND_ISSUES + 1))
else
    echo "✅ No placeholder MAC addresses in DHCP config"
fi

echo ""
echo "Checking for 'mycorp.lan' domain..."
MYCORP_IN_CONFIG=$(grep -r "mycorp.lan" \
    configs/dns/ configs/dhcp/ \
    --include="*.conf" \
    --include="db.*" \
    2>/dev/null | wc -l)

if [ "$MYCORP_IN_CONFIG" -gt 0 ]; then
    echo "⚠️  Found 'mycorp.lan' in $MYCORP_IN_CONFIG files"
    echo "   ℹ️  This is OK for testing! Change later if needed."
    echo "   📖 To customize: edit configs/dns/db.forward-dns.template, configs/dns/db.reverse-dns.template, configs/dns/named.conf.local"
else
    echo "✅ Custom domain configured"
fi

echo ""
echo "🔧 Configuration Check:"
echo "----------------------"

# Check interface consistency (improved parsing)
echo "Checking interface name consistency..."
WAN_IF=$(grep "define WAN_IF" configs/fw/nftables.conf 2>/dev/null | awk -F'=' '{print $2}' | awk '{print $1}' | tr -d ' ')
LAN_IF=$(grep "define LAN_IF" configs/fw/nftables.conf 2>/dev/null | awk -F'=' '{print $2}' | awk '{print $1}' | tr -d ' ')
DHCP_IF=$(grep -A1 '"interfaces"' configs/dhcp/kea-dhcp4.conf 2>/dev/null | grep '"ens' | tr -d ' "[],' | head -1)

if [ -z "$LAN_IF" ] || [ -z "$DHCP_IF" ]; then
    echo "⚠️  Could not parse interface names"
elif [ "$LAN_IF" != "$DHCP_IF" ]; then
    echo "❌ Interface mismatch:"
    echo "   nftables LAN_IF: $LAN_IF"
    echo "   DHCP interface: $DHCP_IF"
    FOUND_ISSUES=$((FOUND_ISSUES + 1))
else
    echo "✅ Interface names consistent: $LAN_IF"
fi

echo ""
echo "Checking SSH username configuration..."
SSH_USER=$(grep "^AllowUsers" configs/hardening/sshd_config 2>/dev/null | awk '{print $2}')
CURRENT_USER=${SUDO_USER:-$(whoami)}

if [ -z "$SSH_USER" ]; then
    echo "❌ No SSH username configured in hardening/sshd_config"
    FOUND_ISSUES=$((FOUND_ISSUES + 1))
elif [ "$SSH_USER" = "YOUR_USERNAME_HERE" ] || [ "$SSH_USER" = "admin" ]; then
    echo "❌ SSH username is placeholder: $SSH_USER"
    echo "   ⚠️  Replace with your actual username: $CURRENT_USER"
    FOUND_ISSUES=$((FOUND_ISSUES + 1))
else
    echo "✅ SSH username configured: $SSH_USER"
    if [ "$SSH_USER" != "$CURRENT_USER" ]; then
        echo "   ⚠️  WARNING: SSH allows '$SSH_USER' but you're logged in as '$CURRENT_USER'"
        echo "   ⚠️  Make sure this user exists or you may not be able to SSH after deployment!"
    fi
fi

echo ""
echo "📋 System Interface Check:"
echo "-------------------------"
echo "Your actual interfaces:"
ip -br addr show 2>/dev/null | grep -E "(UP|DOWN)" || echo "❌ Cannot check interfaces"

echo ""
echo "Configured interfaces in nftables:"
echo "   WAN: $WAN_IF"
echo "   LAN: $LAN_IF"
echo ""
echo "⚠️  Verify these match your actual interfaces above!"

echo ""
echo "📊 Results Summary:"
echo "==================="
echo ""

# Explain false positives
echo "ℹ️  About False Positives:"
echo "   - Warnings in comments (⚠️ markers) are documentation - OK!"
echo "   - Placeholders in verify-placeholders.* scripts are search patterns - OK!"
echo "   - 'mycorp.lan' domain is fine for testing - change later if needed"
echo "   - YOUR_USERNAME in comments/descriptions is documentation - OK!"
echo ""

if [ $FOUND_ISSUES -eq 0 ]; then
    echo "✅ No critical placeholders found!"
    echo "✅ Ready for deployment (verify interface names match above)"
    echo ""
    echo "Next steps:"
    echo "1. Verify interface names match your system"
    echo "2. Verify SSH username matches your login"
    echo "3. Optional: Customize mycorp.lan domain"
    echo "4. Run: sudo ./deploy-complete.sh"
    exit 0
else
    echo "❌ Found $FOUND_ISSUES critical issue(s) in configuration files!"
    echo ""
    echo "📖 Fix these issues before deployment:"
    echo "   1. Edit the files listed above"
    echo "   2. Replace placeholder values with actual configuration"
    echo "   3. Run this script again to verify"
    echo ""
    echo "⚠️  Issues found are in ACTUAL CONFIG FILES, not documentation"
    exit 1
fi