import re

with open("scratch/full_sp3ar.lua", "r", encoding="utf-8", errors="ignore") as f:
    lines = f.readlines()

output = []
for i, line in enumerate(lines, 1):
    line_lower = line.lower()
    # Check for keywords that might indicate credits/author displays
    if any(k in line_lower for k in ["credit", "author", "created", "by", "creator", "dev", "helper", "zosua", "fanta", "cat", "rize"]):
        # output the line and a few lines around it
        start = max(0, i - 3)
        end = min(len(lines), i + 3)
        output.append(f"--- Line {i} ---")
        for idx in range(start, end):
            output.append(f"{idx+1}: {lines[idx].strip()}")
        output.append("\n")

with open("scratch/full_credits_found.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(output))
print("Results written to scratch/full_credits_found.txt, count:", len(output))
