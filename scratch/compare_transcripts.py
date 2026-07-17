import json
from pathlib import Path

full_path = Path(r"C:\Users\User\.gemini\antigravity-ide\brain\9a07c10f-52e2-418a-acde-f7ed33c58c1d\.system_generated\logs\transcript_full.jsonl")
compact_path = Path(r"C:\Users\User\.gemini\antigravity-ide\brain\9a07c10f-52e2-418a-acde-f7ed33c58c1d\.system_generated\logs\transcript.jsonl")

if full_path.exists():
    with open(full_path, "r", encoding="utf-8") as f:
        for line in f:
            try:
                data = json.loads(line)
                if data.get("type") == "USER_INPUT":
                    content = data.get("content", "")
                    print(f"Full transcript content length: {len(content)}")
                    if "truncated" in content.lower():
                        print("Full transcript contains the word 'truncated'.")
            except Exception as e:
                pass

if compact_path.exists():
    with open(compact_path, "r", encoding="utf-8") as f:
        for line in f:
            try:
                data = json.loads(line)
                if data.get("type") == "USER_INPUT":
                    content = data.get("content", "")
                    print(f"Compact transcript content length: {len(content)}")
            except Exception as e:
                pass
