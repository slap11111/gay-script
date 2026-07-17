import re

# Emojis to look for
emoji_chars = [
    ("\U0001f4cb", "clipboard"),
    ("\u2756", "accent bullet"),
    ("\U0001f513", "unlocked lock"),
    ("\u2705", "checkmark"),
    ("\u27f3", "reload"),
    ("\U0001f392", "backpack"),
    ("\U0001f465", "players"),
    ("\u274c", "cross"),
    ("\u2b50", "star"),
    ("\u2699", "settings"),
    ("\U0001f512", "locked lock"),
    ("\U0001f5b1", "mouse"),
    ("\u2328", "keyboard"),
    ("\u262e", "peace"),
    ("\U0001f464", "player profile"),
    ("\u2620", "skull/blacklist"),
    ("\u26a0", "warning")
]

with open("scratch/full_sp3ar.lua", "r", encoding="utf-8", errors="ignore") as f:
    lines = f.readlines()

output = []
for i, line in enumerate(lines, 1):
    found = []
    for ec, name in emoji_chars:
        if ec in line:
            found.append(f"{name} ({ec.encode('ascii', errors='backslashreplace').decode('ascii')})")
    if found:
        escaped_line = line.strip().encode('ascii', errors='backslashreplace').decode('ascii')
        output.append(f"Line {i} matches: {', '.join(found)}\n  Code: {escaped_line}")

with open("scratch/emoji_lines.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(output))
print("Emoji search complete, matches found:", len(output))
