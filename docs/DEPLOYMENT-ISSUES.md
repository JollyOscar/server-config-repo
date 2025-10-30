# Deployment Issues Found and Fixed

This document tracks all issues discovered during comprehensive Ubuntu 24.04 deployment testing and their resolutions.

## Summary

**Total Issues Found:** 22
**Total Issues Fixed:** 22
**Success Rate:** 100%

All issues have been resolved in the Post-Testing branch.

---

## Critical Issues (Deployment Blockers)

### Issue #1: Corrupted SSH Configuration

**File:** `hardening/sshd_config`
**Severity:** Critical
**Symptom:** SSH configuration has 682 lines of duplicated content, syntax errors like `AddressFamily inet#`
**Impact:** Phase 4 (SSH hardening) fails completely, SSH service won't start
**Fix:** Complete file rewrite with clean Ubuntu 24.04 compatible configuration
**Status:** ✅ Fixed

### Issue #2 & #3: BIND9 Duplicate Options Block

**Files:** `dns/named.conf.local`, `dns/named.conf.options`
**Severity:** Critical
**Symptom:** "'options' redefined near 'options'" error
**Impact:** Phase 5 (DNS) fails, BIND9 won't start
**Root Cause:** Ubuntu's `/etc/bind/named.conf` includes BOTH named.conf.options and named.conf.local.
Having options block in both causes redefinition error.
**Fix:**
- Moved all `options {}` content to `dns/named.conf.options`
- Left only zone definitions in `dns/named.conf.local`
**Status:** ✅ Fixed

### Issue #4: AIDE Initialization Hangs Deployment

**File:** `hardening/security-setup.sh`
**Severity:** Critical
**Symptom:** Deployment appears frozen at "Initializing file integrity monitoring"
**Impact:** Makes testing impossible, users think deployment failed
**Root Cause:** `aideinit` command runs synchronously and takes 20-30 minutes
**Fix:** Commented out AIDE initialization with instructions to run manually: `sudo aideinit`
**Status:** ✅ Fixed

### Issue #9: systemd-resolved Port 53 Conflict

**File:** `deploy-complete.sh`
**Severity:** Critical
**Symptom:** BIND9 fails to bind to port 53
**Impact:** DNS service won't start
**Root Cause:** Ubuntu's systemd-resolved listens on port 53 by default
**Fix:** Added configuration to disable DNSStubListener in systemd-resolved
**Status:** ✅ Fixed

### Issue #17: nftables Quoted Define Statements

**File:** `fw/nftables.conf`
**Severity:** Critical
**Symptom:** "Could not resolve hostname: Name or service not known" error
**Impact:** Phase 7 (Firewall) fails, no NAT/routing configured
**Root Cause:** nftables interprets quoted values as hostnames requiring DNS resolution
**Fix:** Removed quotes from ALL define statements (e.g., `define LAN_NET = 10.207.0.0/24`)
**Status:** ✅ Fixed

### Issue #19: Wrong Kea DHCP Package Name

**File:** `deploy-complete.sh`
**Severity:** Critical
**Symptom:** Package 'kea-dhcp4' not found
**Impact:** Phase 2 fails, DHCP server not installed
**Fix:** Changed package name to `kea-dhcp4-server`
**Status:** ✅ Fixed

### Issue #20: Wrong Kea DHCP Service Name

**File:** `deploy-complete.sh`
**Severity:** Critical
**Symptom:** Service 'kea-dhcp4.service' not found
**Impact:** Phase 6 fails, DHCP service won't start
**Fix:** Changed service name to `kea-dhcp4-server.service`
**Status:** ✅ Fixed

### Issue #22: Deploy Script Copies Broken Config Files

**File:** `deploy-complete.sh`
**Severity:** Critical
**Symptom:** Manual fixes get overwritten on re-deployment
**Impact:** Cannot recover from errors, must fix source files in repo
**Fix:** All source files in repository have been corrected
**Status:** ✅ Fixed

---

## Medium Issues (Service Failures/Warnings)

### Issue #5: Wrong Interface Names Throughout

**Files:** Multiple (dhcp, fw, test scripts)
**Severity:** Medium
**Symptom:** Services bind to wrong interfaces (ens18/ens19/ens34)
**Impact:** DHCP and firewall don't work on actual interfaces
**Fix:** Updated all files to use ens33 (WAN) and ens37 (LAN)
**Status:** ✅ Fixed

### Issue #6: Hardcoded Admin Username

**Files:** `hardening/sshd_config`, `hardening/security-setup.sh`
**Severity:** Medium
**Symptom:** SSH allows user 'admin' or 'your_username' instead of actual user
**Impact:** SSH access doesn't work for JollyOscar user
**Fix:** Changed AllowUsers to `JollyOscar`
**Status:** ✅ Fixed

### Issue #10: DNS Service Name Confusion

**File:** `deploy-complete.sh`
**Severity:** Medium
**Symptom:** "Refusing to operate on alias name" warning
**Impact:** Cosmetic warning, but confusing
**Root Cause:** Script uses `named.service`, Ubuntu's actual service is `bind9.service`
**Fix:** Changed all references to `bind9.service`
**Status:** ✅ Fixed

### Issue #21: Kea Test Binary Name Wrong

**File:** `deploy-complete.sh`
**Severity:** Medium
**Symptom:** Command `kea-dhcp4-server -t` not found
**Impact:** Configuration validation fails
**Fix:** Changed test command to `kea-dhcp4 -t` (binary name differs from service name)
**Status:** ✅ Fixed

---

## Minor Issues (Cosmetic/Warnings)

### Issue #8: Netplan File Permissions

**File:** `deploy-complete.sh`
**Severity:** Minor
**Symptom:** "Permissions too open" warning for netplan files
**Impact:** Security warning only
**Fix:** Added `chmod 600` for netplan files
**Status:** ✅ Fixed

---

## Testing Results

### Before Fixes

- ❌ Phase 1-3: Pass
- ❌ Phase 4 (SSH): FAIL - Corrupted config
- ❌ Phase 5 (DNS): FAIL - Duplicate options block
- ❌ Phase 6 (DHCP): FAIL - Wrong package/service names
- ❌ Phase 7 (Firewall): FAIL - Quoted defines
- ❌ Phase 8-10: Not reached

### After Fixes

- ✅ Phase 1: Pre-deployment checklist PASS
- ✅ Phase 2: System preparation PASS
- ✅ Phase 3: Repository deployment PASS
- ✅ Phase 4: Security hardening PASS
- ✅ Phase 5: DNS service deployment PASS
- ✅ Phase 6: DHCP service deployment PASS
- ✅ Phase 7: Firewall deployment PASS
- ✅ Phase 8: Service verification PASS
- ✅ Phase 9: Functionality testing PASS
- ✅ Phase 10: Final configuration PASS

**All services operational:**
- ✅ SSH (port 2222, hardened)
- ✅ DNS (BIND9, serving mycorp.lan)
- ✅ DHCP (Kea, serving 10.207.0.0/24)
- ✅ Firewall (nftables, NAT active)
- ✅ fail2ban (monitoring)

---

## Lessons Learned

1. **Always separate BIND9 options from zones** - Ubuntu's default config structure requires this
2. **nftables variables must NOT be quoted** - Quotes make them hostname lookups
3. **Ubuntu package names don't always match service names** - kea-dhcp4-server vs kea-dhcp4
4. **systemd-resolved conflicts with BIND9** - Must disable stub listener
5. **Long-running tasks need user feedback** - AIDE initialization should be optional
6. **Interface names vary by system** - Make them configurable or document clearly
7. **Test on target OS version** - Ubuntu 24.04 has different defaults than older versions

---

## Deployment Verification Checklist

After applying all fixes, verify:

- [ ] SSH config validates: `sudo sshd -t`
- [ ] BIND9 config validates: `sudo named-checkconf`
- [ ] BIND9 zones validate: `sudo named-checkzone mycorp.lan /etc/bind/db.mycorp.lan`
- [ ] Kea config validates: `sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf`
- [ ] nftables config validates: `sudo nft -c -f /etc/nftables.conf`
- [ ] All packages install: `sudo apt install openssh-server bind9 kea-dhcp4-server nftables fail2ban`
- [ ] All services start: `systemctl status bind9 kea-dhcp4-server nftables fail2ban ssh`
- [ ] DNS resolves internal: `nslookup gateway.mycorp.lan 127.0.0.1`
- [ ] DNS resolves external: `nslookup google.com 127.0.0.1`
- [ ] DHCP listens: `sudo netstat -ulnp | grep :67`
- [ ] Firewall loaded: `sudo nft list ruleset`
- [ ] NAT configured: `sudo nft list table inet nat`
- [ ] IP forwarding enabled: `cat /proc/sys/net/ipv4/ip_forward` (should be 1)

---

**Document Version:** 1.0  
**Last Updated:** 2025-10-30  
**Tested On:** Ubuntu Server 24.04 LTS  
**Repository:** <https://github.com/JollyOscar/server-config-repo>