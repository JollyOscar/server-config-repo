# Placeholder Verification Script (PowerShell)
# Run this before deployment to check for unreplaced placeholders

Write-Host "Checking for unreplaced placeholders..." -ForegroundColor Cyan
Write-Host "========================================"

$FOUND_ISSUES = 0

Write-Host ""
Write-Host "🚨 Critical Placeholders Check:" -ForegroundColor Red
Write-Host "------------------------------"

# Check for obvious placeholder patterns
Write-Host "Checking for 'YOUR_USERNAME'..."
$yourUsernameFiles = Select-String -Path ".\*" -Pattern "YOUR_USERNAME" -Exclude "*.md", "PLACEHOLDERS-GUIDE.md", "verify-placeholders.*" -Recurse -ErrorAction SilentlyContinue
if ($yourUsernameFiles) {
    Write-Host "❌ Found 'YOUR_USERNAME' placeholders:" -ForegroundColor Red
    $yourUsernameFiles | Select-Object -First 5 | ForEach-Object { Write-Host "   $($_.Filename):$($_.LineNumber): $($_.Line.Trim())" }
    $FOUND_ISSUES++
} else {
    Write-Host "✅ No 'YOUR_USERNAME' placeholders found" -ForegroundColor Green
}

Write-Host ""
Write-Host "Checking for placeholder MAC address..."
$macFiles = Select-String -Path ".\*" -Pattern "aa:bb:cc:dd:ee:ff" -Exclude "*.md", "PLACEHOLDERS-GUIDE.md", "verify-placeholders.*" -Recurse -ErrorAction SilentlyContinue
if ($macFiles) {
    Write-Host "❌ Found placeholder MAC address:" -ForegroundColor Red
    $macFiles | ForEach-Object { Write-Host "   $($_.Filename):$($_.LineNumber): $($_.Line.Trim())" }
    $FOUND_ISSUES++
} else {
    Write-Host "✅ No placeholder MAC addresses found" -ForegroundColor Green
}

Write-Host ""
Write-Host "Checking for 'mycorp.lan' domain..."
$domainFiles = Select-String -Path ".\*" -Pattern "mycorp\.lan" -Exclude "*.md", "PLACEHOLDERS-GUIDE.md", "verify-placeholders.*" -Recurse -ErrorAction SilentlyContinue
if ($domainFiles) {
    Write-Host "❌ Found 'mycorp.lan' placeholders:" -ForegroundColor Red
    $domainFiles | Select-Object -First 5 | ForEach-Object { Write-Host "   $($_.Filename):$($_.LineNumber): $($_.Line.Trim())" }
    $FOUND_ISSUES++
} else {
    Write-Host "✅ No 'mycorp.lan' placeholders found" -ForegroundColor Green
}

Write-Host ""
Write-Host "🔧 Configuration Check:" -ForegroundColor Yellow
Write-Host "----------------------"

# Check interface consistency
Write-Host "Checking interface name consistency..."
$nftablesContent = Get-Content "..\configs\fw\nftables.conf" -ErrorAction SilentlyContinue
$wanIF = ($nftablesContent | Select-String "define WAN_IF").ToString().Split('=')[1].Trim()
$lanIF = ($nftablesContent | Select-String "define LAN_IF").ToString().Split('=')[1].Trim()

$dhcpContent = Get-Content "..\configs\dhcp\kea-dhcp4.conf" -ErrorAction SilentlyContinue
$dhcpIF = ($dhcpContent | Select-String '"ens[0-9]+"').Matches.Value.Trim('"')

if ($lanIF -ne $dhcpIF) {
    Write-Host "❌ Interface mismatch:" -ForegroundColor Red
    Write-Host "   nftables LAN_IF: $lanIF"
    Write-Host "   DHCP interface: $dhcpIF"
    $FOUND_ISSUES++
} else {
    Write-Host "✅ Interface names consistent: $lanIF" -ForegroundColor Green
}

Write-Host ""
Write-Host "Checking SSH username configuration..."
$sshdContent = Get-Content "..\configs\hardening\sshd_config" -ErrorAction SilentlyContinue
$sshUser = ($sshdContent | Select-String "AllowUsers").ToString().Split(' ')[1].Trim()
if ($sshUser -eq "YOUR_USERNAME_HERE" -or $sshUser -eq "JollyOscar") {
    Write-Host "❌ SSH username needs updating in hardening/sshd_config:" -ForegroundColor Red
    Write-Host "   Current: $sshUser"
    Write-Host "   ⚠️  Replace with your actual username!" -ForegroundColor Yellow
    $FOUND_ISSUES++
} else {
    Write-Host "✅ SSH username configured: $sshUser" -ForegroundColor Green
}

Write-Host ""
Write-Host "📋 System Interface Check:" -ForegroundColor Cyan
Write-Host "-------------------------"
Write-Host "Your actual interfaces:"
try {
    $interfaces = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object Name, InterfaceDescription
    $interfaces | ForEach-Object { Write-Host "   $($_.Name): $($_.InterfaceDescription)" }
} catch {
    Write-Host "❌ Cannot check interfaces (run as administrator)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Configured interfaces:"
Write-Host "   WAN: $wanIF"
Write-Host "   LAN: $lanIF"
Write-Host ""
Write-Host "⚠️  Verify these match your actual interfaces above!" -ForegroundColor Yellow

Write-Host ""
Write-Host "📊 Results Summary:" -ForegroundColor Cyan
Write-Host "==================="

if ($FOUND_ISSUES -eq 0) {
    Write-Host "✅ No critical placeholders found!" -ForegroundColor Green
    Write-Host "✅ Ready for deployment (but double-check interface names above)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "1. Verify interface names match your system"
    Write-Host "2. Run: sudo ./deploy-complete.sh"
    exit 0
} else {
    Write-Host "❌ Found $FOUND_ISSUES issue(s) that need attention!" -ForegroundColor Red
    Write-Host ""
    Write-Host "📖 Please see PLACEHOLDERS-GUIDE.md for detailed instructions" -ForegroundColor Yellow
    Write-Host "🚨 DO NOT deploy until all placeholders are replaced!" -ForegroundColor Red
    exit 1
}
}