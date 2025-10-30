"""Repository configuration validator

Checks:
 - Expected config files exist (DNS, DHCP, FW, hardening)
 - Scans workflows for referenced configs/ paths and verifies they exist
 - Sanitizes `configs/dhcp/kea-dhcp4.conf` (strip /* */ and ' //' comments) and validates JSON
 - Prints a concise summary and returns non-zero if important checks fail
"""
import os
import sys
import re
import json
from pathlib import Path

repo_root = Path(__file__).resolve().parents[1]
print(f"Repo root: {repo_root}")

expected_paths = [
    "configs/dhcp/kea-dhcp4.conf",
    "configs/dns/named.conf.local",
    "configs/dns/db.forward-dns.template",
    "configs/dns/db.reverse-dns.template",
    "configs/fw/nftables.conf",
    "configs/hardening/sshd_config",
    "configs/hardening/sysctl-security.conf",
]

missing = []
for p in expected_paths:
    full = repo_root / p
    if not full.exists():
        missing.append(p)

# Scan workflows for configs/ references
workflows_dir = repo_root / ".github" / "workflows"
workflow_refs = set()
if workflows_dir.exists():
    for wf in workflows_dir.glob("*.yml"):
        raw = wf.read_text(encoding='utf-8')
        for m in re.finditer(r"configs/[A-Za-z0-9_\-/.]+", raw):
            workflow_refs.add(m.group(0))

print("\nWorkflow-referenced config paths:")
for r in sorted(workflow_refs):
    exists = (repo_root / r).exists()
    print(f" - {r}: {'OK' if exists else 'MISSING'}")
    if not exists:
        missing.append(r)

# Validate Kea JSON (sanitization)
kea_path = repo_root / "configs" / "dhcp" / "kea-dhcp4.conf"
kea_ok = False
if kea_path.exists():
    raw = kea_path.read_text(encoding='utf-8')
    # strip block comments
    sanitized = re.sub(r'/\*.*?\*/', '', raw, flags=re.DOTALL)
    # strip '//' comments that are preceded by whitespace
    sanitized = re.sub(r"[ \t]+//.*$", "", sanitized, flags=re.MULTILINE)
    try:
        parsed = json.loads(sanitized)
        print("\nKea JSON: OK (sanitized)")
        kea_ok = True
    except Exception as e:
        print("\nKea JSON: ERROR after sanitization:", e)
        # show context if possible
        msg = str(e)
        mm = re.search(r'char (\d+)', msg)
        if mm:
            idx = int(mm.group(1))
            cum = 0
            lines = sanitized.splitlines()
            lineno = 0
            for i, L in enumerate(lines):
                cum += len(L) + 1
                if cum > idx:
                    lineno = i + 1
                    break
            start = max(0, lineno - 5)
            end = min(len(lines), lineno + 5)
            print(f"Context (lines {start+1}-{end}):")
            for i in range(start, end):
                print(f"{i+1:4}: {lines[i]}")
        missing.append(str(kea_path.relative_to(repo_root)))
else:
    print("\nKea config not found:", kea_path)
    missing.append(str(kea_path.relative_to(repo_root)))

# Summarize
print("\n=== Summary ===")
if missing:
    print(f"Missing or invalid items ({len(missing)}):")
    for m in sorted(set(missing)):
        print(f" - {m}")
    sys.exit(2)
else:
    print("All expected configs present and Kea JSON parsed OK.")
    sys.exit(0)
