local Window = UI.CreateWindow("Sp3arParvus")

CreateD3vToolHUD(ScreenGui)
CreatePerformanceDisplay(ScreenGui)
CreateLocalHealthHUD(ScreenGui)
CreateClosestPlayerTracker()

local AimTab = UI.CreateTab("Tracking")
local VisualsTab = UI.CreateTab("Visuals")
local HumanoidTab = UI.CreateTab("Humanoid")
WorldHumState.Page = UI.CreateTab("WorldHumanoids")
local PlayerPage = UI.CreateTab("PlayerPage")
InitializePlayerPage(PlayerPage)
local MiscTab = UI.CreateTab("Dev Tools")
local ShortcutsTab = UI.CreateTab("Shortcuts")
InitializeShortcutsPage(ShortcutsTab)

function ShowWorldHumList(page)
    if not page then return end
    for _, child in ipairs(page:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
    ClearWorldHumConnections()
    WorldHumState.selectedHum = nil
    table.clear(WorldHumState.listEntries)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local layout = page:FindFirstChildOfClass("UIListLayout")
    if not layout then
        layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 5)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = page
    end

    UI.CreateSection(page, "Nearby Humanoids")

    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(1, 0, 0, 30)
    refreshBtn.BackgroundColor3 = UI_THEME.Element
    refreshBtn.Text = "Refresh Scan"
    refreshBtn.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    refreshBtn.TextSize = 13
    refreshBtn.TextColor3 = UI_THEME.Accent
    refreshBtn.Parent = page
    local rC = Instance.new("UICorner"); rC.CornerRadius = UDim.new(0, 6); rC.Parent = refreshBtn
    TrackWorldHumConnection(refreshBtn.MouseButton1Click:Connect(function()
        ShowWorldHumList(page)
    end))

    local humanoids = GetNearbyHumanoids()
    if #humanoids == 0 then
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 30)
        lbl.BackgroundTransparency = 1
        lbl.Text = "No non-local humanoids found."
        lbl.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        lbl.TextSize = 13
        lbl.TextColor3 = UI_THEME.TextDark
        lbl.Parent = page
        return
    end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar.PrimaryPart)
    local myPos = myRoot and myRoot.Position or Camera.CFrame.Position

    local humDataList = {}
    for _, hum in ipairs(humanoids) do
        local model = hum.Parent
        local root = hum.RootPart or (model and model.PrimaryPart)
        local dist = root and (root.Position - myPos).Magnitude or 999999
        table.insert(humDataList, {hum = hum, dist = dist})
    end

    table.sort(humDataList, function(a, b)
        return a.dist < b.dist
    end)

    for _, data in ipairs(humDataList) do
        local hum = data.hum
        local model = hum.Parent
        if not model then continue end

        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 45)
        card.BackgroundColor3 = UI_THEME.Element
        card.BorderSizePixel = 0
        card.LayoutOrder = math.floor(data.dist)
        card.Parent = page
        local cC = Instance.new("UICorner"); cC.CornerRadius = UDim.new(0, 6); cC.Parent = card

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -140, 0, 22)
        nameLabel.Position = UDim2.new(0, 12, 0, 4)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = model.Name
        nameLabel.FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        nameLabel.TextSize = 14
        nameLabel.TextColor3 = UI_THEME.Text
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card

        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Size = UDim2.new(1, -140, 0, 16)
        distanceLabel.Position = UDim2.new(0, 12, 0, 22)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.Text = math.floor(data.dist) .. " studs away"
        distanceLabel.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        distanceLabel.TextSize = 12
        distanceLabel.TextColor3 = UI_THEME.TextDark
        distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
        distanceLabel.Parent = card

        table.insert(WorldHumState.listEntries, {hum = hum, card = card, label = distanceLabel})

        local selectionBtn = Instance.new("TextButton")
        selectionBtn.Size = UDim2.new(1, 0, 1, 0)
        selectionBtn.BackgroundTransparency = 1
        selectionBtn.Text = ""
        selectionBtn.ZIndex = 1
        selectionBtn.Parent = card

        local editBtn = Instance.new("TextButton")
        editBtn.Name = "Edit"
        editBtn.Size = UDim2.new(0, 60, 0, 26)
        editBtn.Position = UDim2.new(1, -10, 0.5, 0)
        editBtn.AnchorPoint = Vector2.new(1, 0.5)
        editBtn.BackgroundColor3 = UI_THEME.Accent
        editBtn.Text = "Edit"
        editBtn.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        editBtn.TextSize = 12
        editBtn.TextColor3 = Color3.new(1, 1, 1)
        editBtn.Visible = false
        editBtn.ZIndex = 2
        editBtn.Parent = card
        local eC = Instance.new("UICorner"); eC.CornerRadius = UDim.new(0, 4); eC.Parent = editBtn

        local tpBtn = Instance.new("TextButton")
        tpBtn.Name = "TP"
        tpBtn.Size = UDim2.new(0, 50, 0, 26)
        tpBtn.Position = UDim2.new(1, -75, 0.5, 0)
        tpBtn.AnchorPoint = Vector2.new(1, 0.5)
        tpBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        tpBtn.Text = "TP"
        tpBtn.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        tpBtn.TextSize = 12
        tpBtn.TextColor3 = Color3.new(1, 1, 1)
        tpBtn.Visible = false
        tpBtn.ZIndex = 2
        tpBtn.Parent = card
        local tpC = Instance.new("UICorner"); tpC.CornerRadius = UDim.new(0, 4); tpC.Parent = tpBtn

        TrackWorldHumConnection(selectionBtn.MouseButton1Click:Connect(function()

            if WorldHumState.selectionHighlight then
                pcall(function() WorldHumState.selectionHighlight:Destroy() end)
                WorldHumState.selectionHighlight = nil
            end

            for _, child in ipairs(page:GetChildren()) do
                local eb = child:FindFirstChild("Edit")
                local tb = child:FindFirstChild("TP")
                if eb then eb.Visible = false end
                if tb then tb.Visible = false end
            end

            WorldHumState.selectedHum = hum
            editBtn.Visible = true
            tpBtn.Visible = true

            local hl = Instance.new("Highlight")
            hl.Enabled = not Flags["Settings/GhostMode"]
            hl.Name = "WorldHumSelectionHighlight"
            hl.Adornee = model
            hl.FillTransparency = 1
            hl.OutlineColor = Color3.new(255, 255, 255)
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = model
            WorldHumState.selectionHighlight = hl
        end))

        TrackWorldHumConnection(editBtn.MouseButton1Click:Connect(function()
            if WorldHumState.selectionHighlight then
                WorldHumState.selectionHighlight:Destroy()
                WorldHumState.selectionHighlight = nil
            end
            ShowWorldHumEditor(page, hum)
        end))

        TrackWorldHumConnection(tpBtn.MouseButton1Click:Connect(function()
            if SAFE_MODE then
                UI.Notify("Safe Mode", "Teleporting is disabled while Safe Mode is ON.")
                return
            end
            local myChar = LocalPlayer.Character
            local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar.PrimaryPart)
            local targetPart = hum.RootPart or (model and model.PrimaryPart) or (model and model:FindFirstChildOfClass("BasePart"))
            if myRoot and targetPart then
                myRoot.CFrame = targetPart.CFrame * CFrame.new(0, 3, 0)
                UI.Notify("Teleport", "Teleported to " .. model.Name)
            else
                UI.Notify("Teleport Error", "Target humanoid location could not be determined.")
            end
        end))
    end
end

for _, t in pairs(UIState.Tabs) do
    if t.Label.Text == "WorldHumanoids" then
        TrackConnection(t.Button.MouseButton1Click:Connect(function()
            ShowWorldHumList(WorldHumState.Page)
        end))
        break
    end
end

function CreateWorldHumToggle(page, text, targetHum, prop)
    local path = GetUniquePath(targetHum)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 36)
    Frame.BackgroundColor3 = UI_THEME.Element
    Frame.BorderSizePixel = 0
    Frame.Parent = page
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 6); corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, -30, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Label.TextSize = 13
    Label.TextColor3 = UI_THEME.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local initialLocked = (WorldHumState.lockedProperties[path] and WorldHumState.lockedProperties[path][prop] ~= nil)
    local LockBtn = Instance.new("TextButton")
    LockBtn.Size = UDim2.new(0, 24, 0, 24)
    LockBtn.AnchorPoint = Vector2.new(1, 0.5)
    LockBtn.Position = UDim2.new(1, -64, 0.5, 0)
    LockBtn.BackgroundTransparency = 1
    LockBtn.Text = initialLocked and "🔒" or "🔓"
    LockBtn.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    LockBtn.TextSize = 14
    LockBtn.TextColor3 = initialLocked and UI_THEME.Accent or UI_THEME.TextDark
    LockBtn.Parent = Frame

    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.new(0, 44, 0, 22)
    Switch.AnchorPoint = Vector2.new(1, 0.5)
    Switch.Position = UDim2.new(1, -12, 0.5, 0)
    Switch.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Switch.Parent = Frame
    local swCorner = Instance.new("UICorner"); swCorner.CornerRadius = UDim.new(1, 0); swCorner.Parent = Switch

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 18, 0, 18)
    Knob.AnchorPoint = Vector2.new(0, 0.5)
    Knob.Position = UDim2.new(0, 2, 0.5, 0)
    Knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Knob.Parent = Switch
    local kbCorner = Instance.new("UICorner"); kbCorner.CornerRadius = UDim.new(1, 0); kbCorner.Parent = Knob

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    Button.Parent = Switch

    local function updateVisuals(state)
        TweenService:Create(Switch, TWEENS.MEDIUM, {BackgroundColor3 = state and UI_THEME.Accent or Color3.fromRGB(50, 50, 50)}):Play()
        TweenService:Create(Knob, TWEENS.SMOOTH, {Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}):Play()
    end

    WorldHumState.updaters[prop] = updateVisuals

    TrackWorldHumConnection(LockBtn.MouseButton1Click:Connect(function()
        local isLocked = not (WorldHumState.lockedProperties[path] and WorldHumState.lockedProperties[path][prop] ~= nil)
        if isLocked then
            if not WorldHumState.lockedProperties[path] then WorldHumState.lockedProperties[path] = {} end
            WorldHumState.lockedProperties[path][prop] = targetHum[prop]
        else
            WorldHumState.lockedProperties[path][prop] = nil
        end
        LockBtn.Text = isLocked and "🔒" or "🔓"
        LockBtn.TextColor3 = isLocked and UI_THEME.Accent or UI_THEME.TextDark
    end))

    TrackWorldHumConnection(Button.MouseButton1Click:Connect(function()
        local newState = not targetHum[prop]
        pcall(SafeSetProp, targetHum, prop, newState)
        if WorldHumState.lockedProperties[path] and WorldHumState.lockedProperties[path][prop] ~= nil then
            WorldHumState.lockedProperties[path][prop] = newState
        end
        updateVisuals(newState)
    end))

    updateVisuals(targetHum[prop])
end

function CreateWorldHumNumeric(page, text, targetHum, prop, min, max, step)
    local path = GetUniquePath(targetHum)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 48)
    Frame.BackgroundColor3 = UI_THEME.Element
    Frame.BorderSizePixel = 0
    Frame.Parent = page
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 6); corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, -42, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Label.TextSize = 13
    Label.TextColor3 = UI_THEME.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local initialLocked = (WorldHumState.lockedProperties[path] and WorldHumState.lockedProperties[path][prop] ~= nil)
    local LockBtn = Instance.new("TextButton")
    LockBtn.Size = UDim2.new(0, 24, 0, 24)
    LockBtn.AnchorPoint = Vector2.new(1, 0.5)
    LockBtn.Position = UDim2.new(0.6, -12, 0.5, 0)
    LockBtn.BackgroundTransparency = 1
    LockBtn.Text = initialLocked and "🔒" or "🔓"
    LockBtn.FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    LockBtn.TextSize = 14
    LockBtn.TextColor3 = initialLocked and UI_THEME.Accent or UI_THEME.TextDark
    LockBtn.Parent = Frame

    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(0.4, -12, 0, 30)
    InputFrame.Position = UDim2.new(1, -12, 0.5, 0)
    InputFrame.AnchorPoint = Vector2.new(1, 0.5)
    InputFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    InputFrame.Parent = Frame
    local ifCorner = Instance.new("UICorner"); ifCorner.CornerRadius = UDim.new(0, 4); ifCorner.Parent = InputFrame

    local Input = Instance.new("TextBox")
    Input.Size = UDim2.new(1, -50, 1, 0)
    Input.Position = UDim2.new(0, 25, 0, 0)
    Input.BackgroundTransparency = 1
