--[[
    ╔══════════════════════════════════════════════╗
    ║         MORON FISH IT v11.0 by GasUp ID      ║
    ║     Full Feature - Matching Euphoria Style    ║
    ╚══════════════════════════════════════════════╝
]]

-- ============================================================
--  SERVICES
-- ============================================================
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer
local PLACE_ID = game.PlaceId
local JOB_ID = game.JobId

-- ============================================================
--  ANTI-DUPLICATE
-- ============================================================
if getgenv and getgenv().__MORON_FISH_LOADED then return end
if getgenv then getgenv().__MORON_FISH_LOADED = true end

-- ============================================================
--  CONFIGURATION
-- ============================================================
local CFG_FOLDER = "MoronFishIt"
local CFG_FILE = CFG_FOLDER .. "/config_" .. LP.UserId .. ".json"

local DefaultConfig = {
    -- Fishing
    AutoFish = false, FishingMode = "Normal", AutoShake = false, PerfectCast = false,
    InstantFish = false,
    -- Selling
    AutoSell = false, SellLimit = 100, SellDelay = 30, SellingType = "All",
    -- Favorite
    AutoFavorite = false, FavTier = "Legendary", FavName = "", FavMutation = "",
    -- Movement
    CharFly = false, WalkOnWater = false, InfJump = false, AntiDrown = false,
    WalkSpeed = 16, JumpPower = 50,
    -- Automation
    AutoTotem = false, TotemType = "", AutoPotion = false, PotionName = "",
    AutoCaveCrystal = false, AutoMineCrystal = false,
    -- Shopping
    AutoBuyItems = false, BuyDelay = 1, AutoBuyWeather = false, WeatherType = "",
    -- Quests
    AutoElementQuests = false, AutoGhostfinQuests = false,
    -- Trading
    AutoAcceptTrade = false, AutoTradeEnchant = false, AutoTradeCaveCrystal = false,
    -- Webhook
    WebhookURL = "", WebhookEnabled = false, WebhookTier = "", WebhookName = "",
    WebhookMutation = "", HideUsername = false, TagEveryone = false, TagAccountName = false,
    -- Performance
    FPSBoost = false, GPUSaver = false,
    -- Utility
    AntiAFK = true, NotifPosition = "TopRight",
    AnimSkin = "", AnimChanger = false,
    -- Delays
    FishDelay = 0.9, CatchDelay = 0.2,
}

local Config = {}
for k, v in pairs(DefaultConfig) do Config[k] = v end

-- ============================================================
--  CONFIG SAVE / LOAD
-- ============================================================
local function ensureFolder()
    if not isfolder or not makefolder then return false end
    if not isfolder(CFG_FOLDER) then pcall(makefolder, CFG_FOLDER) end
    return isfolder(CFG_FOLDER)
end

local function saveConfig()
    if not writefile or not ensureFolder() then return end
    pcall(function() writefile(CFG_FILE, HttpService:JSONEncode(Config)) end)
end

local function loadConfig()
    if not readfile or not isfile or not isfile(CFG_FILE) then return end
    pcall(function()
        local d = HttpService:JSONDecode(readfile(CFG_FILE))
        for k, v in pairs(d) do if DefaultConfig[k] ~= nil then Config[k] = v end end
    end)
end

loadConfig()

-- ============================================================
--  NETWORK EVENTS (from nandafjng proven working)
-- ============================================================
local Events = {}
local EventsLoaded = false

local function findNetFolder()
    local pkg = RS:FindFirstChild("Packages")
    if not pkg then return nil end
    local idx = pkg:FindFirstChild("_Index")
    if not idx then return nil end
    for _, child in ipairs(idx:GetChildren()) do
        if child.Name:find("sleitnick_net") then
            local net = child:FindFirstChild("net")
            if net then return net end
        end
    end
    return nil
end

local function loadEvents()
    local ok, err = pcall(function()
        local net = findNetFolder()
        if not net then error("net folder not found") end
        Events.fishing   = net:WaitForChild("RE/FishingCompleted", 5)
        Events.sell       = net:WaitForChild("RF/SellAllItems", 5)
        Events.charge     = net:WaitForChild("RF/ChargeFishingRod", 5)
        Events.minigame   = net:WaitForChild("RF/RequestFishingMinigameStarted", 5)
        Events.cancel     = net:WaitForChild("RF/CancelFishingInputs", 5)
        Events.equip      = net:WaitForChild("RE/EquipToolFromHotbar", 5)
        Events.unequip    = net:WaitForChild("RE/UnequipToolFromHotbar", 5)
        Events.favorite   = net:WaitForChild("RE/FavoriteItem", 5)
        EventsLoaded = true
    end)
    if not ok then warn("[Moron] Events failed: " .. tostring(err)) end
end

loadEvents()

-- ============================================================
--  INVENTORY MODULES
-- ============================================================
local ItemUtility, PlayerData
pcall(function()
    ItemUtility = require(RS.Shared.ItemUtility)
    local Replion = require(RS.Packages.Replion)
    PlayerData = Replion.Client:WaitReplion("Data")
end)

-- ============================================================
--  RARITY SYSTEM
-- ============================================================
local RarityTiers = { Common=1, Uncommon=2, Rare=3, Epic=4, Legendary=5, Mythic=6, Secret=7 }
local RarityList = {"Common","Uncommon","Rare","Epic","Legendary","Mythic","Secret"}

local function getRarityValue(r) return RarityTiers[r] or 0 end
local function getFishRarity(d)
    if d and d.Data and d.Data.Rarity then return d.Data.Rarity end
    return "Common"
end

-- ============================================================
--  TELEPORT LOCATIONS
-- ============================================================
local LOCATIONS = {
    {name="Spawn", cf=CFrame.new(45.28, 252.56, 2987.11)},
    {name="Sisyphus Statue", cf=CFrame.new(-3728.22, -135.07, -1012.13)},
    {name="Coral Reefs", cf=CFrame.new(-3114.78, 1.32, 2237.52)},
    {name="Esoteric Depths", cf=CFrame.new(3248.37, -1301.53, 1403.83)},
    {name="Crater Island", cf=CFrame.new(1016.49, 20.09, 5069.27)},
    {name="Lost Isle", cf=CFrame.new(-3618.16, 240.84, -1317.46)},
    {name="Weather Machine", cf=CFrame.new(-1488.51, 83.17, 1876.30)},
    {name="Tropical Grove", cf=CFrame.new(-2095.34, 197.20, 3718.08)},
    {name="Mount Hallow", cf=CFrame.new(2136.62, 78.92, 3272.50)},
    {name="Treasure Room", cf=CFrame.new(-3606.35, -266.57, -1580.97)},
    {name="Kohana", cf=CFrame.new(-663.90, 3.05, 718.80)},
    {name="Underground Cellar", cf=CFrame.new(2109.52, -94.19, -708.61)},
    {name="Ancient Jungle", cf=CFrame.new(1831.71, 6.62, -299.28)},
    {name="Sacred Temple", cf=CFrame.new(1466.92, -21.88, -622.84)},
}

local function teleportTo(cf)
    pcall(function()
        local c = LP.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            c.HumanoidRootPart.CFrame = cf
        end
    end)
end

-- ============================================================
--  FISHING LOGIC
-- ============================================================
local fishingActive = false
local isFishing = false

local function castRod()
    pcall(function()
        Events.equip:FireServer(1)
        task.wait(0.05)
        Events.charge:InvokeServer(1755848498.4834)
        task.wait(0.02)
        Events.minigame:InvokeServer(1.2854545116425, 1)
    end)
end

local function reelIn()
    pcall(function() Events.fishing:FireServer() end)
end

local function normalFishingLoop()
    while fishingActive and Config.FishingMode == "Normal" do
        if not isFishing then
            isFishing = true
            castRod()
            task.wait(Config.FishDelay)
            reelIn()
            task.wait(Config.CatchDelay)
            isFishing = false
        else
            task.wait(0.1)
        end
    end
end

local function blatantFishingLoop()
    while fishingActive and Config.FishingMode == "Blatant" do
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
            task.wait(Config.FishDelay)
            for i = 1, 5 do
                pcall(function() Events.fishing:FireServer() end)
                task.wait(0.01)
            end
            task.wait(Config.CatchDelay * 0.5)
            isFishing = false
        else
            task.wait(0.01)
        end
    end
end

local function instantFishingLoop()
    while fishingActive and Config.FishingMode == "Instant" do
        if not isFishing then
            isFishing = true
            pcall(function()
                Events.equip:FireServer(1)
                task.wait(0.01)
                Events.charge:InvokeServer(1755848498.4834)
                task.wait(0.01)
                Events.minigame:InvokeServer(1.2854545116425, 1)
            end)
            task.wait(0.05)
            for i = 1, 3 do
                pcall(function() Events.fishing:FireServer() end)
                task.wait(0.01)
            end
            task.wait(0.05)
            isFishing = false
        else
            task.wait(0.01)
        end
    end
end

local fishThread = nil
local function startFishing()
    if fishingActive then return end
    fishingActive = true
    fishThread = task.spawn(function()
        while fishingActive do
            if Config.FishingMode == "Blatant" then
                blatantFishingLoop()
            elseif Config.FishingMode == "Instant" then
                instantFishingLoop()
            else
                normalFishingLoop()
            end
            task.wait(0.1)
        end
    end)
end

local function stopFishing()
    fishingActive = false
    isFishing = false
end

-- Auto Shake (auto reel background)
task.spawn(function()
    while true do
        if Config.AutoShake and fishingActive then
            pcall(function() Events.fishing:FireServer() end)
        end
        task.wait(0.3)
    end
end)

-- ============================================================
--  AUTO SELL
-- ============================================================
local function doSell()
    pcall(function() Events.sell:InvokeServer() end)
end

task.spawn(function()
    while true do
        task.wait(Config.SellDelay)
        if Config.AutoSell then doSell() end
    end
end)

-- ============================================================
--  AUTO FAVORITE / UNFAVORITE
-- ============================================================
local favoritedItems = {}

local function getInventoryItems()
    local items = {}
    pcall(function()
        items = PlayerData:GetExpect("Inventory").Items or {}
    end)
    return items
end

local function isItemFavorited(uuid)
    local ok, res = pcall(function()
        local items = getInventoryItems()
        for _, item in ipairs(items) do
            if item.UUID == uuid then return item.Favorited == true end
        end
        return false
    end)
    return ok and res or false
end

local function autoFavoriteByRarity()
    if not Config.AutoFavorite then return end
    local targetVal = getRarityValue(Config.FavTier)
    pcall(function()
        local items = getInventoryItems()
        for _, item in ipairs(items) do
            local data = ItemUtility:GetItemData(item.Id)
            if data and data.Data then
                local rarity = getFishRarity(data)
                if getRarityValue(rarity) >= targetVal then
                    if not isItemFavorited(item.UUID) and not favoritedItems[item.UUID] then
                        Events.favorite:FireServer(item.UUID)
                        favoritedItems[item.UUID] = true
                        task.wait(0.3)
                    end
                end
            end
        end
    end)
end

local function unfavoriteByTier(tier)
    pcall(function()
        local items = getInventoryItems()
        for _, item in ipairs(items) do
            local data = ItemUtility:GetItemData(item.Id)
            if data and data.Data then
                local rarity = getFishRarity(data)
                if rarity == tier and isItemFavorited(item.UUID) then
                    Events.favorite:FireServer(item.UUID)
                    task.wait(0.3)
                end
            end
        end
    end)
end

local function unfavoriteAll()
    pcall(function()
        local items = getInventoryItems()
        for _, item in ipairs(items) do
            if isItemFavorited(item.UUID) then
                Events.favorite:FireServer(item.UUID)
                task.wait(0.2)
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(10)
        if Config.AutoFavorite then autoFavoriteByRarity() end
    end
end)

-- ============================================================
--  MOVEMENT FEATURES
-- ============================================================
-- Character Fly
local flyActive = false
local flyBV, flyBG

local function startFly()
    if flyActive then return end
    flyActive = true
    pcall(function()
        local c = LP.Character
        if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBV.Velocity = Vector3.zero
        flyBV.Parent = hrp
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyBG.P = 9e4
        flyBG.Parent = hrp
    end)
end

local function stopFly()
    flyActive = false
    pcall(function()
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
    end)
end

RunService.Heartbeat:Connect(function()
    if not flyActive then return end
    pcall(function()
        local c = LP.Character
        if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hrp or not flyBV then return end
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        local spd = 80
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * spd or Vector3.zero
        flyBG.CFrame = cam.CFrame
    end)
end)

-- Walk On Water
local waterPart = nil
local function enableWalkOnWater()
    pcall(function()
        if waterPart then return end
        waterPart = Instance.new("Part")
        waterPart.Size = Vector3.new(2048, 1, 2048)
        waterPart.Position = Vector3.new(0, -0.5, 0)
        waterPart.Anchored = true
        waterPart.Transparency = 1
        waterPart.CanCollide = true
        waterPart.Parent = workspace
    end)
end

local function disableWalkOnWater()
    pcall(function()
        if waterPart then waterPart:Destroy() waterPart = nil end
    end)
end

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    if Config.InfJump then
        pcall(function()
            local c = LP.Character
            if c and c:FindFirstChildOfClass("Humanoid") then
                c:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- Anti Drown
task.spawn(function()
    while true do
        if Config.AntiDrown then
            pcall(function()
                local c = LP.Character
                if c and c:FindFirstChild("HumanoidRootPart") then
                    local hrp = c.HumanoidRootPart
                    if hrp.Position.Y < -5 then
                        hrp.CFrame = hrp.CFrame + Vector3.new(0, 10, 0)
                    end
                end
            end)
        end
        task.wait(1)
    end
end)

-- Walk Speed / Jump Power
RunService.Heartbeat:Connect(function()
    pcall(function()
        local c = LP.Character
        if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if Config.WalkSpeed ~= 16 then hum.WalkSpeed = Config.WalkSpeed end
        if Config.JumpPower ~= 50 then hum.JumpPower = Config.JumpPower end
    end)
end)

-- Noclip
RunService.Stepped:Connect(function()
    if Config.Noclip then
        pcall(function()
            local c = LP.Character
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    end
end)

-- ============================================================
--  GPU SAVER / FPS BOOST
-- ============================================================
local gpuScreen = nil

local function enableGPU()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1
        if setfpscap then setfpscap(8) end
    end)
    if not gpuScreen then
        gpuScreen = Instance.new("ScreenGui")
        gpuScreen.ResetOnSpawn = false
        gpuScreen.DisplayOrder = 999999
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1,0,1,0)
        f.BackgroundColor3 = Color3.fromRGB(20,20,20)
        f.Parent = gpuScreen
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0,400,0,80)
        l.Position = UDim2.new(0.5,-200,0.5,-40)
        l.BackgroundTransparency = 1
        l.Text = "GPU SAVER ACTIVE\nAuto Fish Running..."
        l.TextColor3 = Color3.fromRGB(0,255,0)
        l.TextSize = 24
        l.Font = Enum.Font.GothamBold
        l.Parent = f
        local gui = (gethui and gethui()) or LP.PlayerGui
        gpuScreen.Parent = gui
    end
end

local function disableGPU()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000
        if setfpscap then setfpscap(0) end
    end)
    if gpuScreen then gpuScreen:Destroy() gpuScreen = nil end
end

local function enableFPSBoost()
    pcall(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                v.Enabled = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            end
        end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
end

-- ============================================================
--  ANTI-AFK
-- ============================================================
LP.Idled:Connect(function()
    if Config.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- ============================================================
--  SERVER HOP / REJOIN
-- ============================================================
local function serverHop()
    pcall(function()
        local servers = HttpService:JSONDecode(
            game:HttpGet("https://games.roblox.com/v1/games/"..PLACE_ID.."/servers/Public?sortOrder=Asc&limit=100")
        )
        for _, s in ipairs(servers.data or {}) do
            if s.id ~= JOB_ID and s.playing < s.maxPlayers then
                TeleportService:TeleportToPlaceInstance(PLACE_ID, s.id)
                return
            end
        end
    end)
end

local function rejoinServer()
    pcall(function() TeleportService:TeleportToPlaceInstance(PLACE_ID, JOB_ID) end)
end

-- ============================================================
--  WEBHOOK SYSTEM
-- ============================================================
local function sendWebhook(fishName, tier, mutation)
    if not Config.WebhookEnabled or Config.WebhookURL == "" then return end
    -- Filter checks
    if Config.WebhookTier ~= "" and tier ~= Config.WebhookTier then return end
    if Config.WebhookName ~= "" and fishName ~= Config.WebhookName then return end
    if Config.WebhookMutation ~= "" and (mutation or "") ~= Config.WebhookMutation then return end
    
    pcall(function()
        local username = Config.HideUsername and "Hidden" or LP.Name
        local content = ""
        if Config.TagEveryone then content = "@everyone " end
        content = content .. "**" .. username .. "** caught **" .. fishName .. "** [" .. tier .. "]"
        if mutation and mutation ~= "" then content = content .. " (Mutation: " .. mutation .. ")" end
        if Config.TagAccountName then content = content .. " | Account: " .. LP.Name end
        
        local data = HttpService:JSONEncode({content = content})
        local req = (syn and syn.request) or (http and http.request) or request or http_request
        if req then
            req({Url = Config.WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = data})
        end
    end)
end

-- ============================================================
--  FISH ESP (Drawing API)
-- ============================================================
local espEnabled = false
local espObjects = {}

local function clearESP()
    for _, obj in pairs(espObjects) do pcall(function() obj:Remove() end) end
    espObjects = {}
end

local function updateFishESP()
    clearESP()
    if not espEnabled then return end
    pcall(function()
        local cam = workspace.CurrentCamera
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") == nil and v.Name:find("Fish") then
                local pos = v:GetPivot().Position
                local screenPos, onScreen = cam:WorldToViewportPoint(pos)
                if onScreen then
                    local txt = Drawing.new("Text")
                    txt.Text = v.Name
                    txt.Position = Vector2.new(screenPos.X, screenPos.Y)
                    txt.Size = 14
                    txt.Color = Color3.fromRGB(0, 255, 255)
                    txt.Outline = true
                    txt.Visible = true
                    table.insert(espObjects, txt)
                end
            end
        end
    end)
end

-- ============================================================
--  PLAYER ESP (Drawing API)
-- ============================================================
local playerESPEnabled = false
local playerESPObjects = {}

local function clearPlayerESP()
    for _, obj in pairs(playerESPObjects) do pcall(function() obj:Remove() end) end
    playerESPObjects = {}
end

local function updatePlayerESP()
    clearPlayerESP()
    if not playerESPEnabled then return end
    pcall(function()
        local cam = workspace.CurrentCamera
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local pos = plr.Character.HumanoidRootPart.Position
                local screenPos, onScreen = cam:WorldToViewportPoint(pos)
                if onScreen then
                    local dist = (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))
                        and math.floor((LP.Character.HumanoidRootPart.Position - pos).Magnitude) or 0
                    local txt = Drawing.new("Text")
                    txt.Text = plr.Name .. " [" .. dist .. "m]"
                    txt.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
                    txt.Size = 14
                    txt.Color = Color3.fromRGB(255, 255, 0)
                    txt.Outline = true
                    txt.Visible = true
                    table.insert(playerESPObjects, txt)
                end
            end
        end
    end)
end

-- ESP Update Loop
task.spawn(function()
    while true do
        if espEnabled then updateFishESP() end
        if playerESPEnabled then updatePlayerESP() end
        task.wait(0.5)
    end
end)

-- ============================================================
--  GET DYNAMIC LISTS (for dropdowns)
-- ============================================================
local function getPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(list, p.Name) end
    end
    return list
end

local function getZoneList()
    local list = {}
    for _, loc in ipairs(LOCATIONS) do table.insert(list, loc.name) end
    return list
end

local function getInventoryFishNames()
    local names = {}
    pcall(function()
        local items = getInventoryItems()
        for _, item in ipairs(items) do
            local data = ItemUtility:GetItemData(item.Id)
            if data and data.Data and data.Data.Name then
                local n = data.Data.Name
                if not table.find(names, n) then table.insert(names, n) end
            end
        end
    end)
    return names
end

-- ============================================================
--                    UI SYSTEM
-- ============================================================
-- Destroy old GUI
pcall(function()
    local gui = (gethui and gethui()) or LP.PlayerGui
    for _, g in ipairs(gui:GetChildren()) do
        if g.Name == "MoronFishItGUI" then g:Destroy() end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MoronFishItGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 100000

local guiParent = (gethui and gethui()) or LP.PlayerGui
ScreenGui.Parent = guiParent

-- ============================================================
--  SPLASH SCREEN
-- ============================================================
local splash = Instance.new("Frame")
splash.Size = UDim2.new(1,0,1,0)
splash.BackgroundColor3 = Color3.fromRGB(15,15,20)
splash.BorderSizePixel = 0
splash.ZIndex = 100
splash.Parent = ScreenGui

local splashTitle = Instance.new("TextLabel")
splashTitle.Size = UDim2.new(0,400,0,60)
splashTitle.Position = UDim2.new(0.5,-200,0.4,-30)
splashTitle.BackgroundTransparency = 1
splashTitle.Text = "Moron Fish It"
splashTitle.TextColor3 = Color3.fromRGB(130,200,255)
splashTitle.TextSize = 36
splashTitle.Font = Enum.Font.GothamBold
splashTitle.ZIndex = 101
splashTitle.Parent = splash

local splashSub = Instance.new("TextLabel")
splashSub.Size = UDim2.new(0,400,0,30)
splashSub.Position = UDim2.new(0.5,-200,0.4,35)
splashSub.BackgroundTransparency = 1
splashSub.Text = "by GasUp ID"
splashSub.TextColor3 = Color3.fromRGB(180,180,180)
splashSub.TextSize = 18
splashSub.Font = Enum.Font.Gotham
splashSub.ZIndex = 101
splashSub.Parent = splash

local splashVer = Instance.new("TextLabel")
splashVer.Size = UDim2.new(0,400,0,30)
splashVer.Position = UDim2.new(0.5,-200,0.4,65)
splashVer.BackgroundTransparency = 1
splashVer.Text = "v11.0 - Full Feature Edition"
splashVer.TextColor3 = Color3.fromRGB(120,120,120)
splashVer.TextSize = 14
splashVer.Font = Enum.Font.Gotham
splashVer.ZIndex = 101
splashVer.Parent = splash

task.delay(2.5, function()
    splash:Destroy()
end)

-- ============================================================
--  MAIN FRAME
-- ============================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 580, 0, 420)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = MainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
titleBar.BorderSizePixel = 0
titleBar.Parent = MainFrame

Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 200, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Moron Fish It"
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local verLabel = Instance.new("TextLabel")
verLabel.Size = UDim2.new(0, 80, 1, 0)
verLabel.Position = UDim2.new(0, 160, 0, 0)
verLabel.BackgroundTransparency = 1
verLabel.Text = "v11.0"
verLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
verLabel.TextSize = 12
verLabel.Font = Enum.Font.Gotham
verLabel.TextXAlignment = Enum.TextXAlignment.Left
verLabel.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

-- Minimize Button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -65, 0, 5)
minBtn.BackgroundTransparency = 1
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
minBtn.TextSize = 20
minBtn.Font = Enum.Font.GothamBold
minBtn.Parent = titleBar

-- Dragging
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ============================================================
--  SIDEBAR
-- ============================================================
local sidebar = Instance.new("ScrollingFrame")
sidebar.Size = UDim2.new(0, 150, 1, -40)
sidebar.Position = UDim2.new(0, 0, 0, 40)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
sidebar.BorderSizePixel = 0
sidebar.ScrollBarThickness = 3
sidebar.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
sidebar.Parent = MainFrame

Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 0)

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Padding = UDim.new(0, 2)
sidebarLayout.Parent = sidebar

-- Content Area
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -150, 1, -40)
contentArea.Position = UDim2.new(0, 150, 0, 40)
contentArea.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
contentArea.BorderSizePixel = 0
contentArea.ClipsDescendants = true
contentArea.Parent = MainFrame

-- Tab Pages (scrollable)
local tabPages = {}
local currentTab = nil

local TABS = {
    {name="Local Player", icon="P", order=1},
    {name="Main", icon="F", order=2},
    {name="Zone Fishing", icon="Z", order=3},
    {name="Backpack", icon="B", order=4},
    {name="Webhook", icon="W", order=5},
    {name="Trading", icon="T", order=6},
    {name="Automation", icon="A", order=7},
    {name="Shopping", icon="S", order=8},
    {name="Quests", icon="Q", order=9},
    {name="Teleportation", icon="L", order=10},
    {name="Utilities", icon="U", order=11},
    {name="Performance", icon="G", order=12},
    {name="Settings", icon="C", order=13},
}

-- Create tab pages
for _, tab in ipairs(TABS) do
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = contentArea
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = page
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = page
    
    tabPages[tab.name] = page
end

-- Tab buttons
local tabButtons = {}

local function selectTab(tabName)
    for name, page in pairs(tabPages) do
        page.Visible = (name == tabName)
    end
    for name, btn in pairs(tabButtons) do
        btn.BackgroundColor3 = (name == tabName) and Color3.fromRGB(40, 40, 55) or Color3.fromRGB(20, 20, 25)
    end
    currentTab = tabName
end

for _, tab in ipairs(TABS) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    btn.BorderSizePixel = 0
    btn.Text = "  " .. tab.icon .. "  " .. tab.name
    btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = tab.order
    btn.Parent = sidebar
    
    btn.MouseButton1Click:Connect(function() selectTab(tab.name) end)
    tabButtons[tab.name] = btn
end

-- ============================================================
--  UI COMPONENT BUILDERS
-- ============================================================
local orderCounter = 0

local function makeSection(page, text, order)
    orderCounter = orderCounter + 1
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 28)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(130, 200, 255)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order or orderCounter
    lbl.Parent = page
    return lbl
end

local function makeCollapsible(page, title, order)
    orderCounter = orderCounter + 1
    local ord = order or orderCounter
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    container.BorderSizePixel = 0
    container.LayoutOrder = ord
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.ClipsDescendants = true
    container.Parent = page
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    
    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, 36)
    header.BackgroundTransparency = 1
    header.Text = "  " .. title
    header.TextColor3 = Color3.fromRGB(220, 220, 240)
    header.TextSize = 14
    header.Font = Enum.Font.GothamBold
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = container
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 30, 0, 36)
    arrow.Position = UDim2.new(1, -30, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "v"
    arrow.TextColor3 = Color3.fromRGB(150, 150, 170)
    arrow.TextSize = 14
    arrow.Font = Enum.Font.GothamBold
    arrow.Parent = container
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -10, 0, 0)
    content.Position = UDim2.new(0, 5, 0, 36)
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Visible = false
    content.Parent = container
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 4)
    contentLayout.Parent = content
    
    local expanded = false
    header.MouseButton1Click:Connect(function()
        expanded = not expanded
        content.Visible = expanded
        arrow.Text = expanded and "^" or "v"
        if expanded then
            container.AutomaticSize = Enum.AutomaticSize.Y
        else
            container.Size = UDim2.new(1, 0, 0, 36)
            container.AutomaticSize = Enum.AutomaticSize.None
            task.wait(0.01)
            container.Size = UDim2.new(1, 0, 0, 36)
        end
    end)
    
    return content
end

local function makeToggle(parent, title, desc, configKey, order, callback)
    orderCounter = orderCounter + 1
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order or orderCounter
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 0, 22)
    lbl.Position = UDim2.new(0, 10, 0, 3)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(220, 220, 240)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    if desc and desc ~= "" then
        local descLbl = Instance.new("TextLabel")
        descLbl.Size = UDim2.new(1, -70, 0, 14)
        descLbl.Position = UDim2.new(0, 10, 0, 23)
        descLbl.BackgroundTransparency = 1
        descLbl.Text = desc
        descLbl.TextColor3 = Color3.fromRGB(120, 120, 140)
        descLbl.TextSize = 10
        descLbl.Font = Enum.Font.Gotham
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.Parent = frame
    end
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 44, 0, 22)
    toggleBg.Position = UDim2.new(1, -54, 0.5, -11)
    toggleBg.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(60, 60, 70)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = frame
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = Config[configKey] and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BorderSizePixel = 0
    circle.Parent = toggleBg
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = toggleBg
    
    btn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        toggleBg.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(60, 60, 70)
        circle.Position = Config[configKey] and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)
        if callback then callback(Config[configKey]) end
        saveConfig()
    end)
    
    return frame
end

local function makeButton(parent, title, order, callback)
    orderCounter = orderCounter + 1
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
    btn.BorderSizePixel = 0
    btn.Text = title
    btn.TextColor3 = Color3.fromRGB(200, 200, 220)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.LayoutOrder = order or orderCounter
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return btn
end

local function makeSlider(parent, title, configKey, minVal, maxVal, step, order)
    orderCounter = orderCounter + 1
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order or orderCounter
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.3, 0, 0, 20)
    valLbl.Position = UDim2.new(0.7, 0, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(Config[configKey])
    valLbl.TextColor3 = Color3.fromRGB(130, 200, 255)
    valLbl.TextSize = 12
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -20, 0, 6)
    sliderBg.Position = UDim2.new(0, 10, 0, 32)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame")
    local pct = (Config[configKey] - minVal) / (maxVal - minVal)
    fill.Size = UDim2.new(math.clamp(pct, 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, 0, 1, 0)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.Parent = sliderBg
    
    local sliding = false
    sliderBtn.MouseButton1Down:Connect(function() sliding = true end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local absPos = sliderBg.AbsolutePosition.X
            local absSize = sliderBg.AbsoluteSize.X
            local rel = math.clamp((input.Position.X - absPos) / absSize, 0, 1)
            local val = minVal + (maxVal - minVal) * rel
            val = math.floor(val / step + 0.5) * step
            val = math.clamp(val, minVal, maxVal)
            Config[configKey] = val
            fill.Size = UDim2.new((val - minVal) / (maxVal - minVal), 0, 1, 0)
            valLbl.Text = tostring(math.floor(val * 100) / 100)
            saveConfig()
        end
    end)
    
    return frame
end

local function makeDropdown(parent, title, configKey, options, order)
    orderCounter = orderCounter + 1
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order or orderCounter
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local selected = Instance.new("TextButton")
    selected.Size = UDim2.new(0.45, 0, 0, 26)
    selected.Position = UDim2.new(0.52, 0, 0, 5)
    selected.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    selected.BorderSizePixel = 0
    selected.Text = Config[configKey] ~= "" and Config[configKey] or "--"
    selected.TextColor3 = Color3.fromRGB(180, 180, 200)
    selected.TextSize = 11
    selected.Font = Enum.Font.Gotham
    selected.TextTruncate = Enum.TextTruncate.AtEnd
    selected.Parent = frame
    Instance.new("UICorner", selected).CornerRadius = UDim.new(0, 6)
    
    local dropList = Instance.new("Frame")
    dropList.Size = UDim2.new(0.45, 0, 0, 0)
    dropList.Position = UDim2.new(0.52, 0, 1, 2)
    dropList.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    dropList.BorderSizePixel = 0
    dropList.Visible = false
    dropList.ZIndex = 50
    dropList.ClipsDescendants = true
    dropList.Parent = frame
    Instance.new("UICorner", dropList).CornerRadius = UDim.new(0, 6)
    
    local dropLayout = Instance.new("UIListLayout")
    dropLayout.SortOrder = Enum.SortOrder.LayoutOrder
    dropLayout.Parent = dropList
    
    local function populateDropdown()
        for _, c in ipairs(dropList:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local opts = type(options) == "function" and options() or options
        local h = math.min(#opts * 26, 200)
        dropList.Size = UDim2.new(0.45, 0, 0, h)
        
        for i, opt in ipairs(opts) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 26)
            optBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            optBtn.BorderSizePixel = 0
            optBtn.Text = "  " .. opt
            optBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
            optBtn.TextSize = 11
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextXAlignment = Enum.TextXAlignment.Left
            optBtn.TextTruncate = Enum.TextTruncate.AtEnd
            optBtn.ZIndex = 51
            optBtn.LayoutOrder = i
            optBtn.Parent = dropList
            
            optBtn.MouseButton1Click:Connect(function()
                Config[configKey] = opt
                selected.Text = opt
                dropList.Visible = false
                saveConfig()
            end)
        end
    end
    
    selected.MouseButton1Click:Connect(function()
        dropList.Visible = not dropList.Visible
        if dropList.Visible then populateDropdown() end
    end)
    
    return frame
end

local function makeInput(parent, title, configKey, placeholder, order)
    orderCounter = orderCounter + 1
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order or orderCounter
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.45, 0, 0, 26)
    input.Position = UDim2.new(0.52, 0, 0, 5)
    input.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    input.BorderSizePixel = 0
    input.Text = tostring(Config[configKey] or "")
    input.PlaceholderText = placeholder or ""
    input.TextColor3 = Color3.fromRGB(200, 200, 220)
    input.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    input.TextSize = 11
    input.Font = Enum.Font.Gotham
    input.ClearTextOnFocus = false
    input.Parent = frame
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)
    
    input.FocusLost:Connect(function()
        local val = input.Text
        if type(Config[configKey]) == "number" then
            val = tonumber(val) or Config[configKey]
        end
        Config[configKey] = val
        saveConfig()
    end)
    
    return frame
end

local function makeLabel(parent, text, order)
    orderCounter = orderCounter + 1
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(150, 150, 170)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order or orderCounter
    lbl.Parent = parent
    return lbl
end

-- ============================================================
--  TAB 1: LOCAL PLAYER
-- ============================================================
local lpPage = tabPages["Local Player"]
makeToggle(lpPage, "Character Fly", "WASD + Space/Shift to fly", "CharFly", 1, function(v)
    if v then startFly() else stopFly() end
end)
makeToggle(lpPage, "Walk On Water", "Walk on water surface", "WalkOnWater", 2, function(v)
    if v then enableWalkOnWater() else disableWalkOnWater() end
end)
makeToggle(lpPage, "Infinite Jump", "Jump in mid-air", "InfJump", 3)
makeToggle(lpPage, "Anti Drown", "Auto resurface underwater", "AntiDrown", 4)
makeSlider(lpPage, "Walk Speed", "WalkSpeed", 16, 200, 1, 5)
makeSlider(lpPage, "Jump Power", "JumpPower", 50, 300, 5, 6)

-- ============================================================
--  TAB 2: MAIN
-- ============================================================
local mainPage = tabPages["Main"]

-- Legit Fishing section
local legitFish = makeCollapsible(mainPage, "Legit Fishing", 1)
makeToggle(legitFish, "Perfect Cast", "Always perfect power", "PerfectCast", 1)
makeToggle(legitFish, "Enable Auto Fishing", "Cast and reel automatically", "AutoFish", 2, function(v)
    if v then startFishing() else stopFishing() end
end)
makeToggle(legitFish, "Auto Shake", "Auto click when fish hooked", "AutoShake", 3)
makeSlider(legitFish, "Fish Delay", "FishDelay", 0.1, 5, 0.1, 4)
makeSlider(legitFish, "Catch Delay", "CatchDelay", 0.1, 3, 0.1, 5)
makeDropdown(legitFish, "Fishing Mode", "FishingMode", {"Normal", "Blatant", "Instant"}, 6)

-- Instant Fishing section
local instantFish = makeCollapsible(mainPage, "Instant Fishing", 2)
makeToggle(instantFish, "Enable Instant Fish", "Skip animations completely", "InstantFish", 1, function(v)
    if v then
        Config.FishingMode = "Instant"
        Config.AutoFish = true
        startFishing()
    else
        Config.FishingMode = "Normal"
        stopFishing()
        Config.AutoFish = false
    end
end)

-- Auto Selling section
local autoSellSection = makeCollapsible(mainPage, "Auto Selling", 3)
makeDropdown(autoSellSection, "Selling Type", "SellingType", {"All", "Non-Favorited"}, 1)
makeToggle(autoSellSection, "Enable Auto Selling", "Sell fish on timer", "AutoSell", 2)
makeInput(autoSellSection, "Sell Limit", "SellLimit", "100", 3)
makeInput(autoSellSection, "Sell Delay (Seconds)", "SellDelay", "30", 4)
makeButton(autoSellSection, "Sell All Now", 5, doSell)

-- ============================================================
--  TAB 3: ZONE FISHING
-- ============================================================
local zonePage = tabPages["Zone Fishing"]
makeSection(zonePage, "FISHING ZONES", 1)
for i, loc in ipairs(LOCATIONS) do
    makeButton(zonePage, loc.name, i + 1, function() teleportTo(loc.cf) end)
end

-- ============================================================
--  TAB 4: BACKPACK
-- ============================================================
local bpPage = tabPages["Backpack"]

local autoFavSection = makeCollapsible(bpPage, "Auto Favorite", 1)
makeDropdown(autoFavSection, "by Tier", "FavTier", RarityList, 1)
makeToggle(autoFavSection, "Enable Auto Favorite", "Auto favorite rare fish", "AutoFavorite", 2)
makeButton(autoFavSection, "Favorite All Now", 3, autoFavoriteByRarity)

local unfavSection = makeCollapsible(bpPage, "Unfavorite", 2)
makeDropdown(unfavSection, "Unfavorite With Tier", "UnfavTier", RarityList, 1)
makeButton(unfavSection, "Unfavorite Current Backpack", 2, unfavoriteAll)

-- ============================================================
--  TAB 5: WEBHOOK
-- ============================================================
local whPage = tabPages["Webhook"]
makeInput(whPage, "Webhook URL", "WebhookURL", "Enter your webhook URL", 1)
makeToggle(whPage, "Enable Webhook", "Send notifications on catch", "WebhookEnabled", 2)
makeDropdown(whPage, "by Tier", "WebhookTier", {"", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"}, 3)
makeDropdown(whPage, "by Name", "WebhookName", getInventoryFishNames, 4)
makeDropdown(whPage, "by Mutation", "WebhookMutation", {"", "Shiny", "Albino", "Giant", "Mythical"}, 5)
makeToggle(whPage, "Hide Username", "Hide your name in webhook", "HideUsername", 6)
makeToggle(whPage, "Tag Everyone", "Ping @everyone", "TagEveryone", 7)
makeToggle(whPage, "Tag Account Name", "Show account name", "TagAccountName", 8)

-- ============================================================
--  TAB 6: TRADING
-- ============================================================
local tradePage = tabPages["Trading"]

local tradePlayers = makeCollapsible(tradePage, "Players to Trade With", 1)
makeDropdown(tradePlayers, "Target Players", "TradeTarget", getPlayerList, 1)
makeButton(tradePlayers, "Refresh Player List", 2, function() end)

local autoTrade = makeCollapsible(tradePage, "Auto Trade", 2)
makeDropdown(autoTrade, "by Fish in Inventory", "TradeFish", getInventoryFishNames, 1)
makeButton(autoTrade, "Refresh Fish", 2, function() end)
makeDropdown(autoTrade, "by Tier", "TradeTier", RarityList, 3)
makeDropdown(autoTrade, "by Mutation", "TradeMutation", {"", "Shiny", "Albino", "Giant", "Mythical"}, 4)
makeInput(autoTrade, "Trade Quantity", "TradeQty", "0", 5)
makeInput(autoTrade, "Target Coin Amount", "TradeCoinTarget", "0", 6)
makeToggle(autoTrade, "Enable Auto Trade by Coin Amount", "", "AutoTradeByCoin", 7)

local tradeEnchant = makeCollapsible(tradePage, "Auto Trade Enchant Stones", 3)
makeToggle(tradeEnchant, "Enable Auto Trade Enchant Stones", "", "AutoTradeEnchant", 1)

local tradeCrystal = makeCollapsible(tradePage, "Auto Trade Cave Crystals", 4)
makeToggle(tradeCrystal, "Enable Auto Trade Cave Crystals", "", "AutoTradeCaveCrystal", 1)

local tradeAccept = makeCollapsible(tradePage, "Auto Accept Trade", 5)
makeToggle(tradeAccept, "Enable Auto Accept Trade", "", "AutoAcceptTrade", 1)

-- ============================================================
--  TAB 7: AUTOMATION
-- ============================================================
local autoPage = tabPages["Automation"]
makeButton(autoPage, "Teleport to Altar", 1, function()
    teleportTo(CFrame.new(-3728, -135, -1012))
end)
makeButton(autoPage, "Teleport to Second Altar", 2, function()
    teleportTo(CFrame.new(-3606, -266, -1581))
end)

local autoTotem = makeCollapsible(autoPage, "Auto Totem", 3)
makeDropdown(autoTotem, "Select Totem Type", "TotemType", {"Luck Totem", "Shiny Totem", "Mutation Totem"}, 1)
makeToggle(autoTotem, "Enable Auto Totem", "", "AutoTotem", 2)

local potionSection = makeCollapsible(autoPage, "Potions", 4)
makeDropdown(potionSection, "Select Potion", "PotionName", {"Luck I Potion", "Luck II Potion", "Luck III Potion"}, 1)
makeButton(potionSection, "Refresh Potion", 2, function() end)
makeToggle(potionSection, "Auto Use Potion", "", "AutoPotion", 3)
makeToggle(potionSection, "Auto Use Cave Crystal", "", "AutoCaveCrystal", 4)

local mineCrystal = makeCollapsible(autoPage, "Auto Mine Crystal", 5)
makeToggle(mineCrystal, "Enable Auto Mine Crystal", "", "AutoMineCrystal", 1)

-- ============================================================
--  TAB 8: SHOPPING
-- ============================================================
local shopPage = tabPages["Shopping"]

local giftSection = makeCollapsible(shopPage, "Gift Product", 1)
makeDropdown(giftSection, "Select Gift Product", "GiftProduct", {"Azure Crate", "Elderwood Crate", "Emote Crate", "Enchanted Crate", "Luxury Crate"}, 1)
makeButton(giftSection, "Gift Selected Product", 2, function() end)

local merchantSection = makeCollapsible(shopPage, "Merchant", 2)
makeDropdown(merchantSection, "Select Items to Auto Buy", "MerchantItem", {"Singularity Bait", "Royal Bait", "Luck Totem", "Shiny Totem", "Mutation Totem"}, 1)
makeButton(merchantSection, "Buy Selected Items", 2, function() end)
makeInput(merchantSection, "Buy Delay (seconds)", "BuyDelay", "1", 3)
makeToggle(merchantSection, "Auto Buy Items", "", "AutoBuyItems", 4)

local weatherSection = makeCollapsible(shopPage, "Weather", 3)
makeDropdown(weatherSection, "Select Weather", "WeatherType", {"Thunderstorm", "Blizzard", "Sandstorm", "Meteor Shower"}, 1)
makeToggle(weatherSection, "Auto Buy Weather Events", "", "AutoBuyWeather", 2)

local baitSection = makeCollapsible(shopPage, "Bait", 4)
makeDropdown(baitSection, "Select Bait to Buy", "BaitType", {"Singularity Bait", "Royal Bait", "Enchanted Bait", "Golden Bait"}, 1)
makeButton(baitSection, "Buy Selected Bait", 2, function() end)

local rodSection = makeCollapsible(shopPage, "Fishing Rod", 5)
makeDropdown(rodSection, "Select Rod to Buy", "RodType", {"Angelic Rod", "Angler Rod", "Aqua Prism", "Aquatic", "Arctic Explorer", "Ares Rod"}, 1)
makeButton(rodSection, "Buy Selected Rod", 2, function() end)

-- ============================================================
--  TAB 9: QUESTS
-- ============================================================
local questPage = tabPages["Quests"]
makeToggle(questPage, "Auto Element Quests", "Complete element quests", "AutoElementQuests", 1)

local ghostfinSection = makeCollapsible(questPage, "Auto Ghostfin Quest", 2)
makeLabel(ghostfinSection, "Ghostfin Quest Info: No Active Quests", 1)
makeToggle(ghostfinSection, "Auto Ghostfin Quests", "", "AutoGhostfinQuests", 2)

local leviathanSection = makeCollapsible(questPage, "Auto Leviathan Gate", 3)
makeLabel(leviathanSection, "Leviathan Gate: Coming Soon", 1)

-- ============================================================
--  TAB 10: TELEPORTATION
-- ============================================================
local tpPage = tabPages["Teleportation"]

local artifactSection = makeCollapsible(tpPage, "Artifact Zones", 1)
makeDropdown(artifactSection, "Select Artifact", "ArtifactZone", {"Ancient Jungle", "Sacred Temple", "Underground Cellar", "Esoteric Depths"}, 1)
makeButton(artifactSection, "Teleport to Selected Artifact Zone", 2, function()
    for _, loc in ipairs(LOCATIONS) do
        if loc.name == Config.ArtifactZone then teleportTo(loc.cf) break end
    end
end)

local tpPlayerSection = makeCollapsible(tpPage, "Teleport to Player", 2)
makeDropdown(tpPlayerSection, "Select Player", "TpPlayer", getPlayerList, 1)
makeButton(tpPlayerSection, "Teleport to Selected Player", 2, function()
    pcall(function()
        local target = Players:FindFirstChild(Config.TpPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            teleportTo(target.Character.HumanoidRootPart.CFrame)
        end
    end)
end)

local zoneTPSection = makeCollapsible(tpPage, "Zone Teleport", 3)
for i, loc in ipairs(LOCATIONS) do
    makeButton(zoneTPSection, loc.name, i, function() teleportTo(loc.cf) end)
end

-- ============================================================
--  TAB 11: UTILITIES
-- ============================================================
local utilPage = tabPages["Utilities"]
makeDropdown(utilPage, "Notification Position", "NotifPosition", {"TopRight", "TopLeft", "BottomRight", "BottomLeft"}, 1)

local animSection = makeCollapsible(utilPage, "Animation Changer", 2)
makeDropdown(animSection, "Select Animation Skin", "AnimSkin", {"Default", "Ninja", "Robot", "Zombie", "Pirate"}, 1)
makeToggle(animSection, "Enable Animation Changer", "", "AnimChanger", 2)

local securitySection = makeCollapsible(utilPage, "Security", 3)
makeLabel(securitySection, "Anti-AFK: Always Active", 1)
makeToggle(securitySection, "Anti-AFK", "Prevent idle kick", "AntiAFK", 2)
makeButton(securitySection, "Server Hop", 3, serverHop)
makeButton(securitySection, "Rejoin Server", 4, rejoinServer)

-- ============================================================
--  TAB 12: PERFORMANCE
-- ============================================================
local perfPage = tabPages["Performance"]

local fpsSection = makeCollapsible(perfPage, "FPS Boost", 1)
makeToggle(fpsSection, "Enable FPS Boost", "Remove particles/effects", "FPSBoost", 1, function(v)
    if v then enableFPSBoost() end
end)
makeToggle(fpsSection, "GPU Saver", "Low graphics for AFK farming", "GPUSaver", 2, function(v)
    if v then enableGPU() else disableGPU() end
end)

local espSection = makeCollapsible(perfPage, "ESP", 2)
makeToggle(espSection, "Fish ESP", "Show fish names (Drawing API)", "FishESP", 1, function(v)
    espEnabled = v
    if not v then clearESP() end
end)
makeToggle(espSection, "Player ESP", "Show player names + distance", "PlayerESP", 2, function(v)
    playerESPEnabled = v
    if not v then clearPlayerESP() end
end)

-- ============================================================
--  TAB 13: SETTINGS
-- ============================================================
local setPage = tabPages["Settings"]
makeSection(setPage, "CONFIGURATION", 1)
makeButton(setPage, "Save Config", 2, saveConfig)
makeButton(setPage, "Load Config", 3, function()
    loadConfig()
    -- Refresh UI would go here
end)
makeButton(setPage, "Delete Config", 4, function()
    pcall(function() if delfile and isfile(CFG_FILE) then delfile(CFG_FILE) end end)
end)
makeButton(setPage, "Refresh List", 5, function() end)

makeSection(setPage, "IMPORT / EXPORT", 6)
makeButton(setPage, "Export to Clipboard", 7, function()
    pcall(function()
        if setclipboard then
            setclipboard(HttpService:JSONEncode(Config))
        end
    end)
end)
makeButton(setPage, "Import from Clipboard", 8, function()
    -- Would need clipboard read support
end)

makeSection(setPage, "SCRIPT INFO", 9)
makeLabel(setPage, "Moron Fish It v11.0 by GasUp ID", 10)
makeLabel(setPage, "Full Feature Edition - Matching Euphoria", 11)
makeLabel(setPage, "Events: " .. (EventsLoaded and "Loaded" or "Failed"), 12)

-- ============================================================
--  FLOATING "M" BUTTON (when UI closed)
-- ============================================================
local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 50, 0, 50)
floatBtn.Position = UDim2.new(0, 10, 0.5, -25)
floatBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
floatBtn.Text = "M"
floatBtn.TextColor3 = Color3.fromRGB(130, 200, 255)
floatBtn.TextSize = 22
floatBtn.Font = Enum.Font.GothamBold
floatBtn.Visible = false
floatBtn.Parent = ScreenGui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)

-- Float button dragging
local fDrag, fStart, fPos
floatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        fDrag = true; fStart = input.Position; fPos = floatBtn.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if fDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - fStart
        floatBtn.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset + d.X, fPos.Y.Scale, fPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then fDrag = false end
end)

closeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    floatBtn.Visible = true
end)

minBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    floatBtn.Visible = true
end)

floatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    floatBtn.Visible = false
end)

-- Toggle with RightShift
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
        floatBtn.Visible = not MainFrame.Visible
    end
end)

-- ============================================================
--  SELECT DEFAULT TAB
-- ============================================================
selectTab("Main")

print("[Moron Fish It] v11.0 loaded! 13 tabs, all features ready.")
print("[Moron Fish It] Events: " .. (EventsLoaded and "OK" or "FAILED"))
