#!/bin/bash
# 🔍 Placeholder Verification Script
# Run this before deployment to check for unreplaced placeholders

echo "🔍 Checking for unreplaced placeholders..."
echo "========================================"

FOUND_ISSUES=0

echo ""
echo "🚨 Critical Placeholders Check:"
echo "------------------------------"

# Check for obvious placeholder patterns
echo "Checking for 'YOUR_USERNAME'..."
if grep -r "YOUR_USERNAME" . --exclude="*.md" --exclude="PLACEHOLDERS-GUIDE.md" --exclude="verify-placeholders.sh" >/dev/null 2>&1; then
    echo "❌ Found 'YOUR_USERNAME' placeholders:"
    grep -r "YOUR_USERNAME" . --exclude="*.md" --exclude="PLACEHOLDERS-GUIDE.md" --exclude="verify-placeholders.sh" | head -5
    FOUND_ISSUES=1
else
    echo "✅ No 'YOUR_USERNAME' placeholders found"
fi

echo ""
echo "Checking for placeholder MAC address..."
if grep -r "aa:bb:cc:dd:ee:ff" . --exclude="*.md" --exclude="PLACEHOLDERS-GUIDE.md" --exclude="verify-placeholders.sh" >/dev/null 2>&1; then
    echo "❌ Found placeholder MAC address:"
    grep -r "aa:bb:cc:dd:ee:ff" . --exclude="*.md" --exclude="PLACEHOLDERS-GUIDE.md" --exclude="verify-placeholders.sh"
    FOUND_ISSUES=1
else
    echo "✅ No placeholder MAC addresses found"
fi

echo ""
echo "Checking for 'mycorp.lan' domain..."
if grep -r "mycorp.lan" . --exclude="*.md" --exclude="PLACEHOLDERS-GUIDE.md" --exclude="verify-placeholders.sh" >/dev/null 2>&1; then
    echo "❌ Found 'mycorp.lan' placeholders:"
    grep -r "mycorp.lan" . --exclude="*.md" --exclude="PLACEHOLDERS-GUIDE.md" --exclude="verify-placeholders.sh" | head -5
    FOUND_ISSUES=1
else
    echo "✅ No 'mycorp.lan' placeholders found"
fi

echo ""
echo "🔧 Configuration Check:"
echo "----------------------"

# Check interface consistency
echo "Checking interface name consistency..."
WAN_IF=$(grep "define WAN_IF" ../configs/fw/nftables.conf | cut -d'=' -f2 | tr -d ' ')
LAN_IF=$(grep "define LAN_IF" ../configs/fw/nftables.conf | cut -d'=' -f2 | tr -d ' ')
DHCP_IF=$(grep '"interfaces"' -A1 ../configs/dhcp/kea-dhcp4.conf | grep '"' | tr -d ' "[]')

if [ "$LAN_IF" != "$DHCP_IF" ]; then
    echo "❌ Interface mismatch:"
    echo "   nftables LAN_IF: $LAN_IF"
    echo "   DHCP interface: $DHCP_IF"
    FOUND_ISSUES=1
else
    echo "✅ Interface names consistent: $LAN_IF"
fi

echo ""
echo "Checking SSH username configuration..."
SSH_USER=$(grep "AllowUsers" ../configs/hardening/sshd_config | cut -d' ' -f2)
if [ "$SSH_USER" = "YOUR_USERNAME_HERE" ] || [ "$SSH_USER" = "JollyOscar" ]; then
    echo "❌ SSH username needs updating in hardening/sshd_config:"
    echo "   Current: $SSH_USER"
    echo "   ⚠️  Replace with your actual username!"
    FOUND_ISSUES=1
else
    echo "✅ SSH username configured: $SSH_USER"
fi

echo ""
echo "📋 System Interface Check:"
echo "-------------------------"
echo "Your actual interfaces:"
ip -br addr show 2>/dev/null || echo "❌ Cannot check interfaces (run as user with network access)"

echo ""
echo "Configured interfaces:"
echo "   WAN: $WAN_IF"
echo "   LAN: $LAN_IF"
echo ""
echo "⚠️  Verify these match your actual interfaces above!"

echo ""
echo "📊 Results Summary:"
echo "==================="

if [ $FOUND_ISSUES -eq 0 ]; then
    echo "✅ No critical placeholders found!"
    echo "✅ Ready for deployment (but double-check interface names above)"
    echo ""
    echo "Next steps:"
    echo "1. Verify interface names match your system"
    echo "2. Run: sudo ./deploy-complete.sh"
    exit 0
else
    echo "❌ Found $FOUND_ISSUES issue(s) that need attention!"
    echo ""
    echo "📖 Please see PLACEHOLDERS-GUIDE.md for detailed instructions"
    echo "🚨 DO NOT deploy until all placeholders are replaced!"
    exit 1
fi