import re

with open("scratch/full_sp3ar.lua", "r", encoding="utf-8", errors="ignore") as f:
    lines = f.readlines()

output = []
for i, line in enumerate(lines, 1):
    line_lower = line.lower()
    if any(k in line_lower for k in ["credits", "developer", "helper", "created", "fanta", "cat", "zosua", "rize", "author", "creator", "sp3ar", "parvus"]):
        output.append(f"{i}: {line.strip()}")

with open("scratch/credits_exact_lines.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(output))
print("Found exact credit lines count:", len(output))
