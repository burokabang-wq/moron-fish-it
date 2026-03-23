--[[
    Moron Fish It v6.0 - GasUp ID
    Clean UI | No Key | No HWID | Free
    Style: Atomic Hub inspired
]]

---------- CLEANUP ----------
for _,v in ipairs(game:GetService("Players").LocalPlayer.PlayerGui:GetChildren()) do
    if v:GetAttribute("_mfi") then v:Destroy() end
end

---------- SERVICES ----------
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local LP = Players.LocalPlayer
local PG = LP.PlayerGui

---------- CONFIG ----------
local CFG = {
    autoFish = false,
    blatant = false,
    instantMode = false,
    autoCatch = false,
    fishDelay = 0.8,
    catchDelay = 0.2,
    autoEnchant = false,
    autoBuyRod = false,
    autoBuyWeather = false,
    autoQuest = false,
    autoEvent = false,
    autoArtifact = false,
    autoSell = false,
    sellInterval = 60,
    autoFavorite = false,
    minRarity = "Legendary",
    walkSpeed = 16,
    jumpPower = 50,
    infJump = false,
    fly = false,
    noclip = false,
    antiAfk = false,
    antiDrown = false,
    gpuSaver = false,
    fpsBoost = false,
    fishEsp = false,
    playerEsp = false,
    webhook = "",
}

---------- UTILITY ----------
local function rnd(a,b) return a + math.random() * (b - a) end
local function safe(fn, ...)
    local args = {...}
    local ok, err = pcall(function() fn(unpack(args)) end)
    if not ok then warn("[MFI] " .. tostring(err)) end
end

local function findBtn(name)
    local gui = PG:FindFirstChild("ScreenGui") or PG:FindFirstChildWhichIsA("ScreenGui")
    if not gui then return nil end
    local function scan(p)
        for _,c in ipairs(p:GetChildren()) do
            if (c:IsA("TextButton") or c:IsA("ImageButton")) and c.Name:lower():find(name:lower()) then
                return c
            end
            local r = scan(c)
            if r then return r end
        end
        return nil
    end
    return scan(gui)
end

local function clickBtn(btn)
    if not btn then return end
    if typeof(firesignal) == "function" then
        for _,c in ipairs(getconnections(btn.Activated)) do safe(c.Fire, c) end
        for _,c in ipairs(getconnections(btn.MouseButton1Click)) do safe(c.Fire, c) end
    end
end

local function findRemote(name)
    local function scan(p)
        for _,c in ipairs(p:GetChildren()) do
            if (c:IsA("RemoteEvent") or c:IsA("RemoteFunction")) and c.Name:lower():find(name:lower()) then
                return c
            end
            local r = scan(c)
            if r then return r end
        end
        return nil
    end
    return scan(game:GetService("ReplicatedStorage"))
end

---------- SPLASH SCREEN ----------
local splash = Instance.new("ScreenGui")
splash.Name = "s" .. tostring(math.random(100000,999999))
splash:SetAttribute("_mfi", true)
splash.Parent = PG
splash.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
splash.IgnoreGuiInset = true

local splashBg = Instance.new("Frame", splash)
splashBg.Size = UDim2.new(1,0,1,0)
splashBg.BackgroundColor3 = Color3.fromRGB(0,0,0)
splashBg.BackgroundTransparency = 0.4
splashBg.BorderSizePixel = 0

local splashBox = Instance.new("Frame", splash)
splashBox.Size = UDim2.new(0,180,0,60)
splashBox.Position = UDim2.new(0.5,-90,0.5,-30)
splashBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
splashBox.BorderSizePixel = 0
Instance.new("UICorner", splashBox).CornerRadius = UDim.new(0,10)

local splashTitle = Instance.new("TextLabel", splashBox)
splashTitle.Size = UDim2.new(1,0,0,28)
splashTitle.Position = UDim2.new(0,0,0,8)
splashTitle.BackgroundTransparency = 1
splashTitle.Text = "GasUp ID"
splashTitle.TextColor3 = Color3.fromRGB(0,200,130)
splashTitle.TextSize = 18
splashTitle.Font = Enum.Font.GothamBold

local splashSub = Instance.new("TextLabel", splashBox)
splashSub.Size = UDim2.new(1,0,0,16)
splashSub.Position = UDim2.new(0,0,0,34)
splashSub.BackgroundTransparency = 1
splashSub.Text = "Moron Fish It v6.0"
splashSub.TextColor3 = Color3.fromRGB(160,160,160)
splashSub.TextSize = 11
splashSub.Font = Enum.Font.Gotham

local loadBar = Instance.new("Frame", splashBox)
loadBar.Size = UDim2.new(0,0,0,2)
loadBar.Position = UDim2.new(0,10,1,-6)
loadBar.BackgroundColor3 = Color3.fromRGB(0,200,130)
loadBar.BorderSizePixel = 0
Instance.new("UICorner", loadBar).CornerRadius = UDim.new(0,1)

TS:Create(loadBar, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0,160,0,2)}):Play()

task.delay(2, function()
    TS:Create(splashBg, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    TS:Create(splashBox, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    TS:Create(splashTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TS:Create(splashSub, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TS:Create(loadBar, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    task.delay(0.5, function() splash:Destroy() end)
end)

---------- MAIN UI ----------
task.delay(2.2, function()

local gui = Instance.new("ScreenGui")
gui.Name = "g" .. tostring(math.random(100000,999999))
gui:SetAttribute("_mfi", true)
gui.Parent = PG
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false

-- Main frame
local main = Instance.new("Frame", gui)
main.Name = "m"
main.Size = UDim2.new(0,420,0,310)
main.Position = UDim2.new(0.5,-210,0.5,-155)
main.BackgroundColor3 = Color3.fromRGB(25,25,28)
main.BorderSizePixel = 0
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

-- Subtle shadow
local shadow = Instance.new("ImageLabel", main)
shadow.Name = "sh"
shadow.Size = UDim2.new(1,20,1,20)
shadow.Position = UDim2.new(0,-10,0,-10)
shadow.BackgroundTransparency = 1
shadow.ImageTransparency = 0.6
shadow.Image = "rbxassetid://5554236805"
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(23,23,277,277)
shadow.ZIndex = 0

-- Top bar
local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1,0,0,36)
topBar.BackgroundColor3 = Color3.fromRGB(30,30,34)
topBar.BorderSizePixel = 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0,12)
-- Bottom cover for top bar rounded corners
local topCover = Instance.new("Frame", topBar)
topCover.Size = UDim2.new(1,0,0,12)
topCover.Position = UDim2.new(0,0,1,-12)
topCover.BackgroundColor3 = Color3.fromRGB(30,30,34)
topCover.BorderSizePixel = 0

-- Logo
local logo = Instance.new("TextLabel", topBar)
logo.Size = UDim2.new(0,100,1,0)
logo.Position = UDim2.new(0,12,0,0)
logo.BackgroundTransparency = 1
logo.Text = "Moron"
logo.TextColor3 = Color3.fromRGB(255,255,255)
logo.TextSize = 14
logo.Font = Enum.Font.GothamBold
logo.TextXAlignment = Enum.TextXAlignment.Left

local ver = Instance.new("TextLabel", topBar)
ver.Size = UDim2.new(0,60,1,0)
ver.Position = UDim2.new(0,62,0,0)
ver.BackgroundTransparency = 1
ver.Text = "v6.0"
ver.TextColor3 = Color3.fromRGB(100,100,110)
ver.TextSize = 11
ver.Font = Enum.Font.Gotham
ver.TextXAlignment = Enum.TextXAlignment.Left

-- Close button
local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0,30,0,30)
closeBtn.Position = UDim2.new(1,-33,0,3)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "x"
closeBtn.TextColor3 = Color3.fromRGB(120,120,130)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold

-- Sidebar
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0,110,1,-36)
sidebar.Position = UDim2.new(0,0,0,36)
sidebar.BackgroundColor3 = Color3.fromRGB(22,22,25)
sidebar.BorderSizePixel = 0

-- Sidebar separator
local sep = Instance.new("Frame", sidebar)
sep.Size = UDim2.new(0,1,1,-10)
sep.Position = UDim2.new(1,0,0,5)
sep.BackgroundColor3 = Color3.fromRGB(45,45,50)
sep.BorderSizePixel = 0

-- Content area
local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1,-112,1,-36)
content.Position = UDim2.new(0,112,0,36)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = Color3.fromRGB(60,60,65)
content.CanvasSize = UDim2.new(0,0,0,0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y

local contentLayout = Instance.new("UIListLayout", content)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Padding = UDim.new(0,2)

local contentPad = Instance.new("UIPadding", content)
contentPad.PaddingTop = UDim.new(0,8)
contentPad.PaddingLeft = UDim.new(0,12)
contentPad.PaddingRight = UDim.new(0,12)
contentPad.PaddingBottom = UDim.new(0,8)

-- Tab system
local tabs = {"Fishing","Selling","Teleport","Movement","Utility","Visuals","Settings"}
local tabBtns = {}
local currentTab = "Fishing"

local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Padding = UDim.new(0,1)

local sidePad = Instance.new("UIPadding", sidebar)
sidePad.PaddingTop = UDim.new(0,6)

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1,0,0,30)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. tabName
    btn.TextColor3 = Color3.fromRGB(140,140,150)
    btn.TextSize = 12
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = i

    local indicator = Instance.new("Frame", btn)
    indicator.Name = "ind"
    indicator.Size = UDim2.new(0,3,0,18)
    indicator.Position = UDim2.new(0,0,0.5,-9)
    indicator.BackgroundColor3 = Color3.fromRGB(0,200,130)
    indicator.BorderSizePixel = 0
    indicator.Visible = (i == 1)
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(0,2)

    tabBtns[tabName] = btn
end

-- Toggle component
local function makeToggle(parent, name, desc, key, order)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1,0,0,40)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,-60,0,18)
    lbl.Position = UDim2.new(0,0,0,4)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(220,220,225)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    if desc and desc ~= "" then
        local d = Instance.new("TextLabel", row)
        d.Size = UDim2.new(1,-60,0,14)
        d.Position = UDim2.new(0,0,0,22)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = Color3.fromRGB(90,90,100)
        d.TextSize = 10
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
    end

    -- Toggle track
    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(0,38,0,20)
    track.Position = UDim2.new(1,-42,0,10)
    track.BackgroundColor3 = CFG[key] and Color3.fromRGB(0,200,130) or Color3.fromRGB(55,55,60)
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0,16,0,16)
    knob.Position = CFG[key] and UDim2.new(1,-18,0,2) or UDim2.new(0,2,0,2)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local btn = Instance.new("TextButton", track)
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    btn.MouseButton1Click:Connect(function()
        CFG[key] = not CFG[key]
        local on = CFG[key]
        TS:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = on and Color3.fromRGB(0,200,130) or Color3.fromRGB(55,55,60)}):Play()
        TS:Create(knob, TweenInfo.new(0.2), {Position = on and UDim2.new(1,-18,0,2) or UDim2.new(0,2,0,2)}):Play()
    end)

    return row
end

-- Slider component
local function makeSlider(parent, name, key, mn, mx, step, order)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1,0,0,40)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.5,0,0,18)
    lbl.Position = UDim2.new(0,0,0,4)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(220,220,225)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local val = Instance.new("TextLabel", row)
    val.Size = UDim2.new(0.5,0,0,18)
    val.Position = UDim2.new(0.5,0,0,4)
    val.BackgroundTransparency = 1
    val.Text = tostring(CFG[key])
    val.TextColor3 = Color3.fromRGB(0,200,130)
    val.TextSize = 12
    val.Font = Enum.Font.GothamBold
    val.TextXAlignment = Enum.TextXAlignment.Right

    local trackBg = Instance.new("Frame", row)
    trackBg.Size = UDim2.new(1,0,0,4)
    trackBg.Position = UDim2.new(0,0,0,28)
    trackBg.BackgroundColor3 = Color3.fromRGB(45,45,50)
    trackBg.BorderSizePixel = 0
    Instance.new("UICorner", trackBg).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame", trackBg)
    local pct = (CFG[key] - mn) / (mx - mn)
    fill.Size = UDim2.new(pct,0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(0,200,130)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame", trackBg)
    knob.Size = UDim2.new(0,12,0,12)
    knob.Position = UDim2.new(pct,-6,-0.5,-4)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local hitArea = Instance.new("TextButton", trackBg)
    hitArea.Size = UDim2.new(1,0,1,16)
    hitArea.Position = UDim2.new(0,0,0,-8)
    hitArea.BackgroundTransparency = 1
    hitArea.Text = ""

    local dragging = false
    hitArea.MouseButton1Down:Connect(function() dragging = true end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local function updateSlider(inputPos)
        if not dragging then return end
        local abs = trackBg.AbsolutePosition.X
        local w = trackBg.AbsoluteSize.X
        local rel = math.clamp((inputPos.X - abs) / w, 0, 1)
        local raw = mn + rel * (mx - mn)
        local stepped = math.floor(raw / step + 0.5) * step
        stepped = math.clamp(stepped, mn, mx)
        CFG[key] = stepped
        local p = (stepped - mn) / (mx - mn)
        fill.Size = UDim2.new(p,0,1,0)
        knob.Position = UDim2.new(p,-6,-0.5,-4)
        val.Text = tostring(stepped)
    end

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position)
        end
    end)

    hitArea.MouseButton1Down:Connect(function()
        dragging = true
        local mouse = LP:GetMouse()
        updateSlider(Vector2.new(mouse.X, mouse.Y))
    end)

    return row
end

-- Section header
local function makeSection(parent, title, order)
    local hdr = Instance.new("Frame", parent)
    hdr.Size = UDim2.new(1,0,0,28)
    hdr.BackgroundTransparency = 1
    hdr.LayoutOrder = order

    local txt = Instance.new("TextLabel", hdr)
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.Text = title
    txt.TextColor3 = Color3.fromRGB(90,90,100)
    txt.TextSize = 11
    txt.Font = Enum.Font.GothamBold
    txt.TextXAlignment = Enum.TextXAlignment.Left
end

-- Button component
local function makeButton(parent, name, callback, order)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1,0,0,32)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,40)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200,200,210)
    btn.TextSize = 12
    btn.Font = Enum.Font.Gotham
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    btn.MouseButton1Click:Connect(function()
        safe(callback)
    end)
    return btn
end

-- Dropdown component
local function makeDropdown(parent, name, options, key, order)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1,0,0,36)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.5,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(220,220,225)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local ddBtn = Instance.new("TextButton", row)
    ddBtn.Size = UDim2.new(0.45,0,0,26)
    ddBtn.Position = UDim2.new(0.55,0,0,5)
    ddBtn.BackgroundColor3 = Color3.fromRGB(40,40,45)
    ddBtn.BorderSizePixel = 0
    ddBtn.Text = CFG[key]
    ddBtn.TextColor3 = Color3.fromRGB(0,200,130)
    ddBtn.TextSize = 11
    ddBtn.Font = Enum.Font.Gotham
    Instance.new("UICorner", ddBtn).CornerRadius = UDim.new(0,6)

    local idx = table.find(options, CFG[key]) or 1
    ddBtn.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        CFG[key] = options[idx]
        ddBtn.Text = options[idx]
    end)
end

---------- PAGE CONTENT ----------
local pages = {}

-- Build all pages
for _, tabName in ipairs(tabs) do
    local page = Instance.new("Frame", content)
    page.Name = tabName
    page.Size = UDim2.new(1,0,0,0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.Visible = (tabName == currentTab)

    local layout = Instance.new("UIListLayout", page)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,2)

    pages[tabName] = page
end

-- FISHING PAGE
do
    local p = pages["Fishing"]
    makeSection(p, "FISHING MODE", 1)
    makeToggle(p, "Auto Fish", "Automatically cast and reel fish", "autoFish", 2)
    makeToggle(p, "Blatant Mode", "Faster fishing speed", "blatant", 3)
    makeToggle(p, "Instant Mode", "Maximum speed fishing", "instantMode", 4)
    makeToggle(p, "Auto Catch", "Auto reel when fish bites", "autoCatch", 5)
    makeSection(p, "TIMING", 6)
    makeSlider(p, "Fish Delay", "fishDelay", 0.1, 5.0, 0.1, 7)
    makeSlider(p, "Catch Delay", "catchDelay", 0.1, 3.0, 0.1, 8)
    makeSection(p, "AUTOMATION", 9)
    makeToggle(p, "Auto Enchant", "Enchant rod automatically", "autoEnchant", 10)
    makeToggle(p, "Auto Buy Best Rod", "Buy best affordable rod", "autoBuyRod", 11)
    makeToggle(p, "Auto Buy Weather", "Buy weather for rare fish", "autoBuyWeather", 12)
    makeToggle(p, "Auto Quest", "Accept and complete quests", "autoQuest", 13)
    makeToggle(p, "Auto Event", "Teleport to active events", "autoEvent", 14)
    makeToggle(p, "Auto Artifact", "Find and collect artifacts", "autoArtifact", 15)
end

-- SELLING PAGE
do
    local p = pages["Selling"]
    makeSection(p, "AUTO SELL", 1)
    makeToggle(p, "Auto Sell", "Sell fish at intervals", "autoSell", 2)
    makeSlider(p, "Sell Interval (s)", "sellInterval", 10, 300, 5, 3)
    makeButton(p, "Sell All Now", function()
        local r = findRemote("sell")
        if r then safe(r.FireServer, r) end
    end, 4)
    makeSection(p, "FAVORITES", 5)
    makeToggle(p, "Auto Favorite", "Favorite rare fish", "autoFavorite", 6)
    makeDropdown(p, "Min Rarity", {"Legendary","Mythic","Secret"}, "minRarity", 7)
end

-- TELEPORT PAGE
do
    local p = pages["Teleport"]
    makeSection(p, "ISLANDS", 1)
    local islands = {"Spawn","Coral Reefs","Crater Island","Lost Isle","Tropical Grove","Mount Hallow","Kohana","Ancient Jungle","Sacred Temple","Crystal Cavern","Underwater City","Forgotten Shore"}
    for i, name in ipairs(islands) do
        makeButton(p, name, function()
            -- Smooth teleport via TweenService
            local char = LP.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            -- Try to find the location in workspace
            local dest = workspace:FindFirstChild(name)
            if dest then
                local target = dest:IsA("BasePart") and dest.Position or dest:GetModelCFrame().Position
                local info = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                TS:Create(hrp, info, {CFrame = CFrame.new(target + Vector3.new(0,5,0))}):Play()
            end
        end, i + 1)
    end
end

-- MOVEMENT PAGE
do
    local p = pages["Movement"]
    makeSection(p, "MOVEMENT", 1)
    makeSlider(p, "Walk Speed", "walkSpeed", 16, 200, 1, 2)
    makeSlider(p, "Jump Power", "jumpPower", 50, 300, 5, 3)
    makeToggle(p, "Infinite Jump", "Jump unlimited in air", "infJump", 4)
    makeToggle(p, "Character Fly", "Fly freely with controls", "fly", 5)
    makeToggle(p, "Noclip", "Pass through walls", "noclip", 6)
    makeToggle(p, "Anti Drown", "Auto resurface when drowning", "antiDrown", 7)
end

-- UTILITY PAGE
do
    local p = pages["Utility"]
    makeSection(p, "PROTECTION", 1)
    makeToggle(p, "Anti-AFK", "Prevent idle kick", "antiAfk", 2)
    makeSection(p, "PERFORMANCE", 3)
    makeToggle(p, "GPU Saver", "Reduce graphics for AFK", "gpuSaver", 4)
    makeToggle(p, "FPS Boost", "Remove particles and effects", "fpsBoost", 5)
    makeSection(p, "SERVER", 6)
    makeButton(p, "Server Hop", function()
        local servers = game.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        for _,s in ipairs(servers.data or {}) do
            if s.id ~= game.JobId and s.playing < s.maxPlayers then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, LP)
                break
            end
        end
    end, 7)
    makeButton(p, "Rejoin Server", function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
    end, 8)
end

-- VISUALS PAGE
do
    local p = pages["Visuals"]
    makeSection(p, "ESP", 1)
    makeToggle(p, "Fish ESP", "Show fish locations", "fishEsp", 2)
    makeToggle(p, "Player ESP", "Show player names", "playerEsp", 3)
end

-- SETTINGS PAGE
do
    local p = pages["Settings"]
    makeSection(p, "INFO", 1)

    local info = Instance.new("TextLabel", p)
    info.Size = UDim2.new(1,0,0,60)
    info.BackgroundTransparency = 1
    info.Text = "Moron Fish It v6.0\nby GasUp ID\nNo Key | No HWID | Free"
    info.TextColor3 = Color3.fromRGB(120,120,130)
    info.TextSize = 11
    info.Font = Enum.Font.Gotham
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.LayoutOrder = 2
end

---------- TAB SWITCHING ----------
local function switchTab(tabName)
    currentTab = tabName
    for name, btn in pairs(tabBtns) do
        local active = (name == tabName)
        btn.TextColor3 = active and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,140,150)
        btn.Font = active and Enum.Font.GothamBold or Enum.Font.Gotham
        local ind = btn:FindFirstChild("ind")
        if ind then ind.Visible = active end
    end
    for name, page in pairs(pages) do
        page.Visible = (name == tabName)
    end
    content.CanvasPosition = Vector2.new(0,0)
end

for name, btn in pairs(tabBtns) do
    btn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
end
switchTab("Fishing")

---------- DRAGGING ----------
local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

---------- FLOATING BUTTON ----------
local floatBtn = Instance.new("TextButton", gui)
floatBtn.Size = UDim2.new(0,36,0,36)
floatBtn.Position = UDim2.new(0,10,0.5,-18)
floatBtn.BackgroundColor3 = Color3.fromRGB(30,30,34)
floatBtn.BorderSizePixel = 0
floatBtn.Text = "M"
floatBtn.TextColor3 = Color3.fromRGB(0,200,130)
floatBtn.TextSize = 16
floatBtn.Font = Enum.Font.GothamBold
floatBtn.Visible = false
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(0,10)

---------- SHOW/HIDE ----------
local uiVisible = true
local function toggleUI()
    uiVisible = not uiVisible
    main.Visible = uiVisible
    floatBtn.Visible = not uiVisible
end

closeBtn.MouseButton1Click:Connect(toggleUI)
floatBtn.MouseButton1Click:Connect(toggleUI)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        toggleUI()
    end
end)

---------- FEATURE LOOPS ----------

-- Auto Fish
task.spawn(function()
    while task.wait(0.1) do
        if CFG.autoFish then
            safe(function()
                local castBtn = findBtn("cast") or findBtn("throw") or findBtn("fish")
                if castBtn and castBtn.Visible then
                    clickBtn(castBtn)
                end
            end)
            task.wait(rnd(CFG.fishDelay * 0.85, CFG.fishDelay * 1.15))
        end
    end
end)

-- Auto Catch
task.spawn(function()
    while task.wait(0.1) do
        if CFG.autoCatch or CFG.autoFish then
            safe(function()
                local reelBtn = findBtn("reel") or findBtn("catch") or findBtn("pull")
                if reelBtn and reelBtn.Visible then
                    clickBtn(reelBtn)
                end
            end)
            task.wait(rnd(CFG.catchDelay * 0.85, CFG.catchDelay * 1.15))
        end
    end
end)

-- Auto Sell
task.spawn(function()
    while task.wait(1) do
        if CFG.autoSell then
            task.wait(rnd(CFG.sellInterval * 0.9, CFG.sellInterval * 1.1))
            safe(function()
                local r = findRemote("sell")
                if r then r:FireServer() end
            end)
        end
    end
end)

-- Movement
task.spawn(function()
    while task.wait(0.5) do
        safe(function()
            local char = LP.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            if CFG.walkSpeed ~= 16 then hum.WalkSpeed = CFG.walkSpeed end
            if CFG.jumpPower ~= 50 then hum.JumpPower = CFG.jumpPower end
        end)
    end
end)

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    if CFG.infJump then
        safe(function()
            local char = LP.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
end)

-- Noclip
task.spawn(function()
    RS.Stepped:Connect(function()
        if CFG.noclip then
            safe(function()
                local char = LP.Character
                if not char then return end
                for _,p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end)
        end
    end)
end)

-- Anti-AFK
task.spawn(function()
    while task.wait(60) do
        if CFG.antiAfk then
            safe(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- Anti-Drown
task.spawn(function()
    while task.wait(0.5) do
        if CFG.antiDrown then
            safe(function()
                local char = LP.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Position.Y < -5 then
                    local target = CFrame.new(hrp.Position.X, 10, hrp.Position.Z)
                    TS:Create(hrp, TweenInfo.new(1, Enum.EasingStyle.Quad), {CFrame = target}):Play()
                end
            end)
        end
    end
end)

-- GPU Saver
task.spawn(function()
    while task.wait(5) do
        if CFG.gpuSaver then
            safe(function()
                local l = game:GetService("Lighting")
                l.GlobalShadows = false
                l.FogEnd = 1000
                for _,v in ipairs(l:GetDescendants()) do
                    if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") then
                        v.Enabled = false
                    end
                end
            end)
        end
    end
end)

-- FPS Boost
task.spawn(function()
    while task.wait(10) do
        if CFG.fpsBoost then
            safe(function()
                for _,v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                        v.Enabled = false
                    end
                end
            end)
        end
    end
end)

-- Fish ESP
task.spawn(function()
    local espParts = {}
    while task.wait(2) do
        -- Cleanup old
        for _,v in ipairs(espParts) do
            if v and v.Parent then v:Destroy() end
        end
        espParts = {}

        if CFG.fishEsp then
            safe(function()
                local fishFolder = workspace:FindFirstChild("Fish") or workspace:FindFirstChild("Fishes")
                if not fishFolder then return end
                for _,fish in ipairs(fishFolder:GetChildren()) do
                    if fish:IsA("Model") or fish:IsA("BasePart") then
                        local bb = Instance.new("BillboardGui")
                        bb.Size = UDim2.new(0,80,0,20)
                        bb.StudsOffset = Vector3.new(0,3,0)
                        bb.AlwaysOnTop = true
                        bb.Adornee = fish:IsA("Model") and fish.PrimaryPart or fish
                        bb.Parent = fish

                        local txt = Instance.new("TextLabel", bb)
                        txt.Size = UDim2.new(1,0,1,0)
                        txt.BackgroundTransparency = 1
                        txt.Text = fish.Name
                        txt.TextColor3 = Color3.fromRGB(0,255,180)
                        txt.TextSize = 12
                        txt.Font = Enum.Font.GothamBold
                        txt.TextStrokeTransparency = 0.5

                        table.insert(espParts, bb)
                    end
                end
            end)
        end
    end
end)

-- Player ESP
task.spawn(function()
    local espParts = {}
    while task.wait(3) do
        for _,v in ipairs(espParts) do
            if v and v.Parent then v:Destroy() end
        end
        espParts = {}

        if CFG.playerEsp then
            safe(function()
                for _,plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LP and plr.Character then
                        local head = plr.Character:FindFirstChild("Head")
                        if head then
                            local bb = Instance.new("BillboardGui")
                            bb.Size = UDim2.new(0,100,0,20)
                            bb.StudsOffset = Vector3.new(0,3,0)
                            bb.AlwaysOnTop = true
                            bb.Adornee = head
                            bb.Parent = head

                            local txt = Instance.new("TextLabel", bb)
                            txt.Size = UDim2.new(1,0,1,0)
                            txt.BackgroundTransparency = 1
                            txt.Text = plr.Name
                            txt.TextColor3 = Color3.fromRGB(255,255,100)
                            txt.TextSize = 12
                            txt.Font = Enum.Font.GothamBold
                            txt.TextStrokeTransparency = 0.5

                            table.insert(espParts, bb)
                        end
                    end
                end
            end)
        end
    end
end)

-- Fly
task.spawn(function()
    local flyBV, flyBG
    while task.wait(0.1) do
        safe(function()
            local char = LP.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            if CFG.fly then
                if not flyBV then
                    flyBV = Instance.new("BodyVelocity", hrp)
                    flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    flyBV.Velocity = Vector3.new(0,0,0)
                    flyBG = Instance.new("BodyGyro", hrp)
                    flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                end
                local cam = workspace.CurrentCamera
                local dir = Vector3.new(0,0,0)
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
                flyBV.Velocity = dir * 60
                flyBG.CFrame = cam.CFrame
            else
                if flyBV then flyBV:Destroy() flyBV = nil end
                if flyBG then flyBG:Destroy() flyBG = nil end
            end
        end)
    end
end)

end) -- end task.delay for main UI
