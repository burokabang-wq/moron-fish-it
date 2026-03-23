-- ====================================================================
--              MORON FISH IT v9.0 - by GasUp ID
--         No Key | No HWID | Free Forever | Undetected
-- ====================================================================

-- Cleanup old
pcall(function()
    for _, v in pairs(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
        if v:GetAttribute("_mfi") then v:Destroy() end
    end
end)
pcall(function()
    if gethui then
        for _, v in pairs(gethui():GetChildren()) do
            if v:GetAttribute("_mfi") then v:Destroy() end
        end
    end
end)

-- Services
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Http = game:GetService("HttpService")
local LP = Players.LocalPlayer
local GUI_PARENT = (gethui and gethui()) or LP:WaitForChild("PlayerGui")

local VU
pcall(function() VU = game:GetService("VirtualUser") end)

-- ====================================================================
--                        CONFIG
-- ====================================================================
local CFG = {
    AutoFish = false, BlatantMode = false, AutoCatch = false,
    AutoSell = false, AutoFavorite = true, FavRarity = "Mythic",
    FishDelay = 0.9, CatchDelay = 0.2, SellDelay = 30,
    AntiAFK = true, GPUSaver = false, FPSBoost = false,
    WalkSpeed = 16, JumpPower = 50, InfJump = false,
    Fly = false, Noclip = false, AntiDrown = false,
    FishESP = false, PlayerESP = false,
}
local DEF = {}; for k,v in pairs(CFG) do DEF[k] = v end

local FOLDER = "MoronFishIt"
local CFILE = FOLDER.."/cfg.json"
local function ensureF() if not isfolder then return false end; if not isfolder(FOLDER) then pcall(makefolder, FOLDER) end; return isfolder(FOLDER) end
local function saveCfg() if not writefile or not ensureF() then return end; pcall(writefile, CFILE, Http:JSONEncode(CFG)) end
local function loadCfg() if not readfile or not isfile or not isfile(CFILE) then return end; pcall(function() local d=Http:JSONDecode(readfile(CFILE)); for k,v in pairs(d) do if DEF[k]~=nil then CFG[k]=v end end end) end
loadCfg()

-- ====================================================================
--                    NETWORK EVENTS
-- ====================================================================
local E = {}
local evOK = false
local evStat = "Loading..."

task.spawn(function()
    local s, err = pcall(function()
        -- Hardcode path exactly like working source
        local net = RS:WaitForChild("Packages", 10)
            :WaitForChild("_Index", 10)

        -- Find sleitnick_net folder (any version)
        local nf
        for _, c in pairs(net:GetChildren()) do
            if c.Name:find("sleitnick_net") then nf = c; break end
        end
        -- Fallback: try exact name
        if not nf then
            nf = net:FindFirstChild("sleitnick_net@0.2.0")
        end
        if not nf then error("sleitnick_net not found") end

        local netF = nf:WaitForChild("net", 10)
        if not netF then error("net folder not found") end

        -- These are the EXACT names from the working script
        -- In Fish It, children are named with "/" in their actual name
        local function getChild(name, timeout)
            local c = netF:FindFirstChild(name)
            if c then return c end
            return netF:WaitForChild(name, timeout or 5)
        end

        E.fishing  = getChild("RE/FishingCompleted")
        E.sell     = getChild("RF/SellAllItems")
        E.charge   = getChild("RF/ChargeFishingRod")
        E.minigame = getChild("RF/RequestFishingMinigameStarted")
        E.cancel   = getChild("RF/CancelFishingInputs")
        E.equip    = getChild("RE/EquipToolFromHotbar")
        E.unequip  = getChild("RE/UnequipToolFromHotbar")
        E.favorite = getChild("RE/FavoriteItem")

        -- Count loaded
        local cnt = 0
        for _, v in pairs(E) do if v then cnt = cnt + 1 end end
        if cnt >= 5 then
            evOK = true
            evStat = "Ready ("..cnt.."/8)"
        else
            evStat = "Partial ("..cnt.."/8)"
        end
    end)
    if not s then
        evStat = "Err"
        warn("[MFI] "..tostring(err))
    end
end)

-- Modules for favorite
local ItemUtil, Replion, PData
task.spawn(function()
    pcall(function()
        ItemUtil = require(RS.Shared.ItemUtility)
        Replion = require(RS.Packages.Replion)
        PData = Replion.Client:WaitReplion("Data")
    end)
end)

local RARITY = {Common=1,Uncommon=2,Rare=3,Epic=4,Legendary=5,Mythic=6,Secret=7}
local LOCS = {
    {"Spawn", CFrame.new(45.27,252.56,2987.10)},
    {"Sisyphus Statue", CFrame.new(-3728.21,-135.07,-1012.12)},
    {"Coral Reefs", CFrame.new(-3114.78,1.32,2237.52)},
    {"Esoteric Depths", CFrame.new(3248.37,-1301.53,1403.82)},
    {"Crater Island", CFrame.new(1016.49,20.09,5069.27)},
    {"Lost Isle", CFrame.new(-3618.15,240.83,-1317.45)},
    {"Weather Machine", CFrame.new(-1488.51,83.17,1876.30)},
    {"Tropical Grove", CFrame.new(-2095.34,197.19,3718.08)},
    {"Mount Hallow", CFrame.new(2136.62,78.91,3272.50)},
    {"Treasure Room", CFrame.new(-3606.34,-266.57,-1580.97)},
    {"Kohana", CFrame.new(-663.90,3.04,718.79)},
    {"Underground Cellar", CFrame.new(2109.52,-94.18,-708.60)},
    {"Ancient Jungle", CFrame.new(1831.71,6.62,-299.27)},
    {"Sacred Temple", CFrame.new(1466.92,-21.87,-622.83)},
}

-- ====================================================================
--                    CORE FUNCTIONS
-- ====================================================================
local isFishing = false
local fishActive = false

local function castRod()
    if not evOK then return end
    pcall(function()
        E.equip:FireServer(1)
        task.wait(0.05)
        E.charge:InvokeServer(1755848498.4834)
        task.wait(0.02)
        E.minigame:InvokeServer(1.2854545116425, 1)
    end)
end

local function reelIn()
    if not evOK then return end
    pcall(function() E.fishing:FireServer() end)
end

local function fishLoop()
    while fishActive do
        if CFG.BlatantMode then
            isFishing = true
            pcall(function()
                E.equip:FireServer(1)
                task.wait(0.01)
                task.spawn(function()
                    E.charge:InvokeServer(1755848498.4834)
                    task.wait(0.01)
                    E.minigame:InvokeServer(1.2854545116425, 1)
                end)
                task.wait(0.05)
                task.spawn(function()
                    E.charge:InvokeServer(1755848498.4834)
                    task.wait(0.01)
                    E.minigame:InvokeServer(1.2854545116425, 1)
                end)
            end)
            task.wait(CFG.FishDelay)
            for i=1,5 do pcall(function() E.fishing:FireServer() end); task.wait(0.01) end
            task.wait(CFG.CatchDelay * 0.5)
            isFishing = false
        else
            isFishing = true
            castRod()
            task.wait(CFG.FishDelay)
            reelIn()
            task.wait(CFG.CatchDelay)
            isFishing = false
        end
        task.wait(0.05)
    end
end

local function doSell()
    if not evOK or not E.sell then return end
    pcall(function() E.sell:InvokeServer() end)
end

local favDone = {}
local function doFavorite()
    if not CFG.AutoFavorite or not PData or not ItemUtil then return end
    pcall(function()
        local items = PData:GetExpect("Inventory").Items
        if not items then return end
        for _, item in ipairs(items) do
            local d = ItemUtil:GetItemData(item.Id)
            if d and d.Data then
                local r = d.Data.Rarity or "Common"
                local v = RARITY[r] or 0
                local t = RARITY[CFG.FavRarity] or 6
                if v >= t and not item.Favorited and not favDone[item.UUID] then
                    E.favorite:FireServer(item.UUID)
                    favDone[item.UUID] = true
                    task.wait(0.3)
                end
            end
        end
    end)
end

local function teleportTo(cf)
    pcall(function()
        local c = LP.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            c.HumanoidRootPart.CFrame = cf
        end
    end)
end

-- GPU Saver
local gpuOn = false
local gpuScr = nil
local function gpuEnable()
    if gpuOn then return end; gpuOn = true
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        game.Lighting.GlobalShadows = false
        game.Lighting.FogEnd = 1
        if setfpscap then setfpscap(8) end
    end)
    gpuScr = Instance.new("ScreenGui"); gpuScr.ResetOnSpawn = false; gpuScr.DisplayOrder = 999999; gpuScr:SetAttribute("_mfi", true)
    local f = Instance.new("Frame", gpuScr); f.Size = UDim2.new(1,0,1,0); f.BackgroundColor3 = Color3.fromRGB(15,15,15)
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0,300,0,60); l.Position = UDim2.new(0.5,-150,0.5,-30)
    l.BackgroundTransparency = 1; l.Text = "GPU SAVER ACTIVE\nMoron Fish It Running..."; l.TextColor3 = Color3.fromRGB(0,200,130); l.TextSize = 20; l.Font = Enum.Font.GothamBold
    gpuScr.Parent = GUI_PARENT
end
local function gpuDisable()
    if not gpuOn then return end; gpuOn = false
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        game.Lighting.GlobalShadows = true; game.Lighting.FogEnd = 100000
        if setfpscap then setfpscap(0) end
    end)
    if gpuScr then gpuScr:Destroy(); gpuScr = nil end
end

local function fpsBoost()
    pcall(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled = false
            end
        end
        if setfpscap then setfpscap(60) end
    end)
end

-- Anti-AFK
if VU then
    LP.Idled:Connect(function()
        pcall(function() VU:CaptureController(); VU:ClickButton2(Vector2.new()) end)
    end)
end

-- ====================================================================
--                    SPLASH SCREEN
-- ====================================================================
local splash = Instance.new("ScreenGui"); splash.ResetOnSpawn = false; splash:SetAttribute("_mfi", true); splash.Parent = GUI_PARENT
local sf = Instance.new("Frame", splash); sf.Size = UDim2.new(0,200,0,65); sf.Position = UDim2.new(0.5,-100,0.5,-32)
sf.BackgroundColor3 = Color3.fromRGB(22,22,28); sf.BorderSizePixel = 0
Instance.new("UICorner", sf).CornerRadius = UDim.new(0,10)
local st = Instance.new("TextLabel", sf); st.Size = UDim2.new(1,0,0,30); st.Position = UDim2.new(0,0,0,8)
st.BackgroundTransparency = 1; st.Text = "GasUp ID"; st.TextColor3 = Color3.fromRGB(0,200,130); st.TextSize = 20; st.Font = Enum.Font.GothamBold
local ss = Instance.new("TextLabel", sf); ss.Size = UDim2.new(1,0,0,18); ss.Position = UDim2.new(0,0,0,38)
ss.BackgroundTransparency = 1; ss.Text = "Moron Fish It v9.0"; ss.TextColor3 = Color3.fromRGB(160,160,170); ss.TextSize = 12; ss.Font = Enum.Font.Gotham
task.wait(1.5)
splash:Destroy()

-- ====================================================================
--                    MAIN UI
-- ====================================================================
local sg = Instance.new("ScreenGui"); sg.ResetOnSpawn = false; sg:SetAttribute("_mfi", true); sg.Parent = GUI_PARENT

-- Main frame
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0,460,0,320)
main.Position = UDim2.new(0.5,-230,0.5,-160)
main.BackgroundColor3 = Color3.fromRGB(22,22,28)
main.BorderSizePixel = 0; main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

-- Top bar
local top = Instance.new("Frame", main); top.Size = UDim2.new(1,0,0,36); top.BackgroundColor3 = Color3.fromRGB(28,28,35); top.BorderSizePixel = 0; top.ZIndex = 5
Instance.new("UICorner", top).CornerRadius = UDim.new(0,12)
local topFix = Instance.new("Frame", top); topFix.Size = UDim2.new(1,0,0,14); topFix.Position = UDim2.new(0,0,1,-14); topFix.BackgroundColor3 = Color3.fromRGB(28,28,35); topFix.BorderSizePixel = 0; topFix.ZIndex = 5

-- Title
local tl = Instance.new("TextLabel", top); tl.Size = UDim2.new(0,120,1,0); tl.Position = UDim2.new(0,14,0,0)
tl.BackgroundTransparency = 1; tl.Text = "Moron Fish It"; tl.TextColor3 = Color3.fromRGB(0,200,130); tl.TextSize = 14; tl.Font = Enum.Font.GothamBold; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.ZIndex = 6

-- Version
local vl = Instance.new("TextLabel", top); vl.Size = UDim2.new(0,30,1,0); vl.Position = UDim2.new(0,132,0,0)
vl.BackgroundTransparency = 1; vl.Text = "v9.0"; vl.TextColor3 = Color3.fromRGB(70,70,80); vl.TextSize = 10; vl.Font = Enum.Font.Gotham; vl.TextXAlignment = Enum.TextXAlignment.Left; vl.ZIndex = 6

-- Status
local statLbl = Instance.new("TextLabel", top); statLbl.Size = UDim2.new(0,90,1,0); statLbl.Position = UDim2.new(1,-130,0,0)
statLbl.BackgroundTransparency = 1; statLbl.Text = evStat; statLbl.TextColor3 = Color3.fromRGB(70,70,80); statLbl.TextSize = 9; statLbl.Font = Enum.Font.Gotham; statLbl.TextXAlignment = Enum.TextXAlignment.Right; statLbl.ZIndex = 6
task.spawn(function() while statLbl.Parent do pcall(function() statLbl.Text = evStat end); task.wait(1) end end)

-- Close btn
local xBtn = Instance.new("TextButton", top); xBtn.Size = UDim2.new(0,36,0,36); xBtn.Position = UDim2.new(1,-36,0,0)
xBtn.BackgroundTransparency = 1; xBtn.Text = "x"; xBtn.TextColor3 = Color3.fromRGB(120,120,130); xBtn.TextSize = 16; xBtn.Font = Enum.Font.GothamBold; xBtn.ZIndex = 7

-- Drag
local drag, dS, dP
top.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag=true; dS=i.Position; dP=main.Position end end)
top.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag=false end end)
UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d=i.Position-dS; main.Position = UDim2.new(dP.X.Scale,dP.X.Offset+d.X,dP.Y.Scale,dP.Y.Offset+d.Y) end end)

-- Sidebar
local side = Instance.new("Frame", main); side.Size = UDim2.new(0,125,1,-36); side.Position = UDim2.new(0,0,0,36)
side.BackgroundColor3 = Color3.fromRGB(18,18,23); side.BorderSizePixel = 0
local sep = Instance.new("Frame", side); sep.Size = UDim2.new(0,1,1,0); sep.Position = UDim2.new(1,0,0,0); sep.BackgroundColor3 = Color3.fromRGB(40,40,50); sep.BorderSizePixel = 0

-- Content
local content = Instance.new("Frame", main); content.Size = UDim2.new(1,-126,1,-36); content.Position = UDim2.new(0,126,0,36)
content.BackgroundTransparency = 1; content.ClipsDescendants = true

-- Tab definitions
local TABS = {"Fishing","Selling","Teleport","Movement","Utility","Visuals","Settings"}
local curTab = "Fishing"
local tabData = {}
local pageFrames = {}

-- Sidebar layout
local sLay = Instance.new("UIListLayout", side); sLay.SortOrder = Enum.SortOrder.LayoutOrder; sLay.Padding = UDim.new(0,2)
Instance.new("UIPadding", side).PaddingTop = UDim.new(0,6)

for i, name in ipairs(TABS) do
    local btn = Instance.new("TextButton", side)
    btn.Size = UDim2.new(1,0,0,30); btn.BackgroundTransparency = 1; btn.BorderSizePixel = 0
    btn.Text = "    "..name; btn.TextColor3 = Color3.fromRGB(140,140,150); btn.TextSize = 12
    btn.Font = Enum.Font.Gotham; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.LayoutOrder = i

    local ind = Instance.new("Frame", btn)
    ind.Size = UDim2.new(0,3,0,16); ind.Position = UDim2.new(0,0,0.5,-8)
    ind.BackgroundColor3 = Color3.fromRGB(0,200,130); ind.BorderSizePixel = 0; ind.Visible = (name == curTab)
    Instance.new("UICorner", ind).CornerRadius = UDim.new(0,2)

    tabData[name] = {btn=btn, ind=ind}
end

-- Create pages
for _, name in ipairs(TABS) do
    local scr = Instance.new("ScrollingFrame", content)
    scr.Size = UDim2.new(1,-4,1,-4); scr.Position = UDim2.new(0,2,0,2)
    scr.BackgroundTransparency = 1; scr.BorderSizePixel = 0; scr.ScrollBarThickness = 3
    scr.ScrollBarImageColor3 = Color3.fromRGB(60,60,70); scr.CanvasSize = UDim2.new(0,0,0,0)
    scr.AutomaticCanvasSize = Enum.AutomaticSize.Y; scr.Visible = (name == curTab)

    local lay = Instance.new("UIListLayout", scr); lay.SortOrder = Enum.SortOrder.LayoutOrder; lay.Padding = UDim.new(0,4)
    local pad = Instance.new("UIPadding", scr); pad.PaddingLeft = UDim.new(0,8); pad.PaddingRight = UDim.new(0,8); pad.PaddingTop = UDim.new(0,6)

    pageFrames[name] = scr
end

-- ====================================================================
--                    UI BUILDERS
-- ====================================================================
local function mkSec(pg, txt, ord)
    local l = Instance.new("TextLabel", pg); l.Size = UDim2.new(1,0,0,22); l.BackgroundTransparency = 1
    l.Text = txt; l.TextColor3 = Color3.fromRGB(80,80,95); l.TextSize = 10; l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left; l.LayoutOrder = ord
end

local function mkToggle(pg, title, desc, key, ord, cb)
    local f = Instance.new("Frame", pg); f.Size = UDim2.new(1,0,0, desc and 40 or 32)
    f.BackgroundColor3 = Color3.fromRGB(30,30,38); f.BorderSizePixel = 0; f.LayoutOrder = ord
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)

    local t = Instance.new("TextLabel", f); t.Size = UDim2.new(1,-60,0,18); t.Position = UDim2.new(0,12,0, desc and 4 or 7)
    t.BackgroundTransparency = 1; t.Text = title; t.TextColor3 = Color3.fromRGB(210,210,220); t.TextSize = 12
    t.Font = Enum.Font.GothamMedium; t.TextXAlignment = Enum.TextXAlignment.Left

    if desc then
        local d = Instance.new("TextLabel", f); d.Size = UDim2.new(1,-60,0,14); d.Position = UDim2.new(0,12,0,22)
        d.BackgroundTransparency = 1; d.Text = desc; d.TextColor3 = Color3.fromRGB(70,70,85); d.TextSize = 9
        d.Font = Enum.Font.Gotham; d.TextXAlignment = Enum.TextXAlignment.Left
    end

    local bg = Instance.new("Frame", f); bg.Size = UDim2.new(0,38,0,20); bg.Position = UDim2.new(1,-50,0.5,-10)
    bg.BackgroundColor3 = CFG[key] and Color3.fromRGB(0,190,120) or Color3.fromRGB(50,50,60); bg.BorderSizePixel = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame", bg); knob.Size = UDim2.new(0,16,0,16); knob.BorderSizePixel = 0
    knob.Position = CFG[key] and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 2
    btn.MouseButton1Click:Connect(function()
        CFG[key] = not CFG[key]; local on = CFG[key]
        local tw = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
        TS:Create(bg, tw, {BackgroundColor3 = on and Color3.fromRGB(0,190,120) or Color3.fromRGB(50,50,60)}):Play()
        TS:Create(knob, tw, {Position = on and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}):Play()
        saveCfg()
        if cb then cb(on) end
    end)
end

local function mkBtn(pg, title, ord, cb)
    local b = Instance.new("TextButton", pg); b.Size = UDim2.new(1,0,0,32)
    b.BackgroundColor3 = Color3.fromRGB(30,30,38); b.BorderSizePixel = 0; b.Text = title
    b.TextColor3 = Color3.fromRGB(190,190,200); b.TextSize = 12; b.Font = Enum.Font.GothamMedium; b.LayoutOrder = ord
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
end

local function mkSlider(pg, title, key, mn, mx, step, ord)
    local f = Instance.new("Frame", pg); f.Size = UDim2.new(1,0,0,46)
    f.BackgroundColor3 = Color3.fromRGB(30,30,38); f.BorderSizePixel = 0; f.LayoutOrder = ord
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)

    local t = Instance.new("TextLabel", f); t.Size = UDim2.new(1,-55,0,18); t.Position = UDim2.new(0,12,0,4)
    t.BackgroundTransparency = 1; t.Text = title; t.TextColor3 = Color3.fromRGB(210,210,220); t.TextSize = 12
    t.Font = Enum.Font.GothamMedium; t.TextXAlignment = Enum.TextXAlignment.Left

    local vl = Instance.new("TextLabel", f); vl.Size = UDim2.new(0,45,0,18); vl.Position = UDim2.new(1,-55,0,4)
    vl.BackgroundTransparency = 1; vl.Text = tostring(CFG[key]); vl.TextColor3 = Color3.fromRGB(0,190,120)
    vl.TextSize = 11; vl.Font = Enum.Font.GothamBold; vl.TextXAlignment = Enum.TextXAlignment.Right

    local sbg = Instance.new("Frame", f); sbg.Size = UDim2.new(1,-24,0,4); sbg.Position = UDim2.new(0,12,0,32)
    sbg.BackgroundColor3 = Color3.fromRGB(45,45,55); sbg.BorderSizePixel = 0
    Instance.new("UICorner", sbg).CornerRadius = UDim.new(1,0)

    local pct = math.clamp((CFG[key]-mn)/(mx-mn), 0, 1)
    local fill = Instance.new("Frame", sbg); fill.Size = UDim2.new(pct,0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(0,190,120); fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    local sBtn = Instance.new("TextButton", f); sBtn.Size = UDim2.new(1,-20,0,18); sBtn.Position = UDim2.new(0,10,0,24)
    sBtn.BackgroundTransparency = 1; sBtn.Text = ""; sBtn.ZIndex = 2

    local sliding = false
    local function upd(pos)
        local abs = sbg.AbsolutePosition; local sz = sbg.AbsoluteSize
        local rel = math.clamp((pos.X - abs.X)/sz.X, 0, 1)
        local val = mn + (mx-mn)*rel
        val = math.floor(val/step+0.5)*step; val = math.clamp(val, mn, mx)
        if step < 1 then val = math.floor(val*10+0.5)/10 end
        CFG[key] = val; vl.Text = tostring(val)
        fill.Size = UDim2.new(math.clamp((val-mn)/(mx-mn),0,1),0,1,0)
        saveCfg()
    end

    sBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding=true; upd(i.Position) end end)
    sBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding=false end end)
    UIS.InputChanged:Connect(function(i) if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i.Position) end end)
end

local function mkDropdown(pg, title, key, options, ord)
    local f = Instance.new("Frame", pg); f.Size = UDim2.new(1,0,0,32)
    f.BackgroundColor3 = Color3.fromRGB(30,30,38); f.BorderSizePixel = 0; f.LayoutOrder = ord
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)

    local t = Instance.new("TextLabel", f); t.Size = UDim2.new(0.5,0,1,0); t.Position = UDim2.new(0,12,0,0)
    t.BackgroundTransparency = 1; t.Text = title; t.TextColor3 = Color3.fromRGB(210,210,220); t.TextSize = 12
    t.Font = Enum.Font.GothamMedium; t.TextXAlignment = Enum.TextXAlignment.Left

    local cur = Instance.new("TextButton", f); cur.Size = UDim2.new(0.4,0,0,24); cur.Position = UDim2.new(0.55,0,0.5,-12)
    cur.BackgroundColor3 = Color3.fromRGB(40,40,50); cur.BorderSizePixel = 0; cur.Text = CFG[key]
    cur.TextColor3 = Color3.fromRGB(0,190,120); cur.TextSize = 11; cur.Font = Enum.Font.GothamBold
    Instance.new("UICorner", cur).CornerRadius = UDim.new(0,6)

    local idx = 1
    for i, v in ipairs(options) do if v == CFG[key] then idx = i end end

    cur.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        CFG[key] = options[idx]; cur.Text = options[idx]; saveCfg()
    end)
end

-- ====================================================================
--                    POPULATE PAGES
-- ====================================================================
-- FISHING
local fp = pageFrames["Fishing"]
mkSec(fp, "FISHING MODE", 1)
mkToggle(fp, "Auto Fish", "Auto cast and reel fish", "AutoFish", 2, function(on)
    fishActive = on
    if on then task.spawn(fishLoop) end
end)
mkToggle(fp, "Blatant Mode", "2x parallel casts, faster", "BlatantMode", 3)
mkToggle(fp, "Auto Catch", "Extra reel spam in background", "AutoCatch", 4)
mkSec(fp, "TIMING", 5)
mkSlider(fp, "Fish Delay", "FishDelay", 0.1, 5, 0.1, 6)
mkSlider(fp, "Catch Delay", "CatchDelay", 0.1, 3, 0.1, 7)

-- SELLING
local sp = pageFrames["Selling"]
mkSec(sp, "AUTO SELL", 1)
mkToggle(sp, "Auto Sell", "Sell non-favorited fish", "AutoSell", 2)
mkSlider(sp, "Sell Interval (sec)", "SellDelay", 10, 300, 5, 3)
mkBtn(sp, "Sell All Now", 4, doSell)
mkSec(sp, "FAVORITES", 5)
mkToggle(sp, "Auto Favorite", "Auto favorite rare fish", "AutoFavorite", 6)
mkDropdown(sp, "Min Rarity", "FavRarity", {"Legendary","Mythic","Secret"}, 7)
mkBtn(sp, "Favorite All Now", 8, doFavorite)

-- TELEPORT
local tp = pageFrames["Teleport"]
mkSec(tp, "ISLANDS", 1)
for i, loc in ipairs(LOCS) do
    mkBtn(tp, loc[1], i+1, function() teleportTo(loc[2]) end)
end

-- MOVEMENT
local mp = pageFrames["Movement"]
mkSec(mp, "CHARACTER", 1)
mkSlider(mp, "Walk Speed", "WalkSpeed", 16, 200, 1, 2)
mkSlider(mp, "Jump Power", "JumpPower", 50, 300, 5, 3)
mkToggle(mp, "Infinite Jump", "Jump in mid-air", "InfJump", 4)
mkToggle(mp, "Fly", "WASD + Space/Shift to fly", "Fly", 5)
mkToggle(mp, "Noclip", "Walk through walls", "Noclip", 6)
mkToggle(mp, "Anti Drown", "Auto resurface underwater", "AntiDrown", 7)

-- UTILITY
local up = pageFrames["Utility"]
mkSec(up, "PERFORMANCE", 1)
mkToggle(up, "GPU Saver", "Low graphics for AFK", "GPUSaver", 2, function(on) if on then gpuEnable() else gpuDisable() end end)
mkToggle(up, "FPS Boost", "Remove particles & effects", "FPSBoost", 3, function(on) if on then fpsBoost() end end)
mkToggle(up, "Anti-AFK", "Prevent idle kick", "AntiAFK", 4)
mkSec(up, "SERVER", 5)
mkBtn(up, "Server Hop", 6, function()
    pcall(function()
        local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        local data = Http:JSONDecode(game:HttpGet(url))
        for _, s in pairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id); return
            end
        end
    end)
end)
mkBtn(up, "Rejoin Server", 7, function()
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId) end)
end)

-- VISUALS
local vp = pageFrames["Visuals"]
mkSec(vp, "ESP", 1)
mkToggle(vp, "Fish ESP", "Show fish labels (Drawing)", "FishESP", 2)
mkToggle(vp, "Player ESP", "Show player names + distance", "PlayerESP", 3)

-- SETTINGS
local stp = pageFrames["Settings"]
mkSec(stp, "CONFIG", 1)
mkBtn(stp, "Save Config", 2, saveCfg)
mkBtn(stp, "Load Config", 3, function() loadCfg() end)
mkBtn(stp, "Reset to Default", 4, function() for k,v in pairs(DEF) do CFG[k]=v end; saveCfg() end)
mkSec(stp, "INFO", 5)
local info = Instance.new("TextLabel", stp); info.Size = UDim2.new(1,0,0,55); info.BackgroundTransparency = 1
info.Text = "Moron Fish It v9.0\nby GasUp ID\nNo Key | No HWID | Free Forever"; info.TextColor3 = Color3.fromRGB(80,80,95)
info.TextSize = 10; info.Font = Enum.Font.Gotham; info.TextXAlignment = Enum.TextXAlignment.Left; info.LayoutOrder = 6

-- ====================================================================
--                    TAB SWITCHING
-- ====================================================================
local function switchTab(name)
    curTab = name
    for tn, d in pairs(tabData) do
        local a = (tn == name)
        d.ind.Visible = a
        d.btn.TextColor3 = a and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,140,150)
        d.btn.Font = a and Enum.Font.GothamBold or Enum.Font.Gotham
    end
    for pn, pg in pairs(pageFrames) do pg.Visible = (pn == name) end
end
for tn, d in pairs(tabData) do d.btn.MouseButton1Click:Connect(function() switchTab(tn) end) end
switchTab("Fishing")

-- ====================================================================
--                    FLOATING BUTTON
-- ====================================================================
local floatBtn = Instance.new("TextButton", sg)
floatBtn.Size = UDim2.new(0,40,0,40); floatBtn.Position = UDim2.new(0,10,0.5,-20)
floatBtn.BackgroundColor3 = Color3.fromRGB(22,22,28); floatBtn.BorderSizePixel = 0
floatBtn.Text = "M"; floatBtn.TextColor3 = Color3.fromRGB(0,200,130); floatBtn.TextSize = 18
floatBtn.Font = Enum.Font.GothamBold; floatBtn.Visible = false
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(0,10)

floatBtn.MouseButton1Click:Connect(function() main.Visible = true; floatBtn.Visible = false end)

-- Float drag (mobile)
local fD, fDS, fSP
floatBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then fD=true; fDS=i.Position; fSP=floatBtn.Position end end)
UIS.InputChanged:Connect(function(i) if fD and i.UserInputType == Enum.UserInputType.Touch then local d=i.Position-fDS; floatBtn.Position = UDim2.new(fSP.X.Scale,fSP.X.Offset+d.X,fSP.Y.Scale,fSP.Y.Offset+d.Y) end end)
floatBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then fD=false end end)

xBtn.MouseButton1Click:Connect(function() main.Visible = false; floatBtn.Visible = true end)
UIS.InputBegan:Connect(function(i, g) if g then return end; if i.KeyCode == Enum.KeyCode.RightShift then main.Visible = not main.Visible; floatBtn.Visible = not main.Visible end end)

-- ====================================================================
--                    BACKGROUND LOOPS
-- ====================================================================
-- Auto Catch
task.spawn(function()
    while true do
        if CFG.AutoCatch and not isFishing and evOK then
            pcall(function() E.fishing:FireServer() end)
        end
        task.wait(CFG.CatchDelay)
    end
end)

-- Auto Sell
task.spawn(function()
    while true do
        task.wait(CFG.SellDelay)
        if CFG.AutoSell and evOK then doSell() end
    end
end)

-- Auto Favorite
task.spawn(function()
    while true do
        task.wait(10)
        if CFG.AutoFavorite then doFavorite() end
    end
end)

-- Movement
task.spawn(function()
    while true do
        pcall(function()
            local c = LP.Character; if not c then return end
            local hum = c:FindFirstChildOfClass("Humanoid")
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hum then
                if CFG.WalkSpeed ~= 16 then hum.WalkSpeed = CFG.WalkSpeed end
                if CFG.JumpPower ~= 50 then hum.JumpPower = CFG.JumpPower end
            end
            if CFG.Noclip then
                for _, p in pairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
            if CFG.AntiDrown and hrp and hrp.Position.Y < -5 then
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 10, 0)
            end
        end)
        task.wait(0.1)
    end
end)

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    if CFG.InfJump then
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
            if CFG.Fly and hrp then
                if not flyBV then
                    flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce = Vector3.new(9e9,9e9,9e9)
                    flyBV.Velocity = Vector3.new(0,0,0); flyBV.Parent = hrp
                end
                local cam = workspace.CurrentCamera; local dir = Vector3.new(0,0,0)
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
                flyBV.Velocity = dir * 80
            else
                if flyBV then flyBV:Destroy(); flyBV = nil end
            end
        end)
        task.wait(0.05)
    end
end)

-- Fish ESP (Drawing API)
task.spawn(function()
    local drawings = {}
    while true do
        pcall(function()
            -- Cleanup old
            for _, d in pairs(drawings) do pcall(function() d:Remove() end) end
            drawings = {}

            if CFG.FishESP then
                local cam = workspace.CurrentCamera
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") == nil and v.Name:find("Fish") then
                        local pos = v:GetPivot().Position
                        local sp, onScreen = cam:WorldToViewportPoint(pos)
                        if onScreen then
                            local txt = Drawing.new("Text")
                            txt.Text = v.Name
                            txt.Position = Vector2.new(sp.X, sp.Y)
                            txt.Color = Color3.fromRGB(0,200,130)
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
        task.wait(1)
    end
end)

-- Player ESP (Drawing API)
task.spawn(function()
    local drawings = {}
    while true do
        pcall(function()
            for _, d in pairs(drawings) do pcall(function() d:Remove() end) end
            drawings = {}

            if CFG.PlayerESP then
                local cam = workspace.CurrentCamera
                local myPos = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character.HumanoidRootPart.Position
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local pos = p.Character.HumanoidRootPart.Position
                        local sp, onScreen = cam:WorldToViewportPoint(pos)
                        if onScreen then
                            local dist = myPos and math.floor((myPos - pos).Magnitude) or 0
                            local txt = Drawing.new("Text")
                            txt.Text = p.Name .. " [" .. dist .. "m]"
                            txt.Position = Vector2.new(sp.X, sp.Y - 20)
                            txt.Color = Color3.fromRGB(255,255,255)
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

-- ====================================================================
print("[Moron Fish It] v9.0 Loaded - GasUp ID")
print("[Moron Fish It] Events: " .. evStat)
