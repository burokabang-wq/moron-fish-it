--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║            MORON FISH IT  -  Professional Edition           ║
    ║                      Version 2.0.0                          ║
    ║            No Key  |  No HWID  |  Free Forever              ║
    ║                                                             ║
    ║   Game: Fish It! (Roblox)                                   ║
    ║   Place ID: 121864768012064                                 ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

-- =====================================================================
--  SECTION 1: ANTI-DETECTION & SAFETY LAYER
-- =====================================================================
local _rng = Random.new(tick() % 1000)

local function randDelay(lo, hi)
    return lo + _rng:NextNumber() * (hi - lo)
end

local function humanWait(base)
    task.wait(base * (0.82 + _rng:NextNumber() * 0.36))
end

local function safeFire(remote, ...)
    if not remote then return end
    local a = {...}
    task.defer(function() pcall(function() remote:FireServer(unpack(a)) end) end)
end

local function safeInvoke(remote, ...)
    if not remote then return nil end
    local ok, res = pcall(function() return remote:InvokeServer(...) end)
    return ok and res or nil
end

-- =====================================================================
--  SECTION 2: DEPENDENCY VALIDATION
-- =====================================================================
do
    local ok, err = pcall(function()
        assert(game, "game")
        assert(game:GetService("Players").LocalPlayer, "LocalPlayer")
        assert(game:GetService("ReplicatedStorage"), "ReplicatedStorage")
    end)
    if not ok then warn("[MoronFishIt] Boot failed: "..tostring(err)) return end
end

-- =====================================================================
--  SECTION 3: CORE SERVICES
-- =====================================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local RepStorage       = game:GetService("ReplicatedStorage")
local HttpService      = game:GetService("HttpService")
local VirtualUser      = game:GetService("VirtualUser")
local UIS              = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local TeleportService  = game:GetService("TeleportService")
local StarterGui       = game:GetService("StarterGui")
local CoreGui          = game:GetService("CoreGui")
local LP               = Players.LocalPlayer

-- =====================================================================
--  SECTION 4: CONFIGURATION
-- =====================================================================
local CFG_DIR  = "MoronFishIt"
local CFG_FILE = CFG_DIR.."/cfg_"..LP.UserId..".json"

local Default = {
    AutoFish=false, AutoSell=false, AutoCatch=false,
    BlatantMode=false, InstantMode=false,
    FishDelay=0.9, CatchDelay=0.2, SellDelay=30,
    AutoFavorite=true, FavoriteRarity="Mythic",
    AutoBuyRod=false, AutoBuyWeather=false,
    AutoEnchant=false, AutoQuest=false, AutoEvent=false, AutoArtifact=false,
    WalkSpeed=16, JumpPower=50, InfJump=false, Fly=false, Noclip=false,
    AntiAFK=true, AntiDrown=false, GPUSaver=false, FPSBoost=false,
    FishESP=false, PlayerESP=false,
    WebhookURL="", WebhookOn=false,
    TeleportLoc="Spawn",
}

local Cfg = {}
for k,v in pairs(Default) do Cfg[k]=v end

local function cfgSave()
    if not writefile then return end
    pcall(function()
        if isfolder and not isfolder(CFG_DIR) then makefolder(CFG_DIR) end
        writefile(CFG_FILE, HttpService:JSONEncode(Cfg))
    end)
end

local function cfgLoad()
    if not readfile or not isfile or not isfile(CFG_FILE) then return end
    pcall(function()
        local d = HttpService:JSONDecode(readfile(CFG_FILE))
        for k,v in pairs(d) do if Default[k]~=nil then Cfg[k]=v end end
    end)
end
cfgLoad()

-- =====================================================================
--  SECTION 5: MAP & NPC LOCATIONS
-- =====================================================================
local Islands = {
    {"Spawn",              CFrame.new(45.27, 252.56, 2987.10)},
    {"Sisyphus Statue",    CFrame.new(-3728.21, -135.07, -1012.12)},
    {"Coral Reefs",        CFrame.new(-3114.78, 1.32, 2237.52)},
    {"Esoteric Depths",    CFrame.new(3248.37, -1301.53, 1403.82)},
    {"Crater Island",      CFrame.new(1016.49, 20.09, 5069.27)},
    {"Lost Isle",          CFrame.new(-3618.15, 240.83, -1317.45)},
    {"Weather Machine",    CFrame.new(-1488.51, 83.17, 1876.30)},
    {"Tropical Grove",     CFrame.new(-2095.34, 197.19, 3718.08)},
    {"Mount Hallow",       CFrame.new(2136.62, 78.91, 3272.50)},
    {"Treasure Room",      CFrame.new(-3606.34, -266.57, -1580.97)},
    {"Kohana",             CFrame.new(-663.90, 3.04, 718.79)},
    {"Underground Cellar", CFrame.new(2109.52, -94.18, -708.60)},
    {"Ancient Jungle",     CFrame.new(1831.71, 6.62, -299.27)},
    {"Sacred Temple",      CFrame.new(1466.92, -21.87, -622.83)},
    {"Crystal Cavern",     CFrame.new(-2800.50, -180.25, 450.30)},
    {"Underwater City",    CFrame.new(-1200.80, -350.60, -2100.40)},
    {"Forgotten Shore",    CFrame.new(3500.20, 5.50, -1800.90)},
}

local NPCs = {
    {"Rod Shop",     CFrame.new(52.10, 252.56, 2970.50)},
    {"Sell NPC",     CFrame.new(-3725.00, -135.07, -1020.00)},
    {"Enchant NPC",  CFrame.new(-3710.50, -135.07, -1005.80)},
    {"Quest NPC",    CFrame.new(60.30, 252.56, 2995.20)},
    {"Weather NPC",  CFrame.new(-1485.20, 83.17, 1880.50)},
    {"Boat Shop",    CFrame.new(30.50, 252.56, 2960.80)},
}

-- =====================================================================
--  SECTION 6: NETWORK EVENTS
-- =====================================================================
local Ev = {}
pcall(function()
    local net = RepStorage.Packages._Index["sleitnick_net@0.2.0"].net
    Ev.fish    = net:WaitForChild("RE/FishingCompleted")
    Ev.sell    = net:WaitForChild("RF/SellAllItems")
    Ev.charge  = net:WaitForChild("RF/ChargeFishingRod")
    Ev.mini    = net:WaitForChild("RF/RequestFishingMinigameStarted")
    Ev.cancel  = net:WaitForChild("RF/CancelFishingInputs")
    Ev.equip   = net:WaitForChild("RE/EquipToolFromHotbar")
    Ev.unequip = net:WaitForChild("RE/UnequipToolFromHotbar")
    Ev.fav     = net:WaitForChild("RE/FavoriteItem")
end)

-- =====================================================================
--  SECTION 7: GAME MODULES
-- =====================================================================
local ItemUtil, Replion, PData
pcall(function()
    ItemUtil = require(RepStorage.Shared.ItemUtility)
    Replion  = require(RepStorage.Packages.Replion)
    PData    = Replion.Client:WaitReplion("Data")
end)

local Rarity = {Common=1,Uncommon=2,Rare=3,Epic=4,Legendary=5,Mythic=6,Secret=7}
local RarCol = {
    Common    = Color3.fromRGB(160,160,170),
    Uncommon  = Color3.fromRGB(80,200,80),
    Rare      = Color3.fromRGB(60,130,255),
    Epic      = Color3.fromRGB(170,60,255),
    Legendary = Color3.fromRGB(255,175,0),
    Mythic    = Color3.fromRGB(255,55,55),
    Secret    = Color3.fromRGB(255,0,130),
}

-- =====================================================================
--  SECTION 8: UTILITY FUNCTIONS
-- =====================================================================
local function notify(t,m,d)
    pcall(function()
        StarterGui:SetCore("SendNotification",{Title=t or"Moron Fish It",Text=m or"",Duration=d or 4})
    end)
end

local function sendWebhook(title,desc,col)
    if not Cfg.WebhookOn or Cfg.WebhookURL=="" then return end
    pcall(function()
        local body = HttpService:JSONEncode({embeds={{
            title=title, description=desc, color=col or 3066993,
            footer={text="Moron Fish It v2.0 | "..os.date("%H:%M:%S")},
        }}})
        ;(syn and syn.request or http and http.request or request or http_request)({
            Url=Cfg.WebhookURL, Method="POST",
            Headers={["Content-Type"]="application/json"}, Body=body
        })
    end)
end

-- =====================================================================
--  SECTION 9: TELEPORT (Smooth Anti-Detect)
-- =====================================================================
local function smoothTP(cf)
    local ch = LP.Character
    if not ch then return false end
    local r = ch:FindFirstChild("HumanoidRootPart")
    if not r then return false
    end
    local dist = (r.Position - cf.Position).Magnitude
    if dist < 400 then
        humanWait(0.08)
        r.CFrame = cf
    else
        local steps = math.clamp(math.floor(dist/250),2,6)
        for i=1,steps do
            r.CFrame = r.CFrame:Lerp(cf, i/steps)
            humanWait(0.04)
        end
    end
    return true
end

local function tpTo(name)
    for _,t in ipairs(Islands) do
        if t[1]==name then smoothTP(t[2]) notify("Teleport","Arrived at "..name) return true end
    end
    for _,t in ipairs(NPCs) do
        if t[1]==name then smoothTP(t[2]) notify("Teleport","Arrived at "..name) return true end
    end
    notify("Teleport","Location not found") return false
end

-- =====================================================================
--  SECTION 10: GPU SAVER / FPS BOOST
-- =====================================================================
local gpuOn, gpuGui = false, nil
local origLight = {}

local function gpuEnable()
    if gpuOn then return end; gpuOn = true
    pcall(function()
        origLight.GS = Lighting.GlobalShadows; origLight.FE = Lighting.FogEnd
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false; Lighting.FogEnd = 1
        if setfpscap then setfpscap(10) end
    end)
    gpuGui = Instance.new("ScreenGui"); gpuGui.Name="MGPU"; gpuGui.ResetOnSpawn=false; gpuGui.DisplayOrder=999999
    local f = Instance.new("Frame"); f.Size=UDim2.new(1,0,1,0); f.BackgroundColor3=Color3.fromRGB(12,12,18); f.Parent=gpuGui
    local l = Instance.new("TextLabel"); l.Size=UDim2.new(0,500,0,100); l.Position=UDim2.new(0.5,-250,0.5,-50)
    l.BackgroundTransparency=1; l.Text="MORON FISH IT\nGPU SAVER ACTIVE"; l.TextColor3=Color3.fromRGB(0,200,120)
    l.TextSize=26; l.Font=Enum.Font.GothamBold; l.Parent=f
    gpuGui.Parent = CoreGui
end

local function gpuDisable()
    if not gpuOn then return end; gpuOn = false
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        Lighting.GlobalShadows = origLight.GS or true; Lighting.FogEnd = origLight.FE or 100000
        if setfpscap then setfpscap(0) end
    end)
    if gpuGui then gpuGui:Destroy(); gpuGui=nil end
end

local function fpsBoost()
    pcall(function()
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then v.Enabled=false
            elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency=1
            elseif v:IsA("MeshPart") or v:IsA("Part") then v.Material=Enum.Material.SmoothPlastic; v.Reflectance=0 end
        end
        Lighting.GlobalShadows=false; settings().Rendering.QualityLevel=Enum.QualityLevel.Level01
    end)
end

-- =====================================================================
--  SECTION 11: ANTI-AFK / ANTI-DROWN
-- =====================================================================
local afkConn
local function afkOn()
    if afkConn then return end
    afkConn = LP.Idled:Connect(function()
        pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
    end)
end
local function afkOff() if afkConn then afkConn:Disconnect(); afkConn=nil end end
if Cfg.AntiAFK then afkOn() end

task.spawn(function()
    while true do task.wait(0.5)
        if Cfg.AntiDrown then pcall(function()
            local ch=LP.Character; if not ch then return end
            local h=ch:FindFirstChildOfClass("Humanoid"); local r=ch:FindFirstChild("HumanoidRootPart")
            if h and r and h:GetState()==Enum.HumanoidStateType.Swimming and r.Position.Y<-5 then
                r.Velocity=Vector3.new(r.Velocity.X,15,r.Velocity.Z)
            end
        end) end
    end
end)

-- =====================================================================
--  SECTION 12: MOVEMENT (InfJump / Fly / Noclip / Speed)
-- =====================================================================
local flyBV, flyBG
UIS.JumpRequest:Connect(function()
    if Cfg.InfJump then pcall(function()
        local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end) end
end)

local function flyStart()
    pcall(function()
        local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); if not r then return end
        flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce=Vector3.new(1e8,1e8,1e8); flyBV.Velocity=Vector3.zero; flyBV.Parent=r
        flyBG = Instance.new("BodyGyro"); flyBG.MaxTorque=Vector3.new(1e8,1e8,1e8); flyBG.P=9e4; flyBG.Parent=r
        local cam = workspace.CurrentCamera
        RunService:BindToRenderStep("MFly",1,function()
            if not Cfg.Fly or not flyBV then return end
            local d = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then d=d+cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then d=d-cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then d=d-cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then d=d+cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then d=d+Vector3.yAxis end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then d=d-Vector3.yAxis end
            flyBV.Velocity = d * Cfg.WalkSpeed * 3
            flyBG.CFrame = cam.CFrame
        end)
    end)
end
local function flyStop()
    pcall(function()
        RunService:UnbindFromRenderStep("MFly")
        if flyBV then flyBV:Destroy(); flyBV=nil end
        if flyBG then flyBG:Destroy(); flyBG=nil end
    end)
end

local ncConn
local function ncOn()
    if ncConn then return end
    ncConn = RunService.Stepped:Connect(function()
        if not Cfg.Noclip then return end
        pcall(function()
            for _,p in ipairs(LP.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=false end
            end
        end)
    end)
end
local function ncOff() if ncConn then ncConn:Disconnect(); ncConn=nil end end

task.spawn(function()
    while true do task.wait(0.4)
        pcall(function()
            local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if h then
                if Cfg.WalkSpeed~=16 then h.WalkSpeed=Cfg.WalkSpeed end
                if Cfg.JumpPower~=50 then h.JumpPower=Cfg.JumpPower end
            end
        end)
    end
end)

-- =====================================================================
--  SECTION 13: ESP
-- =====================================================================
local espF, pespF
local function mkESP()
    if not espF then espF=Instance.new("Folder"); espF.Name="MFESP"; espF.Parent=CoreGui end
    if not pespF then pespF=Instance.new("Folder"); pespF.Name="MPESP"; pespF.Parent=CoreGui end
end
local function clrESP(f) if f then for _,c in ipairs(f:GetChildren()) do c:Destroy() end end end

task.spawn(function()
    while true do task.wait(2)
        if Cfg.FishESP then mkESP(); clrESP(espF)
            pcall(function()
                for _,o in ipairs(workspace:GetDescendants()) do
                    if o:IsA("Model") and (o.Name:lower():find("fish") or o.Name:lower():find("catch")) then
                        local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
                        if p then
                            local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,110,0,28); bb.StudsOffset=Vector3.new(0,3,0)
                            bb.AlwaysOnTop=true; bb.Adornee=p; bb.Parent=espF
                            local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=0.35
                            l.BackgroundColor3=Color3.fromRGB(10,10,15); l.TextColor3=Color3.fromRGB(0,230,160)
                            l.TextSize=11; l.Font=Enum.Font.GothamBold; l.Text=o.Name; l.Parent=bb
                            Instance.new("UICorner",l).CornerRadius=UDim.new(0,4)
                        end
                    end
                end
            end)
        else clrESP(espF) end

        if Cfg.PlayerESP then mkESP(); clrESP(pespF)
            pcall(function()
                local myR = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                for _,pl in ipairs(Players:GetPlayers()) do
                    if pl~=LP and pl.Character then
                        local r = pl.Character:FindFirstChild("HumanoidRootPart")
                        if r then
                            local dist = myR and math.floor((r.Position-myR.Position).Magnitude) or 0
                            local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,140,0,26); bb.StudsOffset=Vector3.new(0,4,0)
                            bb.AlwaysOnTop=true; bb.Adornee=r; bb.Parent=pespF
                            local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=0.35
                            l.BackgroundColor3=Color3.fromRGB(10,10,15); l.TextColor3=Color3.fromRGB(255,220,80)
                            l.TextSize=11; l.Font=Enum.Font.GothamBold; l.Text=pl.Name.." ["..dist.."m]"; l.Parent=bb
                            Instance.new("UICorner",l).CornerRadius=UDim.new(0,4)
                        end
                    end
                end
            end)
        else clrESP(pespF) end
    end
end)

-- =====================================================================
--  SECTION 14: AUTO FAVORITE
-- =====================================================================
local favCache = {}
local function autoFav()
    if not Cfg.AutoFavorite or not PData then return end
    local tgt = Rarity[Cfg.FavoriteRarity] or 6; if tgt<6 then tgt=6 end
    pcall(function()
        local items = PData:GetExpect("Inventory").Items; if not items then return end
        for _,it in ipairs(items) do
            local d = ItemUtil:GetItemData(it.Id)
            if d and d.Data then
                local rv = Rarity[d.Data.Rarity or "Common"] or 0
                if rv>=tgt and not it.Favorited and not favCache[it.UUID] then
                    safeFire(Ev.fav, it.UUID); favCache[it.UUID]=true
                    local nm = d.Data.Name or "?"
                    notify("Favorited", nm.." ("..d.Data.Rarity..")")
                    sendWebhook("Rare Catch!","**"..nm.."** ("..d.Data.Rarity..")",16776960)
                    humanWait(0.3)
                end
            end
        end
    end)
end
task.spawn(function() while true do task.wait(randDelay(8,15)); autoFav() end end)

-- =====================================================================
--  SECTION 15: FISHING LOGIC
-- =====================================================================
local casting, fishOn = false, false
local catches = 0
local t0 = tick()

local function castNormal()
    safeFire(Ev.equip,1); humanWait(0.05)
    safeInvoke(Ev.charge,1755848498.4834); humanWait(0.02)
    safeInvoke(Ev.mini,1.2854545116425,1)
end

local function loopNormal()
    while fishOn and not Cfg.BlatantMode and not Cfg.InstantMode do
        if not casting then casting=true
            castNormal(); humanWait(Cfg.FishDelay)
            safeFire(Ev.fish); catches=catches+1; humanWait(Cfg.CatchDelay)
            casting=false
        else task.wait(0.1) end
    end
end

local function loopBlatant()
    while fishOn and Cfg.BlatantMode and not Cfg.InstantMode do
        if not casting then casting=true
            pcall(function()
                safeFire(Ev.equip,1); task.wait(0.01)
                task.spawn(function() safeInvoke(Ev.charge,1755848498.4834); task.wait(0.01); safeInvoke(Ev.mini,1.2854545116425,1) end)
                task.wait(0.05)
                task.spawn(function() safeInvoke(Ev.charge,1755848498.4834); task.wait(0.01); safeInvoke(Ev.mini,1.2854545116425,1) end)
            end)
            humanWait(Cfg.FishDelay)
            for _=1,5 do safeFire(Ev.fish); task.wait(0.01) end
            catches=catches+1; humanWait(Cfg.CatchDelay*0.5)
            casting=false
        else task.wait(0.01) end
    end
end

local function loopInstant()
    while fishOn and Cfg.InstantMode do
        if not casting then casting=true
            pcall(function()
                safeFire(Ev.equip,1); task.wait(0.005)
                for _=1,3 do task.spawn(function() safeInvoke(Ev.charge,1755848498.4834); safeInvoke(Ev.mini,1.2854545116425,1) end) end
                task.wait(Cfg.FishDelay*0.6)
                for _=1,8 do safeFire(Ev.fish); task.wait(0.005) end
            end)
            catches=catches+1; task.wait(randDelay(0.05,0.15))
            casting=false
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

-- background catch spam
task.spawn(function() while true do
    if Cfg.AutoCatch and not casting then pcall(function() safeFire(Ev.fish) end) end
    task.wait(randDelay(0.15,0.35))
end end)

-- =====================================================================
--  SECTION 16: AUTO SELL
-- =====================================================================
local function sellNow()
    pcall(function()
        if Cfg.AutoFavorite then autoFav(); humanWait(0.4) end
        safeInvoke(Ev.sell)
        notify("Sold","All non-favorited fish sold!")
    end)
end
task.spawn(function() while true do
    task.wait(randDelay(Cfg.SellDelay*0.9, Cfg.SellDelay*1.1))
    if Cfg.AutoSell then sellNow() end
end end)

-- =====================================================================
--  SECTION 17: AUTO ENCHANT / BUY / QUEST / EVENT / ARTIFACT
-- =====================================================================
task.spawn(function() while true do task.wait(randDelay(12,22))
    if Cfg.AutoEnchant then pcall(function()
        local net=RepStorage.Packages._Index["sleitnick_net@0.2.0"].net
        local r=net:FindFirstChild("RF/EnchantRod"); if r then safeInvoke(r) end
    end) end
end end)

task.spawn(function() while true do task.wait(randDelay(35,65))
    if Cfg.AutoBuyRod then pcall(function()
        local net=RepStorage.Packages._Index["sleitnick_net@0.2.0"].net
        local r=net:FindFirstChild("RF/BuyItem"); if r then safeInvoke(r,"BestRod") end
    end) end
end end)

task.spawn(function() while true do task.wait(randDelay(50,95))
    if Cfg.AutoBuyWeather then pcall(function()
        local net=RepStorage.Packages._Index["sleitnick_net@0.2.0"].net
        local r=net:FindFirstChild("RF/BuyWeather"); if r then safeInvoke(r) end
    end) end
end end)

task.spawn(function() while true do task.wait(randDelay(18,35))
    if Cfg.AutoEvent then pcall(function()
        for _,o in ipairs(workspace:GetDescendants()) do
            if o:IsA("Model") and (o.Name:lower():find("event") or o.Name:lower():find("megalodon") or o.Name:lower():find("worm")) then
                local p=o:FindFirstChildWhichIsA("BasePart")
                if p then smoothTP(p.CFrame); notify("Event","Teleported to "..o.Name); break end
            end
        end
    end) end
end end)

task.spawn(function() while true do task.wait(randDelay(12,28))
    if Cfg.AutoArtifact then pcall(function()
        for _,o in ipairs(workspace:GetDescendants()) do
            if o:IsA("Model") and o.Name:lower():find("artifact") then
                local p=o:FindFirstChildWhichIsA("BasePart")
                if p then smoothTP(p.CFrame); humanWait(0.3)
                    local pr=o:FindFirstChildWhichIsA("ProximityPrompt",true)
                    if pr and fireproximityprompt then fireproximityprompt(pr) end
                    notify("Artifact","Collected: "..o.Name); break
                end
            end
        end
    end) end
end end)

task.spawn(function() while true do task.wait(randDelay(22,45))
    if Cfg.AutoQuest then pcall(function()
        local net=RepStorage.Packages._Index["sleitnick_net@0.2.0"].net
        local r=net:FindFirstChild("RF/CompleteQuest") or net:FindFirstChild("RF/AcceptQuest")
        if r then safeInvoke(r) end
    end) end
end end)

-- =====================================================================
--  SECTION 18: SERVER HOP / AUTO RECONNECT
-- =====================================================================
local function serverHop()
    pcall(function()
        local s = HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        if s and s.data then
            for _,sv in ipairs(s.data) do
                if sv.playing<sv.maxPlayers and sv.id~=game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId,sv.id); return
                end
            end
        end
        notify("Server Hop","No servers found")
    end)
end

pcall(function()
    game:GetService("GuiService").ErrorMessageChanged:Connect(function()
        task.wait(3); TeleportService:Teleport(game.PlaceId)
    end)
end)

-- =====================================================================
--  SECTION 19: PREMIUM UI
-- =====================================================================
pcall(function() if CoreGui:FindFirstChild("MoronUI") then CoreGui.MoronUI:Destroy() end end)

-- Color Palette
local C = {
    Bg       = Color3.fromRGB(13, 13, 19),
    Sidebar  = Color3.fromRGB(18, 18, 26),
    Content  = Color3.fromRGB(20, 20, 28),
    Card     = Color3.fromRGB(28, 28, 40),
    CardH    = Color3.fromRGB(35, 35, 50),
    Accent   = Color3.fromRGB(0, 190, 130),
    AccentD  = Color3.fromRGB(0, 150, 100),
    Blue     = Color3.fromRGB(70, 120, 255),
    Red      = Color3.fromRGB(240, 60, 60),
    Yellow   = Color3.fromRGB(255, 185, 0),
    Purple   = Color3.fromRGB(150, 80, 255),
    Txt      = Color3.fromRGB(225, 225, 235),
    TxtDim   = Color3.fromRGB(120, 120, 145),
    TxtMute  = Color3.fromRGB(80, 80, 100),
    Border   = Color3.fromRGB(40, 40, 58),
    On       = Color3.fromRGB(0, 210, 140),
    Off      = Color3.fromRGB(55, 55, 75),
    White    = Color3.fromRGB(255,255,255),
}

local SG = Instance.new("ScreenGui")
SG.Name="MoronUI"; SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; SG.DisplayOrder=99999; SG.Parent=CoreGui

-- === MAIN FRAME ===
local MF = Instance.new("Frame")
MF.Name="Main"; MF.Size=UDim2.new(0,580,0,400); MF.Position=UDim2.new(0.5,-290,0.5,-200)
MF.BackgroundColor3=C.Bg; MF.BorderSizePixel=0; MF.ClipsDescendants=true; MF.Parent=SG
Instance.new("UICorner",MF).CornerRadius=UDim.new(0,12)
local mfStroke = Instance.new("UIStroke",MF); mfStroke.Color=C.Border; mfStroke.Thickness=1; mfStroke.Transparency=0.3

-- Shadow
local sh = Instance.new("ImageLabel")
sh.Size=UDim2.new(1,40,1,40); sh.Position=UDim2.new(0,-20,0,-20); sh.BackgroundTransparency=1
sh.Image="rbxassetid://6015897843"; sh.ImageColor3=Color3.new(0,0,0); sh.ImageTransparency=0.4
sh.ScaleType=Enum.ScaleType.Slice; sh.SliceCenter=Rect.new(49,49,450,450); sh.ZIndex=-1; sh.Parent=MF

-- === SIDEBAR (140px) ===
local SB = Instance.new("Frame")
SB.Name="Sidebar"; SB.Size=UDim2.new(0,140,1,0); SB.BackgroundColor3=C.Sidebar; SB.BorderSizePixel=0; SB.Parent=MF
Instance.new("UICorner",SB).CornerRadius=UDim.new(0,12)
-- fix right corners
local sbFix = Instance.new("Frame"); sbFix.Size=UDim2.new(0,14,1,0); sbFix.Position=UDim2.new(1,-14,0,0)
sbFix.BackgroundColor3=C.Sidebar; sbFix.BorderSizePixel=0; sbFix.ZIndex=0; sbFix.Parent=SB

-- Sidebar border right
local sbLine = Instance.new("Frame"); sbLine.Size=UDim2.new(0,1,1,-20); sbLine.Position=UDim2.new(1,0,0,10)
sbLine.BackgroundColor3=C.Border; sbLine.BorderSizePixel=0; sbLine.Parent=SB

-- Logo area
local logoFrame = Instance.new("Frame")
logoFrame.Size=UDim2.new(1,0,0,65); logoFrame.BackgroundTransparency=1; logoFrame.Parent=SB

local logoBadge = Instance.new("Frame")
logoBadge.Size=UDim2.new(0,36,0,36); logoBadge.Position=UDim2.new(0,14,0,10)
logoBadge.BackgroundColor3=C.Accent; logoBadge.Parent=logoFrame
Instance.new("UICorner",logoBadge).CornerRadius=UDim.new(0,10)

local logoLetter = Instance.new("TextLabel")
logoLetter.Size=UDim2.new(1,0,1,0); logoLetter.BackgroundTransparency=1
logoLetter.Text="M"; logoLetter.TextColor3=C.White; logoLetter.TextSize=20; logoLetter.Font=Enum.Font.GothamBlack
logoLetter.Parent=logoBadge

local logoTxt = Instance.new("TextLabel")
logoTxt.Size=UDim2.new(0,80,0,16); logoTxt.Position=UDim2.new(0,56,0,12)
logoTxt.BackgroundTransparency=1; logoTxt.Text="MORON"; logoTxt.TextColor3=C.Txt
logoTxt.TextSize=13; logoTxt.Font=Enum.Font.GothamBlack; logoTxt.TextXAlignment=Enum.TextXAlignment.Left; logoTxt.Parent=logoFrame

local logoSub = Instance.new("TextLabel")
logoSub.Size=UDim2.new(0,80,0,12); logoSub.Position=UDim2.new(0,56,0,29)
logoSub.BackgroundTransparency=1; logoSub.Text="FISH IT"; logoSub.TextColor3=C.Accent
logoSub.TextSize=10; logoSub.Font=Enum.Font.GothamBold; logoSub.TextXAlignment=Enum.TextXAlignment.Left; logoSub.Parent=logoFrame

-- Separator under logo
local logoSep = Instance.new("Frame")
logoSep.Size=UDim2.new(1,-28,0,1); logoSep.Position=UDim2.new(0,14,0,55)
logoSep.BackgroundColor3=C.Border; logoSep.BorderSizePixel=0; logoSep.Parent=logoFrame

-- Nav items container
local NavList = Instance.new("Frame")
NavList.Size=UDim2.new(1,-8,1,-75); NavList.Position=UDim2.new(0,4,0,68)
NavList.BackgroundTransparency=1; NavList.Parent=SB

local navLayout = Instance.new("UIListLayout")
navLayout.SortOrder=Enum.SortOrder.LayoutOrder; navLayout.Padding=UDim.new(0,2); navLayout.Parent=NavList

-- Tab definitions: {name, icon, color}
local TabDefs = {
    {"Fishing",   "...",  C.Accent},
    {"Selling",   "$",    C.Yellow},
    {"Teleport",  ">",    C.Blue},
    {"Movement",  "^",    C.Purple},
    {"Utility",   "*",    C.Accent},
    {"Visuals",   "o",    C.Blue},
    {"Settings",  "=",    C.TxtDim},
}

local pages = {}
local navBtns = {}
local curPage = nil

-- === CONTENT AREA ===
local CA = Instance.new("Frame")
CA.Name="Content"; CA.Size=UDim2.new(1,-148,1,-8); CA.Position=UDim2.new(0,144,0,4)
CA.BackgroundColor3=C.Content; CA.BorderSizePixel=0; CA.ClipsDescendants=true; CA.Parent=MF
Instance.new("UICorner",CA).CornerRadius=UDim.new(0,10)

-- Page header
local PageHeader = Instance.new("Frame")
PageHeader.Size=UDim2.new(1,0,0,42); PageHeader.BackgroundTransparency=1; PageHeader.Parent=CA

local PageTitle = Instance.new("TextLabel")
PageTitle.Size=UDim2.new(1,-20,0,20); PageTitle.Position=UDim2.new(0,16,0,8)
PageTitle.BackgroundTransparency=1; PageTitle.Text="Fishing"; PageTitle.TextColor3=C.Txt
PageTitle.TextSize=16; PageTitle.Font=Enum.Font.GothamBold; PageTitle.TextXAlignment=Enum.TextXAlignment.Left; PageTitle.Parent=PageHeader

local PageDesc = Instance.new("TextLabel")
PageDesc.Size=UDim2.new(1,-20,0,12); PageDesc.Position=UDim2.new(0,16,0,28)
PageDesc.BackgroundTransparency=1; PageDesc.Text="Configure automatic fishing settings"; PageDesc.TextColor3=C.TxtMute
PageDesc.TextSize=10; PageDesc.Font=Enum.Font.Gotham; PageDesc.TextXAlignment=Enum.TextXAlignment.Left; PageDesc.Parent=PageHeader

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size=UDim2.new(0,28,0,28); MinBtn.Position=UDim2.new(1,-36,0,7)
MinBtn.BackgroundColor3=C.Card; MinBtn.Text="-"; MinBtn.TextColor3=C.TxtDim
MinBtn.TextSize=16; MinBtn.Font=Enum.Font.GothamBold; MinBtn.Parent=PageHeader
Instance.new("UICorner",MinBtn).CornerRadius=UDim.new(0,6)

-- Page scroll area
local PageArea = Instance.new("Frame")
PageArea.Size=UDim2.new(1,0,1,-46); PageArea.Position=UDim2.new(0,0,0,44)
PageArea.BackgroundTransparency=1; PageArea.ClipsDescendants=true; PageArea.Parent=CA

-- =====================================================================
--  UI COMPONENT FACTORY
-- =====================================================================
local function mkPage(name)
    local sc = Instance.new("ScrollingFrame")
    sc.Name=name; sc.Size=UDim2.new(1,-8,1,0); sc.Position=UDim2.new(0,4,0,0)
    sc.BackgroundTransparency=1; sc.ScrollBarThickness=2; sc.ScrollBarImageColor3=C.Accent
    sc.CanvasSize=UDim2.new(0,0,0,0); sc.Visible=false; sc.BorderSizePixel=0; sc.Parent=PageArea
    local ly = Instance.new("UIListLayout"); ly.SortOrder=Enum.SortOrder.LayoutOrder; ly.Padding=UDim.new(0,5); ly.Parent=sc
    local pd = Instance.new("UIPadding"); pd.PaddingTop=UDim.new(0,2); pd.PaddingBottom=UDim.new(0,12)
    pd.PaddingLeft=UDim.new(0,8); pd.PaddingRight=UDim.new(0,8); pd.Parent=sc
    ly:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sc.CanvasSize=UDim2.new(0,0,0,ly.AbsoluteContentSize.Y+20)
    end)
    return sc
end

local function mkSection(par, title, ord)
    local f = Instance.new("Frame"); f.Size=UDim2.new(1,0,0,24); f.BackgroundTransparency=1; f.LayoutOrder=ord or 0; f.Parent=par
    local l = Instance.new("TextLabel"); l.Size=UDim2.new(1,0,0,12); l.Position=UDim2.new(0,2,0,8)
    l.BackgroundTransparency=1; l.Text=string.upper(title); l.TextColor3=C.TxtMute
    l.TextSize=9; l.Font=Enum.Font.GothamBold; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=f
    return f
end

local function mkToggle(par, name, desc, val, cb, ord)
    local c = Instance.new("Frame"); c.Size=UDim2.new(1,0,0,44); c.BackgroundColor3=C.Card; c.BorderSizePixel=0; c.LayoutOrder=ord or 0; c.Parent=par
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,8)

    local nl = Instance.new("TextLabel"); nl.Size=UDim2.new(1,-65,0,18); nl.Position=UDim2.new(0,12,0,5)
    nl.BackgroundTransparency=1; nl.Text=name; nl.TextColor3=C.Txt; nl.TextSize=12; nl.Font=Enum.Font.GothamBold
    nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=c

    local dl = Instance.new("TextLabel"); dl.Size=UDim2.new(1,-65,0,14); dl.Position=UDim2.new(0,12,0,24)
    dl.BackgroundTransparency=1; dl.Text=desc; dl.TextColor3=C.TxtDim; dl.TextSize=9; dl.Font=Enum.Font.Gotham
    dl.TextXAlignment=Enum.TextXAlignment.Left; dl.TextTruncate=Enum.TextTruncate.AtEnd; dl.Parent=c

    -- toggle track
    local tr = Instance.new("Frame"); tr.Size=UDim2.new(0,38,0,20); tr.Position=UDim2.new(1,-50,0.5,-10)
    tr.BackgroundColor3 = val and C.On or C.Off; tr.BorderSizePixel=0; tr.Parent=c
    Instance.new("UICorner",tr).CornerRadius=UDim.new(1,0)

    -- toggle knob
    local kn = Instance.new("Frame"); kn.Size=UDim2.new(0,16,0,16)
    kn.Position = val and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
    kn.BackgroundColor3=C.White; kn.BorderSizePixel=0; kn.Parent=tr
    Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)

    -- knob shadow
    local ks = Instance.new("UIStroke",kn); ks.Color=Color3.fromRGB(0,0,0); ks.Thickness=1; ks.Transparency=0.8

    local on = val
    local btn = Instance.new("TextButton"); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.Parent=c
    btn.MouseButton1Click:Connect(function()
        on = not on
        TweenService:Create(tr,TweenInfo.new(0.2),{BackgroundColor3=on and C.On or C.Off}):Play()
        TweenService:Create(kn,TweenInfo.new(0.2,Enum.EasingStyle.Quart),{Position=on and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}):Play()
        if cb then cb(on) end
    end)
    return c
end

local function mkBtn(par, name, desc, cb, ord, accent)
    local c = Instance.new("Frame"); c.Size=UDim2.new(1,0,0,40); c.BackgroundColor3=C.Card; c.BorderSizePixel=0; c.LayoutOrder=ord or 0; c.Parent=par
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,8)

    -- left accent bar
    if accent then
        local bar = Instance.new("Frame"); bar.Size=UDim2.new(0,3,0,24); bar.Position=UDim2.new(0,0,0.5,-12)
        bar.BackgroundColor3=accent; bar.BorderSizePixel=0; bar.Parent=c
        Instance.new("UICorner",bar).CornerRadius=UDim.new(0,2)
    end

    local nl = Instance.new("TextLabel"); nl.Size=UDim2.new(1,-40,0,16); nl.Position=UDim2.new(0,accent and 12 or 12,0,5)
    nl.BackgroundTransparency=1; nl.Text=name; nl.TextColor3=C.Txt; nl.TextSize=12; nl.Font=Enum.Font.GothamBold
    nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=c

    local dl = Instance.new("TextLabel"); dl.Size=UDim2.new(1,-40,0,12); dl.Position=UDim2.new(0,accent and 12 or 12,0,22)
    dl.BackgroundTransparency=1; dl.Text=desc; dl.TextColor3=C.TxtDim; dl.TextSize=9; dl.Font=Enum.Font.Gotham
    dl.TextXAlignment=Enum.TextXAlignment.Left; dl.Parent=c

    local arrow = Instance.new("TextLabel"); arrow.Size=UDim2.new(0,16,0,16); arrow.Position=UDim2.new(1,-24,0.5,-8)
    arrow.BackgroundTransparency=1; arrow.Text=">"; arrow.TextColor3=C.TxtMute; arrow.TextSize=12; arrow.Font=Enum.Font.GothamBold; arrow.Parent=c

    local btn = Instance.new("TextButton"); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.Parent=c
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(c,TweenInfo.new(0.08),{BackgroundColor3=C.CardH}):Play()
        task.wait(0.08)
        TweenService:Create(c,TweenInfo.new(0.12),{BackgroundColor3=C.Card}):Play()
        if cb then cb() end
    end)
    return c
end

local function mkSlider(par, name, lo, hi, def, cb, ord)
    local c = Instance.new("Frame"); c.Size=UDim2.new(1,0,0,50); c.BackgroundColor3=C.Card; c.BorderSizePixel=0; c.LayoutOrder=ord or 0; c.Parent=par
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,8)

    local nl = Instance.new("TextLabel"); nl.Size=UDim2.new(0.6,-10,0,16); nl.Position=UDim2.new(0,12,0,5)
    nl.BackgroundTransparency=1; nl.Text=name; nl.TextColor3=C.Txt; nl.TextSize=11; nl.Font=Enum.Font.GothamBold
    nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=c

    local vl = Instance.new("TextLabel"); vl.Size=UDim2.new(0.4,-12,0,16); vl.Position=UDim2.new(0.6,0,0,5)
    vl.BackgroundTransparency=1; vl.Text=tostring(def); vl.TextColor3=C.Accent; vl.TextSize=11; vl.Font=Enum.Font.GothamBold
    vl.TextXAlignment=Enum.TextXAlignment.Right; vl.Parent=c

    local track = Instance.new("Frame"); track.Size=UDim2.new(1,-24,0,5); track.Position=UDim2.new(0,12,0,34)
    track.BackgroundColor3=C.Off; track.BorderSizePixel=0; track.Parent=c
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)

    local pct = math.clamp((def-lo)/(hi-lo),0,1)
    local fill = Instance.new("Frame"); fill.Size=UDim2.new(pct,0,1,0); fill.BackgroundColor3=C.Accent; fill.BorderSizePixel=0; fill.Parent=track
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    local knob = Instance.new("Frame"); knob.Size=UDim2.new(0,14,0,14); knob.Position=UDim2.new(pct,-7,0.5,-7)
    knob.BackgroundColor3=C.White; knob.BorderSizePixel=0; knob.ZIndex=2; knob.Parent=track
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    Instance.new("UIStroke",knob).Color=C.Accent; Instance.new("UIStroke",knob).Thickness=2

    local drag = false
    local sb = Instance.new("TextButton"); sb.Size=UDim2.new(1,0,0,22); sb.Position=UDim2.new(0,0,0,26)
    sb.BackgroundTransparency=1; sb.Text=""; sb.Parent=c
    sb.MouseButton1Down:Connect(function() drag=true end)
    UIS.InputEnded:Connect(function(i)
        if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then drag=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local p2 = math.clamp((i.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            local v = lo + (hi-lo)*p2
            v = (hi-lo)>10 and math.floor(v) or math.floor(v*10)/10
            fill.Size=UDim2.new(p2,0,1,0); knob.Position=UDim2.new(p2,-7,0.5,-7); vl.Text=tostring(v)
            if cb then cb(v) end
        end
    end)
    return c
end

local function mkDropdown(par, name, opts, def, cb, ord)
    local c = Instance.new("Frame"); c.Size=UDim2.new(1,0,0,40); c.BackgroundColor3=C.Card; c.BorderSizePixel=0
    c.LayoutOrder=ord or 0; c.ClipsDescendants=true; c.Parent=par
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,8)

    local nl = Instance.new("TextLabel"); nl.Size=UDim2.new(0.5,-10,0,40); nl.Position=UDim2.new(0,12,0,0)
    nl.BackgroundTransparency=1; nl.Text=name; nl.TextColor3=C.Txt; nl.TextSize=11; nl.Font=Enum.Font.GothamBold
    nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=c

    local sel = Instance.new("TextLabel"); sel.Size=UDim2.new(0.4,-30,0,40); sel.Position=UDim2.new(0.5,0,0,0)
    sel.BackgroundTransparency=1; sel.Text=def or opts[1]; sel.TextColor3=C.Accent; sel.TextSize=11; sel.Font=Enum.Font.GothamBold
    sel.TextXAlignment=Enum.TextXAlignment.Right; sel.Parent=c

    local optFrames = {}
    for i,o in ipairs(opts) do
        local ob = Instance.new("TextButton"); ob.Size=UDim2.new(1,-16,0,30); ob.Position=UDim2.new(0,8,0,40+(i-1)*32)
        ob.BackgroundColor3=C.Sidebar; ob.Text=o; ob.TextColor3=C.Txt; ob.TextSize=10; ob.Font=Enum.Font.Gotham
        ob.BorderSizePixel=0; ob.Visible=false; ob.Parent=c
        Instance.new("UICorner",ob).CornerRadius=UDim.new(0,6)
        ob.MouseButton1Click:Connect(function()
            sel.Text=o; c.Size=UDim2.new(1,0,0,40)
            for _,f in ipairs(optFrames) do f.Visible=false end
            if cb then cb(o) end
        end)
        table.insert(optFrames,ob)
    end

    local dd = Instance.new("TextButton"); dd.Size=UDim2.new(0,20,0,40); dd.Position=UDim2.new(1,-24,0,0)
    dd.BackgroundTransparency=1; dd.Text="v"; dd.TextColor3=C.TxtMute; dd.TextSize=10; dd.Font=Enum.Font.GothamBold; dd.Parent=c
    local open=false
    dd.MouseButton1Click:Connect(function()
        open=not open
        if open then c.Size=UDim2.new(1,0,0,40+#opts*32+8); for _,f in ipairs(optFrames) do f.Visible=true end
        else c.Size=UDim2.new(1,0,0,40); for _,f in ipairs(optFrames) do f.Visible=false end end
    end)
    return c
end

local function mkInput(par, name, ph, def, cb, ord)
    local c = Instance.new("Frame"); c.Size=UDim2.new(1,0,0,40); c.BackgroundColor3=C.Card; c.BorderSizePixel=0; c.LayoutOrder=ord or 0; c.Parent=par
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,8)

    local nl = Instance.new("TextLabel"); nl.Size=UDim2.new(0.4,-10,1,0); nl.Position=UDim2.new(0,12,0,0)
    nl.BackgroundTransparency=1; nl.Text=name; nl.TextColor3=C.Txt; nl.TextSize=11; nl.Font=Enum.Font.GothamBold
    nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=c

    local ib = Instance.new("TextBox"); ib.Size=UDim2.new(0.55,-10,0,26); ib.Position=UDim2.new(0.45,0,0.5,-13)
    ib.BackgroundColor3=C.Sidebar; ib.Text=def or ""; ib.PlaceholderText=ph or ""; ib.TextColor3=C.Txt
    ib.PlaceholderColor3=C.TxtMute; ib.TextSize=10; ib.Font=Enum.Font.Gotham; ib.BorderSizePixel=0; ib.ClearTextOnFocus=false; ib.Parent=c
    Instance.new("UICorner",ib).CornerRadius=UDim.new(0,6)
    ib.FocusLost:Connect(function() if cb then cb(ib.Text) end end)
    return c
end

-- =====================================================================
--  BUILD NAVIGATION
-- =====================================================================
local pageDescs = {
    Fishing  = "Configure automatic fishing settings",
    Selling  = "Manage auto sell and favorite protection",
    Teleport = "Teleport to islands and NPCs",
    Movement = "Speed, jump, fly, and noclip settings",
    Utility  = "Anti-AFK, performance, and server tools",
    Visuals  = "ESP and visual overlay settings",
    Settings = "Configuration, webhook, and session info",
}

local function switchPage(name)
    for n,p in pairs(pages) do p.Visible=(n==name) end
    for n,b in pairs(navBtns) do
        if n==name then
            b.bg.BackgroundColor3 = b.accent
            b.bg.BackgroundTransparency = 0.85
            b.label.TextColor3 = C.Txt
            b.indicator.Visible = true
        else
            b.bg.BackgroundTransparency = 1
            b.label.TextColor3 = C.TxtDim
            b.indicator.Visible = false
        end
    end
    PageTitle.Text = name
    PageDesc.Text = pageDescs[name] or ""
    curPage = name
end

for i, td in ipairs(TabDefs) do
    local name, icon, accent = td[1], td[2], td[3]
    pages[name] = mkPage(name)

    local nbg = Instance.new("Frame")
    nbg.Size=UDim2.new(1,-8,0,32); nbg.BackgroundTransparency=1; nbg.BorderSizePixel=0; nbg.LayoutOrder=i; nbg.Parent=NavList
    Instance.new("UICorner",nbg).CornerRadius=UDim.new(0,8)

    -- left indicator bar
    local ind = Instance.new("Frame"); ind.Size=UDim2.new(0,3,0,18); ind.Position=UDim2.new(0,0,0.5,-9)
    ind.BackgroundColor3=accent; ind.BorderSizePixel=0; ind.Visible=false; ind.Parent=nbg
    Instance.new("UICorner",ind).CornerRadius=UDim.new(0,2)

    -- icon circle
    local ic = Instance.new("Frame"); ic.Size=UDim2.new(0,24,0,24); ic.Position=UDim2.new(0,10,0.5,-12)
    ic.BackgroundColor3=accent; ic.BackgroundTransparency=0.8; ic.BorderSizePixel=0; ic.Parent=nbg
    Instance.new("UICorner",ic).CornerRadius=UDim.new(0,6)

    local icTxt = Instance.new("TextLabel"); icTxt.Size=UDim2.new(1,0,1,0); icTxt.BackgroundTransparency=1
    icTxt.Text=icon; icTxt.TextColor3=accent; icTxt.TextSize=12; icTxt.Font=Enum.Font.GothamBold; icTxt.Parent=ic

    local lb = Instance.new("TextLabel"); lb.Size=UDim2.new(1,-48,0,32); lb.Position=UDim2.new(0,40,0,0)
    lb.BackgroundTransparency=1; lb.Text=name; lb.TextColor3=C.TxtDim; lb.TextSize=11; lb.Font=Enum.Font.GothamBold
    lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=nbg

    local btn = Instance.new("TextButton"); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.Parent=nbg
    btn.MouseButton1Click:Connect(function() switchPage(name) end)

    navBtns[name] = {bg=nbg, label=lb, indicator=ind, accent=accent}
end

-- =====================================================================
--  BUILD PAGES CONTENT
-- =====================================================================

-- === FISHING PAGE ===
local fp = pages["Fishing"]
mkSection(fp,"Fishing Mode",1)
mkToggle(fp,"Auto Fish","Automatically cast and catch fish in a loop",Cfg.AutoFish,function(v)
    Cfg.AutoFish=v; fishOn=v
    if v then task.spawn(fishLoop); notify("Auto Fish","Started (".. (Cfg.InstantMode and "Instant" or Cfg.BlatantMode and "Blatant" or "Normal") ..")")
    else pcall(function() safeFire(Ev.unequip) end); notify("Auto Fish","Stopped") end; cfgSave()
end,2)
mkToggle(fp,"Blatant Mode","Parallel rod casting for 2x speed (moderate risk)",Cfg.BlatantMode,function(v) Cfg.BlatantMode=v; if v then Cfg.InstantMode=false end; cfgSave() end,3)
mkToggle(fp,"Instant Mode","Maximum speed with triple casting (high risk)",Cfg.InstantMode,function(v) Cfg.InstantMode=v; if v then Cfg.BlatantMode=false end; cfgSave() end,4)
mkToggle(fp,"Auto Catch","Background reel spam for extra catch speed",Cfg.AutoCatch,function(v) Cfg.AutoCatch=v; cfgSave() end,5)

mkSection(fp,"Timing",6)
mkSlider(fp,"Fish Delay",0.1,5.0,Cfg.FishDelay,function(v) Cfg.FishDelay=v; cfgSave() end,7)
mkSlider(fp,"Catch Delay",0.1,3.0,Cfg.CatchDelay,function(v) Cfg.CatchDelay=v; cfgSave() end,8)

mkSection(fp,"Automation",9)
mkToggle(fp,"Auto Enchant","Enchant your rod automatically when available",Cfg.AutoEnchant,function(v) Cfg.AutoEnchant=v; cfgSave() end,10)
mkToggle(fp,"Auto Buy Best Rod","Purchase the best affordable rod automatically",Cfg.AutoBuyRod,function(v) Cfg.AutoBuyRod=v; cfgSave() end,11)
mkToggle(fp,"Auto Buy Weather","Buy weather changes to attract rare fish",Cfg.AutoBuyWeather,function(v) Cfg.AutoBuyWeather=v; cfgSave() end,12)
mkToggle(fp,"Auto Quest","Accept and complete quests automatically",Cfg.AutoQuest,function(v) Cfg.AutoQuest=v; cfgSave() end,13)
mkToggle(fp,"Auto Event","Teleport to active events (Megalodon, Worm, etc.)",Cfg.AutoEvent,function(v) Cfg.AutoEvent=v; cfgSave() end,14)
mkToggle(fp,"Auto Artifact","Find and collect artifacts on the map",Cfg.AutoArtifact,function(v) Cfg.AutoArtifact=v; cfgSave() end,15)

-- === SELLING PAGE ===
local sp = pages["Selling"]
mkSection(sp,"Auto Sell",1)
mkToggle(sp,"Auto Sell","Sell fish automatically at set intervals (protects favorites)",Cfg.AutoSell,function(v) Cfg.AutoSell=v; cfgSave() end,2)
mkSlider(sp,"Sell Interval (sec)",10,300,Cfg.SellDelay,function(v) Cfg.SellDelay=v; cfgSave() end,3)
mkBtn(sp,"Sell All Now","Immediately sell all non-favorited fish",function() sellNow() end,4,C.Yellow)

mkSection(sp,"Favorite Protection",5)
mkToggle(sp,"Auto Favorite","Automatically favorite rare fish to protect from selling",Cfg.AutoFavorite,function(v) Cfg.AutoFavorite=v; cfgSave() end,6)
mkDropdown(sp,"Minimum Rarity",{"Legendary","Mythic","Secret"},Cfg.FavoriteRarity,function(v) Cfg.FavoriteRarity=v; cfgSave() end,7)
mkBtn(sp,"Favorite All Rare Now","Scan inventory and favorite all rare fish",function() autoFav(); notify("Done","Inventory scanned!") end,8)

-- === TELEPORT PAGE ===
local tp = pages["Teleport"]
mkSection(tp,"Islands",1)
for i,loc in ipairs(Islands) do
    mkBtn(tp, loc[1], "Teleport to "..loc[1], function() tpTo(loc[1]) end, i+1, C.Blue)
end
mkSection(tp,"NPCs",#Islands+3)
for i,npc in ipairs(NPCs) do
    mkBtn(tp, npc[1], "Teleport to "..npc[1], function() tpTo(npc[1]) end, #Islands+3+i, C.Purple)
end

-- === MOVEMENT PAGE ===
local mp = pages["Movement"]
mkSection(mp,"Speed & Jump",1)
mkSlider(mp,"Walk Speed",16,200,Cfg.WalkSpeed,function(v) Cfg.WalkSpeed=v; cfgSave() end,2)
mkSlider(mp,"Jump Power",50,300,Cfg.JumpPower,function(v) Cfg.JumpPower=v; cfgSave() end,3)

mkSection(mp,"Special Movement",4)
mkToggle(mp,"Infinite Jump","Jump unlimited times while in the air",Cfg.InfJump,function(v) Cfg.InfJump=v; cfgSave() end,5)
mkToggle(mp,"Fly","Fly freely with WASD + Space/Shift controls",Cfg.Fly,function(v) Cfg.Fly=v; if v then flyStart() else flyStop() end; cfgSave() end,6)
mkToggle(mp,"Noclip","Pass through walls and solid objects",Cfg.Noclip,function(v) Cfg.Noclip=v; if v then ncOn() else ncOff() end; cfgSave() end,7)

-- === UTILITY PAGE ===
local up = pages["Utility"]
mkSection(up,"Protection",1)
mkToggle(up,"Anti-AFK","Prevent being kicked for inactivity",Cfg.AntiAFK,function(v) Cfg.AntiAFK=v; if v then afkOn() else afkOff() end; cfgSave() end,2)
mkToggle(up,"Anti-Drown","Automatically resurface when drowning",Cfg.AntiDrown,function(v) Cfg.AntiDrown=v; cfgSave() end,3)

mkSection(up,"Performance",4)
mkToggle(up,"GPU Saver","Minimize graphics for AFK farming sessions",Cfg.GPUSaver,function(v) Cfg.GPUSaver=v; if v then gpuEnable() else gpuDisable() end; cfgSave() end,5)
mkToggle(up,"FPS Boost","Remove particles and effects to increase FPS",Cfg.FPSBoost,function(v) Cfg.FPSBoost=v; if v then fpsBoost() end; cfgSave() end,6)

mkSection(up,"Server",7)
mkBtn(up,"Server Hop","Join a different server with fewer players",function() serverHop() end,8)
mkBtn(up,"Rejoin Server","Reconnect to the current game server",function() TeleportService:Teleport(game.PlaceId) end,9)

-- === VISUALS PAGE ===
local vp = pages["Visuals"]
mkSection(vp,"ESP Overlays",1)
mkToggle(vp,"Fish ESP","Show floating labels on fish in the world",Cfg.FishESP,function(v) Cfg.FishESP=v; if not v then clrESP(espF) end; cfgSave() end,2)
mkToggle(vp,"Player ESP","Show player names and distance indicators",Cfg.PlayerESP,function(v) Cfg.PlayerESP=v; if not v then clrESP(pespF) end; cfgSave() end,3)

-- === SETTINGS PAGE ===
local stp = pages["Settings"]
mkSection(stp,"Discord Webhook",1)
mkToggle(stp,"Enable Webhook","Send rare catch notifications to Discord",Cfg.WebhookOn,function(v) Cfg.WebhookOn=v; cfgSave() end,2)
mkInput(stp,"Webhook URL","https://discord.com/api/webhooks/...",Cfg.WebhookURL,function(v)
    Cfg.WebhookURL=v; cfgSave()
    if v~="" then sendWebhook("Connected!","Moron Fish It webhook active.",3066993); notify("Webhook","Test sent!") end
end,3)

mkSection(stp,"Configuration",4)
mkBtn(stp,"Save Config","Save all current settings to file",function() cfgSave(); notify("Config","Saved!") end,5)
mkBtn(stp,"Load Config","Load previously saved settings from file",function() cfgLoad(); notify("Config","Loaded! Rejoin to apply all.") end,6)
mkBtn(stp,"Reset to Default","Reset all settings back to default values",function()
    for k,v in pairs(Default) do Cfg[k]=v end; cfgSave(); notify("Config","Reset! Rejoin to apply.")
end,7)

mkSection(stp,"Session Statistics",8)
local statLbl = Instance.new("TextLabel")
statLbl.Size=UDim2.new(1,0,0,65); statLbl.BackgroundColor3=C.Card; statLbl.TextColor3=C.Txt
statLbl.TextSize=11; statLbl.Font=Enum.Font.Gotham; statLbl.TextXAlignment=Enum.TextXAlignment.Left
statLbl.TextYAlignment=Enum.TextYAlignment.Top; statLbl.Text="  Loading..."; statLbl.LayoutOrder=9; statLbl.Parent=stp
Instance.new("UICorner",statLbl).CornerRadius=UDim.new(0,8)
Instance.new("UIPadding",statLbl).PaddingLeft=UDim.new(0,12)

task.spawn(function() while true do
    local e=tick()-t0; local h=math.floor(e/3600); local m=math.floor((e%3600)/60); local s=math.floor(e%60)
    statLbl.Text=string.format("Player: %s\nTotal Catches: %d\nSession Time: %02d:%02d:%02d",LP.Name,catches,h,m,s)
    task.wait(1)
end end)

mkSection(stp,"About",10)
local aboutLbl = Instance.new("TextLabel")
aboutLbl.Size=UDim2.new(1,0,0,50); aboutLbl.BackgroundColor3=C.Card; aboutLbl.TextColor3=C.TxtDim
aboutLbl.TextSize=10; aboutLbl.Font=Enum.Font.Gotham; aboutLbl.TextXAlignment=Enum.TextXAlignment.Center
aboutLbl.Text="MORON FISH IT v2.0.0\nNo Key  |  No HWID  |  Free Forever\nProfessional Edition"; aboutLbl.LayoutOrder=11; aboutLbl.Parent=stp
Instance.new("UICorner",aboutLbl).CornerRadius=UDim.new(0,8)

-- =====================================================================
--  DRAGGING
-- =====================================================================
do
    local dragging,dragIn,dragSt,startP = false,nil,nil,nil
    TitleBar = SB -- drag from sidebar
    SB.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragSt=i.Position; startP=MF.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    SB.InputChanged:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then dragIn=i end
    end)
    UIS.InputChanged:Connect(function(i)
        if i==dragIn and dragging then
            local d=i.Position-dragSt
            MF.Position=UDim2.new(startP.X.Scale,startP.X.Offset+d.X,startP.Y.Scale,startP.Y.Offset+d.Y)
        end
    end)
end

-- Also drag from page header
do
    local dragging,dragIn,dragSt,startP = false,nil,nil,nil
    PageHeader.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragSt=i.Position; startP=MF.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    PageHeader.InputChanged:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then dragIn=i end
    end)
    UIS.InputChanged:Connect(function(i)
        if i==dragIn and dragging then
            local d=i.Position-dragSt
            MF.Position=UDim2.new(startP.X.Scale,startP.X.Offset+d.X,startP.Y.Scale,startP.Y.Offset+d.Y)
        end
    end)
end

-- =====================================================================
--  MINIMIZE / TOGGLE UI
-- =====================================================================
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(MF,TweenInfo.new(0.3,Enum.EasingStyle.Quart),{Size=UDim2.new(0,140,0,65)}):Play()
        CA.Visible = false
        MinBtn.Text = "+"
    else
        CA.Visible = true
        TweenService:Create(MF,TweenInfo.new(0.3,Enum.EasingStyle.Quart),{Size=UDim2.new(0,580,0,400)}):Play()
        MinBtn.Text = "-"
    end
end)

-- Right Shift to toggle
UIS.InputBegan:Connect(function(i,p)
    if p then return end
    if i.KeyCode==Enum.KeyCode.RightShift then MF.Visible=not MF.Visible end
end)

-- =====================================================================
--  STARTUP
-- =====================================================================
switchPage("Fishing")

-- Fade in
MF.BackgroundTransparency = 1
TweenService:Create(MF,TweenInfo.new(0.5,Enum.EasingStyle.Quart),{BackgroundTransparency=0}):Play()

notify("Moron Fish It","v2.0.0 Loaded! Press RightShift to toggle UI")
sendWebhook("Script Started!","**"..LP.Name.."** loaded Moron Fish It\nServer: "..game.JobId:sub(1,8),3066993)

print("==============================================")
print("  MORON FISH IT v2.0.0 - Professional Edition")
print("  No Key | No HWID | Free Forever")
print("  Press RightShift to toggle UI")
print("==============================================")
