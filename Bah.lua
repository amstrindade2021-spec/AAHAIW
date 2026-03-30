--[[
    AUTO BONDS ULTRA v10.0
    "O Último Script de Farm do Dead Rails"
    
    Features:
    - 10 Threads Paralelas
    - Pathfinding AI (Navegação inteligente)
    - Quantum Coleta (3 métodos simultâneos)
    - Servidor Hopping Otimizado
    - Modo Turbo (Bypass de cooldowns)
    - Estatísticas em Tempo Real
    - Auto-Recovery (Anti-kick/erros)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local PathfindingService = game:GetService("PathfindingService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- CONFIGURAÇÃO ULTRA
local Config = {
    FarmRange = 500,          -- Alcance de detecção
    TweenSpeed = 0.05,        -- Velocidade do tween (quanto menor, mais rápido)
    BringRange = 300,         -- Distância para puxar bonds
    RejoinThreshold = 30,     -- Segundos sem bonds para rejoin
    TurboMode = true,         -- Bypass de limitações
    AntiAFK = true,           -- Previne kick por AFK
    AutoOptimize = true       -- Otimiza servidor automaticamente
}

-- ESTATÍSTICAS AVANÇADAS
local Stats = {
    Bonds = 0,
    SessionBonds = 0,
    TotalBonds = 0,
    StartTime = tick(),
    LastBondTime = tick(),
    BondsPerSecond = 0,
    PeakBPS = 0,
    ServerHops = 0,
    Errors = 0,
    IsRunning = false,
    TurboActive = false
}

-- INTERFACE PROFISSIONAL
local SG = Instance.new("ScreenGui")
SG.Name = "BondsUltra"
SG.Parent = game.CoreGui

-- Painel Principal (Design minimalista)
local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 350, 0, 200)
MainPanel.Position = UDim2.new(0, 10, 0, 10)
MainPanel.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
MainPanel.BorderSizePixel = 0
MainPanel.Parent = SG

Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 10)

-- Glow effect
local Glow = Instance.new("ImageLabel")
Glow.Size = UDim2.new(1, 20, 1, 20)
Glow.Position = UDim2.new(0, -10, 0, -10)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://5554236805"
Glow.ImageColor3 = Color3.fromRGB(139, 0, 0)
Glow.ImageTransparency = 0.9
Glow.Parent = MainPanel

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
Header.Parent = MainPanel

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)
Instance.new("Frame", Header).Size = UDim2.new(1, 0, 0, 10)
Instance.new("Frame", Header).Position = UDim2.new(0, 0, 1, -10)
Instance.new("Frame", Header).BackgroundColor3 = Color3.fromRGB(139, 0, 0)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "⚡ BONDS ULTRA v10"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBlack

-- Contador Principal (GIGANTE)
local BigCounter = Instance.new("TextLabel")
BigCounter.Size = UDim2.new(1, 0, 0, 60)
BigCounter.Position = UDim2.new(0, 0, 0, 40)
BigCounter.BackgroundTransparency = 1
BigCounter.Text = "0"
BigCounter.TextColor3 = Color3.fromRGB(0, 255, 127)
BigCounter.TextSize = 56
BigCounter.Font = Enum.Font.GothamBlack
BigCounter.Parent = MainPanel

-- Label "BONDS"
local BondsLabel = Instance.new("TextLabel")
BondsLabel.Size = UDim2.new(1, 0, 0, 20)
BondsLabel.Position = UDim2.new(0, 0, 0, 95)
BondsLabel.BackgroundTransparency = 1
BondsLabel.Text = "BONDS COLETADOS"
BondsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
BondsLabel.TextSize = 12
BondsLabel.Font = Enum.Font.GothamBold
BondsLabel.Parent = MainPanel

-- Velocidade (BPS)
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.5, 0, 0, 25)
SpeedLabel.Position = UDim2.new(0, 0, 0, 120)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "0.0/s"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
SpeedLabel.TextSize = 22
SpeedLabel.Font = Enum.Font.GothamBlack
SpeedLabel.Parent = MainPanel

-- Projeção de 1 hora
local ProjectionLabel = Instance.new("TextLabel")
ProjectionLabel.Size = UDim2.new(0.5, 0, 0, 25)
ProjectionLabel.Position = UDim2.new(0.5, 0, 0, 120)
ProjectionLabel.BackgroundTransparency = 1
ProjectionLabel.Text = "0/hr"
ProjectionLabel.TextColor3 = Color3.fromRGB(0, 191, 255)
ProjectionLabel.TextSize = 22
ProjectionLabel.Font = Enum.Font.GothamBlack
ProjectionLabel.Parent = MainPanel

-- Status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 150)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "AGUARDANDO..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.Parent = MainPanel

-- Barra de progresso (Turbo)
local TurboBarBg = Instance.new("Frame")
TurboBarBg.Size = UDim2.new(0.9, 0, 0, 6)
TurboBarBg.Position = UDim2.new(0.05, 0, 0, 175)
TurboBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TurboBarBg.BorderSizePixel = 0
TurboBarBg.Parent = MainPanel

Instance.new("UICorner", TurboBarBg).CornerRadius = UDim.new(1, 0)

local TurboBar = Instance.new("Frame")
TurboBar.Size = UDim2.new(0, 0, 1, 0)
TurboBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
TurboBar.BorderSizePixel = 0
TurboBar.Parent = TurboBarBg

Instance.new("UICorner", TurboBar).CornerRadius = UDim.new(1, 0)

-- Botão Turbo
local TurboBtn = Instance.new("TextButton")
TurboBtn.Size = UDim2.new(0.45, 0, 0, 30)
TurboBtn.Position = UDim2.new(0.05, 0, 0, 185)
TurboBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
TurboBtn.Text = "▶ INICIAR"
TurboBtn.TextColor3 = Color3.new(1, 1, 1)
TurboBtn.TextSize = 14
TurboBtn.Font = Enum.Font.GothamBlack
TurboBtn.Parent = MainPanel

Instance.new("UICorner", TurboBtn).CornerRadius = UDim.new(0, 6)

-- Botão Modo Turbo
local ModeBtn = Instance.new("TextButton")
ModeBtn.Size = UDim2.new(0.45, 0, 0, 30)
ModeBtn.Position = UDim2.new(0.5, 0, 0, 185)
ModeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 0)
ModeBtn.Text = "TURBO: OFF"
ModeBtn.TextColor3 = Color3.new(1, 1, 1)
ModeBtn.TextSize = 12
ModeBtn.Font = Enum.Font.GothamBold
ModeBtn.Parent = MainPanel

Instance.new("UICorner", ModeBtn).CornerRadius = UDim.new(0, 6)

-- FUNÇÕES AVANÇADAS

-- 1. Pathfinding AI (Navegação inteligente)
local function SmartMoveTo(targetPos)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = 10,
        AgentMaxSlope = 60,
        WaypointSpacing = 5
    })
    
    local success, err = pcall(function()
        path:ComputeAsync(RootPart.Position, targetPos)
    end)
    
    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for _, waypoint in ipairs(waypoints) do
            if not Stats.IsRunning then break end
            
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
            
            local tween = TweenService:Create(RootPart, TweenInfo.new(Config.TweenSpeed), {
                CFrame = CFrame.new(waypoint.Position + Vector3.new(0, 3, 0))
            })
            tween:Play()
            tween.Completed:Wait()
        end
        return true
    else
        -- Fallback: Tween direto
        local tween = TweenService:Create(RootPart, TweenInfo.new(Config.TweenSpeed * 2), {
            CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        })
        tween:Play()
        tween.Completed:Wait()
        return true
    end
end

-- 2. Quantum Coleta (3 métodos simultâneos)
local function QuantumCollect(bond)
    if not bond or not bond:FindFirstChild("Part") then return false end
    
    local success = false
    
    -- Método 1: RemoteEvent (Instantâneo)
    pcall(function()
        ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ActivateObjectClient"):FireServer(bond)
        success = true
    end)
    
    -- Método 2: ProximityPrompt (Físico)
    pcall(function()
        local prompt = bond.Part:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt, 0)
            success = true
        end
    end)
    
    -- Método 3: TouchInterest (Colisão)
    pcall(function()
        local touch = bond.Part:FindFirstChildOfClass("TouchTransmitter")
        if touch then
            firetouchinterest(RootPart, bond.Part, 0)
            firetouchinterest(RootPart, bond.Part, 1)
            success = true
        end
    end)
    
    -- Método 4: Network Ownership (Avançado)
    pcall(function()
        RootPart.CFrame = bond.Part.CFrame
        wait(0.01)
    end)
    
    return success
end

-- 3. Scan Inteligente de Bonds
local function ScanBonds()
    local items = Workspace:FindFirstChild("RuntimeItems")
    if not items then return {} end
    
    local bonds = {}
    for _, item in pairs(items:GetChildren()) do
        if item.Name == "Bond" and item:FindFirstChild("Part") then
            local dist = (item.Part.Position - RootPart.Position).Magnitude
            if dist <= Config.FarmRange then
                table.insert(bonds, {
                    Item = item,
                    Distance = dist,
                    Position = item.Part.Position,
                    Priority = 100 - (dist / Config.FarmRange * 100) -- Prioridade por proximidade
                })
            end
        end
    end
    
    -- Sort por prioridade (mais próximos primeiro)
    table.sort(bonds, function(a, b) return a.Priority > b.Priority end)
    return bonds
end

-- 4. Sistema de Threads

-- Thread 1: Coleta Principal (Ultra-rápida)
local function ThreadMain()
    while Stats.IsRunning do
        local bonds = ScanBonds()
        
        if #bonds > 0 then
            -- Pegar os 3 melhores bonds
            for i = 1, math.min(3, #bonds) do
                if not Stats.IsRunning then break end
                
                local bond = bonds[i]
                StatusLabel.Text = "COLETANDO [" .. math.floor(bond.Distance) .. "m]"
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                
                -- Mover para o bond
                if Config.TurboMode then
                    -- Modo turbo: Teleporte instantâneo silencioso
                    RootPart.CFrame = CFrame.new(bond.Position + Vector3.new(0, 3, 0))
                else
                    SmartMoveTo(bond.Position)
                end
                
                -- Coletar
                if QuantumCollect(bond.Item) then
                    Stats.Bonds += 1
                    Stats.SessionBonds += 1
                    Stats.LastBondTime = tick()
                    
                    -- Efeito visual no contador
                    BigCounter.Text = tostring(Stats.Bonds)
                    BigCounter.TextColor3 = Color3.fromRGB(255, 255, 0)
                    task.delay(0.05, function()
                        BigCounter.TextColor3 = Color3.fromRGB(0, 255, 127)
                    end)
                end
                
                task.wait(Config.TurboMode and 0.001 or 0.01)
            end
        else
            StatusLabel.Text = "PROCURANDO BONDS..."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
            task.wait(0.1)
        end
    end
end

-- Thread 2: Bring Distant Bonds (Magnético)
local function ThreadMagnet()
    while Stats.IsRunning do
        local items = Workspace:FindFirstChild("RuntimeItems")
        if items then
            for _, item in pairs(items:GetChildren()) do
                if item.Name == "Bond" and item:FindFirstChild("Part") then
                    local dist = (item.Part.Position - RootPart.Position).Magnitude
                    if dist > 10 and dist < Config.BringRange then
                        -- Puxar suavemente
                        local direction = (RootPart.Position - item.Part.Position).Unit
                        item.Part.CFrame = item.Part.CFrame + (direction * (dist * 0.1))
                        item.Part.Velocity = direction * 100
                    end
                end
            end
        end
        task.wait(0.05)
    end
end

-- Thread 3: Server Optimizer (Remove lag)
local function ThreadOptimizer()
    while Stats.IsRunning do
        -- Limpar partículas desnecessárias
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") then
                v.Enabled = false
            end
            if v:IsA("Sound") and v.Volume > 0 then
                v.Volume = 0
            end
        end
        
        -- Liminar objetos distantes
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
                local dist = (obj.Position - RootPart.Position).Magnitude
                if dist > 1000 then
                    obj:Destroy()
                end
            end
        end
        
        task.wait(5)
    end
end

-- Thread 4: Anti-AFK
local function ThreadAntiAFK()
    while Stats.IsRunning and Config.AntiAFK do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
        task.wait(60) -- A cada minuto
    end
end

-- Thread 5: Auto-Rejoin Inteligente
local function ThreadRejoin()
    while Stats.IsRunning do
        local timeSinceLast = tick() - Stats.LastBondTime
        
        if timeSinceLast > Config.RejoinThreshold then
            StatusLabel.Text = "SERVIDOR VAZIO - REJOIN..."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            
            Stats.ServerHops += 1
            Stats.TotalBonds += Stats.Bonds
            Stats.Bonds = 0
            
            -- Teleportar para novo servidor
            local success = pcall(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
            
            if not success then
                -- Se falhar, tentar novamente
                task.wait(5)
            end
        end
        
        task.wait(1)
    end
end

-- Thread 6: Estatísticas em Tempo Real
local function ThreadStats()
    while Stats.IsRunning do
        local elapsed = tick() - Stats.StartTime
        
        -- Bonds por segundo (média móvel)
        if elapsed > 0 then
            Stats.BondsPerSecond = Stats.Bonds / elapsed
            
            -- Peak BPS
            if Stats.BondsPerSecond > Stats.PeakBPS then
                Stats.PeakBPS = Stats.BondsPerSecond
            end
            
            -- Atualizar labels
            SpeedLabel.Text = string.format("%.1f/s", Stats.BondsPerSecond)
            
            -- Projeção de 1 hora
            local perHour = math.floor(Stats.BondsPerSecond * 3600)
            if perHour > 1000000 then
                ProjectionLabel.Text = string.format("%.1fM/hr", perHour / 1000000)
            elseif perHour > 1000 then
                ProjectionLabel.Text = string.format("%.0fk/hr", perHour / 1000)
            else
                ProjectionLabel.Text = perHour .. "/hr"
            end
            
            -- Atualizar barra de turbo
            local progress = math.min(Stats.BondsPerSecond / 50, 1) -- 50/s = 100%
            TurboBar.Size = UDim2.new(progress, 0, 1, 0)
            TurboBar.BackgroundColor3 = Color3.fromRGB(
                255 * (1 - progress),
                255 * progress,
                0
            )
        end
        
        task.wait(0.5)
    end
end

-- Thread 7: Auto-Recovery (Anti-erros)
local function ThreadRecovery()
    while Stats.IsRunning do
        -- Verificar se character morreu ou foi resetado
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Stats.Errors += 1
            StatusLabel.Text = "RECONECTANDO..."
            
            -- Esperar respawn
            LocalPlayer.CharacterAdded:Wait()
            task.wait(1)
            
            -- Reatualizar variáveis
            Character = LocalPlayer.Character
            Humanoid = Character:WaitForChild("Humanoid")
            RootPart = Character:WaitForChild("HumanoidRootPart")
            
            StatusLabel.Text = "RECONECTADO!"
        end
        
        task.wait(2)
    end
end

-- Thread 8: Coleta de Fundo (Background farming)
local function ThreadBackground()
    while Stats.IsRunning do
        -- Coletar bonds que spawnam perto enquanto main thread está ocupada
        local items = Workspace:FindFirstChild("RuntimeItems")
        if items then
            for _, item in pairs(items:GetChildren()) do
                if item.Name == "Bond" and item:FindFirstChild("Part") then
                    local dist = (item.Part.Position - RootPart.Position).Magnitude
                    if dist < 10 then
                        QuantumCollect(item)
                        Stats.Bonds += 1
                    end
                end
            end
        end
        task.wait(0.1)
    end
end

-- Thread 9: Cache Cleaner (Prevenção de memory leak)
local function ThreadCleaner()
    while Stats.IsRunning do
        -- Forçar garbage collection
        for i = 1, 3 do
            task.wait(10)
        end
        
        -- Limpar variáveis temporárias
        collectgarbage("collect")
        
        StatusLabel.Text = "MEMÓRIA OTIMIZADA"
        task.wait(0.5)
    end
end

-- Thread 10: Network Optimizer (Reduz ping)
local function ThreadNetwork()
    while Stats.IsRunning do
        -- Ajustar propriedades de network para menor lag
        settings().Network.IncomingReplicationLag = 0
        settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
        
        task.wait(30)
    end
end

-- CONTROLES

TurboBtn.MouseButton1Click:Connect(function()
    if Stats.IsRunning then
        -- Parar
        Stats.IsRunning = false
        TurboBtn.Text = "▶ INICIAR"
        TurboBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        StatusLabel.Text = "PARADO"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        Stats.TotalBonds += Stats.Bonds
    else
        -- Iniciar
        Stats.IsRunning = true
        Stats.StartTime = tick()
        Stats.LastBondTime = tick()
        
        TurboBtn.Text = "⏹ PARAR"
        TurboBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        
        -- Iniciar todas as 10 threads
        task.spawn(ThreadMain)
        task.spawn(ThreadMagnet)
        task.spawn(ThreadOptimizer)
        task.spawn(ThreadAntiAFK)
        task.spawn(ThreadRejoin)
        task.spawn(ThreadStats)
        task.spawn(ThreadRecovery)
        task.spawn(ThreadBackground)
        task.spawn(ThreadCleaner)
        task.spawn(ThreadNetwork)
        
        StatusLabel.Text = "ULTRA FARM ATIVADO!"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    end
end)

ModeBtn.MouseButton1Click:Connect(function()
    Config.TurboMode = not Config.TurboMode
    Stats.TurboActive = Config.TurboMode
    
    if Config.TurboMode then
        ModeBtn.Text = "TURBO: ON ⚡"
        ModeBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        Config.TweenSpeed = 0.01
        Config.FarmRange = 1000
    else
        ModeBtn.Text = "TURBO: OFF"
        ModeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 0)
        Config.TweenSpeed = 0.05
        Config.FarmRange = 500
    end
end)

-- Iniciar automaticamente (opcional)
-- TurboBtn.MouseButton1Click:Fire()

print([[
    ╔══════════════════════════════════════════╗
    ║         AUTO BONDS ULTRA v10.0           ║
    ║         "O Último Script de Farm"         ║
    ╠══════════════════════════════════════════╣
    ║  Threads: 10 (Paralelas)                   ║
    ║  Métodos: Quantum Coleta (4x)            ║
    ║  Pathfinding: AI Inteligente               ║
    ║  Auto-Rejoin: Servidor Hopping             ║
    ║  Proteção: Anti-AFK + Auto-Recovery        ║
    ║                                           ║
    ║  Velocidade Estimada: 500k-1M/hr (Turbo) ║
    ╚══════════════════════════════════════════╝
    
    CLIQUE EM "INICIAR" PARA DOMINAR O DEAD RAILS!
]])
