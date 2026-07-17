with open("scratch/modified_aimbot.lua", "r", encoding="utf-8", errors="ignore") as f:
    code = f.read()

# Check for remaining emojis
remaining = []
for char in code:
    o = ord(char)
    if o > 0x2000 and not (0x2500 <= o <= 0x257f) and char not in ["↓", "−", "—", "▼", "▲", "←", "→", "≤", "•", "▶", "✓"]:
        remaining.append(char)

if remaining:
    rem_str = "".join(set(remaining))
    escaped_rem = rem_str.encode('ascii', errors='backslashreplace').decode('ascii')
    print("Warning, remaining special chars:", escaped_rem)
else:
    print("All target emojis removed successfully!")

# Verify window name and credit labels are present
if 'UI.CreateWindow("Gay Script :3 Aimbot")' in code or 'UI.CreateWindow("gay script :3 aimbot")' in code:
    print("Window name updated successfully!")
else:
    print("Warning: Window name not updated!")

if 'local CreditsTab = UI.CreateTab("Credits")' in code:
    print("Credits Tab present in modified code!")
else:
    print("Warning: Credits Tab missing!")
