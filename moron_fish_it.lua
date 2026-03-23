--[[
    MORON FISH IT v2.2.0
    Game: Fish It! (Roblox)
--]]

-- =====================================================================
--  ANTI-DETECTION: Randomized naming to avoid GUI scanners
-- =====================================================================
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

local GUI_NAME = rName(12)
local SPLASH_NAME = rName(10)

-- =====================================================================
--  SAFE GUI PARENT: Use PlayerGui to avoid CoreGui detection
-- =====================================================================
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local guiParent
do
    -- PlayerGui is safest for anti-cheat bypass
    local ok, pg = pcall(function() return LP:WaitForChild("PlayerGui", 10) end)
    if ok and pg then
        guiParent = pg
    else
        -- Fallback chain
        local ok2, hui = pcall(function() return gethui and gethui() end)
        if ok2 and hui then
            guiParent = hui
        else
            pcall(function()
                guiParent = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
            end)
        end
    end
end

-- Cleanup old instances (randomized search)
pcall(function()
    for _, g in ipairs(guiParent:GetChildren()) do
        if g:IsA("ScreenGui") and g:GetAttribute("_mfi") == true then
            g:Destroy()
        end
    end
end)

-- =====================================================================
--  CORE SERVICES
-- =====================================================================
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

local VirtualUser
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

-- =====================================================================
--  ANTI-DETECTION UTILITIES
-- =====================================================================
local function randDelay(lo, hi)
    return lo + _rng:NextNumber() * (hi - lo)
end

local function humanWait(base)
    local t = base * (0.82 + _rng:NextNumber() * 0.36)
    if t < 0.01 then t = 0.01 end
    task.wait(t)
end

local function safeFire(remote, ...)
    if not remote then return end
    local args = {...}
    task.defer(function()
        pcall(function() remote:FireServer(unpack(args)) end)
    end)
end

local function safeInvoke(remote, ...)
    if not remote then return nil end
    local args = {...}
    local ok, res = pcall(function() return remote:InvokeServer(unpack(args)) end)
    return ok and res or nil
end

-- =====================================================================
--  CONFIGURATION
-- =====================================================================
local CFG_DIR = "MoronFishIt"
local CFG_FILE = CFG_DIR .. "/cfg_" .. tostring(LP.UserId) .. ".json"

local Default = {
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

local Cfg = {}
for k, v in pairs(Default) do Cfg[k] = v end

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
        for k, v in pairs(d) do
            if Default[k] ~= nil then Cfg[k] = v end
        end
    end)
end
cfgLoad()

-- =====================================================================
--  MAP & NPC LOCATIONS
-- =====================================================================
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

-- =====================================================================
--  NETWORK EVENTS
-- =====================================================================
local Ev = {}
pcall(function()
    local net = RepStorage:WaitForChild("Packages", 5)
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

-- =====================================================================
--  GAME MODULES
-- =====================================================================
local ItemUtil, Replion, PData
pcall(function()
    local shared = RepStorage:FindFirstChild("Shared")
    if shared then
        local iu = shared:FindFirstChild("ItemUtility")
        if iu then ItemUtil = require(iu) end
    end
end)
pcall(function()
    local pkgs = RepStorage:FindFirstChild("Packages")
    if pkgs then
        local rep = pkgs:FindFirstChild("Replion")
        if rep then
            Replion = require(rep)
            PData = Replion.Client:WaitReplion("Data")
        end
    end
end)

local Rarity = {Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5, Mythic = 6, Secret = 7}

-- =====================================================================
--  UTILITY FUNCTIONS
-- =====================================================================
local function notify(t, m, d)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = t or "MFI", Text = m or "", Duration = d or 4})
    end)
end

local function sendWebhook(title, desc, col)
    if not Cfg.WebhookOn or Cfg.WebhookURL == "" then return end
    task.spawn(function()
        pcall(function()
            local body = HttpService:JSONEncode({
                embeds = {{title = title, description = desc, color = col or 3066993,
                    footer = {text = "Moron Fish It v2.2 | " .. os.date("%H:%M:%S")}}}
            })
            local rf = (syn and syn.request) or (http and http.request) or request or http_request or (fluxus and fluxus.request)
            if rf then rf({Url = Cfg.WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = body}) end
        end)
    end)
end

-- =====================================================================
--  TELEPORT (Smooth)
-- =====================================================================
local function smoothTP(cf)
    local ch = LP.Character
    if not ch then return false end
    local r = ch:FindFirstChild("HumanoidRootPart")
    if not r then return false end
    local dist = (r.Position - cf.Position).Magnitude
    if dist < 400 then
        humanWait(0.08)
        r.CFrame = cf
    else
        local steps = math.clamp(math.floor(dist / 250), 2, 6)
        for i = 1, steps do
            r.CFrame = r.CFrame:Lerp(cf, i / steps)
            humanWait(0.04)
        end
    end
    return true
end

local function tpTo(name)
    for _, t in ipairs(Islands) do
        if t[1] == name then smoothTP(t[2]) notify("TP", name) return true end
    end
    for _, t in ipairs(NPCs) do
        if t[1] == name then smoothTP(t[2]) notify("TP", name) return true end
    end
    return false
end

-- =====================================================================
--  GPU SAVER / FPS BOOST
-- =====================================================================
local gpuOn = false
local gpuGui = nil
local origLight = {}

local function gpuEnable()
    if gpuOn then return end
    gpuOn = true
    pcall(function()
        origLight.GS = Lighting.GlobalShadows
        origLight.FE = Lighting.FogEnd
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1
        if setfpscap then setfpscap(10) end
    end)
    pcall(function()
        gpuGui = Instance.new("ScreenGui")
        gpuGui.Name = rName(8)
        gpuGui.ResetOnSpawn = false
        gpuGui.DisplayOrder = 999999
        local f = Instance.new("Frame", gpuGui)
        f.Size = UDim2.new(1, 0, 1, 0)
        f.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(0, 500, 0, 100)
        l.Position = UDim2.new(0.5, -250, 0.5, -50)
        l.BackgroundTransparency = 1
        l.Text = "GPU SAVER ACTIVE"
        l.TextColor3 = Color3.fromRGB(0, 200, 120)
        l.TextSize = 26
        l.Font = Enum.Font.GothamBold
        gpuGui.Parent = guiParent
    end)
end

local function gpuDisable()
    if not gpuOn then return end
    gpuOn = false
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        Lighting.GlobalShadows = origLight.GS or true
        Lighting.FogEnd = origLight.FE or 100000
        if setfpscap then setfpscap(0) end
    end)
    pcall(function() if gpuGui then gpuGui:Destroy() gpuGui = nil end end)
end

local function fpsBoost()
    pcall(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("MeshPart") or v:IsA("Part") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            end
        end
        Lighting.GlobalShadows = false
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
end

-- =====================================================================
--  ANTI-AFK / ANTI-DROWN
-- =====================================================================
local afkConn
local function afkOn()
    if afkConn then return end
    pcall(function()
        afkConn = LP.Idled:Connect(function()
            pcall(function()
                if VirtualUser then VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end
            end)
        end)
    end)
end
local function afkOff()
    if afkConn then pcall(function() afkConn:Disconnect() end) afkConn = nil end
end
if Cfg.AntiAFK then afkOn() end

task.spawn(function()
    while true do
        task.wait(0.5)
        if Cfg.AntiDrown then
            pcall(function()
                local ch = LP.Character
                if not ch then return end
                local h = ch:FindFirstChildOfClass("Humanoid")
                local r = ch:FindFirstChild("HumanoidRootPart")
                if h and r and h:GetState() == Enum.HumanoidStateType.Swimming and r.Position.Y < -5 then
                    r.Velocity = Vector3.new(r.Velocity.X, 15, r.Velocity.Z)
                end
            end)
        end
    end
end)

-- =====================================================================
--  MOVEMENT (InfJump / Fly / Noclip / Speed)
-- =====================================================================
local flyBV, flyBG

pcall(function()
    UIS.JumpRequest:Connect(function()
        if Cfg.InfJump then
            pcall(function()
                local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    end)
end)

local flyTag = rName(6)
local function flyStart()
    pcall(function()
        local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not r then return end
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(1e8, 1e8, 1e8)
        flyBV.Velocity = Vector3.zero
        flyBV.Parent = r
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
        flyBG.P = 9e4
        flyBG.Parent = r
        local cam = workspace.CurrentCamera
        RunService:BindToRenderStep(flyTag, 1, function()
            if not Cfg.Fly or not flyBV or not flyBV.Parent then return end
            local d = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then d = d + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then d = d - cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then d = d - cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then d = d + cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then d = d + Vector3.yAxis end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then d = d - Vector3.yAxis end
            flyBV.Velocity = d * Cfg.WalkSpeed * 3
            flyBG.CFrame = cam.CFrame
        end)
    end)
end

local function flyStop()
    pcall(function()
        RunService:UnbindFromRenderStep(flyTag)
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
    end)
end

local ncConn
local function ncOn()
    if ncConn then return end
    ncConn = RunService.Stepped:Connect(function()
        if not Cfg.Noclip then return end
        pcall(function()
            for _, p in ipairs(LP.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end)
end
local function ncOff()
    if ncConn then pcall(function() ncConn:Disconnect() end) ncConn = nil end
end

task.spawn(function()
    while true do
        task.wait(0.4)
        pcall(function()
            local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if h then
                if Cfg.WalkSpeed ~= 16 then h.WalkSpeed = Cfg.WalkSpeed end
                if Cfg.JumpPower ~= 50 then h.JumpPower = Cfg.JumpPower end
            end
        end)
    end
end)

-- =====================================================================
--  ESP
-- =====================================================================
local espF, pespF
local function mkESP()
    if not espF then espF = Instance.new("Folder") espF.Name = rName(6) espF.Parent = guiParent end
    if not pespF then pespF = Instance.new("Folder") pespF.Name = rName(6) pespF.Parent = guiParent end
end
local function clrESP(f)
    if f then pcall(function() for _, c in ipairs(f:GetChildren()) do c:Destroy() end end) end
end

task.spawn(function()
    while true do
        task.wait(2)
        if Cfg.FishESP then
            mkESP() clrESP(espF)
            pcall(function()
                for _, o in ipairs(workspace:GetDescendants()) do
                    if o:IsA("Model") and (o.Name:lower():find("fish") or o.Name:lower():find("catch")) then
                        local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
                        if p then
                            local bb = Instance.new("BillboardGui")
                            bb.Size = UDim2.new(0, 110, 0, 28)
                            bb.StudsOffset = Vector3.new(0, 3, 0)
                            bb.AlwaysOnTop = true
                            bb.Adornee = p
                            bb.Parent = espF
                            local l = Instance.new("TextLabel", bb)
                            l.Size = UDim2.new(1, 0, 1, 0)
                            l.BackgroundTransparency = 0.35
                            l.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
                            l.TextColor3 = Color3.fromRGB(0, 230, 160)
                            l.TextSize = 11
                            l.Font = Enum.Font.GothamBold
                            l.Text = o.Name
                            Instance.new("UICorner", l).CornerRadius = UDim.new(0, 4)
                        end
                    end
                end
            end)
        else clrESP(espF) end

        if Cfg.PlayerESP then
            mkESP() clrESP(pespF)
            pcall(function()
                local myR = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LP and pl.Character then
                        local r = pl.Character:FindFirstChild("HumanoidRootPart")
                        if r then
                            local dist = myR and math.floor((r.Position - myR.Position).Magnitude) or 0
                            local bb = Instance.new("BillboardGui")
                            bb.Size = UDim2.new(0, 140, 0, 26)
                            bb.StudsOffset = Vector3.new(0, 4, 0)
                            bb.AlwaysOnTop = true
                            bb.Adornee = r
                            bb.Parent = pespF
                            local l = Instance.new("TextLabel", bb)
                            l.Size = UDim2.new(1, 0, 1, 0)
                            l.BackgroundTransparency = 0.35
                            l.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
                            l.TextColor3 = Color3.fromRGB(255, 220, 80)
                            l.TextSize = 11
                            l.Font = Enum.Font.GothamBold
                            l.Text = pl.Name .. " [" .. dist .. "m]"
                            Instance.new("UICorner", l).CornerRadius = UDim.new(0, 4)
                        end
                    end
                end
            end)
        else clrESP(pespF) end
    end
end)

-- =====================================================================
--  AUTO FAVORITE
-- =====================================================================
local favCache = {}
local function autoFav()
    if not Cfg.AutoFavorite or not PData then return end
    local tgt = Rarity[Cfg.FavoriteRarity] or 6
    if tgt < 5 then tgt = 5 end
    pcall(function()
        local inv = PData:GetExpect("Inventory")
        if not inv or not inv.Items then return end
        for _, it in ipairs(inv.Items) do
            pcall(function()
                local d = ItemUtil and ItemUtil:GetItemData(it.Id)
                if d and d.Data then
                    local rv = Rarity[d.Data.Rarity or "Common"] or 0
                    if rv >= tgt and not it.Favorited and not favCache[it.UUID] then
                        safeFire(Ev.fav, it.UUID)
                        favCache[it.UUID] = true
                        local nm = d.Data.Name or "?"
                        notify("Fav", nm .. " (" .. (d.Data.Rarity or "?") .. ")")
                        sendWebhook("Rare Catch!", "**" .. nm .. "** (" .. (d.Data.Rarity or "?") .. ")", 16776960)
                        humanWait(0.3)
                    end
                end
            end)
        end
    end)
end
task.spawn(function()
    while true do task.wait(randDelay(8, 15)) autoFav() end
end)

-- =====================================================================
--  FISHING LOGIC
-- =====================================================================
local casting = false
local fishOn = false
local catches = 0
local t0 = tick()

local function castNormal()
    safeFire(Ev.equip, 1)
    humanWait(0.05)
    safeInvoke(Ev.charge, 1755848498.4834)
    humanWait(0.02)
    safeInvoke(Ev.mini, 1.2854545116425, 1)
end

local function loopNormal()
    while fishOn and not Cfg.BlatantMode and not Cfg.InstantMode do
        if not casting then
            casting = true
            castNormal()
            humanWait(Cfg.FishDelay)
            safeFire(Ev.fish)
            catches = catches + 1
            humanWait(Cfg.CatchDelay)
            casting = false
        else task.wait(0.1) end
    end
end

local function loopBlatant()
    while fishOn and Cfg.BlatantMode and not Cfg.InstantMode do
        if not casting then
            casting = true
            pcall(function()
                safeFire(Ev.equip, 1)
                task.wait(0.01)
                task.spawn(function() safeInvoke(Ev.charge, 1755848498.4834) task.wait(0.01) safeInvoke(Ev.mini, 1.2854545116425, 1) end)
                task.wait(0.05)
                task.spawn(function() safeInvoke(Ev.charge, 1755848498.4834) task.wait(0.01) safeInvoke(Ev.mini, 1.2854545116425, 1) end)
            end)
            humanWait(Cfg.FishDelay)
            for _ = 1, 5 do safeFire(Ev.fish) task.wait(0.01) end
            catches = catches + 1
            humanWait(Cfg.CatchDelay * 0.5)
            casting = false
        else task.wait(0.01) end
    end
end

local function loopInstant()
    while fishOn and Cfg.InstantMode do
        if not casting then
            casting = true
            pcall(function()
                safeFire(Ev.equip, 1)
                task.wait(0.005)
                for _ = 1, 3 do
                    task.spawn(function() safeInvoke(Ev.charge, 1755848498.4834) safeInvoke(Ev.mini, 1.2854545116425, 1) end)
                end
                task.wait(Cfg.FishDelay * 0.6)
                for _ = 1, 8 do safeFire(Ev.fish) task.wait(0.005) end
            end)
            catches = catches + 1
            task.wait(randDelay(0.05, 0.15))
            casting = false
        else task.wait(0.01) end
    end
end

local function fishLoop()
    while fishOn do
        if Cfg.InstantMode then loopInstant()
        elseif Cfg.BlatantMode then loopBlatant()
        else loopNormal() end
        task.wait(0.1)
    end
end

task.spawn(function()
    while true do
        if Cfg.AutoCatch and not casting then pcall(function() safeFire(Ev.fish) end) end
        task.wait(randDelay(0.15, 0.35))
    end
end)

-- =====================================================================
--  AUTO SELL
-- =====================================================================
local function sellNow()
    pcall(function()
        if Cfg.AutoFavorite then autoFav() humanWait(0.4) end
        safeInvoke(Ev.sell)
        notify("Sold", "All non-favorited fish sold!")
    end)
end

task.spawn(function()
    while true do
        task.wait(randDelay(Cfg.SellDelay * 0.9, Cfg.SellDelay * 1.1))
        if Cfg.AutoSell then sellNow() end
    end
end)

-- =====================================================================
--  AUTO ENCHANT / BUY / QUEST / EVENT / ARTIFACT
-- =====================================================================
local function getNet()
    local ok, net = pcall(function()
        return RepStorage.Packages._Index["sleitnick_net@0.2.0"].net
    end)
    return ok and net or nil
end

task.spawn(function() while true do task.wait(randDelay(12, 22))
    if Cfg.AutoEnchant then pcall(function() local n = getNet() if n then local r = n:FindFirstChild("RF/EnchantRod") if r then safeInvoke(r) end end end) end
end end)

task.spawn(function() while true do task.wait(randDelay(35, 65))
    if Cfg.AutoBuyRod then pcall(function() local n = getNet() if n then local r = n:FindFirstChild("RF/BuyItem") if r then safeInvoke(r, "BestRod") end end end) end
end end)

task.spawn(function() while true do task.wait(randDelay(50, 95))
    if Cfg.AutoBuyWeather then pcall(function() local n = getNet() if n then local r = n:FindFirstChild("RF/BuyWeather") if r then safeInvoke(r) end end end) end
end end)

task.spawn(function() while true do task.wait(randDelay(18, 35))
    if Cfg.AutoEvent then
        pcall(function()
            for _, o in ipairs(workspace:GetDescendants()) do
                if o:IsA("Model") and (o.Name:lower():find("event") or o.Name:lower():find("megalodon") or o.Name:lower():find("worm")) then
                    local p = o:FindFirstChildWhichIsA("BasePart")
                    if p then smoothTP(p.CFrame) notify("Event", o.Name) break end
                end
            end
        end)
    end
end end)

task.spawn(function() while true do task.wait(randDelay(12, 28))
    if Cfg.AutoArtifact then
        pcall(function()
            for _, o in ipairs(workspace:GetDescendants()) do
                if o:IsA("Model") and o.Name:lower():find("artifact") then
                    local p = o:FindFirstChildWhichIsA("BasePart")
                    if p then
                        smoothTP(p.CFrame) humanWait(0.3)
                        local pr = o:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if pr and fireproximityprompt then fireproximityprompt(pr) end
                        notify("Artifact", o.Name) break
                    end
                end
            end
        end)
    end
end end)

task.spawn(function() while true do task.wait(randDelay(22, 45))
    if Cfg.AutoQuest then pcall(function() local n = getNet() if n then local r = n:FindFirstChild("RF/CompleteQuest") or n:FindFirstChild("RF/AcceptQuest") if r then safeInvoke(r) end end end) end
end end)

-- =====================================================================
--  SERVER HOP / AUTO RECONNECT
-- =====================================================================
local function serverHop()
    pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
        local s = HttpService:JSONDecode(game:HttpGet(url))
        if s and s.data then
            for _, sv in ipairs(s.data) do
                if sv.playing < sv.maxPlayers and sv.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, sv.id)
                    return
                end
            end
        end
        notify("Hop", "No servers found")
    end)
end

pcall(function()
    game:GetService("GuiService").ErrorMessageChanged:Connect(function()
        task.wait(3)
        pcall(function() TeleportService:Teleport(game.PlaceId) end)
    end)
end)

-- =====================================================================
--  SPLASH SCREEN: "GasUp ID"
-- =====================================================================
local splashDone = false

local SplashGui = Instance.new("ScreenGui")
SplashGui.Name = SPLASH_NAME
SplashGui.ResetOnSpawn = false
SplashGui.DisplayOrder = 100000
SplashGui:SetAttribute("_mfi", true)
SplashGui.Parent = guiParent

-- Full screen dark overlay
local splashBG = Instance.new("Frame")
splashBG.Size = UDim2.new(1, 0, 1, 0)
splashBG.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
splashBG.BackgroundTransparency = 0
splashBG.BorderSizePixel = 0
splashBG.Parent = SplashGui

-- Top accent line (thin glow bar)
local topLine = Instance.new("Frame")
topLine.Size = UDim2.new(0, 0, 0, 2)
topLine.Position = UDim2.new(0.5, 0, 0.38, 0)
topLine.AnchorPoint = Vector2.new(0.5, 0.5)
topLine.BackgroundColor3 = Color3.fromRGB(0, 200, 130)
topLine.BorderSizePixel = 0
topLine.Parent = splashBG

-- Main title "GasUp"
local gasLabel = Instance.new("TextLabel")
gasLabel.Size = UDim2.new(0, 400, 0, 70)
gasLabel.Position = UDim2.new(0.5, 0, 0.45, 0)
gasLabel.AnchorPoint = Vector2.new(0.5, 0.5)
gasLabel.BackgroundTransparency = 1
gasLabel.Text = "GasUp"
gasLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
gasLabel.TextSize = 52
gasLabel.Font = Enum.Font.GothamBlack
gasLabel.TextTransparency = 1
gasLabel.Parent = splashBG

-- "ID" badge next to GasUp
local idBadge = Instance.new("TextLabel")
idBadge.Size = UDim2.new(0, 50, 0, 28)
idBadge.Position = UDim2.new(0.5, 85, 0.45, -18)
idBadge.BackgroundColor3 = Color3.fromRGB(0, 200, 130)
idBadge.Text = "ID"
idBadge.TextColor3 = Color3.fromRGB(8, 8, 14)
idBadge.TextSize = 18
idBadge.Font = Enum.Font.GothamBlack
idBadge.TextTransparency = 1
idBadge.BackgroundTransparency = 1
idBadge.Parent = splashBG
Instance.new("UICorner", idBadge).CornerRadius = UDim.new(0, 6)

-- Subtitle
local subLabel = Instance.new("TextLabel")
subLabel.Size = UDim2.new(0, 300, 0, 20)
subLabel.Position = UDim2.new(0.5, 0, 0.54, 0)
subLabel.AnchorPoint = Vector2.new(0.5, 0.5)
subLabel.BackgroundTransparency = 1
subLabel.Text = "MORON FISH IT"
subLabel.TextColor3 = Color3.fromRGB(100, 100, 130)
subLabel.TextSize = 13
subLabel.Font = Enum.Font.GothamBold
subLabel.TextTransparency = 1
subLabel.Parent = splashBG

-- Version tag
local verLabel = Instance.new("TextLabel")
verLabel.Size = UDim2.new(0, 200, 0, 14)
verLabel.Position = UDim2.new(0.5, 0, 0.58, 0)
verLabel.AnchorPoint = Vector2.new(0.5, 0.5)
verLabel.BackgroundTransparency = 1
verLabel.Text = "v2.2.0  -  Professional Edition"
verLabel.TextColor3 = Color3.fromRGB(60, 60, 80)
verLabel.TextSize = 10
verLabel.Font = Enum.Font.Gotham
verLabel.TextTransparency = 1
verLabel.Parent = splashBG

-- Bottom accent line
local botLine = Instance.new("Frame")
botLine.Size = UDim2.new(0, 0, 0, 2)
botLine.Position = UDim2.new(0.5, 0, 0.62, 0)
botLine.AnchorPoint = Vector2.new(0.5, 0.5)
botLine.BackgroundColor3 = Color3.fromRGB(0, 200, 130)
botLine.BorderSizePixel = 0
botLine.Parent = splashBG

-- Loading dots
local loadLabel = Instance.new("TextLabel")
loadLabel.Size = UDim2.new(0, 200, 0, 16)
loadLabel.Position = UDim2.new(0.5, 0, 0.72, 0)
loadLabel.AnchorPoint = Vector2.new(0.5, 0.5)
loadLabel.BackgroundTransparency = 1
loadLabel.Text = "Loading"
loadLabel.TextColor3 = Color3.fromRGB(0, 200, 130)
loadLabel.TextSize = 11
loadLabel.Font = Enum.Font.Gotham
loadLabel.TextTransparency = 1
loadLabel.Parent = splashBG

-- Animate splash
task.spawn(function()
    local ti = TweenInfo.new

    -- Fade in top line
    TweenService:Create(topLine, ti(0.5, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 260, 0, 2)}):Play()
    task.wait(0.3)

    -- Fade in "GasUp"
    TweenService:Create(gasLabel, ti(0.6, Enum.EasingStyle.Quart), {TextTransparency = 0}):Play()
    task.wait(0.2)

    -- Fade in "ID" badge
    TweenService:Create(idBadge, ti(0.4, Enum.EasingStyle.Quart), {TextTransparency = 0, BackgroundTransparency = 0}):Play()
    task.wait(0.3)

    -- Fade in subtitle
    TweenService:Create(subLabel, ti(0.5, Enum.EasingStyle.Quart), {TextTransparency = 0}):Play()
    task.wait(0.15)

    -- Fade in version
    TweenService:Create(verLabel, ti(0.4, Enum.EasingStyle.Quart), {TextTransparency = 0}):Play()
    task.wait(0.15)

    -- Bottom line
    TweenService:Create(botLine, ti(0.5, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 260, 0, 2)}):Play()
    task.wait(0.2)

    -- Loading text
    TweenService:Create(loadLabel, ti(0.3), {TextTransparency = 0}):Play()

    -- Animate loading dots
    for i = 1, 8 do
        local dots = string.rep(".", (i % 4))
        loadLabel.Text = "Loading" .. dots
        task.wait(0.25)
    end

    loadLabel.Text = "Ready"
    task.wait(0.4)

    -- Fade out everything
    TweenService:Create(splashBG, ti(0.6, Enum.EasingStyle.Quart), {BackgroundTransparency = 1}):Play()
    TweenService:Create(gasLabel, ti(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(idBadge, ti(0.4), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
    TweenService:Create(subLabel, ti(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(verLabel, ti(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(loadLabel, ti(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(topLine, ti(0.4), {BackgroundTransparency = 1}):Play()
    TweenService:Create(botLine, ti(0.4), {BackgroundTransparency = 1}):Play()
    task.wait(0.7)

    SplashGui:Destroy()
    splashDone = true
end)

-- Wait for splash to finish before showing main UI
repeat task.wait(0.1) until splashDone

-- =====================================================================
--  MAIN UI (Clean Monochrome Design)
-- =====================================================================
local C = {
    Bg = Color3.fromRGB(15, 15, 22),
    Sidebar = Color3.fromRGB(18, 18, 26),
    Content = Color3.fromRGB(22, 22, 32),
    Card = Color3.fromRGB(30, 30, 44),
    CardH = Color3.fromRGB(38, 38, 55),
    Accent = Color3.fromRGB(0, 200, 130),
    Txt = Color3.fromRGB(220, 220, 230),
    TxtDim = Color3.fromRGB(120, 120, 145),
    TxtMute = Color3.fromRGB(70, 70, 90),
    Border = Color3.fromRGB(40, 40, 58),
    On = Color3.fromRGB(0, 200, 130),
    Off = Color3.fromRGB(55, 55, 72),
    White = Color3.fromRGB(255, 255, 255),
}

local SG = Instance.new("ScreenGui")
SG.Name = GUI_NAME
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.DisplayOrder = 99999
SG:SetAttribute("_mfi", true)
pcall(function() SG.Parent = guiParent end)
if not SG.Parent then pcall(function() SG.Parent = LP:WaitForChild("PlayerGui") end) end

-- Main Frame
local MF = Instance.new("Frame")
MF.Name = rName(6)
MF.Size = UDim2.new(0, 560, 0, 380)
MF.Position = UDim2.new(0.5, -280, 0.5, -190)
MF.BackgroundColor3 = C.Bg
MF.BorderSizePixel = 0
MF.ClipsDescendants = true
MF.Visible = true
MF.Parent = SG
Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 10)

-- Sidebar (130px, clean)
local SB = Instance.new("Frame")
SB.Name = rName(4)
SB.Size = UDim2.new(0, 130, 1, 0)
SB.BackgroundColor3 = C.Sidebar
SB.BorderSizePixel = 0
SB.Parent = MF
Instance.new("UICorner", SB).CornerRadius = UDim.new(0, 10)

-- Fix right corners of sidebar
local sbFix = Instance.new("Frame")
sbFix.Size = UDim2.new(0, 12, 1, 0)
sbFix.Position = UDim2.new(1, -12, 0, 0)
sbFix.BackgroundColor3 = C.Sidebar
sbFix.BorderSizePixel = 0
sbFix.Parent = SB

-- Sidebar right border
local sbLine = Instance.new("Frame")
sbLine.Size = UDim2.new(0, 1, 1, -16)
sbLine.Position = UDim2.new(1, 0, 0, 8)
sbLine.BackgroundColor3 = C.Border
sbLine.BorderSizePixel = 0
sbLine.Parent = SB

-- Logo
local logoFrame = Instance.new("Frame")
logoFrame.Size = UDim2.new(1, 0, 0, 58)
logoFrame.BackgroundTransparency = 1
logoFrame.Parent = SB

local logoBadge = Instance.new("Frame")
logoBadge.Size = UDim2.new(0, 32, 0, 32)
logoBadge.Position = UDim2.new(0, 12, 0, 10)
logoBadge.BackgroundColor3 = C.Accent
logoBadge.Parent = logoFrame
Instance.new("UICorner", logoBadge).CornerRadius = UDim.new(0, 8)

local logoLetter = Instance.new("TextLabel")
logoLetter.Size = UDim2.new(1, 0, 1, 0)
logoLetter.BackgroundTransparency = 1
logoLetter.Text = "G"
logoLetter.TextColor3 = C.White
logoLetter.TextSize = 18
logoLetter.Font = Enum.Font.GothamBlack
logoLetter.Parent = logoBadge

local logoTxt = Instance.new("TextLabel")
logoTxt.Size = UDim2.new(0, 80, 0, 14)
logoTxt.Position = UDim2.new(0, 50, 0, 12)
logoTxt.BackgroundTransparency = 1
logoTxt.Text = "GasUp ID"
logoTxt.TextColor3 = C.Txt
logoTxt.TextSize = 12
logoTxt.Font = Enum.Font.GothamBlack
logoTxt.TextXAlignment = Enum.TextXAlignment.Left
logoTxt.Parent = logoFrame

local logoSub = Instance.new("TextLabel")
logoSub.Size = UDim2.new(0, 80, 0, 10)
logoSub.Position = UDim2.new(0, 50, 0, 27)
logoSub.BackgroundTransparency = 1
logoSub.Text = "Moron Fish It"
logoSub.TextColor3 = C.TxtMute
logoSub.TextSize = 9
logoSub.Font = Enum.Font.Gotham
logoSub.TextXAlignment = Enum.TextXAlignment.Left
logoSub.Parent = logoFrame

-- Separator
local logoSep = Instance.new("Frame")
logoSep.Size = UDim2.new(1, -24, 0, 1)
logoSep.Position = UDim2.new(0, 12, 0, 50)
logoSep.BackgroundColor3 = C.Border
logoSep.BorderSizePixel = 0
logoSep.Parent = logoFrame

-- Nav container
local NavList = Instance.new("Frame")
NavList.Size = UDim2.new(1, -6, 1, -65)
NavList.Position = UDim2.new(0, 3, 0, 60)
NavList.BackgroundTransparency = 1
NavList.Parent = SB

local navLayout = Instance.new("UIListLayout")
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Padding = UDim.new(0, 1)
navLayout.Parent = NavList

-- Tab definitions (clean monochrome - no colors)
local TabDefs = {
    {"Fishing", "~"},
    {"Selling", "$"},
    {"Teleport", ">"},
    {"Movement", "^"},
    {"Utility", "*"},
    {"Visuals", "o"},
    {"Settings", "="},
}

local pages = {}
local navBtns = {}
local curPage = nil

-- Content Area
local CA = Instance.new("Frame")
CA.Name = rName(4)
CA.Size = UDim2.new(1, -138, 1, -8)
CA.Position = UDim2.new(0, 134, 0, 4)
CA.BackgroundColor3 = C.Content
CA.BorderSizePixel = 0
CA.ClipsDescendants = true
CA.Visible = true
CA.Parent = MF
Instance.new("UICorner", CA).CornerRadius = UDim.new(0, 8)

-- Page header
local PageHeader = Instance.new("Frame")
PageHeader.Size = UDim2.new(1, 0, 0, 40)
PageHeader.BackgroundTransparency = 1
PageHeader.Parent = CA

local PageTitle = Instance.new("TextLabel")
PageTitle.Size = UDim2.new(1, -50, 0, 18)
PageTitle.Position = UDim2.new(0, 14, 0, 6)
PageTitle.BackgroundTransparency = 1
PageTitle.Text = "Fishing"
PageTitle.TextColor3 = C.Txt
PageTitle.TextSize = 15
PageTitle.Font = Enum.Font.GothamBold
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.Parent = PageHeader

local PageDesc = Instance.new("TextLabel")
PageDesc.Size = UDim2.new(1, -50, 0, 12)
PageDesc.Position = UDim2.new(0, 14, 0, 25)
PageDesc.BackgroundTransparency = 1
PageDesc.Text = ""
PageDesc.TextColor3 = C.TxtMute
PageDesc.TextSize = 9
PageDesc.Font = Enum.Font.Gotham
PageDesc.TextXAlignment = Enum.TextXAlignment.Left
PageDesc.Parent = PageHeader

-- Close/Hide button (instead of minimize to avoid detection)
local HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.new(0, 26, 0, 26)
HideBtn.Position = UDim2.new(1, -34, 0, 7)
HideBtn.BackgroundColor3 = C.Card
HideBtn.Text = "x"
HideBtn.TextColor3 = C.TxtDim
HideBtn.TextSize = 12
HideBtn.Font = Enum.Font.GothamBold
HideBtn.AutoButtonColor = false
HideBtn.Parent = PageHeader
Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(0, 6)

-- Page scroll area
local PageArea = Instance.new("Frame")
PageArea.Size = UDim2.new(1, 0, 1, -44)
PageArea.Position = UDim2.new(0, 0, 0, 42)
PageArea.BackgroundTransparency = 1
PageArea.ClipsDescendants = true
PageArea.Parent = CA

-- =====================================================================
--  UI COMPONENT FACTORY
-- =====================================================================
local function mkPage(name)
    local sc = Instance.new("ScrollingFrame")
    sc.Name = rName(5)
    sc.Size = UDim2.new(1, -6, 1, 0)
    sc.Position = UDim2.new(0, 3, 0, 0)
    sc.BackgroundTransparency = 1
    sc.ScrollBarThickness = 2
    sc.ScrollBarImageColor3 = C.Accent
    sc.CanvasSize = UDim2.new(0, 0, 0, 0)
    sc.Visible = false
    sc.BorderSizePixel = 0
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sc.Parent = PageArea
    local ly = Instance.new("UIListLayout")
    ly.SortOrder = Enum.SortOrder.LayoutOrder
    ly.Padding = UDim.new(0, 4)
    ly.Parent = sc
    local pd = Instance.new("UIPadding")
    pd.PaddingTop = UDim.new(0, 2)
    pd.PaddingBottom = UDim.new(0, 14)
    pd.PaddingLeft = UDim.new(0, 6)
    pd.PaddingRight = UDim.new(0, 6)
    pd.Parent = sc
    return sc
end

local function mkSection(par, title, ord)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 22)
    f.BackgroundTransparency = 1
    f.LayoutOrder = ord or 0
    f.Parent = par
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 10)
    l.Position = UDim2.new(0, 2, 0, 8)
    l.BackgroundTransparency = 1
    l.Text = string.upper(title)
    l.TextColor3 = C.TxtMute
    l.TextSize = 8
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    return f
end

local function mkToggle(par, name, desc, val, cb, ord)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 42)
    c.BackgroundColor3 = C.Card
    c.BorderSizePixel = 0
    c.LayoutOrder = ord or 0
    c.Parent = par
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 7)

    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1, -60, 0, 16)
    nl.Position = UDim2.new(0, 10, 0, 5)
    nl.BackgroundTransparency = 1
    nl.Text = name
    nl.TextColor3 = C.Txt
    nl.TextSize = 11
    nl.Font = Enum.Font.GothamBold
    nl.TextXAlignment = Enum.TextXAlignment.Left
    nl.Parent = c

    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(1, -60, 0, 12)
    dl.Position = UDim2.new(0, 10, 0, 22)
    dl.BackgroundTransparency = 1
    dl.Text = desc
    dl.TextColor3 = C.TxtDim
    dl.TextSize = 8
    dl.Font = Enum.Font.Gotham
    dl.TextXAlignment = Enum.TextXAlignment.Left
    dl.TextTruncate = Enum.TextTruncate.AtEnd
    dl.Parent = c

    local tr = Instance.new("Frame")
    tr.Size = UDim2.new(0, 36, 0, 18)
    tr.Position = UDim2.new(1, -46, 0.5, -9)
    tr.BackgroundColor3 = val and C.On or C.Off
    tr.BorderSizePixel = 0
    tr.Parent = c
    Instance.new("UICorner", tr).CornerRadius = UDim.new(1, 0)

    local kn = Instance.new("Frame")
    kn.Size = UDim2.new(0, 14, 0, 14)
    kn.Position = val and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    kn.BackgroundColor3 = C.White
    kn.BorderSizePixel = 0
    kn.Parent = tr
    Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)

    local on = val
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = c
    btn.MouseButton1Click:Connect(function()
        on = not on
        TweenService:Create(tr, TweenInfo.new(0.2), {BackgroundColor3 = on and C.On or C.Off}):Play()
        TweenService:Create(kn, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            Position = on and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
        if cb then cb(on) end
    end)
    return c
end

local function mkBtn(par, name, desc, cb, ord)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 38)
    c.BackgroundColor3 = C.Card
    c.BorderSizePixel = 0
    c.LayoutOrder = ord or 0
    c.Parent = par
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 7)

    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1, -30, 0, 14)
    nl.Position = UDim2.new(0, 10, 0, 5)
    nl.BackgroundTransparency = 1
    nl.Text = name
    nl.TextColor3 = C.Txt
    nl.TextSize = 11
    nl.Font = Enum.Font.GothamBold
    nl.TextXAlignment = Enum.TextXAlignment.Left
    nl.Parent = c

    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(1, -30, 0, 11)
    dl.Position = UDim2.new(0, 10, 0, 20)
    dl.BackgroundTransparency = 1
    dl.Text = desc
    dl.TextColor3 = C.TxtDim
    dl.TextSize = 8
    dl.Font = Enum.Font.Gotham
    dl.TextXAlignment = Enum.TextXAlignment.Left
    dl.Parent = c

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 14, 0, 14)
    arrow.Position = UDim2.new(1, -20, 0.5, -7)
    arrow.BackgroundTransparency = 1
    arrow.Text = ">"
    arrow.TextColor3 = C.TxtMute
    arrow.TextSize = 10
    arrow.Font = Enum.Font.GothamBold
    arrow.Parent = c

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = c
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(c, TweenInfo.new(0.06), {BackgroundColor3 = C.CardH}):Play()
        task.wait(0.06)
        TweenService:Create(c, TweenInfo.new(0.1), {BackgroundColor3 = C.Card}):Play()
        if cb then cb() end
    end)
    return c
end

local function mkSlider(par, name, lo, hi, def, cb, ord)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 46)
    c.BackgroundColor3 = C.Card
    c.BorderSizePixel = 0
    c.LayoutOrder = ord or 0
    c.Parent = par
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 7)

    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(0.6, -8, 0, 14)
    nl.Position = UDim2.new(0, 10, 0, 4)
    nl.BackgroundTransparency = 1
    nl.Text = name
    nl.TextColor3 = C.Txt
    nl.TextSize = 10
    nl.Font = Enum.Font.GothamBold
    nl.TextXAlignment = Enum.TextXAlignment.Left
    nl.Parent = c

    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0.4, -10, 0, 14)
    vl.Position = UDim2.new(0.6, 0, 0, 4)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(def)
    vl.TextColor3 = C.Accent
    vl.TextSize = 10
    vl.Font = Enum.Font.GothamBold
    vl.TextXAlignment = Enum.TextXAlignment.Right
    vl.Parent = c

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 4)
    track.Position = UDim2.new(0, 10, 0, 30)
    track.BackgroundColor3 = C.Off
    track.BorderSizePixel = 0
    track.Parent = c
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local pct = math.clamp((def - lo) / (hi - lo), 0, 1)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = C.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(pct, -6, 0.5, -6)
    knob.BackgroundColor3 = C.White
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local drag = false
    local sb = Instance.new("TextButton")
    sb.Size = UDim2.new(1, 0, 0, 20)
    sb.Position = UDim2.new(0, 0, 0, 22)
    sb.BackgroundTransparency = 1
    sb.Text = ""
    sb.AutoButtonColor = false
    sb.Parent = c
    sb.MouseButton1Down:Connect(function() drag = true end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            pcall(function()
                local p2 = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local v = lo + (hi - lo) * p2
                if (hi - lo) > 10 then v = math.floor(v) else v = math.floor(v * 10) / 10 end
                fill.Size = UDim2.new(p2, 0, 1, 0)
                knob.Position = UDim2.new(p2, -6, 0.5, -6)
                vl.Text = tostring(v)
                if cb then cb(v) end
            end)
        end
    end)
    return c
end

local function mkDropdown(par, name, opts, def, cb, ord)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 38)
    c.BackgroundColor3 = C.Card
    c.BorderSizePixel = 0
    c.LayoutOrder = ord or 0
    c.ClipsDescendants = true
    c.Parent = par
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 7)

    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(0.5, -8, 0, 38)
    nl.Position = UDim2.new(0, 10, 0, 0)
    nl.BackgroundTransparency = 1
    nl.Text = name
    nl.TextColor3 = C.Txt
    nl.TextSize = 10
    nl.Font = Enum.Font.GothamBold
    nl.TextXAlignment = Enum.TextXAlignment.Left
    nl.Parent = c

    local sel = Instance.new("TextLabel")
    sel.Size = UDim2.new(0.4, -24, 0, 38)
    sel.Position = UDim2.new(0.5, 0, 0, 0)
    sel.BackgroundTransparency = 1
    sel.Text = def or opts[1]
    sel.TextColor3 = C.Accent
    sel.TextSize = 10
    sel.Font = Enum.Font.GothamBold
    sel.TextXAlignment = Enum.TextXAlignment.Right
    sel.Parent = c

    local optFrames = {}
    for i, o in ipairs(opts) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1, -14, 0, 28)
        ob.Position = UDim2.new(0, 7, 0, 38 + (i - 1) * 30)
        ob.BackgroundColor3 = C.Sidebar
        ob.Text = o
        ob.TextColor3 = C.Txt
        ob.TextSize = 9
        ob.Font = Enum.Font.Gotham
        ob.BorderSizePixel = 0
        ob.AutoButtonColor = false
        ob.Visible = false
        ob.Parent = c
        Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 5)
        ob.MouseButton1Click:Connect(function()
            sel.Text = o
            c.Size = UDim2.new(1, 0, 0, 38)
            for _, f in ipairs(optFrames) do f.Visible = false end
            if cb then cb(o) end
        end)
        table.insert(optFrames, ob)
    end

    local dd = Instance.new("TextButton")
    dd.Size = UDim2.new(0, 18, 0, 38)
    dd.Position = UDim2.new(1, -22, 0, 0)
    dd.BackgroundTransparency = 1
    dd.Text = "v"
    dd.TextColor3 = C.TxtMute
    dd.TextSize = 9
    dd.Font = Enum.Font.GothamBold
    dd.AutoButtonColor = false
    dd.Parent = c
    local open = false
    dd.MouseButton1Click:Connect(function()
        open = not open
        if open then
            c.Size = UDim2.new(1, 0, 0, 38 + #opts * 30 + 6)
            for _, f in ipairs(optFrames) do f.Visible = true end
        else
            c.Size = UDim2.new(1, 0, 0, 38)
            for _, f in ipairs(optFrames) do f.Visible = false end
        end
    end)
    return c
end

local function mkInput(par, name, ph, def, cb, ord)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 38)
    c.BackgroundColor3 = C.Card
    c.BorderSizePixel = 0
    c.LayoutOrder = ord or 0
    c.Parent = par
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 7)

    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(0.35, -8, 1, 0)
    nl.Position = UDim2.new(0, 10, 0, 0)
    nl.BackgroundTransparency = 1
    nl.Text = name
    nl.TextColor3 = C.Txt
    nl.TextSize = 10
    nl.Font = Enum.Font.GothamBold
    nl.TextXAlignment = Enum.TextXAlignment.Left
    nl.Parent = c

    local ib = Instance.new("TextBox")
    ib.Size = UDim2.new(0.6, -8, 0, 24)
    ib.Position = UDim2.new(0.4, 0, 0.5, -12)
    ib.BackgroundColor3 = C.Sidebar
    ib.Text = def or ""
    ib.PlaceholderText = ph or ""
    ib.TextColor3 = C.Txt
    ib.PlaceholderColor3 = C.TxtMute
    ib.TextSize = 9
    ib.Font = Enum.Font.Gotham
    ib.BorderSizePixel = 0
    ib.ClearTextOnFocus = false
    ib.Parent = c
    Instance.new("UICorner", ib).CornerRadius = UDim.new(0, 5)
    ib.FocusLost:Connect(function() if cb then cb(ib.Text) end end)
    return c
end

-- =====================================================================
--  BUILD NAVIGATION (Clean Monochrome)
-- =====================================================================
local pageDescs = {
    Fishing = "Automatic fishing configuration",
    Selling = "Auto sell and favorite protection",
    Teleport = "Teleport to islands and NPCs",
    Movement = "Speed, jump, fly, noclip",
    Utility = "Anti-AFK, performance, server",
    Visuals = "ESP and visual overlays",
    Settings = "Config, webhook, session info",
}

local function switchPage(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for n, b in pairs(navBtns) do
        if n == name then
            b.bg.BackgroundColor3 = C.Card
            b.label.TextColor3 = C.Txt
            b.ind.Visible = true
        else
            b.bg.BackgroundTransparency = 1
            b.bg.BackgroundColor3 = C.Sidebar
            b.label.TextColor3 = C.TxtDim
            b.ind.Visible = false
        end
    end
    PageTitle.Text = name
    PageDesc.Text = pageDescs[name] or ""
    curPage = name
end

for i, td in ipairs(TabDefs) do
    local name, icon = td[1], td[2]
    pages[name] = mkPage(name)

    local nbg = Instance.new("Frame")
    nbg.Size = UDim2.new(1, -6, 0, 30)
    nbg.BackgroundTransparency = 1
    nbg.BorderSizePixel = 0
    nbg.LayoutOrder = i
    nbg.Parent = NavList
    Instance.new("UICorner", nbg).CornerRadius = UDim.new(0, 6)

    -- Left accent indicator (monochrome green)
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 3, 0, 16)
    ind.Position = UDim2.new(0, 0, 0.5, -8)
    ind.BackgroundColor3 = C.Accent
    ind.BorderSizePixel = 0
    ind.Visible = false
    ind.Parent = nbg
    Instance.new("UICorner", ind).CornerRadius = UDim.new(0, 2)

    -- Icon (monochrome)
    local ic = Instance.new("TextLabel")
    ic.Size = UDim2.new(0, 20, 0, 20)
    ic.Position = UDim2.new(0, 10, 0.5, -10)
    ic.BackgroundTransparency = 1
    ic.Text = icon
    ic.TextColor3 = C.TxtDim
    ic.TextSize = 12
    ic.Font = Enum.Font.GothamBold
    ic.Parent = nbg

    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, -38, 0, 30)
    lb.Position = UDim2.new(0, 34, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = name
    lb.TextColor3 = C.TxtDim
    lb.TextSize = 10
    lb.Font = Enum.Font.GothamBold
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Parent = nbg

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = nbg
    btn.MouseButton1Click:Connect(function() switchPage(name) end)

    navBtns[name] = {bg = nbg, label = lb, ind = ind}
end

-- =====================================================================
--  BUILD PAGE CONTENT
-- =====================================================================

-- FISHING
local fp = pages["Fishing"]
mkSection(fp, "Fishing Mode", 1)
mkToggle(fp, "Auto Fish", "Automatically cast and catch fish", Cfg.AutoFish, function(v)
    Cfg.AutoFish = v fishOn = v
    if v then task.spawn(fishLoop) notify("Fish", "Started") else pcall(function() safeFire(Ev.unequip) end) notify("Fish", "Stopped") end
    cfgSave()
end, 2)
mkToggle(fp, "Blatant Mode", "Parallel casting, 2x speed (moderate risk)", Cfg.BlatantMode, function(v) Cfg.BlatantMode = v if v then Cfg.InstantMode = false end cfgSave() end, 3)
mkToggle(fp, "Instant Mode", "Triple casting, max speed (high risk)", Cfg.InstantMode, function(v) Cfg.InstantMode = v if v then Cfg.BlatantMode = false end cfgSave() end, 4)
mkToggle(fp, "Auto Catch", "Background reel spam for extra speed", Cfg.AutoCatch, function(v) Cfg.AutoCatch = v cfgSave() end, 5)
mkSection(fp, "Timing", 6)
mkSlider(fp, "Fish Delay", 0.1, 5.0, Cfg.FishDelay, function(v) Cfg.FishDelay = v cfgSave() end, 7)
mkSlider(fp, "Catch Delay", 0.1, 3.0, Cfg.CatchDelay, function(v) Cfg.CatchDelay = v cfgSave() end, 8)
mkSection(fp, "Extra Automation", 9)
mkToggle(fp, "Auto Enchant", "Enchant rod when available", Cfg.AutoEnchant, function(v) Cfg.AutoEnchant = v cfgSave() end, 10)
mkToggle(fp, "Auto Buy Best Rod", "Purchase best affordable rod", Cfg.AutoBuyRod, function(v) Cfg.AutoBuyRod = v cfgSave() end, 11)
mkToggle(fp, "Auto Buy Weather", "Buy weather for rare fish", Cfg.AutoBuyWeather, function(v) Cfg.AutoBuyWeather = v cfgSave() end, 12)
mkToggle(fp, "Auto Quest", "Accept and complete quests", Cfg.AutoQuest, function(v) Cfg.AutoQuest = v cfgSave() end, 13)
mkToggle(fp, "Auto Event", "Teleport to active events", Cfg.AutoEvent, function(v) Cfg.AutoEvent = v cfgSave() end, 14)
mkToggle(fp, "Auto Artifact", "Find and collect artifacts", Cfg.AutoArtifact, function(v) Cfg.AutoArtifact = v cfgSave() end, 15)

-- SELLING
local sp = pages["Selling"]
mkSection(sp, "Auto Sell", 1)
mkToggle(sp, "Auto Sell", "Sell fish at intervals (protects favorites)", Cfg.AutoSell, function(v) Cfg.AutoSell = v cfgSave() end, 2)
mkSlider(sp, "Sell Interval (sec)", 10, 300, Cfg.SellDelay, function(v) Cfg.SellDelay = v cfgSave() end, 3)
mkBtn(sp, "Sell All Now", "Sell all non-favorited fish immediately", function() sellNow() end, 4)
mkSection(sp, "Favorite Protection", 5)
mkToggle(sp, "Auto Favorite", "Auto-favorite rare fish before selling", Cfg.AutoFavorite, function(v) Cfg.AutoFavorite = v cfgSave() end, 6)
mkDropdown(sp, "Min Rarity", {"Legendary", "Mythic", "Secret"}, Cfg.FavoriteRarity, function(v) Cfg.FavoriteRarity = v cfgSave() end, 7)
mkBtn(sp, "Favorite All Rare Now", "Scan and favorite all rare fish", function() autoFav() notify("Done", "Scanned!") end, 8)

-- TELEPORT
local tp = pages["Teleport"]
mkSection(tp, "Islands", 1)
for i, loc in ipairs(Islands) do
    mkBtn(tp, loc[1], "Teleport to " .. loc[1], function() tpTo(loc[1]) end, i + 1)
end
mkSection(tp, "NPCs", #Islands + 3)
for i, npc in ipairs(NPCs) do
    mkBtn(tp, npc[1], "Teleport to " .. npc[1], function() tpTo(npc[1]) end, #Islands + 3 + i)
end

-- MOVEMENT
local mp = pages["Movement"]
mkSection(mp, "Speed & Jump", 1)
mkSlider(mp, "Walk Speed", 16, 200, Cfg.WalkSpeed, function(v) Cfg.WalkSpeed = v cfgSave() end, 2)
mkSlider(mp, "Jump Power", 50, 300, Cfg.JumpPower, function(v) Cfg.JumpPower = v cfgSave() end, 3)
mkSection(mp, "Special", 4)
mkToggle(mp, "Infinite Jump", "Jump unlimited times in the air", Cfg.InfJump, function(v) Cfg.InfJump = v cfgSave() end, 5)
mkToggle(mp, "Fly", "Fly with WASD + Space/Shift", Cfg.Fly, function(v) Cfg.Fly = v if v then flyStart() else flyStop() end cfgSave() end, 6)
mkToggle(mp, "Noclip", "Pass through walls", Cfg.Noclip, function(v) Cfg.Noclip = v if v then ncOn() else ncOff() end cfgSave() end, 7)

-- UTILITY
local up = pages["Utility"]
mkSection(up, "Protection", 1)
mkToggle(up, "Anti-AFK", "Prevent idle kick", Cfg.AntiAFK, function(v) Cfg.AntiAFK = v if v then afkOn() else afkOff() end cfgSave() end, 2)
mkToggle(up, "Anti-Drown", "Auto resurface when drowning", Cfg.AntiDrown, function(v) Cfg.AntiDrown = v cfgSave() end, 3)
mkSection(up, "Performance", 4)
mkToggle(up, "GPU Saver", "Minimize graphics for AFK farming", Cfg.GPUSaver, function(v) Cfg.GPUSaver = v if v then gpuEnable() else gpuDisable() end cfgSave() end, 5)
mkToggle(up, "FPS Boost", "Remove particles and effects", Cfg.FPSBoost, function(v) Cfg.FPSBoost = v if v then fpsBoost() end cfgSave() end, 6)
mkSection(up, "Server", 7)
mkBtn(up, "Server Hop", "Join a different server", function() serverHop() end, 8)
mkBtn(up, "Rejoin", "Reconnect to current server", function() pcall(function() TeleportService:Teleport(game.PlaceId) end) end, 9)

-- VISUALS
local vp = pages["Visuals"]
mkSection(vp, "ESP Overlays", 1)
mkToggle(vp, "Fish ESP", "Show labels on fish in world", Cfg.FishESP, function(v) Cfg.FishESP = v if not v then clrESP(espF) end cfgSave() end, 2)
mkToggle(vp, "Player ESP", "Show player names and distance", Cfg.PlayerESP, function(v) Cfg.PlayerESP = v if not v then clrESP(pespF) end cfgSave() end, 3)

-- SETTINGS
local stp = pages["Settings"]
mkSection(stp, "Discord Webhook", 1)
mkToggle(stp, "Enable Webhook", "Send rare catch notifications to Discord", Cfg.WebhookOn, function(v) Cfg.WebhookOn = v cfgSave() end, 2)
mkInput(stp, "Webhook URL", "https://discord.com/api/webhooks/...", Cfg.WebhookURL, function(v)
    Cfg.WebhookURL = v cfgSave()
    if v ~= "" then sendWebhook("Connected!", "Webhook active.", 3066993) notify("Webhook", "Test sent!") end
end, 3)
mkSection(stp, "Configuration", 4)
mkBtn(stp, "Save Config", "Save all settings to file", function() cfgSave() notify("Config", "Saved!") end, 5)
mkBtn(stp, "Load Config", "Load saved settings", function() cfgLoad() notify("Config", "Loaded! Rejoin to apply.") end, 6)
mkBtn(stp, "Reset to Default", "Reset all settings", function() for k, v in pairs(Default) do Cfg[k] = v end cfgSave() notify("Config", "Reset!") end, 7)

mkSection(stp, "Session", 8)
local statLbl = Instance.new("TextLabel")
statLbl.Size = UDim2.new(1, 0, 0, 55)
statLbl.BackgroundColor3 = C.Card
statLbl.TextColor3 = C.Txt
statLbl.TextSize = 10
statLbl.Font = Enum.Font.Gotham
statLbl.TextXAlignment = Enum.TextXAlignment.Left
statLbl.TextYAlignment = Enum.TextYAlignment.Top
statLbl.Text = "  Loading..."
statLbl.LayoutOrder = 9
statLbl.BorderSizePixel = 0
statLbl.Parent = stp
Instance.new("UICorner", statLbl).CornerRadius = UDim.new(0, 7)
local statPad = Instance.new("UIPadding")
statPad.PaddingLeft = UDim.new(0, 10)
statPad.PaddingTop = UDim.new(0, 8)
statPad.Parent = statLbl

task.spawn(function()
    while true do
        pcall(function()
            local e = tick() - t0
            local h = math.floor(e / 3600)
            local m = math.floor((e % 3600) / 60)
            local s = math.floor(e % 60)
            statLbl.Text = string.format("Player: %s\nCatches: %d\nTime: %02d:%02d:%02d", LP.Name, catches, h, m, s)
        end)
        task.wait(1)
    end
end)

mkSection(stp, "About", 10)
local aboutLbl = Instance.new("TextLabel")
aboutLbl.Size = UDim2.new(1, 0, 0, 40)
aboutLbl.BackgroundColor3 = C.Card
aboutLbl.TextColor3 = C.TxtDim
aboutLbl.TextSize = 9
aboutLbl.Font = Enum.Font.Gotham
aboutLbl.TextXAlignment = Enum.TextXAlignment.Center
aboutLbl.Text = "GasUp ID  -  Moron Fish It v2.2.0\nFree Forever"
aboutLbl.LayoutOrder = 11
aboutLbl.BorderSizePixel = 0
aboutLbl.Parent = stp
Instance.new("UICorner", aboutLbl).CornerRadius = UDim.new(0, 7)

-- =====================================================================
--  DRAGGING
-- =====================================================================
do
    local dragging, dragIn, dragSt, startP = false, nil, nil, nil
    SB.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragSt = i.Position
            startP = MF.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    SB.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then dragIn = i end
    end)
    UIS.InputChanged:Connect(function(i)
        if i == dragIn and dragging then
            local d = i.Position - dragSt
            MF.Position = UDim2.new(startP.X.Scale, startP.X.Offset + d.X, startP.Y.Scale, startP.Y.Offset + d.Y)
        end
    end)
end

do
    local dragging, dragIn, dragSt, startP = false, nil, nil, nil
    PageHeader.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragSt = i.Position
            startP = MF.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    PageHeader.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then dragIn = i end
    end)
    UIS.InputChanged:Connect(function(i)
        if i == dragIn and dragging then
            local d = i.Position - dragSt
            MF.Position = UDim2.new(startP.X.Scale, startP.X.Offset + d.X, startP.Y.Scale, startP.Y.Offset + d.Y)
        end
    end)
end

-- =====================================================================
--  HIDE/SHOW (No minimize - just hide completely to avoid detection)
-- =====================================================================
HideBtn.MouseButton1Click:Connect(function()
    MF.Visible = false
end)

-- Right Shift to toggle visibility
pcall(function()
    UIS.InputBegan:Connect(function(i, p)
        if p then return end
        if i.KeyCode == Enum.KeyCode.RightShift then
            MF.Visible = not MF.Visible
        end
    end)
end)

-- =====================================================================
--  STARTUP
-- =====================================================================
switchPage("Fishing")
MF.Visible = true

notify("GasUp ID", "Moron Fish It v2.2 Loaded! RightShift to toggle")
sendWebhook("Started!", "**" .. LP.Name .. "** loaded MFI", 3066993)

print("=== GasUp ID - Moron Fish It v2.2.0 ===")
print("  No Key | No HWID | Free Forever")
print("  Press RightShift to toggle UI")
print("========================================")
