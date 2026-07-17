with open("scratch/modified_aimbot.lua", "r", encoding="utf-8", errors="ignore") as f:
    lines = f.readlines()

output = []
for i, line in enumerate(lines, 1):
    if "globalenv" in line.lower() or "gayscript" in line.lower() or "gay script" in line.lower():
        output.append(f"{i}: {line.strip()}")

with open("scratch/variable_checks.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(output))
print("Results written to scratch/variable_checks.txt, count:", len(output))
