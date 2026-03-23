--[[
    MORON FISH IT v5.1 - Full Stealth Edition
    Drawing API UI | Lightweight Bypass | No Freeze
    Floating toggle button | No Key | No HWID
    by GasUp ID
]]

-- =============================================
-- SERVICES
-- =============================================
local cloneref = cloneref or function(x) return x end
local Players = cloneref(game:GetService("Players"))
local UIS = cloneref(game:GetService("UserInputService"))
local RS = cloneref(game:GetService("RunService"))
local WS = cloneref(game:GetService("Workspace"))
local Lighting = cloneref(game:GetService("Lighting"))
local TS = cloneref(game:GetService("TweenService"))
local LP = Players.LocalPlayer

-- =============================================
-- ANTI-CHEAT BYPASS (lightweight, no freeze)
-- =============================================
-- Only hook __namecall (lightest, most effective)
-- No __index or __newindex hooks (cause freeze)
task.spawn(function()
    pcall(function()
        local mt = getrawmetatable(game)
        if not mt then return end
        local oldNc = mt.__namecall
        if setreadonly then setreadonly(mt, false) end
        if make_writeable then make_writeable(mt) end

        mt.__namecall = newcclosure(function(self, ...)
            local m = getnamecallmethod()
            if m == "Kick" or m == "kick" then
                return task.wait(9e9)
            end
            if m == "FireServer" or m == "InvokeServer" then
                local ok, n = pcall(function() return self.Name:lower() end)
                if ok and n then
                    local blocked = {detect=1,cheat=1,ban=1,anticheat=1,exploit=1,hack=1,flag=1,report=1,security=1,guard=1,monitor=1,watchdog=1,violation=1,suspicious=1,kick=1,punish=1,verify=1}
                    for w in pairs(blocked) do
                        if n:find(w) then return nil end
                    end
                end
            end
            return oldNc(self, ...)
        end)

        if setreadonly then setreadonly(mt, true) end
    end)
end)

-- Deferred GC scan (non-blocking, runs in background)
task.defer(function()
    pcall(function()
        if not getgc then return end
        for _, v in ipairs(getgc(true)) do
            if type(v) == "table" then
                pcall(function()
                    for k, val in pairs(v) do
                        local ok2, kl = pcall(function() return tostring(k):lower() end)
                        if ok2 and kl and (kl:find("anticheat") or kl:find("detection")) then
                            if type(val) == "function" then v[k] = function() end end
                        end
                    end
                end)
            end
        end
    end)
end)

-- =============================================
-- CONFIG
-- =============================================
local C = {
    AutoFish = false, FishMode = "Normal", AutoCatch = false,
    FishDelay = 0.8, CatchDelay = 0.2,
    AutoSell = false, SellInterval = 60, ProtectFav = true,
    AutoFavorite = false, MinRarity = "Legendary",
    WalkSpeed = 16, JumpPower = 50,
    InfiniteJump = false, Fly = false, Noclip = false, AntiDrown = false,
    AntiAFK = true, GPUSaver = false, FPSBoost = false,
    FishESP = false, PlayerESP = false,
}

-- =============================================
-- UTILITIES
-- =============================================
local function rD(b) return b * (0.85 + math.random() * 0.3) end

local function clickButton(btn)
    if not btn then return end
    pcall(function()
        for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
            pcall(function() conn:Fire() end)
        end
    end)
end

local function findGameButton(parent, textMatch)
    if not parent then return nil end
    local result = nil
    pcall(function()
        for _, v in ipairs(parent:GetDescendants()) do
            if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible then
                local ok, txt = pcall(function() return v.Text:lower() end)
                if ok and txt and (txt:find(textMatch:lower()) or v.Name:lower():find(textMatch:lower())) then
                    result = v
                    return
                end
            end
        end
    end)
    return result
end

local function getPlayerGui() return LP and LP:FindFirstChild("PlayerGui") end

local function safeTeleport(targetCFrame)
    pcall(function()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local dist = (hrp.Position - targetCFrame.Position).Magnitude
        local dur = math.clamp(dist / 150, 0.5, 4)
        local tw = TS:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        tw:Play()
    end)
end

-- =============================================
-- COLORS
-- =============================================
local Col = {
    BG = Color3.fromRGB(18, 18, 22), Side = Color3.fromRGB(14, 14, 18),
    Head = Color3.fromRGB(22, 22, 28), Acc = Color3.fromRGB(0, 200, 130),
    Txt = Color3.fromRGB(220, 220, 225), Dim = Color3.fromRGB(110, 110, 125),
    TOn = Color3.fromRGB(0, 200, 130), TOff = Color3.fromRGB(55, 55, 65),
    SBg = Color3.fromRGB(40, 40, 50), SFl = Color3.fromRGB(0, 200, 130),
    Btn = Color3.fromRGB(32, 32, 42), Div = Color3.fromRGB(32, 32, 38),
    TAct = Color3.fromRGB(26, 26, 33),
}

-- =============================================
-- DRAWING UI
-- =============================================
local UI = {}
local UIVisible = true
local CurrentTab = 1
local IsDragging = false
local DragOff = Vector2.new(0, 0)
local WPos = Vector2.new(80, 60)
local WW, WH = 460, 340
local SW = 115
local HH = 32
local Tabs = {"Fishing", "Selling", "Teleport", "Movement", "Utility", "Visuals", "Settings"}
local ClickZones = {}
local SliderZones = {}
local ActiveSlider = nil

local FloatBtn = {}

local function D(key, cls, props)
    local obj = Drawing.new(cls)
    for k, v in pairs(props or {}) do obj[k] = v end
    UI[key] = obj
    return obj
end

local function setAllVis(vis)
    for _, obj in pairs(UI) do pcall(function() obj.Visible = vis end) end
end

local function buildFloatBtn()
    FloatBtn.bg = Drawing.new("Square")
    FloatBtn.bg.Size = Vector2.new(36, 36)
    FloatBtn.bg.Color = Col.BG
    FloatBtn.bg.Filled = true
    FloatBtn.bg.Visible = false
    FloatBtn.bg.Transparency = 1
    FloatBtn.border = Drawing.new("Square")
    FloatBtn.border.Size = Vector2.new(36, 36)
    FloatBtn.border.Color = Col.Acc
    FloatBtn.border.Filled = false
    FloatBtn.border.Thickness = 1
    FloatBtn.border.Visible = false
    FloatBtn.border.Transparency = 0.5
    FloatBtn.txt = Drawing.new("Text")
    FloatBtn.txt.Text = "M"
    FloatBtn.txt.Size = 18
    FloatBtn.txt.Color = Col.Acc
    FloatBtn.txt.Font = 2
    FloatBtn.txt.Visible = false
    FloatBtn.txt.Outline = true
    FloatBtn.txt.OutlineColor = Color3.fromRGB(0, 0, 0)
end

local function updateFloatBtn()
    local fx, fy = WPos.X, WPos.Y
    FloatBtn.bg.Position = Vector2.new(fx, fy)
    FloatBtn.border.Position = Vector2.new(fx, fy)
    FloatBtn.txt.Position = Vector2.new(fx + 10, fy + 7)
    local vis = not UIVisible
    FloatBtn.bg.Visible = vis
    FloatBtn.border.Visible = vis
    FloatBtn.txt.Visible = vis
end

local function buildUI()
    local x, y = WPos.X, WPos.Y
    D("bg", "Square", {Position=Vector2.new(x,y), Size=Vector2.new(WW,WH), Color=Col.BG, Filled=true, Visible=true, Transparency=1})
    D("border", "Square", {Position=Vector2.new(x,y), Size=Vector2.new(WW,WH), Color=Col.Acc, Filled=false, Thickness=1, Visible=true, Transparency=0.3})
    D("side", "Square", {Position=Vector2.new(x,y), Size=Vector2.new(SW,WH), Color=Col.Side, Filled=true, Visible=true, Transparency=1})
    D("logoM", "Text", {Position=Vector2.new(x+10,y+7), Text="M", Size=18, Color=Col.Acc, Font=2, Visible=true, Outline=true, OutlineColor=Color3.fromRGB(0,0,0)})
    D("logoT", "Text", {Position=Vector2.new(x+28,y+7), Text="MORON", Size=13, Color=Col.Txt, Font=2, Visible=true})
    D("logoS", "Text", {Position=Vector2.new(x+28,y+20), Text="Fish It v5.1", Size=9, Color=Col.Dim, Font=2, Visible=true})
    D("sline", "Line", {From=Vector2.new(x,y+38), To=Vector2.new(x+SW,y+38), Color=Col.Div, Thickness=1, Visible=true})
    for i = 1, #Tabs do
        local ty = y + 40 + (i-1)*38
        D("tab_bg_"..i, "Square", {Position=Vector2.new(x,ty), Size=Vector2.new(SW,36), Color=Col.Side, Filled=true, Visible=true, Transparency=1})
        D("tab_ind_"..i, "Square", {Position=Vector2.new(x,ty), Size=Vector2.new(3,36), Color=Col.Acc, Filled=true, Visible=false, Transparency=1})
        D("tab_txt_"..i, "Text", {Position=Vector2.new(x+14,ty+10), Text=Tabs[i], Size=11, Color=Col.Dim, Font=2, Visible=true})
    end
    D("head", "Square", {Position=Vector2.new(x+SW,y), Size=Vector2.new(WW-SW,HH), Color=Col.Head, Filled=true, Visible=true, Transparency=1})
    D("htitle", "Text", {Position=Vector2.new(x+SW+12,y+6), Text=Tabs[1], Size=14, Color=Col.Txt, Font=2, Visible=true})
    D("hdesc", "Text", {Position=Vector2.new(x+SW+12,y+20), Text="", Size=8, Color=Col.Dim, Font=2, Visible=true})
    D("hclose", "Text", {Position=Vector2.new(x+WW-20,y+8), Text="x", Size=13, Color=Col.Dim, Font=2, Visible=true})
    D("content_bg", "Square", {Position=Vector2.new(x+SW,y+HH), Size=Vector2.new(WW-SW,WH-HH), Color=Col.BG, Filled=true, Visible=true, Transparency=1})
    for i = 1, 20 do
        local p = "i"..i.."_"
        D(p.."lb", "Text", {Position=Vector2.new(0,0), Text="", Size=12, Color=Col.Txt, Font=2, Visible=false})
        D(p.."ds", "Text", {Position=Vector2.new(0,0), Text="", Size=9, Color=Col.Dim, Font=2, Visible=false})
        D(p.."tb", "Square", {Position=Vector2.new(0,0), Size=Vector2.new(32,14), Color=Col.TOff, Filled=true, Visible=false, Transparency=1})
        D(p.."tk", "Circle", {Position=Vector2.new(0,0), Radius=5, Color=Color3.fromRGB(255,255,255), Filled=true, Visible=false, Transparency=1})
        D(p.."dv", "Line", {From=Vector2.new(0,0), To=Vector2.new(0,0), Color=Col.Div, Thickness=1, Visible=false, Transparency=0.4})
        D(p.."sb", "Square", {Position=Vector2.new(0,0), Size=Vector2.new(0,4), Color=Col.SBg, Filled=true, Visible=false, Transparency=1})
        D(p.."sf", "Square", {Position=Vector2.new(0,0), Size=Vector2.new(0,4), Color=Col.SFl, Filled=true, Visible=false, Transparency=1})
        D(p.."sv", "Text", {Position=Vector2.new(0,0), Text="", Size=10, Color=Col.Acc, Font=2, Visible=false})
        D(p.."bb", "Square", {Position=Vector2.new(0,0), Size=Vector2.new(0,26), Color=Col.Btn, Filled=true, Visible=false, Transparency=1})
        D(p.."bt", "Text", {Position=Vector2.new(0,0), Text="", Size=11, Color=Col.Txt, Font=2, Visible=false})
        D(p.."sc", "Text", {Position=Vector2.new(0,0), Text="", Size=10, Color=Col.Acc, Font=2, Visible=false})
        D(p.."xb", "Square", {Position=Vector2.new(0,0), Size=Vector2.new(84,22), Color=Col.Btn, Filled=true, Visible=false, Transparency=1})
        D(p.."xt", "Text", {Position=Vector2.new(0,0), Text="", Size=10, Color=Col.Acc, Font=2, Visible=false})
    end
end

-- =============================================
-- UPDATE UI
-- =============================================
local function updateUI()
    ClickZones = {}
    SliderZones = {}
    updateFloatBtn()
    if not UIVisible then setAllVis(false) return end

    local x, y = WPos.X, WPos.Y
    UI["bg"].Position = Vector2.new(x,y); UI["bg"].Visible = true
    UI["border"].Position = Vector2.new(x,y); UI["border"].Visible = true
    UI["side"].Position = Vector2.new(x,y); UI["side"].Visible = true
    UI["logoM"].Position = Vector2.new(x+10,y+7); UI["logoM"].Visible = true
    UI["logoT"].Position = Vector2.new(x+28,y+7); UI["logoT"].Visible = true
    UI["logoS"].Position = Vector2.new(x+28,y+20); UI["logoS"].Visible = true
    UI["sline"].From = Vector2.new(x,y+38); UI["sline"].To = Vector2.new(x+SW,y+38); UI["sline"].Visible = true

    for i = 1, #Tabs do
        local ty = y + 40 + (i-1)*38
        local act = (i == CurrentTab)
        UI["tab_bg_"..i].Position = Vector2.new(x,ty); UI["tab_bg_"..i].Color = act and Col.TAct or Col.Side; UI["tab_bg_"..i].Visible = true
        UI["tab_ind_"..i].Position = Vector2.new(x,ty); UI["tab_ind_"..i].Visible = act
        UI["tab_txt_"..i].Position = Vector2.new(x+14,ty+10); UI["tab_txt_"..i].Color = act and Col.Txt or Col.Dim; UI["tab_txt_"..i].Visible = true
        table.insert(ClickZones, {x=x, y=ty, w=SW, h=36, cb=function() CurrentTab=i; updateUI() end})
    end

    local descs = {"Auto fishing controls","Sell & favorites","Travel to locations","Speed & fly","Anti-AFK & boost","ESP overlays","Info & reset"}
    UI["head"].Position = Vector2.new(x+SW,y); UI["head"].Visible = true
    UI["htitle"].Position = Vector2.new(x+SW+12,y+6); UI["htitle"].Text = Tabs[CurrentTab]; UI["htitle"].Visible = true
    UI["hdesc"].Position = Vector2.new(x+SW+12,y+20); UI["hdesc"].Text = descs[CurrentTab] or ""; UI["hdesc"].Visible = true
    UI["hclose"].Position = Vector2.new(x+WW-20,y+8); UI["hclose"].Visible = true
    table.insert(ClickZones, {x=x+WW-28, y=y, w=28, h=HH, cb=function() UIVisible=false; updateUI() end})
    UI["content_bg"].Position = Vector2.new(x+SW,y+HH); UI["content_bg"].Visible = true

    for i = 1, 20 do
        local p = "i"..i.."_"
        for _, s in ipairs({"lb","ds","tb","tk","dv","sb","sf","sv","bb","bt","sc","xb","xt"}) do
            UI[p..s].Visible = false
        end
    end

    local cx = x + SW + 12
    local cw = WW - SW - 24
    local iy = y + HH + 8
    local slot = 0
    local bot = y + WH

    local function ns()
        slot = slot + 1
        if slot > 20 then return nil end
        return "i"..slot.."_"
    end

    local function sec(title)
        local p = ns(); if not p then return end
        if iy < bot then
            UI[p.."sc"].Position = Vector2.new(cx,iy+2); UI[p.."sc"].Text = title:upper(); UI[p.."sc"].Visible = true
        end
        iy = iy + 20
    end

    local function tog(label, desc, val, key)
        local p = ns(); if not p then return end
        if iy + 34 < bot then
            UI[p.."lb"].Position = Vector2.new(cx,iy+1); UI[p.."lb"].Text = label; UI[p.."lb"].Visible = true
            if desc ~= "" then UI[p.."ds"].Position = Vector2.new(cx,iy+16); UI[p.."ds"].Text = desc; UI[p.."ds"].Visible = true end
            local tx = cx + cw - 36
            UI[p.."tb"].Position = Vector2.new(tx,iy+2); UI[p.."tb"].Color = val and Col.TOn or Col.TOff; UI[p.."tb"].Visible = true
            UI[p.."tk"].Position = Vector2.new(val and (tx+25) or (tx+7), iy+9); UI[p.."tk"].Visible = true
            UI[p.."dv"].From = Vector2.new(cx,iy+32); UI[p.."dv"].To = Vector2.new(cx+cw,iy+32); UI[p.."dv"].Visible = true
            table.insert(ClickZones, {x=tx-10, y=iy-2, w=50, h=22, cb=function() C[key] = not C[key]; updateUI() end})
        end
        iy = iy + 38
    end

    local function sld(label, val, mn, mx, unit, key)
        local p = ns(); if not p then return end
        if iy + 34 < bot then
            UI[p.."lb"].Position = Vector2.new(cx,iy+1); UI[p.."lb"].Text = label; UI[p.."lb"].Visible = true
            UI[p.."sv"].Position = Vector2.new(cx+cw-40,iy+1); UI[p.."sv"].Text = string.format("%.1f%s",val,unit or ""); UI[p.."sv"].Visible = true
            local sy2 = iy + 18
            UI[p.."sb"].Position = Vector2.new(cx,sy2); UI[p.."sb"].Size = Vector2.new(cw,4); UI[p.."sb"].Visible = true
            local pct = math.clamp((val-mn)/(mx-mn),0,1)
            UI[p.."sf"].Position = Vector2.new(cx,sy2); UI[p.."sf"].Size = Vector2.new(cw*pct,4); UI[p.."sf"].Visible = true
            UI[p.."dv"].From = Vector2.new(cx,iy+30); UI[p.."dv"].To = Vector2.new(cx+cw,iy+30); UI[p.."dv"].Visible = true
            table.insert(SliderZones, {x=cx, y=sy2-6, w=cw, h=16, mn=mn, mx=mx, key=key, cb=function(nv) C[key]=math.floor(nv*10)/10; updateUI() end})
        end
        iy = iy + 38
    end

    local function btn(label, callback)
        local p = ns(); if not p then return end
        if iy + 28 < bot then
            UI[p.."bb"].Position = Vector2.new(cx,iy); UI[p.."bb"].Size = Vector2.new(cw,26); UI[p.."bb"].Visible = true
            UI[p.."bt"].Position = Vector2.new(cx+cw/2-#label*3, iy+6); UI[p.."bt"].Text = label; UI[p.."bt"].Visible = true
            table.insert(ClickZones, {x=cx, y=iy, w=cw, h=26, cb=callback})
        end
        iy = iy + 32
    end

    local function sel(label, opts, val, key)
        local p = ns(); if not p then return end
        if iy + 26 < bot then
            UI[p.."lb"].Position = Vector2.new(cx,iy+4); UI[p.."lb"].Text = label; UI[p.."lb"].Visible = true
            local bx = cx + cw - 88
            UI[p.."xb"].Position = Vector2.new(bx,iy); UI[p.."xb"].Visible = true
            UI[p.."xt"].Position = Vector2.new(bx+8,iy+5); UI[p.."xt"].Text = tostring(val); UI[p.."xt"].Visible = true
            UI[p.."dv"].From = Vector2.new(cx,iy+26); UI[p.."dv"].To = Vector2.new(cx+cw,iy+26); UI[p.."dv"].Visible = true
            table.insert(ClickZones, {x=bx, y=iy, w=88, h=22, cb=function()
                local idx = 1
                for i2, o in ipairs(opts) do if o == C[key] then idx = i2; break end end
                idx = idx % #opts + 1; C[key] = opts[idx]; updateUI()
            end})
        end
        iy = iy + 32
    end

    local function info(text, color)
        local p = ns(); if not p then return end
        if iy + 16 < bot then
            UI[p.."lb"].Position = Vector2.new(cx,iy); UI[p.."lb"].Text = text; UI[p.."lb"].Color = color or Col.Dim; UI[p.."lb"].Visible = true
        end
        iy = iy + 18
    end

    -- PAGE CONTENT
    if CurrentTab == 1 then
        sec("Automation")
        tog("Auto Fish", "Simulate casting via game UI", C.AutoFish, "AutoFish")
        sel("Mode", {"Normal","Blatant","Instant"}, C.FishMode, "FishMode")
        tog("Auto Catch", "Fast reel via game signals", C.AutoCatch, "AutoCatch")
        sec("Timing")
        sld("Fish Delay", C.FishDelay, 0.1, 5.0, "s", "FishDelay")
        sld("Catch Delay", C.CatchDelay, 0.1, 3.0, "s", "CatchDelay")
    elseif CurrentTab == 2 then
        sec("Auto Sell")
        tog("Auto Sell", "Sell via game sell button", C.AutoSell, "AutoSell")
        tog("Protect Favorites", "Skip favorited fish", C.ProtectFav, "ProtectFav")
        sld("Sell Timer", C.SellInterval, 10, 300, "s", "SellInterval")
        btn("Sell All Now", function()
            pcall(function()
                local b = findGameButton(getPlayerGui(), "sell") or findGameButton(getPlayerGui(), "jual")
                if b then clickButton(b) end
            end)
        end)
        sec("Favorites")
        tog("Auto Favorite", "Fav rare fish auto", C.AutoFavorite, "AutoFavorite")
        sel("Min Rarity", {"Legendary","Mythic","Secret"}, C.MinRarity, "MinRarity")
    elseif CurrentTab == 3 then
        sec("Islands")
        local islands = {
            {"Spawn Island", CFrame.new(0,15,0)},
            {"Coral Reefs", CFrame.new(500,15,200)},
            {"Kohana", CFrame.new(-300,15,400)},
            {"Crater Island", CFrame.new(800,15,-100)},
            {"Lost Isle", CFrame.new(-600,15,-300)},
            {"Mount Hallow", CFrame.new(200,80,-500)},
            {"Ancient Jungle", CFrame.new(-400,15,600)},
        }
        for _, isl in ipairs(islands) do
            btn(isl[1], function() safeTeleport(isl[2]) end)
        end
    elseif CurrentTab == 4 then
        sec("Speed")
        sld("Walk Speed", C.WalkSpeed, 16, 200, "", "WalkSpeed")
        sld("Jump Power", C.JumpPower, 50, 300, "", "JumpPower")
        sec("Abilities")
        tog("Infinite Jump", "Jump in mid-air", C.InfiniteJump, "InfiniteJump")
        tog("Fly", "WASD + Space/Shift", C.Fly, "Fly")
        tog("Noclip", "Walk through walls", C.Noclip, "Noclip")
        tog("Anti-Drown", "Smooth resurface", C.AntiDrown, "AntiDrown")
    elseif CurrentTab == 5 then
        sec("Protection")
        tog("Anti-AFK", "Prevent idle kick", C.AntiAFK, "AntiAFK")
        sec("Performance")
        tog("GPU Saver", "Reduce visual quality", C.GPUSaver, "GPUSaver")
        tog("FPS Boost", "Remove particles/effects", C.FPSBoost, "FPSBoost")
        sec("Server")
        btn("Server Hop", function()
            pcall(function()
                local Http = cloneref(game:GetService("HttpService"))
                local TPS = cloneref(game:GetService("TeleportService"))
                local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
                local svs = Http:JSONDecode(game:HttpGet(url))
                for _, sv in ipairs(svs.data or {}) do
                    if sv.playing < sv.maxPlayers and sv.id ~= game.JobId then
                        TPS:TeleportToPlaceInstance(game.PlaceId, sv.id); break
                    end
                end
            end)
        end)
        btn("Rejoin Server", function()
            pcall(function() cloneref(game:GetService("TeleportService")):TeleportToPlaceInstance(game.PlaceId, game.JobId) end)
        end)
    elseif CurrentTab == 6 then
        sec("ESP (Drawing API)")
        tog("Fish ESP", "Show fish locations", C.FishESP, "FishESP")
        tog("Player ESP", "Show other players", C.PlayerESP, "PlayerESP")
    elseif CurrentTab == 7 then
        sec("Info")
        info("Player: "..tostring(LP.DisplayName), Col.Txt)
        info("UI: Drawing API (Undetectable)", Col.Acc)
        info("Bypass: Namecall Hook + GC Scan", Col.Acc)
        info("Brand: GasUp ID", Col.Txt)
        info("Version: 5.1 Full Stealth", Col.Dim)
        sec("Actions")
        btn("Reset All Settings", function()
            C.AutoFish=false; C.FishMode="Normal"; C.AutoCatch=false
            C.FishDelay=0.8; C.CatchDelay=0.2; C.AutoSell=false; C.SellInterval=60
            C.AutoFavorite=false; C.ProtectFav=true; C.WalkSpeed=16; C.JumpPower=50
            C.InfiniteJump=false; C.Fly=false; C.Noclip=false; C.AntiAFK=true
            C.AntiDrown=false; C.GPUSaver=false; C.FPSBoost=false
            C.FishESP=false; C.PlayerESP=false; updateUI()
        end)
    end
end

-- =============================================
-- INPUT
-- =============================================
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local pos = UIS:GetMouseLocation()
        if not UIVisible then
            local fx, fy = WPos.X, WPos.Y
            if pos.X >= fx and pos.X <= fx+36 and pos.Y >= fy and pos.Y <= fy+36 then
                UIVisible = true; updateUI(); return
            end
            return
        end
        if pos.X >= WPos.X+SW and pos.X <= WPos.X+WW-28 and pos.Y >= WPos.Y and pos.Y <= WPos.Y+HH then
            IsDragging = true; DragOff = Vector2.new(pos.X-WPos.X, pos.Y-WPos.Y); return
        end
        for _, z in ipairs(ClickZones) do
            if pos.X >= z.x and pos.X <= z.x+z.w and pos.Y >= z.y and pos.Y <= z.y+z.h then
                pcall(z.cb); return
            end
        end
        for _, z in ipairs(SliderZones) do
            if pos.X >= z.x and pos.X <= z.x+z.w and pos.Y >= z.y and pos.Y <= z.y+z.h then
                ActiveSlider = z
                local pct = math.clamp((pos.X-z.x)/z.w, 0, 1)
                pcall(function() z.cb(z.mn + pct*(z.mx-z.mn)) end); return
            end
        end
    end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.RightShift then
        UIVisible = not UIVisible; updateUI()
    end
end)

UIS.InputChanged:Connect(function(input)
    if IsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local pos = UIS:GetMouseLocation()
        WPos = Vector2.new(pos.X-DragOff.X, pos.Y-DragOff.Y); updateUI()
    end
    if ActiveSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local pos = UIS:GetMouseLocation()
        local z = ActiveSlider
        local pct = math.clamp((pos.X-z.x)/z.w, 0, 1)
        pcall(function() z.cb(z.mn + pct*(z.mx-z.mn)) end)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsDragging = false; ActiveSlider = nil
    end
end)

-- =============================================
-- FEATURE LOOPS (all in task.spawn, non-blocking)
-- =============================================
task.spawn(function()
    while task.wait(rD(C.FishDelay)) do
        if C.AutoFish then
            pcall(function()
                local b = findGameButton(getPlayerGui(), "cast") or findGameButton(getPlayerGui(), "lempar") or findGameButton(getPlayerGui(), "fish")
                if b then clickButton(b) end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(rD(C.CatchDelay)) do
        if C.AutoCatch then
            pcall(function()
                local b = findGameButton(getPlayerGui(), "reel") or findGameButton(getPlayerGui(), "tarik") or findGameButton(getPlayerGui(), "catch")
                if b then clickButton(b) end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(rD(C.SellInterval)) do
        if C.AutoSell then
            pcall(function()
                local b = findGameButton(getPlayerGui(), "sell") or findGameButton(getPlayerGui(), "jual")
                if b then clickButton(b) end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = C.WalkSpeed
                hum.JumpPower = C.JumpPower
            end
        end)
    end
end)

UIS.JumpRequest:Connect(function()
    if C.InfiniteJump then
        pcall(function()
            LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end)

local flyBV = nil
task.spawn(function()
    while task.wait(1/30) do
        if C.Fly then
            pcall(function()
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if not flyBV or flyBV.Parent ~= hrp then
                        flyBV = Instance.new("BodyVelocity")
                        flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
                        flyBV.Velocity = Vector3.new(0,0,0)
                        flyBV.Parent = hrp
                    end
                    local cam = WS.CurrentCamera
                    local dir = Vector3.new(0,0,0)
                    if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
                    flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * 80 or Vector3.new(0,0,0)
                end
            end)
        else
            if flyBV then pcall(function() flyBV:Destroy() end); flyBV = nil end
        end
    end
end)

task.spawn(function()
    while task.wait(1/15) do
        if C.Noclip then
            pcall(function()
                for _, p in ipairs(LP.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if C.AntiDrown then
            pcall(function()
                local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Position.Y < -5 then
                    TS:Create(hrp, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {CFrame = CFrame.new(hrp.Position.X, 10, hrp.Position.Z)}):Play()
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(60) do
        if C.AntiAFK then
            pcall(function()
                local VU = cloneref(game:GetService("VirtualUser"))
                VU:CaptureController()
                VU:ClickButton2(Vector2.new())
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if C.GPUSaver then
            pcall(function()
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 1e6
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                for _, v in ipairs(Lighting:GetDescendants()) do
                    if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") then v.Enabled = false end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(10) do
        if C.FPSBoost then
            pcall(function()
                for _, v in ipairs(WS:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then v.Enabled = false end
                end
            end)
        end
    end
end)

local espObj = {}
task.spawn(function()
    while task.wait(0.5) do
        for _, o in ipairs(espObj) do pcall(function() o:Remove() end) end
        espObj = {}
        if C.FishESP then
            pcall(function()
                local cam = WS.CurrentCamera
                for _, v in ipairs(WS:GetDescendants()) do
                    if v:IsA("Model") and (v.Name:lower():find("fish") or v.Name:lower():find("ikan")) then
                        local prim = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart
                        if prim then
                            local sp, on = cam:WorldToViewportPoint(prim.Position)
                            if on and sp.Z < 500 then
                                local d = Drawing.new("Circle"); d.Position=Vector2.new(sp.X,sp.Y); d.Radius=4; d.Color=Col.Acc; d.Filled=true; d.Visible=true
                                local t = Drawing.new("Text"); t.Position=Vector2.new(sp.X+8,sp.Y-6); t.Text=v.Name.." ["..math.floor(sp.Z).."m]"; t.Size=10; t.Color=Col.Acc; t.Font=2; t.Visible=true
                                table.insert(espObj, d); table.insert(espObj, t)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

local pEsp = {}
task.spawn(function()
    while task.wait(0.5) do
        for _, o in ipairs(pEsp) do pcall(function() o:Remove() end) end
        pEsp = {}
        if C.PlayerESP then
            pcall(function()
                local cam = WS.CurrentCamera
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local sp, on = cam:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                        if on then
                            local t = Drawing.new("Text"); t.Position=Vector2.new(sp.X,sp.Y-20); t.Text=plr.DisplayName.." ["..math.floor(sp.Z).."m]"; t.Size=11; t.Color=Color3.fromRGB(255,255,255); t.Font=2; t.Visible=true; t.Outline=true; t.OutlineColor=Color3.fromRGB(0,0,0)
                            table.insert(pEsp, t)
                        end
                    end
                end
            end)
        end
    end
end)

-- =============================================
-- SPLASH SCREEN (small, non-blocking)
-- =============================================
local function showSplash()
    local vp = WS.CurrentCamera.ViewportSize
    local sw2, sh = 200, 60
    local sx, sy = (vp.X-sw2)/2, (vp.Y-sh)/2

    local sBg = Drawing.new("Square"); sBg.Position=Vector2.new(sx,sy); sBg.Size=Vector2.new(sw2,sh); sBg.Color=Color3.fromRGB(12,12,16); sBg.Filled=true; sBg.Visible=true; sBg.Transparency=1
    local sBd = Drawing.new("Square"); sBd.Position=Vector2.new(sx,sy); sBd.Size=Vector2.new(sw2,sh); sBd.Color=Col.Acc; sBd.Filled=false; sBd.Thickness=1; sBd.Visible=true; sBd.Transparency=0.4
    local sT = Drawing.new("Text"); sT.Position=Vector2.new(sx+sw2/2-30,sy+8); sT.Text="GasUp ID"; sT.Size=18; sT.Color=Col.Acc; sT.Font=2; sT.Visible=true; sT.Outline=true; sT.OutlineColor=Color3.fromRGB(0,0,0)
    local sS = Drawing.new("Text"); sS.Position=Vector2.new(sx+sw2/2-42,sy+28); sS.Text="Moron Fish It v5.1"; sS.Size=11; sS.Color=Col.Dim; sS.Font=2; sS.Visible=true
    local sB = Drawing.new("Square"); sB.Position=Vector2.new(sx+20,sy+46); sB.Size=Vector2.new(0,3); sB.Color=Col.Acc; sB.Filled=true; sB.Visible=true; sB.Transparency=1

    local barW = sw2 - 40
    for i = 1, 20 do sB.Size = Vector2.new(barW*(i/20), 3); task.wait(0.05) end
    task.wait(0.3)
    sBg:Remove(); sBd:Remove(); sT:Remove(); sS:Remove(); sB:Remove()
end

-- =============================================
-- INIT
-- =============================================
showSplash()
buildFloatBtn()
buildUI()
updateUI()

LP.CharacterRemoving:Connect(function()
    if flyBV then pcall(function() flyBV:Destroy() end); flyBV = nil end
end)
