with open("scratch/full_sp3ar.lua", "r", encoding="utf-8", errors="ignore") as f:
    lines = f.readlines()

start_idx = -1
for i, line in enumerate(lines):
    if 'MiscTab = ' in line or 'UI.CreateTab("Dev Tools")' in line:
        start_idx = i
        break

if start_idx != -1:
    print(f"Found MiscTab at line {start_idx + 1}")
    # Write the next 150 lines to a file to examine
    with open("scratch/misc_tab_setup.lua", "w", encoding="utf-8") as f:
        f.writelines(lines[start_idx:start_idx + 150])
    print("Misc tab setup written to scratch/misc_tab_setup.lua")
else:
    print("MiscTab not found")
