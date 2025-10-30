# 🔍 False Positives in Placeholder Verification

This document explains warnings that may appear during placeholder verification but are **not actual problems**.

## What is a False Positive?

A false positive is when the verification script warns about a "placeholder" that is actually:
- Documentation or a comment
- Part of the verification script itself
- A valid test/example value
- Correct for your system but looks like a placeholder

---

## Common False Positives

### 1. "mycorp.lan" Domain

**Warning:**
```
⚠️  Found 'mycorp.lan' in 16 files
```

**Why This Happens:**
The default domain name is `mycorp.lan` which works perfectly for testing.

**Is This OK?**
✅ **YES!** This is fine for testing and learning. Change it later when you have a real internal domain name.

**How to Fix (Optional):**
Edit these files if you want a custom domain:
- `configs/dns/db.forward-dns.template`
- `configs/dns/db.reverse-dns.template`
- `configs/dns/named.conf.local`
- `configs/dhcp/kea-dhcp4.conf`

---

### 2. Inline Comment Warnings

**Warning:**
```
Found 'REPLACE' in comments
```

**Why This Happens:**
Config files have helpful comments like:
```bash
define WAN_IF = ens33  # ⚠️  REPLACE: Your WAN interface name
```

**Is This OK?**
✅ **YES!** These are instructions for humans, not actual configuration values. The improved verification script filters these out.

**How to Fix:**
No fix needed! The improved `verify-placeholders.sh` ignores comments.

---

### 3. Verification Script Contains Placeholders

**Warning:**
```
Found 'YOUR_USERNAME' in verify-placeholders.sh
```

**Why This Happens:**
The verification script searches FOR these patterns, so they appear in the script itself.

**Is This OK?**
✅ **YES!** The script needs these patterns to search for them. The improved script excludes itself from checks.

**How to Fix:**
No fix needed! This is expected and handled automatically.

---

### 4. SSH Username Doesn't Match Login

**Warning:**
```
⚠️  WARNING: SSH allows 'alice' but you're logged in as 'bob'
```

**Why This Happens:**
The SSH config allows a specific user, but you're currently logged in as a different user.

**Is This OK?**
⚠️  **MAYBE** - You need to decide:

**Option A:** You want to SSH as your current user (`bob`)
```bash
sudo nano configs/hardening/sshd_config
# Change: AllowUsers alice
# To: AllowUsers bob
```

**Option B:** User `alice` exists and you'll use that account
```bash
# Make sure alice user exists:
id alice
```

**Option C:** Allow multiple users
```bash
sudo nano configs/hardening/sshd_config
# Change: AllowUsers alice
# To: AllowUsers alice bob
```

---

### 5. GitHub Workflow Files

**Warning:**
```
Found placeholders in .github/workflows/
```

**Why This Happens:**
CI/CD workflow files test the placeholder verification system.

**Is This OK?**
✅ **YES!** These are for automated testing. The improved script excludes `.github` directories.

**How to Fix:**
No fix needed! Workflow files are excluded from verification.

---

## Real Problems (NOT False Positives)

### ❌ YOUR_USERNAME in Actual Config

**Example:**
```bash
# In configs/hardening/security-setup.sh:
SSH_PUBLIC_KEY_URL="https://github.com/YOUR_USERNAME.keys"
```

**This is a REAL problem** - not a comment, actually used in the script.

**Fix:**
```bash
SSH_PUBLIC_KEY_URL="https://github.com/YourActualGitHubUsername.keys"
```

---

### ❌ Interface Names Don't Match System

**Example:**
```
❌ Interface mismatch:
   nftables LAN_IF: ens37
   Your system has: eth1
```

**This is a REAL problem** - config doesn't match your hardware.

**Fix:**
Check your actual interfaces:
```bash
ip link show
```

Update config files to use your actual interface names.

---

### ❌ Placeholder MAC Address in DHCP

**Example:**
```json
"hw-address": "aa:bb:cc:dd:ee:ff",
```

**This is a REAL problem** if it's not commented out or removed.

**Fix:**
Either remove the reservation or use a real MAC address:
```bash
ip link show  # Find real MAC addresses
```

---

## How to Use Verification Script

```bash
# Run verification
sudo ./scripts/verify-placeholders.sh

# Read the output:
# ✅ = All good
# ⚠️  = Review (probably OK)
# ❌ = Must fix

# At the end, it shows:
# "ℹ️  About False Positives:"
# with explanations
```

---

## Quick Reference

| Warning | False Positive? | Action |
|---------|----------------|--------|
| `mycorp.lan` found | ✅ YES | OK for testing, change later |
| `YOUR_USERNAME` in comments | ✅ YES | Ignored by improved script |
| `YOUR_USERNAME` in config values | ❌ NO | Must replace with actual username |
| Interface names in comments | ✅ YES | Ignored by improved script |
| Interface mismatch (actual config) | ❌ NO | Must match your system |
| SSH username warning | ⚠️  MAYBE | Verify user exists |
| Placeholder MAC in comments | ✅ YES | OK if commented |
| Placeholder MAC in active config | ❌ NO | Remove or replace |

---

## Still Confused?

See `docs/PLACEHOLDERS-GUIDE.md` for the complete guide to replacing placeholders.

The improved `scripts/verify-placeholders.sh` script automatically filters most false positives and explains what's left!