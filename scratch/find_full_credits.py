import re

with open("scratch/full_sp3ar.lua", "r", encoding="utf-8", errors="ignore") as f:
    code = f.read()

# Find occurrences of Developer, helpers, author, credits, creator
for match in re.finditer(r'(?i)(developer|helper|credit|created by|author|creator|by\b|sp3arparvus)', code):
    start = max(0, match.start() - 100)
    end = min(len(code), match.end() + 100)
    snippet = code[start:end]
    escaped_snippet = snippet.encode('ascii', errors='backslashreplace').decode('ascii')
    print(f"Match context ({match.start()}): {escaped_snippet}")
