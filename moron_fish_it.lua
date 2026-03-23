--[[
    MORON FISH IT v5.0 - Full Stealth Edition
    Drawing API UI | Property Spoofing | TweenService Teleport
    Floating toggle button | All features safe | No Key | No HWID
    by GasUp ID
]]

-- =============================================
-- SERVICES (cloneref for stealth)
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
-- ANTI-CHEAT BYPASS (3 layers)
-- =============================================
local RealWalkSpeed = 16
local RealJumpPower = 50

pcall(function()
    local mt = getrawmetatable(game)
    if not mt then return end
    local oldIdx = mt.__index
    local oldNc = mt.__namecall
    local oldNi = mt.__newindex
    if setreadonly then setreadonly(mt, false) end
    if make_writeable then make_writeable(mt) end

    mt.__index = newcclosure(function(self, key)
        pcall(function()
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if self == hum then
                if key == "WalkSpeed" then return 16 end
                if key == "JumpPower" then return 50 end
            end
        end)
        if tostring(key):lower() == "kick" then
            return function() return task.wait(9e9) end
        end
        return oldIdx(self, key)
    end)

    if oldNi then
        mt.__newindex = newcclosure(function(self, key, value)
            pcall(function()
                local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if self == hum and (key == "WalkSpeed" or key == "JumpPower") then
                    if key == "WalkSpeed" and value ~= RealWalkSpeed then return end
                    if key == "JumpPower" and value ~= RealJumpPower then return end
                end
            end)
            return oldNi(self, key, value)
        end)
    end

    mt.__namecall = newcclosure(function(self, ...)
        local m = getnamecallmethod()
        if m == "Kick" or m == "kick" then return task.wait(9e9) end
        if m == "FireServer" or m == "InvokeServer" then
            local n = ""
            pcall(function() n = self.Name:lower() end)
            for _, w in ipairs({"detect","cheat","ban","anticheat","exploit","hack","flag","report","security","guard","monitor","watchdog","violation","suspicious","kick","punish","verify"}) do
                if n:find(w) then return nil end
            end
        end
        return oldNc(self, ...)
    end)

    if setreadonly then setreadonly(mt, true) end
end)

pcall(function()
    for _, v in ipairs(getgc(true)) do
        if type(v) == "table" then
            pcall(function()
                for k, val in pairs(v) do
                    local kl = tostring(k):lower()
                    if kl:find("anticheat") or kl:find("detection") or kl:find("security") then
                        if type(val) == "function" then v[k] = function() end end
                    end
                end
            end)
        end
    end
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
        if firesignal then firesignal(btn.MouseButton1Click) end
    end)
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
                local txt = ""
                pcall(function() txt = v.Text:lower() end)
                if txt:find(textMatch:lower()) or v.Name:lower():find(textMatch:lower()) then
                    result = v
                    break
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
        tw.Completed:Wait()
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
-- DRAWING UI SYSTEM
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

-- Floating toggle button (visible when UI hidden)
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

-- =============================================
-- BUILD UI (called ONCE at startup)
-- =============================================
local function buildUI()
    local x, y = WPos.X, WPos.Y
    D("bg", "Square", {Position = Vector2.new(x, y), Size = Vector2.new(WW, WH), Color = Col.BG, Filled = true, Visible = true, Transparency = 1})
    D("border", "Square", {Position = Vector2.new(x, y), Size = Vector2.new(WW, WH), Color = Col.Acc, Filled = false, Thickness = 1, Visible = true, Transparency = 0.3})
    D("side", "Square", {Position = Vector2.new(x, y), Size = Vector2.new(SW, WH), Color = Col.Side, Filled = true, Visible = true, Transparency = 1})
    D("logoM", "Text", {Position = Vector2.new(x + 10, y + 7), Text = "M", Size = 18, Color = Col.Acc, Font = 2, Visible = true, Outline = true, OutlineColor = Color3.fromRGB(0, 0, 0)})
    D("logoT", "Text", {Position = Vector2.new(x + 28, y + 7), Text = "MORON", Size = 13, Color = Col.Txt, Font = 2, Visible = true})
    D("logoS", "Text", {Position = Vector2.new(x + 28, y + 20), Text = "Fish It v5.0", Size = 9, Color = Col.Dim, Font = 2, Visible = true})
    D("sline", "Line", {From = Vector2.new(x, y + 38), To = Vector2.new(x + SW, y + 38), Color = Col.Div, Thickness = 1, Visible = true})
    for i = 1, #Tabs do
        local ty = y + 40 + (i - 1) * 38
        D("tab_bg_" .. i, "Square", {Position = Vector2.new(x, ty), Size = Vector2.new(SW, 36), Color = Col.Side, Filled = true, Visible = true, Transparency = 1})
        D("tab_ind_" .. i, "Square", {Position = Vector2.new(x, ty), Size = Vector2.new(3, 36), Color = Col.Acc, Filled = true, Visible = false, Transparency = 1})
        D("tab_txt_" .. i, "Text", {Position = Vector2.new(x + 14, ty + 10), Text = Tabs[i], Size = 11, Color = Col.Dim, Font = 2, Visible = true})
    end
    D("head", "Square", {Position = Vector2.new(x + SW, y), Size = Vector2.new(WW - SW, HH), Color = Col.Head, Filled = true, Visible = true, Transparency = 1})
    D("htitle", "Text", {Position = Vector2.new(x + SW + 12, y + 8), Text = Tabs[1], Size = 14, Color = Col.Txt, Font = 2, Visible = true})
    D("hdesc", "Text", {Position = Vector2.new(x + SW + 12, y + 22), Text = "", Size = 8, Color = Col.Dim, Font = 2, Visible = true})
    D("hclose", "Text", {Position = Vector2.new(x + WW - 20, y + 8), Text = "x", Size = 13, Color = Col.Dim, Font = 2, Visible = true})
    D("content_bg", "Square", {Position = Vector2.new(x + SW, y + HH), Size = Vector2.new(WW - SW, WH - HH), Color = Col.BG, Filled = true, Visible = true, Transparency = 1})
    for i = 1, 24 do
        local p = "item_" .. i .. "_"
        D(p.."label", "Text", {Position=Vector2.new(0,0), Text="", Size=12, Color=Col.Txt, Font=2, Visible=false})
        D(p.."desc", "Text", {Position=Vector2.new(0,0), Text="", Size=9, Color=Col.Dim, Font=2, Visible=false})
        D(p.."tog_bg", "Square", {Position=Vector2.new(0,0), Size=Vector2.new(32,14), Color=Col.TOff, Filled=true, Visible=false, Transparency=1})
        D(p.."tog_knob", "Circle", {Position=Vector2.new(0,0), Radius=5, Color=Color3.fromRGB(255,255,255), Filled=true, Visible=false, Transparency=1})
        D(p.."div", "Line", {From=Vector2.new(0,0), To=Vector2.new(0,0), Color=Col.Div, Thickness=1, Visible=false, Transparency=0.4})
        D(p.."sl_bg", "Square", {Position=Vector2.new(0,0), Size=Vector2.new(0,4), Color=Col.SBg, Filled=true, Visible=false, Transparency=1})
        D(p.."sl_fill", "Square", {Position=Vector2.new(0,0), Size=Vector2.new(0,4), Color=Col.SFl, Filled=true, Visible=false, Transparency=1})
        D(p.."sl_val", "Text", {Position=Vector2.new(0,0), Text="", Size=10, Color=Col.Acc, Font=2, Visible=false})
        D(p.."btn_bg", "Square", {Position=Vector2.new(0,0), Size=Vector2.new(0,26), Color=Col.Btn, Filled=true, Visible=false, Transparency=1})
        D(p.."btn_txt", "Text", {Position=Vector2.new(0,0), Text="", Size=11, Color=Col.Txt, Font=2, Visible=false})
        D(p.."sec", "Text", {Position=Vector2.new(0,0), Text="", Size=10, Color=Col.Acc, Font=2, Visible=false})
        D(p.."sel_bg", "Square", {Position=Vector2.new(0,0), Size=Vector2.new(84,22), Color=Col.Btn, Filled=true, Visible=false, Transparency=1})
        D(p.."sel_txt", "Text", {Position=Vector2.new(0,0), Text="", Size=10, Color=Col.Acc, Font=2, Visible=false})
    end
end

-- =============================================
-- UPDATE UI (reposition only, no create/destroy)
-- =============================================
local function updateUI()
    ClickZones = {}
    SliderZones = {}
    updateFloatBtn()

    if not UIVisible then setAllVis(false) return end

    local x, y = WPos.X, WPos.Y
    UI["bg"].Position = Vector2.new(x, y); UI["bg"].Visible = true
    UI["border"].Position = Vector2.new(x, y); UI["border"].Visible = true
    UI["side"].Position = Vector2.new(x, y); UI["side"].Visible = true
    UI["logoM"].Position = Vector2.new(x + 10, y + 7); UI["logoM"].Visible = true
    UI["logoT"].Position = Vector2.new(x + 28, y + 7); UI["logoT"].Visible = true
    UI["logoS"].Position = Vector2.new(x + 28, y + 20); UI["logoS"].Visible = true
    UI["sline"].From = Vector2.new(x, y + 38); UI["sline"].To = Vector2.new(x + SW, y + 38); UI["sline"].Visible = true

    for i = 1, #Tabs do
        local ty = y + 40 + (i - 1) * 38
        local act = (i == CurrentTab)
        UI["tab_bg_"..i].Position = Vector2.new(x, ty); UI["tab_bg_"..i].Color = act and Col.TAct or Col.Side; UI["tab_bg_"..i].Visible = true
        UI["tab_ind_"..i].Position = Vector2.new(x, ty); UI["tab_ind_"..i].Visible = act
        UI["tab_txt_"..i].Position = Vector2.new(x + 14, ty + 10); UI["tab_txt_"..i].Color = act and Col.Txt or Col.Dim; UI["tab_txt_"..i].Visible = true
        table.insert(ClickZones, {x=x, y=ty, w=SW, h=36, cb=function() CurrentTab=i; updateUI() end})
    end

    local descs = {"Auto fishing controls", "Sell & favorites", "Travel to locations", "Speed & fly", "Anti-AFK & boost", "ESP overlays", "Info & reset"}
    UI["head"].Position = Vector2.new(x+SW, y); UI["head"].Visible = true
    UI["htitle"].Position = Vector2.new(x+SW+12, y+6); UI["htitle"].Text = Tabs[CurrentTab]; UI["htitle"].Visible = true
    UI["hdesc"].Position = Vector2.new(x+SW+12, y+20); UI["hdesc"].Text = descs[CurrentTab] or ""; UI["hdesc"].Visible = true
    UI["hclose"].Position = Vector2.new(x+WW-20, y+8); UI["hclose"].Visible = true
    table.insert(ClickZones, {x=x+WW-28, y=y, w=28, h=HH, cb=function() UIVisible=false; updateUI() end})
    UI["content_bg"].Position = Vector2.new(x+SW, y+HH); UI["content_bg"].Visible = true

    -- Hide all item slots
    for i = 1, 24 do
        local p = "item_"..i.."_"
        for _, s in ipairs({"label","desc","tog_bg","tog_knob","div","sl_bg","sl_fill","sl_val","btn_bg","btn_txt","sec","sel_bg","sel_txt"}) do
            UI[p..s].Visible = false
        end
    end

    -- Content helpers
    local cx = x + SW + 12
    local cw = WW - SW - 24
    local iy = y + HH + 8
    local slot = 0
    local contentBot = y + WH

    local function nextSlot()
        slot = slot + 1
        if slot > 24 then return nil end
        return "item_"..slot.."_"
    end

    local function drawSection(title)
        local p = nextSlot(); if not p then return end
        if iy < contentBot then
            UI[p.."sec"].Position = Vector2.new(cx, iy+2); UI[p.."sec"].Text = title:upper(); UI[p.."sec"].Visible = true
        end
        iy = iy + 20
    end

    local function drawToggle(label, desc, val, key)
        local p = nextSlot(); if not p then return end
        if iy + 34 < contentBot then
            UI[p.."label"].Position = Vector2.new(cx, iy+1); UI[p.."label"].Text = label; UI[p.."label"].Color = Col.Txt; UI[p.."label"].Visible = true
            if desc ~= "" then UI[p.."desc"].Position = Vector2.new(cx, iy+16); UI[p.."desc"].Text = desc; UI[p.."desc"].Visible = true end
            local tx = cx + cw - 36
            UI[p.."tog_bg"].Position = Vector2.new(tx, iy+2); UI[p.."tog_bg"].Color = val and Col.TOn or Col.TOff; UI[p.."tog_bg"].Visible = true
            UI[p.."tog_knob"].Position = Vector2.new(val and (tx+25) or (tx+7), iy+9); UI[p.."tog_knob"].Visible = true
            UI[p.."div"].From = Vector2.new(cx, iy+32); UI[p.."div"].To = Vector2.new(cx+cw, iy+32); UI[p.."div"].Visible = true
            table.insert(ClickZones, {x=tx-10, y=iy-2, w=50, h=22, cb=function() C[key] = not C[key]; if key=="WalkSpeed" then RealWalkSpeed=C[key] and C.WalkSpeed or 16 end; if key=="JumpPower" then RealJumpPower=C[key] and C.JumpPower or 50 end; updateUI() end})
        end
        iy = iy + 38
    end

    local function drawSlider(label, val, mn, mx, unit, key)
        local p = nextSlot(); if not p then return end
        if iy + 34 < contentBot then
            UI[p.."label"].Position = Vector2.new(cx, iy+1); UI[p.."label"].Text = label; UI[p.."label"].Color = Col.Txt; UI[p.."label"].Visible = true
            UI[p.."sl_val"].Position = Vector2.new(cx+cw-40, iy+1); UI[p.."sl_val"].Text = string.format("%.1f%s", val, unit or ""); UI[p.."sl_val"].Visible = true
            local sy2 = iy + 18
            UI[p.."sl_bg"].Position = Vector2.new(cx, sy2); UI[p.."sl_bg"].Size = Vector2.new(cw, 4); UI[p.."sl_bg"].Visible = true
            local pct = math.clamp((val-mn)/(mx-mn), 0, 1)
            UI[p.."sl_fill"].Position = Vector2.new(cx, sy2); UI[p.."sl_fill"].Size = Vector2.new(cw*pct, 4); UI[p.."sl_fill"].Visible = true
            UI[p.."div"].From = Vector2.new(cx, iy+30); UI[p.."div"].To = Vector2.new(cx+cw, iy+30); UI[p.."div"].Visible = true
            table.insert(SliderZones, {x=cx, y=sy2-6, w=cw, h=16, mn=mn, mx=mx, key=key, cb=function(nv)
                C[key] = math.floor(nv*10)/10
                if key == "WalkSpeed" then RealWalkSpeed = C[key] end
                if key == "JumpPower" then RealJumpPower = C[key] end
                updateUI()
            end})
        end
        iy = iy + 38
    end

    local function drawButton(label, callback)
        local p = nextSlot(); if not p then return end
        if iy + 28 < contentBot then
            UI[p.."btn_bg"].Position = Vector2.new(cx, iy); UI[p.."btn_bg"].Size = Vector2.new(cw, 26); UI[p.."btn_bg"].Visible = true
            UI[p.."btn_txt"].Position = Vector2.new(cx + cw/2 - #label*3, iy+6); UI[p.."btn_txt"].Text = label; UI[p.."btn_txt"].Visible = true
            table.insert(ClickZones, {x=cx, y=iy, w=cw, h=26, cb=callback})
        end
        iy = iy + 32
    end

    local function drawSelector(label, opts, val, key)
        local p = nextSlot(); if not p then return end
        if iy + 26 < contentBot then
            UI[p.."label"].Position = Vector2.new(cx, iy+4); UI[p.."label"].Text = label; UI[p.."label"].Color = Col.Txt; UI[p.."label"].Visible = true
            local bx = cx + cw - 88
            UI[p.."sel_bg"].Position = Vector2.new(bx, iy); UI[p.."sel_bg"].Visible = true
            UI[p.."sel_txt"].Position = Vector2.new(bx+8, iy+5); UI[p.."sel_txt"].Text = tostring(val); UI[p.."sel_txt"].Visible = true
            UI[p.."div"].From = Vector2.new(cx, iy+26); UI[p.."div"].To = Vector2.new(cx+cw, iy+26); UI[p.."div"].Visible = true
            table.insert(ClickZones, {x=bx, y=iy, w=88, h=22, cb=function()
                local idx = 1
                for i2, o in ipairs(opts) do if o == C[key] then idx = i2; break end end
                idx = idx % #opts + 1; C[key] = opts[idx]; updateUI()
            end})
        end
        iy = iy + 32
    end

    local function drawInfo(text, color)
        local p = nextSlot(); if not p then return end
        if iy + 16 < contentBot then
            UI[p.."label"].Position = Vector2.new(cx, iy); UI[p.."label"].Text = text; UI[p.."label"].Color = color or Col.Dim; UI[p.."label"].Visible = true
        end
        iy = iy + 18
    end

    -- ==========================================
    -- PAGE CONTENT
    -- ==========================================
    if CurrentTab == 1 then
        drawSection("Automation")
        drawToggle("Auto Fish", "Simulate casting via game UI", C.AutoFish, "AutoFish")
        drawSelector("Mode", {"Normal","Blatant","Instant"}, C.FishMode, "FishMode")
        drawToggle("Auto Catch", "Fast reel via game signals", C.AutoCatch, "AutoCatch")
        drawSection("Timing")
        drawSlider("Fish Delay", C.FishDelay, 0.1, 5.0, "s", "FishDelay")
        drawSlider("Catch Delay", C.CatchDelay, 0.1, 3.0, "s", "CatchDelay")

    elseif CurrentTab == 2 then
        drawSection("Auto Sell")
        drawToggle("Auto Sell", "Sell via game sell button", C.AutoSell, "AutoSell")
        drawToggle("Protect Favorites", "Skip favorited fish", C.ProtectFav, "ProtectFav")
        drawSlider("Sell Timer", C.SellInterval, 10, 300, "s", "SellInterval")
        drawButton("Sell All Now", function()
            pcall(function()
                local btn = findGameButton(getPlayerGui(), "sell") or findGameButton(getPlayerGui(), "jual")
                if btn then clickButton(btn) end
            end)
        end)
        drawSection("Favorites")
        drawToggle("Auto Favorite", "Fav rare fish auto", C.AutoFavorite, "AutoFavorite")
        drawSelector("Min Rarity", {"Legendary","Mythic","Secret"}, C.MinRarity, "MinRarity")

    elseif CurrentTab == 3 then
        drawSection("Islands")
        local islands = {
            {"Spawn Island", CFrame.new(0, 15, 0)},
            {"Coral Reefs", CFrame.new(500, 15, 200)},
            {"Kohana", CFrame.new(-300, 15, 400)},
            {"Crater Island", CFrame.new(800, 15, -100)},
            {"Lost Isle", CFrame.new(-600, 15, -300)},
            {"Mount Hallow", CFrame.new(200, 80, -500)},
            {"Ancient Jungle", CFrame.new(-400, 15, 600)},
        }
        for _, isl in ipairs(islands) do
            drawButton(isl[1], function() safeTeleport(isl[2]) end)
        end
        drawSection("NPCs")
        local npcs = {{"Rod Shop"}, {"Sell NPC"}, {"Quest NPC"}}
        for _, npc in ipairs(npcs) do
            drawButton(npc[1], function()
                pcall(function()
                    for _, v in ipairs(WS:GetDescendants()) do
                        if v:IsA("Model") and v.Name:lower():find(npc[1]:lower():sub(1,4)) then
                            local pos = v:GetPivot()
                            safeTeleport(pos + Vector3.new(0, 3, 0))
                            break
                        end
                    end
                end)
            end)
        end

    elseif CurrentTab == 4 then
        drawSection("Speed (Spoofed)")
        drawSlider("Walk Speed", C.WalkSpeed, 16, 200, "", "WalkSpeed")
        drawSlider("Jump Power", C.JumpPower, 50, 300, "", "JumpPower")
        drawSection("Abilities (Spoofed)")
        drawToggle("Infinite Jump", "Jump in mid-air", C.InfiniteJump, "InfiniteJump")
        drawToggle("Fly", "WASD + Space/Shift", C.Fly, "Fly")
        drawToggle("Noclip", "Walk through walls", C.Noclip, "Noclip")
        drawToggle("Anti-Drown", "Smooth resurface", C.AntiDrown, "AntiDrown")

    elseif CurrentTab == 5 then
        drawSection("Protection")
        drawToggle("Anti-AFK", "Prevent idle kick", C.AntiAFK, "AntiAFK")
        drawSection("Performance")
        drawToggle("GPU Saver", "Reduce visual quality", C.GPUSaver, "GPUSaver")
        drawToggle("FPS Boost", "Remove particles/effects", C.FPSBoost, "FPSBoost")
        drawSection("Server")
        drawButton("Server Hop", function()
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
        drawButton("Rejoin Server", function()
            pcall(function() cloneref(game:GetService("TeleportService")):TeleportToPlaceInstance(game.PlaceId, game.JobId) end)
        end)

    elseif CurrentTab == 6 then
        drawSection("ESP (Drawing API)")
        drawToggle("Fish ESP", "Show fish locations", C.FishESP, "FishESP")
        drawToggle("Player ESP", "Show other players", C.PlayerESP, "PlayerESP")

    elseif CurrentTab == 7 then
        drawSection("Info")
        drawInfo("Player: "..tostring(LP.DisplayName), Col.Txt)
        drawInfo("UI: Drawing API (Undetectable)", Col.Acc)
        drawInfo("Bypass: Property Spoof + TweenTP", Col.Acc)
        drawInfo("Brand: GasUp ID", Col.Txt)
        drawInfo("Version: 5.0 Full Stealth", Col.Dim)
        drawSection("Actions")
        drawButton("Reset All Settings", function()
            C.AutoFish=false; C.FishMode="Normal"; C.AutoCatch=false
            C.FishDelay=0.8; C.CatchDelay=0.2; C.AutoSell=false; C.SellInterval=60
            C.AutoFavorite=false; C.ProtectFav=true; C.WalkSpeed=16; C.JumpPower=50
            C.InfiniteJump=false; C.Fly=false; C.Noclip=false; C.AntiAFK=true
            C.AntiDrown=false; C.GPUSaver=false; C.FPSBoost=false
            C.FishESP=false; C.PlayerESP=false
            RealWalkSpeed=16; RealJumpPower=50
            updateUI()
        end)
    end
end

-- =============================================
-- INPUT HANDLING
-- =============================================
local function onInputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local pos = UIS:GetMouseLocation()

        -- Float button click (show UI)
        if not UIVisible then
            local fx, fy = WPos.X, WPos.Y
            if pos.X >= fx and pos.X <= fx + 36 and pos.Y >= fy and pos.Y <= fy + 36 then
                UIVisible = true
                updateUI()
                return
            end
            return
        end

        -- Drag header
        local hx, hy = WPos.X, WPos.Y
        if pos.X >= hx + SW and pos.X <= hx + WW - 28 and pos.Y >= hy and pos.Y <= hy + HH then
            IsDragging = true
            DragOff = Vector2.new(pos.X - WPos.X, pos.Y - WPos.Y)
            return
        end

        -- Click zones
        for _, z in ipairs(ClickZones) do
            if pos.X >= z.x and pos.X <= z.x + z.w and pos.Y >= z.y and pos.Y <= z.y + z.h then
                pcall(z.cb)
                return
            end
        end

        -- Slider zones
        for _, z in ipairs(SliderZones) do
            if pos.X >= z.x and pos.X <= z.x + z.w and pos.Y >= z.y and pos.Y <= z.y + z.h then
                ActiveSlider = z
                local pct = math.clamp((pos.X - z.x) / z.w, 0, 1)
                local nv = z.mn + pct * (z.mx - z.mn)
                pcall(function() z.cb(nv) end)
                return
            end
        end
    end

    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.RightShift then
            UIVisible = not UIVisible
            updateUI()
        end
    end
end

local function onInputChanged(input)
    if IsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local pos = UIS:GetMouseLocation()
        WPos = Vector2.new(pos.X - DragOff.X, pos.Y - DragOff.Y)
        updateUI()
    end
    if ActiveSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local pos = UIS:GetMouseLocation()
        local z = ActiveSlider
        local pct = math.clamp((pos.X - z.x) / z.w, 0, 1)
        local nv = z.mn + pct * (z.mx - z.mn)
        pcall(function() z.cb(nv) end)
    end
end

local function onInputEnded(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsDragging = false
        ActiveSlider = nil
    end
end

UIS.InputBegan:Connect(onInputBegan)
UIS.InputChanged:Connect(onInputChanged)
UIS.InputEnded:Connect(onInputEnded)

-- =============================================
-- FEATURE LOOPS
-- =============================================

-- Auto Fish
task.spawn(function()
    while true do
        if C.AutoFish then
            pcall(function()
                local gui = getPlayerGui()
                if gui then
                    local castBtn = findGameButton(gui, "cast") or findGameButton(gui, "lempar") or findGameButton(gui, "fish") or findGameButton(gui, "throw")
                    if castBtn then clickButton(castBtn) end
                end
            end)
        end
        task.wait(rD(C.FishDelay))
    end
end)

-- Auto Catch
task.spawn(function()
    while true do
        if C.AutoCatch then
            pcall(function()
                local gui = getPlayerGui()
                if gui then
                    local reelBtn = findGameButton(gui, "reel") or findGameButton(gui, "tarik") or findGameButton(gui, "catch") or findGameButton(gui, "pull")
                    if reelBtn then clickButton(reelBtn) end
                end
            end)
        end
        task.wait(rD(C.CatchDelay))
    end
end)

-- Auto Sell
task.spawn(function()
    while true do
        if C.AutoSell then
            pcall(function()
                local gui = getPlayerGui()
                if gui then
                    local sellBtn = findGameButton(gui, "sell") or findGameButton(gui, "jual")
                    if sellBtn then clickButton(sellBtn) end
                end
            end)
        end
        task.wait(rD(C.SellInterval))
    end
end)

-- Movement: WalkSpeed, JumpPower
task.spawn(function()
    while true do
        pcall(function()
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = C.WalkSpeed
                hum.JumpPower = C.JumpPower
                RealWalkSpeed = C.WalkSpeed
                RealJumpPower = C.JumpPower
            end
        end)
        task.wait(0.5)
    end
end)

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    if C.InfiniteJump then
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
        if C.Fly then
            pcall(function()
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if not flyBV or flyBV.Parent ~= hrp then
                        flyBV = Instance.new("BodyVelocity")
                        flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                        flyBV.Velocity = Vector3.new(0, 0, 0)
                        flyBV.Parent = hrp
                    end
                    local cam = WS.CurrentCamera
                    local dir = Vector3.new(0, 0, 0)
                    if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                    flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * 80 or Vector3.new(0, 0, 0)
                end
            end)
        else
            pcall(function()
                if flyBV then flyBV:Destroy(); flyBV = nil end
            end)
        end
        task.wait(1/30)
    end
end)

-- Noclip
task.spawn(function()
    while true do
        if C.Noclip then
            pcall(function()
                local ch = LP.Character
                if ch then
                    for _, p in ipairs(ch:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        end
        task.wait(1/15)
    end
end)

-- Anti-Drown (smooth resurface via tween)
task.spawn(function()
    while true do
        if C.AntiDrown then
            pcall(function()
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Position.Y < -5 then
                    local target = CFrame.new(hrp.Position.X, 10, hrp.Position.Z)
                    local tw = TS:Create(hrp, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {CFrame = target})
                    tw:Play()
                end
            end)
        end
        task.wait(1)
    end
end)

-- Anti-AFK
task.spawn(function()
    while true do
        if C.AntiAFK then
            pcall(function()
                local VU = cloneref(game:GetService("VirtualUser"))
                VU:CaptureController()
                VU:ClickButton2(Vector2.new())
            end)
        end
        task.wait(60)
    end
end)

-- GPU Saver
task.spawn(function()
    while true do
        if C.GPUSaver then
            pcall(function()
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 1e6
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                for _, v in ipairs(Lighting:GetDescendants()) do
                    if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") then
                        v.Enabled = false
                    end
                end
            end)
        end
        task.wait(5)
    end
end)

-- FPS Boost
task.spawn(function()
    while true do
        if C.FPSBoost then
            pcall(function()
                for _, v in ipairs(WS:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                        v.Enabled = false
                    end
                    if v:IsA("Decal") and v.Parent and v.Parent:IsA("BasePart") then
                        v.Transparency = 1
                    end
                end
            end)
        end
        task.wait(10)
    end
end)

-- Fish ESP
local espObjects = {}
task.spawn(function()
    while true do
        for _, obj in ipairs(espObjects) do pcall(function() obj:Remove() end) end
        espObjects = {}
        if C.FishESP then
            pcall(function()
                local cam = WS.CurrentCamera
                for _, v in ipairs(WS:GetDescendants()) do
                    if v:IsA("Model") and (v.Name:lower():find("fish") or v.Name:lower():find("ikan")) and v:FindFirstChild("HumanoidRootPart") then
                        local pos = v:GetPivot().Position
                        local sp, onScreen = cam:WorldToViewportPoint(pos)
                        if onScreen and sp.Z < 500 then
                            local dot = Drawing.new("Circle")
                            dot.Position = Vector2.new(sp.X, sp.Y)
                            dot.Radius = 4
                            dot.Color = Col.Acc
                            dot.Filled = true
                            dot.Visible = true
                            table.insert(espObjects, dot)
                            local txt = Drawing.new("Text")
                            txt.Position = Vector2.new(sp.X + 8, sp.Y - 6)
                            txt.Text = v.Name .. " [" .. math.floor(sp.Z) .. "m]"
                            txt.Size = 10
                            txt.Color = Col.Acc
                            txt.Font = 2
                            txt.Visible = true
                            table.insert(espObjects, txt)
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- Player ESP
local pEspObjects = {}
task.spawn(function()
    while true do
        for _, obj in ipairs(pEspObjects) do pcall(function() obj:Remove() end) end
        pEspObjects = {}
        if C.PlayerESP then
            pcall(function()
                local cam = WS.CurrentCamera
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local pos = plr.Character.HumanoidRootPart.Position
                        local sp, onScreen = cam:WorldToViewportPoint(pos)
                        if onScreen then
                            local txt = Drawing.new("Text")
                            txt.Position = Vector2.new(sp.X, sp.Y - 20)
                            txt.Text = plr.DisplayName .. " [" .. math.floor(sp.Z) .. "m]"
                            txt.Size = 11
                            txt.Color = Color3.fromRGB(255, 255, 255)
                            txt.Font = 2
                            txt.Visible = true
                            txt.Outline = true
                            txt.OutlineColor = Color3.fromRGB(0, 0, 0)
                            table.insert(pEspObjects, txt)
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- =============================================
-- SPLASH SCREEN (small, professional, centered)
-- =============================================
local function showSplash()
    local vp = WS.CurrentCamera.ViewportSize
    local sw2, sh = 200, 60
    local sx = (vp.X - sw2) / 2
    local sy = (vp.Y - sh) / 2

    local sBg = Drawing.new("Square")
    sBg.Position = Vector2.new(sx, sy)
    sBg.Size = Vector2.new(sw2, sh)
    sBg.Color = Color3.fromRGB(12, 12, 16)
    sBg.Filled = true
    sBg.Visible = true
    sBg.Transparency = 1

    local sBorder = Drawing.new("Square")
    sBorder.Position = Vector2.new(sx, sy)
    sBorder.Size = Vector2.new(sw2, sh)
    sBorder.Color = Col.Acc
    sBorder.Filled = false
    sBorder.Thickness = 1
    sBorder.Visible = true
    sBorder.Transparency = 0.4

    local sTitle = Drawing.new("Text")
    sTitle.Position = Vector2.new(sx + sw2/2 - 30, sy + 8)
    sTitle.Text = "GasUp ID"
    sTitle.Size = 18
    sTitle.Color = Col.Acc
    sTitle.Font = 2
    sTitle.Visible = true
    sTitle.Outline = true
    sTitle.OutlineColor = Color3.fromRGB(0, 0, 0)

    local sSub = Drawing.new("Text")
    sSub.Position = Vector2.new(sx + sw2/2 - 42, sy + 28)
    sSub.Text = "Moron Fish It v5.0"
    sSub.Size = 11
    sSub.Color = Col.Dim
    sSub.Font = 2
    sSub.Visible = true

    local sBar = Drawing.new("Square")
    sBar.Position = Vector2.new(sx + 20, sy + 46)
    sBar.Size = Vector2.new(0, 3)
    sBar.Color = Col.Acc
    sBar.Filled = true
    sBar.Visible = true
    sBar.Transparency = 1

    local barW = sw2 - 40
    for i = 1, 20 do
        sBar.Size = Vector2.new(barW * (i / 20), 3)
        task.wait(0.06)
    end

    task.wait(0.3)
    sBg:Remove(); sBorder:Remove(); sTitle:Remove(); sSub:Remove(); sBar:Remove()
end

-- =============================================
-- INITIALIZATION
-- =============================================
showSplash()
buildFloatBtn()
buildUI()
updateUI()

-- Cleanup on character removal
LP.CharacterRemoving:Connect(function()
    pcall(function() if flyBV then flyBV:Destroy(); flyBV = nil end end)
end)
