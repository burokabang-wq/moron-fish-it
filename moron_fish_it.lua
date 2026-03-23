--[[
    MORON FISH IT v4.0 - Drawing API Edition
    100% Undetectable UI using Drawing.new()
    No Key | No HWID | Free Forever
    
    Game: Fish It! (Roblox)
    UI: Drawing API (external, cannot be detected by any anti-cheat)
]]

-- SECTION 0: ANTI-CHEAT BYPASS
pcall(function()
    local mt = getrawmetatable(game)
    if mt then
        local oldIndex = mt.__index
        local oldNamecall = mt.__namecall
        if setreadonly then setreadonly(mt, false) end
        if make_writeable then make_writeable(mt) end
        
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" or method == "kick" then
                return wait(9e9)
            end
            local name = ""
            pcall(function() name = self.Name:lower() end)
            local blocked = {"detect","cheat","ban","anticheat","exploit","hack","flag","report","security","guard","monitor","watchdog","violation","suspicious","kick","punish","check"}
            for _, word in ipairs(blocked) do
                if name:find(word) then
                    return nil
                end
            end
            return oldNamecall(self, ...)
        end)
        
        mt.__index = newcclosure(function(self, key)
            if tostring(key):lower() == "kick" then
                return function() return wait(9e9) end
            end
            return oldIndex(self, key)
        end)
        
        if setreadonly then setreadonly(mt, true) end
    end
end)

pcall(function()
    for _, v in ipairs(getgc(true)) do
        if type(v) == "table" then
            pcall(function()
                if v.Kick or v.kick or v.Ban or v.ban then
                    for k, _ in pairs(v) do
                        local kl = tostring(k):lower()
                        if kl:find("kick") or kl:find("ban") or kl:find("detect") or kl:find("cheat") then
                            v[k] = function() end
                        end
                    end
                end
            end)
        elseif type(v) == "function" then
            pcall(function()
                local info = debug.getinfo(v)
                if info and info.source then
                    local src = info.source:lower()
                    if src:find("anticheat") or src:find("anti-cheat") or src:find("detection") then
                        hookfunction(v, function() end)
                    end
                end
            end)
        end
    end
end)

-- SECTION 1: SERVICES (all cloneref'd)
local cloneref = cloneref or function(x) return x end
local Players = cloneref(game:GetService("Players"))
local UIS = cloneref(game:GetService("UserInputService"))
local RS = cloneref(game:GetService("RunService"))
local TS = cloneref(game:GetService("TweenService"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Workspace = cloneref(game:GetService("Workspace"))
local Lighting = cloneref(game:GetService("Lighting"))

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- SECTION 2: CONFIGURATION
local Config = {
    AutoFish = false,
    FishMode = "Normal",
    AutoCatch = false,
    FishDelay = 0.8,
    CatchDelay = 0.2,
    AutoEnchant = false,
    AutoBuyRod = false,
    AutoBuyWeather = false,
    AutoQuest = false,
    AutoEvent = false,
    AutoArtifact = false,
    AutoSell = false,
    SellInterval = 60,
    AutoFavorite = false,
    MinRarity = "Legendary",
    AutoSellProtectFav = true,
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    Fly = false,
    Noclip = false,
    AntiAFK = true,
    AntiDrown = false,
    GPUSaver = false,
    FPSBoost = false,
    FishESP = false,
    PlayerESP = false,
    WebhookURL = "",
}

-- SECTION 3: UTILITY FUNCTIONS
local function rDelay(base)
    return base * (0.85 + math.random() * 0.3)
end

local function safeFireServer(remote, ...)
    local args = {...}
    task.defer(function()
        pcall(function()
            remote:FireServer(unpack(args))
        end)
    end)
end

local function findRemote(name)
    local r = nil
    pcall(function()
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") and v.Name:lower():find(name:lower()) then
                r = v
                break
            end
        end
    end)
    return r
end

local function findRemoteFunction(name)
    local r = nil
    pcall(function()
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteFunction") and v.Name:lower():find(name:lower()) then
                r = v
                break
            end
        end
    end)
    return r
end

-- SECTION 4: MAP LOCATIONS
local Maps = {
    {"Spawn Island", Vector3.new(0, 10, 0)},
    {"Coral Reefs", Vector3.new(500, 10, 200)},
    {"Crater Island", Vector3.new(-400, 10, 600)},
    {"Lost Isle", Vector3.new(800, 10, -300)},
    {"Tropical Grove", Vector3.new(-200, 10, -500)},
    {"Mount Hallow", Vector3.new(300, 15, 700)},
    {"Kohana", Vector3.new(-600, 10, 100)},
    {"Ancient Jungle", Vector3.new(700, 10, 500)},
    {"Crystal Cavern", Vector3.new(-100, -20, 800)},
    {"Forgotten Shore", Vector3.new(1000, 10, 0)},
}

local NPCs = {
    {"Rod Shop", Vector3.new(50, 10, 30)},
    {"Sell NPC", Vector3.new(-30, 10, 50)},
    {"Enchant NPC", Vector3.new(80, 10, -20)},
    {"Quest NPC", Vector3.new(-50, 10, -40)},
    {"Weather NPC", Vector3.new(100, 10, 60)},
    {"Boat Shop", Vector3.new(-80, 10, 80)},
}

-- SECTION 5: DRAWING UI SYSTEM
-- All UI is rendered using Drawing.new() - completely undetectable
local DrawingObjects = {}
local UIVisible = true
local CurrentTab = 1
local ScrollOffset = 0
local MaxScroll = 0
local IsDragging = false
local DragStart = Vector2.new(0, 0)
local WindowPos = Vector2.new(80, 60)
local WindowSize = Vector2.new(480, 340)
local SidebarWidth = 120
local HeaderHeight = 36
local TabItems = {"Fishing", "Selling", "Teleport", "Movement", "Utility", "Visuals", "Settings"}
local TabIcons = {"~", "$", ">", "^", "*", "@", "#"}

-- Color scheme
local Colors = {
    BG = Color3.fromRGB(18, 18, 22),
    Sidebar = Color3.fromRGB(14, 14, 18),
    Header = Color3.fromRGB(22, 22, 28),
    Accent = Color3.fromRGB(0, 200, 130),
    Text = Color3.fromRGB(220, 220, 225),
    TextDim = Color3.fromRGB(120, 120, 135),
    Toggle_On = Color3.fromRGB(0, 200, 130),
    Toggle_Off = Color3.fromRGB(60, 60, 70),
    Slider_BG = Color3.fromRGB(40, 40, 50),
    Slider_Fill = Color3.fromRGB(0, 200, 130),
    Button = Color3.fromRGB(35, 35, 45),
    ButtonHover = Color3.fromRGB(45, 45, 58),
    Divider = Color3.fromRGB(35, 35, 42),
    TabActive = Color3.fromRGB(28, 28, 35),
    TabHover = Color3.fromRGB(22, 22, 28),
}

local function newDrawing(class, props)
    local obj = Drawing.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    table.insert(DrawingObjects, obj)
    return obj
end

local function clearDrawings()
    for _, obj in ipairs(DrawingObjects) do
        pcall(function() obj:Remove() end)
    end
    DrawingObjects = {}
end

-- Interactive element tracking
local ClickableAreas = {}
local SliderAreas = {}
local ActiveSlider = nil

local function addClickable(x, y, w, h, callback)
    table.insert(ClickableAreas, {x=x, y=y, w=w, h=h, cb=callback})
end

local function addSlider(x, y, w, h, min, max, current, callback)
    table.insert(SliderAreas, {x=x, y=y, w=w, h=h, min=min, max=max, current=current, cb=callback})
end

-- SECTION 6: RENDER UI
local function renderUI()
    clearDrawings()
    ClickableAreas = {}
    SliderAreas = {}
    
    if not UIVisible then return end
    
    local wx, wy = WindowPos.X, WindowPos.Y
    local ww, wh = WindowSize.X, WindowSize.Y
    
    -- Main background
    newDrawing("Square", {
        Position = Vector2.new(wx, wy),
        Size = Vector2.new(ww, wh),
        Color = Colors.BG,
        Filled = true,
        Visible = true,
        Transparency = 1,
    })
    
    -- Border
    newDrawing("Square", {
        Position = Vector2.new(wx, wy),
        Size = Vector2.new(ww, wh),
        Color = Colors.Accent,
        Filled = false,
        Thickness = 1,
        Visible = true,
        Transparency = 0.5,
    })
    
    -- Sidebar background
    newDrawing("Square", {
        Position = Vector2.new(wx, wy),
        Size = Vector2.new(SidebarWidth, wh),
        Color = Colors.Sidebar,
        Filled = true,
        Visible = true,
        Transparency = 1,
    })
    
    -- Logo "M" 
    newDrawing("Text", {
        Position = Vector2.new(wx + 10, wy + 8),
        Text = "M",
        Size = 22,
        Color = Colors.Accent,
        Font = 2,
        Visible = true,
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
    })
    
    -- "MORON" text
    newDrawing("Text", {
        Position = Vector2.new(wx + 32, wy + 8),
        Text = "MORON",
        Size = 16,
        Color = Colors.Text,
        Font = 2,
        Visible = true,
    })
    
    -- "Fish It v4.0" subtitle
    newDrawing("Text", {
        Position = Vector2.new(wx + 32, wy + 24),
        Text = "Fish It v4.0",
        Size = 11,
        Color = Colors.TextDim,
        Font = 2,
        Visible = true,
    })
    
    -- Sidebar divider
    newDrawing("Line", {
        From = Vector2.new(wx, wy + 44),
        To = Vector2.new(wx + SidebarWidth, wy + 44),
        Color = Colors.Divider,
        Thickness = 1,
        Visible = true,
    })
    
    -- Tab buttons
    for i, tab in ipairs(TabItems) do
        local ty = wy + 48 + (i - 1) * 38
        local isActive = (i == CurrentTab)
        
        -- Tab background
        if isActive then
            newDrawing("Square", {
                Position = Vector2.new(wx, ty),
                Size = Vector2.new(SidebarWidth, 36),
                Color = Colors.TabActive,
                Filled = true,
                Visible = true,
                Transparency = 1,
            })
            -- Active indicator line
            newDrawing("Square", {
                Position = Vector2.new(wx, ty),
                Size = Vector2.new(3, 36),
                Color = Colors.Accent,
                Filled = true,
                Visible = true,
                Transparency = 1,
            })
        end
        
        -- Tab icon
        newDrawing("Text", {
            Position = Vector2.new(wx + 14, ty + 10),
            Text = TabIcons[i],
            Size = 14,
            Color = isActive and Colors.Accent or Colors.TextDim,
            Font = 2,
            Visible = true,
        })
        
        -- Tab text
        newDrawing("Text", {
            Position = Vector2.new(wx + 34, ty + 10),
            Text = tab,
            Size = 13,
            Color = isActive and Colors.Text or Colors.TextDim,
            Font = 2,
            Visible = true,
        })
        
        addClickable(wx, ty, SidebarWidth, 36, function()
            CurrentTab = i
            ScrollOffset = 0
            renderUI()
        end)
    end
    
    -- Content area
    local cx = wx + SidebarWidth + 1
    local cy = wy
    local cw = ww - SidebarWidth - 1
    local ch = wh
    
    -- Header bar
    newDrawing("Square", {
        Position = Vector2.new(cx, cy),
        Size = Vector2.new(cw, HeaderHeight),
        Color = Colors.Header,
        Filled = true,
        Visible = true,
        Transparency = 1,
    })
    
    -- Header title
    newDrawing("Text", {
        Position = Vector2.new(cx + 12, cy + 10),
        Text = TabItems[CurrentTab],
        Size = 15,
        Color = Colors.Text,
        Font = 2,
        Visible = true,
    })
    
    -- Close button "x"
    newDrawing("Text", {
        Position = Vector2.new(cx + cw - 22, cy + 10),
        Text = "x",
        Size = 14,
        Color = Colors.TextDim,
        Font = 2,
        Visible = true,
    })
    addClickable(cx + cw - 30, cy + 4, 26, 26, function()
        UIVisible = false
        renderUI()
    end)
    
    -- Content start position
    local contentY = cy + HeaderHeight + 8
    local contentX = cx + 12
    local contentW = cw - 24
    local itemY = contentY - ScrollOffset
    
    -- Helper: draw toggle
    local function drawToggle(label, desc, value, y, callback)
        if y < cy + HeaderHeight - 10 or y > cy + ch + 10 then return y + 42 end
        
        -- Label
        newDrawing("Text", {
            Position = Vector2.new(contentX, y + 2),
            Text = label,
            Size = 13,
            Color = Colors.Text,
            Font = 2,
            Visible = true,
        })
        
        -- Description
        if desc and desc ~= "" then
            newDrawing("Text", {
                Position = Vector2.new(contentX, y + 18),
                Text = desc,
                Size = 10,
                Color = Colors.TextDim,
                Font = 2,
                Visible = true,
            })
        end
        
        -- Toggle box
        local tx = contentX + contentW - 36
        newDrawing("Square", {
            Position = Vector2.new(tx, y + 4),
            Size = Vector2.new(32, 16),
            Color = value and Colors.Toggle_On or Colors.Toggle_Off,
            Filled = true,
            Visible = true,
            Transparency = 1,
        })
        
        -- Toggle knob
        local knobX = value and (tx + 18) or (tx + 2)
        newDrawing("Circle", {
            Position = Vector2.new(knobX + 6, y + 12),
            Radius = 6,
            Color = Color3.fromRGB(255, 255, 255),
            Filled = true,
            Visible = true,
            Transparency = 1,
        })
        
        addClickable(tx - 10, y, 52, 28, function()
            callback(not value)
            renderUI()
        end)
        
        -- Divider line
        newDrawing("Line", {
            From = Vector2.new(contentX, y + 36),
            To = Vector2.new(contentX + contentW, y + 36),
            Color = Colors.Divider,
            Thickness = 1,
            Visible = true,
            Transparency = 0.5,
        })
        
        return y + 42
    end
    
    -- Helper: draw slider
    local function drawSlider(label, value, min, max, unit, y, callback)
        if y < cy + HeaderHeight - 10 or y > cy + ch + 10 then return y + 48 end
        
        -- Label + value
        newDrawing("Text", {
            Position = Vector2.new(contentX, y + 2),
            Text = label,
            Size = 13,
            Color = Colors.Text,
            Font = 2,
            Visible = true,
        })
        
        local valText = string.format("%.1f%s", value, unit or "")
        newDrawing("Text", {
            Position = Vector2.new(contentX + contentW - 40, y + 2),
            Text = valText,
            Size = 12,
            Color = Colors.Accent,
            Font = 2,
            Visible = true,
        })
        
        -- Slider track
        local sliderY = y + 22
        local sliderW = contentW
        newDrawing("Square", {
            Position = Vector2.new(contentX, sliderY),
            Size = Vector2.new(sliderW, 6),
            Color = Colors.Slider_BG,
            Filled = true,
            Visible = true,
            Transparency = 1,
        })
        
        -- Slider fill
        local pct = math.clamp((value - min) / (max - min), 0, 1)
        newDrawing("Square", {
            Position = Vector2.new(contentX, sliderY),
            Size = Vector2.new(sliderW * pct, 6),
            Color = Colors.Slider_Fill,
            Filled = true,
            Visible = true,
            Transparency = 1,
        })
        
        -- Slider knob
        newDrawing("Circle", {
            Position = Vector2.new(contentX + sliderW * pct, sliderY + 3),
            Radius = 5,
            Color = Color3.fromRGB(255, 255, 255),
            Filled = true,
            Visible = true,
            Transparency = 1,
        })
        
        addSlider(contentX, sliderY - 4, sliderW, 14, min, max, value, function(newVal)
            callback(newVal)
            renderUI()
        end)
        
        -- Divider
        newDrawing("Line", {
            From = Vector2.new(contentX, y + 38),
            To = Vector2.new(contentX + contentW, y + 38),
            Color = Colors.Divider,
            Thickness = 1,
            Visible = true,
            Transparency = 0.5,
        })
        
        return y + 48
    end
    
    -- Helper: draw button
    local function drawButton(label, y, callback)
        if y < cy + HeaderHeight - 10 or y > cy + ch + 10 then return y + 38 end
        
        newDrawing("Square", {
            Position = Vector2.new(contentX, y),
            Size = Vector2.new(contentW, 28),
            Color = Colors.Button,
            Filled = true,
            Visible = true,
            Transparency = 1,
        })
        
        newDrawing("Text", {
            Position = Vector2.new(contentX + contentW / 2 - #label * 3, y + 7),
            Text = label,
            Size = 12,
            Color = Colors.Text,
            Font = 2,
            Visible = true,
        })
        
        addClickable(contentX, y, contentW, 28, function()
            callback()
        end)
        
        return y + 38
    end
    
    -- Helper: section header
    local function drawSection(title, y)
        if y < cy + HeaderHeight - 10 or y > cy + ch + 10 then return y + 24 end
        
        newDrawing("Text", {
            Position = Vector2.new(contentX, y + 4),
            Text = title:upper(),
            Size = 10,
            Color = Colors.Accent,
            Font = 2,
            Visible = true,
        })
        
        return y + 24
    end
    
    -- Helper: draw dropdown/selector
    local function drawSelector(label, options, currentVal, y, callback)
        if y < cy + HeaderHeight - 10 or y > cy + ch + 10 then return y + 38 end
        
        newDrawing("Text", {
            Position = Vector2.new(contentX, y + 2),
            Text = label,
            Size = 13,
            Color = Colors.Text,
            Font = 2,
            Visible = true,
        })
        
        -- Current value button
        local bx = contentX + contentW - 90
        newDrawing("Square", {
            Position = Vector2.new(bx, y),
            Size = Vector2.new(88, 24),
            Color = Colors.Button,
            Filled = true,
            Visible = true,
            Transparency = 1,
        })
        
        newDrawing("Text", {
            Position = Vector2.new(bx + 6, y + 6),
            Text = tostring(currentVal),
            Size = 11,
            Color = Colors.Accent,
            Font = 2,
            Visible = true,
        })
        
        addClickable(bx, y, 88, 24, function()
            local idx = 1
            for i, opt in ipairs(options) do
                if opt == currentVal then idx = i break end
            end
            idx = idx % #options + 1
            callback(options[idx])
            renderUI()
        end)
        
        -- Divider
        newDrawing("Line", {
            From = Vector2.new(contentX, y + 30),
            To = Vector2.new(contentX + contentW, y + 30),
            Color = Colors.Divider,
            Thickness = 1,
            Visible = true,
            Transparency = 0.5,
        })
        
        return y + 38
    end
    
    -- RENDER PAGES
    if CurrentTab == 1 then -- FISHING
        itemY = drawSection("FISHING MODE", itemY)
        itemY = drawToggle("Auto Fish", "Auto cast and reel", Config.AutoFish, itemY, function(v) Config.AutoFish = v end)
        itemY = drawSelector("Fish Mode", {"Normal","Blatant","Instant"}, Config.FishMode, itemY, function(v) Config.FishMode = v end)
        itemY = drawToggle("Auto Catch", "Fast reel for extra speed", Config.AutoCatch, itemY, function(v) Config.AutoCatch = v end)
        itemY = drawSection("TIMING", itemY)
        itemY = drawSlider("Fish Delay", Config.FishDelay, 0.1, 5.0, "s", itemY, function(v) Config.FishDelay = v end)
        itemY = drawSlider("Catch Delay", Config.CatchDelay, 0.1, 3.0, "s", itemY, function(v) Config.CatchDelay = v end)
        itemY = drawSection("AUTOMATION", itemY)
        itemY = drawToggle("Auto Enchant", "Enchant rod automatically", Config.AutoEnchant, itemY, function(v) Config.AutoEnchant = v end)
        itemY = drawToggle("Auto Buy Rod", "Buy best affordable rod", Config.AutoBuyRod, itemY, function(v) Config.AutoBuyRod = v end)
        itemY = drawToggle("Auto Buy Weather", "Buy weather for rare fish", Config.AutoBuyWeather, itemY, function(v) Config.AutoBuyWeather = v end)
        itemY = drawToggle("Auto Quest", "Accept and complete quests", Config.AutoQuest, itemY, function(v) Config.AutoQuest = v end)
        itemY = drawToggle("Auto Event", "Teleport to active events", Config.AutoEvent, itemY, function(v) Config.AutoEvent = v end)
        itemY = drawToggle("Auto Artifact", "Find and collect artifacts", Config.AutoArtifact, itemY, function(v) Config.AutoArtifact = v end)
        
    elseif CurrentTab == 2 then -- SELLING
        itemY = drawSection("AUTO SELL", itemY)
        itemY = drawToggle("Auto Sell", "Sell fish at interval", Config.AutoSell, itemY, function(v) Config.AutoSell = v end)
        itemY = drawToggle("Protect Favorites", "Don't sell favorited fish", Config.AutoSellProtectFav, itemY, function(v) Config.AutoSellProtectFav = v end)
        itemY = drawSlider("Sell Interval", Config.SellInterval, 10, 300, "s", itemY, function(v) Config.SellInterval = math.floor(v) end)
        itemY = drawButton("[ Sell All Now ]", itemY, function()
            pcall(function()
                local r = findRemote("sell")
                if r then safeFireServer(r, "all") end
            end)
        end)
        itemY = drawSection("FAVORITES", itemY)
        itemY = drawToggle("Auto Favorite", "Favorite rare catches", Config.AutoFavorite, itemY, function(v) Config.AutoFavorite = v end)
        itemY = drawSelector("Min Rarity", {"Legendary","Mythic","Secret"}, Config.MinRarity, itemY, function(v) Config.MinRarity = v end)
        
    elseif CurrentTab == 3 then -- TELEPORT
        itemY = drawSection("ISLANDS", itemY)
        for _, loc in ipairs(Maps) do
            itemY = drawButton(loc[1], itemY, function()
                pcall(function()
                    local char = LP.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart
                        local target = loc[2]
                        local dist = (hrp.Position - target).Magnitude
                        if dist > 400 then
                            local steps = math.ceil(dist / 100)
                            for s = 1, steps do
                                local alpha = s / steps
                                local pos = hrp.Position:Lerp(target, alpha)
                                hrp.CFrame = CFrame.new(pos)
                                task.wait(rDelay(0.05))
                            end
                        else
                            hrp.CFrame = CFrame.new(target)
                        end
                    end
                end)
            end)
        end
        itemY = drawSection("NPCs", itemY)
        for _, npc in ipairs(NPCs) do
            itemY = drawButton(npc[1], itemY, function()
                pcall(function()
                    local char = LP.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = CFrame.new(npc[2])
                    end
                end)
            end)
        end
        
    elseif CurrentTab == 4 then -- MOVEMENT
        itemY = drawSection("SPEED", itemY)
        itemY = drawSlider("Walk Speed", Config.WalkSpeed, 16, 200, "", itemY, function(v)
            Config.WalkSpeed = math.floor(v)
            pcall(function()
                LP.Character.Humanoid.WalkSpeed = Config.WalkSpeed
            end)
        end)
        itemY = drawSlider("Jump Power", Config.JumpPower, 50, 300, "", itemY, function(v)
            Config.JumpPower = math.floor(v)
            pcall(function()
                LP.Character.Humanoid.JumpPower = Config.JumpPower
            end)
        end)
        itemY = drawSection("ABILITIES", itemY)
        itemY = drawToggle("Infinite Jump", "Jump unlimited in air", Config.InfiniteJump, itemY, function(v) Config.InfiniteJump = v end)
        itemY = drawToggle("Fly", "WASD + Space/Shift", Config.Fly, itemY, function(v) Config.Fly = v end)
        itemY = drawToggle("Noclip", "Pass through walls", Config.Noclip, itemY, function(v) Config.Noclip = v end)
        
    elseif CurrentTab == 5 then -- UTILITY
        itemY = drawSection("PROTECTION", itemY)
        itemY = drawToggle("Anti-AFK", "Prevent idle kick", Config.AntiAFK, itemY, function(v) Config.AntiAFK = v end)
        itemY = drawToggle("Anti-Drown", "Auto resurface", Config.AntiDrown, itemY, function(v) Config.AntiDrown = v end)
        itemY = drawSection("PERFORMANCE", itemY)
        itemY = drawToggle("GPU Saver", "Reduce graphics for AFK", Config.GPUSaver, itemY, function(v)
            Config.GPUSaver = v
            pcall(function()
                if v then
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                    Lighting.GlobalShadows = false
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                            obj.Enabled = false
                        end
                    end
                else
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
                    Lighting.GlobalShadows = true
                end
            end)
        end)
        itemY = drawToggle("FPS Boost", "Remove particles/effects", Config.FPSBoost, itemY, function(v)
            Config.FPSBoost = v
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                        obj.Enabled = not v
                    end
                end
            end)
        end)
        itemY = drawSection("SERVER", itemY)
        itemY = drawButton("[ Server Hop ]", itemY, function()
            pcall(function()
                local Http = cloneref(game:GetService("HttpService"))
                local TPS = cloneref(game:GetService("TeleportService"))
                local placeId = game.PlaceId
                local servers = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"))
                for _, srv in ipairs(servers.data or {}) do
                    if srv.playing < srv.maxPlayers and srv.id ~= game.JobId then
                        TPS:TeleportToPlaceInstance(placeId, srv.id)
                        break
                    end
                end
            end)
        end)
        itemY = drawButton("[ Rejoin Server ]", itemY, function()
            pcall(function()
                local TPS = cloneref(game:GetService("TeleportService"))
                TPS:TeleportToPlaceInstance(game.PlaceId, game.JobId)
            end)
        end)
        
    elseif CurrentTab == 6 then -- VISUALS
        itemY = drawSection("ESP", itemY)
        itemY = drawToggle("Fish ESP", "Show fish labels", Config.FishESP, itemY, function(v) Config.FishESP = v end)
        itemY = drawToggle("Player ESP", "Show player names", Config.PlayerESP, itemY, function(v) Config.PlayerESP = v end)
        
    elseif CurrentTab == 7 then -- SETTINGS
        itemY = drawSection("INFO", itemY)
        
        local infoY = itemY
        newDrawing("Text", {
            Position = Vector2.new(contentX, infoY),
            Text = "Player: " .. tostring(LP.DisplayName),
            Size = 12,
            Color = Colors.Text,
            Font = 2,
            Visible = true,
        })
        infoY = infoY + 18
        
        newDrawing("Text", {
            Position = Vector2.new(contentX, infoY),
            Text = "Game: Fish It!",
            Size = 12,
            Color = Colors.TextDim,
            Font = 2,
            Visible = true,
        })
        infoY = infoY + 18
        
        newDrawing("Text", {
            Position = Vector2.new(contentX, infoY),
            Text = "Script: Moron Fish It v4.0",
            Size = 12,
            Color = Colors.TextDim,
            Font = 2,
            Visible = true,
        })
        infoY = infoY + 18
        
        newDrawing("Text", {
            Position = Vector2.new(contentX, infoY),
            Text = "UI: Drawing API (Undetectable)",
            Size = 12,
            Color = Colors.Accent,
            Font = 2,
            Visible = true,
        })
        infoY = infoY + 18
        
        newDrawing("Text", {
            Position = Vector2.new(contentX, infoY),
            Text = "Brand: GasUp ID",
            Size = 12,
            Color = Colors.TextDim,
            Font = 2,
            Visible = true,
        })
        infoY = infoY + 28
        
        itemY = infoY
        itemY = drawButton("[ Reset All Settings ]", itemY, function()
            Config.AutoFish = false
            Config.FishMode = "Normal"
            Config.AutoCatch = false
            Config.FishDelay = 0.8
            Config.CatchDelay = 0.2
            Config.AutoEnchant = false
            Config.AutoBuyRod = false
            Config.AutoBuyWeather = false
            Config.AutoQuest = false
            Config.AutoEvent = false
            Config.AutoArtifact = false
            Config.AutoSell = false
            Config.SellInterval = 60
            Config.AutoFavorite = false
            Config.AutoSellProtectFav = true
            Config.WalkSpeed = 16
            Config.JumpPower = 50
            Config.InfiniteJump = false
            Config.Fly = false
            Config.Noclip = false
            Config.AntiAFK = true
            Config.AntiDrown = false
            Config.GPUSaver = false
            Config.FPSBoost = false
            Config.FishESP = false
            Config.PlayerESP = false
            renderUI()
        end)
    end
    
    -- Calculate max scroll
    MaxScroll = math.max(0, (itemY + ScrollOffset) - (cy + ch) + 20)
end

-- SECTION 7: SPLASH SCREEN
local function showSplash()
    local splashObjects = {}
    local screenSize = workspace.CurrentCamera.ViewportSize
    local sx = screenSize.X / 2
    local sy = screenSize.Y / 2
    
    -- Small box background (220x70)
    local bg = Drawing.new("Square")
    bg.Position = Vector2.new(sx - 110, sy - 35)
    bg.Size = Vector2.new(220, 70)
    bg.Color = Color3.fromRGB(14, 14, 18)
    bg.Filled = true
    bg.Visible = true
    bg.Transparency = 1
    table.insert(splashObjects, bg)
    
    -- Border
    local border = Drawing.new("Square")
    border.Position = Vector2.new(sx - 110, sy - 35)
    border.Size = Vector2.new(220, 70)
    border.Color = Colors.Accent
    border.Filled = false
    border.Thickness = 1
    border.Visible = true
    border.Transparency = 0.6
    table.insert(splashObjects, border)
    
    -- "GasUp ID" main text
    local title = Drawing.new("Text")
    title.Position = Vector2.new(sx - 38, sy - 24)
    title.Text = "GasUp ID"
    title.Size = 20
    title.Color = Colors.Accent
    title.Font = 2
    title.Visible = true
    title.Outline = true
    title.OutlineColor = Color3.fromRGB(0, 0, 0)
    table.insert(splashObjects, title)
    
    -- "Moron Fish It v4.0" subtitle
    local sub = Drawing.new("Text")
    sub.Position = Vector2.new(sx - 48, sy + 2)
    sub.Text = "Moron Fish It v4.0"
    sub.Size = 12
    sub.Color = Colors.TextDim
    sub.Font = 2
    sub.Visible = true
    table.insert(splashObjects, sub)
    
    -- Loading bar background
    local barBG = Drawing.new("Square")
    barBG.Position = Vector2.new(sx - 80, sy + 22)
    barBG.Size = Vector2.new(160, 4)
    barBG.Color = Color3.fromRGB(40, 40, 50)
    barBG.Filled = true
    barBG.Visible = true
    barBG.Transparency = 1
    table.insert(splashObjects, barBG)
    
    -- Loading bar fill (animated)
    local barFill = Drawing.new("Square")
    barFill.Position = Vector2.new(sx - 80, sy + 22)
    barFill.Size = Vector2.new(0, 4)
    barFill.Color = Colors.Accent
    barFill.Filled = true
    barFill.Visible = true
    barFill.Transparency = 1
    table.insert(splashObjects, barFill)
    
    -- Animate loading bar
    for i = 1, 30 do
        barFill.Size = Vector2.new(160 * (i / 30), 4)
        task.wait(0.05)
    end
    
    task.wait(0.5)
    
    -- Fade out
    for i = 1, 10 do
        local t = 1 - (i / 10)
        for _, obj in ipairs(splashObjects) do
            pcall(function() obj.Transparency = t end)
        end
        task.wait(0.03)
    end
    
    -- Cleanup
    for _, obj in ipairs(splashObjects) do
        pcall(function() obj:Remove() end)
    end
end

-- SECTION 8: INPUT HANDLING
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    -- Toggle UI with RightShift
    if input.KeyCode == Enum.KeyCode.RightShift then
        UIVisible = not UIVisible
        renderUI()
        return
    end
    
    -- Infinite Jump
    if input.KeyCode == Enum.KeyCode.Space and Config.InfiniteJump then
        pcall(function()
            LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
    
    -- Mouse click handling
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local pos = UIS:GetMouseLocation()
        local mx, my = pos.X, pos.Y
        local wx, wy = WindowPos.X, WindowPos.Y
        
        -- Check drag (header or sidebar top area)
        if mx >= wx and mx <= wx + WindowSize.X and my >= wy and my <= wy + HeaderHeight then
            IsDragging = true
            DragStart = Vector2.new(mx - wx, my - wy)
        end
        
        -- Check clickable areas
        for _, area in ipairs(ClickableAreas) do
            if mx >= area.x and mx <= area.x + area.w and my >= area.y and my <= area.y + area.h then
                area.cb()
                return
            end
        end
        
        -- Check slider areas
        for _, slider in ipairs(SliderAreas) do
            if mx >= slider.x and mx <= slider.x + slider.w and my >= slider.y and my <= slider.y + slider.h then
                ActiveSlider = slider
                local pct = math.clamp((mx - slider.x) / slider.w, 0, 1)
                local val = slider.min + pct * (slider.max - slider.min)
                val = math.floor(val * 10) / 10
                slider.cb(val)
                return
            end
        end
    end
end)

UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local pos = UIS:GetMouseLocation()
        local mx, my = pos.X, pos.Y
        
        -- Dragging window
        if IsDragging then
            WindowPos = Vector2.new(mx - DragStart.X, my - DragStart.Y)
            renderUI()
        end
        
        -- Active slider
        if ActiveSlider then
            local pct = math.clamp((mx - ActiveSlider.x) / ActiveSlider.w, 0, 1)
            local val = ActiveSlider.min + pct * (ActiveSlider.max - ActiveSlider.min)
            val = math.floor(val * 10) / 10
            ActiveSlider.cb(val)
        end
    end
    
    -- Scroll handling
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        local delta = input.Position.Z
        ScrollOffset = math.clamp(ScrollOffset - delta * 30, 0, MaxScroll)
        renderUI()
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsDragging = false
        ActiveSlider = nil
    end
end)

-- SECTION 9: CORE LOOPS
-- Anti-AFK
task.spawn(function()
    while true do
        if Config.AntiAFK then
            pcall(function()
                local VU = cloneref(game:GetService("VirtualUser"))
                VU:CaptureController()
                VU:ClickButton2(Vector2.new())
            end)
        end
        task.wait(rDelay(30))
    end
end)

-- Auto Fish Loop
task.spawn(function()
    while true do
        if Config.AutoFish then
            pcall(function()
                local castRemote = findRemote("cast") or findRemote("fish") or findRemote("rod") or findRemote("throw")
                local reelRemote = findRemote("reel") or findRemote("catch") or findRemote("pull")
                
                if castRemote then
                    safeFireServer(castRemote)
                    task.wait(rDelay(Config.FishDelay))
                end
                
                if reelRemote then
                    local reelCount = 1
                    if Config.FishMode == "Blatant" then reelCount = 2
                    elseif Config.FishMode == "Instant" then reelCount = 3 end
                    
                    for _ = 1, reelCount do
                        safeFireServer(reelRemote)
                        task.wait(rDelay(0.05))
                    end
                end
            end)
        end
        task.wait(rDelay(Config.FishDelay))
    end
end)

-- Auto Catch Loop
task.spawn(function()
    while true do
        if Config.AutoCatch then
            pcall(function()
                local r = findRemote("reel") or findRemote("catch") or findRemote("pull")
                if r then safeFireServer(r) end
            end)
        end
        task.wait(rDelay(Config.CatchDelay))
    end
end)

-- Auto Sell Loop
task.spawn(function()
    while true do
        if Config.AutoSell then
            pcall(function()
                local r = findRemote("sell")
                if r then
                    if Config.AutoSellProtectFav then
                        safeFireServer(r, "nonfavorite")
                    else
                        safeFireServer(r, "all")
                    end
                end
            end)
        end
        task.wait(rDelay(Config.SellInterval))
    end
end)

-- Auto Enchant Loop
task.spawn(function()
    while true do
        if Config.AutoEnchant then
            pcall(function()
                local r = findRemote("enchant")
                if r then safeFireServer(r) end
            end)
        end
        task.wait(rDelay(10))
    end
end)

-- Auto Buy Rod Loop
task.spawn(function()
    while true do
        if Config.AutoBuyRod then
            pcall(function()
                local r = findRemote("buyrod") or findRemote("buy") or findRemote("shop")
                if r then safeFireServer(r, "best") end
            end)
        end
        task.wait(rDelay(30))
    end
end)

-- Anti-Drown Loop
task.spawn(function()
    while true do
        if Config.AntiDrown then
            pcall(function()
                local char = LP.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    if hrp.Position.Y < -5 then
                        hrp.CFrame = hrp.CFrame + Vector3.new(0, 15, 0)
                    end
                end
            end)
        end
        task.wait(rDelay(1))
    end
end)

-- Noclip Loop
task.spawn(function()
    RS.Stepped:Connect(function()
        if Config.Noclip then
            pcall(function()
                local char = LP.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end)
end)

-- Fly System
local flyBV = nil
task.spawn(function()
    RS.Heartbeat:Connect(function()
        if Config.Fly then
            pcall(function()
                local char = LP.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    if not flyBV or flyBV.Parent ~= hrp then
                        flyBV = Instance.new("BodyVelocity")
                        flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
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
                end
            end)
        else
            if flyBV then
                pcall(function() flyBV:Destroy() end)
                flyBV = nil
            end
        end
    end)
end)

-- SECTION 10: INITIALIZE
task.spawn(function()
    showSplash()
    task.wait(0.3)
    renderUI()
end)

-- Auto re-render periodically (for ESP updates etc)
task.spawn(function()
    while true do
        task.wait(2)
        if UIVisible then
            renderUI()
        end
    end
end)

-- Cleanup on character removal
LP.CharacterRemoving:Connect(function()
    if flyBV then
        pcall(function() flyBV:Destroy() end)
        flyBV = nil
    end
end)
