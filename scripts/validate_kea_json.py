#!/usr/bin/env python3
import re, json, sys, os
p = 'configs/dhcp/kea-dhcp4.conf'
if not os.path.exists(p):
    print('file not found:', p)
    sys.exit(1)
raw = open(p, 'r', encoding='utf-8').read()
print('--- ORIGINAL HEAD (first 20 lines) ---')
print('\n'.join(raw.splitlines()[:20]))
# strip C-style block comments (non-greedy, DOTALL)
sanitized = re.sub(r'/\*.*?\*/', '', raw, flags=re.DOTALL)
# strip line comments that start with whitespace then // (avoid removing http:// inside strings)
sanitized = re.sub(r"[ \t]+//.*$", "", sanitized, flags=re.MULTILINE)
print('\n--- SANITIZED HEAD (first 20 lines) ---')
print('\n'.join(sanitized.splitlines()[:20]))
print('\n--- JSON PARSE ATTEMPT ---')
try:
    obj = json.loads(sanitized)
    print('JSON parse: OK')
    if isinstance(obj, dict):
        print('Top-level keys:', list(obj.keys())[:10])
except Exception as e:
    print('JSON parse error:', e)
    # try to show context around the error position if available
    msg = str(e)
    m = None
    try:
        # extract char index from message like 'char 879'
        import re
        mm = re.search(r'char (\d+)', msg)
        if mm:
            idx = int(mm.group(1))
            # compute line number and show surrounding lines
            lines = sanitized.splitlines()
            # find line number by summing lengths
            cum = 0
            lineno = 0
            for i, L in enumerate(lines):
                cum += len(L) + 1
                if cum > idx:
                    lineno = i + 1
                    break
            start = max(0, lineno - 5)
            end = min(len(lines), lineno + 5)
            print(f"\n--- Context around line {lineno} (lines {start+1}-{end}) ---")
            for i in range(start, end):
                print(f"{i+1:4}: {lines[i]}")
    except Exception:
        pass
    sys.exit(2)
