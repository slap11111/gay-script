import re

with open("ScriptHubNA.lua", "r", encoding="utf-8", errors="ignore") as f:
    content = f.read()

urls = re.findall(r'https?://[^\s"\']+', content)
for url in urls:
    print("URL in ScriptHub:", url)
