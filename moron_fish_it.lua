-- ====================================================================
-- MORON FISH IT v7.1 - by GasUp ID
-- No Key | No HWID | Free Forever
-- ====================================================================

-- Cleanup previous instances
for _,v in ipairs(game:GetService("CoreGui"):GetChildren()) do
    if v:GetAttribute("_mfi") then pcall(function() v:Destroy() end) end
end
for _,v in ipairs(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
    if v:GetAttribute("_mfi") then pcall(function() v:Destroy() end) end
end

-- ====================================================================
-- CORE SERVICES
-- ====================================================================
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

-- ====================================================================
-- NETWORK EVENTS (exact paths from Fish It game)
-- ====================================================================
local Events = {}
local eventsLoaded = false

local function loadEvents()
    local ok, err = pcall(function()
        local net = RepStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
        Events = {
            fishing   = net:WaitForChild("RE/FishingCompleted", 10),
            sell      = net:WaitForChild("RF/SellAllItems", 10),
            charge    = net:WaitForChild("RF/ChargeFishingRod", 10),
            minigame  = net:WaitForChild("RF/RequestFishingMinigameStarted", 10),
            cancel    = net:WaitForChild("RF/CancelFishingInputs", 10),
            equip     = net:WaitForChild("RE/EquipToolFromHotbar", 10),
            unequip   = net:WaitForChild("RE/UnequipToolFromHotbar", 10),
            favorite  = net:WaitForChild("RE/FavoriteItem", 10)
        }
        eventsLoaded = true
    end)
    if not ok then warn("[MFI] Events error: " .. tostring(err)) end
end

task.spawn(loadEvents)

-- ====================================================================
-- MODULES (for Auto Favorite)
-- ====================================================================
local ItemUtility, PlayerData
pcall(function()
    ItemUtility = require(RepStorage.Shared.ItemUtility)
    local Replion = require(RepStorage.Packages.Replion)
    PlayerData = Replion.Client:WaitReplion("Data")
end)

-- ====================================================================
-- CONFIGURATION
-- ====================================================================
local CFG = {
    -- Fishing
    autoFish = false,
    blatant = false,
    autoCatch = false,
    fishDelay = 0.9,
    catchDelay = 0.2,
    -- Selling
    autoSell = false,
    sellDelay = 30,
    -- Favorite
    autoFavorite = false,
    favRarity = "Mythic",
    -- Movement
    walkSpeed = 16,
    jumpPower = 50,
    infJump = false,
    fly = false,
    noclip = false,
    -- Utility
    antiAfk = true,
    antiDrown = false,
    gpuSaver = false,
    fpsBoost = false,
    -- Visuals
    fishEsp = false,
    playerEsp = false,
}

-- ====================================================================
-- TELEPORT LOCATIONS (exact CFrames from working script)
-- ====================================================================
local LOCATIONS = {
    {"Spawn", CFrame.new(45.28, 252.56, 2987.11)},
    {"Sisyphus Statue", CFrame.new(-3728.22, -135.07, -1012.13)},
    {"Coral Reefs", CFrame.new(-3114.78, 1.32, 2237.52)},
    {"Esoteric Depths", CFrame.new(3248.37, -1301.53, 1403.83)},
    {"Crater Island", CFrame.new(1016.49, 20.09, 5069.27)},
    {"Lost Isle", CFrame.new(-3618.16, 240.84, -1317.46)},
    {"Weather Machine", CFrame.new(-1488.51, 83.17, 1876.30)},
    {"Tropical Grove", CFrame.new(-2095.34, 197.20, 3718.08)},
    {"Mount Hallow", CFrame.new(2136.62, 78.92, 3272.50)},
    {"Treasure Room", CFrame.new(-3606.35, -266.57, -1580.97)},
    {"Kohana", CFrame.new(-663.90, 3.05, 718.80)},
    {"Underground Cellar", CFrame.new(2109.52, -94.19, -708.61)},
    {"Ancient Jungle", CFrame.new(1831.71, 6.62, -299.28)},
    {"Sacred Temple", CFrame.new(1466.92, -21.88, -622.84)},
}

-- Rarity system
local RarityTiers = {Common=1, Uncommon=2, Rare=3, Epic=4, Legendary=5, Mythic=6, Secret=7}

-- Utility
local function rnd(a, b) return a + math.random() * (b - a) end

-- ====================================================================
-- SPLASH SCREEN (small, professional, centered)
-- ====================================================================
local splashGui = Instance.new("ScreenGui")
splashGui:SetAttribute("_mfi", true)
splashGui.Name = "S" .. math.random(100000,999999)
splashGui.ResetOnSpawn = false
splashGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
splashGui.DisplayOrder = 100
pcall(function() splashGui.Parent = game:GetService("CoreGui") end)
if not splashGui.Parent then splashGui.Parent = LP:WaitForChild("PlayerGui") end

local splashFrame = Instance.new("Frame", splashGui)
splashFrame.Size = UDim2.new(0, 200, 0, 70)
splashFrame.Position = UDim2.new(0.5, -100, 0.5, -35)
splashFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
splashFrame.BorderSizePixel = 0
splashFrame.BackgroundTransparency = 1
Instance.new("UICorner", splashFrame).CornerRadius = UDim.new(0, 12)

local splashTitle = Instance.new("TextLabel", splashFrame)
splashTitle.Size = UDim2.new(1, 0, 0, 30)
splashTitle.Position = UDim2.new(0, 0, 0, 10)
splashTitle.BackgroundTransparency = 1
splashTitle.Text = "GasUp ID"
splashTitle.TextColor3 = Color3.fromRGB(0, 200, 130)
splashTitle.TextSize = 20
splashTitle.Font = Enum.Font.GothamBold
splashTitle.TextTransparency = 1

local splashSub = Instance.new("TextLabel", splashFrame)
splashSub.Size = UDim2.new(1, 0, 0, 16)
splashSub.Position = UDim2.new(0, 0, 0, 40)
splashSub.BackgroundTransparency = 1
splashSub.Text = "Moron Fish It v7.1"
splashSub.TextColor3 = Color3.fromRGB(140, 140, 150)
splashSub.TextSize = 11
splashSub.Font = Enum.Font.Gotham
splashSub.TextTransparency = 1

TS:Create(splashFrame, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
TS:Create(splashTitle, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
task.wait(0.2)
TS:Create(splashSub, TweenInfo.new(0.5), {TextTransparency = 0}):Play()

task.delay(2.5, function()
    TS:Create(splashFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    TS:Create(splashTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TS:Create(splashSub, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    task.wait(0.5)
    splashGui:Destroy()
end)

-- ====================================================================
-- MAIN UI (Atomic Hub Style - compact, rounded, professional)
-- ====================================================================
task.delay(3.2, function()

local gui = Instance.new("ScreenGui")
gui:SetAttribute("_mfi", true)
gui.Name = "G" .. math.random(100000,999999)
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 99
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

-- Main container
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 460, 0, 330)
main.Position = UDim2.new(0.5, -230, 0.5, -165)
main.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- Drop shadow (subtle)
local shadow = Instance.new("ImageLabel", main)
shadow.Name = "Shadow"
shadow.BackgroundTransparency = 1
shadow.Position = UDim2.new(0, -6, 0, -6)
shadow.Size = UDim2.new(1, 12, 1, 12)
shadow.ZIndex = -1
shadow.Image = "rbxassetid://6014261993"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(49, 49, 450, 450)

-- ====================================================================
-- TOP BAR
-- ====================================================================
local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 34)
topBar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
topBar.BorderSizePixel = 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)
-- Fix bottom corners
local topFix = Instance.new("Frame", topBar)
topFix.Size = UDim2.new(1, 0, 0, 12)
topFix.Position = UDim2.new(0, 0, 1, -12)
topFix.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
topFix.BorderSizePixel = 0

local titleLbl = Instance.new("TextLabel", topBar)
titleLbl.Size = UDim2.new(0, 120, 1, 0)
titleLbl.Position = UDim2.new(0, 12, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "Moron Hub"
titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLbl.TextSize = 14
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextXAlignment = Enum.TextXAlignment.Left

local verLbl = Instance.new("TextLabel", topBar)
verLbl.Size = UDim2.new(0, 50, 1, 0)
verLbl.Position = UDim2.new(0, 100, 0, 0)
verLbl.BackgroundTransparency = 1
verLbl.Text = "v7.1"
verLbl.TextColor3 = Color3.fromRGB(0, 200, 130)
verLbl.TextSize = 10
verLbl.Font = Enum.Font.Gotham
verLbl.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 34, 0, 34)
closeBtn.Position = UDim2.new(1, -34, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "x"
closeBtn.TextColor3 = Color3.fromRGB(120, 120, 130)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold

-- ====================================================================
-- SIDEBAR
-- ====================================================================
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 120, 1, -34)
sidebar.Position = UDim2.new(0, 0, 0, 34)
sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
sidebar.BorderSizePixel = 0
-- Bottom left corner
local sideCornerBL = Instance.new("UICorner", sidebar)
sideCornerBL.CornerRadius = UDim.new(0, 10)
-- Fix top and right corners
local sideFix1 = Instance.new("Frame", sidebar)
sideFix1.Size = UDim2.new(1, 0, 0, 12)
sideFix1.Position = UDim2.new(0, 0, 0, 0)
sideFix1.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
sideFix1.BorderSizePixel = 0
local sideFix2 = Instance.new("Frame", sidebar)
sideFix2.Size = UDim2.new(0, 12, 1, 0)
sideFix2.Position = UDim2.new(1, -12, 0, 0)
sideFix2.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
sideFix2.BorderSizePixel = 0

-- Sidebar scroll for tabs
local sideScroll = Instance.new("ScrollingFrame", sidebar)
sideScroll.Size = UDim2.new(1, 0, 1, -4)
sideScroll.Position = UDim2.new(0, 0, 0, 4)
sideScroll.BackgroundTransparency = 1
sideScroll.BorderSizePixel = 0
sideScroll.ScrollBarThickness = 0
sideScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
sideScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local sideLayout = Instance.new("UIListLayout", sideScroll)
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Padding = UDim.new(0, 1)

local tabs = {"Fishing", "Selling", "Teleport", "Movement", "Utility", "Visuals", "Settings"}
local currentTab = "Fishing"
local tabBtns = {}

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton", sideScroll)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.LayoutOrder = i
    btn.BorderSizePixel = 0

    -- Indicator bar (left green line)
    local ind = Instance.new("Frame", btn)
    ind.Name = "ind"
    ind.Size = UDim2.new(0, 3, 0, 18)
    ind.Position = UDim2.new(0, 2, 0.5, -9)
    ind.BackgroundColor3 = Color3.fromRGB(0, 200, 130)
    ind.BorderSizePixel = 0
    ind.Visible = (tabName == currentTab)
    Instance.new("UICorner", ind).CornerRadius = UDim.new(0, 2)

    -- Tab label
    local lbl = Instance.new("TextLabel", btn)
    lbl.Name = "lbl"
    lbl.Size = UDim2.new(1, -14, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = tabName
    lbl.TextColor3 = (tabName == currentTab) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(130, 130, 140)
    lbl.TextSize = 12
    lbl.Font = (tabName == currentTab) and Enum.Font.GothamBold or Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    tabBtns[tabName] = btn
end

-- ====================================================================
-- CONTENT AREA
-- ====================================================================
local contentFrame = Instance.new("Frame", main)
contentFrame.Size = UDim2.new(1, -124, 1, -38)
contentFrame.Position = UDim2.new(0, 122, 0, 36)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.ClipsDescendants = true

local content = Instance.new("ScrollingFrame", contentFrame)
content.Size = UDim2.new(1, -4, 1, 0)
content.Position = UDim2.new(0, 2, 0, 0)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 2
content.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y

-- ====================================================================
-- UI COMPONENT BUILDERS
-- ====================================================================
local function makeSection(parent, title, order)
    local hdr = Instance.new("Frame", parent)
    hdr.Size = UDim2.new(1, -8, 0, 24)
    hdr.BackgroundTransparency = 1
    hdr.LayoutOrder = order
    local txt = Instance.new("TextLabel", hdr)
    txt.Size = UDim2.new(1, -4, 1, 0)
    txt.Position = UDim2.new(0, 4, 0, 0)
    txt.BackgroundTransparency = 1
    txt.Text = title
    txt.TextColor3 = Color3.fromRGB(80, 80, 100)
    txt.TextSize = 10
    txt.Font = Enum.Font.GothamBold
    txt.TextXAlignment = Enum.TextXAlignment.Left
end

local function makeToggle(parent, name, desc, key, order)
    local h = (desc and desc ~= "") and 42 or 30
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -8, 0, h)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -52, 0, 16)
    lbl.Position = UDim2.new(0, 4, 0, 3)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(210, 210, 220)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    if desc and desc ~= "" then
        local d = Instance.new("TextLabel", row)
        d.Size = UDim2.new(1, -52, 0, 12)
        d.Position = UDim2.new(0, 4, 0, 20)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = Color3.fromRGB(70, 70, 85)
        d.TextSize = 9
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
    end

    -- Toggle track
    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(0, 36, 0, 18)
    track.Position = UDim2.new(1, -42, 0, h/2 - 9)
    track.BackgroundColor3 = CFG[key] and Color3.fromRGB(0, 200, 130) or Color3.fromRGB(50, 50, 60)
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    -- Toggle knob
    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = CFG[key] and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    -- Clickable area
    local btn = Instance.new("TextButton", track)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 2

    btn.MouseButton1Click:Connect(function()
        CFG[key] = not CFG[key]
        local on = CFG[key]
        TS:Create(track, TweenInfo.new(0.15), {
            BackgroundColor3 = on and Color3.fromRGB(0, 200, 130) or Color3.fromRGB(50, 50, 60)
        }):Play()
        TS:Create(knob, TweenInfo.new(0.15), {
            Position = on and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2)
        }):Play()
    end)
    return row
end

local function makeSlider(parent, name, key, mn, mx, step, order)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -8, 0, 38)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.65, 0, 0, 16)
    lbl.Position = UDim2.new(0, 4, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(210, 210, 220)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local val = Instance.new("TextLabel", row)
    val.Size = UDim2.new(0.35, -4, 0, 16)
    val.Position = UDim2.new(0.65, 0, 0, 2)
    val.BackgroundTransparency = 1
    val.Text = tostring(CFG[key])
    val.TextColor3 = Color3.fromRGB(0, 200, 130)
    val.TextSize = 11
    val.Font = Enum.Font.GothamBold
    val.TextXAlignment = Enum.TextXAlignment.Right

    local bg = Instance.new("Frame", row)
    bg.Size = UDim2.new(1, -8, 0, 4)
    bg.Position = UDim2.new(0, 4, 0, 26)
    bg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    bg.BorderSizePixel = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local pct = math.clamp((CFG[key] - mn) / (mx - mn), 0, 1)
    local fill = Instance.new("Frame", bg)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 130)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knobS = Instance.new("Frame", bg)
    knobS.Size = UDim2.new(0, 10, 0, 10)
    knobS.Position = UDim2.new(pct, -5, 0.5, -5)
    knobS.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knobS.BorderSizePixel = 0
    knobS.ZIndex = 2
    Instance.new("UICorner", knobS).CornerRadius = UDim.new(1, 0)

    local hit = Instance.new("TextButton", bg)
    hit.Size = UDim2.new(1, 0, 1, 16)
    hit.Position = UDim2.new(0, 0, 0, -8)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.ZIndex = 3

    local dragging = false
    hit.MouseButton1Down:Connect(function() dragging = true end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local function updSlider(pos)
        if not dragging then return end
        local x = bg.AbsolutePosition.X
        local w = bg.AbsoluteSize.X
        if w <= 0 then return end
        local r = math.clamp((pos.X - x) / w, 0, 1)
        local v = math.floor((mn + r * (mx - mn)) / step + 0.5) * step
        v = math.clamp(v, mn, mx)
        v = math.floor(v * 10 + 0.5) / 10
        CFG[key] = v
        local p = (v - mn) / (mx - mn)
        fill.Size = UDim2.new(p, 0, 1, 0)
        knobS.Position = UDim2.new(p, -5, 0.5, -5)
        val.Text = tostring(v)
    end

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updSlider(input.Position)
        end
    end)
    hit.MouseButton1Down:Connect(function()
        dragging = true
        local m = LP:GetMouse()
        updSlider(Vector2.new(m.X, m.Y))
    end)
end

local function makeButton(parent, name, callback, order)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -8, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(190, 190, 200)
    btn.TextSize = 11
    btn.Font = Enum.Font.Gotham
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseEnter:Connect(function()
        TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(42, 42, 52)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(32, 32, 40)}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
end

local function makeSeparator(parent, order)
    local sep = Instance.new("Frame", parent)
    sep.Size = UDim2.new(1, -16, 0, 1)
    sep.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    sep.BorderSizePixel = 0
    sep.LayoutOrder = order
end

-- ====================================================================
-- BUILD ALL PAGES
-- ====================================================================
local pages = {}
for _, tabName in ipairs(tabs) do
    local page = Instance.new("Frame", content)
    page.Name = tabName
    page.Size = UDim2.new(1, 0, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.Visible = (tabName == currentTab)
    local lay = Instance.new("UIListLayout", page)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Padding = UDim.new(0, 2)
    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 8)
    pages[tabName] = page
end

-- ======================== FISHING PAGE ========================
do
    local p = pages["Fishing"]
    makeSection(p, "FISHING MODE", 1)
    makeToggle(p, "Auto Fish", "Equip rod, cast and reel automatically", "autoFish", 2)
    makeToggle(p, "Blatant Mode", "2x parallel casts, faster reeling", "blatant", 3)
    makeToggle(p, "Auto Catch", "Spam reel for extra catch speed", "autoCatch", 4)
    makeSeparator(p, 5)
    makeSection(p, "TIMING", 6)
    makeSlider(p, "Fish Delay", "fishDelay", 0.1, 5.0, 0.1, 7)
    makeSlider(p, "Catch Delay", "catchDelay", 0.1, 3.0, 0.1, 8)
    makeSeparator(p, 9)
    makeSection(p, "EXTRAS", 10)
    makeToggle(p, "Auto Favorite", "Auto favorite Mythic+ fish", "autoFavorite", 11)
end

-- ======================== SELLING PAGE ========================
do
    local p = pages["Selling"]
    makeSection(p, "AUTO SELL", 1)
    makeToggle(p, "Auto Sell", "Sell all non-favorited fish on timer", "autoSell", 2)
    makeSlider(p, "Sell Interval (s)", "sellDelay", 10, 300, 5, 3)
    makeSeparator(p, 4)
    makeSection(p, "MANUAL", 5)
    makeButton(p, "Sell All Now", function()
        if eventsLoaded and Events.sell then
            Events.sell:InvokeServer()
        end
    end, 6)
end

-- ======================== TELEPORT PAGE ========================
do
    local p = pages["Teleport"]
    makeSection(p, "ISLANDS", 1)
    for i, loc in ipairs(LOCATIONS) do
        makeButton(p, loc[1], function()
            local char = LP.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            -- Direct CFrame teleport (same as working script)
            hrp.CFrame = loc[2]
        end, i + 1)
    end
end

-- ======================== MOVEMENT PAGE ========================
do
    local p = pages["Movement"]
    makeSection(p, "SPEED", 1)
    makeSlider(p, "Walk Speed", "walkSpeed", 16, 200, 1, 2)
    makeSlider(p, "Jump Power", "jumpPower", 50, 300, 5, 3)
    makeSeparator(p, 4)
    makeSection(p, "ABILITIES", 5)
    makeToggle(p, "Infinite Jump", "Jump unlimited in air", "infJump", 6)
    makeToggle(p, "Character Fly", "Fly with WASD + Space/Shift", "fly", 7)
    makeToggle(p, "Noclip", "Walk through walls", "noclip", 8)
    makeToggle(p, "Anti Drown", "Resurface when underwater", "antiDrown", 9)
end

-- ======================== UTILITY PAGE ========================
do
    local p = pages["Utility"]
    makeSection(p, "PROTECTION", 1)
    makeToggle(p, "Anti-AFK", "Prevent idle kick", "antiAfk", 2)
    makeSeparator(p, 3)
    makeSection(p, "PERFORMANCE", 4)
    makeToggle(p, "GPU Saver", "Lower graphics, cap FPS to 8", "gpuSaver", 5)
    makeToggle(p, "FPS Boost", "Remove particles and effects", "fpsBoost", 6)
    makeSeparator(p, 7)
    makeSection(p, "SERVER", 8)
    makeButton(p, "Server Hop", function()
        local ok, data = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(
                "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            ))
        end)
        if ok and data and data.data then
            for _, s in ipairs(data.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, LP)
                    break
                end
            end
        end
    end, 9)
    makeButton(p, "Rejoin Server", function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
    end, 10)
end

-- ======================== VISUALS PAGE ========================
do
    local p = pages["Visuals"]
    makeSection(p, "ESP (Drawing API - Undetectable)", 1)
    makeToggle(p, "Fish ESP", "Show fish locations on screen", "fishEsp", 2)
    makeToggle(p, "Player ESP", "Show player names on screen", "playerEsp", 3)
end

-- ======================== SETTINGS PAGE ========================
do
    local p = pages["Settings"]
    makeSection(p, "CONFIG", 1)
    makeButton(p, "Save Config", function()
        if not writefile or not isfolder or not makefolder then return end
        if not isfolder("MoronFishIt") then makefolder("MoronFishIt") end
        writefile("MoronFishIt/config.json", HttpService:JSONEncode(CFG))
    end, 2)
    makeButton(p, "Load Config", function()
        if not readfile or not isfile then return end
        if isfile("MoronFishIt/config.json") then
            local data = HttpService:JSONDecode(readfile("MoronFishIt/config.json"))
            for k, v in pairs(data) do
                if CFG[k] ~= nil then CFG[k] = v end
            end
        end
    end, 3)
    makeSeparator(p, 4)
    makeSection(p, "INFO", 5)
    local info = Instance.new("TextLabel", p)
    info.Size = UDim2.new(1, -8, 0, 60)
    info.BackgroundTransparency = 1
    info.Text = "Moron Fish It v7.1\nby GasUp ID\nNo Key | No HWID | Free Forever\n\nToggle UI: Right Shift or Float Button"
    info.TextColor3 = Color3.fromRGB(100, 100, 115)
    info.TextSize = 10
    info.Font = Enum.Font.Gotham
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.LayoutOrder = 6
end

-- ====================================================================
-- TAB SWITCHING
-- ====================================================================
local function switchTab(tabName)
    currentTab = tabName
    for name, btn in pairs(tabBtns) do
        local active = (name == tabName)
        local ind = btn:FindFirstChild("ind")
        local lbl = btn:FindFirstChild("lbl")
        if ind then ind.Visible = active end
        if lbl then
            lbl.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(130, 130, 140)
            lbl.Font = active and Enum.Font.GothamBold or Enum.Font.Gotham
        end
    end
    for name, page in pairs(pages) do
        page.Visible = (name == tabName)
    end
    content.CanvasPosition = Vector2.new(0, 0)
end

for name, btn in pairs(tabBtns) do
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end
switchTab("Fishing")

-- ====================================================================
-- DRAGGING
-- ====================================================================
local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ====================================================================
-- FLOATING BUTTON (when UI hidden)
-- ====================================================================
local floatBtn = Instance.new("TextButton", gui)
floatBtn.Size = UDim2.new(0, 36, 0, 36)
floatBtn.Position = UDim2.new(0, 8, 0.5, -18)
floatBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
floatBtn.BorderSizePixel = 0
floatBtn.Text = "M"
floatBtn.TextColor3 = Color3.fromRGB(0, 200, 130)
floatBtn.TextSize = 16
floatBtn.Font = Enum.Font.GothamBold
floatBtn.Visible = false
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(0, 8)

-- Float button dragging
local fDrag, fDragStart, fStartPos
floatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        fDrag = true
        fDragStart = input.Position
        fStartPos = floatBtn.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if fDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - fDragStart
        floatBtn.Position = UDim2.new(fStartPos.X.Scale, fStartPos.X.Offset + d.X, fStartPos.Y.Scale, fStartPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        fDrag = false
    end
end)

-- ====================================================================
-- SHOW / HIDE TOGGLE
-- ====================================================================
local uiVisible = true
local function toggleUI()
    uiVisible = not uiVisible
    main.Visible = uiVisible
    floatBtn.Visible = not uiVisible
end

closeBtn.MouseButton1Click:Connect(toggleUI)
floatBtn.MouseButton1Click:Connect(toggleUI)
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then toggleUI() end
end)

-- ====================================================================
-- ====================================================================
--                    FEATURE IMPLEMENTATIONS
-- ====================================================================
-- ====================================================================

-- ======================== FISHING SYSTEM ========================
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
    pcall(function()
        Events.fishing:FireServer()
    end)
end

-- Normal fishing loop
local function normalFishingLoop()
    while fishingActive and not CFG.blatant do
        if not isFishing then
            isFishing = true
            castRod()
            task.wait(rnd(CFG.fishDelay * 0.9, CFG.fishDelay * 1.1))
            reelIn()
            task.wait(rnd(CFG.catchDelay * 0.9, CFG.catchDelay * 1.1))
            isFishing = false
        else
            task.wait(0.1)
        end
    end
end

-- Blatant fishing loop (2x parallel casts, spam reel)
local function blatantFishingLoop()
    while fishingActive and CFG.blatant do
        if not isFishing then
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
            task.wait(CFG.fishDelay)
            for i = 1, 5 do
                pcall(function() Events.fishing:FireServer() end)
                task.wait(0.01)
            end
            task.wait(CFG.catchDelay * 0.5)
            isFishing = false
        else
            task.wait(0.01)
        end
    end
end

-- Auto Fish controller
task.spawn(function()
    while task.wait(0.2) do
        if CFG.autoFish and not fishingActive then
            fishingActive = true
            task.spawn(function()
                while CFG.autoFish do
                    if CFG.blatant then
                        blatantFishingLoop()
                    else
                        normalFishingLoop()
                    end
                    task.wait(0.1)
                end
                fishingActive = false
                pcall(function()
                    if eventsLoaded and Events.unequip then Events.unequip:FireServer() end
                end)
            end)
        elseif not CFG.autoFish and fishingActive then
            fishingActive = false
        end
    end
end)

-- ======================== AUTO CATCH ========================
task.spawn(function()
    while true do
        if CFG.autoCatch and not isFishing and eventsLoaded and Events.fishing then
            pcall(function() Events.fishing:FireServer() end)
        end
        task.wait(CFG.catchDelay)
    end
end)

-- ======================== AUTO SELL ========================
task.spawn(function()
    while true do
        task.wait(CFG.sellDelay)
        if CFG.autoSell and eventsLoaded and Events.sell then
            pcall(function() Events.sell:InvokeServer() end)
        end
    end
end)

-- ======================== AUTO FAVORITE ========================
local favoritedItems = {}
task.spawn(function()
    while true do
        task.wait(10)
        if CFG.autoFavorite and eventsLoaded and PlayerData and ItemUtility and Events.favorite then
            pcall(function()
                local targetValue = RarityTiers[CFG.favRarity] or 6
                if targetValue < 6 then targetValue = 6 end
                local items = PlayerData:GetExpect("Inventory").Items
                if not items then return end
                for _, item in ipairs(items) do
                    local data = ItemUtility:GetItemData(item.Id)
                    if data and data.Data then
                        local rarity = data.Data.Rarity or "Common"
                        local rv = RarityTiers[rarity] or 0
                        if rv >= targetValue and not favoritedItems[item.UUID] then
                            if not (item.Favorited == true) then
                                Events.favorite:FireServer(item.UUID)
                                favoritedItems[item.UUID] = true
                                task.wait(0.3)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ======================== MOVEMENT ========================
-- WalkSpeed / JumpPower
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local char = LP.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            if CFG.walkSpeed ~= 16 then hum.WalkSpeed = CFG.walkSpeed end
            if CFG.jumpPower ~= 50 then hum.JumpPower = CFG.jumpPower end
        end)
    end
end)

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    if CFG.infJump then
        pcall(function()
            local char = LP.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
end)

-- Noclip
RS.Stepped:Connect(function()
    if CFG.noclip then
        pcall(function()
            local char = LP.Character
            if not char then return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
    end
end)

-- Anti-Drown
task.spawn(function()
    while task.wait(0.5) do
        if CFG.antiDrown then
            pcall(function()
                local char = LP.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Position.Y < -5 then
                    hrp.CFrame = CFrame.new(hrp.Position.X, 10, hrp.Position.Z)
                end
            end)
        end
    end
end)

-- Fly
task.spawn(function()
    local flyBV, flyBG
    while task.wait(0.1) do
        pcall(function()
            local char = LP.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if CFG.fly then
                if not flyBV then
                    flyBV = Instance.new("BodyVelocity", hrp)
                    flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    flyBV.Velocity = Vector3.new(0, 0, 0)
                    flyBG = Instance.new("BodyGyro", hrp)
                    flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                end
                local cam = workspace.CurrentCamera
                local dir = Vector3.new(0, 0, 0)
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                flyBV.Velocity = dir * 60
                flyBG.CFrame = cam.CFrame
            else
                if flyBV then flyBV:Destroy() flyBV = nil end
                if flyBG then flyBG:Destroy() flyBG = nil end
            end
        end)
    end
end)

-- ======================== UTILITY ========================
-- Anti-AFK
LP.Idled:Connect(function()
    if CFG.antiAfk then
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end
end)

-- GPU Saver
local gpuActive = false
task.spawn(function()
    while task.wait(2) do
        if CFG.gpuSaver and not gpuActive then
            gpuActive = true
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                game.Lighting.GlobalShadows = false
                game.Lighting.FogEnd = 1
                if setfpscap then setfpscap(8) end
            end)
        elseif not CFG.gpuSaver and gpuActive then
            gpuActive = false
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
                game.Lighting.GlobalShadows = true
                game.Lighting.FogEnd = 100000
                if setfpscap then setfpscap(0) end
            end)
        end
    end
end)

-- FPS Boost
task.spawn(function()
    while task.wait(10) do
        if CFG.fpsBoost then
            pcall(function()
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                        v.Enabled = false
                    end
                end
            end)
        end
    end
end)

-- ======================== VISUALS (Drawing API - Undetectable) ========================
-- Fish ESP using Drawing API
task.spawn(function()
    local drawings = {}
    while task.wait(1) do
        -- Clear old drawings
        for _, d in ipairs(drawings) do
            pcall(function() d:Remove() end)
        end
        drawings = {}

        if CFG.fishEsp then
            pcall(function()
                local cam = workspace.CurrentCamera
                local fishFolder = workspace:FindFirstChild("Fish") or workspace:FindFirstChild("Fishes") or workspace:FindFirstChild("FishModels")
                if not fishFolder then return end
                for _, fish in ipairs(fishFolder:GetChildren()) do
                    local part = nil
                    if fish:IsA("Model") then
                        part = fish.PrimaryPart or fish:FindFirstChildWhichIsA("BasePart")
                    elseif fish:IsA("BasePart") then
                        part = fish
                    end
                    if part then
                        local pos, onScreen = cam:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local txt = Drawing.new("Text")
                            txt.Text = fish.Name
                            txt.Position = Vector2.new(pos.X, pos.Y)
                            txt.Size = 13
                            txt.Color = Color3.fromRGB(0, 255, 180)
                            txt.Center = true
                            txt.Outline = true
                            txt.Visible = true
                            table.insert(drawings, txt)
                        end
                    end
                end
            end)
        end
    end
end)

-- Player ESP using Drawing API
task.spawn(function()
    local drawings = {}
    while task.wait(1) do
        for _, d in ipairs(drawings) do
            pcall(function() d:Remove() end)
        end
        drawings = {}

        if CFG.playerEsp then
            pcall(function()
                local cam = workspace.CurrentCamera
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LP and plr.Character then
                        local head = plr.Character:FindFirstChild("Head")
                        if head then
                            local pos, onScreen = cam:WorldToViewportPoint(head.Position)
                            if onScreen then
                                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                                local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                                local dist = ""
                                if hrp and myHrp then
                                    dist = " [" .. math.floor((hrp.Position - myHrp.Position).Magnitude) .. "m]"
                                end
                                local txt = Drawing.new("Text")
                                txt.Text = plr.Name .. dist
                                txt.Position = Vector2.new(pos.X, pos.Y - 20)
                                txt.Size = 13
                                txt.Color = Color3.fromRGB(255, 255, 100)
                                txt.Center = true
                                txt.Outline = true
                                txt.Visible = true
                                table.insert(drawings, txt)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

end) -- end task.delay for main UI
