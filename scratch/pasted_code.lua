-- ╔══════════════════════════════════════════════════════════════════╗
-- ║            Sp3arParvus — Developer Tool                          ║
-- ╠══════════════════════════════════════════════════════════════════╣
-- ║  Version: 4.2.5                                                  ║
-- ╚══════════════════════════════════════════════════════════════════╝

local VERSION = "4.2.5" -- Shortcuts Page Update, Performance Update, and Closest-Player-Panel Settings Update
local SAFE_MODE = false  -- ←SafeMode Flag, Change 'false' to 'true' before executing to enable SafeMode

print(string.format("[Sp3arParvus v%s] Loading...", VERSION))
MAX_INIT_WAIT = 30
initStartTime = tick()
print("[Sp3arParvus] Waiting for game to load...")
repeat task.wait() until game:IsLoaded()
print("[Sp3arParvus] Game loaded!")
print("[Sp3arParvus] Waiting for LocalPlayer...")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    repeat
        task.wait(0.1)
        LocalPlayer = Players.LocalPlayer
    until LocalPlayer or (tick() - initStartTime > MAX_INIT_WAIT)
end
if not LocalPlayer then
    return warn("[Sp3arParvus] Failed to get LocalPlayer after " .. MAX_INIT_WAIT .. " seconds. Aborting.")
end
print("[Sp3arParvus] LocalPlayer ready: " .. LocalPlayer.Name)

print("[Sp3arParvus] Checking for Character (non-blocking)...")
local character = LocalPlayer.Character
if character then

    local charWaitStart = tick()
    repeat
        task.wait(0.1)
        character = LocalPlayer.Character
    until (character and character.Parent) or (tick() - charWaitStart > 3)
    if character and character.Parent then
        print("[Sp3arParvus] Character ready!")
    else
        warn("[Sp3arParvus] Character exists but not yet parented, continuing anyway...")
    end
else

    print("[Sp3arParvus] No character at load time — continuing without one. Humanoid will be detected when spawned.")
end

print("[Sp3arParvus] Waiting for Camera...")
local Workspace = game:GetService("Workspace")
repeat
    task.wait(0.1)
until Workspace.CurrentCamera or (tick() - initStartTime > MAX_INIT_WAIT)
if not Workspace.CurrentCamera then
    warn("[Sp3arParvus] Camera not found, continuing anyway...")
end
print("[Sp3arParvus] Camera ready!")

print("[Sp3arParvus] Waiting for PlayerScripts to initialize...")
local playerScripts = LocalPlayer:FindFirstChildOfClass("PlayerScripts")
if not playerScripts then
    repeat
        task.wait(0.1)
        playerScripts = LocalPlayer:FindFirstChildOfClass("PlayerScripts")
    until playerScripts or (tick() - initStartTime > MAX_INIT_WAIT)
end
if playerScripts then
    task.wait(0.5)
end
print("[Sp3arParvus] PlayerScripts ready!")

task.wait(0.2)
print(string.format("[Sp3arParvus] Initialization complete! (%.2fs)", tick() - initStartTime))

local CharCache = {}
local AimState = {
    Aim = false,
    LastAimTarget = nil,
    LastMouseMode = nil,
    LastOriginX = nil,
    LastOriginY = nil,
    AcquiringFrames = 0
}
local Flags = {
    ["Aim/AimLock"] = true,
    ["Aim/AlwaysEnabled"] = true,
    ["Aim/ShowAssistDots"] = false,
    ["Aim/TeamCheck"] = false,
    ["Aim/VisibilityCheck"] = true,
    ["Aim/AttractionStrength"] = 200,
    ["Aim/FOV/Radius"] = 50,
    ["Aim/FOV/ShowCircle"] = true,
    ["Aim/Dampening"] = true,
    ["Aim/Dampening/Threshold"] = 5,
    ["Aim/Dampening/Strength"] = 5,
    ["Aim/Priority"] = "Head",
    ["Aim/TargetBlacklistedThroughTerrain"] = true,
    ["Aim/BypassBlacklistPriorityIfOccludedOrFar"] = false,
    ["Aim/BlacklistBypassDistance"] = 200,
    ["Aim/BodyParts"] = {"Head"},
    ["Aim/TargetGroups"] = {
        Head = true,
        Torso = false,
        LeftArm = false,
        RightArm = false,
        LeftLeg = false,
        RightLeg = false
    },
    ["ShootBot/Enabled"] = false,
    ["ShootBot/CPS"] = 8,
    ["ShootBot/TeamCheck"] = false,
    ["ShootBot/TargetParts"] = {
        Head = false,
        Torso = false,
        LeftArm = false,
        RightArm = false,
        LeftLeg = false,
        RightLeg = false
    },
    ["ESP/Enabled"] = true,
    ["ESP/MaxDistance"] = 10000,
    ["ESP/TeamCheck"] = false,
    ["ESP/ShowStatus"] = true,
    ["ESP/ShowNickname"] = true,
    ["ESP/ShowUsername"] = true,
    ["ESP/ShowDistance"] = true,
    ["ESP/HealthIndicator"] = true,
    ["ESP/ShowEquipped"] = true,
    ["ESP/AdvancedPlayerPanel"] = false,
    ["ESP/PlayerOutlines"] = true,
    ["Visuals/Fullbright"] = false,
    ["Visuals/FullDark"] = false,
    -- Fullbright modifiers
    ["Visuals/Fullbright/ClockTime"]        = 12,
    ["Visuals/Fullbright/Brightness"]       = 2,
    ["Visuals/Fullbright/FogEnd"]           = 100000,
    ["Visuals/Fullbright/FogStart"]         = 0,
    ["Visuals/Fullbright/RemoveFog"]        = true,
    ["Visuals/Fullbright/RemoveShadows"]    = true,
    ["Visuals/Fullbright/WhiteAmbient"]     = true,
    ["Visuals/Fullbright/RemoveAtmosphere"] = true,
    ["Visuals/Fullbright/SkyHaze"]          = 0,
    ["Visuals/Fullbright/SkyGlare"]         = 0,
    ["Visuals/Fullbright/ExposureCompensation"] = 0,
    -- FullDark modifiers
    ["Visuals/FullDark/ClockTime"]          = 0,
    ["Visuals/FullDark/Brightness"]         = 0,
    ["Visuals/FullDark/FogEnd"]             = 100,
    ["Visuals/FullDark/FogStart"]           = 0,
    ["Visuals/FullDark/SetFog"]             = true,
    ["Visuals/FullDark/SetShadows"]         = true,
    ["Visuals/FullDark/BlackAmbient"]       = true,
    ["Visuals/FullDark/SetAtmosphere"]      = true,
    ["Visuals/FullDark/AtmosphereDensity"]  = 1,
    ["Visuals/FullDark/SkyHaze"]            = 0,
    ["Visuals/FullDark/SkyGlare"]           = 0,
    ["Visuals/FullDark/ExposureCompensation"] = -2,
    ["Visuals/UIScale"] = 1,
    ["LocalUI/PerformancePanel"] = true,
    ["LocalUI/LocalHealthIndicator"] = true,
    ["LocalUI/ClosestPlayerTracker"] = true,
    ["LocalUI/ClosestPlayer/ShowDisplayName"] = false,
    ["LocalUI/ClosestPlayer/ShowUsername"] = true,
    ["LocalUI/ClosestPlayer/ShowDistance"] = true,
    ["LocalUI/ClosestPlayer/ShowHealth"] = false,
    ["LocalUI/ClosestPlayer/ShowEquipped"] = false,
    ["Br3ak3r/Enabled"] = true,
    ["Waypoints/Enabled"] = true,
    ["Settings/Freecam Toggle"] = true,
    ["Settings/GhostMode"] = false,
    ["Misc/D3vTool"] = true,
    ["Misc/ScrollUnlocker"] = true,
    ["Misc/ItemPanel"] = false,
    ["Misc/QTeleport"] = true,
    ["Misc/HorizontalPositionForceValue"] = 1.5,
    ["Misc/VerticalPositionForceValue"] = 3.5,
    ["ESP/NametagOpacity"] = 90,
    ["LocalUI/ScreenUIOpacity"] = 90
}

if SAFE_MODE then
    Flags["Aim/AimLock"]        = false
    Flags["Aim/AlwaysEnabled"]  = false
    Flags["ShootBot/Enabled"]   = false
    Flags["Misc/QTeleport"]     = false
end
local ScreenGui = nil
local FovCircleFrame = nil
local UI = {}
local UI_THEME = {
    Background = Color3.fromRGB(18, 18, 18),
    Sidebar = Color3.fromRGB(25, 25, 25),
    Element = Color3.fromRGB(32, 32, 32),
    Accent = Color3.fromRGB(252, 149, 175),
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(150, 150, 150),
    Success = Color3.fromRGB(0, 220, 100),
    Fail = Color3.fromRGB(220, 50, 50)
}

local UIState = {
    MainFrame = nil,
    PriorityLabel = nil,
    Tabs = {},
    CurrentTab = nil,
    Visible = true,
    Minimized = false,
    ToggleMinimize = nil,
    DraggableFrames = {},
    Updaters = {},
    ActiveDraggedFrame = nil,
    DragStart = nil,
    StartPos = nil
}
local PROPERTY_CATEGORIES = {
    Data = {"Name", "ClassName", "Value", "Text"},
    Appearance = {"Color", "BrickColor", "Transparency", "Reflectance", "Material"},
    Behavior = {"CanCollide", "CanTouch", "CanQuery", "Anchored", "Locked", "Archivable"},
    Stats = {"Health", "MaxHealth", "WalkSpeed", "JumpPower", "JumpHeight"},
    Transform = {"Position", "Size", "Rotation", "CFrame"}
}

local AdvancedPlayerPanelState = {
    Visible = false,
    CurrentView = "List",
    SelectedPlayer = nil,
    Spectating = nil,
    ListTab = "All",
    DetailsTab = "General",
    ExplorerExpanded = {},
    ExplorerSelected = nil,
    PropertySearchText = "",
    Whitelist = {},
    Blacklist = {},
    TeamWhitelist = {},
    TeamBlacklist = {},
    TeamExpanded = {},
    PlayerRowCache = {},
    PriorityList = {}
}

local ItemPanelState = {
    Visible = false,
    lockedProperties = {},
    selectedItem = nil,
    explorerExpanded = {},
    explorerSelected = nil,
    PropertySearchText = ""
}

function ToggleWhitelist(player)
    if not player then return end
    local id = player.UserId
    AdvancedPlayerPanelState.Whitelist[id] = not AdvancedPlayerPanelState.Whitelist[id]
    if AdvancedPlayerPanelState.Whitelist[id] then
        AdvancedPlayerPanelState.Blacklist[id] = nil
        UI.Notify("Player Whitelisted ☮️", player.Name .. " has been whitelisted.", 3)
    else
        UI.Notify("Player unWhitelisted ☮️", player.Name .. " has been unwhitelisted.", 3)
    end
end

function ToggleBlacklist(player)
    if not player then return end
    local id = player.UserId
    AdvancedPlayerPanelState.Blacklist[id] = not AdvancedPlayerPanelState.Blacklist[id]
    if AdvancedPlayerPanelState.Blacklist[id] then
        AdvancedPlayerPanelState.Whitelist[id] = nil
        UI.Notify("Player Blacklisted ☠️", player.Name .. " has been blacklisted.", 3)
    else
        UI.Notify("Player unBlacklisted ☠️", player.Name .. " has been unblacklisted.", 3)
    end
end

function ToggleTeamWhitelist(teamName)
    if not teamName then return end
    AdvancedPlayerPanelState.TeamWhitelist[teamName] = not AdvancedPlayerPanelState.TeamWhitelist[teamName]
    if AdvancedPlayerPanelState.TeamWhitelist[teamName] then
        AdvancedPlayerPanelState.TeamBlacklist[teamName] = nil
        UI.Notify("Team Whitelisted ☮️", "Team " .. teamName .. " has been whitelisted.", 3)
    else
        UI.Notify("Team unWhitelisted ☮️", "Team " .. teamName .. " has been unwhitelisted.", 3)
    end
end

function ToggleTeamBlacklist(teamName)
    if not teamName then return end
    AdvancedPlayerPanelState.TeamBlacklist[teamName] = not AdvancedPlayerPanelState.TeamBlacklist[teamName]
    if AdvancedPlayerPanelState.TeamBlacklist[teamName] then
        AdvancedPlayerPanelState.TeamWhitelist[teamName] = nil
        UI.Notify("Team Blacklisted ☠️", "Team " .. teamName .. " has been blacklisted.", 3)
    else
        UI.Notify("Team unBlacklisted ☠️", "Team " .. teamName .. " has been unblacklisted.", 3)
    end
end

function GetPriorityRank(player, teamName)
    if not AdvancedPlayerPanelState.PriorityList then return nil end
    for index, item in ipairs(AdvancedPlayerPanelState.PriorityList) do
        if item.type == "Player" then
            if player.UserId == item.value or player.Name == item.value then
                return index
            end
        elseif item.type == "Team" then
            if teamName == item.value then
                return index
            end
        end
    end
    return nil
end

function IsPlayerPrioritized(player)
    if not player then return false end
    for _, item in ipairs(AdvancedPlayerPanelState.PriorityList) do
        if item.type == "Player" and (item.value == player.UserId or item.value == player.Name) then
            return true
        end
    end
    return false
end

function TogglePlayerPriority(player)
    if not player then return end
    local foundIdx = nil
    for i, item in ipairs(AdvancedPlayerPanelState.PriorityList) do
        if item.type == "Player" and (item.value == player.UserId or item.value == player.Name) then
            foundIdx = i
            break
        end
    end

    if foundIdx then
        table.remove(AdvancedPlayerPanelState.PriorityList, foundIdx)
        UI.Notify("Player Deprioritized ⭐", player.Name .. " has been deprioritized.", 3)
    else
        table.insert(AdvancedPlayerPanelState.PriorityList, {
            type = "Player",
            value = player.Name
        })
        UI.Notify("Player Prioritized ⭐", player.Name .. " has been prioritized.", 3)
    end
end

function IsTeamPrioritized(teamName)
    if not teamName then return false end
    for _, item in ipairs(AdvancedPlayerPanelState.PriorityList) do
        if item.type == "Team" and item.value == teamName then
            return true
        end
    end
    return false
end

function ToggleTeamPriority(teamName)
    if not teamName then return end
    local foundIdx = nil
    for i, item in ipairs(AdvancedPlayerPanelState.PriorityList) do
        if item.type == "Team" and item.value == teamName then
            foundIdx = i
            break
        end
    end

    if foundIdx then
        table.remove(AdvancedPlayerPanelState.PriorityList, foundIdx)
        UI.Notify("Player Explorer", "Team " .. teamName .. " has been deprioritized.", 3)
    else
        table.insert(AdvancedPlayerPanelState.PriorityList, {
            type = "Team",
            value = teamName
        })
        UI.Notify("Player Explorer", "Team " .. teamName .. " has been prioritized.", 3)
    end
end
local AdvancedPlayerPanelUI = {
    MainFrame = nil,
    ListFrame = nil,
    DetailsFrame = nil,
    Entries = {},
    DetailLabels = {},
    TabButtons = {},
    DetailsTabButtons = {},
    PropertyFrame = nil,
    PropertyContent = nil,
    PropertySearch = nil
}

local SwitchToPlayerPageView
local UpdateActionButtonsState

local ItemPanelUI = {
    MainFrame = nil,
    ExplorerContent = nil,
    PropertyContent = nil,
    PropertyFrame = nil,
    PropertySearch = nil,
    ExplorerCounter = 0
}
local HumanoidState = {
    originalSettings = {},
    captured = false,
    presetsApplied = false
}
local WorldHumState = {
    selectedHum = nil,
    Page = nil,
    lockedProperties = {},
    connections = {},
    updaters = {},
    listEntries = {},
    selectionHighlight = nil,
    presetsApplied = {}
}
local Br3ak3rState = {
    FilterDirty = true,
    CLICKBREAK_ENABLED = true,
    brokenSet = {},
    brokenIgnoreCache = {},
    scratchIgnore = {},
    brokenCacheDirty = true,
    undoStack = {},
    hoverHL = nil,
    CTRL_HELD = false,
    LEFT_CTRL_HELD = false,
    RIGHT_CTRL_HELD = false,
    lastEnforcement = 0,
    br3akerRaycastParams = RaycastParams.new()
}
Br3ak3rState.br3akerRaycastParams.IgnoreWater = true
local H1ghl1ght3rState = {
    ENABLED = true,
    highlightedSet = {},
    undoStack = {},
    SHIFT_HELD = false
}
local FullbrightState = {
    lastState = false,
    originalSettings = nil
}
local ZoomState = {
    OriginalMax = LocalPlayer.CameraMaxZoomDistance,
    OriginalMin = LocalPlayer.CameraMinZoomDistance,
    LastSetMax = nil,
    LastSetMin = nil,
    Multiplier = 1,
    WasCtrlHeld = false,
    UserScrolled = false
}

local LocalCharReady = true
function OnLocalCharacterAdded(newChar)
    LocalCharReady = false
    if Br3ak3rState then Br3ak3rState.FilterDirty = true end

    if CharCache then table.clear(CharCache) end

    HumanoidState.captured = false
    HumanoidState.presetsApplied = false

    task.wait(1.5)

    local root = nil
    local humanoid = nil
    local attempts = 0
    repeat
        task.wait(0.2)
        root = newChar:FindFirstChild("HumanoidRootPart") or newChar.PrimaryPart
        humanoid = newChar:FindFirstChildOfClass("Humanoid")
        attempts = attempts + 1
    until (root and humanoid) or attempts > 25

    if not humanoid then
        local humConn
        humConn = newChar.ChildAdded:Connect(function(child)
            if child:IsA("Humanoid") then
                humConn:Disconnect()
                CaptureHumanoidSettings(child)
                print("[Sp3arParvus] Humanoid detected late (deferred spawn) and captured.")
            end
        end)
    else
        CaptureHumanoidSettings(humanoid)
    end

    LocalCharReady = true
    print("[Sp3arParvus] Local character re-cached and ready.")
end

globalEnv = getgenv and getgenv() or _G
if rawget(globalEnv, "Sp3arParvus") then
    return warn("[Sp3arParvus] Already loaded! Use Shutdown button to cleanup first.")
end

globalEnv.Sp3arParvus = {
    Active = true,
    Version = VERSION,
    Connections = {},
    Threads = {}
}
Sp3arParvus = globalEnv.Sp3arParvus

function TrackConnection(connection)
    if connection and typeof(connection) == "RBXScriptConnection" then
        table.insert(Sp3arParvus.Connections, connection)
    end
    return connection
end

function TrackThread(thread)
    if thread and type(thread) == "thread" then
        table.insert(Sp3arParvus.Threads, thread)
    end
    return thread
end

function CleanupDeadConnections()
    local connections = Sp3arParvus.Connections
    local n = #connections
    local i = 1
    while i <= n do
        local conn = connections[i]
        if not conn or not conn.Connected then
            connections[i] = connections[n]
            connections[n] = nil
            n = n - 1
        else
            i = i + 1
        end
    end
end

function CleanupDeadThreads()
    local threads = Sp3arParvus.Threads
    local n = #threads
    local i = 1
    while i <= n do
        local t = threads[i]
        if not t or coroutine.status(t) == "dead" then
            threads[i] = threads[n]
            threads[n] = nil
            n = n - 1
        else
            i = i + 1
        end
    end
end

TrackConnection(LocalPlayer.CharacterAdded:Connect(OnLocalCharacterAdded))

local Services = {
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    Lighting = game:GetService("Lighting"),
    TeleportService = game:GetService("TeleportService"),
    Stats = game:GetService("Stats"),
    GuiService = game:GetService("GuiService"),
    TweenService = game:GetService("TweenService"),
    Workspace = game:GetService("Workspace"),
    Players = game:GetService("Players"),
    VirtualUser = game:GetService("VirtualUser"),
    TextService = game:GetService("TextService")
}
local RunService, UserInputService, Lighting, TeleportService, Stats, GuiService, TweenService, Workspace, Players, VirtualUser, TextService =
    Services.RunService, Services.UserInputService, Services.Lighting, Services.TeleportService, Services.Stats, Services.GuiService, Services.TweenService, Services.Workspace, Services.Players, Services.VirtualUser, Services.TextService

TrackConnection(LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end))

function ResolveEnumItem(enumContainer, possibleNames)
    for _, name in ipairs(possibleNames) do
        local success, enumItem = pcall(function()
            return enumContainer[name]
        end)

        if success and enumItem and typeof(enumItem) == "EnumItem" then
            return enumItem
        end
    end

    return nil
end

local Camera = Services.Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Vector3new, Vector2new, CFramenew, UDim2new, Instancenew, RaycastParamsnew, Color3fromRGB, Color3new =
    Vector3.new, Vector2.new, CFrame.new, UDim2.new, Instance.new, RaycastParams.new, Color3.fromRGB, Color3.new
local abs, floor, max, min, sqrt = math.abs, math.floor, math.max, math.min, math.sqrt
local deg, atan2, rad, sin, cos = math.deg, math.atan2, math.rad, math.sin, math.cos

local function _setProp(obj, prop, val) obj[prop] = val end
local function PcallSetProp(obj, prop, val)
    return pcall(_setProp, obj, prop, val)
end

local function _safeSetProp(obj, prop, val)
    if obj[prop] ~= val then
        obj[prop] = val
        return true
    end
    return false
end
local function PcallSafeSetProp(obj, prop, val)
    local ok, changed = pcall(_safeSetProp, obj, prop, val)
    return ok and changed
end

local function _destroy(obj) if obj then obj:Destroy() end end
local function PcallDestroy(obj)
    return pcall(_destroy, obj)
end

local function _setEnabled(obj, state) obj.Enabled = state end
local function PcallSetEnabled(obj, state)
    return pcall(_setEnabled, obj, state)
end

local function _disconnect(conn) if conn and conn.Connected then conn:Disconnect() end end
local function PcallDisconnect(conn)
    return pcall(_disconnect, conn)
end

local _DNS_SET = {
    [1628571024] = true,
    [125458810] = true,
    [1554084058] = true,
    [10476800936] = true
}
function DNS(Player)
    return _DNS_SET[Player.UserId] or false
end

local function _getParent(obj) return obj.Parent end
local function PcallGetParent(obj)
    local ok, res = pcall(_getParent, obj)
    return ok and res or nil
end

local function SafeSetProp(obj, prop, val)
    if obj[prop] ~= val then
        obj[prop] = val
    end
end

local function SafeGetProp(obj, prop)
    return obj[prop]
end

local function BoundedInsertionSort(array, count, compare)
    for i = 2, count do
        local key = array[i]
        local j = i - 1
        while j > 0 and compare(key, array[j]) do
            array[j + 1] = array[j]
            j = j - 1
        end
        array[j + 1] = key
    end
end

local TWEENS = {
    INSTANT = TweenInfo.new(0.05),
    FAST = TweenInfo.new(0.1),
    MEDIUM = TweenInfo.new(0.2),
    SMOOTH = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    BACK = TweenInfo.new(0.3, Enum.EasingStyle.Back),
    DRAG = TweenInfo.new(0.05)
}

local ViewportCache = {}
local ViewportPool = {}
TrackConnection(RunService.RenderStepped:Connect(function()
    for pos, entry in pairs(ViewportCache) do
        table.insert(ViewportPool, entry)
    end
    table.clear(ViewportCache)
end))

local function GetViewportPoint(worldPos)
    local entry = ViewportCache[worldPos]
    if entry then
        return entry[1], entry[2]
    end
    local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
    entry = table.remove(ViewportPool) or {}
    entry[1], entry[2] = screenPos, onScreen
    ViewportCache[worldPos] = entry
    return screenPos, onScreen
end

local cachedPlayersList = {}

function InitPlayerCache()
    cachedPlayersList = Players:GetPlayers()
end
InitPlayerCache()

function GetPlayersCache()
    return cachedPlayersList
end

function UpdatePlayerCache()
    cachedPlayersList = Players:GetPlayers()
end

function AddPlayerToCache(player)
    if not table.find(cachedPlayersList, player) then
        table.insert(cachedPlayersList, player)
    end
end

function RemovePlayerFromCache(player)
    local idx = table.find(cachedPlayersList, player)
    if idx then
        table.remove(cachedPlayersList, idx)
    end
end

local AIM_ACQUIRE_STABILIZE_FRAMES = 2
local AIM_ORIGIN_JUMP_RATIO = 0.25

function ClearAimLockState(resetMouseMode)
    AimState.LastAimTarget = nil
    AimState.LastOriginX = nil
    AimState.LastOriginY = nil
    AimState.AcquiringFrames = 0

    if resetMouseMode then
        AimState.LastMouseMode = nil
    end
end

function GetCrosshairViewportPosition(mouseBehavior)
    if not Camera then
        Camera = Services.Workspace.CurrentCamera
    end
    if not Camera then
        return nil, nil, false
    end

    local viewportSize = Camera.ViewportSize

    if mouseBehavior == Enum.MouseBehavior.LockCenter then
        return viewportSize.X * 0.5, viewportSize.Y * 0.5, true
    end

    local mouseLoc = Services.UserInputService:GetMouseLocation()

    local crosshairX = mouseLoc.X
    local crosshairY = mouseLoc.Y

    if crosshairX ~= crosshairX or crosshairY ~= crosshairY then
        return nil, nil, false
    end

    if crosshairX < 0 or crosshairY < 0 or crosshairX > viewportSize.X or crosshairY > viewportSize.Y then
        return nil, nil, false
    end

    return crosshairX, crosshairY, true
end

local CachedTarget = nil
local CachedTargetTime = 0

local TARGET_GROUPS = {
    Head = {"Head"},
    Torso = {"Torso", "UpperTorso", "LowerTorso", "HumanoidRootPart"},
    LeftArm = {"Left Arm", "LeftUpperArm", "LeftLowerArm", "LeftHand"},
    RightArm = {"Right Arm", "RightUpperArm", "RightLowerArm", "RightHand"},
    LeftLeg = {"Left Leg", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot"},
    RightLeg = {"Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot"}
}

local ALL_BODY_PARTS = {}
for _, group in pairs(TARGET_GROUPS) do
    for _, part in ipairs(group) do
        table.insert(ALL_BODY_PARTS, part)
    end
end

KnownBodyParts = ALL_BODY_PARTS

local HUMANOID_PROPERTY_MAPPING = {
    ["Humanoid/Archivable"] = "Archivable",
    ["Humanoid/BreakJointsOnDeath"] = "BreakJointsOnDeath",
    ["Humanoid/EvaluateStateMachine"] = "EvaluateStateMachine",
    ["Humanoid/RequiresNeck"] = "RequiresNeck",
    ["Humanoid/AutoRotate"] = "AutoRotate",
    ["Humanoid/PlatformStand"] = "PlatformStand",
    ["Humanoid/Sit"] = "Sit",
    ["Humanoid/Jump"] = "Jump",
    ["Humanoid/AutoJumpEnabled"] = "AutoJumpEnabled",
    ["Humanoid/JumpHeight"] = "JumpHeight",
    ["Humanoid/JumpPower"] = "JumpPower",
    ["Humanoid/UseJumpPower"] = "UseJumpPower",
    ["Humanoid/AutomaticScalingEnabled"] = "AutomaticScalingEnabled",
    ["Humanoid/Health"] = "Health",
    ["Humanoid/MaxHealth"] = "MaxHealth",
    ["Humanoid/HipHeight"] = "HipHeight",
    ["Humanoid/MaxSlopeAngle"] = "MaxSlopeAngle",
    ["Humanoid/WalkSpeed"] = "WalkSpeed"
}

local HUMANOID_ENFORCED_PROPERTIES = {
    ["Humanoid/Archivable"] = "Archivable",
    ["Humanoid/BreakJointsOnDeath"] = "BreakJointsOnDeath",
    ["Humanoid/EvaluateStateMachine"] = "EvaluateStateMachine",
    ["Humanoid/RequiresNeck"] = "RequiresNeck",
    ["Humanoid/AutoRotate"] = "AutoRotate",
    ["Humanoid/PlatformStand"] = "PlatformStand",
    ["Humanoid/AutoJumpEnabled"] = "AutoJumpEnabled",
    ["Humanoid/UseJumpPower"] = "UseJumpPower",
    ["Humanoid/AutomaticScalingEnabled"] = "AutomaticScalingEnabled",
    ["Humanoid/MaxHealth"] = "MaxHealth",
    ["Humanoid/MaxSlopeAngle"] = "MaxSlopeAngle"
}

function TrackWorldHumConnection(connection)
    if connection and typeof(connection) == "RBXScriptConnection" then
        table.insert(WorldHumState.connections, connection)
    end
    return connection
end

function ClearWorldHumConnections()
    for _, conn in ipairs(WorldHumState.connections) do
        if conn.Connected then
            conn:Disconnect()
        end
    end
    table.clear(WorldHumState.connections)
    table.clear(WorldHumState.updaters)
    table.clear(WorldHumState.presetsApplied)
end

function CaptureHumanoidSettings(humanoid)
    if not humanoid or HumanoidState.captured then return end
    HumanoidState.presetsApplied = false

    local properties = {
        "Archivable", "BreakJointsOnDeath", "EvaluateStateMachine", "RequiresNeck",
        "AutoRotate", "PlatformStand", "Sit", "Jump", "AutoJumpEnabled",
        "JumpHeight", "JumpPower", "UseJumpPower", "AutomaticScalingEnabled",
        "Health", "MaxHealth", "HipHeight", "MaxSlopeAngle", "WalkSpeed"
    }

    local flagMapping = {
        Archivable = "Humanoid/Archivable",
        BreakJointsOnDeath = "Humanoid/BreakJointsOnDeath",
        EvaluateStateMachine = "Humanoid/EvaluateStateMachine",
        RequiresNeck = "Humanoid/RequiresNeck",
        AutoRotate = "Humanoid/AutoRotate",
        PlatformStand = "Humanoid/PlatformStand",
        Sit = "Humanoid/Sit",
        Jump = "Humanoid/Jump",
        AutoJumpEnabled = "Humanoid/AutoJumpEnabled",
        JumpHeight = "Humanoid/JumpHeight",
        JumpPower = "Humanoid/JumpPower",
        UseJumpPower = "Humanoid/UseJumpPower",
        AutomaticScalingEnabled = "Humanoid/AutomaticScalingEnabled",
        Health = "Humanoid/Health",
        MaxHealth = "Humanoid/MaxHealth",
        HipHeight = "Humanoid/HipHeight",
        MaxSlopeAngle = "Humanoid/MaxSlopeAngle",
        WalkSpeed = "Humanoid/WalkSpeed"
    }

    for _, prop in ipairs(properties) do
        pcall(function()
            local val = humanoid[prop]
            HumanoidState.originalSettings[prop] = val

            if flagMapping[prop] then
                local flag = flagMapping[prop]
                Flags[flag] = val
                local updater = UIState.Updaters[flag]
                if updater then
                    updater(val)
                end
            end
        end)
    end

    HumanoidState.captured = true
    print("[Sp3arParvus] Local Humanoid settings captured and synced.")
end

function ApplyHumanoidSettings()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if not humanoid then return end

    if not HumanoidState.captured then
        CaptureHumanoidSettings(humanoid)
    end

    if not HumanoidState.presetsApplied and game.PlaceId == 2474168535 and DNS(LocalPlayer) then
        local presets = {
            ["Humanoid/JumpHeight"] = 8,
            ["Humanoid/UseJumpPower"] = false,
            ["Humanoid/PlatformStand"] = false,
            ["Humanoid/AutoRotate"] = true,
            ["Humanoid/MaxSlopeAngle"] = 90
        }
        for flag, val in pairs(presets) do
            if Flags[flag] ~= val or not Flags[flag .. "/Locked"] then
                Flags[flag] = val
                Flags[flag .. "/Locked"] = true
                local updater = UIState.Updaters[flag]
                if updater then updater(val) end
                local lockUpdater = UIState.Updaters[flag .. "/Locked"]
                if lockUpdater then lockUpdater(true) end
            end
        end
        HumanoidState.presetsApplied = true
    end

    for flag, prop in pairs(HUMANOID_PROPERTY_MAPPING) do
        local isEnforced = HUMANOID_ENFORCED_PROPERTIES[flag] ~= nil
        local isLocked = Flags[flag .. "/Locked"] == true

        if isEnforced or isLocked then
            local val = Flags[flag]
            if val ~= nil then
                pcall(SafeSetProp, humanoid, prop, val)
            end
        end
    end
end

function UpdateHumanoidUI()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    for flag, prop in pairs(HUMANOID_PROPERTY_MAPPING) do
        if Flags[flag .. "/Locked"] then continue end

        local success, val = pcall(SafeGetProp, humanoid, prop)

        if success and val ~= nil and Flags[flag] ~= val then
            Flags[flag] = val
            local updater = UIState.Updaters[flag]
            if updater then
                updater(val)
            end
        end
    end
end

local _nearbyOverlapParams = OverlapParams.new()
_nearbyOverlapParams.MaxParts = 500

function GetNearbyHumanoids()
    local humanoids = {}
    local seen = {}
    local myChar = LocalPlayer.Character

    _nearbyOverlapParams.FilterDescendantsInstances = myChar and {myChar} or {}
    if CachedFilterType and _nearbyOverlapParams.FilterType ~= CachedFilterType then
        _nearbyOverlapParams.FilterType = CachedFilterType
    end

    local parts = Services.Workspace:GetPartBoundsInRadius(Camera.CFrame.Position, 500, _nearbyOverlapParams)
    for i = 1, #parts do
        local part = parts[i]
        local model = part:FindFirstAncestorOfClass("Model")
        if model and model ~= myChar and not seen[model] then
            seen[model] = true
            local hum = model:FindFirstChildOfClass("Humanoid")
            if hum and not Players:GetPlayerFromCharacter(model) then
                table.insert(humanoids, hum)
            end
        end
    end

    return humanoids
end

function ApplyItemPanelSettings()
    for path, props in pairs(ItemPanelState.lockedProperties) do
        local inst = ResolveItemPath(path)
        if inst then
            for prop, val in pairs(props) do
                pcall(PcallSafeSetProp, inst, prop, val)
            end
        end
    end
end

function ApplyWorldHumanoidSettings()

    if game.PlaceId == 2474168535 and DNS(LocalPlayer) then
        local now = os.clock()
        if (now - lastWorldHumPresetScan) > 5.0 then
            lastWorldHumPresetScan = now
            local nearby = GetNearbyHumanoids()
            for i = 1, #nearby do
                local hum = nearby[i]
                if hum.Name == "Horse" or (hum.Parent and hum.Parent.Name == "Horse") then
                    local path = GetUniquePath(hum)
                    if not WorldHumState.presetsApplied[path] then
                        if not WorldHumState.lockedProperties[path] then
                            WorldHumState.lockedProperties[path] = {
                                ["JumpPower"] = 65,
                                ["MaxSlopeAngle"] = 89.9
                            }
                        else
                            WorldHumState.lockedProperties[path]["JumpPower"] = 65
                            WorldHumState.lockedProperties[path]["MaxSlopeAngle"] = 89.9
                        end
                        WorldHumState.presetsApplied[path] = true
                    end
                end
            end
        end
    end

    for path, props in pairs(WorldHumState.lockedProperties) do
        local hum = GetInstanceFromPath(path)
        if hum and hum:IsA("Humanoid") then
            for prop, val in pairs(props) do
                pcall(SafeSetProp, hum, prop, val)
            end
        else

            WorldHumState.lockedProperties[path] = nil
            WorldHumState.presetsApplied[path] = nil
        end
    end
end

function UpdateWorldHumanoidEditorUI()
    local hum = WorldHumState.selectedHum
    if not hum then return end

    if not hum.Parent then
        WorldHumState.selectedHum = nil
        ClearWorldHumConnections()
        if WorldHumState.Page then
            ShowWorldHumList(WorldHumState.Page)
        end
        return
    end

    local path = GetUniquePath(hum)
    local lockedProps = WorldHumState.lockedProperties[path] or {}

    for prop, updater in pairs(WorldHumState.updaters) do
        if lockedProps[prop] ~= nil then continue end

        local success, val = pcall(SafeGetProp, hum, prop)
        if success and val ~= nil then
            updater(val)
        end
    end
end

ActiveWaypoints = {}
WaypointCounter = 0
WaypointColors = {
    Color3.fromRGB(0, 200, 255),
    Color3.fromRGB(255, 100, 100),
    Color3.fromRGB(100, 255, 100),
    Color3.fromRGB(255, 200, 50),
    Color3.fromRGB(200, 100, 255)
}
WaypointsTabButton = nil
WaypointsPage = nil
WaypointsUIList = nil
WaypointConnections = {}

UNDO_LIMIT = 100
RAYCAST_MAX_DISTANCE = 3000

function GetFullPath(instance)
    local path = instance.Name
    local current = instance.Parent
    while current and current ~= game do
        path = current.Name .. "/" .. path
        current = current.Parent
    end
    return path
end

local PathCache = setmetatable({}, {__mode = "k"})
function GetUniquePath(instance)
    if PathCache[instance] then return PathCache[instance] end
    local path = ""
    local current = instance
    while current and current ~= game do
        local name = current.Name
        local parent = current.Parent
        local index = 1
        if parent then
            for _, child in ipairs(parent:GetChildren()) do
                if child == current then break end
                if child.Name == name then
                    index = index + 1
                end
            end
        end
        path = name .. "[" .. index .. "]" .. (path == "" and "" or "\1" .. path)
        current = parent
    end
    PathCache[instance] = path
    return path
end

function GetItemUniquePath(instance)
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character

    local root = nil
    local rootName = ""

    if backpack and instance:IsDescendantOf(backpack) then
        root = backpack
        rootName = "Backpack"
    elseif character and instance:IsDescendantOf(character) then
        root = character
        rootName = "Character"
    end

    if not root then return GetUniquePath(instance) end

    local path = ""
    local current = instance
    while current and current ~= root do
        local name = current.Name
        local parent = current.Parent
        local index = 1
        if parent then
            for _, child in ipairs(parent:GetChildren()) do
                if child == current then break end
                if child.Name == name then
                    index = index + 1
                end
            end
        end
        path = name .. "[" .. index .. "]" .. (path == "" and "" or "\1" .. path)
        current = parent
    end

    return rootName .. "\2" .. path
end

function ResolveRelativePath(root, relativePath)
    if not relativePath or relativePath == "" then return root end
    local segments = string.split(relativePath, "\1")
    local current = root
    for _, segment in ipairs(segments) do
        local name, index = string.match(segment, "^(.*)%[(%d+)%]$")
        if name and index then
            index = tonumber(index)
            local count = 0
            local found = false
            for _, child in ipairs(current:GetChildren()) do
                if child.Name == name then
                    count = count + 1
                    if count == index then
                        current = child
                        found = true
                        break
                    end
                end
            end
            if not found then return nil end
        else
            current = current:FindFirstChild(segment)
            if not current then return nil end
        end
    end
    return current
end

function ResolveItemPath(itemPath)
    if not itemPath then return nil end
    if not string.find(itemPath, "\2") then return GetInstanceFromPath(itemPath) end

    local parts = string.split(itemPath, "\2")
    local rootName = parts[1]
    local relativePath = parts[2]

    local root = nil
    if rootName == "Backpack" then
        root = LocalPlayer:FindFirstChild("Backpack")
    elseif rootName == "Character" then
        root = LocalPlayer.Character
    end

    local resolved = root and ResolveRelativePath(root, relativePath)
    if not resolved then

        if rootName == "Backpack" then
            root = LocalPlayer.Character
        else
            root = LocalPlayer:FindFirstChild("Backpack")
        end
        resolved = root and ResolveRelativePath(root, relativePath)
    end

    return resolved
end

function GetInstanceFromPath(uniquePath)
    if type(uniquePath) ~= "string" then return nil end
    local segments = string.split(uniquePath, "\1")
    local current = game
    for _, segment in ipairs(segments) do
        local name, index = string.match(segment, "^(.*)%[(%d+)%]$")
        if name and index then
            index = tonumber(index)
            local count = 0
            local found = false
            for _, child in ipairs(current:GetChildren()) do
                if child.Name == name then
                    count = count + 1
                    if count == index then
                        current = child
                        found = true
                        break
                    end
                end
            end
            if not found then return nil end
        else
            current = current:FindFirstChild(segment)
            if not current then return nil end
        end
    end
    return current
end

function RobustResolvePart(path, data)
    local part = GetInstanceFromPath(path)
    if part and part.Parent and part:IsA("BasePart") then
        if not data.pos or (part.Position - data.pos).Magnitude < 0.1 then
            return part
        end
    end

    if data.pos and data.name then
        local parts = Services.Workspace:GetPartBoundsInRadius(data.pos, 0.5)
        for _, p in ipairs(parts) do
            if p.Name == data.name and p:IsA("BasePart") then
                return p
            end
        end
    end
    return nil
end

Br3ak3rFilterType = (function()
    local ok, val = pcall(function() return Enum.RaycastFilterType.Exclude end)
    if ok and val and typeof(val) == "EnumItem" then return val end
    ok, val = pcall(function() return Enum.RaycastFilterType.Blacklist end)
    if ok and val and typeof(val) == "EnumItem" then return val end
    return nil
end)()

if Br3ak3rFilterType then
    Br3ak3rState.br3akerRaycastParams.FilterType = Br3ak3rFilterType
end

function RebuildBrokenIgnore()
    Br3ak3rState.FilterDirty = true
    if not next(Br3ak3rState.brokenSet) then
        table.clear(Br3ak3rState.brokenIgnoreCache)
        Br3ak3rState.brokenCacheDirty = false
        return
    end
    table.clear(Br3ak3rState.brokenIgnoreCache)
    local cacheIndex = 1
    for path, data in pairs(Br3ak3rState.brokenSet) do
        local part = data.instance
        if not part or not part.Parent then
            part = RobustResolvePart(path, data)
            if part then data.instance = part end
        end
        if part and part:IsDescendantOf(Services.Workspace) then
            Br3ak3rState.brokenIgnoreCache[cacheIndex] = part
            cacheIndex = cacheIndex + 1
        end
    end
    Br3ak3rState.brokenCacheDirty = false
end

function GetMouseRay()
    local mouseLocation = Services.UserInputService:GetMouseLocation()
    local inset = Services.GuiService:GetGuiInset()
    local adjustedLocation = mouseLocation - inset

    if not Camera then Camera = Services.Workspace.CurrentCamera end
    if not Camera then return nil end

    local ray = Camera:ScreenPointToRay(adjustedLocation.X, adjustedLocation.Y)
    if not ray then return nil end

    return ray.Origin, ray.Direction * RAYCAST_MAX_DISTANCE, mouseLocation.X, mouseLocation.Y
end

MAX_IGNORE_COUNT = 200

function WorldRaycastBr3ak3r(origin, direction, ignoreLocalChar, extraIgnore)
    if Br3ak3rState.brokenCacheDirty then
        RebuildBrokenIgnore()
    end

    if Br3ak3rState.FilterDirty or extraIgnore then
        local ignore = Br3ak3rState.scratchIgnore
        table.clear(ignore)

        local ignoreCount = 0
        if ignoreLocalChar then
            local ch = LocalPlayer.Character
            if ch then
                ignoreCount = ignoreCount + 1
                ignore[ignoreCount] = ch
            end
        end

        if extraIgnore then
            for i = 1, #extraIgnore do
                local item = extraIgnore[i]
                if item then
                    ignoreCount = ignoreCount + 1
                    ignore[ignoreCount] = item
                end
            end
        end

        local brokenCacheLen = #Br3ak3rState.brokenIgnoreCache
        for i = 1, brokenCacheLen do
            local item = Br3ak3rState.brokenIgnoreCache[i]
            if item then
                ignoreCount = ignoreCount + 1
                ignore[ignoreCount] = item
            end
        end

        Br3ak3rState.br3akerRaycastParams.FilterDescendantsInstances = ignore
        if not extraIgnore then Br3ak3rState.FilterDirty = false end
    end

    return Services.Workspace:Raycast(origin, direction, Br3ak3rState.br3akerRaycastParams)
end

function markBroken(part)
    if not part or not part:IsA("BasePart") or part:IsA("Terrain") then return end
    local path = GetUniquePath(part)
    if Br3ak3rState.brokenSet[path] then return end

    if #Br3ak3rState.undoStack >= UNDO_LIMIT then
        unbreakAll()
    end

    Br3ak3rState.brokenSet[path] = {
        instance = part,
        pos = part.Position,
        name = part.Name,
        cc = part.CanCollide,
        ct = part.CanTouch,
        cq = part.CanQuery,
        ltm = part.LocalTransparencyModifier,
        t = part.Transparency
    }
    Br3ak3rState.brokenCacheDirty = true

    table.insert(Br3ak3rState.undoStack, {
        path = path,
        instance = part,
        pos = part.Position,
        name = part.Name,
        cc = part.CanCollide,
        ct = part.CanTouch,
        cq = part.CanQuery,
        ltm = part.LocalTransparencyModifier,
        t = part.Transparency
    })

    part.CanCollide = false
    pcall(function() part.CanTouch = false end)
    pcall(function() part.CanQuery = false end)
    part.LocalTransparencyModifier = 0.5
    part.Transparency = 0.5

    UI.Notify("Br3ak3r", "Br3ak3r removed '" .. (part.Name or "Unknown") .. "'")
end

function unbreakLast()
    local entry = table.remove(Br3ak3rState.undoStack)
    if not entry or not entry.path then return end

    local path = entry.path
    local part = entry.instance
    if not part or not part.Parent then
        part = RobustResolvePart(path, entry)
    end

    Br3ak3rState.brokenSet[path] = nil
    Br3ak3rState.brokenCacheDirty = true

    UI.Notify("Br3ak3r", "Br3ak3r r3st0r3d '" .. (entry.name or (part and part.Name) or "Unknown") .. "'")

    if part then

        part.CanCollide = entry.cc
        pcall(function() part.CanTouch = entry.ct end)
        pcall(function() part.CanQuery = entry.cq end)
        part.LocalTransparencyModifier = entry.ltm
        part.Transparency = entry.t
    end
end

function unbreakAll()
    local count = 0
    for _ in pairs(Br3ak3rState.brokenSet) do count = count + 1 end

    for path, data in pairs(Br3ak3rState.brokenSet) do
        pcall(function()
            local part = data.instance
            if not part or not part.Parent then
                part = RobustResolvePart(path, data)
            end
            if part and part.Parent and type(data) == "table" then
                part.CanCollide = data.cc
                pcall(function() part.CanTouch = data.ct end)
                pcall(function() part.CanQuery = data.cq end)
                part.LocalTransparencyModifier = data.ltm
                part.Transparency = data.t
            end
        end)
    end
    table.clear(Br3ak3rState.brokenSet)
    table.clear(Br3ak3rState.undoStack)
    table.clear(Br3ak3rState.brokenIgnoreCache)
    Br3ak3rState.brokenCacheDirty = true

    UI.Notify("Br3ak3r", "Br3ak3r restored " .. count .. " parts")
end

sweepAccum = 0
function sweepUndo(dt)
    sweepAccum = sweepAccum + dt
    if sweepAccum < 2 then return end
    sweepAccum = 0

    local n = #Br3ak3rState.undoStack
    if n == 0 then return end

    local j = 1
    local camPos = Camera and Camera.CFrame.Position
    for i = 1, n do
        local entry = Br3ak3rState.undoStack[i]
        local keep = true

        local part = entry.instance
        if not part or not part.Parent then
            local resolved = RobustResolvePart(entry.path, entry)
            if resolved then
                entry.instance = resolved
                part = resolved
            end
        end

        if not part or not part.Parent then
            local lastPos = entry.pos
            if lastPos and camPos then
                local dist = (lastPos - camPos).Magnitude

                if dist < 250 then
                    keep = false
                end
            elseif not lastPos then

                keep = false
            end
        end

        if keep then
            if i ~= j then
                Br3ak3rState.undoStack[j] = entry
            end
            j = j + 1
        end
    end

    for i = j, n do
        Br3ak3rState.undoStack[i] = nil
    end
end

function pruneBrokenSet()

    local removed = false
    local camPos = Camera and Camera.CFrame.Position
    for path, data in pairs(Br3ak3rState.brokenSet) do
        local part = data.instance
        if not part or not part.Parent then
            local resolved = RobustResolvePart(path, data)
            if resolved then
                data.instance = resolved
                part = resolved
            end
        end

        if not part or not part.Parent then

            local lastPos = data.pos
            if lastPos and camPos then
                local dist = (lastPos - camPos).Magnitude

                if dist < 250 then
                    Br3ak3rState.brokenSet[path] = nil
                    removed = true
                end
            elseif not lastPos then

                Br3ak3rState.brokenSet[path] = nil
                removed = true
            end
        end
    end
    if removed then
        Br3ak3rState.brokenCacheDirty = true
    end
end

function markHighlighted(part)
    if not part or not part:IsA("BasePart") or part:IsA("Terrain") then return end
    if H1ghl1ght3rState.highlightedSet[part] then return end

    local hl = Instance.new("Highlight")

<truncated 415819 bytes>

NOTE: The output was truncated because it was too long. Use a more targeted query or a smaller range to get the information you need.