-- ====================================================================
--          MORON FISH IT v10.0 - by GasUp ID
--     No Key | No HWID | Free Forever | Undetected
-- ====================================================================

-- ==================== CLEANUP ====================
pcall(function()
    for _, v in pairs(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
        if v.Name == "MoronFishIt" then v:Destroy() end
    end
    if gethui then
        for _, v in pairs(gethui():GetChildren()) do
            if v.Name == "MoronFishIt" then v:Destroy() end
        end
    end
end)

-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer
local GUI_PARENT = (gethui and gethui()) or LP:WaitForChild("PlayerGui")

local VirtualUser
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

-- ==================== CONFIGURATION ====================
local DefaultConfig = {
    -- Fishing
    AutoFish = false,
    FishingMode = "Normal",
    AutoCatch = false,
    FishDelay = 0.9,
    CatchDelay = 0.2,
    -- Automation
    AutoSell = false,
    SellDelay = 30,
    AutoFavorite = true,
    FavRarity = "Mythic",
    AutoEnchant = false,
    AutoBuyRod = false,
    AutoBuyWeather = false,
    AutoQuest = false,
    AutoEvent = false,
    -- Movement
    WalkSpeed = 16,
    JumpPower = 50,
    InfJump = false,
    Fly = false,
    Noclip = false,
    AntiDrown = false,
    -- Utility
    GPUSaver = false,
    FPSBoost = false,
    AntiAFK = true,
    -- Visuals
    FishESP = false,
    PlayerESP = false,
}

local Config = {}
for k, v in pairs(DefaultConfig) do Config[k] = v end

local CONFIG_FOLDER = "MoronFishIt"
local CONFIG_FILE = CONFIG_FOLDER .. "/config.json"

local function ensureFolder()
    if not isfolder or not makefolder then return false end
    if not isfolder(CONFIG_FOLDER) then pcall(makefolder, CONFIG_FOLDER) end
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
        for k, v in pairs(data) do
            if DefaultConfig[k] ~= nil then Config[k] = v end
        end
    end)
end

loadConfig()

-- ==================== NETWORK EVENTS ====================
local Events = {}
local eventsLoaded = false
local eventsStatus = "Loading..."

task.spawn(function()
    local ok, err = pcall(function()
        local packages = RS:WaitForChild("Packages", 15)
        if not packages then error("Packages not found") end
        local index = packages:WaitForChild("_Index", 15)
        if not index then error("_Index not found") end

        -- Find sleitnick_net folder (any version)
        local netFolder
        for _, child in pairs(index:GetChildren()) do
            if child.Name:find("sleitnick_net") then
                netFolder = child
                break
            end
        end
        if not netFolder then
            -- Fallback hardcode
            netFolder = index:FindFirstChild("sleitnick_net@0.2.0")
        end
        if not netFolder then error("sleitnick_net not found in _Index") end

        local net = netFolder:WaitForChild("net", 10)
        if not net then error("net folder not found") end

        -- Load all events - names contain "/" as part of the actual name
        Events.fishing  = net:WaitForChild("RE/FishingCompleted", 8)
        Events.sell     = net:WaitForChild("RF/SellAllItems", 8)
        Events.charge   = net:WaitForChild("RF/ChargeFishingRod", 8)
        Events.minigame = net:WaitForChild("RF/RequestFishingMinigameStarted", 8)
        Events.cancel   = net:WaitForChild("RF/CancelFishingInputs", 8)
        Events.equip    = net:WaitForChild("RE/EquipToolFromHotbar", 8)
        Events.unequip  = net:WaitForChild("RE/UnequipToolFromHotbar", 8)
        Events.favorite = net:WaitForChild("RE/FavoriteItem", 8)

        local count = 0
        for _, v in pairs(Events) do if v then count = count + 1 end end

        if count >= 6 then
            eventsLoaded = true
            eventsStatus = "OK (" .. count .. "/8)"
        else
            eventsStatus = "Partial (" .. count .. "/8)"
        end
    end)
    if not ok then
        eventsStatus = "Error"
        warn("[MFI] Events: " .. tostring(err))
    end
end)

-- ==================== MODULES ====================
local ItemUtility, Replion, PlayerData
task.spawn(function()
    pcall(function()
        ItemUtility = require(RS.Shared.ItemUtility)
        Replion = require(RS.Packages.Replion)
        PlayerData = Replion.Client:WaitReplion("Data")
    end)
end)

local RarityTiers = {
    Common = 1, Uncommon = 2, Rare = 3,
    Epic = 4, Legendary = 5, Mythic = 6, Secret = 7
}

-- ==================== TELEPORT LOCATIONS ====================
local LOCATIONS = {
    {name = "Spawn", cf = CFrame.new(45.27, 252.56, 2987.10)},
    {name = "Sisyphus Statue", cf = CFrame.new(-3728.21, -135.07, -1012.12)},
    {name = "Coral Reefs", cf = CFrame.new(-3114.78, 1.32, 2237.52)},
    {name = "Esoteric Depths", cf = CFrame.new(3248.37, -1301.53, 1403.82)},
    {name = "Crater Island", cf = CFrame.new(1016.49, 20.09, 5069.27)},
    {name = "Lost Isle", cf = CFrame.new(-3618.15, 240.83, -1317.45)},
    {name = "Weather Machine", cf = CFrame.new(-1488.51, 83.17, 1876.30)},
    {name = "Tropical Grove", cf = CFrame.new(-2095.34, 197.19, 3718.08)},
    {name = "Mount Hallow", cf = CFrame.new(2136.62, 78.91, 3272.50)},
    {name = "Treasure Room", cf = CFrame.new(-3606.34, -266.57, -1580.97)},
    {name = "Kohana", cf = CFrame.new(-663.90, 3.04, 718.79)},
    {name = "Underground Cellar", cf = CFrame.new(2109.52, -94.18, -708.60)},
    {name = "Ancient Jungle", cf = CFrame.new(1831.71, 6.62, -299.27)},
    {name = "Sacred Temple", cf = CFrame.new(1466.92, -21.87, -622.83)},
}

-- ====================================================================
--                    CORE FEATURE FUNCTIONS
-- ====================================================================

-- ========== FISHING ==========
local isFishing = false
local fishingActive = false

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
                Events.minigame:InvokeServer(1.2854545116425, 1)
                task.wait(0.02)
                Events.fishing:FireServer()
            end)
            task.wait(0.1)
            isFishing = false
        else
            task.wait(0.01)
        end
    end
end

local function fishingLoop()
    while fishingActive do
        if not eventsLoaded then task.wait(1); continue end
        if Config.FishingMode == "Blatant" then
            blatantFishingLoop()
        elseif Config.FishingMode == "Instant" then
            instantFishingLoop()
        else
            normalFishingLoop()
        end
        task.wait(0.1)
    end
end

local function startFishing()
    fishingActive = true
    task.spawn(fishingLoop)
end

local function stopFishing()
    fishingActive = false
    pcall(function() Events.unequip:FireServer() end)
end

-- ========== AUTO CATCH (background reel spam) ==========
task.spawn(function()
    while true do
        if Config.AutoCatch and not isFishing and eventsLoaded then
            pcall(function() Events.fishing:FireServer() end)
        end
        task.wait(Config.CatchDelay)
    end
end)

-- ========== AUTO SELL ==========
local function doSell()
    if not eventsLoaded or not Events.sell then return end
    pcall(function() Events.sell:InvokeServer() end)
end

task.spawn(function()
    while true do
        task.wait(Config.SellDelay)
        if Config.AutoSell and eventsLoaded then doSell() end
    end
end)

-- ========== AUTO FAVORITE ==========
local favoritedItems = {}

local function autoFavoriteByRarity()
    if not Config.AutoFavorite or not PlayerData or not ItemUtility then return end
    pcall(function()
        local items = PlayerData:GetExpect("Inventory").Items
        if not items or #items == 0 then return end
        local targetValue = RarityTiers[Config.FavRarity] or 6
        for _, item in ipairs(items) do
            local data = ItemUtility:GetItemData(item.Id)
            if data and data.Data then
                local rarity = data.Data.Rarity or "Common"
                local rarityValue = RarityTiers[rarity] or 0
                if rarityValue >= targetValue and not item.Favorited and not favoritedItems[item.UUID] then
                    Events.favorite:FireServer(item.UUID)
                    favoritedItems[item.UUID] = true
                    task.wait(0.3)
                end
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

-- ========== AUTO ENCHANT ==========
local function doEnchant()
    if not eventsLoaded then return end
    pcall(function()
        local net = RS.Packages._Index
        local enchantEvent
        for _, child in pairs(net:GetDescendants()) do
            if child.Name == "RE/EnchantItem" or child.Name == "RF/EnchantItem" then
                enchantEvent = child
                break
            end
        end
        if enchantEvent then
            if enchantEvent:IsA("RemoteEvent") then
                enchantEvent:FireServer()
            elseif enchantEvent:IsA("RemoteFunction") then
                enchantEvent:InvokeServer()
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(15)
        if Config.AutoEnchant and eventsLoaded then doEnchant() end
    end
end)

-- ========== AUTO BUY ROD ==========
local function doBuyRod()
    if not eventsLoaded then return end
    pcall(function()
        local net = RS.Packages._Index
        local buyEvent
        for _, child in pairs(net:GetDescendants()) do
            if child.Name == "RF/PurchaseItem" or child.Name == "RE/PurchaseItem" then
                buyEvent = child
                break
            end
        end
        if buyEvent then
            if buyEvent:IsA("RemoteFunction") then
                buyEvent:InvokeServer("Rod")
            elseif buyEvent:IsA("RemoteEvent") then
                buyEvent:FireServer("Rod")
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(60)
        if Config.AutoBuyRod and eventsLoaded then doBuyRod() end
    end
end)

-- ========== AUTO BUY WEATHER ==========
local function doBuyWeather()
    if not eventsLoaded then return end
    pcall(function()
        local net = RS.Packages._Index
        local weatherEvent
        for _, child in pairs(net:GetDescendants()) do
            if child.Name == "RF/PurchaseWeather" or child.Name == "RE/PurchaseWeather" or child.Name == "RF/BuyWeather" then
                weatherEvent = child
                break
            end
        end
        if weatherEvent then
            if weatherEvent:IsA("RemoteFunction") then
                weatherEvent:InvokeServer()
            elseif weatherEvent:IsA("RemoteEvent") then
                weatherEvent:FireServer()
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(120)
        if Config.AutoBuyWeather and eventsLoaded then doBuyWeather() end
    end
end)

-- ========== AUTO QUEST ==========
local function doQuest()
    if not eventsLoaded then return end
    pcall(function()
        local net = RS.Packages._Index
        for _, child in pairs(net:GetDescendants()) do
            if child.Name:find("Quest") and (child:IsA("RemoteEvent") or child:IsA("RemoteFunction")) then
                if child.Name:find("Accept") or child.Name:find("Claim") or child.Name:find("Complete") then
                    if child:IsA("RemoteEvent") then
                        child:FireServer()
                    else
                        child:InvokeServer()
                    end
                    task.wait(0.5)
                end
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(30)
        if Config.AutoQuest and eventsLoaded then doQuest() end
    end
end)

-- ========== AUTO EVENT ==========
local function doEvent()
    if not eventsLoaded then return end
    pcall(function()
        local net = RS.Packages._Index
        for _, child in pairs(net:GetDescendants()) do
            if child.Name:find("Event") and not child.Name:find("Fishing") and (child:IsA("RemoteEvent") or child:IsA("RemoteFunction")) then
                if child.Name:find("Join") or child.Name:find("Start") or child.Name:find("Claim") then
                    if child:IsA("RemoteEvent") then
                        child:FireServer()
                    else
                        child:InvokeServer()
                    end
                    task.wait(0.5)
                end
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(45)
        if Config.AutoEvent and eventsLoaded then doEvent() end
    end
end)

-- ========== TELEPORT ==========
local function teleportTo(cf)
    pcall(function()
        local character = LP.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = cf
        end
    end)
end

-- ========== MOVEMENT ==========
task.spawn(function()
    while true do
        pcall(function()
            local c = LP.Character
            if not c then return end
            local hum = c:FindFirstChildOfClass("Humanoid")
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hum then
                if Config.WalkSpeed ~= 16 then hum.WalkSpeed = Config.WalkSpeed end
                if Config.JumpPower ~= 50 then hum.JumpPower = Config.JumpPower end
            end
            if Config.Noclip then
                for _, p in pairs(c:GetDescendants()) do
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

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    if Config.InfJump then
        pcall(function()
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end)

-- Fly
local flyBV = nil
task.spawn(function()
    while true do
        pcall(function()
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if Config.Fly and hrp then
                if not flyBV then
                    flyBV = Instance.new("BodyVelocity")
                    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    flyBV.Velocity = Vector3.new(0, 0, 0)
                    flyBV.Parent = hrp
                end
                local cam = workspace.CurrentCamera
                local dir = Vector3.new(0, 0, 0)
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                flyBV.Velocity = dir * 80
            else
                if flyBV then flyBV:Destroy(); flyBV = nil end
            end
        end)
        task.wait(0.05)
    end
end)

-- ========== GPU SAVER ==========
local gpuActive = false
local gpuScreen = nil

local function enableGPU()
    if gpuActive then return end
    gpuActive = true
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1
        if setfpscap then setfpscap(8) end
    end)
    gpuScreen = Instance.new("ScreenGui")
    gpuScreen.Name = "MFI_GPU"
    gpuScreen.ResetOnSpawn = false
    gpuScreen.DisplayOrder = 999999
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
    gpuScreen.Parent = GUI_PARENT
end

local function disableGPU()
    if not gpuActive then return end
    gpuActive = false
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000
        if setfpscap then setfpscap(0) end
    end)
    if gpuScreen then gpuScreen:Destroy(); gpuScreen = nil end
end

-- ========== FPS BOOST ==========
local function fpsBoost()
    pcall(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam")
                or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled = false
            end
        end
        if setfpscap then setfpscap(60) end
    end)
end

-- ========== ANTI-AFK ==========
if VirtualUser then
    LP.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

-- ========== ESP ==========
-- Fish ESP
task.spawn(function()
    local drawings = {}
    while true do
        pcall(function()
            for _, d in pairs(drawings) do pcall(function() d:Remove() end) end
            drawings = {}
            if Config.FishESP and Drawing then
                local cam = workspace.CurrentCamera
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") == nil and v.Name:find("Fish") then
                        local ok2, pos = pcall(function() return v:GetPivot().Position end)
                        if ok2 then
                            local sp, onScreen = cam:WorldToViewportPoint(pos)
                            if onScreen then
                                local txt = Drawing.new("Text")
                                txt.Text = v.Name
                                txt.Position = Vector2.new(sp.X, sp.Y)
                                txt.Color = Color3.fromRGB(0, 200, 130)
                                txt.Size = 13
                                txt.Center = true
                                txt.Outline = true
                                txt.Visible = true
                                table.insert(drawings, txt)
                            end
                        end
                    end
                end
            end
        end)
        task.wait(1)
    end
end)

-- Player ESP
task.spawn(function()
    local drawings = {}
    while true do
        pcall(function()
            for _, d in pairs(drawings) do pcall(function() d:Remove() end) end
            drawings = {}
            if Config.PlayerESP and Drawing then
                local cam = workspace.CurrentCamera
                local myPos = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    and LP.Character.HumanoidRootPart.Position
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local pos = p.Character.HumanoidRootPart.Position
                        local sp, onScreen = cam:WorldToViewportPoint(pos)
                        if onScreen then
                            local dist = myPos and math.floor((myPos - pos).Magnitude) or 0
                            local txt = Drawing.new("Text")
                            txt.Text = p.Name .. " [" .. dist .. "m]"
                            txt.Position = Vector2.new(sp.X, sp.Y - 20)
                            txt.Color = Color3.fromRGB(255, 255, 255)
                            txt.Size = 13
                            txt.Center = true
                            txt.Outline = true
                            txt.Visible = true
                            table.insert(drawings, txt)
                        end
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end)

-- ========== SERVER HOP ==========
local function serverHop()
    pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local data = HttpService:JSONDecode(game:HttpGet(url))
        for _, s in pairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id)
                return
            end
        end
    end)
end

local function rejoinServer()
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId) end)
end

-- ====================================================================
--                    SPLASH SCREEN
-- ====================================================================
local splashGui = Instance.new("ScreenGui")
splashGui.Name = "MFI_Splash"
splashGui.ResetOnSpawn = false
splashGui.Parent = GUI_PARENT

local splashFrame = Instance.new("Frame", splashGui)
splashFrame.Size = UDim2.new(0, 200, 0, 65)
splashFrame.Position = UDim2.new(0.5, -100, 0.5, -32)
splashFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
splashFrame.BorderSizePixel = 0
Instance.new("UICorner", splashFrame).CornerRadius = UDim.new(0, 10)

local splashTitle = Instance.new("TextLabel", splashFrame)
splashTitle.Size = UDim2.new(1, 0, 0, 30)
splashTitle.Position = UDim2.new(0, 0, 0, 8)
splashTitle.BackgroundTransparency = 1
splashTitle.Text = "GasUp ID"
splashTitle.TextColor3 = Color3.fromRGB(0, 200, 130)
splashTitle.TextSize = 20
splashTitle.Font = Enum.Font.GothamBold

local splashSub = Instance.new("TextLabel", splashFrame)
splashSub.Size = UDim2.new(1, 0, 0, 18)
splashSub.Position = UDim2.new(0, 0, 0, 38)
splashSub.BackgroundTransparency = 1
splashSub.Text = "Moron Fish It v10.0"
splashSub.TextColor3 = Color3.fromRGB(160, 160, 170)
splashSub.TextSize = 12
splashSub.Font = Enum.Font.Gotham

task.wait(1.5)
splashGui:Destroy()

-- ====================================================================
--                    MAIN UI
-- ====================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoronFishIt"
screenGui.ResetOnSpawn = false
screenGui.Parent = GUI_PARENT

-- Main Frame
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 470, 0, 340)
mainFrame.Position = UDim2.new(0.5, -235, 0.5, -170)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Top Bar
local topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, 0, 0, 36)
topBar.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
topBar.BorderSizePixel = 0
topBar.ZIndex = 5
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)
local topFix = Instance.new("Frame", topBar)
topFix.Size = UDim2.new(1, 0, 0, 14)
topFix.Position = UDim2.new(0, 0, 1, -14)
topFix.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
topFix.BorderSizePixel = 0
topFix.ZIndex = 5

-- Title
local titleLabel = Instance.new("TextLabel", topBar)
titleLabel.Size = UDim2.new(0, 130, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Moron Fish It"
titleLabel.TextColor3 = Color3.fromRGB(0, 200, 130)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 6

-- Version
local verLabel = Instance.new("TextLabel", topBar)
verLabel.Size = UDim2.new(0, 35, 1, 0)
verLabel.Position = UDim2.new(0, 142, 0, 0)
verLabel.BackgroundTransparency = 1
verLabel.Text = "v10"
verLabel.TextColor3 = Color3.fromRGB(70, 70, 80)
verLabel.TextSize = 10
verLabel.Font = Enum.Font.Gotham
verLabel.TextXAlignment = Enum.TextXAlignment.Left
verLabel.ZIndex = 6

-- Status label
local statusLabel = Instance.new("TextLabel", topBar)
statusLabel.Size = UDim2.new(0, 100, 1, 0)
statusLabel.Position = UDim2.new(1, -145, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = eventsStatus
statusLabel.TextColor3 = Color3.fromRGB(70, 70, 80)
statusLabel.TextSize = 9
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Right
statusLabel.ZIndex = 6

task.spawn(function()
    while statusLabel and statusLabel.Parent do
        pcall(function()
            statusLabel.Text = eventsStatus
            statusLabel.TextColor3 = eventsLoaded and Color3.fromRGB(0, 160, 100) or Color3.fromRGB(180, 80, 80)
        end)
        task.wait(1)
    end
end)

-- Close button
local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -36, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "x"
closeBtn.TextColor3 = Color3.fromRGB(120, 120, 130)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.ZIndex = 7

-- Drag
local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
topBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Sidebar
local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0, 120, 1, -36)
sidebar.Position = UDim2.new(0, 0, 0, 36)
sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
sidebar.BorderSizePixel = 0

local sidebarSep = Instance.new("Frame", sidebar)
sidebarSep.Size = UDim2.new(0, 1, 1, 0)
sidebarSep.Position = UDim2.new(1, 0, 0, 0)
sidebarSep.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
sidebarSep.BorderSizePixel = 0

-- Content area
local contentArea = Instance.new("Frame", mainFrame)
contentArea.Size = UDim2.new(1, -121, 1, -36)
contentArea.Position = UDim2.new(0, 121, 0, 36)
contentArea.BackgroundTransparency = 1
contentArea.ClipsDescendants = true

-- Tab system
local TABS = {"Fishing", "Automation", "Teleport", "Movement", "Utility", "Visuals", "Settings"}
local currentTab = "Fishing"
local tabButtons = {}
local tabPages = {}

-- Sidebar buttons
local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Padding = UDim.new(0, 2)
Instance.new("UIPadding", sidebar).PaddingTop = UDim.new(0, 6)

for i, tabName in ipairs(TABS) do
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = "    " .. tabName
    btn.TextColor3 = Color3.fromRGB(140, 140, 150)
    btn.TextSize = 12
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = i

    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(0, 3, 0, 16)
    indicator.Position = UDim2.new(0, 0, 0.5, -8)
    indicator.BackgroundColor3 = Color3.fromRGB(0, 200, 130)
    indicator.BorderSizePixel = 0
    indicator.Visible = (tabName == currentTab)
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 2)

    tabButtons[tabName] = {btn = btn, indicator = indicator}
end

-- Create page scrollframes
for _, tabName in ipairs(TABS) do
    local scroll = Instance.new("ScrollingFrame", contentArea)
    scroll.Size = UDim2.new(1, -4, 1, -4)
    scroll.Position = UDim2.new(0, 2, 0, 2)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Visible = (tabName == currentTab)

    local layout = Instance.new("UIListLayout", scroll)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    local padding = Instance.new("UIPadding", scroll)
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.PaddingTop = UDim.new(0, 6)

    tabPages[tabName] = scroll
end

-- Tab switching
local function switchTab(name)
    currentTab = name
    for tn, data in pairs(tabButtons) do
        local active = (tn == name)
        data.indicator.Visible = active
        data.btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 150)
        data.btn.Font = active and Enum.Font.GothamBold or Enum.Font.Gotham
    end
    for pn, page in pairs(tabPages) do
        page.Visible = (pn == name)
    end
end

for tn, data in pairs(tabButtons) do
    data.btn.MouseButton1Click:Connect(function() switchTab(tn) end)
end

-- ====================================================================
--                    UI COMPONENT BUILDERS
-- ====================================================================
local function makeSection(page, text, order)
    local label = Instance.new("TextLabel", page)
    label.Size = UDim2.new(1, 0, 0, 22)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(80, 80, 95)
    label.TextSize = 10
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = order
end

local function makeToggle(page, title, desc, configKey, order, callback)
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.new(1, 0, 0, desc and 40 or 32)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local titleLbl = Instance.new("TextLabel", frame)
    titleLbl.Size = UDim2.new(1, -60, 0, 18)
    titleLbl.Position = UDim2.new(0, 12, 0, desc and 4 or 7)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(210, 210, 220)
    titleLbl.TextSize = 12
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    if desc then
        local descLbl = Instance.new("TextLabel", frame)
        descLbl.Size = UDim2.new(1, -60, 0, 14)
        descLbl.Position = UDim2.new(0, 12, 0, 22)
        descLbl.BackgroundTransparency = 1
        descLbl.Text = desc
        descLbl.TextColor3 = Color3.fromRGB(70, 70, 85)
        descLbl.TextSize = 9
        descLbl.Font = Enum.Font.Gotham
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
    end

    local toggleBg = Instance.new("Frame", frame)
    toggleBg.Size = UDim2.new(0, 38, 0, 20)
    toggleBg.Position = UDim2.new(1, -50, 0.5, -10)
    toggleBg.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 190, 120) or Color3.fromRGB(50, 50, 60)
    toggleBg.BorderSizePixel = 0
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", toggleBg)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = Config[configKey] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local clickBtn = Instance.new("TextButton", frame)
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 2

    clickBtn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        local on = Config[configKey]
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
        TweenService:Create(toggleBg, tweenInfo, {BackgroundColor3 = on and Color3.fromRGB(0, 190, 120) or Color3.fromRGB(50, 50, 60)}):Play()
        TweenService:Create(knob, tweenInfo, {Position = on and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        saveConfig()
        if callback then callback(on) end
    end)
end

local function makeButton(page, title, order, callback)
    local btn = Instance.new("TextButton", page)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    btn.BorderSizePixel = 0
    btn.Text = title
    btn.TextColor3 = Color3.fromRGB(190, 190, 200)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamMedium
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(function() if callback then callback() end end)
end

local function makeSlider(page, title, configKey, minVal, maxVal, step, order)
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.new(1, 0, 0, 46)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local titleLbl = Instance.new("TextLabel", frame)
    titleLbl.Size = UDim2.new(1, -55, 0, 18)
    titleLbl.Position = UDim2.new(0, 12, 0, 4)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(210, 210, 220)
    titleLbl.TextSize = 12
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local valLabel = Instance.new("TextLabel", frame)
    valLabel.Size = UDim2.new(0, 45, 0, 18)
    valLabel.Position = UDim2.new(1, -55, 0, 4)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(Config[configKey])
    valLabel.TextColor3 = Color3.fromRGB(0, 190, 120)
    valLabel.TextSize = 11
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextXAlignment = Enum.TextXAlignment.Right

    local sliderBg = Instance.new("Frame", frame)
    sliderBg.Size = UDim2.new(1, -24, 0, 4)
    sliderBg.Position = UDim2.new(0, 12, 0, 32)
    sliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    sliderBg.BorderSizePixel = 0
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

    local pct = math.clamp((Config[configKey] - minVal) / (maxVal - minVal), 0, 1)
    local fillBar = Instance.new("Frame", sliderBg)
    fillBar.Size = UDim2.new(pct, 0, 1, 0)
    fillBar.BackgroundColor3 = Color3.fromRGB(0, 190, 120)
    fillBar.BorderSizePixel = 0
    Instance.new("UICorner", fillBar).CornerRadius = UDim.new(1, 0)

    local sliderBtn = Instance.new("TextButton", frame)
    sliderBtn.Size = UDim2.new(1, -20, 0, 18)
    sliderBtn.Position = UDim2.new(0, 10, 0, 24)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.ZIndex = 2

    local sliding = false
    local function updateSlider(inputPos)
        local absPos = sliderBg.AbsolutePosition
        local absSize = sliderBg.AbsoluteSize
        local rel = math.clamp((inputPos.X - absPos.X) / absSize.X, 0, 1)
        local val = minVal + (maxVal - minVal) * rel
        val = math.floor(val / step + 0.5) * step
        val = math.clamp(val, minVal, maxVal)
        if step < 1 then val = math.floor(val * 10 + 0.5) / 10 end
        Config[configKey] = val
        valLabel.Text = tostring(val)
        fillBar.Size = UDim2.new(math.clamp((val - minVal) / (maxVal - minVal), 0, 1), 0, 1, 0)
        saveConfig()
    end

    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateSlider(input.Position)
        end
    end)
    sliderBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position)
        end
    end)
end

local function makeDropdown(page, title, configKey, options, order)
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local titleLbl = Instance.new("TextLabel", frame)
    titleLbl.Size = UDim2.new(0.5, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(210, 210, 220)
    titleLbl.TextSize = 12
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local currentBtn = Instance.new("TextButton", frame)
    currentBtn.Size = UDim2.new(0.4, 0, 0, 24)
    currentBtn.Position = UDim2.new(0.55, 0, 0.5, -12)
    currentBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    currentBtn.BorderSizePixel = 0
    currentBtn.Text = tostring(Config[configKey])
    currentBtn.TextColor3 = Color3.fromRGB(0, 190, 120)
    currentBtn.TextSize = 11
    currentBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", currentBtn).CornerRadius = UDim.new(0, 6)

    local idx = 1
    for i, v in ipairs(options) do
        if v == Config[configKey] then idx = i end
    end

    currentBtn.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        Config[configKey] = options[idx]
        currentBtn.Text = options[idx]
        saveConfig()
    end)
end

-- ====================================================================
--                    POPULATE ALL PAGES
-- ====================================================================

-- ========== TAB 1: FISHING ==========
local fishPage = tabPages["Fishing"]
makeSection(fishPage, "FISHING", 1)
makeToggle(fishPage, "Auto Fish", "Cast and reel automatically", "AutoFish", 2, function(on)
    if on then startFishing() else stopFishing() end
end)
makeDropdown(fishPage, "Fishing Mode", "FishingMode", {"Normal", "Blatant", "Instant"}, 3)
makeToggle(fishPage, "Auto Catch", "Background reel spam for speed", "AutoCatch", 4)
makeSection(fishPage, "TIMING", 5)
makeSlider(fishPage, "Fish Delay", "FishDelay", 0.1, 5, 0.1, 6)
makeSlider(fishPage, "Catch Delay", "CatchDelay", 0.1, 3, 0.1, 7)
makeSection(fishPage, "QUICK ACTIONS", 8)
makeButton(fishPage, "Sell All Now", 9, doSell)
makeButton(fishPage, "Favorite All Now", 10, autoFavoriteByRarity)

-- ========== TAB 2: AUTOMATION ==========
local autoPage = tabPages["Automation"]
makeSection(autoPage, "SELLING", 1)
makeToggle(autoPage, "Auto Sell", "Sell non-favorited fish on timer", "AutoSell", 2)
makeSlider(autoPage, "Sell Interval (sec)", "SellDelay", 10, 300, 5, 3)
makeSection(autoPage, "FAVORITES", 4)
makeToggle(autoPage, "Auto Favorite", "Auto favorite rare fish", "AutoFavorite", 5)
makeDropdown(autoPage, "Min Rarity", "FavRarity", {"Legendary", "Mythic", "Secret"}, 6)
makeSection(autoPage, "ADVANCED", 7)
makeToggle(autoPage, "Auto Enchant", "Enchant equipped rod", "AutoEnchant", 8)
makeToggle(autoPage, "Auto Buy Rod", "Buy best available rod", "AutoBuyRod", 9)
makeToggle(autoPage, "Auto Buy Weather", "Buy weather items", "AutoBuyWeather", 10)
makeToggle(autoPage, "Auto Quest", "Accept and claim quests", "AutoQuest", 11)
makeToggle(autoPage, "Auto Event", "Join events automatically", "AutoEvent", 12)

-- ========== TAB 3: TELEPORT ==========
local tpPage = tabPages["Teleport"]
makeSection(tpPage, "ISLANDS", 1)
for i, loc in ipairs(LOCATIONS) do
    makeButton(tpPage, loc.name, i + 1, function() teleportTo(loc.cf) end)
end

-- ========== TAB 4: MOVEMENT ==========
local movePage = tabPages["Movement"]
makeSection(movePage, "SPEED", 1)
makeSlider(movePage, "Walk Speed", "WalkSpeed", 16, 200, 1, 2)
makeSlider(movePage, "Jump Power", "JumpPower", 50, 300, 5, 3)
makeSection(movePage, "ABILITIES", 4)
makeToggle(movePage, "Infinite Jump", "Jump in mid-air", "InfJump", 5)
makeToggle(movePage, "Fly", "WASD + Space/Shift to fly", "Fly", 6)
makeToggle(movePage, "Noclip", "Walk through walls", "Noclip", 7)
makeToggle(movePage, "Anti Drown", "Auto resurface underwater", "AntiDrown", 8)

-- ========== TAB 5: UTILITY ==========
local utilPage = tabPages["Utility"]
makeSection(utilPage, "PERFORMANCE", 1)
makeToggle(utilPage, "GPU Saver", "Low graphics for AFK farming", "GPUSaver", 2, function(on)
    if on then enableGPU() else disableGPU() end
end)
makeToggle(utilPage, "FPS Boost", "Remove particles and effects", "FPSBoost", 3, function(on)
    if on then fpsBoost() end
end)
makeToggle(utilPage, "Anti-AFK", "Prevent idle kick", "AntiAFK", 4)
makeSection(utilPage, "SERVER", 5)
makeButton(utilPage, "Server Hop", 6, serverHop)
makeButton(utilPage, "Rejoin Server", 7, rejoinServer)

-- ========== TAB 6: VISUALS ==========
local visPage = tabPages["Visuals"]
makeSection(visPage, "ESP", 1)
makeToggle(visPage, "Fish ESP", "Show fish names (Drawing API)", "FishESP", 2)
makeToggle(visPage, "Player ESP", "Show player names + distance", "PlayerESP", 3)

-- ========== TAB 7: SETTINGS ==========
local setPage = tabPages["Settings"]
makeSection(setPage, "CONFIGURATION", 1)
makeButton(setPage, "Save Config", 2, saveConfig)
makeButton(setPage, "Load Config", 3, function()
    loadConfig()
    -- Notify
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Moron Fish It",
            Text = "Config loaded!",
            Duration = 3
        })
    end)
end)
makeButton(setPage, "Reset to Default", 4, function()
    for k, v in pairs(DefaultConfig) do Config[k] = v end
    saveConfig()
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Moron Fish It",
            Text = "Config reset!",
            Duration = 3
        })
    end)
end)
makeSection(setPage, "SCRIPT INFO", 5)
local infoLabel = Instance.new("TextLabel", setPage)
infoLabel.Size = UDim2.new(1, 0, 0, 70)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Moron Fish It v10.0\nby GasUp ID\n\nNo Key | No HWID | Free Forever\nEvents: " .. eventsStatus
infoLabel.TextColor3 = Color3.fromRGB(80, 80, 95)
infoLabel.TextSize = 10
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.LayoutOrder = 6
infoLabel.TextWrapped = true

task.spawn(function()
    while infoLabel and infoLabel.Parent do
        pcall(function()
            infoLabel.Text = "Moron Fish It v10.0\nby GasUp ID\n\nNo Key | No HWID | Free Forever\nEvents: " .. eventsStatus
        end)
        task.wait(2)
    end
end)

-- Initialize first tab
switchTab("Fishing")

-- ====================================================================
--                    FLOATING BUTTON
-- ====================================================================
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

floatBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    floatBtn.Visible = false
end)

-- Float drag (mobile)
local fDrag, fDragStart, fStartPos
floatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        fDrag = true
        fDragStart = input.Position
        fStartPos = floatBtn.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if fDrag and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - fDragStart
        floatBtn.Position = UDim2.new(fStartPos.X.Scale, fStartPos.X.Offset + delta.X, fStartPos.Y.Scale, fStartPos.Y.Offset + delta.Y)
    end
end)
floatBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then fDrag = false end
end)

-- Close/Open
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    floatBtn.Visible = true
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
        floatBtn.Visible = not mainFrame.Visible
    end
end)

-- ====================================================================
print("[Moron Fish It] v10.0 Loaded - GasUp ID")
print("[Moron Fish It] Events: " .. eventsStatus)
print("[Moron Fish It] No Key | No HWID | Free Forever")
