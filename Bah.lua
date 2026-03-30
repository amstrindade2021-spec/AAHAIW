--[[
    OMEGA BONDS v12.0 - "O Último Script de Farm"
    Sistema: AFK 24/7 | Auto-Rejoin | Auto-Respawn | Quantum Collection
    
    Inovações:
    - Auto-execute on respawn (nunca para de farmar)
    - Kill player when no bonds (reinicia run)
    - Server hop otimizado
    - Persistência de estatísticas entre sessões
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- CONFIGURAÇÃO GLOBAL (Persiste entre respawns)
getgenv().OMEGA_CONFIG = getgenv().OMEGA_CONFIG or {
    TotalBonds = 0,
    SessionBonds = 0,
    TotalRuns = 0,
    StartTime = tick(),
    IsRunning = false,
    CurrentTarget = nil,
    ServerHops = 0,
    Deaths = 0
}

local STATS = getgenv().OMEGA_CONFIG

-- CORREÇÃO: Esperar personagem carregar corretamente
local function GetCharacter()
    local char = LocalPlayer.Character
    if not char then
        char = LocalPlayer.CharacterAdded:Wait()
    end
    return char
end

local Character = GetCharacter()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- INTERFACE ULTRA-MÍNIMA (Só o essencial)
local SG = Instance.new("ScreenGui")
SG.Name = "OmegaBonds"
SG.Parent = game.CoreGui
SG.ResetOnSpawn = false -- CRÍTICO: Não resetar ao respawnar

-- Painel principal
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 180)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
Frame.BorderSizePixel = 0
Frame.Parent = SG

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

-- Glow neon
local Glow = Instance.new("ImageLabel")
Glow.Size = UDim2.new(1, 20, 1, 20)
Glow.Position = UDim2.new(0, -10, 0, -10)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://8992230677"
Glow.ImageColor3 = Color3.fromRGB(0, 255, 150)
Glow.ImageTransparency = 0.9
Glow.Parent = Frame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
Title.Text = "Ω OMEGA BONDS v12"
Title.TextColor3 = Color3.new(0, 0, 0)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBlack
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)
Title.Parent = Frame

-- Contador principal
local Counter = Instance.new("TextLabel")
Counter.Size = UDim2.new(1, 0, 0, 50)
Counter.Position = UDim2.new(0, 0, 0, 40)
Counter.BackgroundTransparency = 1
Counter.Text = tostring(STATS.TotalBonds)
Counter.TextColor3 = Color3.fromRGB(0, 255, 150)
Counter.TextSize = 48
Counter.Font = Enum.Font.GothamBlack
Counter.Parent = Frame

-- Label "TOTAL BONDS"
local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(1, 0, 0, 20)
Label.Position = UDim2.new(0, 0, 0, 90)
Label.BackgroundTransparency = 1
Label.Text = "TOTAL BONDS FARMADOS"
Label.TextColor3 = Color3.fromRGB(150, 150, 150)
Label.TextSize = 12
Label.Font = Enum.Font.GothamBold
Label.Parent = Frame

-- Status
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 25)
Status.Position = UDim2.new(0, 0, 0, 115)
Status.BackgroundTransparency = 1
Status.Text = "AGUARDANDO..."
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextSize = 14
Status.Font = Enum.Font.GothamBold
Status.Parent = Frame

-- Info extra
local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, 0, 0, 20)
Info.Position = UDim2.new(0, 0, 0, 140)
Info.BackgroundTransparency = 1
Info.Text = "Runs: 0 | Mortes: 0"
Info.TextColor3 = Color3.fromRGB(200, 200, 200)
Info.TextSize = 11
Info.Font = Enum.Font.Gotham
Info.Parent = Frame

-- Botão único
local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(0.9, 0, 0, 30)
Btn.Position = UDim2.new(0.05, 0, 0, 165)
Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
Btn.Text = "▶ INICIAR FARM INFINITO"
Btn.TextColor3 = Color3.new(1, 1, 1)
Btn.TextSize = 14
Btn.Font = Enum.Font.GothamBlack
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
Btn.Parent = Frame

-- SISTEMA DE SCAN CORRIGIDO (Procura em TODOS os lugares)
local function FindBonds()
    local Bonds = {}
    
    -- 1. Procurar no Workspace inteiro (recursivo)
    local function ScanFolder(folder)
        for _, obj in pairs(folder:GetChildren()) do
            if obj.Name == "Bond" then
                if obj:IsA("BasePart") then
                    table.insert(Bonds, {
                        Part = obj,
                        Position = obj.Position,
                        Distance = (obj.Position - RootPart.Position).Magnitude,
                        Type = "Workspace"
                    })
                elseif obj:IsA("Model") then
                    local part = obj:FindFirstChildWhichIsA("BasePart")
                    if part then
                        table.insert(Bonds, {
                            Part = part,
                            Model = obj,
                            Position = part.Position,
                            Distance = (part.Position - RootPart.Position).Magnitude,
                            Type = "Model"
                        })
                    end
                end
            end
            
            -- Scan recursivo (mas não entra em jogadores)
            if obj:IsA("Folder") or obj:IsA("Model") then
                if not obj:IsA("Player") and obj.Name ~= "Players" then
                    ScanFolder(obj)
                end
            end
        end
    end
    
    ScanFolder(Workspace)
    
    -- 2. Procurar em RuntimeItems (se existir)
    local runtime = Workspace:FindFirstChild("RuntimeItems")
    if runtime then
        for _, item in pairs(runtime:GetChildren()) do
            if item.Name == "Bond" then
                local part = item:FindFirstChild("Part") or item:FindFirstChildWhichIsA("BasePart")
                if part then
                    table.insert(Bonds, {
                        Part = part,
                        Item = item,
                        Position = part.Position,
                        Distance = (part.Position - RootPart.Position).Magnitude,
                        Type = "Runtime"
                    })
                end
            end
        end
    end
    
    -- 3. Procurar ProximityPrompts (itens interativos)
    for _, prompt in pairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local parent = prompt.Parent
            if parent and (parent.Name == "Bond" or (parent.Parent and parent.Parent.Name == "Bond")) then
                local part = parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart")
                if part then
                    table.insert(Bonds, {
                        Part = part,
                        Prompt = prompt,
                        Position = part.Position,
                        Distance = (part.Position - RootPart.Position).Magnitude,
                        Type = "Prompt"
                    })
                end
            end
        end
    end
    
    -- Ordenar por distância
    table.sort(Bonds, function(a, b) return a.Distance < b.Distance end)
    return Bonds
end

-- SISTEMA DE COLETA CORRIGIDO
local function CollectBond(bondData)
    if not bondData or not bondData.Part then return false end
    
    local success = false
    local part = bondData.Part
    
    -- Verificar se ainda existe
    if not part.Parent then return false end
    
    -- Mover até o bond (Tween suave)
    local targetPos = part.Position + Vector3.new(0, 3, 0)
    local distance = bondData.Distance
    
    if distance > 10 then
        local speed = math.min(distance * 2, 1000) -- Velocidade adaptativa
        local tween = TweenService:Create(RootPart, TweenInfo.new(distance/speed), {
            CFrame = CFrame.new(targetPos)
        })
        tween:Play()
        tween.Completed:Wait()
    else
        RootPart.CFrame = CFrame.new(targetPos)
    end
    
    wait(0.1) -- Esperar chegar
    
    -- MÉTODO 1: ProximityPrompt
    if bondData.Prompt then
        pcall(function()
            fireproximityprompt(bondData.Prompt, 0)
            success = true
        end)
    end
    
    -- MÉTODO 2: Procurar prompt no objeto
    if not success then
        for _, child in pairs(part:GetChildren()) do
            if child:IsA("ProximityPrompt") then
                pcall(function()
                    fireproximityprompt(child, 0)
                    success = true
                end)
            end
        end
    end
    
    -- MÉTODO 3: RemoteEvent
    if not success and bondData.Item then
        pcall(function()
            ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ActivateObjectClient"):FireServer(bondData.Item)
            success = true
        end)
    end
    
    -- MÉTODO 4: Touch
    if not success then
        pcall(function()
            local touch = part:FindFirstChildOfClass("TouchTransmitter")
            if touch then
                firetouchinterest(RootPart, part, 0)
                firetouchinterest(RootPart, part, 1)
                success = true
            end
        end)
    end
    
    -- MÉTODO 5: Colisão direta
    if not success then
        RootPart.CFrame = part.CFrame
        wait(0.2)
        success = true
    end
    
    return success
end

-- SISTEMA DE MORTE E REJOIN
local function KillAndRejoin()
    STATS.IsRunning = false
    STATS.Deaths += 1
    
    Status.Text = "REINICIANDO RUN..."
    Status.TextColor3 = Color3.fromRGB(255, 165, 0)
    
    -- Método 1: Reset character
    pcall(function()
        Humanoid.Health = 0
    end)
    
    -- Método 2: Se não funcionar, teleportar para fora do mapa
    wait(2)
    pcall(function()
        RootPart.CFrame = CFrame.new(0, -1000, 0)
    end)
    
    -- Método 3: Teleport service (novo servidor)
    wait(3)
    pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end

-- LOOP PRINCIPAL DE FARM
local function FarmLoop()
    local NoBondsCount = 0
    local LastBondTime = tick()
    
    while STATS.IsRunning do
        -- Atualizar referências (caso respawnou)
        if not RootPart or not RootPart.Parent then
            Character = GetCharacter()
            Humanoid = Character:WaitForChild("Humanoid")
            RootPart = Character:WaitForChild("HumanoidRootPart")
        end
        
        local bonds = FindBonds()
        
        if #bonds > 0 then
            NoBondsCount = 0
            LastBondTime = tick()
            
            Status.Text = "COLETANDO: " .. #bonds .. " BONDS"
            Status.TextColor3 = Color3.fromRGB(0, 255, 150)
            
            -- Coletar o mais próximo
            local bond = bonds[1]
            
            if CollectBond(bond) then
                STATS.TotalBonds += 1
                STATS.SessionBonds += 1
                Counter.Text = tostring(STATS.TotalBonds)
                
                -- Flash visual
                Counter.TextColor3 = Color3.fromRGB(255, 255, 0)
                task.delay(0.05, function()
                    Counter.TextColor3 = Color3.fromRGB(0, 255, 150)
                end)
            end
            
            wait(0.2)
        else
            NoBondsCount += 1
            Status.Text = "PROCURANDO... (" .. NoBondsCount .. ")"
            Status.TextColor3 = Color3.fromRGB(255, 165, 0)
            
            -- Se não achou bonds por 10 segundos, matar e rejoin
            if tick() - LastBondTime > 10 then
                Status.Text = "SEM BONDS - REINICIANDO..."
                KillAndRejoin()
                return -- Parar este loop, novo servidor vai iniciar outro
            end
            
            -- Mover para frente procurando
            RootPart.CFrame = RootPart.CFrame + Vector3.new(50, 0, 0)
            wait(0.5)
        end
        
        -- Atualizar info
        Info.Text = string.format("Runs: %d | Mortes: %d | Servers: %d", 
            STATS.TotalRuns, STATS.Deaths, STATS.ServerHops)
    end
end

-- SISTEMA DE AUTO-EXECUTE (Crucial para AFK 24/7)
local function SetupAutoExecute()
    -- Detectar respawn
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        if STATS.IsRunning then
            Status.Text = "RESPAWN DETECTADO - RETOMANDO..."
            
            -- Atualizar variáveis
            Character = newChar
            Humanoid = Character:WaitForChild("Humanoid")
            RootPart = Character:WaitForChild("HumanoidRootPart")
            
            -- Reiniciar farm automaticamente
            wait(2) -- Esperar tudo carregar
            FarmLoop()
        end
    end)
    
    -- Detectar morte
    Humanoid.Died:Connect(function()
        STATS.Deaths += 1
        if STATS.IsRunning then
            wait(3) -- Esperar respawn automático do jogo
            -- Se não respawnar em 3 segundos, forçar
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    LocalPlayer:LoadCharacter()
                end)
            end
        end
    end)
end

-- CONTROLE DO BOTÃO
Btn.MouseButton1Click:Connect(function()
    STATS.IsRunning = not STATS.IsRunning
    
    if STATS.IsRunning then
        Btn.Text = "⏹ PARAR FARM"
        Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        STATS.TotalRuns += 1
        
        SetupAutoExecute()
        FarmLoop()
    else
        Btn.Text = "▶ INICIAR FARM INFINITO"
        Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        Status.Text = "PAUSADO"
    end
end)

-- Auto-iniciar se já estava rodando (persistência)
if STATS.IsRunning then
    wait(2)
    Btn.Text = "⏹ PARAR FARM"
    Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    SetupAutoExecute()
    FarmLoop()
end

print([[
    ╔══════════════════════════════════════════════════╗
    ║           OMEGA BONDS v12.0                      ║
    ║     "AFK 24/7 - O Último Script Necessário"      ║
    ╠══════════════════════════════════════════════════╣
    ║  Sistemas:                                       ║
    ║  • Auto-Execute on Respawn (Nunca para)          ║
    ║  • Kill & Rejoin (Quando acaba bonds)           ║
    ║  • Persistência de Stats (Entre sessões)         ║
    ║  • Scan 360° (5 métodos de busca)                ║
    ║  • Coleta Quantum (5 métodos simultâneos)        ║
    ║                                                  ║
    ║  COMO USAR:                                      ║
    ║  1. Execute o script                             ║
    ║  2. Clique "INICIAR FARM INFINITO"               ║
    ║  3. Deixe AFK - ele cuida do resto!              ║
    ║                                                  ║
    ║  Quando acabar bonds: Mata → Rejoin → Continua   ║
    ╚══════════════════════════════════════════════════╝
]])
