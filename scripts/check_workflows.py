"""Repo sanity checks for workflows

- Parse YAML files under .github/workflows
- Report YAML parse errors
- Extract file paths referenced in `run:` blocks that look like configs/... and verify they exist
- Exit code 0 if all good, 2 if errors found
"""
import os
import sys
import re

WORKFLOWS_DIR = os.path.join(os.path.dirname(__file__), '..', '.github', 'workflows')
WORKFLOWS_DIR = os.path.normpath(WORKFLOWS_DIR)

if not os.path.isdir(WORKFLOWS_DIR):
    print(f"Workflows dir not found: {WORKFLOWS_DIR}")
    sys.exit(2)

files = [f for f in os.listdir(WORKFLOWS_DIR) if f.endswith('.yml') or f.endswith('.yaml')]
if not files:
    print("No workflow YAML files found.")
    sys.exit(0)

missing_paths = set()
parse_errors = []

# Try to import PyYAML
try:
    import yaml
except Exception as e:
    print("PyYAML is required to parse workflow files. Please install with: python -m pip install --user pyyaml")
    sys.exit(2)

path_pattern = re.compile(r"configs/[A-Za-z0-9_\-/.]+")

for fn in files:
    full = os.path.join(WORKFLOWS_DIR, fn)
    print(f"\n== Checking {fn} ==")
    try:
        with open(full, 'r', encoding='utf-8') as fh:
            raw = fh.read()
        # Parse YAML
        docs = list(yaml.safe_load_all(raw))
        print(f"Parsed YAML: {len(docs)} document(s)")
    except Exception as e:
        print(f"YAML parse error in {fn}: {e}")
        parse_errors.append((fn, str(e)))
        continue

    # search for references to configs/ in raw text (covers run: blocks)
    for m in path_pattern.finditer(raw):
        p = m.group(0)
        # normalize relative path from repo root
        candidate = os.path.normpath(os.path.join(os.path.dirname(WORKFLOWS_DIR), '..', p))
        # The above join goes up too far; instead compute from repo root
        repo_root = os.path.normpath(os.path.join(WORKFLOWS_DIR, '..', '..'))
        candidate = os.path.normpath(os.path.join(repo_root, p))
        if not os.path.exists(candidate):
            missing_paths.add((p, candidate))
            print(f"Referenced path not found: {p} -> {candidate}")
        else:
            print(f"Referenced path exists: {p}")

print("\n=== Summary ===")
if parse_errors:
    print(f"YAML parse errors: {len(parse_errors)}")
    for fn, err in parse_errors:
        print(f" - {fn}: {err}")
else:
    print("No YAML parse errors.")

if missing_paths:
    print(f"Missing referenced files: {len(missing_paths)}")
    for p, full in missing_paths:
        print(f" - {p} -> {full}")
else:
    print("All referenced paths in workflows exist.")

# Quick git status
try:
    import subprocess
    out = subprocess.check_output(['git', 'status', '--porcelain'], cwd=repo_root, text=True)
    if out.strip():
        print("\nUncommitted changes present (git status --porcelain):")
        print(out)
    else:
        print("\nNo uncommitted changes (git clean).")
except Exception as e:
    print(f"Could not run git status: {e}")

# Exit codes: 0 = ok, 2 = issues
if parse_errors or missing_paths:
    sys.exit(2)
else:
    sys.exit(0)
