getgenv().ZYPH = {
    Running = false,
    Bonds = 0,
    SessionStart = 0,
    ScanCooldown = 0.08,
    TweenSpeed = 0.05,
    CollectDelay = 0.06,
    ESP = true,
    AutoFarm = false,
    Noclip = false,
    Speed = 16
}

local Z = getgenv().ZYPH
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ESPObjects = {}
local LastScan = {}
local LastScanTime = 0
local NoclipConn = nil

local function GetRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function IsBond(obj)
    if not obj then return false end
    local name = obj.Name:lower()
    if name == "bond" then return true end
    if name:find("bond") then return true end
    if name:find("treasury") then return true end
    if obj:IsA("BasePart") then
        local col = obj.Color
        if col.r > 0.6 and col.g > 0.4 and col.b < 0.4 then return true end
    end
    for _, child in pairs(obj:GetDescendants()) do
        if child:IsA("ProximityPrompt") then
            local txt = child.ActionText:lower()
            if txt:find("bond") or txt:find("collect") or txt:find("grab") then return true end
        end
    end
    return false
end

local function EnableNoclip()
    if NoclipConn then return end
    Z.Noclip = true
    NoclipConn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end

local function DisableNoclip()
    Z.Noclip = false
    if NoclipConn then
        NoclipConn:Disconnect()
        NoclipConn = nil
    end
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

local function CreateESP(part, text)
    if part:FindFirstChild("ZYPH_ESP") then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ZYPH_ESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 160, 0, 45)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.Parent = part
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 215, 0)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 15
    label.Parent = billboard
    local highlight = Instance.new("Highlight")
    highlight.Name = "ZYPH_HL"
    highlight.FillColor = Color3.fromRGB(255, 215, 0)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.75
    highlight.OutlineTransparency = 0
    highlight.Parent = part
    table.insert(ESPObjects, {Part = part, Billboard = billboard, Highlight = highlight})
end

local function ClearESP()
    for _, esp in ipairs(ESPObjects) do
        pcall(function()
            if esp.Billboard then esp.Billboard:Destroy() end
            if esp.Highlight then esp.Highlight:Destroy() end
        end)
    end
    ESPObjects = {}
end

local function UpdateESP()
    local root = GetRoot()
    if not root then return end
    for i = #ESPObjects, 1, -1 do
        local esp = ESPObjects[i]
        if esp.Part and esp.Part.Parent then
            local dist = (esp.Part.Position - root.Position).Magnitude
            if esp.Billboard and esp.Billboard:FindFirstChild("TextLabel") then
                esp.Billboard.TextLabel.Text = string.format("BOND [%.0fm]", dist)
            end
        else
            pcall(function()
                if esp.Billboard then esp.Billboard:Destroy() end
                if esp.Highlight then esp.Highlight:Destroy() end
            end)
            table.remove(ESPObjects, i)
        end
    end
end

local function TweenTo(pos)
    local root = GetRoot()
    if not root then return false end
    local dist = (pos - root.Position).Magnitude
    if dist < 5 then
        root.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
        return true
    end
    local dur = math.clamp(dist / 350, Z.TweenSpeed, 0.9)
    local tween = TweenService:Create(root, TweenInfo.new(dur, Enum.EasingStyle.Quad), {CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))})
    local done = false
    tween.Completed:Connect(function() done = true end)
    tween:Play()
    local start = tick()
    while not done and tick() - start < dur + 0.3 do task.wait(0.01) end
    return done
end

local function Collect(obj)
    if not obj or not obj.Parent then return false end
    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
    if not part then return false end
    TweenTo(part.Position)
    task.wait(Z.CollectDelay)
    local root = GetRoot()
    if not root then return false end
    local collected = false
    for _, child in pairs(obj:GetDescendants()) do
        if child:IsA("ProximityPrompt") then
            pcall(function()
                fireproximityprompt(child, 1)
                collected = true
            end)
        end
    end
    if not collected then
        pcall(function()
            firetouchinterest(root, part, 0)
            task.wait(0.03)
            firetouchinterest(root, part, 1)
            collected = true
        end)
    end
    return collected
end

local function ScanBonds()
    local bonds = {}
    local checked = {}
    local root = GetRoot()
    if not root then return bonds end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if IsBond(obj) and not checked[obj] then
            checked[obj] = true
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part and part.Parent then
                local dist = (part.Position - root.Position).Magnitude
                table.insert(bonds, {Object = obj, Part = part, Distance = dist})
                if Z.ESP then CreateESP(part, "BOND") end
            end
        end
    end
    table.sort(bonds, function(a, b) return a.Distance < b.Distance end)
    return bonds
end

local function CreateUI()
    for _, child in pairs(game.CoreGui:GetChildren()) do
        if child.Name == "ZyphUI" then pcall(function() child:Destroy() end) end
    end
    local ui = Instance.new("ScreenGui")
    ui.Name = "ZyphUI"
    ui.Parent = game.CoreGui
    ui.ResetOnSpawn = false
    ui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 320, 0, 200)
    main.Position = UDim2.new(0.5, -160, 0.08, 0)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = ui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = main
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 190, 40)
    stroke.Thickness = 2
    stroke.Parent = main
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1, 50, 1, 50)
    glow.Position = UDim2.new(0, -25, 0, -25)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://8992230677"
    glow.ImageColor3 = Color3.fromRGB(255, 190, 40)
    glow.ImageTransparency = 0.9
    glow.Parent = main
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(255, 190, 40)
    header.BorderSizePixel = 0
    header.Parent = main
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 14)
    corner2.Parent = header
    local fix = Instance.new("Frame")
    fix.Size = UDim2.new(1, 0, 0, 18)
    fix.Position = UDim2.new(0, 0, 1, -18)
    fix.BackgroundColor3 = Color3.fromRGB(255, 190, 40)
    fix.BorderSizePixel = 0
    fix.Parent = header
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "ZYPH BONDS"
    title.TextColor3 = Color3.new(0, 0, 0)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBlack
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 32, 0, 32)
    close.Position = UDim2.new(1, -36, 0, 4)
    close.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    close.Text = "X"
    close.TextColor3 = Color3.new(1, 1, 1)
    close.TextSize = 16
    close.Font = Enum.Font.GothamBold
    close.Parent = header
    local corner3 = Instance.new("UICorner")
    corner3.CornerRadius = UDim.new(0, 8)
    corner3.Parent = close
    local counterFrame = Instance.new("Frame")
    counterFrame.Size = UDim2.new(0, 100, 0, 85)
    counterFrame.Position = UDim2.new(0, 12, 0, 50)
    counterFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    counterFrame.BorderSizePixel = 0
    counterFrame.Parent = main
    local corner4 = Instance.new("UICorner")
    corner4.CornerRadius = UDim.new(0, 10)
    corner4.Parent = counterFrame
    local counterLabel = Instance.new("TextLabel")
    counterLabel.Size = UDim2.new(1, 0, 0, 22)
    counterLabel.Position = UDim2.new(0, 0, 0, 6)
    counterLabel.BackgroundTransparency = 1
    counterLabel.Text = "BONDS"
    counterLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
    counterLabel.TextSize = 12
    counterLabel.Font = Enum.Font.GothamBold
    counterLabel.Parent = counterFrame
    local counter = Instance.new("TextLabel")
    counter.Name = "Counter"
    counter.Size = UDim2.new(1, 0, 0, 48)
    counter.Position = UDim2.new(0, 0, 0, 30)
    counter.BackgroundTransparency = 1
    counter.Text = "0"
    counter.TextColor3 = Color3.fromRGB(255, 190, 40)
    counter.TextSize = 38
    counter.Font = Enum.Font.GothamBlack
    counter.Parent = counterFrame
    local infoFrame = Instance.new("Frame")
    infoFrame.Size = UDim2.new(0, 185, 0, 85)
    infoFrame.Position = UDim2.new(0, 122, 0, 50)
    infoFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    infoFrame.BorderSizePixel = 0
    infoFrame.Parent = main
    local corner5 = Instance.new("UICorner")
    corner5.CornerRadius = UDim.new(0, 10)
    corner5.Parent = infoFrame
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(1, 0, 0, 24)
    status.Position = UDim2.new(0, 0, 0, 8)
    status.BackgroundTransparency = 1
    status.Text = "PRONT0"
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    status.TextSize = 15
    status.Font = Enum.Font.GothamBold
    status.Parent = infoFrame
    local rate = Instance.new("TextLabel")
    rate.Name = "Rate"
    rate.Size = UDim2.new(1, 0, 0, 18)
    rate.Position = UDim2.new(0, 0, 0, 36)
    rate.BackgroundTransparency = 1
    rate.Text = "0/min"
    rate.TextColor3 = Color3.fromRGB(140, 140, 140)
    rate.TextSize = 12
    rate.Font = Enum.Font.Gotham
    rate.Parent = infoFrame
    local time = Instance.new("TextLabel")
    time.Name = "Time"
    time.Size = UDim2.new(1, 0, 0, 18)
    time.Position = UDim2.new(0, 0, 0, 56)
    time.BackgroundTransparency = 1
    time.Text = "00:00"
    time.TextColor3 = Color3.fromRGB(140, 140, 140)
    time.TextSize = 12
    time.Font = Enum.Font.Gotham
    time.Parent = infoFrame
    local btnFrame = Instance.new("Frame")
    btnFrame.Size = UDim2.new(1, -24, 0, 36)
    btnFrame.Position = UDim2.new(0, 12, 0, 145)
    btnFrame.BackgroundTransparency = 1
    btnFrame.Parent = main
    local farmBtn = Instance.new("TextButton")
    farmBtn.Name = "FarmBtn"
    farmBtn.Size = UDim2.new(0.32, -4, 1, 0)
    farmBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 75)
    farmBtn.Text = "FARM"
    farmBtn.TextColor3 = Color3.new(0, 0, 0)
    farmBtn.TextSize = 14
    farmBtn.Font = Enum.Font.GothamBlack
    farmBtn.Parent = btnFrame
    local corner6 = Instance.new("UICorner")
    corner6.CornerRadius = UDim.new(0, 8)
    corner6.Parent = farmBtn
    local espBtn = Instance.new("TextButton")
    espBtn.Name = "EspBtn"
    espBtn.Size = UDim.new(0.32, -4, 1, 0)
    espBtn.Position = UDim2.new(0.34, 0, 0, 0)
    espBtn.BackgroundColor3 = Color3.fromRGB(255, 190, 40)
    espBtn.Text = "ESP"
    espBtn.TextColor3 = Color3.new(0, 0, 0)
    espBtn.TextSize = 14
    espBtn.Font = Enum.Font.GothamBlack
    espBtn.Parent = btnFrame
    local corner7 = Instance.new("UICorner")
    corner7.CornerRadius = UDim.new(0, 8)
    corner7.Parent = espBtn
    local noclipBtn = Instance.new("TextButton")
    noclipBtn.Name = "NoclipBtn"
    noclipBtn.Size = UDim2.new(0.32, -4, 1, 0)
    noclipBtn.Position = UDim2.new(0.68, 4, 0, 0)
    noclipBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    noclipBtn.Text = "NOCLIP"
    noclipBtn.TextColor3 = Color3.new(1, 1, 1)
    noclipBtn.TextSize = 14
    noclipBtn.Font = Enum.Font.GothamBlack
    noclipBtn.Parent = btnFrame
    local corner8 = Instance.new("UICorner")
    corner8.CornerRadius = UDim.new(0, 8)
    corner8.Parent = noclipBtn
    close.MouseButton1Click:Connect(function()
        Z.Running = false
        DisableNoclip()
        ClearESP()
        pcall(function() ui:Destroy() end)
    end)
    farmBtn.MouseButton1Click:Connect(function()
        Z.AutoFarm = not Z.AutoFarm
        if Z.AutoFarm then
            Z.Running = true
            Z.SessionStart = tick()
            farmBtn.Text = "PARAR"
            farmBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
            status.Text = "FARMANDO"
            status.TextColor3 = Color3.fromRGB(0, 255, 100)
        else
            Z.Running = false
            farmBtn.Text = "FARM"
            farmBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 75)
            status.Text = "PAUSADO"
            status.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end)
    espBtn.MouseButton1Click:Connect(function()
        Z.ESP = not Z.ESP
        if Z.ESP then
            espBtn.Text = "ESP"
            espBtn.BackgroundColor3 = Color3.fromRGB(255, 190, 40)
            espBtn.TextColor3 = Color3.new(0, 0, 0)
        else
            espBtn.Text = "ESP"
            espBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            espBtn.TextColor3 = Color3.new(1, 1, 1)
            ClearESP()
        end
    end)
    noclipBtn.MouseButton1Click:Connect(function()
        if Z.Noclip then
            DisableNoclip()
            noclipBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            noclipBtn.TextColor3 = Color3.new(1, 1, 1)
        else
            EnableNoclip()
            noclipBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
            noclipBtn.TextColor3 = Color3.new(1, 1, 1)
        end
    end)
    return {Counter = counter, Status = status, Rate = rate, Time = time, FarmBtn = farmBtn, EspBtn = espBtn, NoclipBtn = noclipBtn}
end

local UI = CreateUI()

local function UpdateUI()
    UI.Counter.Text = tostring(Z.Bonds)
    if Z.SessionStart > 0 then
        local elapsed = tick() - Z.SessionStart
        local mins = math.floor(elapsed / 60)
        local secs = math.floor(elapsed % 60)
        UI.Time.Text = string.format("%02d:%02d", mins, secs)
        if elapsed > 0 then
            local rate = math.floor(Z.Bonds / elapsed * 60)
            UI.Rate.Text = rate .. "/min"
        end
    end
end

local function FarmLoop()
    while true do
        if Z.Running and Z.AutoFarm then
            local root = GetRoot()
            local hum = GetHumanoid()
            if root and hum and hum.Health > 0 then
                local now = tick()
                if now - LastScanTime > Z.ScanCooldown then
                    LastScan = ScanBonds()
                    LastScanTime = now
                end
                if #LastScan > 0 then
                    UI.Status.Text = "COLETANDO " .. #LastScan
                    UI.Status.TextColor3 = Color3.fromRGB(255, 190, 40)
                    local bond = LastScan[1]
                    if Collect(bond.Object) then
                        Z.Bonds = Z.Bonds + 1
                        UpdateUI()
                        table.remove(LastScan, 1)
                        for i, esp in ipairs(ESPObjects) do
                            if esp.Part == bond.Part then
                                pcall(function()
                                    if esp.Billboard then esp.Billboard:Destroy() end
                                    if esp.Highlight then esp.Highlight:Destroy() end
                                end)
                                table.remove(ESPObjects, i)
                                break
                            end
                        end
                    end
                    task.wait(Z.CollectDelay)
                else
                    UI.Status.Text = "EXPLORANDO"
                    UI.Status.TextColor3 = Color3.fromRGB(150, 150, 150)
                    root.CFrame = root.CFrame + Vector3.new(120, 0, math.random(-50, 50))
                    task.wait(0.25)
                end
                if Z.ESP then UpdateESP() end
            else
                UI.Status.Text = "AGUARDANDO"
                UI.Status.TextColor3 = Color3.fromRGB(255, 100, 0)
                task.wait(1)
            end
        else
            task.wait(0.1)
        end
    end
end

task.spawn(FarmLoop)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Z.AutoFarm then Z.Running = true end
    if Z.Noclip then EnableNoclip() end
end)
