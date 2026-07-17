with open("scratch/full_sp3ar.lua", "r", encoding="utf-8", errors="ignore") as f:
    lines = f.readlines()

output = []
for i, line in enumerate(lines, 1):
    if "createsection" in line.lower() or "createlabel" in line.lower():
        output.append(f"{i}: {line.strip()}")

with open("scratch/sections_labels.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(output))
print("Results written to scratch/sections_labels.txt, count:", len(output))
