-- ====================================================================
--              MORON FISH IT v8.0 - by GasUp ID
--       Based on verified working Auto Fish V4.0 method
--         No Key | No HWID | Free Forever | Undetected
-- ====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local VirtualUser
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

-- ====================================================================
--                    CONFIGURATION
-- ====================================================================
local CONFIG_FOLDER = "MoronFishIt"
local CONFIG_FILE = CONFIG_FOLDER .. "/config.json"

local Config = {
    AutoFish = false,
    AutoSell = false,
    AutoCatch = false,
    GPUSaver = false,
    BlatantMode = false,
    AutoFavorite = true,
    FavoriteRarity = "Mythic",
    FishDelay = 0.9,
    CatchDelay = 0.2,
    SellDelay = 30,
    AntiAFK = true,
    WalkSpeed = 16,
    JumpPower = 50,
    InfJump = false,
    Fly = false,
    Noclip = false,
    AntiDrown = false,
}

local DefaultConfig = {}
for k, v in pairs(Config) do DefaultConfig[k] = v end

local function ensureFolder()
    if not isfolder or not makefolder then return false end
    if not isfolder(CONFIG_FOLDER) then pcall(function() makefolder(CONFIG_FOLDER) end) end
    return isfolder(CONFIG_FOLDER)
end

local function saveConfig()
    if not writefile or not ensureFolder() then return end
    pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(Config)) end)
end

local function loadConfig()
    if not readfile or not isfile or not isfile(CONFIG_FILE) then return end
    pcall(function()
        local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
        for k, v in pairs(data) do if DefaultConfig[k] ~= nil then Config[k] = v end end
    end)
end

loadConfig()

-- ====================================================================
--                     NETWORK EVENTS (VERIFIED WORKING)
-- ====================================================================
local Events = {}
local eventsLoaded = false

local function initEvents()
    local ok = pcall(function()
        local net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
        Events.fishing = net:WaitForChild("RE/FishingCompleted", 10)
        Events.sell = net:WaitForChild("RF/SellAllItems", 10)
        Events.charge = net:WaitForChild("RF/ChargeFishingRod", 10)
        Events.minigame = net:WaitForChild("RF/RequestFishingMinigameStarted", 10)
        Events.cancel = net:WaitForChild("RF/CancelFishingInputs", 10)
        Events.equip = net:WaitForChild("RE/EquipToolFromHotbar", 10)
        Events.unequip = net:WaitForChild("RE/UnequipToolFromHotbar", 10)
        Events.favorite = net:WaitForChild("RE/FavoriteItem", 10)
        eventsLoaded = true
    end)
    if not ok then warn("[Moron] Events failed to load") end
end

initEvents()

-- ====================================================================
--                     MODULES FOR AUTO FAVORITE
-- ====================================================================
local ItemUtility, Replion, PlayerData
pcall(function()
    ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
    Replion = require(ReplicatedStorage.Packages.Replion)
    PlayerData = Replion.Client:WaitReplion("Data")
end)

local RarityTiers = { Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5, Mythic = 6, Secret = 7 }

-- ====================================================================
--                     TELEPORT LOCATIONS
-- ====================================================================
local LOCATIONS = {
    ["Spawn"] = CFrame.new(45.27, 252.56, 2987.10),
    ["Sisyphus Statue"] = CFrame.new(-3728.21, -135.07, -1012.12),
    ["Coral Reefs"] = CFrame.new(-3114.78, 1.32, 2237.52),
    ["Esoteric Depths"] = CFrame.new(3248.37, -1301.53, 1403.82),
    ["Crater Island"] = CFrame.new(1016.49, 20.09, 5069.27),
    ["Lost Isle"] = CFrame.new(-3618.15, 240.83, -1317.45),
    ["Weather Machine"] = CFrame.new(-1488.51, 83.17, 1876.30),
    ["Tropical Grove"] = CFrame.new(-2095.34, 197.19, 3718.08),
    ["Mount Hallow"] = CFrame.new(2136.62, 78.91, 3272.50),
    ["Treasure Room"] = CFrame.new(-3606.34, -266.57, -1580.97),
    ["Kohana"] = CFrame.new(-663.90, 3.04, 718.79),
    ["Underground Cellar"] = CFrame.new(2109.52, -94.18, -708.60),
    ["Ancient Jungle"] = CFrame.new(1831.71, 6.62, -299.27),
    ["Sacred Temple"] = CFrame.new(1466.92, -21.87, -622.83),
}

-- ====================================================================
--                     FISHING FUNCTIONS (VERIFIED)
-- ====================================================================
local isFishing = false
local fishingActive = false

local function castRod()
    if not eventsLoaded then return end
    pcall(function()
        Events.equip:FireServer(1)
        task.wait(0.05)
        Events.charge:InvokeServer(1755848498.4834)
        task.wait(0.02)
        Events.minigame:InvokeServer(1.2854545116425, 1)
    end)
end

local function reelIn()
    if not eventsLoaded then return end
    pcall(function() Events.fishing:FireServer() end)
end

local function fishingLoop()
    while fishingActive do
        if Config.BlatantMode then
            isFishing = true
            pcall(function()
                Events.equip:FireServer(1)
                task.wait(0.01)
                task.spawn(function()
                    Events.charge:InvokeServer(1755848498.4834)
                    task.wait(0.01)
                    Events.minigame:InvokeServer(1.2854545116425, 1)
                end)
                task.wait(0.05)
                task.spawn(function()
                    Events.charge:InvokeServer(1755848498.4834)
                    task.wait(0.01)
                    Events.minigame:InvokeServer(1.2854545116425, 1)
                end)
            end)
            task.wait(Config.FishDelay)
            for i = 1, 5 do
                pcall(function() Events.fishing:FireServer() end)
                task.wait(0.01)
            end
            task.wait(Config.CatchDelay * 0.5)
            isFishing = false
        else
            isFishing = true
            castRod()
            task.wait(Config.FishDelay)
            reelIn()
            task.wait(Config.CatchDelay)
            isFishing = false
        end
        task.wait(0.05)
    end
end

-- ====================================================================
--                     UTILITY FUNCTIONS
-- ====================================================================
local function simpleSell()
    if not eventsLoaded then return end
    pcall(function() Events.sell:InvokeServer() end)
end

local favoritedItems = {}
local function autoFavoriteByRarity()
    if not Config.AutoFavorite or not PlayerData or not ItemUtility then return end
    pcall(function()
        local items = PlayerData:GetExpect("Inventory").Items
        if not items then return end
        for _, item in ipairs(items) do
            local data = ItemUtility:GetItemData(item.Id)
            if data and data.Data then
                local rarity = data.Data.Rarity or "Common"
                local val = RarityTiers[rarity] or 0
                local target = RarityTiers[Config.FavoriteRarity] or 6
                if val >= target and not item.Favorited and not favoritedItems[item.UUID] then
                    Events.favorite:FireServer(item.UUID)
                    favoritedItems[item.UUID] = true
                    task.wait(0.3)
                end
            end
        end
    end)
end

local function teleportTo(name)
    local cf = LOCATIONS[name]
    if not cf then return end
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = cf
        end
    end)
end

local gpuActive = false
local gpuScreen = nil
local function enableGPU()
    if gpuActive then return end
    gpuActive = true
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        game.Lighting.GlobalShadows = false
        game.Lighting.FogEnd = 1
        if setfpscap then setfpscap(8) end
    end)
    gpuScreen = Instance.new("ScreenGui")
    gpuScreen.ResetOnSpawn = false
    gpuScreen.DisplayOrder = 999999
    gpuScreen:SetAttribute("_mfi", true)
    local f = Instance.new("Frame", gpuScreen)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0, 300, 0, 60)
    l.Position = UDim2.new(0.5, -150, 0.5, -30)
    l.BackgroundTransparency = 1
    l.Text = "GPU SAVER ACTIVE\nMoron Fish It Running..."
    l.TextColor3 = Color3.fromRGB(0, 200, 130)
    l.TextSize = 20
    l.Font = Enum.Font.GothamBold
    gpuScreen.Parent = (gethui and gethui()) or LocalPlayer.PlayerGui
end

local function disableGPU()
    if not gpuActive then return end
    gpuActive = false
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        game.Lighting.GlobalShadows = true
        game.Lighting.FogEnd = 100000
        if setfpscap then setfpscap(0) end
    end)
    if gpuScreen then gpuScreen:Destroy() gpuScreen = nil end
end

-- ====================================================================
--                     ANTI-AFK
-- ====================================================================
if VirtualUser then
    LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

-- ====================================================================
--                     BACKGROUND LOOPS
-- ====================================================================
task.spawn(function()
    while true do
        if Config.AutoCatch and not isFishing and eventsLoaded then
            pcall(function() Events.fishing:FireServer() end)
        end
        task.wait(Config.CatchDelay)
    end
end)

task.spawn(function()
    while true do
        task.wait(Config.SellDelay)
        if Config.AutoSell and eventsLoaded then simpleSell() end
    end
end)

task.spawn(function()
    while true do
        task.wait(10)
        if Config.AutoFavorite then autoFavoriteByRarity() end
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hum then
                if Config.WalkSpeed ~= 16 then hum.WalkSpeed = Config.WalkSpeed end
                if Config.JumpPower ~= 50 then hum.JumpPower = Config.JumpPower end
            end
            if Config.Noclip and char then
                for _, p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
            if Config.AntiDrown and hrp and hrp.Position.Y < -5 then
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 10, 0)
            end
        end)
        task.wait(0.1)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Config.InfJump then
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end)

local flyBV = nil
task.spawn(function()
    while true do
        pcall(function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if Config.Fly and hrp then
                if not flyBV then
                    flyBV = Instance.new("BodyVelocity")
                    flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    flyBV.Velocity = Vector3.new(0, 0, 0)
                    flyBV.Parent = hrp
                end
                local cam = workspace.CurrentCamera
                local dir = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                flyBV.Velocity = dir * 80
            else
                if flyBV then flyBV:Destroy() flyBV = nil end
            end
        end)
        task.wait(0.05)
    end
end)

-- ====================================================================
--                     CLEANUP OLD UI
-- ====================================================================
local guiParent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
for _, v in pairs(guiParent:GetChildren()) do
    if v:GetAttribute("_mfi") then v:Destroy() end
end

-- ====================================================================
--                     SPLASH SCREEN
-- ====================================================================
local splash = Instance.new("ScreenGui")
splash.ResetOnSpawn = false
splash:SetAttribute("_mfi", true)
splash.Parent = guiParent

local sf = Instance.new("Frame", splash)
sf.Size = UDim2.new(0, 200, 0, 65)
sf.Position = UDim2.new(0.5, -100, 0.5, -32)
sf.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
sf.BorderSizePixel = 0
sf.BackgroundTransparency = 1
Instance.new("UICorner", sf).CornerRadius = UDim.new(0, 10)

local st = Instance.new("TextLabel", sf)
st.Size = UDim2.new(1, 0, 0, 30)
st.Position = UDim2.new(0, 0, 0, 8)
st.BackgroundTransparency = 1
st.Text = "GasUp ID"
st.TextColor3 = Color3.fromRGB(0, 200, 130)
st.TextSize = 20
st.Font = Enum.Font.GothamBold
st.TextTransparency = 1

local ss = Instance.new("TextLabel", sf)
ss.Size = UDim2.new(1, 0, 0, 18)
ss.Position = UDim2.new(0, 0, 0, 38)
ss.BackgroundTransparency = 1
ss.Text = "Moron Fish It v8.0"
ss.TextColor3 = Color3.fromRGB(160, 160, 170)
ss.TextSize = 12
ss.Font = Enum.Font.Gotham
ss.TextTransparency = 1

local ti = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenService:Create(sf, ti, {BackgroundTransparency = 0}):Play()
TweenService:Create(st, ti, {TextTransparency = 0}):Play()
TweenService:Create(ss, ti, {TextTransparency = 0}):Play()
task.wait(2)
TweenService:Create(sf, ti, {BackgroundTransparency = 1}):Play()
TweenService:Create(st, ti, {TextTransparency = 1}):Play()
TweenService:Create(ss, ti, {TextTransparency = 1}):Play()
task.wait(0.5)
splash:Destroy()

-- ====================================================================
--                     MAIN UI - ATOMIC HUB STYLE
-- ====================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui:SetAttribute("_mfi", true)
screenGui.Parent = guiParent

local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 460, 0, 320)
main.Position = UDim2.new(0.5, -230, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
main.BorderSizePixel = 0
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- Top bar
local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 36)
topBar.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
topBar.BorderSizePixel = 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)
local tbFix = Instance.new("Frame", topBar)
tbFix.Size = UDim2.new(1, 0, 0, 12)
tbFix.Position = UDim2.new(0, 0, 1, -12)
tbFix.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
tbFix.BorderSizePixel = 0

local titleLbl = Instance.new("TextLabel", topBar)
titleLbl.Size = UDim2.new(0, 130, 1, 0)
titleLbl.Position = UDim2.new(0, 12, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "Moron Fish It"
titleLbl.TextColor3 = Color3.fromRGB(0, 200, 130)
titleLbl.TextSize = 14
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextXAlignment = Enum.TextXAlignment.Left

local verLbl = Instance.new("TextLabel", topBar)
verLbl.Size = UDim2.new(0, 40, 1, 0)
verLbl.Position = UDim2.new(0, 138, 0, 0)
verLbl.BackgroundTransparency = 1
verLbl.Text = "v8.0"
verLbl.TextColor3 = Color3.fromRGB(80, 80, 90)
verLbl.TextSize = 11
verLbl.Font = Enum.Font.Gotham
verLbl.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -36, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "x"
closeBtn.TextColor3 = Color3.fromRGB(120, 120, 130)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold

-- Draggable
local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
topBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- Sidebar
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 130, 1, -36)
sidebar.Position = UDim2.new(0, 0, 0, 36)
sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
sidebar.BorderSizePixel = 0

local sepLine = Instance.new("Frame", sidebar)
sepLine.Size = UDim2.new(0, 1, 1, 0)
sepLine.Position = UDim2.new(1, 0, 0, 0)
sepLine.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
sepLine.BorderSizePixel = 0

-- Content area
local contentArea = Instance.new("Frame", main)
contentArea.Size = UDim2.new(1, -130, 1, -36)
contentArea.Position = UDim2.new(0, 130, 0, 36)
contentArea.BackgroundTransparency = 1
contentArea.ClipsDescendants = true

-- ====== TABS ======
local tabNames = {"Fishing", "Selling", "Teleport", "Movement", "Utility", "Settings"}
local currentTab = "Fishing"
local tabBtns = {}
local pages = {}

local sLayout = Instance.new("UIListLayout", sidebar)
sLayout.SortOrder = Enum.SortOrder.LayoutOrder
sLayout.Padding = UDim.new(0, 2)

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(160, 160, 170)
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = i

    local ind = Instance.new("Frame", btn)
    ind.Size = UDim2.new(0, 3, 0, 20)
    ind.Position = UDim2.new(0, 0, 0.5, -10)
    ind.BackgroundColor3 = Color3.fromRGB(0, 200, 130)
    ind.BorderSizePixel = 0
    ind.Visible = (name == currentTab)
    Instance.new("UICorner", ind).CornerRadius = UDim.new(0, 2)

    tabBtns[name] = {btn = btn, ind = ind}
end

-- ====== CREATE PAGES ======
for _, name in ipairs(tabNames) do
    local scroll = Instance.new("ScrollingFrame", contentArea)
    scroll.Size = UDim2.new(1, -10, 1, -10)
    scroll.Position = UDim2.new(0, 5, 0, 5)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Visible = (name == currentTab)

    local lay = Instance.new("UIListLayout", scroll)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Padding = UDim.new(0, 4)

    local pad = Instance.new("UIPadding", scroll)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.PaddingTop = UDim.new(0, 5)

    pages[name] = scroll
end

-- ====== UI COMPONENT BUILDERS ======
local function mkSection(page, text, ord)
    local l = Instance.new("TextLabel", page)
    l.Size = UDim2.new(1, 0, 0, 22)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(100, 100, 110)
    l.TextSize = 11
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = ord
end

local function mkToggle(page, title, desc, key, ord, cb)
    local f = Instance.new("Frame", page)
    f.Size = UDim2.new(1, 0, 0, desc and 40 or 34)
    f.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    f.BorderSizePixel = 0
    f.LayoutOrder = ord
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1, -70, 0, 20)
    t.Position = UDim2.new(0, 12, 0, desc and 3 or 7)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = Color3.fromRGB(220, 220, 230)
    t.TextSize = 13
    t.Font = Enum.Font.GothamMedium
    t.TextXAlignment = Enum.TextXAlignment.Left

    if desc then
        local d = Instance.new("TextLabel", f)
        d.Size = UDim2.new(1, -70, 0, 14)
        d.Position = UDim2.new(0, 12, 0, 22)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = Color3.fromRGB(90, 90, 100)
        d.TextSize = 10
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
    end

    local bg = Instance.new("Frame", f)
    bg.Size = UDim2.new(0, 40, 0, 22)
    bg.Position = UDim2.new(1, -52, 0.5, -11)
    bg.BackgroundColor3 = Config[key] and Color3.fromRGB(0, 200, 130) or Color3.fromRGB(55, 55, 65)
    bg.BorderSizePixel = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", bg)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = Config[key] and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton", bg)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    btn.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        local on = Config[key]
        local tw = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
        TweenService:Create(bg, tw, {BackgroundColor3 = on and Color3.fromRGB(0, 200, 130) or Color3.fromRGB(55, 55, 65)}):Play()
        TweenService:Create(knob, tw, {Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
        saveConfig()
        if cb then cb(on) end
    end)
end

local function mkButton(page, title, ord, cb)
    local b = Instance.new("TextButton", page)
    b.Size = UDim2.new(1, 0, 0, 34)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    b.BorderSizePixel = 0
    b.Text = title
    b.TextColor3 = Color3.fromRGB(200, 200, 210)
    b.TextSize = 13
    b.Font = Enum.Font.GothamMedium
    b.LayoutOrder = ord
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
end

local function mkSlider(page, title, key, mn, mx, ord, cb)
    local f = Instance.new("Frame", page)
    f.Size = UDim2.new(1, 0, 0, 50)
    f.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    f.BorderSizePixel = 0
    f.LayoutOrder = ord
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1, -60, 0, 20)
    t.Position = UDim2.new(0, 12, 0, 4)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = Color3.fromRGB(220, 220, 230)
    t.TextSize = 13
    t.Font = Enum.Font.GothamMedium
    t.TextXAlignment = Enum.TextXAlignment.Left

    local vl = Instance.new("TextLabel", f)
    vl.Size = UDim2.new(0, 50, 0, 20)
    vl.Position = UDim2.new(1, -58, 0, 4)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(Config[key])
    vl.TextColor3 = Color3.fromRGB(0, 200, 130)
    vl.TextSize = 12
    vl.Font = Enum.Font.GothamBold
    vl.TextXAlignment = Enum.TextXAlignment.Right

    local sbg = Instance.new("Frame", f)
    sbg.Size = UDim2.new(1, -24, 0, 6)
    sbg.Position = UDim2.new(0, 12, 0, 34)
    sbg.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    sbg.BorderSizePixel = 0
    Instance.new("UICorner", sbg).CornerRadius = UDim.new(1, 0)

    local pct = math.clamp((Config[key] - mn) / (mx - mn), 0, 1)
    local fill = Instance.new("Frame", sbg)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 130)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local sBtn = Instance.new("TextButton", f)
    sBtn.Size = UDim2.new(1, 0, 0, 20)
    sBtn.Position = UDim2.new(0, 0, 0, 28)
    sBtn.BackgroundTransparency = 1
    sBtn.Text = ""

    local sliding = false
    local function upd(pos)
        local abs = sbg.AbsolutePosition
        local sz = sbg.AbsoluteSize
        local rel = math.clamp((pos.X - abs.X) / sz.X, 0, 1)
        local val = mn + (mx - mn) * rel
        if mx <= 10 then val = math.floor(val * 10 + 0.5) / 10 else val = math.floor(val + 0.5) end
        Config[key] = val
        vl.Text = tostring(val)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        saveConfig()
        if cb then cb(val) end
    end

    sBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            upd(inp.Position)
        end
    end)
    sBtn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if sliding and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            upd(inp.Position)
        end
    end)
end

-- ====== POPULATE PAGES ======

-- FISHING
local fp = pages["Fishing"]
mkSection(fp, "FISHING MODE", 1)
mkToggle(fp, "Auto Fish", "Automatically cast and reel", "AutoFish", 2, function(on)
    fishingActive = on
    if on then task.spawn(fishingLoop) else pcall(function() Events.unequip:FireServer() end) end
end)
mkToggle(fp, "Blatant Mode", "2x parallel casts + spam reel", "BlatantMode", 3)
mkToggle(fp, "Auto Catch", "Extra reel spam for speed", "AutoCatch", 4)
mkSection(fp, "TIMING", 5)
mkSlider(fp, "Fish Delay", "FishDelay", 0.1, 5, 6)
mkSlider(fp, "Catch Delay", "CatchDelay", 0.1, 3, 7)

-- SELLING
local sp = pages["Selling"]
mkSection(sp, "AUTO SELL", 1)
mkToggle(sp, "Auto Sell", "Sell non-favorited fish", "AutoSell", 2)
mkSlider(sp, "Sell Delay (sec)", "SellDelay", 10, 300, 3)
mkButton(sp, "Sell All Now", 4, simpleSell)
mkSection(sp, "AUTO FAVORITE", 5)
mkToggle(sp, "Auto Favorite", "Favorite Mythic/Secret fish", "AutoFavorite", 6)
mkButton(sp, "Favorite All Now", 7, autoFavoriteByRarity)

-- TELEPORT
local tp = pages["Teleport"]
mkSection(tp, "LOCATIONS", 1)
local tpOrd = 2
for name, _ in pairs(LOCATIONS) do
    mkButton(tp, name, tpOrd, function() teleportTo(name) end)
    tpOrd = tpOrd + 1
end

-- MOVEMENT
local mp = pages["Movement"]
mkSection(mp, "CHARACTER", 1)
mkSlider(mp, "Walk Speed", "WalkSpeed", 16, 200, 2)
mkSlider(mp, "Jump Power", "JumpPower", 50, 300, 3)
mkToggle(mp, "Infinite Jump", "Jump in mid-air", "InfJump", 4)
mkToggle(mp, "Fly", "WASD + Space/Shift", "Fly", 5)
mkToggle(mp, "Noclip", "Walk through walls", "Noclip", 6)
mkToggle(mp, "Anti Drown", "Auto resurface underwater", "AntiDrown", 7)

-- UTILITY
local up = pages["Utility"]
mkSection(up, "PERFORMANCE", 1)
mkToggle(up, "GPU Saver", "Reduce graphics for FPS", "GPUSaver", 2, function(on)
    if on then enableGPU() else disableGPU() end
end)
mkSection(up, "SERVER", 3)
mkButton(up, "Server Hop", 4, function()
    pcall(function()
        local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, s in pairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id)
                return
            end
        end
    end)
end)
mkButton(up, "Rejoin Server", 5, function()
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId) end)
end)

-- SETTINGS
local stp = pages["Settings"]
mkSection(stp, "CONFIG", 1)
mkButton(stp, "Save Config", 2, saveConfig)
mkButton(stp, "Load Config", 3, loadConfig)
mkButton(stp, "Reset Config", 4, function()
    for k, v in pairs(DefaultConfig) do Config[k] = v end
    saveConfig()
end)
mkSection(stp, "INFO", 5)
local infoLbl = Instance.new("TextLabel", stp)
infoLbl.Size = UDim2.new(1, 0, 0, 50)
infoLbl.BackgroundTransparency = 1
infoLbl.Text = "Moron Fish It v8.0\nby GasUp ID\nNo Key | No HWID | Free Forever"
infoLbl.TextColor3 = Color3.fromRGB(100, 100, 110)
infoLbl.TextSize = 11
infoLbl.Font = Enum.Font.Gotham
infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.LayoutOrder = 6

-- ====== TAB SWITCHING ======
local function switchTab(name)
    currentTab = name
    for tn, data in pairs(tabBtns) do
        local active = (tn == name)
        data.ind.Visible = active
        data.btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 170)
        data.btn.Font = active and Enum.Font.GothamBold or Enum.Font.Gotham
    end
    for pn, pg in pairs(pages) do pg.Visible = (pn == name) end
end

for tn, data in pairs(tabBtns) do
    data.btn.MouseButton1Click:Connect(function() switchTab(tn) end)
end
switchTab("Fishing")

-- ====== FLOATING BUTTON ======
local floatBtn = Instance.new("TextButton", screenGui)
floatBtn.Size = UDim2.new(0, 40, 0, 40)
floatBtn.Position = UDim2.new(0, 10, 0.5, -20)
floatBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
floatBtn.BorderSizePixel = 0
floatBtn.Text = "M"
floatBtn.TextColor3 = Color3.fromRGB(0, 200, 130)
floatBtn.TextSize = 18
floatBtn.Font = Enum.Font.GothamBold
floatBtn.Visible = false
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(0, 10)

local fbDrag, fbDS, fbSP
floatBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        fbDrag = true
        fbDS = inp.Position
        fbSP = floatBtn.Position
    end
end)
floatBtn.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        if fbDrag then
            local d = inp.Position - fbDS
            if math.abs(d.X) < 5 and math.abs(d.Y) < 5 then
                main.Visible = true
                floatBtn.Visible = false
            end
        end
        fbDrag = false
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if fbDrag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - fbDS
        floatBtn.Position = UDim2.new(fbSP.X.Scale, fbSP.X.Offset + d.X, fbSP.Y.Scale, fbSP.Y.Offset + d.Y)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    floatBtn.Visible = true
end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        main.Visible = not main.Visible
        floatBtn.Visible = not main.Visible
    end
end)

-- ====== DONE ======
print("[Moron Fish It] v8.0 Loaded - GasUp ID")
print("[Moron Fish It] Events: " .. (eventsLoaded and "OK" or "FAILED"))
