with open("scratch/modified_aimbot.lua", "r", encoding="utf-8", errors="ignore") as f:
    code = f.read()

import re
matches = re.findall(r'(?i)sp3arparvus', code)
print("Sp3arParvus remnants in modified_aimbot.lua:", len(matches))
for m in set(matches):
    print("  Remnant match:", m)
