with open("scratch/pasted_code.lua", "r", encoding="utf-8", errors="ignore") as f:
    lines = f.readlines()

output = []
for i, line in enumerate(lines, 1):
    line_lower = line.lower()
    if any(k in line_lower for k in ["credit", "developer", "helper", "created", "fanta", "cat", "zosua", "rize"]):
        # output the line and a few lines around it
        start = max(0, i - 5)
        end = min(len(lines), i + 5)
        output.append(f"--- Line {i} ---")
        for idx in range(start, end):
            output.append(f"{idx+1}: {lines[idx].strip()}")
        output.append("\n")

with open("scratch/credits_found.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(output))
print("Results written to scratch/credits_found.txt")
