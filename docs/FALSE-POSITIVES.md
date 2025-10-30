# 🔍 Understanding "False Positives" in Verification

This guide explains why the `verify-placeholders.sh` script might flag items that are not actual errors.
Understanding these "false positives" will help you confidently assess the verification results.

## What is a False Positive?

A false positive occurs when the verification script flags a piece of text as a placeholder that is, in fact, intentional.
This can happen if the text is:
- Part of a comment or documentation.
- A valid example value (like `mycorp.lan`).
- A necessary part of the script's own code.

The current verification script is designed to be intelligent and ignore most of these, but it's still helpful to understand them.

---

## Common False Positives (and Why They Are Safe)

### 1. The `mycorp.lan` Domain

**Potential Warning:**

```
⚠️  Found 'mycorp.lan' in 16 files. This may be a placeholder.
```

**Explanation:**

The repository uses `mycorp.lan` as a default, functional domain name for testing and demonstration purposes.
It is not a broken value and works out-of-the-box.

**Is This a Problem?**

✅ **No.** This is the intended default. You only need to change this when you are ready to deploy with your own custom internal domain name.

**How to Change (Optional):**

If you have a custom domain, you can replace `mycorp.lan` in the following files:
- `configs/dns/db.forward-dns.template`
- `configs/dns/db.reverse-dns.template`
- `configs/dns/named.conf.local`
- `configs/dhcp/kea-dhcp4.conf`

---

### 2. Placeholders in Comments

**Potential Warning:**

```
INFO: Found placeholder 'REPLACE' inside a comment.
```

**Explanation:**

Many configuration files contain helpful comments that include placeholder markers to guide you. For example:

```bash
# ⚠️ REPLACE: Your WAN interface name (e.g., ens33)
define WAN_IF = "ens33"
```

The script is designed to find placeholders, and sometimes it finds them in the instructional comments themselves.

**Is This a Problem?**

✅ **No.** The improved `verify-placeholders.sh` script is smart enough to check if the placeholder is in a comment.
It will inform you about it but will not treat it as an error that needs fixing.

---

### 3. Placeholders Within the Verification Script Itself

**Potential Warning:**

```
INFO: Found placeholder 'YOUR_USERNAME' in scripts/verify-placeholders.sh.
```

**Explanation:**

The verification script must contain the placeholder patterns it is searching for.
For example, to find `YOUR_USERNAME`, that exact string must exist within the script's code.

**Is This a Problem?**

✅ **No.** This is expected behavior. The script is designed to ignore matches found within itself.

---

### 4. Mismatched SSH Usernames

**Potential Warning:**

```
⚠️  WARNING: SSH config allows user 'alice', but you are logged in as 'bob'.
```

**Explanation:**

The `sshd_config` file specifies which users are allowed to log in via SSH.
The script checks if your *current* Linux username is on that list. If not, it issues this warning.

**Is This a Problem?**

⚠️ **Maybe.** This is a genuine check that requires your judgment.

- **Scenario A: The warning is correct.** You want to log in as `bob`, but the config only allows `alice`.
  - **Fix:** Edit `configs/hardening/sshd_config` and change `AllowUsers alice` to `AllowUsers bob`.

- **Scenario B: The warning is expected.** You are logged in as `bob` to run the deployment, but you fully intend to use the `alice` account for remote SSH access later.
  - **Fix:** No fix is needed. You can safely ignore this warning, as your setup is intentional.

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