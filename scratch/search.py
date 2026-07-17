import re

filepath = r"C:\Users\User\.gemini\antigravity-ide\brain\2a1779ec-8e0e-4440-9d95-0dfc6d6db684\.system_generated\steps\43\content.md"

with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if '"ESP"' in line or 'esp' in line.lower() or 'drawing' in line.lower() or 'highlight' in line.lower() or 'box' in line.lower():
        print(f"{i+1}: {line.strip()}")
