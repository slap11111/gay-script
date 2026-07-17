import re

with open("scratch/full_sp3ar.lua", "r", encoding="utf-8", errors="ignore") as f:
    code = f.read()

# 1. Strip emojis and special characters using direct character replacements
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

# 2. Replace Sp3arParvus in string literals, prints, and notifications with the spaced name
def replace_in_strings(match):
    double_quote = match.group(1)
    double_content = match.group(2)
    single_quote = match.group(3)
    single_content = match.group(4)
    
    if double_quote is not None:
        new_content = re.sub(r'(?i)Sp3arParvus', 'gay script :3 aimbot', double_content)
        return f'{double_quote}{new_content}{double_quote}'
    elif single_quote is not None:
        new_content = re.sub(r'(?i)Sp3arParvus', 'gay script :3 aimbot', single_content)
        return f'{single_quote}{new_content}{single_quote}'
    return match.group(0)

# Match both double quoted and single quoted string literals
code = re.sub(r'(")([^"\\]*(?:\\.[^"\\]*)*)"|(\')([^\'\\]*(?:\\.[^\'\\]*)*)\'', replace_in_strings, code)

# 3. Also replace in comments (which might be headers, etc.)
def replace_in_comments(match):
    comment = match.group(0)
    new_comment = re.sub(r'(?i)Sp3arParvus', 'gay script :3 aimbot', comment)
    return new_comment

code = re.sub(r'--.*', replace_in_comments, code)

# 4. Now replace all remaining Sp3arParvus code identifiers with valid Lua variable name 'GayScript3Aimbot'
code = re.sub(r'Sp3arParvus', 'GayScript3Aimbot', code)
code = re.sub(r'sp3arparvus', 'gayscript3aimbot', code)
code = re.sub(r'SP3ARPARVUS', 'GAYSCRIPT3AIMBOT', code)

# Fix script names and identifiers in code
code = code.replace('Sp3arNotifications', 'GayScriptNotifications')
code = code.replace('Sp3arParvusUI', 'GayScriptUI')
code = code.replace('Sp3arParvusSplash', 'GayScriptSplash')
code = code.replace('Sp3arParvusShortcuts', 'GayScriptShortcuts')
code = code.replace('Sp3arParvus_Icon.png', 'GayScriptAimbot_Icon.png')
code = code.replace('Sp3arParvus.lua', 'GayScriptAimbot.lua')

# Update header comment
header_old = """-- ╔══════════════════════════════════════════════════════════════════╗
-- ║            gay script :3 aimbot — Developer Tool                          ║
-- ╠══════════════════════════════════════════════════════════════════╣
-- ║  Version: 4.2.5                                                  ║
-- ╚══════════════════════════════════════════════════════════════════╝"""

header_new = """-- ╔══════════════════════════════════════════════════════════════════╗
-- ║            gay script :3 aimbot                                  ║
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
