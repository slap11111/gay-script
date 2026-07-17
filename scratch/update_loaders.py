# Modify the files in the actual GitHub repo directory
target_files = [
    r"C:\Users\User\Documents\GitHub\gay-script\Source.lua",
    r"C:\Users\User\Documents\GitHub\gay-script\NA testing.lua"
]

target_str = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/CriShoux/OwlHub/master/OwlHub.txt"))();'
replacement_str = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/slap11111/gay-script/refs/heads/main/NewAimbot.lua"))();'

for filepath in target_files:
    try:
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
        
        if target_str in content:
            content = content.replace(target_str, replacement_str)
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(content)
            print(f"Successfully updated loadstring in {filepath}")
        else:
            print(f"Target loadstring not found in {filepath} (or already updated)")
    except Exception as e:
        print(f"Error modifying {filepath}: {e}")
