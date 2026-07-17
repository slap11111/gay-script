import os

def patch_file(filepath):
    print(f"Patching {filepath}...")
    if not os.path.exists(filepath):
        print(f"File {filepath} not found!")
        return False
        
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Inject GetPreciseViewportBounds definition above ESP_UpdateDrawingBox
    precise_bounds_fn = """NAmanage.GetPreciseViewportBounds = function(inst, camera)
	camera = camera or (Workspace and Workspace.CurrentCamera)
	if not camera then return nil end
	
	local RootPart = inst:FindFirstChild("HumanoidRootPart")
	if not RootPart then return nil end
	
	local Distance = (camera.CFrame.Position - RootPart.Position).Magnitude
	if Distance <= 0 then return nil end
	
	local ViewportHeight = camera.ViewportSize.Y
	local FOV_Rad = math.rad(camera.FieldOfView)
	local PPS = ViewportHeight / (2 * Distance * math.tan(FOV_Rad / 2))
	
	local minX, minY, maxX, maxY
	local staticDistance = 300
	local staticSize = Vector2.new(4, 6)
	local paddingInStuds = 1.5
	local minBoxSize = 2
	
	if Distance > staticDistance then
		local RootScreen, OnScreen = camera:WorldToViewportPoint(RootPart.Position)
		if OnScreen then
			local BoxW_Pixel = staticSize.X * PPS
			local BoxH_Pixel = staticSize.Y * PPS
			
			minX = RootScreen.X - (BoxW_Pixel / 2)
			maxX = RootScreen.X + (BoxW_Pixel / 2)
			minY = RootScreen.Y - (BoxH_Pixel / 2)
			maxY = RootScreen.Y + (BoxH_Pixel / 2)
		else
			return nil
		end
	else
		minX, minY = 99999, 99999
		maxX, maxY = -99999, -99999
		local AnyPartOnScreen = false
		for _, part in ipairs(inst:GetChildren()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "Handle" then
				local ScreenPos, OnScreen = camera:WorldToViewportPoint(part.Position)
				if OnScreen then
					AnyPartOnScreen = true
					if ScreenPos.X < minX then minX = ScreenPos.X end
					if ScreenPos.X > maxX then maxX = ScreenPos.X end
					if ScreenPos.Y < minY then minY = ScreenPos.Y end
					if ScreenPos.Y > maxY then maxY = ScreenPos.Y end
				end
			end
		end
		if not AnyPartOnScreen then return nil end
		
		local Padding = PPS * paddingInStuds
		minX = minX - Padding
		maxX = maxX + Padding
		minY = minY - Padding
		maxY = maxY + Padding
	end
	
	local Left = math.floor(minX)
	local Top = math.floor(minY)
	local Right = math.floor(maxX)
	local Bottom = math.floor(maxY)
	
	local W = Right - Left
	local H = Bottom - Top
	
	W = math.max(W, minBoxSize)
	H = math.max(H, minBoxSize)
	
	return Left, Top, W, H
end

NAmanage.ESP_UpdateDrawingBox = function(data, inst, color, fillTransparency)"""

    target_update_box = "NAmanage.ESP_UpdateDrawingBox = function(data, inst, color, fillTransparency)"
    
    if precise_bounds_fn not in content and target_update_box in content:
        content = content.replace(target_update_box, precise_bounds_fn, 1)
        print("-> Injected GetPreciseViewportBounds")
    else:
        print("-> GetPreciseViewportBounds already injected or target not found")

    # 2. Modify ESP_UpdateDrawingBox to use our new GetPreciseViewportBounds
    target_bounds = """\tlocal minX, minY, width, height = NAgui.getInstanceViewportBounds(inst)"""
    replacement_bounds = """\tlocal minX, minY, width, height = NAmanage.GetPreciseViewportBounds(inst)"""

    if target_bounds in content:
        content = content.replace(target_bounds, replacement_bounds, 1)
        print("-> Updated bounds calculation inside ESP_UpdateDrawingBox")
    else:
        target_bounds_rn = target_bounds.replace('\n', '\r\n')
        replacement_bounds_rn = replacement_bounds.replace('\n', '\r\n')
        if target_bounds_rn in content:
            content = content.replace(target_bounds_rn, replacement_bounds_rn, 1)
            print("-> Updated bounds calculation inside ESP_UpdateDrawingBox (CRLF)")
        else:
            print("-> Bounds calculation target not found")

    # 3. Update ESP_UpdateOne to set budget = 0 when drawing is enabled for super fast updates
    target_budget = """\tif drawingPlayers then
\t\tbudget = dist and ((dist <= 50 and 0.03) or (dist <= 150 and 0.06) or (dist <= 400 and 0.12) or 0.25) or 0.06"""
    replacement_budget = """\tif drawingPlayers then
\t\tbudget = 0"""

    if target_budget in content:
        content = content.replace(target_budget, replacement_budget, 1)
        print("-> Disabled update throttling budget for drawing players")
    else:
        target_budget_rn = target_budget.replace('\n', '\r\n')
        replacement_budget_rn = replacement_budget.replace('\n', '\r\n')
        if target_budget_rn in content:
            content = content.replace(target_budget_rn, replacement_budget_rn, 1)
            print("-> Disabled update throttling budget for drawing players (CRLF)")
        else:
            print("-> Budget target not found")

    # 4. Modify ESP_StartGlobal to switch dynamically between RenderStepped and Heartbeat
    target_start_global = """NAmanage.ESP_StartGlobal = function()
	if NAlib.isConnected("esp_update_global") then return end
	NAlib.connect("esp_update_global", RunService.Heartbeat:Connect(function()"""

    replacement_start_global = """NAmanage.ESP_StartGlobal = function()
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

    if target_start_global in content:
        content = content.replace(target_start_global, replacement_start_global, 1)
        print("-> Updated ESP_StartGlobal to use RenderStepped dynamically")
    else:
        target_start_global_rn = target_start_global.replace('\n', '\r\n')
        replacement_start_global_rn = replacement_start_global.replace('\n', '\r\n')
        if target_start_global_rn in content:
            content = content.replace(target_start_global_rn, replacement_start_global_rn, 1)
            print("-> Updated ESP_StartGlobal to use RenderStepped dynamically (CRLF)")
        else:
            print("-> ESP_StartGlobal target not found")

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Done patching.")
    return True

patch_file('Source.lua')
patch_file('NA testing.lua')
