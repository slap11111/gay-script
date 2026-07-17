with open("scratch/full_sp3ar.lua", "r", encoding="utf-8", errors="ignore") as f:
    lines = f.readlines()

start_idx = -1
for i, line in enumerate(lines):
    if 'UI.CreateWindow("Sp3arParvus")' in line:
        start_idx = i
        break

if start_idx != -1:
    print(f"Found CreateWindow at line {start_idx + 1}")
    # Write the next 300 lines to a file to examine
    with open("scratch/ui_setup.lua", "w", encoding="utf-8") as f:
        f.writelines(lines[start_idx:start_idx + 350])
    print("UI setup written to scratch/ui_setup.lua")
else:
    print("CreateWindow not found")
