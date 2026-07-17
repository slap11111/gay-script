with open("scratch/full_sp3ar.lua", "r", encoding="utf-8", errors="ignore") as f:
    lines = f.readlines()

for i, line in enumerate(lines, 1):
    if "InitializeShortcutsPage" in line:
        print(f"Line {i}: {line.strip()}")
