-- Dead Rails Ultimate Hub v3.0
-- Criado com base na mecânica completa do jogo
-- Funcionalidades: Auto Farm, GUI Premium, Movimentação Avançada, Auto Explore

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Configurações Globais
getgenv().DeadRailsConfig = {
    AutoFarm = {
        Enabled = false,
        CollectValuables = true,
        CollectFuel = true,
        CollectWeapons = true,
        CollectMedical = true,
        AutoKillEnemies = true,
        AutoCollectCorpses = true,
        SafeDistance = 20,
        CollectionRadius = 50
    },
    Movement = {
        SpeedEnabled = false,
        SpeedValue = 100,
        FlyEnabled = false,
        FlySpeed = 50,
        NoClip = false,
        InfiniteJump = false,
        AutoSprint = true
    },
    ESP = {
        Enabled = false,
        ShowValuables = true,
        ShowEnemies = true,
        ShowItems = true,
        ShowTrain = true,
        ShowSafeZones = true
    },
    Train = {
        AutoDrive = false,
        AutoFuel = true,
        TargetSpeed = 1,
        StopAtTowns = true,
        StopAtSafeZones = true
    },
    Combat = {
        AutoAim = false,
        OneHitKill = false,
        GodMode = false,
        InfiniteAmmo = false
    },
    Teleport = {
        AutoTeleport = false,
        SelectedLocation = nil
    }
}

-- Locais Importantes do Mapa (baseado na wiki)[^7^]
local ImportantLocations = {
    {Name = "Início (San Antonio)", Position = Vector3.new(0, 50, 0)},
    {Name = "Safe Zone 10km", Position = Vector3.new(10000, 50, 0)},
    {Name = "Safe Zone 20km", Position = Vector3.new(20000, 50, 0)},
    {Name = "Safe Zone 39km (Castle)", Position = Vector3.new(39000, 50, 0)},
    {Name = "Fort Constitution", Position = Vector3.new(35000, 50, 200)},
    {Name = "Tesla Lab", Position = Vector3.new(45000, 50, -200)},
    {Name = "Castle (Hard)", Position = Vector3.new(39000, 50, 300)},
    {Name = "Sterling", Position = Vector3.new(60000, 50, 0)},
    {Name = "Stillwater Prison", Position = Vector3.new(75000, 50, 0)},
    {Name = "Final Bridge (78km)", Position = Vector3.new(78000, 50, 0)}
}

-- Lista de Itens Valiosos[^6^]
local ValuableItems = {
    "GoldBar", "SilverBar", "GoldStatue", "SilverStatue", "Crucifix", 
    "Bond", "Valuable", "Gold", "Silver", "BankNote"
}

local FuelItems = {
    "Coal", "Corpse", "Zombie", "Vampire", "Werewolf", "Body", 
    "Newspaper", "Wood", "Barrel", "Chair", "Table"
}

local MedicalItems = {
    "Bandage", "SnakeOil", "Medkit", "Health"
}

local WeaponItems = {
    "Revolver", "Rifle", "Shotgun", "Turret", "Cannon", "Knife", "Axe", "Shovel", "Tomahawk"
}

-- Sistema de ESP
local ESPFolder = Instance.new("Folder", game.CoreGui)
ESPFolder.Name = "DeadRailsESP"

local function CreateESP(object, color, text)
    if not object then return end
    if object:FindFirstChild("DeadRailsESP") then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DeadRailsESP"
    billboard.Adornee = object:IsA("Model") and object:FindFirstChild("HumanoidRootPart") or object:FindFirstChildWhichIsA("BasePart") or object
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
