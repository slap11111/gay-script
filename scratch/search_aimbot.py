import re

with open("Source.lua", "r", encoding="utf-8", errors="ignore") as f:
    for line_num, line in enumerate(f, 1):
        line_lower = line.lower()
        if "aimbot" in line_lower or "owlhub" in line_lower or "owl" in line_lower:
            print(f"Line {line_num}: {line.strip()}")
