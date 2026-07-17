with open("scratch/full_sp3ar.lua", "r", encoding="utf-8", errors="ignore") as f:
    lines = f.readlines()

output = []
for i in range(9450, len(lines)):
    line = lines[i]
    line_lower = line.lower()
    # Find button and section additions, or text labels containing credits/names
    if "uicreatebutton" in line_lower or "uicreatetab" in line_lower or "credits" in line_lower or "developer" in line_lower or "helper" in line_lower or "cat" in line_lower or "fanta" in line_lower or "zosua" in line_lower or "rize" in line_lower or "author" in line_lower:
        start = max(9450, i - 3)
        end = min(len(lines), i + 4)
        output.append(f"--- Line {i+1} ---")
        for idx in range(start, end):
            output.append(f"{idx+1}: {lines[idx].strip()}")
        output.append("\n")

with open("scratch/ui_elements_credits.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(output))
print("Results written to scratch/ui_elements_credits.txt, count:", len(output))
