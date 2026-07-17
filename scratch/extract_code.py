import json
from pathlib import Path

# Path to the full transcript
transcript_path = Path(r"C:\Users\User\.gemini\antigravity-ide\brain\9a07c10f-52e2-418a-acde-f7ed33c58c1d\.system_generated\logs\transcript_full.jsonl")

if not transcript_path.exists():
    print("Transcript not found at", transcript_path)
else:
    # Read the lines and find the last USER_INPUT step
    user_input = None
    with open(transcript_path, "r", encoding="utf-8") as f:
        for line in f:
            try:
                data = json.loads(line)
                if data.get("type") == "USER_INPUT":
                    user_input = data
            except Exception as e:
                pass
    
    if user_input:
        content = user_input.get("content", "")
        # Find the start of the code (it starts after the user prompt description)
        code_start = content.find("-- ╔══════════════════════════════════════════════════════════════════╗")
        if code_start != -1:
            code = content[code_start:]
            output_path = Path("scratch/pasted_code.lua")
            output_path.write_text(code, encoding="utf-8")
            print(f"Successfully extracted code ({len(code)} characters) to scratch/pasted_code.lua")
        else:
            print("Could not find the start of the lua code in user input.")
    else:
        print("No user input found in transcript.")
