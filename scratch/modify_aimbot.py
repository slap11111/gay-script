import re

with open("scratch/full_sp3ar.lua", "r", encoding="utf-8", errors="ignore") as f:
    code = f.read()

# 1. Direct emoji character mapping to safe ASCII alternatives
emoji_map = {
    "☮️": "[W]",
    "☮": "[W]",
    "☠️": "[B]",
    "☠": "[B]",
    "⭐": "[*]",
    "🔒": "[Locked]",
    "🔓": "[Unlocked]",
    "❌": "[X]",
    "✅": "[OK]",
    "⚙️": "[S]",
    "⚙": "[S]",
    "📋": "[C]",
    "⚠️": "[!]",
    "⌛": "[T]",
    "🎒": "[Item]",
    "👤": "[P]",
    "👥": "[T]",
    "⌨️": "[Key]",
    "⌨": "[Key]",
    "🖱️": "[Mouse]",
    "🖱": "[Mouse]",
    "⟳": "[R]",
    "❖": "*",
    "–": "-", # replace en dash with hyphen
}

for emoji, replacement in emoji_map.items():
    code = code.replace(emoji, replacement)

# 2. Rename Sp3arParvus to Gay Script :3 Aimbot (maintaining appropriate casing)
code = re.sub(r'Sp3arParvus', 'Gay Script :3 Aimbot', code)
code = re.sub(r'sp3arparvus', 'gay script :3 aimbot', code)
code = re.sub(r'SP3ARPARVUS', 'GAY SCRIPT :3 AIMBOT', code)

# Fix script names and identifiers in code
code = code.replace('Sp3arNotifications', 'GayScriptNotifications')
code = code.replace('Sp3arParvusUI', 'GayScriptUI')
code = code.replace('Sp3arParvusSplash', 'GayScriptSplash')
code = code.replace('Sp3arParvusShortcuts', 'GayScriptShortcuts')
code = code.replace('Sp3arParvus_Icon.png', 'GayScriptAimbot_Icon.png')
code = code.replace('Sp3arParvus.lua', 'GayScriptAimbot.lua')

# Update header comment
header_old = """-- ╔══════════════════════════════════════════════════════════════════╗
-- ║            Gay Script :3 Aimbot — Developer Tool                          ║
-- ╠══════════════════════════════════════════════════════════════════╣
-- ║  Version: 4.2.5                                                  ║
-- ╚══════════════════════════════════════════════════════════════════╝"""

header_new = """-- ╔══════════════════════════════════════════════════════════════════╗
-- ║            Gay Script :3 Aimbot                                  ║
-- ╠══════════════════════════════════════════════════════════════════╣
-- ║  Developer: cat                                                  ║
-- ║  Helpers: fanta, zosua                                           ║
-- ║  Version: 4.2.5                                                  ║
-- ╚══════════════════════════════════════════════════════════════════╝"""

code = code.replace(header_old, header_new)

# Inject Credits Tab
credits_tab_code = """
local CreditsTab = UI.CreateTab("Credits")
UI.CreateSection(CreditsTab, "Credits")
UI.CreateButton(CreditsTab, "Developer: cat", function() end)
UI.CreateButton(CreditsTab, "Helper: fanta", function() end)
UI.CreateButton(CreditsTab, "Helper: zosua", function() end)
"""

# Insert CreditsTab after ShortcutsTab initialization:
target_insertion = """local ShortcutsTab = UI.CreateTab("Shortcuts")
InitializeShortcutsPage(ShortcutsTab)"""

if target_insertion in code:
    code = code.replace(target_insertion, target_insertion + credits_tab_code)
    print("Credits Tab successfully injected!")
else:
    print("Warning: ShortcutsTab target insertion not found.")

with open("scratch/modified_aimbot.lua", "w", encoding="utf-8") as f:
    f.write(code)

print("Modification complete. File saved to scratch/modified_aimbot.lua")
