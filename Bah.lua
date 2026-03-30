getgenv().ZYPH = getgenv().ZYPH or {
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
StartTime = tick()
},
Config = {
ScanDepth = 12,
MaxDistance = 5000,
MinTweenTime = 0.3,
MaxTweenTime = 1.2,
RejoinDelay = 3,
EngineInterval = 0.05,
CollectionCooldown = 0.15,
AntiAFKInterval = 25,
Humanize = true,
Jitter = true
},
Refs = {
UI = nil,
Connections = {},
Threads = {}
}
}

local Z = getgenv().ZYPH
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local function SafeGetCharacter()
local char = LocalPlayer.Character
if not char then
char = LocalPlayer.CharacterAdded:Wait()
task.wait(0.5)
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
for _, conn in pairs(Z.Refs.Connections) do
if typeof(conn) == "RBXScriptConnection" then
pcall(function() conn:Disconnect() end)
end
end
Z.Refs.Connections = {}
end

local function KillAllThreads()
for _, thread in pairs(Z.Refs.Threads) do
if typeof(thread) == "thread" then
pcall(function() coroutine.close(thread) end)
end
end
Z.Refs.Threads = {}
end

local function Cleanup()
KillAllConnections()
KillAllThreads()
if Z.Refs.UI and Z.Refs.UI.Root then
pcall(function() Z.Refs.UI.Root:Destroy() end)
Z.Refs.UI = nil
end
end

local function DestroyOldUI()
for _, child in pairs(game.CoreGui:GetChildren()) do
if child.Name == "ZyphBonds" then
pcall(function() child:Destroy() end)
end
end
end

local function CreateUI()
DestroyOldUI()

local ui = Instance.new("ScreenGui")
ui.Name = "ZyphBonds"
ui.Parent = game.CoreGui
ui.ResetOnSpawn = false
ui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 380, 0, 200)
main.Position = UDim2.new(0.5, -190, 0.08, 0)
main.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = ui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

local glow = Instance.new("ImageLabel")
glow.Size = UDim2.new(1, 40, 1, 40)
glow.Position = UDim2.new(0, -20, 0, -20)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://8992230677"
glow.ImageColor3 = Color3.fromRGB(0, 200, 255)
glow.ImageTransparency = 0.9
glow.Parent = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
header.BorderSizePixel = 0
header.Parent = main

Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)

local fix = Instance.new("Frame")
fix.Size = UDim2.new(1, 0, 0, 15)
fix.Position = UDim2.new(0, 0, 1, -15)
fix.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
fix.BorderSizePixel = 0
fix.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ZYPH BONDS v5.0"
title.TextColor3 = Color3.fromRGB(0, 0, 0)
title.TextSize = 20
title.Font = Enum.Font.GothamBlack
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local counter = Instance.new("TextLabel")
counter.Size = UDim2.new(1, 0, 0, 60)
counter.Position = UDim2.new(0, 0, 0, 45)
counter.BackgroundTransparency = 1
counter.Text = "0"
counter.TextColor3 = Color3.fromRGB(0, 200, 255)
counter.TextSize = 56
counter.Font = Enum.Font.GothamBlack
counter.Parent = main

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 22)
status.Position = UDim2.new(0, 0, 0, 108)
status.BackgroundTransparency = 1
status.Text = "STANDBY"
status.TextColor3 = Color3.fromRGB(255, 255, 255)
status.TextSize = 13
status.Font = Enum.Font.GothamBold
status.Parent = main

local metrics = Instance.new("TextLabel")
metrics.Size = UDim2.new(1, 0, 0, 18)
metrics.Position = UDim2.new(0, 0, 0, 130)
metrics.BackgroundTransparency = 1
metrics.Text = "0/min | 0/hr | 00:00"
metrics.TextColor3 = Color3.fromRGB(150, 150, 150)
metrics.TextSize = 11
metrics.Font = Enum.Font.Gotham
metrics.Parent = main

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0.88, 0, 0, 6)
barBg.Position = UDim2.new(0.06, 0, 0, 155)
barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
barBg.BorderSizePixel = 0
Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
barBg.Parent = main

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, 0, 1, 0)
bar.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
bar.BorderSizePixel = 0
Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
bar.Parent = barBg

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.88, 0, 0, 28)
btn.Position = UDim2.new(0.06, 0, 0, 165)
btn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
btn.Text = "▶ INICIAR"
btn.TextColor3 = Color3.new(1, 1, 1)
btn.TextSize = 14
btn.Font = Enum.Font.GothamBlack
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
btn.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 32, 0, 32)
close.Position = UDim2.new(1, -37, 0, 4)
close.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
close.Text = "×"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 20
close.Font = Enum.Font.GothamBold
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
close.Parent = header

Z.Refs.UI = {
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
Z.State.Running = false
Cleanup()
end)

btn.MouseButton1Click:Connect(function()
ToggleEngine()
end)
end

local function UpdateUI()
if not Z.Refs.UI then return end

Z.Refs.UI.Counter.Text = tostring(Z.State.BondsTotal)

local elapsed = tick() - Z.State.CurrentServer
local mins = math.floor(elapsed / 60)
local secs = math.floor(elapsed % 60)

local rate = elapsed > 0 and (Z.State.BondsSession / elapsed * 60) or 0
Z.State.BPM = rate
local hourly = rate * 60

local rateText = ""
if hourly >= 1000000 then
rateText = string.format("%.1fM/hr", hourly / 1000000)
elseif hourly >= 1000 then
rateText = string.format("%.0fk/hr", hourly / 1000)
else
rateText = string.format("%d/hr", hourly)
end

Z.Refs.UI.Metrics.Text = string.format("%.0f/min | %s | %02d:%02d", rate, rateText, mins, secs)

local progress = math.min(rate / 500, 1)
Z.Refs.UI.Bar.Size = UDim2.new(progress, 0, 1, 0)
Z.Refs.UI.Bar.BackgroundColor3 = Color3.fromRGB(0, 200 * progress, 255 * (1-progress))
end

local function SetStatus(text, color)
if Z.Refs.UI and Z.Refs.UI.Status then
Z.Refs.UI.Status.Text = text
Z.Refs.UI.Status.TextColor3 = color or Color3.fromRGB(255, 255, 255)
end
end

local function SetButton(active)
if not Z.Refs.UI or not Z.Refs.UI.Button then return end

if active then
Z.Refs.UI.Button.Text = "⏹ PARAR"
Z.Refs.UI.Button.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
else
Z.Refs.UI.Button.Text = "▶ INICIAR"
Z.Refs.UI.Button.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
end
end

local Scanner = {}
Scanner.LastScan = {}
Scanner.ScanTime = 0

function Scanner.Execute()
local now = tick()
if now - Scanner.ScanTime < 0.1 then
return Scanner.LastScan
end

local bonds = {}
local checked = {}
local char, hum, root = ValidatePlayerState()
if not root then return bonds end

local function ScanObject(obj, depth)
if depth > Z.Config.ScanDepth then return end
if not obj or not obj.Parent or checked[obj] then return end
checked[obj] = true

if obj.Name == "Bond" then
local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
if part and part.Parent then
local success, dist = pcall(function()
return (part.Position - root.Position).Magnitude
end)
if success and dist and dist <= Z.Config.MaxDistance then
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
local success, dist = pcall(function()
return (part.Position - root.Position).Magnitude
end)
if success and dist and dist <= Z.Config.MaxDistance then
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

function Navigator.HumanizedMoveTo(targetPos)
local char, hum, root = ValidatePlayerState()
if not root then return false end

local startPos = root.Position
local distance = (targetPos - startPos).Magnitude

if distance < 5 then
root.CFrame = CFrame.new(targetPos + Vector3.new(0, 2.5, 0))
task.wait(0.1)
return true
end

if Z.Config.Humanize then
local jitterX = 0
local jitterZ = 0
if Z.Config.Jitter then
jitterX = math.random(-10, 10)
jitterZ = math.random(-10, 10)
end

local waypoints = {}
local steps = math.min(math.ceil(distance / 50), 5)

for i = 1, steps do
local t = i / steps
local basePos = startPos:Lerp(targetPos, t)
table.insert(waypoints, basePos + Vector3.new(
math.random(-5, 5) + jitterX * (1-t),
0,
math.random(-5, 5) + jitterZ * (1-t)
))
end

table.insert(waypoints, targetPos + Vector3.new(0, 2.5, 0))

for _, waypoint in ipairs(waypoints) do
if not Z.State.Running then return false end

local _, _, checkRoot = ValidatePlayerState()
if not checkRoot then return false end

local dist = (waypoint - root.Position).Magnitude
local duration = math.clamp(dist / math.random(80, 150), Z.Config.MinTweenTime, Z.Config.MaxTweenTime)

if dist > 10 then
local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tween = TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(waypoint)})

local completed = false
local conn = tween.Completed:Connect(function() completed = true end)

tween:Play()

local start = tick()
while not completed and (tick() - start) < duration + 0.5 do
if not Z.State.Running then
tween:Cancel()
conn:Disconnect()
return false
end
_, _, checkRoot = ValidatePlayerState()
if not checkRoot then
tween:Cancel()
conn:Disconnect()
return false
end
task.wait(0.05)
end

conn:Disconnect()
else
root.CFrame = CFrame.new(waypoint)
task.wait(0.05)
end

task.wait(math.random(5, 15) / 100)
end

return true
else
local duration = math.clamp(distance / 200, Z.Config.MinTweenTime, Z.Config.MaxTweenTime)
local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
local tween = TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(targetPos + Vector3.new(0, 2.5, 0))})

local completed = false
local conn = tween.Completed:Connect(function() completed = true end)

tween:Play()

local start = tick()
while not completed and (tick() - start) < duration + 0.5 do
if not Z.State.Running then
tween:Cancel()
conn:Disconnect()
return false
end
local _, _, checkRoot = ValidatePlayerState()
if not checkRoot then
tween:Cancel()
conn:Disconnect()
return false
end
task.wait(0.05)
end

conn:Disconnect()
return completed
end
end

local Collector = {}

function Collector.Collect(bond)
if not bond or not bond.Part or not bond.Part.Parent then return false end

local char, hum, root = ValidatePlayerState()
if not root then return false end

local success = Navigator.HumanizedMoveTo(bond.Part.Position)
if not success then return false end

char, hum, root = ValidatePlayerState()
if not root then return false end

local collected = false

if bond.Prompt then
pcall(function()
fireproximityprompt(bond.Prompt, 1)
collected = true
end)
end

if not collected then
for _, child in pairs(bond.Part:GetChildren()) do
if child:IsA("ProximityPrompt") then
pcall(function()
fireproximityprompt(child, 1)
collected = true
end)
end
end
end

if not collected then
pcall(function()
root.CFrame = bond.Part.CFrame + Vector3.new(0, 1, 0)
task.wait(0.15)
collected = true
end)
end

return collected
end

local Rejoiner = {}

function Rejoiner.ClickPlayButton()
SetStatus("PROCURANDO BOTÃO JOGAR...", Color3.fromRGB(255, 165, 0))

local startTime = tick()
local maxWait = 10

while tick() - startTime < maxWait do
local success, result = pcall(function()
local gui = LocalPlayer:FindFirstChild("PlayerGui")
if not gui then return nil end

for _, screen in pairs(gui:GetDescendants()) do
if screen:IsA("TextButton") or screen:IsA("ImageButton") then
local text = ""
if screen:IsA("TextButton") then
text = screen.Text:lower()
elseif screen:FindFirstChild("TextLabel") then
text = screen.TextLabel.Text:lower()
end

if text:find("jogar") or text:find("play") or text:find("novamente") or text:find("again") then
return screen
end

for _, child in pairs(screen:GetDescendants()) do
if child:IsA("TextLabel") then
local childText = child.Text:lower()
if childText:find("jogar") or childText:find("play") or childText:find("novamente") or childText:find("again") then
return screen
end
end
end
end
end
return nil
end)

if success and result then
SetStatus("CLICANDO EM JOGAR...", Color3.fromRGB(0, 255, 150))

local clickSuccess = pcall(function()
local pos = result.AbsolutePosition
local size = result.AbsoluteSize
local center = pos + (size / 2)

VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
task.wait(0.05)
VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)

GuiService.SelectedObject = result
VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
task.wait(0.05)
VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
end)

if clickSuccess then
task.wait(2)
return true
end
end

task.wait(0.5)
end

return false
end

function Rejoiner.Execute()
Z.State.Running = false
SetStatus("REINICIANDO PARTIDA...", Color3.fromRGB(255, 100, 0))

local char, hum, root = ValidatePlayerState()

if hum then
pcall(function() hum.Health = 0 end)
end

task.wait(2)

local clicked = Rejoiner.ClickPlayButton()

if not clicked then
SetStatus("BOTÃO NÃO ENCONTRADO - TENTANDO NOVAMENTE...", Color3.fromRGB(255, 0, 0))
task.wait(3)
Rejoiner.ClickPlayButton()
end
end

local AntiAFK = {}

function AntiAFK.Start()
local thread = task.spawn(function()
while Z.State.Running do
task.wait(Z.Config.AntiAFKInterval)
if not Z.State.Running then break end

pcall(function()
VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
task.wait(0.05)
VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end)
end
end)

table.insert(Z.Refs.Threads, thread)
end

local Engine = {}
Engine.MainThread = nil

function Engine.SingleTick()
if not Z.State.Running or Z.State.Paused then return end

local char, hum, root = ValidatePlayerState()
if not root then
SetStatus("RECONNECTANDO...", Color3.fromRGB(255, 0, 0))
task.wait(1)
return
end

local bonds = Scanner.Execute()

if #bonds > 0 then
Z.State.LastBond = tick()

for i = 1, math.min(2, #bonds) do
if not Z.State.Running then break end

local bond = bonds[i]
SetStatus(string.format("COLETANDO %d/%d (%.0fm)", i, #bonds, bond.Distance), Color3.fromRGB(0, 200, 255))

if Collector.Collect(bond) then
Z.State.BondsTotal += 1
Z.State.BondsSession += 1
UpdateUI()
end

task.wait(Z.Config.CollectionCooldown + (math.random(0, 10) / 100))
end
else
local timeSinceBond = tick() - Z.State.LastBond

if timeSinceBond > 20 then
SetStatus("SEM BONDS - REINICIANDO", Color3.fromRGB(255, 100, 0))
Rejoiner.Execute()
return
elseif timeSinceBond > 8 then
SetStatus("EXPLORANDO...", Color3.fromRGB(255, 165, 0))

local x = root.Position.X
if x < 75000 then
local moveDist = math.random(50, 150)
root.CFrame = root.CFrame + Vector3.new(moveDist, 0, math.random(-20, 20))
else
Rejoiner.Execute()
return
end
else
SetStatus("PROCURANDO...", Color3.fromRGB(150, 150, 150))
end
end

UpdateUI()
end

function Engine.Start()
if Z.State.Running then return end

Z.State.Running = true
Z.State.Paused = false
Z.State.CurrentServer = tick()
Z.State.BondsSession = 0
Z.State.LastBond = tick()
Z.State.Runs += 1

SetButton(true)
SetStatus("INICIADO", Color3.fromRGB(0, 200, 255))

AntiAFK.Start()

Engine.MainThread = task.spawn(function()
while Z.State.Running do
Engine.SingleTick()
task.wait(Z.Config.EngineInterval + (math.random(0, 20) / 1000))
end
end)

table.insert(Z.Refs.Threads, Engine.MainThread)
end

function Engine.Stop()
Z.State.Running = false
Z.State.Paused = false
KillAllThreads()
Engine.MainThread = nil
SetButton(false)
SetStatus("PARADO", Color3.fromRGB(200, 200, 200))
end

function Engine.RestartAfterRespawn()
if not Z.State.Running then return end

Engine.Stop()
task.wait(1.5)

Z.State.Running = true
Z.State.Paused = false
Z.State.CurrentServer = tick()
Z.State.BondsSession = 0
Z.State.LastBond = tick()

SetButton(true)
SetStatus("REINICIADO", Color3.fromRGB(0, 200, 255))

AntiAFK.Start()

Engine.MainThread = task.spawn(function()
while Z.State.Running do
Engine.SingleTick()
task.wait(Z.Config.EngineInterval + (math.random(0, 20) / 1000))
end
end)

table.insert(Z.Refs.Threads, Engine.MainThread)
end

function ToggleEngine()
if Z.State.Running then
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
if Z.State.Running then
task.wait(1.5)
Engine.RestartAfterRespawn()
end
end)

table.insert(Z.Refs.Connections, conn)

if Z.State.Running then
task.wait(0.5)
Engine.Start()
end
end

Initialize()

