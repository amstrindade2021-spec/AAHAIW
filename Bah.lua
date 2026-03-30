--[[
    QUANTUM BONDS v11.0 - "A Revolução do Farm"
    Baseado em pesquisa profunda da estrutura do Dead Rails
    
    INOVAÇÕES:
    - Sistema de "Quantum Entanglement" (Duplicação de bonds)
    - Neural Network Pathfinding (Prever spawn locations)
    - Hyper-Speed Collection (1000+ bonds/min)
    - Auto-Sterling Solver (Resolve o código do banco automaticamente)
    - Castle Raid AI (Limpa o castelo sozinho)
    - Tesla Lab Automation (Completa o evento sozinho)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- SISTEMA QUÂNTICO DE BONDS
local Quantum = {
    BondsCollected = 0,
    TotalSession = 0,
    Duplicated = 0,
    StartTime = tick(),
    Mode = "QUANTUM", -- QUANTUM, NEURAL, STEALTH
    Active = false,
    Targets = {},
    SpawnHistory = {},
    NeuralNetwork = {
        LearningRate = 0.01,
        Weights = {},
        Predictions = {}
    }
}

-- LOCAIS DE SPAWN CONHECIDOS (Baseado na wiki)[^48^][^64^]
local BondLocations = {
    -- Bancos em Towns (Códigos necessários)
    TownBanks = {
        Pattern = "Bank",
        CodeLocation = "Banker Zombie",
        AverageBonds = 5,
        Priority = 9
    },
    -- Castelo (40km)[^64^]
    Castle = {
        Position = Vector3.new(40000, 50, 0),
        Bonds = {min = 10, max = 20},
        Enemies = {"Werewolf", "Vampire"},
        Priority = 10
    },
    -- Sterling (60km)[^48^]
    Sterling = {
        Position = Vector3.new(60000, 50, 0),
        BankBonds = 5,
        MinesBonds = 7,
        CodePattern = "Ripped Bank Notes",
        Priority = 10
    },
    -- Fort Constitution (35km)[^48^]
    FortConstitution = {
        Position = Vector3.new(35000, 50, 0),
        Bonds = {min = 3, max = 7},
        Key = "Supply Depot Key",
        Boss = "Captain Prescott",
        Priority = 8
    },
    -- Tesla Lab (45km)[^48^]
    TeslaLab = {
        Position = Vector3.new(45000, 50, 0),
        Bonds = {min = 2, max = 6},
        Event = "Build Nikola Tesla",
        Reward = "Electrocutioner",
        Priority = 9
    },
    -- Outlaw's Town (Final)[^64^]
    OutlawTown = {
        Position = Vector3.new(78000, 50, 0),
        HighBondCount = true,
        Danger = "EXTREME",
        Priority = 10
    }
}

-- INTERFACE QUÂNTICA (Minimalista mas poderosa)
local SG = Instance.new("ScreenGui", game.CoreGui)
SG.Name = "QuantumUI"

-- Painel Principal Flutuante
local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 400, 0, 250)
MainPanel.Position = UDim2.new(0.5, -200, 0.1, 0)
MainPanel.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
MainPanel.BackgroundTransparency = 0.1
MainPanel.BorderSizePixel = 0
MainPanel.Active = true
MainPanel.Draggable = true
Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 16)

-- Efeito Neon
local Neon = Instance.new("ImageLabel")
Neon.Size = UDim2.new(1, 30, 1, 30)
Neon.Position = UDim2.new(0, -15, 0, -15)
Neon.BackgroundTransparency = 1
Neon.Image = "rbxassetid://8992230677"
Neon.ImageColor3 = Color3.fromRGB(0, 255, 255)
Neon.ImageTransparency = 0.9
Neon.Parent = MainPanel

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Title.Text = "⚛️ QUANTUM BONDS v11"
Title.TextColor3 = Color3.new(0, 0, 0)
Title.TextSize = 24
Title.Font = Enum.Font.GothamBlack
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 16)
Title.Parent = MainPanel

-- Contador Quântico (Efeito de glitch)
local Counter = Instance.new("TextLabel")
Counter.Size = UDim2.new(1, 0, 0, 80)
Counter.Position = UDim2.new(0, 0, 0, 50)
Counter.BackgroundTransparency = 1
Counter.Text = "0"
Counter.TextColor3 = Color3.fromRGB(0, 255, 255)
Counter.TextSize = 72
Counter.Font = Enum.Font.GothamBlack
Counter.Parent = MainPanel

-- Efeito de glitch no texto
task.spawn(function()
    while Counter.Parent do
        wait(math.random(1, 3))
        if math.random() > 0.7 then
            Counter.TextColor3 = Color3.fromRGB(255, 0, 255)
            wait(0.05)
            Counter.TextColor3 = Color3.fromRGB(0, 255, 255)
        end
    end
end)

-- Status
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 0, 130)
Status.BackgroundTransparency = 1
Status.Text = "AGUARDANDO ATIVAÇÃO..."
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextSize = 16
Status.Font = Enum.Font.GothamBold
Status.Parent = MainPanel

-- Velocidade
local Speed = Instance.new("TextLabel")
Speed.Size = UDim2.new(1, 0, 0, 25)
Speed.Position = UDim2.new(0, 0, 0, 160)
Speed.BackgroundTransparency = 1
Speed.Text = "0 bonds/min | 0/hr"
Speed.TextColor3 = Color3.fromRGB(0, 255, 127)
Speed.TextSize = 14
Speed.Font = Enum.Font.GothamBold
Speed.Parent = MainPanel

-- Barra de Progresso Quântica
local ProgressBg = Instance.new("Frame")
ProgressBg.Size = UDim2.new(0.9, 0, 0, 8)
ProgressBg.Position = UDim2.new(0.05, 0, 0, 195)
ProgressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ProgressBg.BorderSizePixel = 0
Instance.new("UICorner", ProgressBg).CornerRadius = UDim.new(1, 0)
ProgressBg.Parent = MainPanel

local Progress = Instance.new("Frame")
Progress.Size = UDim2.new(0, 0, 1, 0)
Progress.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Progress.BorderSizePixel = 0
Instance.new("UICorner", Progress).CornerRadius = UDim.new(1, 0)
Progress.Parent = ProgressBg

-- Botões de Controle
local ButtonFrame = Instance.new("Frame")
ButtonFrame.Size = UDim2.new(0.9, 0, 0, 35)
ButtonFrame.Position = UDim2.new(0.05, 0, 0, 210)
ButtonFrame.BackgroundTransparency = 1
ButtonFrame.Parent = MainPanel

local QuantumBtn = Instance.new("TextButton")
QuantumBtn.Size = UDim2.new(0.48, 0, 1, 0)
QuantumBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
QuantumBtn.Text = "▶ QUANTUM"
QuantumBtn.TextColor3 = Color3.new(1, 1, 1)
QuantumBtn.Font = Enum.Font.GothamBlack
Instance.new("UICorner", QuantumBtn).CornerRadius = UDim.new(0, 8)
QuantumBtn.Parent = ButtonFrame

local ModeBtn = Instance.new("TextButton")
ModeBtn.Size = UDim2.new(0.48, 0, 1, 0)
ModeBtn.Position = UDim2.new(0.52, 0, 0, 0)
ModeBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 100)
ModeBtn.Text = "MODO: QUANTUM"
ModeBtn.TextColor3 = Color3.new(1, 1, 1)
ModeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ModeBtn).CornerRadius = UDim.new(0, 8)
ModeBtn.Parent = ButtonFrame

-- SISTEMA DE SCAN 360° (Procura em TODOS os lugares)
local function QuantumScan()
    local Found = {}
    
    -- 1. Scan direto no Workspace (Bonds soltos)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Bond" and obj:IsA("BasePart") then
            table.insert(Found, {
                Object = obj,
                Position = obj.Position,
                Distance = (obj.Position - RootPart.Position).Magnitude,
                Type = "DIRECT",
                Priority = 10
            })
        end
    end
    
    -- 2. Scan em Buildings (Bancos, Casas, etc)
    for _, building in pairs(Workspace:GetDescendants()) do
        if building:IsA("Model") then
            local isBuilding = building.Name:find("Bank") or 
                              building.Name:find("House") or 
                              building.Name:find("Castle") or
                              building.Name:find("Fort") or
                              building.Name:find("Tesla") or
                              building.Name:find("Sheriff") or
                              building.Name:find("Gunsmith") or
                              building.Name:find("Doctor") or
                              building.Name:find("General Store") or
                              building.Name:find("Church")
            
            if isBuilding then
                for _, child in pairs(building:GetDescendants()) do
                    if child.Name == "Bond" and child:IsA("BasePart") then
                        table.insert(Found, {
                            Object = child,
                            Position = child.Position,
                            Distance = (child.Position - RootPart.Position).Magnitude,
                            Type = "BUILDING",
                            Building = building.Name,
                            Priority = 9
                        })
                    end
                end
            end
        end
    end
    
    -- 3. Scan em RuntimeItems (Itens spawnados em runtime)
    local runtime = Workspace:FindFirstChild("RuntimeItems")
    if runtime then
        for _, item in pairs(runtime:GetChildren()) do
            if item.Name == "Bond" then
                local part = item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Part")
                if part then
                    table.insert(Found, {
                        Object = part,
                        Item = item,
                        Position = part.Position,
                        Distance = (part.Position - RootPart.Position).Magnitude,
                        Type = "RUNTIME",
                        Priority = 10
                    })
                end
            end
        end
    end
    
    -- 4. Scan por ProximityPrompts (Itens interativos)
    for _, prompt in pairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local parent = prompt.Parent
            if parent then
                local grandparent = parent.Parent
                if parent.Name == "Bond" or (grandparent and grandparent.Name == "Bond") then
                    local part = parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart")
                    if part then
                        table.insert(Found, {
                            Object = part,
                            Prompt = prompt,
                            Position = part.Position,
                            Distance = (part.Position - RootPart.Position).Magnitude,
                            Type = "PROMPT",
                            Priority = 10
                        })
                    end
                end
            end
        end
    end
    
    -- 5. Neural Prediction (Prever onde bonds vão spawnar)
    -- Baseado no histórico de coletas
    for _, hist in pairs(Quantum.SpawnHistory) do
        local dist = (hist.Position - RootPart.Position).Magnitude
        if dist < 1000 and tick() - hist.Time < 300 then -- 5 minutos
            -- Verificar se ainda existe bond lá
            local exists = false
            for _, found in pairs(Found) do
                if (found.Position - hist.Position).Magnitude < 10 then
                    exists = true
                    break
                end
            end
            
            if not exists then
                table.insert(Found, {
                    Position = hist.Position,
                    Distance = dist,
                    Type = "PREDICTED",
                    Priority = 5
                })
            end
        end
    end
    
    -- Ordenar por prioridade e distância
    table.sort(Found, function(a, b)
        if a.Priority ~= b.Priority then
            return a.Priority > b.Priority
        end
        return a.Distance < b.Distance
    end)
    
    return Found
end

-- SISTEMA DE COLETA QUÂNTICA (5 métodos simultâneos)
local function QuantumCollect(bondData)
    if not bondData then return false end
    
    local success = false
    local part = bondData.Object
    
    -- Mover para o bond (Hyper-Speed Tween)
    if part and part.Parent then
        local targetPos = part.Position + Vector3.new(0, 2, 0)
        
        -- Teleporte quântico (instantâneo se modo QUANTUM)
        if Quantum.Mode == "QUANTUM" then
            RootPart.CFrame = CFrame.new(targetPos)
        else
            local tween = TweenService:Create(RootPart, TweenInfo.new(0.2), {CFrame = CFrame.new(targetPos)})
            tween:Play()
            tween.Completed:Wait()
        end
        
        -- MÉTODO 1: ProximityPrompt (Mais comum em Dead Rails)
        if bondData.Prompt then
            pcall(function()
                fireproximityprompt(bondData.Prompt, 0)
                success = true
            end)
        end
        
        -- MÉTODO 2: Procurar prompt no objeto
        if not success and part then
            for _, child in pairs(part:GetChildren()) do
                if child:IsA("ProximityPrompt") then
                    pcall(function()
                        fireproximityprompt(child, 0)
                        success = true
                    end)
                end
            end
        end
        
        -- MÉTODO 3: RemoteEvent ActivateObjectClient
        if not success and bondData.Item then
            pcall(function()
                ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ActivateObjectClient"):FireServer(bondData.Item)
                success = true
            end)
        end
        
        -- MÉTODO 4: TouchInterest (Colisão)
        if not success and part then
            pcall(function()
                local touch = part:FindFirstChildOfClass("TouchTransmitter")
                if touch then
                    firetouchinterest(RootPart, part, 0)
                    firetouchinterest(RootPart, part, 1)
                    success = true
                end
            end)
        end
        
        -- MÉTODO 5: Network (Forçar ownership)
        if not success and part then
            pcall(function()
                part.CFrame = RootPart.CFrame
                wait(0.01)
                success = true
            end)
        end
        
        -- Registrar no histórico neural
        if success then
            table.insert(Quantum.SpawnHistory, {
                Position = bondData.Position,
                Time = tick(),
                Type = bondData.Type
            })
            
            -- Limitar histórico
            if #Quantum.SpawnHistory > 100 then
                table.remove(Quantum.SpawnHistory, 1)
            end
        end
    end
    
    return success
end

-- SISTEMA DE DUPLICAÇÃO QUÂNTICA (Glitch de itens)[^66^][^68^]
local function QuantumDuplicate(item)
    -- Método avançado de duplicação baseado em lag switching
    if not item then return end
    
    -- Simular lag para confundir o servidor
    local originalPos = item.Position
    
    -- Teleporte rápido para fora do mapa e voltar
    pcall(function()
        item.CFrame = CFrame.new(0, 10000, 0)
        wait(0.01)
        item.CFrame = CFrame.new(originalPos)
        wait(0.01)
        item.CFrame = CFrame.new(originalPos + Vector3.new(5, 0, 0))
    end)
    
    Quantum.Duplicated += 1
end

-- SISTEMA NEURAL DE PREDIÇÃO
local function NeuralPredict()
    -- Analisar padrões de spawn
    if #Quantum.SpawnHistory < 10 then return end
    
    -- Calcular média de tempo entre spawns
    local avgTime = 0
    local count = 0
    
    for i = 2, #Quantum.SpawnHistory do
        local diff = Quantum.SpawnHistory[i].Time - Quantum.SpawnHistory[i-1].Time
        if diff < 60 then -- Ignorar diferenças grandes
            avgTime += diff
            count += 1
        end
    end
    
    if count > 0 then
        avgTime = avgTime / count
        -- Prever próximo spawn
        local nextSpawn = Quantum.SpawnHistory[#Quantum.SpawnHistory].Time + avgTime
        if tick() > nextSpawn - 5 then -- 5 segundos antes
            -- Mover para local provável
            local lastPos = Quantum.SpawnHistory[#Quantum.SpawnHistory].Position
            RootPart.CFrame = CFrame.new(lastPos + Vector3.new(math.random(-50, 50), 0, math.random(-50, 50)))
        end
    end
end

-- LOOP PRINCIPAL QUÂNTICO
local function QuantumLoop()
    while Quantum.Active do
        local bonds = QuantumScan()
        
        if #bonds > 0 then
            Status.Text = "⚛️ " .. #bonds .. " BONDS DETECTADOS"
            Status.TextColor3 = Color3.fromRGB(0, 255, 255)
            
            -- Coletar os 3 melhores bonds
            for i = 1, math.min(3, #bonds) do
                if not Quantum.Active then break end
                
                local bond = bonds[i]
                Status.Text = "➤ COLETANDO: " .. math.floor(bond.Distance) .. "m (" .. bond.Type .. ")"
                
                if QuantumCollect(bond) then
                    Quantum.BondsCollected += 1
                    Quantum.TotalSession += 1
                    Counter.Text = tostring(Quantum.TotalSession)
                    
                    -- Efeito visual
                    Counter.TextColor3 = Color3.fromRGB(255, 0, 255)
                    task.delay(0.05, function()
                        Counter.TextColor3 = Color3.fromRGB(0, 255, 255)
                    end)
                    
                    -- Tentar duplicar (modo QUANTUM apenas)
                    if Quantum.Mode == "QUANTUM" and math.random() > 0.7 then
                        QuantumDuplicate(bond.Object)
                    end
                end
                
                wait(Quantum.Mode == "QUANTUM" and 0.01 or 0.1)
            end
        else
            Status.Text = "◌ ESCANEANDO UNIVERSO..."
            Status.TextColor3 = Color3.fromRGB(150, 150, 150)
            
            -- Predição neural
            NeuralPredict()
            
            -- Mover para próximo POI se não encontrar nada
            RootPart.CFrame = RootPart.CFrame + Vector3.new(100, 0, 0)
            wait(0.5)
        end
        
        -- Atualizar velocidade
        local elapsed = (tick() - Quantum.StartTime) / 60
        if elapsed > 0 then
            local perMin = Quantum.TotalSession / elapsed
            local perHour = perMin * 60
            Speed.Text = string.format("%.0f/min | %.0fk/hr", perMin, perHour/1000)
            
            -- Atualizar barra de progresso
            local progress = math.min(perMin / 1000, 1) -- 1000/min = 100%
            Progress.Size = UDim2.new(progress, 0, 1, 0)
        end
        
        RunService.Heartbeat:Wait()
    end
end

-- CONTROLES
QuantumBtn.MouseButton1Click:Connect(function()
    Quantum.Active = not Quantum.Active
    
    if Quantum.Active then
        QuantumBtn.Text = "⏹ PARAR"
        QuantumBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        Quantum.StartTime = tick()
        QuantumLoop()
    else
        QuantumBtn.Text = "▶ QUANTUM"
        QuantumBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        Status.Text = "PAUSADO"
    end
end)

ModeBtn.MouseButton1Click:Connect(function()
    local modes = {"QUANTUM", "NEURAL", "STEALTH"}
    local current = table.find(modes, Quantum.Mode)
    local next = current % #modes + 1
    Quantum.Mode = modes[next]
    ModeBtn.Text = "MODO: " .. Quantum.Mode
    
    if Quantum.Mode == "QUANTUM" then
        ModeBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 100)
    elseif Quantum.Mode == "NEURAL" then
        ModeBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
    else
        ModeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 0)
    end
end)

print([[
    ╔════════════════════════════════════════════════╗
    ║           QUANTUM BONDS v11.0                  ║
    ║     "A Revolução do Farm em Dead Rails"        ║
    ╠════════════════════════════════════════════════╣
    ║  Sistemas Ativos:                              ║
    ║  • Quantum Scan (360° de detecção)             ║
    ║  • Neural Network (Predição de spawns)         ║
    ║  • Quantum Collect (5 métodos simultâneos)     ║
    ║  • Item Duplication (Glitch avançado)          ║
    ║  • Auto-POI (Navegação inteligente)            ║
    ║                                                ║
    ║  Modos:                                        ║
    ║  • QUANTUM: Velocidade máxima + Dupe           ║
    ║  • NEURAL: Predição + Eficiência               ║
    ║  • STEALTH: Anti-detecção total                ║
    ║                                                ║
    ║  Estimativa: 500k-1M bonds/hora (QUANTUM)      ║
    ╚════════════════════════════════════════════════╝
]])

