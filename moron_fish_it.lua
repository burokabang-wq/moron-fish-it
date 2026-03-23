--[[
    Moron Fish It v3.0.0 - GasUp ID
    No Key | No HWID | Free Forever
    Anti-Cheat Bypass Included
]]

------------------------------------------------------
-- SECTION 0: ANTI-CHEAT BYPASS (MUST RUN FIRST)
------------------------------------------------------
local cloneref = cloneref or function(x) return x end

local Game = cloneref(game)
local Players = cloneref(Game:GetService("Players"))
local RS = cloneref(Game:GetService("ReplicatedStorage"))
local TweenService = cloneref(Game:GetService("TweenService"))
local UIS = cloneref(Game:GetService("UserInputService"))
local RunService = cloneref(Game:GetService("RunService"))
local StarterGui = cloneref(Game:GetService("StarterGui"))
local Workspace = cloneref(Game:GetService("Workspace"))
local Lighting = cloneref(Game:GetService("Lighting"))
local HttpService = cloneref(Game:GetService("HttpService"))
local TeleportService = cloneref(Game:GetService("TeleportService"))
local VIM
pcall(function() VIM = cloneref(Game:GetService("VirtualInputManager")) end)

local LP = Players.LocalPlayer

-- Anti-Kick: Hook __index
pcall(function()
    if hookmetamethod then
        local oldIdx
        oldIdx = hookmetamethod(Game, "__index", newcclosure(function(self, key)
            if self == LP and type(key) == "string" and key:lower() == "kick" then
                return error("Expected ':' not '.' calling member function Kick", 2)
            end
            return oldIdx(self, key)
        end))
    end
end)

-- Anti-Kick: Hook __namecall
pcall(function()
    if hookmetamethod and getnamecallmethod then
        local oldNc
        oldNc = hookmetamethod(Game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if self == LP and method:lower() == "kick" then
                return
            end
            if method == "FireServer" or method == "InvokeServer" then
                local rn = ""
                pcall(function() rn = tostring(self.Name):lower() end)
                local bl = {"detect","cheat","kick","ban","anticheat","exploit","hack","flag","report","security","guard","monitor","watchdog","violation","suspicious"}
                for _, w in ipairs(bl) do
                    if rn:find(w) then return end
                end
                if type(args[1]) == "string" then
                    local al = args[1]:lower()
                    for _, w in ipairs(bl) do
                        if al:find(w) then return end
                    end
                end
            end
            return oldNc(self, ...)
        end))
    end
end)

-- Disable anti-cheat via getgc
pcall(function()
    if getgc then
        for _, v in pairs(getgc(true)) do
            pcall(function()
                if type(v) == "table" then
                    if rawget(v, "indexInstance") and type(rawget(v, "indexInstance")) == "table" and rawget(v, "indexInstance")[1] == "kick" then
                        v.lvk = {"Kick", function() return Workspace:WaitForChild("") end}
                    end
                    for _, fn in ipairs({"Detected","detect","Kill","kill"}) do
                        if rawget(v, fn) and type(rawget(v, fn)) == "function" then
                            rawset(v, fn, function() end)
                        end
                    end
                end
            end)
        end
    end
end)

------------------------------------------------------
-- SECTION 1: UTILITIES
------------------------------------------------------
local _rng = Random.new(os.clock() * 1000 % 99999)
local function rName(len)
    local c = "abcdefghijklmnopqrstuvwxyz"
    local s = ""
    for i = 1, (len or 8) do
        local r = _rng:NextInteger(1, #c)
        s = s .. c:sub(r, r)
    end
    return s
end

local function rDelay(base, var)
    return base + (_rng:NextNumber() * (var or 0.3))
end

local function hWait(base)
    task.wait(base * (0.82 + _rng:NextNumber() * 0.36))
end

local function safeFire(remote, ...)
    if not remote then return end
    local a = {...}
    task.defer(function() pcall(function() remote:FireServer(unpack(a)) end) end)
end

local function safeInvoke(remote, ...)
    if not remote then return nil end
    local a = {...}
    local ok, res = pcall(function() return remote:InvokeServer(unpack(a)) end)
    return ok and res or nil
end

------------------------------------------------------
-- SECTION 2: CONFIGURATION
------------------------------------------------------
local Cfg = {
    AutoFish = false, AutoSell = false, AutoCatch = false,
    BlatantMode = false, InstantMode = false,
    FishDelay = 0.9, CatchDelay = 0.2, SellDelay = 30,
    AutoFavorite = true, FavoriteRarity = "Mythic",
    AutoBuyRod = false, AutoBuyWeather = false,
    AutoEnchant = false, AutoQuest = false, AutoEvent = false, AutoArtifact = false,
    WalkSpeed = 16, JumpPower = 50, InfJump = false, Fly = false, Noclip = false,
    AntiAFK = true, AntiDrown = false, GPUSaver = false, FPSBoost = false,
    FishESP = false, PlayerESP = false,
    WebhookURL = "", WebhookOn = false,
}

local CFG_DIR = "MoronFishIt"
local CFG_FILE = CFG_DIR .. "/cfg.json"

local function cfgSave()
    pcall(function()
        if not writefile then return end
        if isfolder and not isfolder(CFG_DIR) then makefolder(CFG_DIR) end
        writefile(CFG_FILE, HttpService:JSONEncode(Cfg))
    end)
end

local function cfgLoad()
    pcall(function()
        if not readfile or not isfile then return end
        if not isfile(CFG_FILE) then return end
        local d = HttpService:JSONDecode(readfile(CFG_FILE))
        for k, v in pairs(d) do if Cfg[k] ~= nil then Cfg[k] = v end end
    end)
end
cfgLoad()

------------------------------------------------------
-- SECTION 3: MAP & NPC LOCATIONS
------------------------------------------------------
local Islands = {
    {"Spawn", CFrame.new(45.27, 252.56, 2987.10)},
    {"Sisyphus Statue", CFrame.new(-3728.21, -135.07, -1012.12)},
    {"Coral Reefs", CFrame.new(-3114.78, 1.32, 2237.52)},
    {"Esoteric Depths", CFrame.new(3248.37, -1301.53, 1403.82)},
    {"Crater Island", CFrame.new(1016.49, 20.09, 5069.27)},
    {"Lost Isle", CFrame.new(-3618.15, 240.83, -1317.45)},
    {"Weather Machine", CFrame.new(-1488.51, 83.17, 1876.30)},
    {"Tropical Grove", CFrame.new(-2095.34, 197.19, 3718.08)},
    {"Mount Hallow", CFrame.new(2136.62, 78.91, 3272.50)},
    {"Treasure Room", CFrame.new(-3606.34, -266.57, -1580.97)},
    {"Kohana", CFrame.new(-663.90, 3.04, 718.79)},
    {"Underground Cellar", CFrame.new(2109.52, -94.18, -708.60)},
    {"Ancient Jungle", CFrame.new(1831.71, 6.62, -299.27)},
    {"Sacred Temple", CFrame.new(1466.92, -21.87, -622.83)},
    {"Crystal Cavern", CFrame.new(-2800.50, -180.25, 450.30)},
    {"Underwater City", CFrame.new(-1200.80, -350.60, -2100.40)},
    {"Forgotten Shore", CFrame.new(3500.20, 5.50, -1800.90)},
}

local NPCs = {
    {"Rod Shop", CFrame.new(52.10, 252.56, 2970.50)},
    {"Sell NPC", CFrame.new(-3725.00, -135.07, -1020.00)},
    {"Enchant NPC", CFrame.new(-3710.50, -135.07, -1005.80)},
    {"Quest NPC", CFrame.new(60.30, 252.56, 2995.20)},
    {"Weather NPC", CFrame.new(-1485.20, 83.17, 1880.50)},
    {"Boat Shop", CFrame.new(30.50, 252.56, 2960.80)},
}

------------------------------------------------------
-- SECTION 4: NETWORK EVENTS
------------------------------------------------------
local Ev = {}
pcall(function()
    local net = RS:WaitForChild("Packages", 5)
    if not net then return end
    net = net:FindFirstChild("_Index")
    if not net then return end
    net = net:FindFirstChild("sleitnick_net@0.2.0")
    if not net then return end
    net = net:FindFirstChild("net")
    if not net then return end
    local function sw(p, n) return p:FindFirstChild(n) or p:WaitForChild(n, 5) end
    Ev.fish = sw(net, "RE/FishingCompleted")
    Ev.sell = sw(net, "RF/SellAllItems")
    Ev.charge = sw(net, "RF/ChargeFishingRod")
    Ev.mini = sw(net, "RF/RequestFishingMinigameStarted")
    Ev.cancel = sw(net, "RF/CancelFishingInputs")
    Ev.equip = sw(net, "RE/EquipToolFromHotbar")
    Ev.unequip = sw(net, "RE/UnequipToolFromHotbar")
    Ev.fav = sw(net, "RE/FavoriteItem")
end)

------------------------------------------------------
-- SECTION 5: GAME MODULES
------------------------------------------------------
local ItemUtil, Replion, PData
pcall(function()
    local shared = RS:FindFirstChild("Shared")
    if shared then
        local iu = shared:FindFirstChild("ItemUtility")
        if iu then ItemUtil = require(iu) end
    end
end)
pcall(function()
    local pkgs = RS:FindFirstChild("Packages")
    if pkgs then
        local rep = pkgs:FindFirstChild("Replion")
        if rep then
            Replion = require(rep)
            PData = Replion.Client:WaitReplion("Data")
        end
    end
end)

local Rarity = {Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5, Mythic = 6, Secret = 7}

------------------------------------------------------
-- SECTION 6: CORE FUNCTIONS
------------------------------------------------------
local function notify(t, m, d)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = t or "MFI", Text = m or "", Duration = d or 4})
    end)
end

local function smoothTP(cf)
    local ch = LP.Character
    if not ch then return false end
    local r = ch:FindFirstChild("HumanoidRootPart")
    if not r then return false end
    local dist = (r.Position - cf.Position).Magnitude
    if dist < 400 then
        hWait(0.08)
        r.CFrame = cf
    else
        local steps = math.clamp(math.floor(dist / 250), 2, 6)
        for i = 1, steps do
            r.CFrame = r.CFrame:Lerp(cf, i / steps)
            hWait(0.04)
        end
    end
    return true
end

local function sendWebhook(title, desc, col)
    if not Cfg.WebhookOn or Cfg.WebhookURL == "" then return end
    task.spawn(function()
        pcall(function()
            local body = HttpService:JSONEncode({
                embeds = {{title = title, description = desc, color = col or 3066993,
                    footer = {text = "Moron Fish It v3.0 | " .. os.date("%H:%M:%S")}}}
            })
            local rf = (syn and syn.request) or (http and http.request) or request or http_request or (fluxus and fluxus.request)
            if rf then rf({Url = Cfg.WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = body}) end
        end)
    end)
end

------------------------------------------------------
-- SECTION 7: CLEANUP OLD GUI
------------------------------------------------------
pcall(function()
    local pg = LP:FindFirstChild("PlayerGui")
    if pg then
        for _, g in ipairs(pg:GetChildren()) do
            if g:IsA("ScreenGui") and g:GetAttribute("_mfi") then g:Destroy() end
        end
    end
end)

------------------------------------------------------
-- SECTION 8: GUI PARENT
------------------------------------------------------
local guiParent
pcall(function()
    if gethui then
        guiParent = gethui()
    else
        guiParent = LP:WaitForChild("PlayerGui", 10)
    end
end)
if not guiParent then
    guiParent = LP:FindFirstChild("PlayerGui") or Game:GetService("CoreGui")
end

------------------------------------------------------
-- SECTION 9: SPLASH SCREEN
------------------------------------------------------
local splashGui = Instance.new("ScreenGui")
splashGui.Name = rName(10)
splashGui:SetAttribute("_mfi", true)
splashGui.ResetOnSpawn = false
splashGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
splashGui.DisplayOrder = 999
splashGui.Parent = guiParent

local splashFrame = Instance.new("Frame")
splashFrame.Parent = splashGui
splashFrame.AnchorPoint = Vector2.new(0.5, 0.5)
splashFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
splashFrame.Size = UDim2.new(0, 220, 0, 80)
splashFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
splashFrame.BorderSizePixel = 0
splashFrame.BackgroundTransparency = 1
Instance.new("UICorner", splashFrame).CornerRadius = UDim.new(0, 10)

local splashTitle = Instance.new("TextLabel")
splashTitle.Parent = splashFrame
splashTitle.Size = UDim2.new(1, 0, 0.55, 0)
splashTitle.Position = UDim2.new(0, 0, 0, 8)
splashTitle.BackgroundTransparency = 1
splashTitle.Text = "GasUp ID"
splashTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
splashTitle.Font = Enum.Font.GothamBold
splashTitle.TextSize = 22
splashTitle.TextTransparency = 1

local splashSub = Instance.new("TextLabel")
splashSub.Parent = splashFrame
splashSub.Size = UDim2.new(1, 0, 0.25, 0)
splashSub.Position = UDim2.new(0, 0, 0.5, 0)
splashSub.BackgroundTransparency = 1
splashSub.Text = "Moron Fish It v3.0"
splashSub.TextColor3 = Color3.fromRGB(120, 120, 130)
splashSub.Font = Enum.Font.Gotham
splashSub.TextSize = 11
splashSub.TextTransparency = 1

local loadBg = Instance.new("Frame")
loadBg.Parent = splashFrame
loadBg.Size = UDim2.new(0.6, 0, 0, 2)
loadBg.Position = UDim2.new(0.2, 0, 0.85, 0)
loadBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
loadBg.BorderSizePixel = 0
loadBg.BackgroundTransparency = 1
Instance.new("UICorner", loadBg).CornerRadius = UDim.new(1, 0)

local loadFill = Instance.new("Frame")
loadFill.Parent = loadBg
loadFill.Size = UDim2.new(0, 0, 1, 0)
loadFill.BackgroundColor3 = Color3.fromRGB(100, 200, 130)
loadFill.BorderSizePixel = 0
loadFill.BackgroundTransparency = 1
Instance.new("UICorner", loadFill).CornerRadius = UDim.new(1, 0)

task.spawn(function()
    TweenService:Create(splashFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    task.wait(0.1)
    TweenService:Create(splashTitle, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    task.wait(0.1)
    TweenService:Create(splashSub, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
    task.wait(0.08)
    TweenService:Create(loadBg, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    TweenService:Create(loadFill, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    task.wait(0.08)
    TweenService:Create(loadFill, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(1.8)
    TweenService:Create(splashFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(splashTitle, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
    TweenService:Create(splashSub, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
    TweenService:Create(loadBg, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    TweenService:Create(loadFill, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    task.wait(0.4)
    splashGui:Destroy()
end)

task.wait(2.5)

------------------------------------------------------
-- SECTION 10: MAIN UI
------------------------------------------------------
local MF = Instance.new("ScreenGui")
MF.Name = rName(12)
MF:SetAttribute("_mfi", true)
MF.ResetOnSpawn = false
MF.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MF.DisplayOrder = 100
MF.Parent = guiParent

local C = {
    bg = Color3.fromRGB(18, 18, 24),
    sidebar = Color3.fromRGB(13, 13, 17),
    card = Color3.fromRGB(25, 25, 32),
    text = Color3.fromRGB(215, 215, 220),
    dim = Color3.fromRGB(100, 100, 110),
    accent = Color3.fromRGB(100, 200, 130),
    off = Color3.fromRGB(45, 45, 55),
    border = Color3.fromRGB(32, 32, 42),
    slider = Color3.fromRGB(55, 55, 68),
}

local mainFrame = Instance.new("Frame")
mainFrame.Parent = MF
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.Size = UDim2.new(0, 500, 0, 320)
mainFrame.BackgroundColor3 = C.bg
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Parent = mainFrame
sidebar.Size = UDim2.new(0, 120, 1, 0)
sidebar.BackgroundColor3 = C.sidebar
sidebar.BorderSizePixel = 0

local sbCornerFix = Instance.new("Frame")
sbCornerFix.Parent = sidebar
sbCornerFix.Size = UDim2.new(0, 10, 1, 0)
sbCornerFix.Position = UDim2.new(1, -10, 0, 0)
sbCornerFix.BackgroundColor3 = C.sidebar
sbCornerFix.BorderSizePixel = 0

Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

-- Logo
local logoLabel = Instance.new("TextLabel")
logoLabel.Parent = sidebar
logoLabel.Size = UDim2.new(1, 0, 0, 22)
logoLabel.Position = UDim2.new(0, 0, 0, 10)
logoLabel.BackgroundTransparency = 1
logoLabel.Text = "MORON"
logoLabel.TextColor3 = C.text
logoLabel.Font = Enum.Font.GothamBold
logoLabel.TextSize = 14

local logoSub = Instance.new("TextLabel")
logoSub.Parent = sidebar
logoSub.Size = UDim2.new(1, 0, 0, 12)
logoSub.Position = UDim2.new(0, 0, 0, 30)
logoSub.BackgroundTransparency = 1
logoSub.Text = "Fish It v3.0"
logoSub.TextColor3 = C.dim
logoSub.Font = Enum.Font.Gotham
logoSub.TextSize = 9

local divLine = Instance.new("Frame")
divLine.Parent = sidebar
divLine.Size = UDim2.new(0.75, 0, 0, 1)
divLine.Position = UDim2.new(0.125, 0, 0, 46)
divLine.BackgroundColor3 = C.border
divLine.BorderSizePixel = 0

-- Content area
local contentArea = Instance.new("Frame")
contentArea.Parent = mainFrame
contentArea.Size = UDim2.new(1, -124, 1, -4)
contentArea.Position = UDim2.new(0, 122, 0, 2)
contentArea.BackgroundTransparency = 1
contentArea.ClipsDescendants = true

local pageTitle = Instance.new("TextLabel")
pageTitle.Parent = contentArea
pageTitle.Size = UDim2.new(1, -10, 0, 22)
pageTitle.Position = UDim2.new(0, 5, 0, 4)
pageTitle.BackgroundTransparency = 1
pageTitle.Text = "Fishing"
pageTitle.TextColor3 = C.text
pageTitle.Font = Enum.Font.GothamBold
pageTitle.TextSize = 14
pageTitle.TextXAlignment = Enum.TextXAlignment.Left

local pageDesc = Instance.new("TextLabel")
pageDesc.Parent = contentArea
pageDesc.Size = UDim2.new(1, -10, 0, 14)
pageDesc.Position = UDim2.new(0, 5, 0, 24)
pageDesc.BackgroundTransparency = 1
pageDesc.Text = "Configure automatic fishing"
pageDesc.TextColor3 = C.dim
pageDesc.Font = Enum.Font.Gotham
pageDesc.TextSize = 10
pageDesc.TextXAlignment = Enum.TextXAlignment.Left

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = mainFrame
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -28, 0, 4)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "x"
closeBtn.TextColor3 = C.dim
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.ZIndex = 10
closeBtn.MouseButton1Click:Connect(function() MF.Enabled = false end)

------------------------------------------------------
-- SECTION 11: UI BUILDERS
------------------------------------------------------
local pages = {}
local currentPage = nil
local tabBtns = {}

local function mkScroll(parent)
    local s = Instance.new("ScrollingFrame")
    s.Parent = parent
    s.Size = UDim2.new(1, -4, 1, -44)
    s.Position = UDim2.new(0, 0, 0, 44)
    s.BackgroundTransparency = 1
    s.BorderSizePixel = 0
    s.ScrollBarThickness = 2
    s.ScrollBarImageColor3 = C.border
    s.CanvasSize = UDim2.new(0, 0, 0, 0)
    s.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local l = Instance.new("UIListLayout", s)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, 3)
    local p = Instance.new("UIPadding", s)
    p.PaddingLeft = UDim.new(0, 4)
    p.PaddingRight = UDim.new(0, 6)
    p.PaddingTop = UDim.new(0, 2)
    return s
end

local function mkPage(name, desc)
    local s = mkScroll(contentArea)
    s.Visible = false
    pages[name] = {scroll = s, desc = desc}
    return s
end

local function showPage(name)
    for n, p in pairs(pages) do p.scroll.Visible = (n == name) end
    pageTitle.Text = name
    pageDesc.Text = pages[name].desc or ""
    currentPage = name
    for _, b in pairs(tabBtns) do
        if b.pn == name then
            b.BackgroundTransparency = 0
            b.BackgroundColor3 = C.card
            b.lbl.TextColor3 = C.text
        else
            b.BackgroundTransparency = 1
            b.lbl.TextColor3 = C.dim
        end
    end
end

local function mkTab(name, icon, order)
    local btn = Instance.new("TextButton")
    btn.Parent = sidebar
    btn.Size = UDim2.new(0.88, 0, 0, 26)
    btn.Position = UDim2.new(0.06, 0, 0, 52 + (order * 29))
    btn.BackgroundColor3 = C.card
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.pn = name

    local ic = Instance.new("TextLabel", btn)
    ic.Size = UDim2.new(0, 20, 1, 0)
    ic.Position = UDim2.new(0, 5, 0, 0)
    ic.BackgroundTransparency = 1
    ic.Text = icon
    ic.TextColor3 = C.dim
    ic.Font = Enum.Font.Gotham
    ic.TextSize = 11

    local lb = Instance.new("TextLabel", btn)
    lb.Size = UDim2.new(1, -28, 1, 0)
    lb.Position = UDim2.new(0, 26, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = name
    lb.TextColor3 = C.dim
    lb.Font = Enum.Font.GothamMedium
    lb.TextSize = 11
    lb.TextXAlignment = Enum.TextXAlignment.Left
    btn.lbl = lb

    btn.MouseButton1Click:Connect(function() showPage(name) end)
    table.insert(tabBtns, btn)
    return btn
end

local function addHeader(parent, text, order)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 18)
    f.BackgroundTransparency = 1
    f.LayoutOrder = order
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = text:upper()
    l.TextColor3 = C.dim
    l.Font = Enum.Font.GothamBold
    l.TextSize = 9
    l.TextXAlignment = Enum.TextXAlignment.Left
end

local function addToggle(parent, text, desc, default, order, cb)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 36)
    f.BackgroundColor3 = C.card
    f.BorderSizePixel = 0
    f.LayoutOrder = order
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)

    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(0.65, 0, 0, 16)
    t.Position = UDim2.new(0, 8, 0, 3)
    t.BackgroundTransparency = 1
    t.Text = text
    t.TextColor3 = C.text
    t.Font = Enum.Font.GothamMedium
    t.TextSize = 11
    t.TextXAlignment = Enum.TextXAlignment.Left

    if desc and desc ~= "" then
        local d = Instance.new("TextLabel", f)
        d.Size = UDim2.new(0.65, 0, 0, 10)
        d.Position = UDim2.new(0, 8, 0, 20)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = C.dim
        d.Font = Enum.Font.Gotham
        d.TextSize = 8
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.TextTruncate = Enum.TextTruncate.AtEnd
    end

    local bg = Instance.new("Frame", f)
    bg.Size = UDim2.new(0, 32, 0, 16)
    bg.Position = UDim2.new(1, -42, 0.5, -8)
    bg.BackgroundColor3 = default and C.accent or C.off
    bg.BorderSizePixel = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local kn = Instance.new("Frame", bg)
    kn.Size = UDim2.new(0, 12, 0, 12)
    kn.Position = default and UDim2.new(1, -14, 0, 2) or UDim2.new(0, 2, 0, 2)
    kn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    kn.BorderSizePixel = 0
    Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)

    local en = default
    local click = Instance.new("TextButton", f)
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.ZIndex = 5
    click.MouseButton1Click:Connect(function()
        en = not en
        TweenService:Create(bg, TweenInfo.new(0.15), {BackgroundColor3 = en and C.accent or C.off}):Play()
        TweenService:Create(kn, TweenInfo.new(0.15), {Position = en and UDim2.new(1, -14, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
        if cb then cb(en) end
    end)
end

local function addSlider(parent, text, min, max, default, order, cb)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 40)
    f.BackgroundColor3 = C.card
    f.BorderSizePixel = 0
    f.LayoutOrder = order
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)

    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(0.55, 0, 0, 14)
    t.Position = UDim2.new(0, 8, 0, 3)
    t.BackgroundTransparency = 1
    t.Text = text
    t.TextColor3 = C.text
    t.Font = Enum.Font.GothamMedium
    t.TextSize = 10
    t.TextXAlignment = Enum.TextXAlignment.Left

    local vl = Instance.new("TextLabel", f)
    vl.Size = UDim2.new(0, 36, 0, 14)
    vl.Position = UDim2.new(1, -44, 0, 3)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(default)
    vl.TextColor3 = C.accent
    vl.Font = Enum.Font.GothamMedium
    vl.TextSize = 10
    vl.TextXAlignment = Enum.TextXAlignment.Right

    local sbg = Instance.new("Frame", f)
    sbg.Size = UDim2.new(1, -20, 0, 3)
    sbg.Position = UDim2.new(0, 10, 0, 26)
    sbg.BackgroundColor3 = C.slider
    sbg.BorderSizePixel = 0
    Instance.new("UICorner", sbg).CornerRadius = UDim.new(1, 0)

    local pct = (default - min) / (max - min)
    local sf = Instance.new("Frame", sbg)
    sf.Size = UDim2.new(pct, 0, 1, 0)
    sf.BackgroundColor3 = C.accent
    sf.BorderSizePixel = 0
    Instance.new("UICorner", sf).CornerRadius = UDim.new(1, 0)

    local sb = Instance.new("TextButton", f)
    sb.Size = UDim2.new(1, -16, 0, 18)
    sb.Position = UDim2.new(0, 8, 0, 18)
    sb.BackgroundTransparency = 1
    sb.Text = ""
    sb.ZIndex = 5

    local dragging = false
    sb.MouseButton1Down:Connect(function() dragging = true end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((inp.Position.X - sbg.AbsolutePosition.X) / sbg.AbsoluteSize.X, 0, 1)
            sf.Size = UDim2.new(rel, 0, 1, 0)
            local val = min + (max - min) * rel
            if max <= 5 then val = math.floor(val * 10) / 10 else val = math.floor(val) end
            vl.Text = tostring(val)
            if cb then cb(val) end
        end
    end)
end

local function addButton(parent, text, desc, order, cb)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 32)
    f.BackgroundColor3 = C.card
    f.BorderSizePixel = 0
    f.LayoutOrder = order
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)

    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(0.7, 0, 0, 14)
    t.Position = UDim2.new(0, 8, 0, 3)
    t.BackgroundTransparency = 1
    t.Text = text
    t.TextColor3 = C.text
    t.Font = Enum.Font.GothamMedium
    t.TextSize = 11
    t.TextXAlignment = Enum.TextXAlignment.Left

    if desc and desc ~= "" then
        local d = Instance.new("TextLabel", f)
        d.Size = UDim2.new(0.7, 0, 0, 10)
        d.Position = UDim2.new(0, 8, 0, 17)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = C.dim
        d.Font = Enum.Font.Gotham
        d.TextSize = 8
        d.TextXAlignment = Enum.TextXAlignment.Left
    end

    local ar = Instance.new("TextLabel", f)
    ar.Size = UDim2.new(0, 16, 1, 0)
    ar.Position = UDim2.new(1, -22, 0, 0)
    ar.BackgroundTransparency = 1
    ar.Text = ">"
    ar.TextColor3 = C.dim
    ar.Font = Enum.Font.GothamBold
    ar.TextSize = 12

    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 5
    btn.MouseButton1Click:Connect(function() if cb then cb() end end)
end

local function addDropdown(parent, text, opts, default, order, cb)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 32)
    f.BackgroundColor3 = C.card
    f.BorderSizePixel = 0
    f.LayoutOrder = order
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)

    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(0.5, 0, 1, 0)
    t.Position = UDim2.new(0, 8, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = text
    t.TextColor3 = C.text
    t.Font = Enum.Font.GothamMedium
    t.TextSize = 11
    t.TextXAlignment = Enum.TextXAlignment.Left

    local sel = default or opts[1]
    local sb = Instance.new("TextButton", f)
    sb.Size = UDim2.new(0, 90, 0, 20)
    sb.Position = UDim2.new(1, -100, 0.5, -10)
    sb.BackgroundColor3 = C.slider
    sb.BorderSizePixel = 0
    sb.Text = sel
    sb.TextColor3 = C.accent
    sb.Font = Enum.Font.GothamMedium
    sb.TextSize = 10
    sb.AutoButtonColor = false
    Instance.new("UICorner", sb).CornerRadius = UDim.new(0, 4)

    local idx = 1
    for i, v in ipairs(opts) do if v == default then idx = i end end
    sb.MouseButton1Click:Connect(function()
        idx = idx % #opts + 1
        sel = opts[idx]
        sb.Text = sel
        if cb then cb(sel) end
    end)
end

------------------------------------------------------
-- SECTION 12: BUILD PAGES
------------------------------------------------------

-- Fishing
local fp = mkPage("Fishing", "Configure automatic fishing")
addHeader(fp, "Fishing Mode", 1)
addToggle(fp, "Auto Fish", "Automatically cast and reel", Cfg.AutoFish, 2, function(v) Cfg.AutoFish = v end)
addToggle(fp, "Blatant Mode", "Fast fishing, less natural", Cfg.BlatantMode, 3, function(v) Cfg.BlatantMode = v end)
addToggle(fp, "Instant Mode", "Maximum speed fishing", Cfg.InstantMode, 4, function(v) Cfg.InstantMode = v end)
addToggle(fp, "Auto Catch", "Auto catch when fish bites", Cfg.AutoCatch, 5, function(v) Cfg.AutoCatch = v end)
addHeader(fp, "Timing", 6)
addSlider(fp, "Fish Delay", 0.1, 3.0, Cfg.FishDelay, 7, function(v) Cfg.FishDelay = v end)
addSlider(fp, "Catch Delay", 0.1, 2.0, Cfg.CatchDelay, 8, function(v) Cfg.CatchDelay = v end)
addHeader(fp, "Automation", 9)
addToggle(fp, "Auto Enchant", "Enchant rods automatically", Cfg.AutoEnchant, 10, function(v) Cfg.AutoEnchant = v end)
addToggle(fp, "Auto Buy Rod", "Buy best available rod", Cfg.AutoBuyRod, 11, function(v) Cfg.AutoBuyRod = v end)
addToggle(fp, "Auto Buy Weather", "Purchase weather items", Cfg.AutoBuyWeather, 12, function(v) Cfg.AutoBuyWeather = v end)
addToggle(fp, "Auto Quest", "Complete quests auto", Cfg.AutoQuest, 13, function(v) Cfg.AutoQuest = v end)
addToggle(fp, "Auto Event", "Auto teleport to events", Cfg.AutoEvent, 14, function(v) Cfg.AutoEvent = v end)
addToggle(fp, "Auto Artifact", "Collect artifacts auto", Cfg.AutoArtifact, 15, function(v) Cfg.AutoArtifact = v end)

-- Selling
local sp = mkPage("Selling", "Auto sell and favorite management")
addHeader(sp, "Sell Settings", 1)
addToggle(sp, "Auto Sell", "Sell fish on timer", Cfg.AutoSell, 2, function(v) Cfg.AutoSell = v end)
addSlider(sp, "Sell Timer (sec)", 10, 300, Cfg.SellDelay, 3, function(v) Cfg.SellDelay = v end)
addButton(sp, "Sell All Now", "Sell all non-favorite fish", 4, function()
    pcall(function() if Ev.sell then safeInvoke(Ev.sell) end end)
end)
addHeader(sp, "Favorites", 5)
addToggle(sp, "Auto Favorite", "Favorite fish by rarity", Cfg.AutoFavorite, 6, function(v) Cfg.AutoFavorite = v end)
addDropdown(sp, "Min Rarity", {"Common","Uncommon","Rare","Epic","Legendary","Mythic","Secret"}, Cfg.FavoriteRarity, 7, function(v) Cfg.FavoriteRarity = v end)

-- Teleport
local tp = mkPage("Teleport", "Teleport to islands and NPCs")
addHeader(tp, "Islands", 1)
for i, data in ipairs(Islands) do
    addButton(tp, data[1], "", i + 1, function() smoothTP(data[2]) notify("TP", data[1]) end)
end
addHeader(tp, "NPCs", #Islands + 2)
for i, data in ipairs(NPCs) do
    addButton(tp, data[1], "", #Islands + 2 + i, function() smoothTP(data[2]) notify("TP", data[1]) end)
end

-- Movement
local mp = mkPage("Movement", "Speed, jump, fly and noclip")
addHeader(mp, "Speed & Jump", 1)
addSlider(mp, "Walk Speed", 16, 200, Cfg.WalkSpeed, 2, function(v)
    Cfg.WalkSpeed = v
    pcall(function() local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = v end end)
end)
addSlider(mp, "Jump Power", 50, 300, Cfg.JumpPower, 3, function(v)
    Cfg.JumpPower = v
    pcall(function() local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") if h then h.JumpPower = v end end)
end)
addHeader(mp, "Movement Hacks", 4)
addToggle(mp, "Infinite Jump", "Jump unlimited in air", Cfg.InfJump, 5, function(v) Cfg.InfJump = v end)
addToggle(mp, "Fly", "Fly freely", Cfg.Fly, 6, function(v) Cfg.Fly = v end)
addToggle(mp, "Noclip", "Walk through walls", Cfg.Noclip, 7, function(v) Cfg.Noclip = v end)

-- Utility
local up = mkPage("Utility", "Anti-AFK, performance, server tools")
addHeader(up, "Protection", 1)
addToggle(up, "Anti-AFK", "Prevent idle kick", Cfg.AntiAFK, 2, function(v) Cfg.AntiAFK = v end)
addToggle(up, "Anti-Drown", "Prevent drowning", Cfg.AntiDrown, 3, function(v) Cfg.AntiDrown = v end)
addHeader(up, "Performance", 4)
addToggle(up, "GPU Saver", "Reduce graphics load", Cfg.GPUSaver, 5, function(v)
    Cfg.GPUSaver = v
    pcall(function()
        if v then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            for _, o in pairs(Workspace:GetDescendants()) do
                if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") then o.Enabled = false end
            end
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
    end)
end)
addToggle(up, "FPS Boost", "Disable shadows/effects", Cfg.FPSBoost, 6, function(v)
    Cfg.FPSBoost = v
    pcall(function()
        if v then Lighting.GlobalShadows = false; Lighting.FogEnd = 99999 else Lighting.GlobalShadows = true end
    end)
end)
addHeader(up, "Server", 7)
addButton(up, "Server Hop", "Join different server", 8, function()
    pcall(function()
        local s = HttpService:JSONDecode(Game:HttpGet("https://games.roblox.com/v1/games/" .. Game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, sv in pairs(s.data) do
            if sv.playing < sv.maxPlayers and sv.id ~= Game.JobId then
                TeleportService:TeleportToPlaceInstance(Game.PlaceId, sv.id, LP)
                break
            end
        end
    end)
end)
addButton(up, "Rejoin", "Reconnect to server", 9, function()
    pcall(function() TeleportService:Teleport(Game.PlaceId, LP) end)
end)

-- Visuals
local vp = mkPage("Visuals", "ESP and visual enhancements")
addHeader(vp, "ESP", 1)
addToggle(vp, "Fish ESP", "Highlight fish locations", Cfg.FishESP, 2, function(v) Cfg.FishESP = v end)
addToggle(vp, "Player ESP", "Show other players", Cfg.PlayerESP, 3, function(v) Cfg.PlayerESP = v end)

-- Settings
local stp = mkPage("Settings", "Configuration and info")
addHeader(stp, "Config", 1)
addButton(stp, "Save Config", "Save current settings", 2, function() cfgSave() notify("Config", "Saved!") end)
addButton(stp, "Load Config", "Load saved settings", 3, function() cfgLoad() notify("Config", "Loaded! Re-execute to apply") end)
addHeader(stp, "Info", 4)
addButton(stp, "GasUp ID", "Script by GasUp ID", 5, function() end)
addButton(stp, "v3.0.0 Anti-Cheat", "Moron Fish It - Bypass Edition", 6, function() end)

------------------------------------------------------
-- SECTION 13: SIDEBAR TABS
------------------------------------------------------
mkTab("Fishing", "F", 0)
mkTab("Selling", "$", 1)
mkTab("Teleport", "T", 2)
mkTab("Movement", "M", 3)
mkTab("Utility", "U", 4)
mkTab("Visuals", "V", 5)
mkTab("Settings", "S", 6)

showPage("Fishing")

------------------------------------------------------
-- SECTION 14: TOGGLE KEY
------------------------------------------------------
UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        MF.Enabled = not MF.Enabled
    end
end)

------------------------------------------------------
-- SECTION 15: CORE LOOPS
------------------------------------------------------

-- Anti-AFK
task.spawn(function()
    while true do
        task.wait(55 + math.random() * 10)
        if Cfg.AntiAFK then
            pcall(function()
                if VIM then
                    VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, Game)
                    task.wait(0.1)
                    VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, Game)
                end
            end)
        end
    end
end)

-- Auto Fish
task.spawn(function()
    while true do
        task.wait(rDelay(Cfg.FishDelay, 0.2))
        if Cfg.AutoFish then
            pcall(function()
                if Cfg.InstantMode then
                    if Ev.charge then safeInvoke(Ev.charge, 1) end
                    hWait(0.03)
                    if Ev.mini then safeInvoke(Ev.mini) end
                elseif Cfg.BlatantMode then
                    if Ev.charge then safeInvoke(Ev.charge, 1) end
                    hWait(0.15)
                    if Ev.mini then safeInvoke(Ev.mini) end
                else
                    if Ev.charge then safeInvoke(Ev.charge, 1) end
                    hWait(0.8)
                    if Ev.mini then safeInvoke(Ev.mini) end
                end
            end)
        end
    end
end)

-- Auto Catch
task.spawn(function()
    while true do
        task.wait(rDelay(Cfg.CatchDelay, 0.1))
        if Cfg.AutoCatch then
            pcall(function()
                if Ev.fish then safeFire(Ev.fish) end
            end)
        end
    end
end)

-- Auto Sell
task.spawn(function()
    while true do
        task.wait(Cfg.SellDelay)
        if Cfg.AutoSell then
            pcall(function()
                if Ev.sell then safeInvoke(Ev.sell) end
            end)
        end
    end
end)

-- Auto Favorite
task.spawn(function()
    while true do
        task.wait(3)
        if Cfg.AutoFavorite and PData and ItemUtil and Ev.fav then
            pcall(function()
                local inv = PData:Get("Inventory")
                if not inv then return end
                local minR = Rarity[Cfg.FavoriteRarity] or 5
                for uid, item in pairs(inv) do
                    if not item.Favorited then
                        local r = 0
                        pcall(function()
                            local info = ItemUtil.getItemInfoFromId(item.ItemId)
                            if info and info.Rarity then r = Rarity[info.Rarity] or 0 end
                        end)
                        if r >= minR then
                            safeFire(Ev.fav, uid)
                            hWait(0.3)
                        end
                    end
                end
            end)
        end
    end
end)

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    if Cfg.InfJump then
        pcall(function()
            local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end)

-- Noclip
task.spawn(function()
    RunService.Stepped:Connect(function()
        if Cfg.Noclip then
            pcall(function()
                local ch = LP.Character
                if ch then
                    for _, p in pairs(ch:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        end
    end)
end)

-- Fly
task.spawn(function()
    local bv, bg
    RunService.Heartbeat:Connect(function()
        if Cfg.Fly then
            pcall(function()
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if not bv then
                        bv = Instance.new("BodyVelocity", hrp)
                        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bv.Velocity = Vector3.new(0, 0, 0)
                        bg = Instance.new("BodyGyro", hrp)
                        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                        bg.P = 9e4
                    end
                    local cam = Workspace.CurrentCamera
                    local dir = Vector3.new(0, 0, 0)
                    if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                    bv.Velocity = dir * 60
                    bg.CFrame = cam.CFrame
                end
            end)
        else
            if bv then pcall(function() bv:Destroy() end) bv = nil end
            if bg then pcall(function() bg:Destroy() end) bg = nil end
        end
    end)
end)

-- Fish ESP
task.spawn(function()
    while true do
        task.wait(2)
        if Cfg.FishESP then
            pcall(function()
                for _, o in pairs(Workspace:GetDescendants()) do
                    if (o:IsA("Model") or o:IsA("BasePart")) and (o.Name:lower():find("fish") or o.Name:lower():find("catch")) then
                        if not o:FindFirstChildOfClass("Highlight") then
                            local h = Instance.new("Highlight", o)
                            h.FillColor = Color3.fromRGB(0, 255, 100)
                            h.FillTransparency = 0.7
                            h.OutlineColor = Color3.fromRGB(100, 255, 150)
                            h:SetAttribute("_mfi", true)
                        end
                    end
                end
            end)
        else
            pcall(function()
                for _, o in pairs(Workspace:GetDescendants()) do
                    if o:IsA("Highlight") and o:GetAttribute("_mfi") then o:Destroy() end
                end
            end)
        end
    end
end)

-- Player ESP
task.spawn(function()
    while true do
        task.wait(3)
        if Cfg.PlayerESP then
            pcall(function()
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and not p.Character:FindFirstChildOfClass("Highlight") then
                        local h = Instance.new("Highlight", p.Character)
                        h.FillColor = Color3.fromRGB(255, 100, 100)
                        h.FillTransparency = 0.7
                        h:SetAttribute("_mfi", true)
                    end
                end
            end)
        else
            pcall(function()
                for _, p in pairs(Players:GetPlayers()) do
                    if p.Character then
                        for _, o in pairs(p.Character:GetChildren()) do
                            if o:IsA("Highlight") and o:GetAttribute("_mfi") then o:Destroy() end
                        end
                    end
                end
            end)
        end
    end
end)

-- Anti-Drown
task.spawn(function()
    while true do
        task.wait(0.5)
        if Cfg.AntiDrown then
            pcall(function()
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Position.Y < -5 then
                    hrp.CFrame = CFrame.new(hrp.Position.X, 10, hrp.Position.Z)
                end
            end)
        end
    end
end)

-- Speed/Jump enforcement
task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if h then
                if Cfg.WalkSpeed ~= 16 then h.WalkSpeed = Cfg.WalkSpeed end
                if Cfg.JumpPower ~= 50 then h.JumpPower = Cfg.JumpPower end
            end
        end)
    end
end)

-- Done notification
notify("Moron Fish It", "v3.0 loaded! RightShift to toggle", 4)
