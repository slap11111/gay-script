import os

def patch_file(filepath):
    print(f"Patching {filepath}...")
    if not os.path.exists(filepath):
        print(f"File {filepath} not found!")
        return False
        
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Revert RenderStepped to Heartbeat
    target_start_global = """NAmanage.ESP_StartGlobal = function()
	local desiredEvent = (NAgui.espUsesDrawing("players") or NAgui.espUsesDrawing("npcs")) and RunService.RenderStepped or RunService.Heartbeat
	local currentEventName = NAStuff.ESP_CurrentEventName
	if NAlib.isConnected("esp_update_global") then
		if currentEventName == desiredEvent then
			return
		else
			NAlib.disconnect("esp_update_global")
		end
	end
	NAStuff.ESP_CurrentEventName = desiredEvent
	NAlib.connect("esp_update_global", desiredEvent:Connect(function()"""

    replacement_start_global = """NAmanage.ESP_StartGlobal = function()
	if NAlib.isConnected("esp_update_global") then return end
	NAlib.connect("esp_update_global", RunService.Heartbeat:Connect(function()"""

    if target_start_global in content:
        content = content.replace(target_start_global, replacement_start_global, 1)
        print("-> Reverted ESP_StartGlobal to use Heartbeat")
    else:
        target_start_global_rn = target_start_global.replace('\n', '\r\n')
        replacement_start_global_rn = replacement_start_global.replace('\n', '\r\n')
        if target_start_global_rn in content:
            content = content.replace(target_start_global_rn, replacement_start_global_rn, 1)
            print("-> Reverted ESP_StartGlobal to use Heartbeat (CRLF)")
        else:
            print("-> ESP_StartGlobal target not found")

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Done patching.")
    return True

patch_file('Source.lua')
patch_file('NA testing.lua')
