--[[
    MORON FISH IT v4.2 - Stealth Edition
    Drawing API UI | firesignal automation | No character modification
    No Key | No HWID | Free Forever
    
    SAFE features: Auto Fish, Auto Sell, Anti-AFK, GPU Saver, FPS Boost, ESP
    RISKY features: Teleport, Fly, Noclip, Speed (labeled with warning)
]]

-- =============================================
-- ANTI-CHEAT BYPASS
-- =============================================
pcall(function()
    local mt = getrawmetatable(game)
    if mt then
        local oldIdx = mt.__index
        local oldNc = mt.__namecall
        if setreadonly then setreadonly(mt, false) end
        if make_writeable then make_writeable(mt) end
        mt.__namecall = newcclosure(function(self, ...)
            local m = getnamecallmethod()
            if m == "Kick" or m == "kick" then return wait(9e9) end
            local n = ""
            pcall(function() n = self.Name:lower() end)
            for _, w in ipairs({"detect","cheat","ban","anticheat","exploit","hack","flag","report","security","guard","monitor","watchdog","violation","suspicious","kick","punish"}) do
                if n:find(w) then return nil end
            end
            return oldNc(self, ...)
        end)
        mt.__index = newcclosure(function(self, key)
            if tostring(key):lower() == "kick" then return function() return wait(9e9) end end
            return oldIdx(self, key)
        end)
        if setreadonly then setreadonly(mt, true) end
    end
end)
pcall(function()
    for _, v in ipairs(getgc(true)) do
        if type(v) == "table" then
            pcall(function()
                for k, _ in pairs(v) do
                    local kl = tostring(k):lower()
                    if kl:find("kick") or kl:find("ban") or kl:find("detect") or kl:find("cheat") then
                        v[k] = function() end
                    end
                end
            end)
        end
    end
end)

-- =============================================
-- SERVICES
-- =============================================
local cloneref = cloneref or function(x) return x end
local Players = cloneref(game:GetService("Players"))
local UIS = cloneref(game:GetService("UserInputService"))
local RS = cloneref(game:GetService("RunService"))
local RepStore = cloneref(game:GetService("ReplicatedStorage"))
local WS = cloneref(game:GetService("Workspace"))
local Lighting = cloneref(game:GetService("Lighting"))
local LP = Players.LocalPlayer

-- =============================================
-- CONFIG
-- =============================================
local C = {
    AutoFish = false,
    FishMode = "Normal",
    AutoCatch = false,
    FishDelay = 0.8,
    CatchDelay = 0.2,
    AutoSell = false,
    SellInterval = 60,
    AutoFavorite = false,
    MinRarity = "Legendary",
    ProtectFav = true,
    AntiAFK = true,
    GPUSaver = false,
    FPSBoost = false,
    FishESP = false,
    PlayerESP = false,
    -- Risky features (labeled)
    WalkSpeed = 16,
    JumpPower = 50,
    Fly = false,
    Noclip = false,
    InfiniteJump = false,
    AntiDrown = false,
}

-- =============================================
-- SAFE UTILITIES (no character modification)
-- =============================================
local function rD(b) return b * (0.85 + math.random() * 0.3) end

-- firesignal: simulate clicking game's own UI buttons (safe)
local function clickButton(btn)
    if not btn then return end
    pcall(function()
        if firesignal then
            firesignal(btn.MouseButton1Click)
        elseif fireclickdetector then
            -- fallback
        end
    end)
    pcall(function()
        if btn.MouseButton1Click then
            for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
                pcall(function() conn:Fire() end)
            end
        end
    end)
end

-- Find game UI buttons by text/name
local function findGameButton(parent, textMatch)
    if not parent then return nil end
    local result = nil
    pcall(function()
        for _, v in ipairs(parent:GetDescendants()) do
            if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible then
                local txt = ""
                pcall(function() txt = v.Text:lower() end)
                local nm = v.Name:lower()
                if txt:find(textMatch:lower()) or nm:find(textMatch:lower()) then
                    result = v
                    break
                end
            end
        end
    end)
    return result
end

local function getPlayerGui()
    return LP and LP:FindFirstChild("PlayerGui")
end

-- =============================================
-- COLORS
-- =============================================
local Col = {
    BG = Color3.fromRGB(18, 18, 22),
    Side = Color3.fromRGB(14, 14, 18),
    Head = Color3.fromRGB(22, 22, 28),
    Acc = Color3.fromRGB(0, 200, 130),
    Txt = Color3.fromRGB(220, 220, 225),
    Dim = Color3.fromRGB(110, 110, 125),
    TOn = Color3.fromRGB(0, 200, 130),
    TOff = Color3.fromRGB(55, 55, 65),
    SBg = Color3.fromRGB(40, 40, 50),
    SFl = Color3.fromRGB(0, 200, 130),
    Btn = Color3.fromRGB(32, 32, 42),
    Div = Color3.fromRGB(32, 32, 38),
    TAct = Color3.fromRGB(26, 26, 33),
    Warn = Color3.fromRGB(255, 180, 50),
}

-- =============================================
-- DRAWING UI SYSTEM (persistent, no recreate)
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
local Tabs = {"Fishing", "Selling", "Movement", "Utility", "Visuals", "Settings"}
local ClickZones = {}
local SliderZones = {}
local ScrollOffset = 0
local MaxScroll = 0

local function D(key, cls, props)
    local obj = Drawing.new(cls)
    for k, v in pairs(props or {}) do obj[k] = v end
    UI[key] = obj
    return obj
end

local function setAllVis(vis)
    for _, obj in pairs(UI) do
        pcall(function() obj.Visible = vis end)
    end
end

-- =============================================
-- BUILD UI (called ONCE at startup)
-- =============================================
local function buildUI()
    local x, y = WPos.X, WPos.Y

    -- Background
    D("bg", "Square", {Position = Vector2.new(x, y), Size = Vector2.new(WW, WH), Color = Col.BG, Filled = true, Visible = true, Transparency = 1})
    D("border", "Square", {Position = Vector2.new(x, y), Size = Vector2.new(WW, WH), Color = Col.Acc, Filled = false, Thickness = 1, Visible = true, Transparency = 0.3})

    -- Sidebar
    D("side", "Square", {Position = Vector2.new(x, y), Size = Vector2.new(SW, WH), Color = Col.Side, Filled = true, Visible = true, Transparency = 1})

    -- Logo
    D("logoM", "Text", {Position = Vector2.new(x + 10, y + 7), Text = "M", Size = 18, Color = Col.Acc, Font = 2, Visible = true, Outline = true, OutlineColor = Color3.fromRGB(0, 0, 0)})
    D("logoT", "Text", {Position = Vector2.new(x + 28, y + 7), Text = "MORON", Size = 13, Color = Col.Txt, Font = 2, Visible = true})
    D("logoS", "Text", {Position = Vector2.new(x + 28, y + 20), Text = "Fish It v4.2", Size = 9, Color = Col.Dim, Font = 2, Visible = true})
    D("sline", "Line", {From = Vector2.new(x, y + 38), To = Vector2.new(x + SW, y + 38), Color = Col.Div, Thickness = 1, Visible = true})

    -- Tab buttons (6 tabs)
    for i, tab in ipairs(Tabs) do
        local ty = y + 42 + (i - 1) * 42
        local act = (i == CurrentTab)
        D("tab_bg_" .. i, "Square", {Position = Vector2.new(x, ty), Size = Vector2.new(SW, 40), Color = act and Col.TAct or Col.Side, Filled = true, Visible = true, Transparency = 1})
        D("tab_ind_" .. i, "Square", {Position = Vector2.new(x, ty), Size = Vector2.new(3, 40), Color = Col.Acc, Filled = true, Visible = act, Transparency = 1})
        D("tab_txt_" .. i, "Text", {Position = Vector2.new(x + 16, ty + 12), Text = tab, Size = 12, Color = act and Col.Txt or Col.Dim, Font = 2, Visible = true})
    end

    -- Header
    D("head", "Square", {Position = Vector2.new(x + SW, y), Size = Vector2.new(WW - SW, HH), Color = Col.Head, Filled = true, Visible = true, Transparency = 1})
    D("htitle", "Text", {Position = Vector2.new(x + SW + 12, y + 8), Text = Tabs[CurrentTab], Size = 14, Color = Col.Txt, Font = 2, Visible = true})
    D("hclose", "Text", {Position = Vector2.new(x + WW - 20, y + 8), Text = "x", Size = 13, Color = Col.Dim, Font = 2, Visible = true})

    -- Content area
    D("content_bg", "Square", {Position = Vector2.new(x + SW, y + HH), Size = Vector2.new(WW - SW, WH - HH), Color = Col.BG, Filled = true, Visible = true, Transparency = 1})

    -- Pre-create 20 item slots
    for i = 1, 20 do
        local p = "item_" .. i .. "_"
        D(p .. "label", "Text", {Position = Vector2.new(0, 0), Text = "", Size = 12, Color = Col.Txt, Font = 2, Visible = false})
        D(p .. "desc", "Text", {Position = Vector2.new(0, 0), Text = "", Size = 9, Color = Col.Dim, Font = 2, Visible = false})
        D(p .. "tog_bg", "Square", {Position = Vector2.new(0, 0), Size = Vector2.new(32, 14), Color = Col.TOff, Filled = true, Visible = false, Transparency = 1})
        D(p .. "tog_knob", "Circle", {Position = Vector2.new(0, 0), Radius = 5, Color = Color3.fromRGB(255, 255, 255), Filled = true, Visible = false, Transparency = 1})
        D(p .. "div", "Line", {From = Vector2.new(0, 0), To = Vector2.new(0, 0), Color = Col.Div, Thickness = 1, Visible = false, Transparency = 0.4})
        D(p .. "sl_bg", "Square", {Position = Vector2.new(0, 0), Size = Vector2.new(0, 4), Color = Col.SBg, Filled = true, Visible = false, Transparency = 1})
        D(p .. "sl_fill", "Square", {Position = Vector2.new(0, 0), Size = Vector2.new(0, 4), Color = Col.SFl, Filled = true, Visible = false, Transparency = 1})
        D(p .. "sl_val", "Text", {Position = Vector2.new(0, 0), Text = "", Size = 10, Color = Col.Acc, Font = 2, Visible = false})
        D(p .. "btn_bg", "Square", {Position = Vector2.new(0, 0), Size = Vector2.new(0, 26), Color = Col.Btn, Filled = true, Visible = false, Transparency = 1})
        D(p .. "btn_txt", "Text", {Position = Vector2.new(0, 0), Text = "", Size = 11, Color = Col.Txt, Font = 2, Visible = false})
        D(p .. "sec", "Text", {Position = Vector2.new(0, 0), Text = "", Size = 10, Color = Col.Acc, Font = 2, Visible = false})
        D(p .. "sel_bg", "Square", {Position = Vector2.new(0, 0), Size = Vector2.new(84, 22), Color = Col.Btn, Filled = true, Visible = false, Transparency = 1})
        D(p .. "sel_txt", "Text", {Position = Vector2.new(0, 0), Text = "", Size = 10, Color = Col.Acc, Font = 2, Visible = false})
        D(p .. "warn", "Text", {Position = Vector2.new(0, 0), Text = "", Size = 8, Color = Col.Warn, Font = 2, Visible = false})
    end
end

-- =============================================
-- UPDATE UI (reposition, no create/destroy)
-- =============================================
local function updateUI()
    ClickZones = {}
    SliderZones = {}

    if not UIVisible then
        setAllVis(false)
        return
    end

    local x, y = WPos.X, WPos.Y

    -- Update static elements
    UI["bg"].Position = Vector2.new(x, y)
    UI["border"].Position = Vector2.new(x, y)
    UI["side"].Position = Vector2.new(x, y)
    UI["logoM"].Position = Vector2.new(x + 10, y + 7)
    UI["logoT"].Position = Vector2.new(x + 28, y + 7)
    UI["logoS"].Position = Vector2.new(x + 28, y + 20)
    UI["sline"].From = Vector2.new(x, y + 38)
    UI["sline"].To = Vector2.new(x + SW, y + 38)

    for _, k in ipairs({"bg", "border", "side", "logoM", "logoT", "logoS", "sline"}) do
        UI[k].Visible = true
    end

    -- Update tabs
    for i = 1, #Tabs do
        local ty = y + 42 + (i - 1) * 42
        local act = (i == CurrentTab)
        UI["tab_bg_" .. i].Position = Vector2.new(x, ty)
        UI["tab_bg_" .. i].Color = act and Col.TAct or Col.Side
        UI["tab_bg_" .. i].Visible = true
        UI["tab_ind_" .. i].Position = Vector2.new(x, ty)
        UI["tab_ind_" .. i].Visible = act
        UI["tab_txt_" .. i].Position = Vector2.new(x + 16, ty + 12)
        UI["tab_txt_" .. i].Color = act and Col.Txt or Col.Dim
        UI["tab_txt_" .. i].Visible = true
        table.insert(ClickZones, {x = x, y = ty, w = SW, h = 40, cb = function()
            CurrentTab = i
            ScrollOffset = 0
            updateUI()
        end})
    end

    -- Header
    UI["head"].Position = Vector2.new(x + SW, y)
    UI["head"].Visible = true
    UI["htitle"].Position = Vector2.new(x + SW + 12, y + 8)
    UI["htitle"].Text = Tabs[CurrentTab]
    UI["htitle"].Visible = true
    UI["hclose"].Position = Vector2.new(x + WW - 20, y + 8)
    UI["hclose"].Visible = true
    table.insert(ClickZones, {x = x + WW - 28, y = y, w = 28, h = HH, cb = function()
        UIVisible = false
        setAllVis(false)
    end})

    UI["content_bg"].Position = Vector2.new(x + SW, y + HH)
    UI["content_bg"].Visible = true

    -- Hide all item slots
    for i = 1, 20 do
        local p = "item_" .. i .. "_"
        for _, s in ipairs({"label", "desc", "tog_bg", "tog_knob", "div", "sl_bg", "sl_fill", "sl_val", "btn_bg", "btn_txt", "sec", "sel_bg", "sel_txt", "warn"}) do
            UI[p .. s].Visible = false
        end
    end

    -- Content rendering
    local cx = x + SW + 12
    local cw = WW - SW - 24
    local iy = y + HH + 8
    local slot = 0
    local contentTop = y + HH
    local contentBot = y + WH

    local function nextSlot()
        slot = slot + 1
        if slot > 20 then return nil end
        return "item_" .. slot .. "_"
    end

    local function inView(py, h)
        return (py + h) > contentTop and py < contentBot
    end

    local function drawSection(title)
        local p = nextSlot()
        if not p then return end
        if inView(iy, 18) then
            UI[p .. "sec"].Position = Vector2.new(cx, iy + 2)
            UI[p .. "sec"].Text = title:upper()
            UI[p .. "sec"].Visible = true
        end
        iy = iy + 20
    end

    local function drawToggle(label, desc, val, key, warn)
        local p = nextSlot()
        if not p then return end
        if inView(iy, 34) then
            UI[p .. "label"].Position = Vector2.new(cx, iy + 1)
            UI[p .. "label"].Text = label
            UI[p .. "label"].Color = Col.Txt
            UI[p .. "label"].Visible = true
            if desc and desc ~= "" then
                UI[p .. "desc"].Position = Vector2.new(cx, iy + 16)
                UI[p .. "desc"].Text = desc
                UI[p .. "desc"].Visible = true
            end
            if warn then
                UI[p .. "warn"].Position = Vector2.new(cx + cw - 90, iy + 16)
                UI[p .. "warn"].Text = "! RISKY"
                UI[p .. "warn"].Visible = true
            end
            local tx = cx + cw - 36
            UI[p .. "tog_bg"].Position = Vector2.new(tx, iy + 2)
            UI[p .. "tog_bg"].Color = val and Col.TOn or Col.TOff
            UI[p .. "tog_bg"].Visible = true
            local kx = val and (tx + 20) or (tx + 2)
            UI[p .. "tog_knob"].Position = Vector2.new(kx + 5, iy + 9)
            UI[p .. "tog_knob"].Visible = true
            UI[p .. "div"].From = Vector2.new(cx, iy + 32)
            UI[p .. "div"].To = Vector2.new(cx + cw, iy + 32)
            UI[p .. "div"].Visible = true
            table.insert(ClickZones, {x = tx - 10, y = iy - 2, w = 50, h = 22, cb = function()
                C[key] = not C[key]
                updateUI()
            end})
        end
        iy = iy + 38
    end

    local function drawSlider(label, val, mn, mx, unit, key)
        local p = nextSlot()
        if not p then return end
        if inView(iy, 34) then
            UI[p .. "label"].Position = Vector2.new(cx, iy + 1)
            UI[p .. "label"].Text = label
            UI[p .. "label"].Color = Col.Txt
            UI[p .. "label"].Visible = true
            UI[p .. "sl_val"].Position = Vector2.new(cx + cw - 40, iy + 1)
            UI[p .. "sl_val"].Text = string.format("%.1f%s", val, unit or "")
            UI[p .. "sl_val"].Visible = true
            local sy2 = iy + 18
            UI[p .. "sl_bg"].Position = Vector2.new(cx, sy2)
            UI[p .. "sl_bg"].Size = Vector2.new(cw, 4)
            UI[p .. "sl_bg"].Visible = true
            local pct = math.clamp((val - mn) / (mx - mn), 0, 1)
            UI[p .. "sl_fill"].Position = Vector2.new(cx, sy2)
            UI[p .. "sl_fill"].Size = Vector2.new(cw * pct, 4)
            UI[p .. "sl_fill"].Visible = true
            UI[p .. "div"].From = Vector2.new(cx, iy + 30)
            UI[p .. "div"].To = Vector2.new(cx + cw, iy + 30)
            UI[p .. "div"].Visible = true
            table.insert(SliderZones, {x = cx, y = sy2 - 6, w = cw, h = 16, mn = mn, mx = mx, key = key, cb = function(nv)
                C[key] = math.floor(nv * 10) / 10
                updateUI()
            end})
        end
        iy = iy + 38
    end

    local function drawButton(label, callback)
        local p = nextSlot()
        if not p then return
 end
        if inView(iy, 28) then
            UI[p .. "btn_bg"].Position = Vector2.new(cx, iy)
            UI[p .. "btn_bg"].Size = Vector2.new(cw, 26)
            UI[p .. "btn_bg"].Visible = true
            UI[p .. "btn_txt"].Position = Vector2.new(cx + cw / 2 - #label * 3, iy + 6)
            UI[p .. "btn_txt"].Text = label
            UI[p .. "btn_txt"].Visible = true
            table.insert(ClickZones, {x = cx, y = iy, w = cw, h = 26, cb = callback})
        end
        iy = iy + 32
    end

    local function drawSelector(label, opts, val, key)
        local p = nextSlot()
        if not p then return end
        if inView(iy, 26) then
            UI[p .. "label"].Position = Vector2.new(cx, iy + 4)
            UI[p .. "label"].Text = label
            UI[p .. "label"].Color = Col.Txt
            UI[p .. "label"].Visible = true
            local bx = cx + cw - 88
            UI[p .. "sel_bg"].Position = Vector2.new(bx, iy)
            UI[p .. "sel_bg"].Visible = true
            UI[p .. "sel_txt"].Position = Vector2.new(bx + 8, iy + 5)
            UI[p .. "sel_txt"].Text = tostring(val)
            UI[p .. "sel_txt"].Visible = true
            UI[p .. "div"].From = Vector2.new(cx, iy + 26)
            UI[p .. "div"].To = Vector2.new(cx + cw, iy + 26)
            UI[p .. "div"].Visible = true
            table.insert(ClickZones, {x = bx, y = iy, w = 88, h = 22, cb = function()
                local idx = 1
                for i2, o in ipairs(opts) do
                    if o == C[key] then idx = i2 break end
                end
                idx = idx % #opts + 1
                C[key] = opts[idx]
                updateUI()
            end})
        end
        iy = iy + 32
    end

    local function drawInfo(text, color)
        local p = nextSlot()
        if not p then return end
        if inView(iy, 16) then
            UI[p .. "label"].Position = Vector2.new(cx, iy)
            UI[p .. "label"].Text = text
            UI[p .. "label"].Color = color or Col.Dim
            UI[p .. "label"].Visible = true
        end
        iy = iy + 18
    end

    -- ==========================================
    -- PAGE CONTENT
    -- ==========================================
    if CurrentTab == 1 then -- FISHING
        drawSection("Automation")
        drawToggle("Auto Fish", "Simulate casting via game UI", C.AutoFish, "AutoFish")
        drawSelector("Mode", {"Normal", "Blatant", "Instant"}, C.FishMode, "FishMode")
        drawToggle("Auto Catch", "Fast reel via game signals", C.AutoCatch, "AutoCatch")
        drawSection("Timing")
        drawSlider("Fish Delay", C.FishDelay, 0.1, 5.0, "s", "FishDelay")
        drawSlider("Catch Delay", C.CatchDelay, 0.1, 3.0, "s", "CatchDelay")

    elseif CurrentTab == 2 then -- SELLING
        drawSection("Auto Sell")
        drawToggle("Auto Sell", "Sell via game sell button", C.AutoSell, "AutoSell")
        drawToggle("Protect Favorites", "Skip favorited fish", C.ProtectFav, "ProtectFav")
        drawSlider("Sell Timer", C.SellInterval, 10, 300, "s", "SellInterval")
        drawButton("[ Sell All Now ]", function()
            pcall(function()
                local pg = getPlayerGui()
                if pg then
                    local btn = findGameButton(pg, "sell")
                    if btn then clickButton(btn) end
                end
            end)
        end)
        drawSection("Favorites")
        drawToggle("Auto Favorite", "Fav rare fish auto", C.AutoFavorite, "AutoFavorite")
        drawSelector("Min Rarity", {"Legendary", "Mythic", "Secret"}, C.MinRarity, "MinRarity")

    elseif CurrentTab == 3 then -- MOVEMENT
        drawInfo("! Movement features modify character - use at own risk", Col.Warn)
        drawSection("Speed")
        drawSlider("Walk Speed", C.WalkSpeed, 16, 200, "", "WalkSpeed")
        drawSlider("Jump Power", C.JumpPower, 50, 300, "", "JumpPower")
        drawSection("Abilities")
        drawToggle("Infinite Jump", "Jump in mid-air", C.InfiniteJump, "InfiniteJump", true)
        drawToggle("Fly", "WASD to move in air", C.Fly, "Fly", true)
        drawToggle("Noclip", "Walk through walls", C.Noclip, "Noclip", true)
        drawToggle("Anti-Drown", "Stay above water", C.AntiDrown, "AntiDrown", true)

    elseif CurrentTab == 4 then -- UTILITY
        drawSection("Safe Features")
        drawToggle("Anti-AFK", "Prevent idle disconnect", C.AntiAFK, "AntiAFK")
        drawToggle("GPU Saver", "Reduce visual quality", C.GPUSaver, "GPUSaver")
        drawToggle("FPS Boost", "Remove particles/effects", C.FPSBoost, "FPSBoost")
        drawSection("Server")
        drawButton("[ Server Hop ]", function()
            pcall(function()
                local Http = cloneref(game:GetService("HttpService"))
                local TPS = cloneref(game:GetService("TeleportService"))
                local pid = game.PlaceId
                local url = "https://games.roblox.com/v1/games/" .. pid .. "/servers/Public?sortOrder=Asc&limit=100"
                local svs = Http:JSONDecode(game:HttpGet(url))
                for _, sv in ipairs(svs.data or {}) do
                    if sv.playing < sv.maxPlayers and sv.id ~= game.JobId then
                        TPS:TeleportToPlaceInstance(pid, sv.id)
                        break
                    end
                end
            end)
        end)
        drawButton("[ Rejoin Server ]", function()
            pcall(function()
                cloneref(game:GetService("TeleportService")):TeleportToPlaceInstance(game.PlaceId, game.JobId)
            end)
        end)

    elseif CurrentTab == 5 then -- VISUALS
        drawSection("ESP (Drawing API - Safe)")
        drawToggle("Fish ESP", "Show fish locations", C.FishESP, "FishESP")
        drawToggle("Player ESP", "Show other players", C.PlayerESP, "PlayerESP")

    elseif CurrentTab == 6 then -- SETTINGS
        drawSection("Info")
        drawInfo("Player: " .. tostring(LP.DisplayName), Col.Txt)
        drawInfo("UI: Drawing API (Undetectable)", Col.Acc)
        drawInfo("Brand: GasUp ID", Col.Txt)
        drawInfo("Version: 4.2 Stealth", Col.Dim)
        drawSection("Actions")
        drawButton("[ Reset All Settings ]", function()
            C.AutoFish = false C.FishMode = "Normal" C.AutoCatch = false
            C.FishDelay = 0.8 C.CatchDelay = 0.2
            C.AutoSell = false C.SellInterval = 60 C.AutoFavorite = false
            C.ProtectFav = true C.WalkSpeed = 16 C.JumpPower = 50
            C.InfiniteJump = false C.Fly = false C.Noclip = false
            C.AntiAFK = true C.AntiDrown = false C.GPUSaver = false
            C.FPSBoost = false C.FishESP = false C.PlayerESP = false
            updateUI()
        end)
    end
end

-- =============================================
-- SPLASH SCREEN (small, center, professional)
-- =============================================
local function showSplash()
    local cam = WS.CurrentCamera
    if not cam then return end
    local vs = cam.ViewportSize
    local sx, sy = vs.X / 2, vs.Y / 2

    local sBg = Drawing.new("Square")
    sBg.Position = Vector2.new(sx - 90, sy - 28)
    sBg.Size = Vector2.new(180, 56)
    sBg.Color = Color3.fromRGB(14, 14, 18)
    sBg.Filled = true
    sBg.Visible = true
    sBg.Transparency = 1

    local sBrd = Drawing.new("Square")
    sBrd.Position = Vector2.new(sx - 90, sy - 28)
    sBrd.Size = Vector2.new(180, 56)
    sBrd.Color = Col.Acc
    sBrd.Filled = false
    sBrd.Thickness = 1
    sBrd.Visible = true
    sBrd.Transparency = 0.4

    local sTxt = Drawing.new("Text")
    sTxt.Position = Vector2.new(sx - 30, sy - 20)
    sTxt.Text = "GasUp ID"
    sTxt.Size = 16
    sTxt.Color = Col.Acc
    sTxt.Font = 2
    sTxt.Visible = true
    sTxt.Outline = true
    sTxt.OutlineColor = Color3.fromRGB(0, 0, 0)

    local sSub = Drawing.new("Text")
    sSub.Position = Vector2.new(sx - 40, sy - 2)
    sSub.Text = "Moron Fish It v4.2"
    sSub.Size = 10
    sSub.Color = Col.Dim
    sSub.Font = 2
    sSub.Visible = true

    local sBar = Drawing.new("Square")
    sBar.Position = Vector2.new(sx - 60, sy + 14)
    sBar.Size = Vector2.new(120, 3)
    sBar.Color = Color3.fromRGB(40, 40, 50)
    sBar.Filled = true
    sBar.Visible = true
    sBar.Transparency = 1

    local sFill = Drawing.new("Square")
    sFill.Position = Vector2.new(sx - 60, sy + 14)
    sFill.Size = Vector2.new(0, 3)
    sFill.Color = Col.Acc
    sFill.Filled = true
    sFill.Visible = true
    sFill.Transparency = 1

    for i = 1, 20 do
        sFill.Size = Vector2.new(120 * (i / 20), 3)
        task.wait(0.05)
    end
    task.wait(0.3)

    for i = 1, 6 do
        local t = 1 - (i / 6)
        pcall(function() sBg.Transparency = t end)
        pcall(function() sBrd.Transparency = t * 0.4 end)
        pcall(function() sTxt.Transparency = t end)
        pcall(function() sSub.Transparency = t end)
        pcall(function() sBar.Transparency = t end)
        pcall(function() sFill.Transparency = t end)
        task.wait(0.04)
    end

    pcall(function() sBg:Remove() end)
    pcall(function() sBrd:Remove() end)
    pcall(function() sTxt:Remove() end)
    pcall(function() sSub:Remove() end)
    pcall(function() sBar:Remove() end)
    pcall(function() sFill:Remove() end)
end

-- =============================================
-- INPUT HANDLING
-- =============================================
local ActiveSlider = nil

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    -- Toggle UI
    if input.KeyCode == Enum.KeyCode.RightShift then
        UIVisible = not UIVisible
        updateUI()
        return
    end

    -- Infinite Jump
    if input.KeyCode == Enum.KeyCode.Space and C.InfiniteJump then
        pcall(function()
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end

    if not UIVisible then return end

    local isMouse = input.UserInputType == Enum.UserInputType.MouseButton1
    local isTouch = input.UserInputType == Enum.UserInputType.Touch
    if not (isMouse or isTouch) then return end

    local pos = UIS:GetMouseLocation()
    local mx, my = pos.X, pos.Y

    -- Drag header
    if mx >= WPos.X + SW and mx <= WPos.X + WW and my >= WPos.Y and my <= WPos.Y + HH then
        IsDragging = true
        DragOff = Vector2.new(mx - WPos.X, my - WPos.Y)
        return
    end

    -- Click zones
    for _, z in ipairs(ClickZones) do
        if mx >= z.x and mx <= z.x + z.w and my >= z.y and my <= z.y + z.h then
            z.cb()
            return
        end
    end

    -- Slider zones
    for _, z in ipairs(SliderZones) do
        if mx >= z.x and mx <= z.x + z.w and my >= z.y and my <= z.y + z.h then
            ActiveSlider = z
            local pct = math.clamp((mx - z.x) / z
.w, 0, 1)
            local nv = z.mn + pct * (z.mx - z.mn)
            z.cb(nv)
            return
        end
    end
end)

UIS.InputChanged:Connect(function(input)
    if not UIVisible then return end
    local isMove = input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
    if not isMove then return end

    local pos = UIS:GetMouseLocation()
    local mx, my = pos.X, pos.Y

    if IsDragging then
        WPos = Vector2.new(mx - DragOff.X, my - DragOff.Y)
        updateUI()
        return
    end

    if ActiveSlider then
        local z = ActiveSlider
        local pct = math.clamp((mx - z.x) / z.w, 0, 1)
        local nv = z.mn + pct * (z.mx - z.mn)
        z.cb(nv)
    end
end)

UIS.InputEnded:Connect(function(input)
    local isMouse = input.UserInputType == Enum.UserInputType.MouseButton1
    local isTouch = input.UserInputType == Enum.UserInputType.Touch
    if isMouse or isTouch then
        IsDragging = false
        ActiveSlider = nil
    end
end)

-- =============================================
-- FEATURE LOOPS (safe methods)
-- =============================================

-- Anti-AFK (safe: just prevents idle)
task.spawn(function()
    while task.wait(60) do
        if C.AntiAFK then
            pcall(function()
                local VIM = game:GetService("VirtualInputManager")
                VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.1)
                VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
        end
    end
end)

-- Auto Fish (safe: uses firesignal on game's own cast button)
task.spawn(function()
    while task.wait(0.5) do
        if C.AutoFish then
            pcall(function()
                local pg = getPlayerGui()
                if not pg then return end

                -- Find cast/throw button in game UI
                local castBtn = findGameButton(pg, "cast") or findGameButton(pg, "throw") or findGameButton(pg, "lempar") or findGameButton(pg, "fish") or findGameButton(pg, "klik")
                if castBtn then
                    clickButton(castBtn)
                    task.wait(rD(C.FishDelay))
                end
            end)

            -- Auto Catch: find and click reel/catch button
            if C.AutoCatch then
                pcall(function()
                    local pg = getPlayerGui()
                    if not pg then return end
                    task.wait(rD(C.CatchDelay))
                    local catchBtn = findGameButton(pg, "reel") or findGameButton(pg, "catch") or findGameButton(pg, "tarik") or findGameButton(pg, "pull")
                    if catchBtn then
                        clickButton(catchBtn)
                    end
                end)
            end
        end
    end
end)

-- Auto Sell (safe: clicks game sell button)
task.spawn(function()
    while task.wait(1) do
        if C.AutoSell then
            pcall(function()
                local pg = getPlayerGui()
                if not pg then return end
                local sellBtn = findGameButton(pg, "sell") or findGameButton(pg, "jual")
                if sellBtn then
                    clickButton(sellBtn)
                end
            end)
            task.wait(rD(C.SellInterval))
        end
    end
end)

-- GPU Saver (safe: client visual only)
task.spawn(function()
    while task.wait(5) do
        if C.GPUSaver then
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 9e9
                for _, v in ipairs(WS:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                        v.Enabled = false
                    end
                end
            end)
        end
    end
end)

-- FPS Boost (safe: client visual only)
task.spawn(function()
    while task.wait(5) do
        if C.FPSBoost then
            pcall(function()
                for _, v in ipairs(WS:GetDescendants()) do
                    if v:IsA("Decal") or v:IsA("Texture") or v:IsA("MeshPart") then
                        pcall(function()
                            if v:IsA("Decal") or v:IsA("Texture") then
                                v.Transparency = 1
                            end
                        end)
                    end
                end
                for _, v in ipairs(Lighting:GetDescendants()) do
                    if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
                        v.Enabled = false
                    end
                end
            end)
        end
    end
end)

-- Movement features (RISKY - modifies character)
RS.Heartbeat:Connect(function()
    pcall(function()
        local ch = LP.Character
        if not ch then return end
        local hum = ch:FindFirstChildOfClass("Humanoid")
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        -- Walk Speed (risky)
        if C.WalkSpeed ~= 16 then
            hum.WalkSpeed = C.WalkSpeed
        end

        -- Jump Power (risky)
        if C.JumpPower ~= 50 then
            hum.JumpPower = C.JumpPower
        end

        -- Noclip (risky)
        if C.Noclip then
            for _, part in ipairs(ch:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end

        -- Anti-Drown (risky)
        if C.AntiDrown and hrp.Position.Y < -5 then
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 10, 0)
        end
    end)
end)

-- Fly (risky)
local flyBV = nil
RS.Heartbeat:Connect(function()
    pcall(function()
        local ch = LP.Character
        if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if C.Fly then
            if not flyBV then
                flyBV = Instance.new("BodyVelocity")
                flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
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
            flyBV.Velocity = dir * 60
        else
            if flyBV then
                flyBV:Destroy()
                flyBV = nil
            end
        end
    end)
end)

-- Fish ESP (safe: Drawing API)
local espDrawings = {}
task.spawn(function()
    while task.wait(2) do
        -- Clear old ESP
        for _, d in ipairs(espDrawings) do
            pcall(function() d:Remove() end)
        end
        espDrawings = {}

        if C.FishESP then
            pcall(function()
                local cam = WS.CurrentCamera
                for _, v in ipairs(WS:GetDescendants()) do
                    if v:IsA("Model") and (v.Name:lower():find("fish") or v.Name:lower():find("ikan")) then
                        local pos = v:GetPivot().Position
                        local screenPos, onScreen = cam:WorldToViewportPoint(pos)
                        if onScreen then
                            local txt = Drawing.new("Text")
                            txt.Position = Vector2.new(screenPos.X, screenPos.Y)
                            txt.Text = v.Name
                            txt.Size = 11
                            txt.Color = Col.Acc
                            txt.Font = 2
                            txt.Visible = true
                            txt.Outline = true
                            txt.OutlineColor = Color3.fromRGB(0, 0, 0)
                            table.insert(espDrawings, txt)
                        end
                    end
                end
            end)
        end

        if C.PlayerESP then
            pcall(function()
                local cam = WS.CurrentCamera
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LP and plr.Character then
                        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                            if onScreen then
                                local dist = math.floor((LP.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                                local txt = Drawing.new("Text")
                                txt.Position = Vector2.new(screenPos.X, screenPos.Y)
                                txt.Text = plr.DisplayName .. " [" .. dist .. "m]"
                                txt.Size = 11
                                txt.Color = Color3.fromRGB(255, 255, 255)
                                txt.Font = 2
                                txt.Visible = true
                                txt.Outline = true
                                txt.OutlineColor = Color3.fromRGB(0, 0, 0)
                                table.insert(espDrawings, txt)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- =============================================
-- INITIALIZATION
-- =============================================
showSplash()
buildUI()
updateUI()
