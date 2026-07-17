with open("scratch/modified_aimbot.lua", "r", encoding="utf-8", errors="ignore") as f:
    code = f.read()

# Let's search for "globalEnv.gay" or similar patterns in the code
import re
matches = re.findall(r'(?i)globalenv\s*\.\s*[a-z0-9_ :]+', code)
print("globalEnv property access matches:", matches)

matches_raw = re.findall(r'(?i)gay\s+script', code)
print("Total 'gay script' occurrences:", len(matches_raw))
