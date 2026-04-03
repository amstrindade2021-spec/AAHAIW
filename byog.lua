if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local LOBBY = 116495829188952
local GAME = 70876832253163

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local HRP = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(c)
    character = c
    HRP = c:WaitForChild("HumanoidRootPart")
    humanoid = c:WaitForChild("Humanoid")
end)

local Alive = true

local function safeDestroy(obj)
    pcall(function() if obj then obj:Destroy() end end)
end

local function tw(obj, props, t, style, dir)
    local ti = TweenInfo.new(t or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, ti, props)
    tween:Play()
    return tween
end

local function mkCorner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = obj
    return c
end

local function mkStroke(obj, thickness, color, transparency)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness or 1
    s.Color = color or Color3.fromRGB(255, 255, 255)
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end

local function mkGradient(obj, points, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(points)
    g.Rotation = rotation or 0
    g.Parent = obj
    return g
end

local function mkShadow(obj, size, transparency)
    local s = Instance.new("ImageLabel")
    s.Name = "Shadow"
    s.AnchorPoint = Vector2.new(0.5, 0.5)
    s.Size = UDim2.new(1, size or 40, 1, size or 40)
    s.Position = UDim2.new(0.5, 0, 0.5, 0)
    s.BackgroundTransparency = 1
    s.Image = "rbxassetid://131604521396804"
    s.ImageColor3 = Color3.fromRGB(0, 0, 0)
    s.ImageTransparency = transparency or 0.6
    s.ScaleType = Enum.ScaleType.Slice
    s.SliceCenter = Rect.new(50, 50, 50, 50)
    s.ZIndex = obj.ZIndex - 1
    s.Parent = obj
    return s
end

local function mkLabel(parent, text, size, font, color, alignX, alignY)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel = 0
    l.Text = text or ""
    l.TextSize = size or 14
    l.Font = font or Enum.Font.Gotham
    l.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    l.TextXAlignment = alignX or Enum.TextXAlignment.Left
    l.TextYAlignment = alignY or Enum.TextYAlignment.Center
    l.Parent = parent
    return l
end

local function mkButton(parent, text, bg, tc, fontSize)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.BackgroundColor3 = bg
    b.BorderSizePixel = 0
    b.Text = text
    b.TextSize = fontSize or 13
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = tc
    b.Parent = parent
    mkCorner(b, 10)
    return b
end

local function brighten(c, a)
    return Color3.new(
        math.clamp(c.R + a, 0, 1),
        math.clamp(c.G + a, 0, 1),
        math.clamp(c.B + a, 0, 1)
    )
end

local G = {
    running = false,
    mode = nil,
    bonds = 0,
    wins = 0,
    runs = 0,
    t0 = tick(),
    bpmBase = 0,
    bpmTick = tick(),
    bpm = 0,
    page = "farm",
    structuresFound = 0,
    currentStructure = nil,
    isCollecting = false
}

local Settings = {
    antiAfk = true,
    animations = true,
    autoCollect = true,
    fastMode = false
}

local CollectRemote = nil
local Items = Workspace

task.spawn(function()
    local pkg = ReplicatedStorage:WaitForChild("Packages", 20)
    if pkg then
        CollectRemote = pkg:FindFirstChild("ActivateObjectClient")
        if not CollectRemote then
            for _, v in ipairs(pkg:GetDescendants()) do
                if v:IsA("RemoteEvent") then
                    local n = v.Name:lower()
                    if n:find("activat") or n:find("collect") or n:find("object") then
                        CollectRemote = v
                        break
                    end
                end
            end
        end
    end
    if not CollectRemote then
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                local n = v.Name:lower()
                if n:find("activat") or n:find("collect") then
                    CollectRemote = v
                    break
                end
            end
        end
    end
end)

task.spawn(function()
    local ok, r = pcall(function()
        return Workspace:WaitForChild("RuntimeItems", 30)
    end)
    if ok and r then Items = r end
end)

if CoreGui:FindFirstChild("__OG9_UI") then
    CoreGui.__OG9_UI:Destroy()
end
local oldBlur = Lighting:FindFirstChild("__OG9_BLUR")
if oldBlur then oldBlur:Destroy() end

local sg = Instance.new("ScreenGui")
sg.Name = "__OG9_UI"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.IgnoreGuiInset = true
sg.Parent = CoreGui

local blur = Instance.new("BlurEffect")
blur.Name = "__OG9_BLUR"
blur.Size = 0
blur.Parent = Lighting
tw(blur, {Size = 18}, 0.4)

local loading = Instance.new("Frame")
loading.Size = UDim2.new(1, 0, 1, 0)
loading.BackgroundColor3 = Color3.fromRGB(2, 3, 8)
loading.BorderSizePixel = 0
loading.ZIndex = 200
loading.Parent = sg

mkGradient(loading, {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(4, 5, 12)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 6, 18)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(3, 4, 10)),
}, 45)

local glow1 = Instance.new("Frame")
glow1.Size = UDim2.new(0, 400, 0, 400)
glow1.Position = UDim2.new(0.25, 0, 0.28, 0)
glow1.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
glow1.BackgroundTransparency = 0.92
glow1.BorderSizePixel = 0
glow1.ZIndex = 201
glow1.Parent = loading
mkCorner(glow1, 999)

local glow2 = Instance.new("Frame")
glow2.Size = UDim2.new(0, 320, 0, 320)
glow2.Position = UDim2.new(0.75, 0, 0.62, 0)
glow2.BackgroundColor3 = Color3.fromRGB(140, 50, 255)
glow2.BackgroundTransparency = 0.94
glow2.BorderSizePixel = 0
glow2.ZIndex = 201
glow2.Parent = loading
mkCorner(glow2, 999)

local glow3 = Instance.new("Frame")
glow3.Size = UDim2.new(0, 260, 0, 260)
glow3.Position = UDim2.new(0.52, 0, 0.34, 0)
glow3.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
glow3.BackgroundTransparency = 0.95
glow3.BorderSizePixel = 0
glow3.ZIndex = 201
glow3.Parent = loading
mkCorner(glow3, 999)

local loadCard = Instance.new("Frame")
loadCard.AnchorPoint = Vector2.new(0.5, 0.5)
loadCard.Size = UDim2.new(0, 480, 0, 240)
loadCard.Position = UDim2.new(0.5, 0, 0.5, 0)
loadCard.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
loadCard.BackgroundTransparency = 0.02
loadCard.BorderSizePixel = 0
loadCard.ZIndex = 205
loadCard.Parent = loading
mkCorner(loadCard, 24)

local loadStroke = mkStroke(loadCard, 2, Color3.fromRGB(36, 40, 58), 0)
local loadStrokeGrad = mkGradient(loadStroke, {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 180, 0)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 85, 0)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(130, 45, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255)),
}, 0)

local loadAccent = Instance.new("Frame")
loadAccent.Size = UDim2.new(0, 56, 0, 3)
loadAccent.Position = UDim2.new(0, 24, 0, 0)
loadAccent.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
loadAccent.BorderSizePixel = 0
loadAccent.ZIndex = 206
loadAccent.Parent = loadCard
mkCorner(loadAccent, 999)
mkGradient(loadAccent, {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 180, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 85, 0)),
}, 0)

local loadTitle = mkLabel(loadCard, "OGART PREMIUM", 26, Enum.Font.GothamBlack, Color3.fromRGB(250, 235, 200))
loadTitle.Size = UDim2.new(1, -48, 0, 32)
loadTitle.Position = UDim2.new(0, 24, 0, 22)
loadTitle.ZIndex = 206

local loadSub = mkLabel(loadCard, "Inicializando sistema premium...", 12, Enum.Font.GothamMedium, Color3.fromRGB(130, 138, 175))
loadSub.Size = UDim2.new(1, -48, 0, 20)
loadSub.Position = UDim2.new(0, 24, 0, 58)
loadSub.ZIndex = 206

local tagFrame = Instance.new("Frame")
tagFrame.Size = UDim2.new(0, 90, 0, 26)
tagFrame.Position = UDim2.new(0, 24, 0, 92)
tagFrame.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
tagFrame.BorderSizePixel = 0
tagFrame.ZIndex = 206
tagFrame.Parent = loadCard
mkCorner(tagFrame, 999)

local tagTxt = mkLabel(tagFrame, "v9.0 ULTRA", 11, Enum.Font.GothamBlack, Color3.fromRGB(8, 8, 14), Enum.TextXAlignment.Center)
tagTxt.Size = UDim2.new(1, 0, 1, 0)
tagTxt.ZIndex = 207

local loadHint = mkLabel(loadCard, "Carregando módulos...", 11, Enum.Font.Gotham, Color3.fromRGB(95, 102, 140))
loadHint.Size = UDim2.new(1, -48, 0, 18)
loadHint.Position = UDim2.new(0, 24, 1, -88)
loadHint.ZIndex = 206

local loadPerc = mkLabel(loadCard, "0%", 12, Enum.Font.GothamBlack, Color3.fromRGB(255, 210, 130), Enum.TextXAlignment.Right)
loadPerc.Size = UDim2.new(1, -48, 0, 18)
loadPerc.Position = UDim2.new(0, 24, 1, -68)
loadPerc.ZIndex = 206

local loadBarBack = Instance.new("Frame")
loadBarBack.Size = UDim2.new(1, -48, 0, 12)
loadBarBack.Position = UDim2.new(0, 24, 1, -46)
loadBarBack.BackgroundColor3 = Color3.fromRGB(16, 18, 30)
loadBarBack.BorderSizePixel = 0
loadBarBack.ZIndex = 206
loadBarBack.Parent = loadCard
mkCorner(loadBarBack, 999)

local loadBar = Instance.new("Frame")
loadBar.Size = UDim2.new(0, 0, 1, 0)
loadBar.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
loadBar.BorderSizePixel = 0
loadBar.ZIndex = 207
loadBar.Parent = loadBarBack
mkCorner(loadBar, 999)

local loadBarGrad = mkGradient(loadBar, {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 0)),
    ColorSequenceKeypoint.new(0.35, Color3.fromRGB(255, 95, 0)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(140, 55, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255)),
}, 0)

local function setLoadProgress(p, text)
    p = math.clamp(p, 0, 1)
    tw(loadBar, {Size = UDim2.new(p, 0, 1, 0)}, 0.25)
    loadPerc.Text = string.format("%d%%", math.floor(p * 100))
    if text then loadHint.Text = text end
end

task.spawn(function()
    local r = 0
    while loading and loading.Parent do
        task.wait(0.016)
        r = (r + 1.2) % 360
        loadStrokeGrad.Rotation = r
        loadBarGrad.Rotation = -r
    end
end)

setLoadProgress(0.08, "Inicializando core...")
task.wait(0.1)
setLoadProgress(0.22, "Detectando remotes...")
task.wait(0.12)
setLoadProgress(0.40, "Carregando algoritmos...")
task.wait(0.12)
setLoadProgress(0.58, "Montando interface...")
task.wait(0.14)
setLoadProgress(0.76, "Renderizando UI...")
task.wait(0.14)
setLoadProgress(0.92, "Finalizando...")
task.wait(0.16)
setLoadProgress(1, "Pronto!")
task.wait(0.18)

local W, H = 500, 580

local window = Instance.new("Frame")
window.Name = "OGWindow"
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Size = UDim2.new(0, W, 0, H)
window.Position = UDim2.new(0.5, 0, 0.5, 0)
window.BackgroundColor3 = Color3.fromRGB(6, 7, 14)
window.BackgroundTransparency = 0.01
window.BorderSizePixel = 0
window.ClipsDescendants = true
window.Visible = false
window.Parent = sg
mkCorner(window, 24)
mkShadow(window, 50, 0.55)

local winStroke = mkStroke(window, 1.5, Color3.fromRGB(26, 28, 44), 0)
local winStrokeGrad = mkGradient(winStroke, {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 0)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 80, 0)),
    ColorSequenceKeypoint.new(0.55, Color3.fromRGB(130, 45, 255)),
    ColorSequenceKeypoint.new(0.82, Color3.fromRGB(0, 195, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 170, 0)),
}, 0)

mkGradient(window, {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(7, 8, 16)),
    ColorSequenceKeypoint.new(0.55, Color3.fromRGB(9, 7, 18)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 6, 12)),
}, 110)

local bgGlow1 = Instance.new("Frame")
bgGlow1.Size = UDim2.new(0, 220, 0, 220)
bgGlow1.Position = UDim2.new(0.12, 0, 0.1, 0)
bgGlow1.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
bgGlow1.BackgroundTransparency = 0.96
bgGlow1.BorderSizePixel = 0
bgGlow1.ZIndex = 0
bgGlow1.Parent = window
mkCorner(bgGlow1, 999)

local bgGlow2 = Instance.new("Frame")
bgGlow2.Size = UDim2.new(0, 200, 0, 200)
bgGlow2.Position = UDim2.new(0.88, 0, 0.14, 0)
bgGlow2.BackgroundColor3 = Color3.fromRGB(120, 40, 255)
bgGlow2.BackgroundTransparency = 0.97
bgGlow2.BorderSizePixel = 0
bgGlow2.ZIndex = 0
bgGlow2.Parent = window
mkCorner(bgGlow2, 999)

local bgGlow3 = Instance.new("Frame")
bgGlow3.Size = UDim2.new(0, 180, 0, 180)
bgGlow3.Position = UDim2.new(0.76, 0, 0.88, 0)
bgGlow3.BackgroundColor3 = Color3.fromRGB(0, 190, 255)
bgGlow3.BackgroundTransparency = 0.97
bgGlow3.BorderSizePixel = 0
bgGlow3.ZIndex = 0
bgGlow3.Parent = window
mkCorner(bgGlow3, 999)

for i = 1, 16 do
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
    p.Position = UDim2.new(math.random(), 0, math.random(), 0)
    p.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    p.BackgroundTransparency = 0.97
    p.BorderSizePixel = 0
    p.ZIndex = 0
    p.Parent = window
    mkCorner(p, 999)
end

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, -20, 0, 64)
header.Position = UDim2.new(0, 10, 0, 10)
header.BackgroundColor3 = Color3.fromRGB(10, 12, 22)
header.BackgroundTransparency = 0.01
header.BorderSizePixel = 0
header.ZIndex = 2
header.Parent = window
mkCorner(header, 18)
mkStroke(header, 1, Color3.fromRGB(20, 22, 36), 0)

local headerAccent = Instance.new("Frame")
headerAccent.Size = UDim2.new(0, 42, 0, 2)
headerAccent.Position = UDim2.new(0, 16, 1, -1)
headerAccent.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
headerAccent.BorderSizePixel = 0
headerAccent.ZIndex = 3
headerAccent.Parent = header
mkCorner(headerAccent, 999)
mkGradient(headerAccent, {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 0)),
}, 0)

local logoBadge = Instance.new("Frame")
logoBadge.Size = UDim2.new(0, 42, 0, 42)
logoBadge.Position = UDim2.new(0, 14, 0.5, -21)
logoBadge.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
logoBadge.BorderSizePixel = 0
logoBadge.ZIndex = 3
logoBadge.Parent = header
mkCorner(logoBadge, 14)
mkGradient(logoBadge, {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 190, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(225, 130, 0)),
}, 135)

local logoTxt = mkLabel(logoBadge, "OG", 16, Enum.Font.GothamBlack, Color3.fromRGB(8, 8, 12), Enum.TextXAlignment.Center)
logoTxt.Size = UDim2.new(1, 0, 1, 0)
logoTxt.ZIndex = 4

local winTitle = mkLabel(header, "OGART  ·  DEAD RAILS", 16, Enum.Font.GothamBlack, Color3.fromRGB(248, 232, 205))
winTitle.Size = UDim2.new(0, 240, 0, 22)
winTitle.Position = UDim2.new(0, 64, 0, 10)
winTitle.ZIndex = 3

local winSub = mkLabel(header, "Ultra Edition v9.0  —  Auto Farm Suite", 11, Enum.Font.GothamMedium, Color3.fromRGB(105, 112, 150))
winSub.Size = UDim2.new(0, 260, 0, 18)
winSub.Position = UDim2.new(0, 64, 0, 32)
winSub.ZIndex = 3

local premPill = Instance.new("Frame")
premPill.Size = UDim2.new(0, 78, 0, 22)
premPill.Position = UDim2.new(1, -174, 0.5, -11)
premPill.BackgroundColor3 = Color3.fromRGB(14, 15, 26)
premPill.BorderSizePixel = 0
premPill.ZIndex = 3
premPill.Parent = header
mkCorner(premPill, 999)
mkStroke(premPill, 1, Color3.fromRGB(255, 170, 0), 0.45)

local premTxt = mkLabel(premPill, "ULTRA", 10, Enum.Font.GothamBlack, Color3.fromRGB(255, 180, 70), Enum.TextXAlignment.Center)
premTxt.Size = UDim2.new(1, 0, 1, 0)
premTxt.ZIndex = 4

local minBtn = mkButton(header, "−", Color3.fromRGB(16, 18, 30), Color3.fromRGB(135, 142, 175))
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -72, 0.5, -15)
minBtn.ZIndex = 3

local closeBtn = mkButton(header, "✕", Color3.fromRGB(125, 20, 26), Color3.fromRGB(255, 240, 245))
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -36, 0.5, -15)
closeBtn.ZIndex = 3

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -20, 0, 38)
tabBar.Position = UDim2.new(0, 10, 0, 78)
tabBar.BackgroundColor3 = Color3.fromRGB(9, 11, 20)
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 2
tabBar.Parent = window
mkCorner(tabBar, 14)
mkStroke(tabBar, 1, Color3.fromRGB(18, 20, 34), 0)

local tabList = Instance.new("UIListLayout")
tabList.FillDirection = Enum.FillDirection.Horizontal
tabList.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabList.VerticalAlignment = Enum.VerticalAlignment.Center
tabList.Padding = UDim.new(0, 6)
tabList.Parent = tabBar

local tabPad = Instance.new("UIPadding")
tabPad.PaddingLeft = UDim.new(0, 8)
tabPad.PaddingRight = UDim.new(0, 8)
tabPad.Parent = tabBar

local pages = {}
local tabRefs = {}

local pageHolder = Instance.new("Frame")
pageHolder.Size = UDim2.new(1, -20, 1, -130)
pageHolder.Position = UDim2.new(0, 10, 0, 120)
pageHolder.BackgroundTransparency = 1
pageHolder.ClipsDescendants = true
pageHolder.ZIndex = 1
pageHolder.Parent = window

local function newPage(id)
    local p = Instance.new("Frame")
    p.Name = id
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.Parent = pageHolder
    pages[id] = p
    return p
end

local function switchPage(id)
    G.page = id
    for n, p in pairs(pages) do
        p.Visible = (n == id)
    end
    for n, t in pairs(tabRefs) do
        local active = (n == id)
        tw(t.bg, {BackgroundColor3 = active and Color3.fromRGB(16, 18, 32) or Color3.fromRGB(9, 11, 20)}, 0.15)
        tw(t.accentBar, {BackgroundTransparency = active and 0 or 1}, 0.15)
        t.lbl.TextColor3 = active and Color3.fromRGB(248, 232, 205) or Color3.fromRGB(100, 108, 145)
        t.lbl.Font = active and Enum.Font.GothamBold or Enum.Font.GothamMedium
    end
end

local function makeTab(id, ico, label)
    local btn = Instance.new("Frame")
    btn.Size = UDim2.new(0, 0, 0, 28)
    btn.AutomaticSize = Enum.AutomaticSize.X
    btn.BackgroundColor3 = Color3.fromRGB(9, 11, 20)
    btn.BorderSizePixel = 0
    btn.ZIndex = 3
    btn.Parent = tabBar
    mkCorner(btn, 10)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.Parent = btn

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(1, -18, 0, 2)
    accentBar.Position = UDim2.new(0, 9, 1, -2)
    accentBar.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    accentBar.BackgroundTransparency = 1
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 4
    accentBar.Parent = btn
    mkCorner(accentBar, 999)

    local lbl = mkLabel(btn, ico .. "  " .. label, 12, Enum.Font.GothamMedium, Color3.fromRGB(100, 108, 145), Enum.TextXAlignment.Center)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.ZIndex = 4

    local hit = Instance.new("TextButton")
    hit.Size = UDim2.new(1, 0, 1, 0)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.ZIndex = 5
    hit.Parent = btn

    hit.MouseButton1Click:Connect(function() switchPage(id) end)
    hit.MouseEnter:Connect(function()
        if G.page ~= id then
            tw(btn, {BackgroundColor3 = Color3.fromRGB(12, 14, 26)}, 0.1)
        end
    end)
    hit.MouseLeave:Connect(function()
        if G.page ~= id then
            tw(btn, {BackgroundColor3 = Color3.fromRGB(9, 11, 20)}, 0.1)
        end
    end)

    tabRefs[id] = {bg = btn, accentBar = accentBar, lbl = lbl}
end

makeTab("farm", "⚡", "Farm")
makeTab("stats", "📊", "Stats")
makeTab("settings", "⚙", "Config")

local watermark = Instance.new("Frame")
watermark.Size = UDim2.new(0, 200, 0, 32)
watermark.Position = UDim2.new(1, -210, 0, 12)
watermark.BackgroundColor3 = Color3.fromRGB(7, 8, 16)
watermark.BackgroundTransparency = 0.06
watermark.BorderSizePixel = 0
watermark.Parent = sg
mkCorner(watermark, 12)
mkStroke(watermark, 1, Color3.fromRGB(26, 28, 44), 0)
mkShadow(watermark, 20, 0.7)

local wmDot = Instance.new("Frame")
wmDot.Size = UDim2.new(0, 7, 0, 7)
wmDot.Position = UDim2.new(0, 12, 0.5, -4)
wmDot.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
wmDot.BorderSizePixel = 0
wmDot.Parent = watermark
mkCorner(wmDot, 999)

local wmLbl = mkLabel(watermark, "OGART ULTRA  ·  RightCtrl", 10, Enum.Font.GothamBlack, Color3.fromRGB(225, 230, 245))
wmLbl.Size = UDim2.new(1, -26, 1, 0)
wmLbl.Position = UDim2.new(0, 22, 0, 0)

local farmPage = newPage("farm")
local statsPage = newPage("stats")
local settingsPage = newPage("settings")

local function sectionLbl(parent, y, txt)
    local l = mkLabel(parent, txt, 10, Enum.Font.GothamBlack, Color3.fromRGB(72, 78, 110))
    l.Size = UDim2.new(1, 0, 0, 16)
    l.Position = UDim2.new(0, 4, 0, y)
    return l
end

local function divLine(parent, y)
    local d = Instance.new("Frame")
    d.Size = UDim2.new(1, 0, 0, 1)
    d.Position = UDim2.new(0, 0, 0, y)
    d.BackgroundColor3 = Color3.fromRGB(16, 18, 30)
    d.BorderSizePixel = 0
    d.Parent = parent
    return d
end

local statusCard = Instance.new("Frame")
statusCard.Size = UDim2.new(1, 0, 0, 42)
statusCard.BackgroundColor3 = Color3.fromRGB(9, 11, 20)
statusCard.BorderSizePixel = 0
statusCard.Parent = farmPage
mkCorner(statusCard, 14)
mkStroke(statusCard, 1, Color3.fromRGB(20, 23, 36), 0)

local sDot = Instance.new("Frame")
sDot.Size = UDim2.new(0, 9, 0, 9)
sDot.Position = UDim2.new(0, 14, 0.5, -5)
sDot.BackgroundColor3 = Color3.fromRGB(62, 68, 100)
sDot.BorderSizePixel = 0
sDot.Parent = statusCard
mkCorner(sDot, 999)

local statusLbl = mkLabel(statusCard, "Selecione um modo abaixo", 11, Enum.Font.GothamBold, Color3.fromRGB(100, 108, 145))
statusLbl.Size = UDim2.new(1, -36, 1, 0)
statusLbl.Position = UDim2.new(0, 32, 0, 0)
statusLbl.TextTruncate = Enum.TextTruncate.AtEnd

local activityLog = {}
local logHolder

local function pushLog(text, color)
    table.insert(activityLog, 1, {
        text = os.date("%H:%M:%S") .. "  ›  " .. text,
        color = color or Color3.fromRGB(255, 170, 0)
    })
    while #activityLog > 14 do table.remove(activityLog) end
    if logHolder then
        for _, c in ipairs(logHolder:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        local y = 0
        for i, entry in ipairs(activityLog) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 28)
            row.Position = UDim2.new(0, 0, 0, y)
            row.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(11, 13, 24) or Color3.fromRGB(9, 11, 20)
            row.BorderSizePixel = 0
            row.Parent = logHolder
            mkCorner(row, 8)

            local d = Instance.new("Frame")
            d.Size = UDim2.new(0, 7, 0, 7)
            d.Position = UDim2.new(0, 10, 0.5, -4)
            d.BackgroundColor3 = entry.color
            d.BorderSizePixel = 0
            d.Parent = row
            mkCorner(d, 999)

            local t = mkLabel(row, entry.text, 10, Enum.Font.GothamMedium, Color3.fromRGB(195, 200, 225))
            t.Size = UDim2.new(1, -24, 1, 0)
            t.Position = UDim2.new(0, 20, 0, 0)
            t.TextTruncate = Enum.TextTruncate.AtEnd

            y = y + 32
        end
        logHolder.CanvasSize = UDim2.new(0, 0, 0, y)
    end
end

local function setStatus(txt, cor)
    statusLbl.Text = txt
    statusLbl.TextColor3 = cor or Color3.fromRGB(100, 108, 145)
    tw(sDot, {BackgroundColor3 = cor or Color3.fromRGB(62, 68, 100)}, 0.18)
    pushLog(txt, cor or Color3.fromRGB(100, 108, 145))
end

sectionLbl(farmPage, 50, "MODO DE OPERAÇÃO")

local modeWrap = Instance.new("Frame")
modeWrap.Size = UDim2.new(1, 0, 0, 210)
modeWrap.Position = UDim2.new(0, 0, 0, 68)
modeWrap.BackgroundTransparency = 1
modeWrap.Parent = farmPage

local modeList = Instance.new("UIListLayout")
modeList.Padding = UDim.new(0, 10)
modeList.Parent = modeWrap

local modeColors = {
    bonds = Color3.fromRGB(255, 170, 0),
    win = Color3.fromRGB(0, 210, 95),
    both = Color3.fromRGB(145, 45, 255),
}

local modeNames = {
    bonds = "Auto Bonds",
    win = "Auto Win",
    both = "Win + Bonds",
}

local activeCards = {}

local function modeCard(id, labelText, subText, icon)
    local accent = modeColors[id]

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 62)
    card.BackgroundColor3 = Color3.fromRGB(9, 11, 20)
    card.BorderSizePixel = 0
    card.Parent = modeWrap
    mkCorner(card, 16)
    mkStroke(card, 1, Color3.fromRGB(20, 23, 38), 0)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 4, 0.55, 0)
    bar.Position = UDim2.new(0, 0, 0.225, 0)
    bar.BackgroundColor3 = accent
    bar.BorderSizePixel = 0
    bar.Parent = card
    mkCorner(bar, 999)

    local ico = mkLabel(card, icon, 20, Enum.Font.GothamBold, Color3.fromRGB(255, 255, 255), Enum.TextXAlignment.Center)
    ico.Size = UDim2.new(0, 34, 0, 34)
    ico.Position = UDim2.new(0, 12, 0.5, -17)

    local ttl = mkLabel(card, labelText, 13, Enum.Font.GothamBlack, Color3.fromRGB(230, 235, 250))
    ttl.Size = UDim2.new(1, -108, 0, 18)
    ttl.Position = UDim2.new(0, 52, 0, 11)

    local sub = mkLabel(card, subText, 10, Enum.Font.GothamMedium, Color3.fromRGB(82, 90, 125))
    sub.Size = UDim2.new(1, -108, 0, 14)
    sub.Position = UDim2.new(0, 52, 0, 31)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 9, 0, 9)
    dot.Position = UDim2.new(1, -18, 0.5, -5)
    dot.BackgroundColor3 = Color3.fromRGB(26, 30, 44)
    dot.BorderSizePixel = 0
    dot.Parent = card
    mkCorner(dot, 999)

    local hit = Instance.new("TextButton")
    hit.Size = UDim2.new(1, 0, 1, 0)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.Parent = card

    hit.MouseEnter:Connect(function()
        if G.mode ~= id then
            tw(card, {BackgroundColor3 = Color3.fromRGB(12, 14, 26)}, 0.1)
        end
    end)
    hit.MouseLeave:Connect(function()
        if G.mode ~= id then
            tw(card, {BackgroundColor3 = Color3.fromRGB(9, 11, 20)}, 0.1)
        end
    end)
    hit.MouseButton1Click:Connect(function()
        G.mode = id
        for _, d in ipairs(activeCards) do
            tw(d.card, {BackgroundColor3 = Color3.fromRGB(9, 11, 20)}, 0.14)
            tw(d.stroke, {Color = Color3.fromRGB(20, 23, 38), Thickness = 1}, 0.14)
            tw(d.dot, {BackgroundColor3 = Color3.fromRGB(26, 30, 44)}, 0.14)
        end
        tw(card, {BackgroundColor3 = Color3.fromRGB(13, 15, 28)}, 0.14)
        local cs = card:FindFirstChildOfClass("UIStroke")
        if cs then tw(cs, {Color = accent, Thickness = 1.8}, 0.14) end
        tw(dot, {BackgroundColor3 = accent}, 0.14)
        setStatus("Modo: " .. labelText, accent)
    end)

    table.insert(activeCards, {card = card, stroke = card:FindFirstChildOfClass("UIStroke"), dot = dot})
end

modeCard("bonds", "AUTO BONDS", "Visita estruturas e coleta todos os bonds", "💰")
modeCard("win", "AUTO WIN", "Vai ao final, ativa a alavanca e fecha a run", "🏆")
modeCard("both", "AUTO WIN + BONDS", "Farm completo e depois força a vitória", "⚡")

divLine(farmPage, 286)
sectionLbl(farmPage, 294, "ESTATÍSTICAS")

local statRefs = {bonds = {}, wins = {}, runs = {}, bpm = {}}

local function bindStat(name, lbl)
    table.insert(statRefs[name], lbl)
end

local statsRow = Instance.new("Frame")
statsRow.Size = UDim2.new(1, 0, 0, 72)
statsRow.Position = UDim2.new(0, 0, 0, 314)
statsRow.BackgroundTransparency = 1
statsRow.Parent = farmPage

local statList = Instance.new("UIListLayout")
statList.FillDirection = Enum.FillDirection.Horizontal
statList.HorizontalAlignment = Enum.HorizontalAlignment.Left
statList.VerticalAlignment = Enum.VerticalAlignment.Center
statList.Padding = UDim.new(0, 8)
statList.Parent = statsRow

local statDefs = {
    {"BONDS", Color3.fromRGB(255, 170, 0), "bonds"},
    {"WINS", Color3.fromRGB(0, 210, 95), "wins"},
    {"RUNS", Color3.fromRGB(95, 160, 255), "runs"},
    {"B/MIN", Color3.fromRGB(165, 65, 255), "bpm"},
}

for _, def in ipairs(statDefs) do
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.25, -6, 1, 0)
    f.BackgroundColor3 = Color3.fromRGB(9, 10, 18)
    f.BorderSizePixel = 0
    f.Parent = statsRow
    mkCorner(f, 14)
    mkStroke(f, 1, Color3.fromRGB(18, 20, 32), 0)

    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, 0, 2)
    top.BackgroundColor3 = def[2]
    top.BorderSizePixel = 0
    top.Parent = f
    mkCorner(top, 14)

    local val = mkLabel(f, "0", 22, Enum.Font.GothamBlack, def[2], Enum.TextXAlignment.Center)
    val.Size = UDim2.new(1, 0, 0, 28)
    val.Position = UDim2.new(0, 0, 0, 11)
    bindStat(def[3], val)

    local sub = mkLabel(f, def[1], 9, Enum.Font.GothamBold, Color3.fromRGB(72, 78, 110), Enum.TextXAlignment.Center)
    sub.Size = UDim2.new(1, 0, 0, 14)
    sub.Position = UDim2.new(0, 0, 0, 46)
end

divLine(farmPage, 394)
sectionLbl(farmPage, 402, "SESSÃO")

local detailCard = Instance.new("Frame")
detailCard.Size = UDim2.new(1, 0, 0, 66)
detailCard.Position = UDim2.new(0, 0, 0, 420)
detailCard.BackgroundColor3 = Color3.fromRGB(9, 10, 18)
detailCard.BorderSizePixel = 0
detailCard.Parent = farmPage
mkCorner(detailCard, 14)
mkStroke(detailCard, 1, Color3.fromRGB(18, 20, 32), 0)

local detailRefs = {time = {}, loc = {}, mode = {}}

local function setDetail(name, text)
    for _, l in ipairs(detailRefs[name]) do l.Text = text end
end

local function detailRow(parent, y, key, refName)
    local k = mkLabel(parent, key, 10, Enum.Font.GothamBlack, Color3.fromRGB(65, 72, 105))
    k.Size = UDim2.new(0, 85, 0, 18)
    k.Position = UDim2.new(0, 14, 0, y)

    local v = mkLabel(parent, "—", 10, Enum.Font.GothamMedium, Color3.fromRGB(168, 172, 208))
    v.Size = UDim2.new(1, -105, 0, 18)
    v.Position = UDim2.new(0, 98, 0, y)

    table.insert(detailRefs[refName], v)
end

detailRow(detailCard, 7, "Sessão", "time")
detailRow(detailCard, 25, "Local", "loc")
detailRow(detailCard, 43, "Modo", "mode")

local btnWrap = Instance.new("Frame")
btnWrap.Size = UDim2.new(1, 0, 0, 40)
btnWrap.Position = UDim2.new(0, 0, 1, -40)
btnWrap.BackgroundTransparency = 1
btnWrap.Parent = farmPage

local startBtn = mkButton(btnWrap, "▶  INICIAR", Color3.fromRGB(255, 170, 0), Color3.fromRGB(8, 8, 12), 13)
startBtn.Size = UDim2.new(0.46, 0, 1, 0)
startBtn.Position = UDim2.new(0, 0, 0, 0)

local stopBtn = mkButton(btnWrap, "■  PARAR", Color3.fromRGB(115, 16, 24), Color3.fromRGB(245, 245, 252), 13)
stopBtn.Size = UDim2.new(0.52, 0, 1, 0)
stopBtn.Position = UDim2.new(0.48, 0, 0, 0)

local function animBtn(btn, base)
    btn.MouseEnter:Connect(function() tw(btn, {BackgroundColor3 = brighten(base, 0.08)}, 0.12) end)
    btn.MouseLeave:Connect(function() tw(btn, {BackgroundColor3 = base}, 0.12) end)
    btn.MouseButton1Down:Connect(function() tw(btn, {BackgroundTransparency = 0.12}, 0.06) end)
    btn.MouseButton1Up:Connect(function() tw(btn, {BackgroundTransparency = 0}, 0.08) end)
end

animBtn(startBtn, Color3.fromRGB(255, 170, 0))
animBtn(stopBtn, Color3.fromRGB(115, 16, 24))
animBtn(minBtn, Color3.fromRGB(16, 18, 30))
animBtn(closeBtn, Color3.fromRGB(125, 20, 26))

sectionLbl(statsPage, 2, "VISÃO GERAL")

local heroWrap = Instance.new("Frame")
heroWrap.Size = UDim2.new(1, 0, 0, 90)
heroWrap.Position = UDim2.new(0, 0, 0, 22)
heroWrap.BackgroundTransparency = 1
heroWrap.Parent = statsPage

local heroList = Instance.new("UIListLayout")
heroList.FillDirection = Enum.FillDirection.Horizontal
heroList.Padding = UDim.new(0, 10)
heroList.Parent = heroWrap

local heroDefs = {
    {"TOTAL BONDS", Color3.fromRGB(255, 170, 0), "bonds"},
    {"TOTAL WINS", Color3.fromRGB(0, 210, 95), "wins"},
    {"TOTAL RUNS", Color3.fromRGB(95, 160, 255), "runs"},
    {"BONDS/MIN", Color3.fromRGB(165, 65, 255), "bpm"},
}

for _, def in ipairs(heroDefs) do
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.25, -8, 1, 0)
    f.BackgroundColor3 = Color3.fromRGB(9, 10, 18)
    f.BorderSizePixel = 0
    f.Parent = heroWrap
    mkCorner(f, 16)
    mkStroke(f, 1, Color3.fromRGB(20, 22, 34), 0)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 3)
    bar.BackgroundColor3 = def[2]
    bar.BorderSizePixel = 0
    bar.Parent = f
    mkCorner(bar, 16)

    local lbl = mkLabel(f, def[1], 9, Enum.Font.GothamBlack, Color3.fromRGB(75, 82, 115))
    lbl.Size = UDim2.new(1, -18, 0, 16)
    lbl.Position = UDim2.new(0, 10, 0, 14)

    local val = mkLabel(f, "0", 24, Enum.Font.GothamBlack, def[2])
    val.Size = UDim2.new(1, -18, 0, 32)
    val.Position = UDim2.new(0, 10, 0, 36)

    bindStat(def[3], val)
end

divLine(statsPage, 118)
sectionLbl(statsPage, 126, "DETALHES")

local sesCard = Instance.new("Frame")
sesCard.Size = UDim2.new(0.44, 0, 0, 108)
sesCard.Position = UDim2.new(0, 0, 0, 146)
sesCard.BackgroundColor3 = Color3.fromRGB(9, 10, 18)
sesCard.BorderSizePixel = 0
sesCard.Parent = statsPage
mkCorner(sesCard, 16)
mkStroke(sesCard, 1, Color3.fromRGB(18, 20, 32), 0)

local function statsDetailRow(parent, y, key, refName)
    local k = mkLabel(parent, key, 10, Enum.Font.GothamBlack, Color3.fromRGB(68, 75, 108))
    k.Size = UDim2.new(0, 78, 0, 18)
    k.Position = UDim2.new(0, 12, 0, y)
    local v = mkLabel(parent, "—", 10, Enum.Font.GothamMedium, Color3.fromRGB(168, 172, 208))
    v.Size = UDim2.new(1, -94, 0, 18)
    v.Position = UDim2.new(0, 86, 0, y)
    table.insert(detailRefs[refName], v)
end

statsDetailRow(sesCard, 12, "Sessão", "time")
statsDetailRow(sesCard, 36, "Local", "loc")
statsDetailRow(sesCard, 60, "Modo", "mode")

local hintLbl = mkLabel(sesCard, "Atualizado em tempo real", 9, Enum.Font.GothamMedium, Color3.fromRGB(65, 72, 102))
hintLbl.Size = UDim2.new(1, -20, 0, 16)
hintLbl.Position = UDim2.new(0, 10, 1, -22)

local logCard = Instance.new("Frame")
logCard.Size = UDim2.new(0.54, -10, 0, 108)
logCard.Position = UDim2.new(0.46, 10, 0, 146)
logCard.BackgroundColor3 = Color3.fromRGB(9, 10, 18)
logCard.BorderSizePixel = 0
logCard.Parent = statsPage
mkCorner(logCard, 16)
mkStroke(logCard, 1, Color3.fromRGB(18, 20, 32), 0)

local logTitle2 = mkLabel(logCard, "Activity Log", 11, Enum.Font.GothamBlack, Color3.fromRGB(230, 235, 250))
logTitle2.Size = UDim2.new(1, -18, 0, 18)
logTitle2.Position = UDim2.new(0, 12, 0, 10)

logHolder = Instance.new("ScrollingFrame")
logHolder.Size = UDim2.new(1, -12, 1, -34)
logHolder.Position = UDim2.new(0, 6, 0, 30)
logHolder.BackgroundTransparency = 1
logHolder.BorderSizePixel = 0
logHolder.ScrollBarThickness = 3
logHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
logHolder.Parent = logCard

sectionLbl(settingsPage, 2, "CONFIGURAÇÕES")

local settingsScroll = Instance.new("ScrollingFrame")
settingsScroll.Size = UDim2.new(1, 0, 1, -24)
settingsScroll.Position = UDim2.new(0, 0, 0, 24)
settingsScroll.BackgroundTransparency = 1
settingsScroll.BorderSizePixel = 0
settingsScroll.ScrollBarThickness = 4
settingsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
settingsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
settingsScroll.Parent = settingsPage

local settingsList = Instance.new("UIListLayout")
settingsList.Padding = UDim.new(0, 10)
settingsList.Parent = settingsScroll

local function makeToggle(parent, titleText, subText, key)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 62)
    row.BackgroundColor3 = Color3.fromRGB(9, 10, 18)
    row.BorderSizePixel = 0
    row.Parent = parent
    mkCorner(row, 14)
    mkStroke(row, 1, Color3.fromRGB(18, 20, 32), 0)

    local ttl = mkLabel(row, titleText, 12, Enum.Font.GothamBlack, Color3.fromRGB(230, 235, 250))
    ttl.Size = UDim2.new(1, -90, 0, 18)
    ttl.Position = UDim2.new(0, 14, 0, 11)

    local sub = mkLabel(row, subText, 10, Enum.Font.GothamMedium, Color3.fromRGB(95, 102, 135))
    sub.Size = UDim2.new(1, -90, 0, 16)
    sub.Position = UDim2.new(0, 14, 0, 33)

    local tog = Instance.new("Frame")
    tog.Size = UDim2.new(0, 48, 0, 26)
    tog.Position = UDim2.new(1, -62, 0.5, -13)
    tog.BackgroundColor3 = Settings[key] and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(26, 30, 44)
    tog.BorderSizePixel = 0
    tog.Parent = row
    mkCorner(tog, 999)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = Settings[key] and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 4, 0.5, -10)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = tog
    mkCorner(knob, 999)

    local hit = Instance.new("TextButton")
    hit.Size = UDim2.new(1, 0, 1, 0)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.Parent = row

    local function apply()
        tw(tog, {BackgroundColor3 = Settings[key] and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(26, 30, 44)}, 0.18)
        tw(knob, {Position = Settings[key] and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 4, 0.5, -10)}, 0.18)
    end

    hit.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        apply()
    end)

    apply()
end

makeToggle(settingsScroll, "Anti AFK", "Prevenção de kick por inatividade", "antiAfk")
makeToggle(settingsScroll, "Animações", "Animações suaves da interface", "animations")
makeToggle(settingsScroll, "Auto Coletar", "Coleta automática de bonds próximos", "autoCollect")
makeToggle(settingsScroll, "Modo Rápido", "Teleporte rápido entre estruturas", "fastMode")

local infoCard = Instance.new("Frame")
infoCard.Size = UDim2.new(1, 0, 0, 110)
infoCard.BackgroundColor3 = Color3.fromRGB(9, 10, 18)
infoCard.BorderSizePixel = 0
infoCard.Parent = settingsScroll
mkCorner(infoCard, 16)
mkStroke(infoCard, 1, Color3.fromRGB(18, 20, 32), 0)

local infoTitleLbl = mkLabel(infoCard, "Atalhos", 11, Enum.Font.GothamBlack, Color3.fromRGB(230, 235, 250))
infoTitleLbl.Size = UDim2.new(1, -22, 0, 18)
infoTitleLbl.Position = UDim2.new(0, 14, 0, 10)

local infoBodyLbl = mkLabel(infoCard, "• RightCtrl: esconder/mostrar UI\n• Aba Farm: selecione modo e inicie\n• Mova a janela pelo header\n• Execute no Lobby ou Partida", 10, Enum.Font.GothamMedium, Color3.fromRGB(92, 98, 132))
infoBodyLbl.Size = UDim2.new(1, -22, 0, 76)
infoBodyLbl.Position = UDim2.new(0, 14, 0, 30)
infoBodyLbl.TextYAlignment = Enum.TextYAlignment.Top

do
    local dragging, dragStart, startPos = false, nil, nil

    header.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = inp.Position
            startPos = window.Position
        end
    end)
    header.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

local minimized = false
local fullSize = UDim2.new(0, W, 0, H)
local miniSize = UDim2.new(0, W, 0, 78)

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        tw(window, {Size = miniSize}, 0.26)
        minBtn.Text = "+"
    else
        tw(window, {Size = fullSize}, 0.26)
        minBtn.Text = "−"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    Alive = false
    G.running = false
    pcall(function() HRP.Anchored = false end)
    safeDestroy(blur)
    safeDestroy(sg)
end)

UIS.InputBegan:Connect(function(inp, gpe)
    if gpe or not Alive then return end
    if inp.KeyCode == Enum.KeyCode.RightControl then
        sg.Enabled = not sg.Enabled
        watermark.Visible = sg.Enabled
    end
end)

local structKeywords = {
    "bank", "fort", "castle", "prison", "lab", "sterling", "town", "outlaw",
    "church", "vault", "depot", "dungeon", "safehouse", "cabin", "camp", "compound",
    "house", "mine", "headframe", "gunsmith", "doctor", "sheriff", "trading", "barn",
    "tesla", "constitution", "stillwater", "saloon", "general", "store", "station"
}

local bondKeywords = {
    "bond", "treasury", "bonus", "reward", "cash", "money", "gold", "loot"
}

local function isStructure(model)
    local name = model.Name:lower()
    for _, kw in ipairs(structKeywords) do
        if name:find(kw) then return true end
    end
    return false
end

local function getStructurePosition(model)
    local primary = model:FindFirstChild("PrimaryPart") or model:FindFirstChildWhichIsA("BasePart")
    if primary then
        return primary.Position
    end
    local cf = nil
    pcall(function() cf = model:GetModelCFrame() end)
    if cf then return cf.Position end
    return nil
end

local function findAllStructures()
    local structures = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and isStructure(obj) then
            local pos = getStructurePosition(obj)
            if pos then
                table.insert(structures, {
                    model = obj,
                    position = pos,
                    distance = (pos - HRP.Position).Magnitude
                })
            end
        end
    end
    table.sort(structures, function(a, b) return a.distance < b.distance end)
    return structures
end

local function collectAllBonds()
    local collected = 0
    local searchContainers = {Workspace, Items}
    
    for _, container in ipairs(searchContainers) do
        pcall(function()
            for _, item in ipairs(container:GetDescendants()) do
                if item and item.Parent then
                    local n = item.Name:lower()
                    local isBond = false
                    
                    if n == "bond" or n == "bonds" or n:find("bond") or n:find("treasury") or n:find("cash") or n:find("money") or n:find("gold") then
                        isBond = true
                    end
                    
                    if isBond then
                        local part = nil
                        if item:IsA("BasePart") then
                            part = item
                        else
                            part = item:FindFirstChildWhichIsA("BasePart")
                        end
                        
                        if part then
                            local dist = (part.Position - HRP.Position).Magnitude
                            if dist <= 200 then
                                for i = 1, 8 do
                                    part.CFrame = HRP.CFrame + Vector3.new(math.random(-2, 2), 2, math.random(-2, 2))
                                    part.AssemblyLinearVelocity = Vector3.zero
                                    part.AssemblyAngularVelocity = Vector3.zero
                                    task.wait(0.04)
                                end
                                
                                if CollectRemote then
                                    pcall(function() CollectRemote:FireServer(item) end)
                                end
                                
                                local pp = item:FindFirstChildWhichIsA("ProximityPrompt")
                                if not pp and item.Parent then
                                    pp = item.Parent:FindFirstChildWhichIsA("ProximityPrompt")
                                end
                                if pp then
                                    pcall(function()
                                        pp.HoldDuration = 0
                                        fireproximityprompt(pp)
                                    end)
                                end
                                
                                collected = collected + 1
                            end
                        end
                    end
                end
            end
        end)
    end
    
    return collected
end

local function activateLeverProperly(leverPrompt)
    if not leverPrompt then return false end

    local holdTime = leverPrompt.HoldDuration or 15
    if holdTime <= 0 then holdTime = 15 end

    setStatus(string.format("Ativando alavanca: segurando por %.0fs...", holdTime), Color3.fromRGB(0, 240, 120))

    leverPrompt.Enabled = true
    leverPrompt.RequiresLineOfSight = false

    local success = pcall(function()
        leverPrompt:InputHoldBegin()
    end)

    if not success then
        fireproximityprompt(leverPrompt)
        return true
    end

    local startTime = tick()
    while tick() - startTime < holdTime + 2 do
        if not G.running then
            pcall(function() leverPrompt:InputHoldEnd() end)
            return false
        end

        local elapsed = tick() - startTime
        local remaining = math.max(0, holdTime - elapsed)
        setStatus(string.format("Segurando alavanca: %.1fs restantes", remaining), Color3.fromRGB(0, 230, 110))

        pcall(function()
            HRP.AssemblyLinearVelocity = Vector3.zero
            HRP.AssemblyAngularVelocity = Vector3.zero
        end)

        task.wait(0.1)
    end

    pcall(function() leverPrompt:InputHoldEnd() end)

    task.wait(0.5)

    for i = 1, 3 do
        pcall(function() fireproximityprompt(leverPrompt) end)
        task.wait(0.2)
    end

    setStatus("Alavanca ativada com sucesso!", Color3.fromRGB(0, 255, 130))
    return true
end

local function findLever()
    local leverKeywords = {"lever", "crank", "drawbridge", "bridge", "winch", "alavanca", "handle", "pull", "gate", "switch"}
    local bestLever = nil
    local bestPart = nil
    local bestScore = 0

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent then
                local score = 0
                local pName = parent.Name:lower()
                local gpName = parent.Parent and parent.Parent.Name:lower() or ""

                for _, kw in ipairs(leverKeywords) do
                    if pName:find(kw) then score = score + 10 end
                    if gpName:find(kw) then score = score + 5 end
                end

                if obj.ActionText:lower():find("pull") or obj.ActionText:lower():find("activate") then
                    score = score + 8
                end

                local partPos = nil
                if parent:IsA("BasePart") then
                    partPos = parent.Position
                elseif parent:FindFirstChildWhichIsA("BasePart") then
                    partPos = parent:FindFirstChildWhichIsA("BasePart").Position
                end

                if partPos and partPos.Z < -48000 then
                    score = score + 20
                end

                if score > bestScore then
                    bestScore = score
                    bestLever = obj
                    bestPart = parent
                end
            end
        end
    end

    return bestLever, bestPart
end

local function findRails()
    local rails = Workspace:FindFirstChild("RailSegments")
    if rails then return rails end

    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name:lower():find("rail") then
            return obj
        end
    end

    return nil
end

local WIN_POS = {
    CFrame.new(-424, 28, -48750),
    CFrame.new(-424, 28, -48900),
    CFrame.new(-424, 28, -49050),
    CFrame.new(-424, 26, -49150),
    CFrame.new(-424, 26, -49250),
}

local function doBondsRun()
    setStatus("Iniciando farm de bonds...", Color3.fromRGB(255, 170, 0))
    setDetail("loc", "Partida")
    setDetail("mode", "Auto Bonds")

    G.runs = G.runs + 1
    for _, l in ipairs(statRefs.runs) do l.Text = tostring(G.runs) end

    local structures = findAllStructures()
    G.structuresFound = #structures

    if #structures == 0 then
        setStatus("Nenhuma estrutura encontrada! Usando trilhos...", Color3.fromRGB(255, 140, 0))

        local rails = findRails()
        if rails then
            local track = rails:FindFirstChild("RailSegment") or rails:FindFirstChildWhichIsA("BasePart")
            local visited = {}

            while G.running and track do
                if visited[track] then break end
                visited[track] = true

                local guide = track:FindFirstChild("Guide") or track:FindFirstChildWhichIsA("BasePart")
                if guide then
                    local pos = guide:IsA("BasePart") and guide.Position or guide.CFrame.Position
                    HRP.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
                    setStatus("Varrendo trilhos por bonds...", Color3.fromRGB(255, 170, 0))
                    task.wait(0.3)
                    
                    local c = collectAllBonds()
                    if c > 0 then
                        G.bonds = G.bonds + c
                        for _, lbl in ipairs(statRefs.bonds) do lbl.Text = tostring(G.bonds) end
                        setStatus("Coletados " .. c .. " bonds!", Color3.fromRGB(0, 230, 100))
                    end
                end

                local nxt = track:FindFirstChild("NextTrack")
                if nxt and nxt.Value then
                    track = nxt.Value
                else
                    break
                end
                task.wait(0.2)
            end
        end
    else
        setStatus(string.format("Encontradas %d estruturas!", #structures), Color3.fromRGB(255, 170, 0))
        task.wait(0.5)

        for i, struct in ipairs(structures) do
            if not G.running then break end

            G.currentStructure = struct.model.Name
            setStatus(string.format("[%d/%d] Indo para %s...", i, #structures, struct.model.Name), Color3.fromRGB(255, 190, 40))

            HRP.Anchored = true

            HRP.CFrame = CFrame.new(struct.position + Vector3.new(0, 10, 0))
            task.wait(0.5)

            setStatus(string.format("[%d/%d] Coletando bonds em %s...", i, #structures, struct.model.Name), Color3.fromRGB(255, 200, 60))

            local totalCollected = 0
            
            for attempt = 1, 3 do
                local c = collectAllBonds()
                totalCollected = totalCollected + c
                
                if c > 0 then
                    G.bonds = G.bonds + c
                    for _, lbl in ipairs(statRefs.bonds) do lbl.Text = tostring(G.bonds) end
                end
                
                task.wait(0.4)
            end

            if totalCollected > 0 then
                setStatus(string.format("[%d/%d] %s: %d bonds!", i, #structures, struct.model.Name, totalCollected), Color3.fromRGB(0, 230, 100))
            else
                setStatus(string.format("[%d/%d] %s: nenhum bond", i, #structures, struct.model.Name), Color3.fromRGB(150, 150, 150))
            end

            HRP.Anchored = false
            task.wait(0.5)
        end
    end

    setStatus("Farm de bonds concluído! Voltando ao lobby...", Color3.fromRGB(0, 230, 100))
    task.wait(2)
    pcall(function() TeleportService:Teleport(LOBBY, player) end)
    task.wait(10)
end

local function doWinRun(skipBonds)
    setDetail("loc", "Partida")
    G.runs = G.runs + 1
    for _, l in ipairs(statRefs.runs) do l.Text = tostring(G.runs) end

    if not skipBonds then
        setStatus("Win+Bonds: farmando antes...", Color3.fromRGB(145, 45, 255))
        setDetail("mode", "Win + Bonds")

        local structures = findAllStructures()
        local maxStructures = math.min(5, #structures)

        for i = 1, maxStructures do
            if not G.running then break end
            local struct = structures[i]
            
            setStatus(string.format("Pré-farm: indo para %s...", struct.model.Name), Color3.fromRGB(145, 55, 255))

            HRP.Anchored = true
            HRP.CFrame = CFrame.new(struct.position + Vector3.new(0, 10, 0))
            task.wait(0.4)

            local c = collectAllBonds()
            if c > 0 then
                G.bonds = G.bonds + c
                for _, lbl in ipairs(statRefs.bonds) do lbl.Text = tostring(G.bonds) end
            end

            HRP.Anchored = false
            task.wait(0.4)
        end
    else
        setDetail("mode", "Auto Win")
    end

    if not G.running then return end

    setStatus("Teleportando para 80km...", Color3.fromRGB(0, 210, 95))
    HRP.Anchored = true

    for i, cf in ipairs(WIN_POS) do
        if not G.running then break end
        HRP.CFrame = cf
        pcall(function()
            for _, p in ipairs(character:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.AssemblyLinearVelocity = Vector3.zero
                    p.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end)
        setStatus(string.format("Avançando... (%d/%d)", i, #WIN_POS), Color3.fromRGB(0, 210, 95))
        task.wait(Settings.fastMode and 0.8 or 1.2)
    end

    collectAllBonds()
    task.wait(0.3)

    setStatus("Procurando alavanca...", Color3.fromRGB(0, 210, 95))
    local lever, leverPart, tries = nil, nil, 0

    while G.running and not lever and tries < 100 do
        lever, leverPart = findLever()
        if lever then break end
        tries = tries + 1

        if tries % 10 == 0 then
            local searchPos = WIN_POS[math.min(#WIN_POS, math.floor(tries / 10) + 2)]
            HRP.CFrame = searchPos
            setStatus(string.format("Procurando alavanca... (%d)", tries), Color3.fromRGB(0, 200, 85))
        end

        task.wait(0.25)
    end

    if lever then
        setStatus("Alavanca encontrada! Aproximando...", Color3.fromRGB(0, 240, 120))

        local lPos = nil
        if leverPart then
            if leverPart:IsA("BasePart") then
                lPos = leverPart.Position
            else
                local p = leverPart:FindFirstChildWhichIsA("BasePart")
                if p then lPos = p.Position end
            end
        end

        if lPos then
            HRP.CFrame = CFrame.new(lPos + Vector3.new(0, 3, 4))
            task.wait(0.5)
            HRP.CFrame = CFrame.new(lPos + Vector3.new(0, 2, 2))
            task.wait(0.5)
        end

        local activated = activateLeverProperly(lever)

        if activated then
            setStatus("Alavanca ativada! Posicionando na parede...", Color3.fromRGB(0, 255, 130))
            
            if lPos then
                HRP.CFrame = CFrame.new(lPos + Vector3.new(-5, 5, 0))
                task.wait(0.3)
            end
            
            setStatus("Aguardando vitória... (ver timer na alavanca)", Color3.fromRGB(0, 255, 130))
        else
            setStatus("Erro ao ativar! Tentando alternativo...", Color3.fromRGB(255, 140, 0))
            for _ = 1, 5 do
                pcall(function() fireproximityprompt(lever) end)
                task.wait(0.3)
            end
        end
    else
        setStatus("Alavanca não encontrada! Tentando método alternativo...", Color3.fromRGB(255, 140, 0))
    end

    HRP.Anchored = false

    local waited = 0
    while G.running and waited < 270 do
        task.wait(1)
        waited = waited + 1
        local rem = 270 - waited
        setStatus(string.format("Aguardando vitória... %dm%02ds", math.floor(rem / 60), rem % 60), Color3.fromRGB(0, 210, 95))
    end

    if G.running then
        G.wins = G.wins + 1
        for _, l in ipairs(statRefs.wins) do l.Text = tostring(G.wins) end
        setStatus("VITÓRIA! Voltando ao lobby...", Color3.fromRGB(0, 255, 140))
        task.wait(2)
        pcall(function() TeleportService:Teleport(LOBBY, player) end)
        task.wait(10)
    end
end

local function lobby_createParty()
    setStatus("Procurando sistema de party...", Color3.fromRGB(95, 160, 255))
    setDetail("loc", "Lobby")

    local shared = ReplicatedStorage:WaitForChild("Shared", 20)
    if not shared then
        setStatus("Shared não encontrado! Tentando teleporte direto...", Color3.fromRGB(255, 140, 0))
        pcall(function() TeleportService:Teleport(GAME, player) end)
        task.wait(10)
        return
    end

    local partyRemote = shared:FindFirstChild("CreatePartyClient")
    if not partyRemote then
        for _, v in ipairs(shared:GetDescendants()) do
            if v:IsA("RemoteEvent") and v.Name:lower():find("party") then
                partyRemote = v
                break
            end
        end
    end

    if not partyRemote then
        setStatus("Remote de party não encontrado! Tentando teleporte direto...", Color3.fromRGB(255, 140, 0))
        pcall(function() TeleportService:Teleport(GAME, player) end)
        task.wait(10)
        return
    end

    local zones = Workspace:FindFirstChild("TeleportZones") or Workspace:FindFirstChild("Zones")
    if not zones then
        setStatus("Zonas não encontradas! Tentando teleporte...", Color3.fromRGB(255, 140, 0))
        pcall(function() partyRemote:FireServer({maxPlayers = 1}) end)
        task.wait(3)
        pcall(function() TeleportService:Teleport(GAME, player) end)
        task.wait(10)
        return
    end

    local found, attempts = false, 0

    while G.running and not found do
        attempts = attempts + 1

        for _, z in ipairs(zones:GetChildren()) do
            if not G.running then break end

            local isZone = z.Name:lower():find("zone") or z.Name:lower():find("teleport")
            if isZone or z:IsA("BasePart") or z:FindFirstChildWhichIsA("BasePart") then
                local zonePart = z:IsA("BasePart") and z or z:FindFirstChildWhichIsA("BasePart")
                local billboard = z:FindFirstChildOfClass("BillboardGui")
                local stateLabel = billboard and billboard:FindFirstChild("StateLabel")

                local canUse = true
                if stateLabel then
                    local txt = stateLabel.Text:lower()
                    if txt:find("full") or txt:find("cheio") or txt:find("in") then
                        canUse = false
                    end
                end

                if zonePart and canUse then
                    HRP.CFrame = zonePart.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.5)

                    pcall(function()
                        partyRemote:FireServer({maxPlayers = 1, isPublic = false})
                    end)

                    setStatus("Party criada! Aguardando teleporte...", Color3.fromRGB(255, 170, 0))
                    found = true
                    task.wait(6)
                    break
                end
            end
        end

        if not found then
            setStatus(string.format("Procurando zona disponível... (%d)", attempts), Color3.fromRGB(95, 160, 255))
            task.wait(1.5)
        end

        if attempts > 20 then
            setStatus("Tentando teleporte direto...", Color3.fromRGB(255, 140, 0))
            pcall(function() partyRemote:FireServer({maxPlayers = 1}) end)
            task.wait(3)
            pcall(function() TeleportService:Teleport(GAME, player) end)
            task.wait(10)
            break
        end
    end
end

startBtn.MouseButton1Click:Connect(function()
    if G.running then return end
    if not G.mode then
        setStatus("Selecione um modo primeiro!", Color3.fromRGB(220, 55, 55))
        return
    end

    G.running = true
    G.t0 = tick()
    G.bpmBase = G.bonds
    G.bpmTick = tick()
    setDetail("mode", modeNames[G.mode] or G.mode)

    task.spawn(function()
        while G.running do
            local ok, err = pcall(function()
                local pid = game.PlaceId
                if pid == LOBBY then
                    lobby_createParty()
                elseif pid == GAME then
                    if G.mode == "bonds" then
                        doBondsRun()
                    elseif G.mode == "win" then
                        doWinRun(true)
                    elseif G.mode == "both" then
                        doWinRun(false)
                    end
                else
                    setStatus("Execute no lobby ou na partida!", Color3.fromRGB(220, 55, 55))
                    task.wait(3)
                end
            end)

            if not ok then
                setStatus("Erro: " .. tostring(err):sub(1, 55), Color3.fromRGB(220, 55, 55))
                task.wait(3)
            end

            if G.running then task.wait(2) end
        end
    end)
end)

stopBtn.MouseButton1Click:Connect(function()
    G.running = false
    G.mode = nil
    pcall(function() HRP.Anchored = false end)
    for _, d in ipairs(activeCards) do
        tw(d.card, {BackgroundColor3 = Color3.fromRGB(9, 11, 20)}, 0.14)
        if d.stroke then tw(d.stroke, {Color = Color3.fromRGB(20, 23, 38), Thickness = 1}, 0.14) end
        tw(d.dot, {BackgroundColor3 = Color3.fromRGB(26, 30, 44)}, 0.14)
    end
    setStatus("Parado pelo usuário.", Color3.fromRGB(85, 92, 125))
    setDetail("loc", "—")
    setDetail("mode", "—")
end)

task.spawn(function()
    while Alive and sg.Parent do
        task.wait(0.5)
        local el = math.floor(tick() - G.t0)
        setDetail("time", string.format("%dm %02ds", math.floor(el / 60), el % 60))

        local pid = game.PlaceId
        setDetail("loc", pid == LOBBY and "Lobby" or pid == GAME and "Partida" or "Outro")

        if tick() - G.bpmTick >= 60 then
            G.bpm = G.bonds - G.bpmBase
            G.bpmBase = G.bonds
            G.bpmTick = tick()
            for _, l in ipairs(statRefs.bpm) do l.Text = tostring(G.bpm) end
        end

        for _, l in ipairs(statRefs.bonds) do l.Text = tostring(G.bonds) end
        for _, l in ipairs(statRefs.wins) do l.Text = tostring(G.wins) end
        for _, l in ipairs(statRefs.runs) do l.Text = tostring(G.runs) end
    end
end)

task.spawn(function()
    while Alive and sg.Parent do
        task.wait(50)
        if Settings.antiAfk then
            pcall(function()
                VirtualUser:Button1Down(Vector2.zero, Workspace.CurrentCamera.CFrame)
                task.wait(0.1)
                VirtualUser:Button1Up(Vector2.zero, Workspace.CurrentCamera.CFrame)
            end)
        end
    end
end)

task.spawn(function()
    local r = 0
    while Alive and window.Parent do
        task.wait(0.016)
        if Settings.animations then
            r = (r + 0.9) % 360
            winStrokeGrad.Rotation = r
        end
    end
end)

task.spawn(function()
    while Alive and wmDot.Parent do
        task.wait(1.0)
        if Settings.animations then
            tw(wmDot, {BackgroundColor3 = Color3.fromRGB(255, 200, 110)}, 0.35)
            task.wait(0.35)
            tw(wmDot, {BackgroundColor3 = Color3.fromRGB(255, 170, 0)}, 0.35)
        end
    end
end)

switchPage("farm")
setDetail("time", "0m 00s")
setDetail("loc", "—")
setDetail("mode", "—")

window.Visible = true
window.Size = UDim2.new(0, W - 40, 0, H - 40)
window.BackgroundTransparency = 1
tw(window, {Size = UDim2.new(0, W, 0, H), BackgroundTransparency = 0.01}, 0.35)

task.wait(0.12)

tw(loading, {BackgroundTransparency = 1}, 0.35)
tw(loadCard, {Position = UDim2.new(0.5, 0, 0.5, 20), BackgroundTransparency = 1}, 0.35)
task.wait(0.4)
safeDestroy(loading)
tw(blur, {Size = 0}, 0.35)
task.delay(0.4, function() safeDestroy(blur) end)

setStatus("Pronto! Selecione um modo para iniciar.", Color3.fromRGB(105, 112, 150))

window.AncestryChanged:Connect(function(_, parent)
    if not parent then Alive = false end
end)
