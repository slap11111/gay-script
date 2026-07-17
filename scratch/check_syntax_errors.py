with open("scratch/modified_aimbot.lua", "r", encoding="utf-8", errors="ignore") as f:
    lines = f.readlines()

output = []
for i, line in enumerate(lines, 1):
    if "gay script" in line.lower() or "gayscript" in line.lower():
        # Only print occurrences that look like code variables or dot-accesses (e.g. not in comments or strings)
        # Simple heuristic: if it has "gay script :3 aimbot" outside comments and quotes
        cleaned = line.strip()
        # strip comments
        if "--" in cleaned:
            cleaned = cleaned.split("--")[0].strip()
        # check if "gay script" is outside double/single quotes
        # We can count quotes or look for patterns like globalEnv.Gay or dot-accesses
        if "gay script" in cleaned.lower():
            # If it doesn't look like a string literal (e.g. not surrounded by quotes)
            # or if it has globalEnv.Gay
            if "globalenv" in cleaned.lower() or "=" in cleaned or "." in cleaned:
                # print matches
                output.append(f"{i}: {line.strip()}")

with open("scratch/variable_syntax_errors.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(output))
print("Found potential syntax errors count:", len(output))
for item in output[:10]:
    print("  ", item)
