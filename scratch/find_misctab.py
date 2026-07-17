with open("scratch/full_sp3ar.lua", "r", encoding="utf-8", errors="ignore") as f:
    lines = f.readlines()

output = []
for i, line in enumerate(lines, 1):
    if "misctab" in line.lower() and not "local misctab" in line.lower():
        start = max(0, i - 4)
        end = min(len(lines), i + 4)
        output.append(f"--- Line {i} ---")
        for idx in range(start, end):
            output.append(f"{idx+1}: {lines[idx].strip()}")
        output.append("\n")

with open("scratch/misctab_occurrences.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(output))
print("Results written to scratch/misctab_occurrences.txt")
