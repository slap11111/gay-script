import re

with open("scratch/full_sp3ar.lua", "r", encoding="utf-8", errors="ignore") as f:
    lines = f.readlines()

output = []
for i, line in enumerate(lines, 1):
    line_lower = line.lower()
    if "createwindow" in line_lower or "createtab" in line_lower or "createcredits" in line_lower or "creator" in line_lower or "cat" in line_lower or "fanta" in line_lower or "zosua" in line_lower or "rize" in line_lower:
        start = max(0, i - 4)
        end = min(len(lines), i + 4)
        output.append(f"--- Line {i} ---")
        for idx in range(start, end):
            output.append(f"{idx+1}: {lines[idx].strip()}")
        output.append("\n")

with open("scratch/tabs_sections.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(output))
print("Results written to scratch/tabs_sections.txt")
