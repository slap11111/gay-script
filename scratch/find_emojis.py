import sys

# Set console to utf-8 if possible
try:
    sys.stdout.reconfigure(encoding='utf-8')
except:
    pass

with open("scratch/full_sp3ar.lua", "r", encoding="utf-8", errors="ignore") as f:
    code = f.read()

# Print all non-ascii characters that are emoji-like or special characters
emojis = set()
for char in code:
    o = ord(char)
    # Emojis and other symbols are typically high unicode characters
    if o > 0x2000 and not (0x2500 <= o <= 0x257f): # exclude box drawing chars
        emojis.add(char)

# Print escaped representation
emoji_str = "".join(emojis)
print("Found special characters/emojis:", emoji_str.encode('ascii', errors='backslashreplace').decode('ascii'))
