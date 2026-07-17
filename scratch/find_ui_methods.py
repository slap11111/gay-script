with open("scratch/full_sp3ar.lua", "r", encoding="utf-8", errors="ignore") as f:
    lines = f.readlines()

output = []
recording = False
for i, line in enumerate(lines, 1):
    if "function UI." in line:
        output.append(f"{i}: {line.strip()}")

with open("scratch/ui_methods.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(output))
print("Results written to scratch/ui_methods.txt")
