getgenv().Apex = getgenv().Apex or {
State = {
Running = false,
Paused = false,
CurrentServer = tick(),
BondsTotal = 0,
BondsSession = 0,
Runs = 0,
Errors = 0,
LastBond = 0,
BPM = 0,
ServerHops = 0,
StartTime = tick()
},
Config = {
ScanDepth = 12,
MaxDistance = 5000,
TweenSpeed = 350,
RejoinDelay = 15,
EngineInterval = 0.016,
CollectionCooldown = 0.08,
AntiAFKInterval = 30
},
Refs = {
UI = nil,
Connections = {},
Threads = {}
}
}

local A = getgenv().Apex
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local function SafeGetCharacter()
local char = LocalPlayer.Character
if not char then
char = LocalPlayer.CharacterAdded:Wait()
task.wait(0.3)
end
return char
end

local function ValidatePlayerState()
local char = LocalPlayer.Character
if not char then return nil, nil, nil end

local hum = char:FindFirstChildOfClass("Humanoid")
if not hum or hum.Health <= 0 then return nil, nil, nil end

local root = char:FindFirstChild("HumanoidRootPart")
if not root then return nil, nil, nil end

return char, hum, root
end

local function KillAllConnections()
for _, conn in pairs(A.Refs.Connections) do
if typeof(conn) == "RBXScriptConnection" then
pcall(function() conn:Disconnect() end)
end
end
A.Refs.Connections = {}
end

local function KillAllThreads()
for _, thread in pairs(A.Refs.Threads) do
if typeof(thread) == "thread" then
pcall(function() coroutine.close(thread) end)
end
end
A.Refs.Threads = {}
end

local function Cleanup()
KillAllConnections()
KillAllThreads()
if A.Refs.UI and A.Refs.UI.Root then
pcall(function() A.Refs.UI.Root:Destroy() end)
A.Refs.UI = nil
end
end

local function DestroyOldUI()
for _, child in pairs(game.CoreGui:GetChildren()) do
if child.Name == "ApexBonds" then
pcall(function() child:Destroy() end)
end
end
end

local function CreateUI()
DestroyOldUI()

if A.Refs.UI and A.Refs.UI.Root then
A.Refs.UI.Root:Destroy()
A.Refs.UI = nil
end

local ui = Instance.new("ScreenGui")
ui.Name = "ApexBonds"
ui.Parent = game.CoreGui
ui.ResetOnSpawn = false
ui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 360, 0, 180)
main.Position = UDim2.new(0.5, -180, 0.08, 0)
main.BackgroundColor3 = Color3.fromRGB(6, 6, 8)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = ui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

local glow = Instance.new("ImageLabel")
glow.Size = UDim2.new(1, 40, 1, 40)
glow.Position = UDim2.new(0, -20, 0, -20)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://8992230677"
glow.ImageColor3 = Color3.fromRGB(0, 255, 150)
glow.ImageTransparency = 0.9
glow.Parent = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 36)
header.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
header.BorderSizePixel = 0
header.Parent = main

Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)

local fix = Instance.new("Frame")
fix.Size = UDim2.new(1, 0, 0, 12)
fix.Position = UDim2.new(0, 0, 1, -12)
fix.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
fix.BorderSizePixel = 0
fix.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "APEX BONDS v4.1"
title.TextColor3 = Color3.fromRGB(0, 0, 0)
title.TextSize = 18
title.Font = Enum.Font.GothamBlack
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local counter = Instance.new("TextLabel")
counter.Size = UDim2.new(1, 0, 0, 55)
counter.Position = UDim2.new(0, 0, 0, 42)
counter.BackgroundTransparency = 1
counter.Text = "0"
counter.TextColor3 = Color3.fromRGB(0, 255, 150)
counter.TextSize = 52
counter.Font = Enum.Font.GothamBlack
counter.Parent = main

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 20)
status.Position = UDim2.new(0, 0, 0, 98)
status.BackgroundTransparency = 1
status.Text = "STANDBY"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.TextSize = 12
status.Font = Enum.Font.GothamBold
status.Parent = main

local metrics = Instance.new("TextLabel")
metrics.Size = UDim2.new(1, 0, 0, 16)
metrics.Position = UDim2.new(0, 0, 0, 118)
metrics.BackgroundTransparency = 1
metrics.Text = "0/min | 0/hr | 00:00"
metrics.TextColor3 = Color3.fromRGB(120, 120, 120)
metrics.TextSize = 10
metrics.Font = Enum.Font.Gotham
metrics.Parent = main

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0.86, 0, 0, 4)
barBg.Position = UDim2.new(0.07, 0, 0, 140)
barBg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
barBg.BorderSizePixel = 0
Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
barBg.Parent = main

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, 0, 1, 0)
bar.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
bar.BorderSizePixel = 0
Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
bar.Parent = barBg

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.86, 0, 0, 26)
btn.Position = UDim2.new(0.07, 0, 0, 148)
btn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
btn.Text = "INITIALIZE"
btn.TextColor3 = Color3.new(1, 1, 1)
btn.TextSize = 13
btn.Font = Enum.Font.GothamBlack
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
btn.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 28, 0, 28)
close.Position = UDim2.new(1, -32, 0, 4)
close.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
close.Text = "×"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 18
close.Font = Enum.Font.GothamBold
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
close.Parent = header

A.Refs.UI = {
Root = ui,
Main = main,
Counter = counter,
Status = status,
Metrics = metrics,
Bar = bar,
Button = btn,
Close = close
}

close.MouseButton1Click:Connect(function()
A.State.Running = false
Cleanup()
end)

btn.MouseButton1Click:Connect(function()
ToggleEngine()
end)
end

local function UpdateUI()
if not A.Refs.UI then return end

A.Refs.UI.Counter.Text = tostring(A.State.BondsTotal)

local elapsed = tick() - A.State.CurrentServer
local mins = math.floor(elapsed / 60)
local secs = math.floor(elapsed % 60)

local rate = elapsed > 0 and (A.State.BondsSession / elapsed * 60) or 0
A.State.BPM = rate
local hourly = rate * 60

local rateText = ""
if hourly >= 1000000 then
rateText = string.format("%.1fM/hr", hourly / 1000000)
elseif hourly >= 1000 then
rateText = string.format("%.0fk/hr", hourly / 1000)
else
rateText = string.format("%d/hr", hourly)
end

A.Refs.UI.Metrics.Text = string.format("%.0f/min | %s | %02d:%02d", rate, rateText, mins, secs)

local progress = math.min(rate / 1000, 1)
A.Refs.UI.Bar.Size = UDim2.new(progress, 0, 1, 0)
A.Refs.UI.Bar.BackgroundColor3 = Color3.fromRGB(0, 255 * progress, 150 * (1 - progress))
end

local function SetStatus(text, color)
if A.Refs.UI and A.Refs.UI.Status then
A.Refs.UI.Status.Text = text
A.Refs.UI.Status.TextColor3 = color or Color3.fromRGB(200, 200, 200)
end
end

local function SetButton(active)
if not A.Refs.UI or not A.Refs.UI.Button then return end

if active then
A.Refs.UI.Button.Text = "TERMINATE"
A.Refs.UI.Button.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
else
A.Refs.UI.Button.Text = "INITIALIZE"
A.Refs.UI.Button.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
end
end

local Scanner = {}
Scanner.LastScan = {}
Scanner.ScanTime = 0

function Scanner.Execute()
local now = tick()
if now - Scanner.ScanTime < 0.05 then
return Scanner.LastScan
end

local bonds = {}
local checked = {}
local char, hum, root = ValidatePlayerState()
if not root then return bonds end

local function ScanObject(obj, depth)
if depth > A.Config.ScanDepth then return end
if not obj or checked[obj] then return end
checked[obj] = true

if obj.Name == "Bond" then
local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
if part then
local dist = (part.Position - root.Position).Magnitude
if dist <= A.Config.MaxDistance then
table.insert(bonds, {
Part = part,
Distance = dist,
Priority = 1000 - dist,
Type = obj:IsA("Model") and "Model" or "Part"
})
end
end
end

for _, child in pairs(obj:GetChildren()) do
if not child:IsA("Player") and child.Name ~= "Players" then
ScanObject(child, depth + 1)
end
end
end

ScanObject(Workspace, 0)

for _, prompt in pairs(Workspace:GetDescendants()) do
if prompt:IsA("ProximityPrompt") then
local parent = prompt.Parent
if parent and (parent.Name == "Bond" or (parent.Parent and parent.Parent.Name == "Bond")) then
local part = parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart")
if part and not checked[part] then
local dist = (part.Position - root.Position).Magnitude
if dist <= A.Config.MaxDistance then
table.insert(bonds, {
Part = part,
Prompt = prompt,
Distance = dist,
Priority = 1100 - dist,
Type = "Prompt"
})
checked[part] = true
end
end
end
end
end

table.sort(bonds, function(a, b)
if math.abs(a.Priority - b.Priority) > 100 then
return a.Priority > b.Priority
end
return a.Distance < b.Distance
end)

Scanner.LastScan = bonds
Scanner.ScanTime = now
return bonds
end

local Navigator = {}

function Navigator.TeleportTo(position)
local char, hum, root = ValidatePlayerState()
if not root then return false end

local target = position + Vector3.new(0, 2.5, 0)
local dist = (target - root.Position).Magnitude

if dist > A.Config.MaxDistance then
root.CFrame = CFrame.new(target)
task.wait(0.15)
return true
elseif dist > 8 then
local duration = math.min(dist / A.Config.TweenSpeed, 1.2)
local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
local tween = TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(target)})

local completed = false
local connection = nil

connection = tween.Completed:Connect(function()
completed = true
if connection then
connection:Disconnect()
end
end)

tween:Play()

local startTime = tick()
while not completed and (tick() - startTime) < duration + 0.5 do
if not A.State.Running then
tween:Cancel()
if connection then connection:Disconnect() end
return false
end
local _, _, checkRoot = ValidatePlayerState()
if not checkRoot then
tween:Cancel()
if connection then connection:Disconnect() end
return false
end
task.wait(0.03)
end

if connection then
connection:Disconnect()
end

return completed
else
root.CFrame = CFrame.new(target)
task.wait(0.05)
return true
end
end

local Collector = {}

function Collector.Collect(bond)
if not bond or not bond.Part or not bond.Part.Parent then return false end

local success = false
local part = bond.Part

local _, _, root = ValidatePlayerState()
if not root then return false end

local navSuccess = Navigator.TeleportTo(part.Position)
if not navSuccess then return false end

_, _, root = ValidatePlayerState()
if not root then return false end

if bond.Prompt then
pcall(function()
fireproximityprompt(bond.Prompt, 1)
success = true
end)
end

if not success then
for _, child in pairs(part:GetChildren()) do
if child:IsA("ProximityPrompt") then
pcall(function()
fireproximityprompt(child, 1)
success = true
end)
end
end
end

if not success then
pcall(function()
root.CFrame = part.CFrame
task.wait(0.1)
success = true
end)
end

return success
end

local Hopper = {}

function Hopper.Execute()
A.State.Running = false
SetStatus("HOPPING SERVER...", Color3.fromRGB(255, 165, 0))

local success, result = pcall(function()
local api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
local response = game:HttpGet(api)
local data = HttpService:JSONDecode(response)

if data and data.data then
for _, server in ipairs(data.data) do
if server.id ~= game.JobId and server.playing < server.maxPlayers then
return server.id
end
end
end
return nil
end)

task.wait(0.5)

if success and result then
pcall(function()
TeleportService:TeleportToPlaceInstance(game.PlaceId, result, LocalPlayer)
end)
else
pcall(function()
TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)
end
end

function Hopper.ResetAndHop()
A.State.Running = false
SetStatus("EXECUTING RESET...", Color3.fromRGB(255, 50, 50))

local char, hum, root = ValidatePlayerState()
if hum then
pcall(function() hum.Health = 0 end)
end

task.wait(A.Config.RejoinDelay)

pcall(function()
if root then
root.CFrame = CFrame.new(0, -500, 0)
end
end)

task.wait(2)

Hopper.Execute()
end

local AntiAFK = {}

function AntiAFK.Start()
local thread = task.spawn(function()
while A.State.Running do
task.wait(A.Config.AntiAFKInterval)
if not A.State.Running then break end

pcall(function()
VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
task.wait(0.05)
VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
end)
end
end)

table.insert(A.Refs.Threads, thread)
end

local Engine = {}
Engine.MainThread = nil

function Engine.SingleTick()
if not A.State.Running or A.State.Paused then return end

local char, hum, root = ValidatePlayerState()
if not root then
SetStatus("INVALID STATE - RECONNECTING", Color3.fromRGB(255, 0, 0))
task.wait(1)
return
end

local bonds = Scanner.Execute()

if #bonds > 0 then
A.State.LastBond = tick()

for i = 1, math.min(3, #bonds) do
if not A.State.Running then break end

local bond = bonds[i]
SetStatus(string.format("COLLECTING %d/%d (%.0fm)", i, #bonds, bond.Distance), Color3.fromRGB(0, 255, 150))

if Collector.Collect(bond) then
A.State.BondsTotal += 1
A.State.BondsSession += 1
UpdateUI()
end

task.wait(A.Config.CollectionCooldown)
end
else
local timeSinceBond = tick() - A.State.LastBond

if timeSinceBond > 12 then
SetStatus("SERVER DEPLETED - RESETTING", Color3.fromRGB(255, 100, 0))
Hopper.ResetAndHop()
return
elseif timeSinceBond > 5 then
SetStatus("EXPLORING...", Color3.fromRGB(255, 165, 0))

local x = root.Position.X
if x < 75000 then
root.CFrame = root.CFrame + Vector3.new(150, 0, 0)
else
Hopper.ResetAndHop()
return
end
else
SetStatus("SCANNING...", Color3.fromRGB(120, 120, 120))
end
end

UpdateUI()
end

function Engine.Start()
if A.State.Running then return end

A.State.Running = true
A.State.Paused = false
A.State.CurrentServer = tick()
A.State.BondsSession = 0
A.State.LastBond = tick()
A.State.Runs += 1

SetButton(true)
SetStatus("ENGINE STARTED", Color3.fromRGB(0, 255, 150))

AntiAFK.Start()

Engine.MainThread = task.spawn(function()
while A.State.Running do
Engine.SingleTick()
task.wait(A.Config.EngineInterval)
end
end)

table.insert(A.Refs.Threads, Engine.MainThread)
end

function Engine.Stop()
A.State.Running = false
A.State.Paused = false
KillAllThreads()
Engine.MainThread = nil
SetButton(false)
SetStatus("TERMINATED", Color3.fromRGB(200, 200, 200))
end

function Engine.RestartAfterRespawn()
if not A.State.Running then return end

Engine.Stop()
task.wait(1)

A.State.Running = true
A.State.Paused = false
A.State.CurrentServer = tick()
A.State.BondsSession = 0
A.State.LastBond = tick()

SetButton(true)
SetStatus("RESTARTED AFTER RESPAWN", Color3.fromRGB(0, 255, 150))

AntiAFK.Start()

Engine.MainThread = task.spawn(function()
while A.State.Running do
Engine.SingleTick()
task.wait(A.Config.EngineInterval)
end
end)

table.insert(A.Refs.Threads, Engine.MainThread)
end

function ToggleEngine()
if A.State.Running then
Engine.Stop()
else
Engine.Start()
end
end

local function Initialize()
Cleanup()
DestroyOldUI()
CreateUI()

local conn = LocalPlayer.CharacterAdded:Connect(function(char)
if A.State.Running then
task.wait(1)
Engine.RestartAfterRespawn()
end
end)

table.insert(A.Refs.Connections, conn)

if A.State.Running then
task.wait(0.5)
Engine.Start()
end
end

Initialize()
