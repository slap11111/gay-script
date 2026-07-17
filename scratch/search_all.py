import os

for root, dirs, files in os.walk("."):
    for file in files:
        if file.endswith((".lua", ".luau", ".json", ".txt")) or file in ["dupe tools", "namelesss", "comet", "Source"]:
            path = os.path.join(root, file)
            try:
                with open(path, "r", encoding="utf-8", errors="ignore") as f:
                    for line_num, line in enumerate(f, 1):
                        if "aimbot" in line.lower() or "owl" in line.lower():
                            print(f"{path} line {line_num}: {line.strip()}")
            except Exception as e:
                pass
