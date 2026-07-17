import sys
import re

# Set console to utf-8 if possible
try:
    sys.stdout.reconfigure(encoding='utf-8')
except:
    pass

with open("scratch/pasted_code.lua", "r", encoding="utf-8", errors="ignore") as f:
    code = f.read()

# Find occurrences of Developer or helpers or Sp3arParvus
for match in re.finditer(r'(?i)(developer|helper|credit|created by|by\b|sp3arparvus)', code):
    start = max(0, match.start() - 100)
    end = min(len(code), match.end() + 100)
    snippet = code[start:end]
    # Escape non-ASCII characters
    escaped_snippet = snippet.encode('ascii', errors='backslashreplace').decode('ascii')
    print(f"Match context ({match.start()}): {escaped_snippet}")
