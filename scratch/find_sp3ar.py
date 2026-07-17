import os
from pathlib import Path

search_dirs = [
    Path.home() / "Downloads",
    Path.home() / "Documents",
    Path.home() / "Desktop",
    Path.home() / "Saved Games"
]

found_files = []
for sdir in search_dirs:
    if not sdir.exists():
        continue
    print(f"Scanning {sdir}...")
    for root, dirs, files in os.walk(sdir):
        # Skip deep/useless directories to keep it fast
        for d in list(dirs):
            if d.startswith('.') or d in ['node_modules', 'venv', 'AppData', '.git']:
                dirs.remove(d)
        for file in files:
            if file.endswith((".lua", ".luau", ".txt", ".json")) or "sp3ar" in file.lower() or "parvus" in file.lower():
                path = Path(root) / file
                try:
                    # check size to avoid reading massive binary files
                    if path.stat().st_size < 5 * 1024 * 1024:
                        content = path.read_text(encoding='utf-8', errors='ignore')
                        if "Sp3arParvus" in content:
                            found_files.append(str(path))
                except Exception as e:
                    pass

print("Found Sp3arParvus files at:", found_files)
