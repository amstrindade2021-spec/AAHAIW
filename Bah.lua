-- Dead Rails Premium Hub v4.0
-- UI Moderna + Funcionalidades Reais

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Configurações
local Settings = {
    Speed = false,
    SpeedValue = 100,
    Jump = false,
    Fly = false,
    Noclip = false,
    ESP = false,
    AutoFarm = false,
    GodMode = false
}

-- Criar GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeadRailsPremium"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Frame Principal (Moderno, centralizado)
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 700, 0, 450)
Main.Position = UDim2.new(0.5, -350, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

-- Gradiente sutil
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
})
Gradient.Parent = Main

-- Sombra
local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.Position = UDim2.new(0, -20, 0, -20)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.6
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(20, 20, 280, 280)
Shadow.Parent = Main

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

-- Consertar cantos do header
local Fix = Instance.new("Frame")
Fix.Size = UDim2.new(1, 0, 0, 10)
Fix.Position = UDim2.new(0, 0, 1, -10)
Fix.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
Fix.BorderSizePixel = 0
Fix.Parent = Header

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🚂 DEAD RAILS PREMIUM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Botão Fechar (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- Sidebar (Menu lateral)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 160, 1, -50)
Sidebar.Position = UDim2.new(0, 0, 0, 50)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 0)
SidebarCorner.Parent = Sidebar

-- Conteúdo
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -160, 1, -50)
Content.Position = UDim2.new(0, 160, 0, 50)
Content.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Content.BorderSizePixel = 0
Content.Parent = Main

-- Sistema de Abas
local Tabs = {}
local CurrentTab = "Main"

-- Função criar botão de aba
local function CreateTabButton(name, icon, pos)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.9, 0, 0, 40)
    Btn.Position = UDim2.new(0.05, 0, 0, 10 + (pos * 50))
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Btn.Text = "  " .. icon .. "  " .. name
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.TextSize = 14
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = Sidebar
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Btn
    
    Btn.MouseEnter:Connect(function()
        if CurrentTab ~= name then
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
        end
    end)
    
    Btn.MouseLeave:Connect(function()
        if CurrentTab ~= name then
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}):Play()
        end
    end)
    
    Btn.MouseButton1Click:Connect(function()
        CurrentTab = name
        -- Resetar cores
        for _, b in pairs(Sidebar:GetChildren()) do
            if b:IsA("TextButton") then
                TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 35), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
            end
        end
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(139, 0, 0), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        
        -- Atualizar conteúdo
        for _, c in pairs(Content:GetChildren()) do
            c.Visible = (c.Name == name)
        end
    end)
    
    return Btn
end

-- Criar abas
CreateTabButton("Main", "⚡", 0)
CreateTabButton("Farm", "💰", 1)
CreateTabButton("ESP", "👁️", 2)
CreateTabButton("Teleport", "🎯", 3)
CreateTabButton("Misc", "⚙️", 4)

-- Função criar Toggle Switch moderno
local function CreateToggle(parent, text, yPos, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0.95, 0, 0, 50)
    Container.Position = UDim2.new(0.025, 0, 0, yPos)
    Container.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Container.BorderSizePixel = 0
    Container.Parent = parent
    
    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(0, 10)
    CCorner.Parent = Container
    
    -- Label
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0.05, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 16
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    -- Botão Toggle
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 50, 0, 26)
    ToggleBtn.Position = UDim2.new(1, -60, 0.5, -13)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    ToggleBtn.Text = ""
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Parent = Container
    
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(1, 0)
    TCorner.Parent = ToggleBtn
    
    -- Círculo que desliza
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 22, 0, 22)
    Circle.Position = UDim2.new(0, 2, 0.5, -11)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.BorderSizePixel = 0
    Circle.Parent = ToggleBtn
    
    local CCircle = Instance.new("UICorner")
    CCircle.CornerRadius = UDim.new(1, 0)
    CCircle.Parent = Circle
    
    local Enabled = false
    
    ToggleBtn.MouseButton1Click:Connect(function()
        Enabled = not Enabled
        if Enabled then
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 0)}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 26, 0.5, -11)}):Play()
        else
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -11)}):Play()
        end
        callback(Enabled)
    end)
    
    return Container
end

-- Criar Páginas de Conteúdo
local MainPage = Instance.new("Frame")
MainPage.Name = "Main"
MainPage.Size = UDim2.new(1, 0, 1, 0)
MainPage.BackgroundTransparency = 1
MainPage.Parent = Content

local FarmPage = Instance.new("Frame")
FarmPage.Name = "Farm"
FarmPage.Size = UDim2.new(1, 0, 1, 0)
FarmPage.BackgroundTransparency = 1
FarmPage.Visible = false
FarmPage.Parent = Content

local ESPPage = Instance.new("Frame")
ESPPage.Name = "ESP"
ESPPage.Size = UDim2.new(1, 0, 1, 0)
ESPPage.BackgroundTransparency = 1
ESPPage.Visible = false
ESPPage.Parent = Content

local TeleportPage = Instance.new("Frame")
TeleportPage.Name = "Teleport"
TeleportPage.Size = UDim2.new(1, 0, 1, 0)
TeleportPage.BackgroundTransparency = 1
TeleportPage.Visible = false
TeleportPage.Parent = Content

local MiscPage = Instance.new("Frame")
MiscPage.Name = "Misc"
MiscPage.Size = UDim2.new(1, 0, 1, 0)
MiscPage.BackgroundTransparency = 1
MiscPage.Visible = false
MiscPage.Parent = Content

-- SCROLL FRAME para páginas longas
local function MakeScrollable(frame)
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -10, 1, -10)
    Scroll.Position = UDim2.new(0, 5, 0, 5)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 4
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(139, 0, 0)
    Scroll.Parent = frame
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 10)
    Layout.Parent = Scroll
    
    return Scroll
end

local MainScroll = MakeScrollable(MainPage)
local FarmScroll = MakeScrollable(FarmPage)
local ESPScroll = MakeScrollable(ESPPage)

-- ========== FUNÇÕES REAIS ==========

-- SPEED
CreateToggle(MainScroll, "Super Speed", 10, function(state)
    Settings.Speed = state
    if state then
        Humanoid.WalkSpeed = Settings.SpeedValue
    else
        Humanoid.WalkSpeed = 16
    end
end)

-- JUMP POWER
CreateToggle(MainScroll, "Super Jump", 70, function(state)
    Settings.Jump = state
    if state then
        Humanoid.JumpPower = 100
    else
        Humanoid.JumpPower = 50
    end
end)

-- FLY
local FlyConnection
CreateToggle(MainScroll, "Fly (Voo)", 130, function(state)
    Settings.Fly = state
    if state then
        local BG = Instance.new("BodyGyro")
        BG.P = 9e4
        BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        BG.CFrame = RootPart.CFrame
        BG.Parent = RootPart
        
        local BV = Instance.new("BodyVelocity")
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        BV.Parent = RootPart
        
        FlyConnection = RunService.Heartbeat:Connect(function()
            if not Settings.Fly then return end
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + workspace.CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - workspace.CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + workspace.CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - workspace.CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
            
            if dir.Magnitude > 0 then
                BV.Velocity = dir.Unit * 50
            else
                BV.Velocity = Vector3.new(0, 0, 0)
            end
            BG.CFrame = workspace.CurrentCamera.CFrame
        end)
    else
        if FlyConnection then FlyConnection:Disconnect() end
        for _, v in pairs(RootPart:GetChildren()) do
            if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
        end
    end
end)

-- NOCLIP
local NoclipConnection
CreateToggle(MainScroll, "No Clip", 190, function(state)
    Settings.Noclip = state
    if state then
        NoclipConnection = RunService.Stepped:Connect(function()
            if not Settings.Noclip then return end
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        if NoclipConnection then NoclipConnection:Disconnect() end
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end)

-- GOD MODE
CreateToggle(MainScroll, "God Mode (Vida Infinita)", 250, function(state)
    Settings.GodMode = state
    if state then
        Humanoid.MaxHealth = math.huge
        Humanoid.Health = math.huge
    else
        Humanoid.MaxHealth = 100
        Humanoid.Health = 100
    end
end)

-- ========== FARM PAGE ==========
CreateToggle(FarmScroll, "Auto Farm (Coletar Itens)", 10, function(state)
    Settings.AutoFarm = state
end)

-- ========== ESP PAGE ==========
local ESPObjects = {}
CreateToggle(ESPScroll, "ESP Jogadores/Inimigos", 10, function(state)
    Settings.ESP = state
    if not state then
        for _, obj in pairs(ESPObjects) do
            if obj then obj:Destroy() end
        end
        ESPObjects = {}
    end
end)

-- ========== TELEPORT PAGE ==========
local Locations = {
    {"Início", Vector3.new(0, 50, 0)},
    {"10km", Vector3.new(10000, 50, 0)},
    {"20km", Vector3.new(20000, 50, 0)},
    {"Castle (39km)", Vector3.new(39000, 50, 0)},
    {"Final (78km)", Vector3.new(78000, 50, 0)}
}

local TScroll = Instance.new("ScrollingFrame")
TScroll.Size = UDim2.new(1, -20, 1, -20)
TScroll.Position = UDim2.new(0, 10, 0, 10)
TScroll.BackgroundTransparency = 1
TScroll.ScrollBarThickness = 4
TScroll.Parent = TeleportPage

local TLayout = Instance.new("UIListLayout")
TLayout.Padding = UDim.new(0, 8)
TLayout.Parent = TScroll

for i, loc in pairs(Locations) do
    local TpBtn = Instance.new("TextButton")
    TpBtn.Size = UDim2.new(1, -10, 0, 40)
    TpBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
    TpBtn.Text = "Teleportar para: " .. loc[1]
    TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TpBtn.TextSize = 16
    TpBtn.Font = Enum.Font.GothamBold
    TpBtn.Parent = TScroll
    
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 8)
    TCorner.Parent = TpBtn
    
    TpBtn.MouseButton1Click:Connect(function()
        RootPart.CFrame = CFrame.new(loc[2])
    end)
end

-- ========== LOOP PRINCIPAL ==========
RunService.Heartbeat:Connect(function()
    -- Auto Farm
    if Settings.AutoFarm then
        for _, item in pairs(Workspace:GetDescendants()) do
            if item:IsA("BasePart") and (item.Position - RootPart.Position).Magnitude < 20 then
                -- Verificar se é item valioso pelo nome
                local name = item.Name:lower()
                if name:find("gold") or name:find("silver") or name:find("bond") or name:find("weapon") or name:find("med") then
                    RootPart.CFrame = item.CFrame
                    wait(0.1)
                end
            end
        end
    end
    
    -- ESP
    if Settings.ESP then
        -- Limpar ESP antigo
        for _, obj in pairs(ESPObjects) do
            if obj then obj:Destroy() end
        end
        ESPObjects = {}
        
        -- Criar novo ESP
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local ESP = Instance.new("BillboardGui")
                ESP.Size = UDim2.new(0, 100, 0, 40)
                ESP.AlwaysOnTop = true
                ESP.StudsOffset = Vector3.new(0, 3, 0)
                ESP.Parent = CoreGui
                
                local Text = Instance.new("TextLabel")
                Text.Size = UDim2.new(1, 0, 1, 0)
                Text.BackgroundTransparency = 1
                Text.Text = player.Name
                Text.TextColor3 = Color3.fromRGB(255, 0, 0)
                Text.TextStrokeTransparency = 0
                Text.Parent = ESP
                
                ESP.Adornee = player.Character.HumanoidRootPart
                table.insert(ESPObjects, ESP)
            end
        end
        wait(1) -- Atualizar a cada segundo
    end
end)

-- Fechar GUI
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    -- Desligar tudo
    Settings.Fly = false
    Settings.Noclip = false
    if FlyConnection then FlyConnection:Disconnect() end
    if NoclipConnection then NoclipConnection:Disconnect() end
end)

-- Drag (Mover GUI)
local dragging = false
local dragInput, dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Notificação de carregamento
local Notif = Instance.new("Frame")
Notif.Size = UDim2.new(0, 300, 0, 60)
Notif.Position = UDim2.new(0.5, -150, 0, -100)
Notif.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
Notif.Parent = ScreenGui

local NCorner = Instance.new("UICorner")
NCorner.CornerRadius = UDim.new(0, 10)
NCorner.Parent = Notif

local NText = Instance.new("TextLabel")
NText.Size = UDim2.new(1, 0, 1, 0)
NText.BackgroundTransparency = 1
NText.Text = "✅ Hub Carregado com Sucesso!"
NText.TextColor3 = Color3.fromRGB(255, 255, 255)
NText.TextSize = 18
NText.Font = Enum.Font.GothamBold
NText.Parent = Notif

-- Animar entrada
Notif.Position = UDim2.new(0.5, -150, 0, -100)
wait(0.5)
TweenService:Create(Notif, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -150, 0, 20)}):Play()
wait(3)
TweenService:Create(Notif, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -150, 0, -100)}):Play()
wait(0.5)
Notif:Destroy()

print("Dead Rails Premium Hub carregado!")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text or object.Name
    label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard
    
    billboard.Parent = ESPFolder
    
    -- Atualizar posição se necessário
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent then
            billboard:Destroy()
            connection:Disconnect()
        end
    end)
    
    return billboard
end

local function UpdateESP()
    if not getgenv().DeadRailsConfig.ESP.Enabled then
        ESPFolder:ClearAllChildren()
        return
    end
    
    -- ESP para inimigos[^4^][^5^]
    if getgenv().DeadRailsConfig.ESP.ShowEnemies then
        for _, enemy in pairs(Workspace:GetDescendants()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                if enemy ~= Character then
                    local isEnemy = false
                    local color = Color3.fromRGB(255, 0, 0)
                    local name = enemy.Name:lower()
                    
                    if name:find("zombie") or name:find("runner") then
                        color = Color3.fromRGB(0, 255, 0)
                        isEnemy = true
                    elseif name:find("vampire") then
                        color = Color3.fromRGB(138, 0, 0)
                        isEnemy = true
                    elseif name:find("werewolf") then
                        color = Color3.fromRGB(139, 69, 19)
                        isEnemy = true
                    elseif name:find("outlaw") or name:find("bandit") then
                        color = Color3.fromRGB(255, 140, 0)
                        isEnemy = true
                    elseif name:find("wolf") then
                        color = Color3.fromRGB(128, 128, 128)
                        isEnemy = true
                    end
                    
                    if isEnemy then
                        CreateESP(enemy, color, enemy.Name .. " [" .. math.floor(enemy.Humanoid.Health) .. "HP]")
                    end
                end
            end
        end
    end
    
    -- ESP para itens valiosos[^6^]
    if getgenv().DeadRailsConfig.ESP.ShowItems then
        for _, item in pairs(Workspace:GetDescendants()) do
            if item:IsA("BasePart") or item:IsA("MeshPart") then
                local name = item.Name:lower()
                local isValuable = false
                local color = Color3.fromRGB(255, 215, 0)
                
                for _, v in pairs(ValuableItems) do
                    if name:find(v:lower()) then
                        isValuable = true
                        break
                    end
                end
                
                if not isValuable then
                    for _, v in pairs(FuelItems) do
                        if name:find(v:lower()) then
                            isValuable = true
                            color = Color3.fromRGB(139, 69, 19)
                            break
                        end
                    end
                end
                
                if not isValuable then
                    for _, v in pairs(WeaponItems) do
                        if name:find(v:lower()) then
                            isValuable = true
                            color = Color3.fromRGB(0, 191, 255)
                            break
                        end
                    end
                end
                
                if not isValuable then
                    for _, v in pairs(MedicalItems) do
                        if name:find(v:lower()) then
                            isValuable = true
                            color = Color3.fromRGB(255, 105, 180)
                            break
                        end
                    end
                end
                
                if isValuable and (item.Position - HumanoidRootPart.Position).Magnitude < 100 then
                    CreateESP(item, color, item.Name .. " [" .. math.floor((item.Position - HumanoidRootPart.Position).Magnitude) .. "m]")
                end
            end
        end
    end
end

-- Sistema de Auto Farm
local function GetNearbyItems()
    local items = {}
    for _, item in pairs(Workspace:GetDescendants()) do
        if item:IsA("BasePart") or item:IsA("MeshPart") then
            local distance = (item.Position - HumanoidRootPart.Position).Magnitude
            if distance <= getgenv().DeadRailsConfig.AutoFarm.CollectionRadius then
                table.insert(items, {Item = item, Distance = distance})
            end
        end
    end
    return items
end

local function ShouldCollectItem(item)
    local name = item.Name:lower()
    
    if getgenv().DeadRailsConfig.AutoFarm.CollectValuables then
        for _, v in pairs(ValuableItems) do
            if name:find(v:lower()) then return true, "Valuable" end
        end
    end
    
    if getgenv().DeadRailsConfig.AutoFarm.CollectFuel then
        for _, v in pairs(FuelItems) do
            if name:find(v:lower()) then return true, "Fuel" end
        end
    end
    
    if getgenv().DeadRailsConfig.AutoFarm.CollectMedical then
        for _, v in pairs(MedicalItems) do
            if name:find(v:lower()) then return true, "Medical" end
        end
    end
    
    if getgenv().DeadRailsConfig.AutoFarm.CollectWeapons then
        for _, v in pairs(WeaponItems) do
            if name:find(v:lower()) then return true, "Weapon" end
        end
    end
    
    return false
end

local function CollectItem(item)
    local args = {
        [1] = item
    }
    
    -- Tentar diferentes métodos de coleta comuns em Dead Rails
    pcall(function()
        ReplicatedStorage.Remotes.PickupItem:FireServer(unpack(args))
    end)
    
    pcall(function()
        ReplicatedStorage.Events.Pickup:FireServer(item)
    end)
    
    -- Mover personagem até o item se estiver perto
    if (item.Position - HumanoidRootPart.Position).Magnitude < 10 then
        HumanoidRootPart.CFrame = item.CFrame
    end
end

-- Sistema de Combate
local function GetClosestEnemy()
    local closestEnemy = nil
    local closestDistance = math.huge
    
    for _, enemy in pairs(Workspace:GetDescendants()) do
        if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
            if enemy ~= Character then
                local distance = (enemy.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                if distance < closestDistance and distance <= getgenv().DeadRailsConfig.AutoFarm.SafeDistance then
                    closestDistance = distance
                    closestEnemy = enemy
                end
            end
        end
    end
    
    return closestEnemy, closestDistance
end

local function AttackEnemy(enemy)
    if not enemy or not enemy:FindFirstChild("Humanoid") then return end
    
    -- Auto Aim
    if getgenv().DeadRailsConfig.Combat.AutoAim then
        HumanoidRootPart.CFrame = CFrame.lookAt(HumanoidRootPart.Position, enemy.HumanoidRootPart.Position)
    end
    
    -- One Hit Kill (tentar diferentes métodos)
    if getgenv().DeadRailsConfig.Combat.OneHitKill then
        pcall(function()
            enemy.Humanoid.Health = 0
        end)
        
        pcall(function()
            ReplicatedStorage.Remotes.Damage:FireServer(enemy.Humanoid, 999999)
        end)
    end
    
    -- Dano normal via ferramenta equipada
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
    end
end

-- Sistema de Movimentação Avançada
local flyConnection
local noclipConnection
local moveConnection

local function EnableFly()
    if flyConnection then flyConnection:Disconnect() end
    
    local flying = true
    local speed = getgenv().DeadRailsConfig.Movement.FlySpeed
    
    flyConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().DeadRailsConfig.Movement.FlyEnabled then return end
        
        local direction = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + Workspace.CurrentCamera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - Workspace.CurrentCamera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - Workspace.CurrentCamera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + Workspace.CurrentCamera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            direction = direction - Vector3.new(0, 1, 0)
        end
        
        if direction.Magnitude > 0 then
            direction = direction.Unit * speed
            HumanoidRootPart.Velocity = direction
            Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        else
            HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

local function EnableNoClip()
    if noclipConnection then noclipConnection:Disconnect() end
    
    noclipConnection = RunService.Stepped:Connect(function()
        if getgenv().DeadRailsConfig.Movement.NoClip then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

-- Sistema de Teleporte e Exploração
local function TeleportTo(position)
    HumanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 10, 0))
end

local function FindTrain()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("train") or obj.Name:lower():find("locomotive") then
            return obj
        end
    end
    return nil
end

local function AutoDriveTrain()
    if not getgenv().DeadRailsConfig.Train.AutoDrive then return end
    
    local train = FindTrain()
    if train then
        -- Tentar sentar no assento do motorista[^2^]
        for _, part in pairs(train:GetDescendants()) do
            if part.Name:lower():find("seat") or part.Name:lower():find("driver") then
                HumanoidRootPart.CFrame = part.CFrame
                wait(0.5)
                -- Simular pressionamento de W para acelerar
                -- Isso depende do sistema específico do jogo
                break
            end
        end
    end
end

-- GUI Premium
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DeadRailsUltimateHub"
    ScreenGui.Parent = game.CoreGui
    
    -- Frame Principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Cantos arredondados
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainFrame
    
    -- Gradiente
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
    })
    Gradient.Parent = MainFrame
    
    -- Título
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
    Title.Text = "🚂 DEAD RAILS ULTIMATE HUB v3.0"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title
    
    -- Botão Fechar
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 16
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = MainFrame
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Abas
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(0, 150, 1, -40)
    TabFrame.Position = UDim2.new(0, 0, 0, 40)
    TabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TabFrame.Parent = MainFrame
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabFrame
    
    -- Conteúdo das Abas
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Size = UDim2.new(1, -160, 1, -50)
    ContentFrame.Position = UDim2.new(0, 155, 0, 45)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ScrollBarThickness = 5
    ContentFrame.Parent = MainFrame
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 8)
    ContentCorner.Parent = ContentFrame
    
    -- Layout
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 10)
    ListLayout.Parent = ContentFrame
    
    -- Função para criar botões toggle
    local function CreateToggle(parent, text, configPath, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(0.95, 0, 0, 35)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        ToggleFrame.Parent = parent
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 6)
        ToggleCorner.Parent = ToggleFrame
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0.05, 0, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 14
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame
        
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0.2, 0, 0.7, 0)
        Button.Position = UDim2.new(0.75, 0, 0.15, 0)
        Button.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
        Button.Text = "OFF"
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 12
        Button.Font = Enum.Font.GothamBold
        Button.Parent = ToggleFrame
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 4)
        ButtonCorner.Parent = Button
        
        Button.MouseButton1Click:Connect(function()
            local paths = string.split(configPath, ".")
            local current = getgenv().DeadRailsConfig
            for i = 1, #paths - 1 do
                current = current[paths[i]]
            end
            
            current[paths[#paths]] = not current[paths[#paths]]
            local state = current[paths[#paths]]
            
            Button.Text = state and "ON" or "OFF"
            Button.BackgroundColor3 = state and Color3.fromRGB(0, 139, 0) or Color3.fromRGB(139, 0, 0)
            
            if callback then callback(state) end
        end)
        
        return ToggleFrame
    end
    
    -- Criar Seções
    local Sections = {
        {Name = "Auto Farm", Icon = "💰"},
        {Name = "Movimento", Icon = "🏃"},
        {Name = "Visual", Icon = "👁️"},
        {Name = "Trem", Icon = "🚂"},
        {Name = "Combate", Icon = "⚔️"},
        {Name = "Teleporte", Icon = "🎯"}
    }
    
    local CurrentTab = "Auto Farm"
    
    local function ShowTab(tabName)
        ContentFrame:ClearAllChildren()
        ListLayout.Parent = ContentFrame
        
        if tabName == "Auto Farm" then
            CreateToggle(ContentFrame, "Auto Farm Master", "AutoFarm.Enabled")
            CreateToggle(ContentFrame, "Coletar Valores (Ouro/Prata)", "AutoFarm.CollectValuables")
            CreateToggle(ContentFrame, "Coletar Combustível", "AutoFarm.CollectFuel")
            CreateToggle(ContentFrame, "Coletar Armas", "AutoFarm.CollectWeapons")
            CreateToggle(ContentFrame, "Coletar Medicamentos", "AutoFarm.CollectMedical")
            CreateToggle(ContentFrame, "Auto Matar Inimigos", "AutoFarm.AutoKillEnemies")
            CreateToggle(ContentFrame, "Coletar Corpos", "AutoFarm.AutoCollectCorpses")
            
        elseif tabName == "Movimento" then
            CreateToggle(ContentFrame, "Super Velocidade", "Movement.SpeedEnabled", function(state)
                if state then
                    Humanoid.WalkSpeed = getgenv().DeadRailsConfig.Movement.SpeedValue
                else
                    Humanoid.WalkSpeed = 16
                end
            end)
            
            CreateToggle(ContentFrame, "Fly (Voo)", "Movement.FlyEnabled", function(state)
                if state then EnableFly() else if flyConnection then flyConnection:Disconnect() end end
            end)
            
            CreateToggle(ContentFrame, "No Clip", "Movement.NoClip", function(state)
                if state then EnableNoClip() else if noclipConnection then noclipConnection:Disconnect() end end
            end)
            
            CreateToggle(ContentFrame, "Pulo Infinito", "Movement.InfiniteJump")
            CreateToggle(ContentFrame, "Auto Sprint", "Movement.AutoSprint")
            
        elseif tabName == "Visual" then
            CreateToggle(ContentFrame, "ESP Master", "ESP.Enabled")
            CreateToggle(ContentFrame, "Mostrar Inimigos", "ESP.ShowEnemies")
            CreateToggle(ContentFrame, "Mostrar Itens", "ESP.ShowItems")
            CreateToggle(ContentFrame, "Mostrar Trem", "ESP.ShowTrain")
            CreateToggle(ContentFrame, "Mostrar Safe Zones", "ESP.ShowSafeZones")
            
        elseif tabName == "Trem" then
            CreateToggle(ContentFrame, "Auto Pilotar", "Train.AutoDrive")
            CreateToggle(ContentFrame, "Auto Abastecer", "Train.AutoFuel")
            CreateToggle(ContentFrame, "Parar em Cidades", "Train.StopAtTowns")
            CreateToggle(ContentFrame, "Parar em Safe Zones", "Train.StopAtSafeZones")
            
        elseif tabName == "Combate" then
            CreateToggle(ContentFrame, "Auto Aim", "Combat.AutoAim")
            CreateToggle(ContentFrame, "One Hit Kill", "Combat.OneHitKill")
            CreateToggle(ContentFrame, "God Mode", "Combat.GodMode", function(state)
                if state then
                    Humanoid.MaxHealth = math.huge
                    Humanoid.Health = math.huge
                else
                    Humanoid.MaxHealth = 100
                    Humanoid.Health = 100
                end
            end)
            CreateToggle(ContentFrame, "Munição Infinita", "Combat.InfiniteAmmo")
            
        elseif tabName == "Teleporte" then
            for _, loc in pairs(ImportantLocations) do
                local TeleportBtn = Instance.new("TextButton")
                TeleportBtn.Size = UDim2.new(0.95, 0, 0, 40)
                TeleportBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
                TeleportBtn.Text = loc.Name
                TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                TeleportBtn.Font = Enum.Font.GothamBold
                TeleportBtn.Parent = ContentFrame
                
                TeleportBtn.MouseButton1Click:Connect(function()
                    TeleportTo(loc.Position)
                end)
            end
        end
    end
    
    -- Criar botões de aba
    for i, section in ipairs(Sections) do
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0.9, 0, 0, 40)
        TabBtn.Position = UDim2.new(0.05, 0, 0, 10 + (i-1) * 45)
        TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        TabBtn.Text = section.Icon .. " " .. section.Name
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.Parent = TabFrame
        
        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 6)
        TabBtnCorner.Parent = TabBtn
        
        TabBtn.MouseButton1Click:Connect(function()
            CurrentTab = section.Name
            ShowTab(CurrentTab)
            -- Resetar cores
            for _, btn in pairs(TabFrame:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                end
            end
            TabBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
        end)
    end
    
    -- Botão Toggle GUI (minimizar)
    local ToggleGuiBtn = Instance.new("TextButton")
    ToggleGuiBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleGuiBtn.Position = UDim2.new(0, 10, 0.5, -25)
    ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
    ToggleGuiBtn.Text = "🚂"
    ToggleGuiBtn.TextSize = 24
    ToggleGuiBtn.Parent = ScreenGui
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleGuiBtn
    
    ToggleGuiBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)
    
    ShowTab("Auto Farm")
    
    -- Drag functionality
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Loops Principais
RunService.Heartbeat:Connect(function()
    -- Auto Farm Loop
    if getgenv().DeadRailsConfig.AutoFarm.Enabled then
        local items = GetNearbyItems()
        for _, data in pairs(items) do
            local shouldCollect, type = ShouldCollectItem(data.Item)
            if shouldCollect then
                CollectItem(data.Item)
            end
        end
        
        -- Auto Kill
        if getgenv().DeadRailsConfig.AutoFarm.AutoKillEnemies then
            local enemy, distance = GetClosestEnemy()
            if enemy and distance < 10 then
                AttackEnemy(enemy)
            end
        end
    end
    
    -- ESP Update
    if tick() % 1 < 0.03 then -- Atualizar a cada segundo
        UpdateESP()
    end
    
    -- Movimentação
    if getgenv().DeadRailsConfig.Movement.AutoSprint then
        Humanoid.WalkSpeed = getgenv().DeadRailsConfig.Movement.SpeedEnabled and getgenv().DeadRailsConfig.Movement.SpeedValue or 20
    end
    
    -- Infinite Jump
    if getgenv().DeadRailsConfig.Movement.InfiniteJump then
        UserInputService.JumpRequest:Connect(function()
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end)

-- Inicialização
CreateGUI()

-- Notificação
local NotifGui = Instance.new("ScreenGui", game.CoreGui)
local NotifFrame = Instance.new("TextLabel")
NotifFrame.Size = UDim2.new(0, 300, 0, 50)
NotifFrame.Position = UDim2.new(0.5, -150, 0, 20)
NotifFrame.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
NotifFrame.Text = "✅ Dead Rails Ultimate Hub Carregado!"
NotifFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
NotifFrame.Font = Enum.Font.GothamBold
NotifFrame.TextSize = 18

local NotifCorner = Instance.new("UICorner")
NotifCorner.CornerRadius = UDim.new(0, 10)
NotifCorner.Parent = NotifFrame

game:GetService("TweenService"):Create(NotifFrame, TweenInfo.new(3), {Position = UDim2.new(0.5, -150, 0, -100)}):Play()
wait(3)
NotifGui:Destroy()

print([[
    🚂 DEAD RAILS ULTIMATE HUB v3.0 🚂
    =================================
    Comandos:
    - GUI Toggle: Clique no botão 🚂
    - Auto Farm: Coleta automática de recursos[^1^]
    - ESP: Visualização através de paredes
    - Teleporte: Viaje para qualquer localização[^7^]
    - Fly: Voo livre pelo mapa
    
    Dicas:
    - Use Auto Farm em Safe Zones para farmar bonds[^3^]
    - Colete corpos de vampiros e lobisomens para vender[^4^]
    - Use o trem automaticamente para chegar ao Final Bridge (78km)[^2^]
]])
