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

