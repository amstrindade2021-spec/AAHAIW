--[[
    ╔══════════════════════════════════════════════════════════════════════════╗
    ║                                                                          ║
    ║   ██╗      ██████╗ ███████╗████████╗    ██████╗  █████╗ ██╗██╗         ║
    ║   ██║     ██╔═══██╗██╔════╝╚══██╔══╝    ██╔══██╗██╔══██╗██║██║         ║
    ║   ██║     ██║   ██║███████╗   ██║       ██████╔╝███████║██║██║         ║
    ║   ██║     ██║   ██║╚════██║   ██║       ██╔══██╗██╔══██║██║██║         ║
    ║   ███████╗╚██████╔╝███████║   ██║       ██║  ██║██║  ██║██║███████╗    ║
    ║   ╚══════╝ ╚═════╝ ╚══════╝   ╚═╝       ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝    ║
    ║                                                                          ║
    ║   Versão 4.0 - Professional Edition                                      ║
    ║   Autor: Senior Developer                                                ║
    ║   Jogo: Dead Rails (Roblox)                                              ║
    ║                                                                          ║
    ╚══════════════════════════════════════════════════════════════════════════╝
]]

--// Prevenir múltiplas execuções
if getgenv().LostRailsLoaded then
    warn("[Lost Rails] Script já está carregado!")
    return
end
getgenv().LostRailsLoaded = true

--// Serviços
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService"),
    PathfindingService = game:GetService("PathfindingService"),
    UserInputService = game:GetService("UserInputService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    Lighting = game:GetService("Lighting"),
    VirtualUser = game:GetService("VirtualUser"),
    HttpService = game:GetService("HttpService"),
    CoreGui = game:GetService("CoreGui"),
    StarterGui = game:GetService("StarterGui"),
    Stats = game:GetService("Stats")
}

--// Variáveis do Jogador
local Player = {
    Instance = Services.Players.LocalPlayer,
    Character = nil,
    Humanoid = nil,
    RootPart = nil,
    Camera = Services.Workspace.CurrentCamera,
    Position = Vector3.zero,
    Health = 100,
    MaxHealth = 100,
    Class = "None",
    Money = 0,
    Bonds = 0
}

--// Configurações Avançadas
local Settings = {
    -- Auto Farm
    AutoFarm = {
        Enabled = false,
        CollectBonds = true,
        CollectValuables = true,
        CollectFuel = true,
        CollectAmmo = true,
        CollectWeapons = true,
        CollectHeals = true,
        PrioritySystem = true,
        AutoSell = true,
        SmartPathfinding = true,
        CollectionRadius = 75,
        MinValueThreshold = 10
    },
    
    -- Mega Auto Win + Bonds
    MegaMode = {
        Enabled = false,
        AutoRaidTowns = true,
        AutoRaidCastle = true,
        AutoRaidFort = true,
        AutoRaidTesla = true,
        AutoRaidSterling = true,
        AutoCompleteGame = true,
        SmartDecisionMaking = true,
        RiskAssessment = true,
        EscapeAtNight = true,
        DefendTrain = true,
        FuelManagement = true
    },
    
    -- Movimento
    Movement = {
        SpeedEnabled = false,
        SpeedValue = 32,
        NoClip = false,
        Fly = false,
        FlySpeed = 60,
        AutoJump = true,
        AntiStuck = true,
        SmoothTeleport = true,
        FollowTrain = false
    },
    
    -- Combate
    Combat = {
        KillAura = false,
        KillAuraRange = 25,
        Aimbot = false,
        AutoAttack = false,
        PrioritizeDangerous = true,
        AutoReload = true,
        InfiniteAmmo = false,
        GodMode = false,
        AutoEquipBestWeapon = true
    },
    
    -- Anti-Detecção
    Security = {
        AntiDetection = true,
        RandomDelays = true,
        HumanLikeMovement = true,
        ActionRandomization = true,
        PatternBreaker = true,
        AntiAFK = true,
        FakeLag = false,
        SafeMode = true
    },
    
    -- Performance
    Performance = {
        CacheRefreshRate = 0.5,
        MaxCacheSize = 500,
        RenderDistance = 500,
        LODSystem = true,
        FrameRateLimit = 60
    }
}

--// Estado do Sistema
local State = {
    IsRunning = false,
    CurrentTask = "Inativo",
    CurrentZone = "Unknown",
    GameTime = 12,
    IsNight = false,
    NightType = "None",
    TrainPosition = Vector3.zero,
    TrainSpeed = 0,
    DistanceTraveled = 0,
    
    -- Estatísticas
    Stats = {
        BondsCollected = 0,
        ItemsCollected = 0,
        EnemiesKilled = 0,
        MoneyEarned = 0,
        DistanceMoved = 0,
        StartTime = 0
    },
    
    -- Cache
    Cache = {
        Enemies = {},
        Items = {},
        Buildings = {},
        Train = nil,
        SafeZones = {},
        LastUpdate = 0
    },
    
    -- Controle
    StuckCounter = 0,
    LastPosition = nil,
    ActivePath = nil,
    CurrentTarget = nil,
    LootedBuildings = {},
    DangerZones = {}
}

--// Constantes do Jogo
local GameConstants = {
    -- Localizações (km)
    Locations = {
        Castle = 40000,
        FortConstitution = {10000, 30000, 50000, 60000},
        TeslaLab = {9000, 75000},
        Sterling = {11000, 70000},
        Stillwater = {9000, 75000},
        FinalFort = 80000
    },
    
    -- Tipos de Noite
    NightTypes = {
        NEW_MOON = "New Moon",
        FULL_MOON = "Full Moon",
        BLOOD_MOON = "Blood Moon",
        STORM = "Storm"
    },
    
    -- Valores dos Itens
    ItemValues = {
        Bond = 100,
        GoldBar = 50,
        SilverBar = 25,
        GoldCup = 30,
        SilverCup = 15,
        GoldStatue = 40,
        SilverStatue = 20,
        GoldPainting = 35,
        SilverPainting = 18,
        BrainInJar = 250,
        VampireKnife = 100,
        JadeSword = 250,
        StrangeMask = 250,
        UnicornAlive = 250,
        UnicornDead = 150,
        TeslaCorpse = 300,
        CaptainPrescott = 150,
        Outlaw = 35,
        Werewolf = 20,
        Vampire = 15,
        Goliath = 100
    },
    
    -- Prioridades de Inimigos
    EnemyPriority = {
        ZombieMiner = 10,  -- Mais perigoso (dinamite)
        Werewolf = 9,
        Vampire = 8,
        CaptainPrescott = 7,
        Goliath = 7,
        Outlaw = 6,
        ZombieSoldier = 5,
        ZombieRunner = 4,
        Zombie = 3,
        Skeleton = 2,
        Wolf = 1
    }
}

--// Utilitários Avançados
local Utils = {}

function Utils.SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[Lost Rails] Erro: " .. tostring(result))
        return nil
    end
    return result
end

function Utils.WaitForChild(parent, name, timeout)
    timeout = timeout or 5
    local startTime = tick()
    while tick() - startTime < timeout do
        local child = parent:FindFirstChild(name)
        if child then return child end
        task.wait(0.1)
    end
    return nil
end

function Utils.GetDistance(pos1, pos2)
    if not pos1 or not pos2 then return math.huge end
    return (pos1 - pos2).Magnitude
end

function Utils.IsValid(obj)
    return obj and obj.Parent ~= nil
end

function Utils.RandomRange(min, max)
    return math.random() * (max - min) + min
end

function Utils.RandomInt(min, max)
    return math.random(min, max)
end

function Utils.HumanizedDelay(baseDelay)
    if not Settings.Security.RandomDelays then return baseDelay end
    local variance = baseDelay * 0.3
    return baseDelay + Utils.RandomRange(-variance, variance)
end

function Utils.AddJitter(position, amount)
    if not Settings.Security.HumanLikeMovement then return position end
    amount = amount or 2
    return position + Vector3.new(
        Utils.RandomRange(-amount, amount),
        0,
        Utils.RandomRange(-amount, amount)
    )
end

function Utils.Lerp(a, b, t)
    return a + (b - a) * t
end

function Utils.FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(math.floor(num))
    end
end

function Utils.FormatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d", mins, secs)
end

function Utils.GetTimeOfDay()
    return Services.Lighting.ClockTime or 12
end

function Utils.IsNightTime()
    local time = Utils.GetTimeOfDay()
    return time < 6 or time > 18
end

function Utils.GetNightType()
    -- Detectar tipo de noite baseado no ambiente
    local atmosphere = Services.Lighting:FindFirstChild("Atmosphere")
    if atmosphere then
        local color = atmosphere.Color
        if color.R > 0.5 and color.G < 0.3 then
            return GameConstants.NightTypes.BLOOD_MOON
        elseif color.G > 0.4 then
            return GameConstants.NightTypes.NEW_MOON
        end
    end
    
    -- Verificar inimigos spawnados
    for _, enemy in ipairs(State.Cache.Enemies) do
        if enemy.Type:match("Werewolf") then
            return GameConstants.NightTypes.FULL_MOON
        elseif enemy.Type:match("Vampire") then
            return GameConstants.NightTypes.BLOOD_MOON
        end
    end
    
    return GameConstants.NightTypes.NEW_MOON
end

--// Sistema de Notificações
local NotificationSystem = {}

function NotificationSystem.Create(title, message, duration, type)
    duration = duration or 3
    type = type or "Info"
    
    local colors = {
        Info = Color3.fromRGB(0, 150, 255),
        Success = Color3.fromRGB(0, 200, 100),
        Warning = Color3.fromRGB(255, 200, 0),
        Error = Color3.fromRGB(255, 50, 50)
    }
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LRNotification_" .. tostring(tick())
    screenGui.Parent = Services.CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 90)
    frame.Position = UDim2.new(1, 20, 0.8, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = colors[type]
    stroke.Thickness = 2
    stroke.Parent = frame
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 10, 0, 10)
    icon.BackgroundTransparency = 1
    icon.Text = type == "Info" and "ℹ️" or type == "Success" and "✅" or type == "Warning" and "⚠️" or "❌"
    icon.TextSize = 24
    icon.Parent = frame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 0, 25)
    titleLabel.Position = UDim2.new(0, 45, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = colors[type]
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, 45)
    messageLabel.Position = UDim2.new(0, 10, 0, 35)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 13
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Parent = frame
    
    -- Animação de entrada
    Services.TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
        Position = UDim2.new(1, -340, 0.8, 0)
    }):Play()
    
    -- Som de notificação (opcional)
    -- Services.StarterGui:SetCore("SendNotification", {...})
    
    -- Remover após duração
    task.delay(duration, function()
        local tween = Services.TweenService:Create(frame, TweenInfo.new(0.3), {
            Position = UDim2.new(1, 20, 0.8, 0)
        })
        tween:Play()
        tween.Completed:Wait()
        screenGui:Destroy()
    end)
end

--// Sistema de Cache Inteligente
local CacheManager = {}

function CacheManager.Initialize()
    task.spawn(function()
        while State.IsRunning do
            CacheManager.UpdateAll()
            task.wait(Settings.Performance.CacheRefreshRate)
        end
    end)
end

function CacheManager.UpdateAll()
    local currentTime = tick()
    if currentTime - State.Cache.LastUpdate < 0.3 then return end
    State.Cache.LastUpdate = currentTime
    
    CacheManager.UpdateEnemies()
    CacheManager.UpdateItems()
    CacheManager.UpdateBuildings()
    CacheManager.UpdateTrain()
end

function CacheManager.UpdateEnemies()
    State.Cache.Enemies = {}
    
    for _, obj in ipairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= Player.Character then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
            
            if humanoid and hrp and humanoid.Health > 0 then
                local enemyType = CacheManager.ClassifyEnemy(obj.Name)
                if enemyType then
                    table.insert(State.Cache.Enemies, {
                        Model = obj,
                        Humanoid = humanoid,
                        HRP = hrp,
                        Type = enemyType,
                        Priority = GameConstants.EnemyPriority[enemyType] or 1,
                        Health = humanoid.Health,
                        MaxHealth = humanoid.MaxHealth,
                        Position = hrp.Position,
                        Distance = Utils.GetDistance(Player.Position, hrp.Position),
                        LastSeen = tick()
                    })
                end
            end
        end
    end
    
    -- Ordenar por prioridade
    table.sort(State.Cache.Enemies, function(a, b)
        return a.Priority > b.Priority
    end)
end

function CacheManager.ClassifyEnemy(name)
    name = name:lower()
    
    if name:match("miner") and name:match("zombie") then return "ZombieMiner" end
    if name:match("werewolf") then return "Werewolf" end
    if name:match("vampire") then return "Vampire" end
    if name:match("prescott") then return "CaptainPrescott" end
    if name:match("goliath") then return "Goliath" end
    if name:match("outlaw") then return "Outlaw" end
    if name:match("soldier") and name:match("zombie") then return "ZombieSoldier" end
    if name:match("runner") then return "ZombieRunner" end
    if name:match("zombie") then return "Zombie" end
    if name:match("skeleton") then return "Skeleton" end
    if name:match("wolf") then return "Wolf" end
    
    return nil
end

function CacheManager.UpdateItems()
    State.Cache.Items = {}
    
    local itemPatterns = {
        {Pattern = "bond", Type = "Bond", Value = 100},
        {Pattern = "goldbar", Type = "GoldBar", Value = 50},
        {Pattern = "silverbar", Type = "SilverBar", Value = 25},
        {Pattern = "goldcup", Type = "GoldCup", Value = 30},
        {Pattern = "silvercup", Type = "SilverCup", Value = 15},
        {Pattern = "coal", Type = "Fuel", Value = 5},
        {Pattern = "ammo", Type = "Ammo", Value = 10},
        {Pattern = "bandage", Type = "Heal", Value = 15},
        {Pattern = "snakeoil", Type = "Heal", Value = 20},
        {Pattern = "revolver", Type = "Weapon", Value = 25},
        {Pattern = "rifle", Type = "Weapon", Value = 40},
        {Pattern = "shotgun", Type = "Weapon", Value = 50},
        {Pattern = "brain", Type = "Special", Value = 250},
        {Pattern = "vampireknife", Type = "Special", Value = 100},
        {Pattern = "jadesword", Type = "Special", Value = 250},
        {Pattern = "strangemask", Type = "Special", Value = 250}
    }
    
    for _, obj in ipairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            local objName = obj.Name:lower()
            
            for _, itemInfo in ipairs(itemPatterns) do
                if objName:match(itemInfo.Pattern) then
                    local distance = Utils.GetDistance(Player.Position, obj.Position)
                    
                    if distance <= Settings.Performance.RenderDistance then
                        table.insert(State.Cache.Items, {
                            Part = obj,
                            Name = obj.Name,
                            Type = itemInfo.Type,
                            Value = itemInfo.Value,
                            Position = obj.Position,
                            Distance = distance,
                            Priority = itemInfo.Value / math.max(distance, 1),
                            CanCollect = distance <= Settings.AutoFarm.CollectionRadius
                        })
                    end
                    break
                end
            end
        end
    end
    
    -- Ordenar por prioridade (valor/distância)
    if Settings.AutoFarm.PrioritySystem then
        table.sort(State.Cache.Items, function(a, b)
            return a.Priority > b.Priority
        end)
    end
end

function CacheManager.UpdateBuildings()
    State.Cache.Buildings = {}
    
    local buildingTypes = {
        {Pattern = "house", Type = "House"},
        {Pattern = "bank", Type = "Bank"},
        {Pattern = "sheriff", Type = "Sheriff"},
        {Pattern = "doctor", Type = "Doctor"},
        {Pattern = "gunsmith", Type = "Gunsmith"},
        {Pattern = "general", Type = "Store"},
        {Pattern = "furniture", Type = "Furniture"},
        {Pattern = "castle", Type = "Castle"},
        {Pattern = "fort", Type = "Fort"},
        {Pattern = "tesla", Type = "TeslaLab"},
        {Pattern = "sterling", Type = "Sterling"},
        {Pattern = "barn", Type = "Barn"},
        {Pattern = "church", Type = "Church"}
    }
    
    for _, obj in ipairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local objName = obj.Name:lower()
            
            for _, buildingInfo in ipairs(buildingTypes) do
                if objName:match(buildingInfo.Pattern) then
                    local position = obj:GetPivot().Position
                    local distance = Utils.GetDistance(Player.Position, position)
                    
                    table.insert(State.Cache.Buildings, {
                        Model = obj,
                        Name = obj.Name,
                        Type = buildingInfo.Type,
                        Position = position,
                        Distance = distance,
                        Looted = State.LootedBuildings[obj] or false,
                        Priority = CacheManager.GetBuildingPriority(buildingInfo.Type)
                    })
                    break
                end
            end
        end
    end
    
    table.sort(State.Cache.Buildings, function(a, b)
        return a.Priority > b.Priority
    end)
end

function CacheManager.GetBuildingPriority(buildingType)
    local priorities = {
        Castle = 10,
        TeslaLab = 9,
        Sterling = 8,
        Fort = 7,
        Bank = 6,
        Sheriff = 5,
        Gunsmith = 4,
        Doctor = 3,
        Store = 2,
        House = 1
    }
    return priorities[buildingType] or 0
end

function CacheManager.UpdateTrain()
    local train = Services.Workspace:FindFirstChild("Train") or 
                  Services.Workspace:FindFirstChild("TrainModel") or
                  Services.Workspace:FindFirstChildOfClass("Model")
    
    if train then
        State.Cache.Train = train
        State.TrainPosition = train:GetPivot().Position
        
        -- Calcular velocidade do trem
        local primaryPart = train:FindFirstChild("PrimaryPart") or train:FindFirstChildOfClass("BasePart")
        if primaryPart then
            State.TrainSpeed = primaryPart.Velocity.Magnitude
        end
    end
end

--// Sistema de Pathfinding Avançado
local PathfindingSystem = {}

function PathfindingSystem.CreatePath(startPos, endPos, agentRadius)
    agentRadius = agentRadius or 2
    
    local path = Services.PathfindingService:CreatePath({
        AgentRadius = agentRadius,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = 10,
        AgentMaxSlope = 45,
        WaypointSpacing = 3,
        Costs = {
            Water = 20,
            Grass = 1,
            Sand = 2
        }
    })
    
    local success = pcall(function()
        path:ComputeAsync(startPos, endPos)
    end)
    
    return success and path.Status == Enum.PathStatus.Success and path or nil
end

function PathfindingSystem.FollowPath(path, onWaypointReached)
    if not path then return false end
    
    local waypoints = path:GetWaypoints()
    if #waypoints == 0 then return false end
    
    State.ActivePath = path
    
    for i, waypoint in ipairs(waypoints) do
        if not State.IsRunning then break end
        
        -- Adicionar jitter para movimento humanizado
        local targetPos = Utils.AddJitter(waypoint.Position, 1.5)
        
        -- Pular se necessário
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            Player.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        
        -- Mover para waypoint
        Player.Humanoid:MoveTo(targetPos)
        local reached = Player.Humanoid.MoveToFinished:Wait()
        
        if not reached then
            -- Se falhou, tentar teleporte curto
            if Settings.Movement.SmoothTeleport then
                PathfindingSystem.SmartTeleport(targetPos)
            end
        end
        
        if onWaypointReached then
            onWaypointReached(i, #waypoints)
        end
        
        task.wait(Utils.HumanizedDelay(0.05))
    end
    
    State.ActivePath = nil
    return true
end

function PathfindingSystem.SmartTeleport(position)
    local distance = Utils.GetDistance(Player.Position, position)
    
    if distance > 100 then
        -- Teleporte em etapas para parecer mais natural
        local steps = math.ceil(distance / 50)
        for i = 1, steps do
            local t = i / steps
            local intermediatePos = Player.Position:Lerp(position, t)
            intermediatePos = Utils.AddJitter(intermediatePos, 3)
            
            Player.RootPart.CFrame = CFrame.new(intermediatePos)
            task.wait(Utils.HumanizedDelay(0.1))
        end
    else
        Player.RootPart.CFrame = CFrame.new(Utils.AddJitter(position, 2))
    end
end

function PathfindingSystem.MoveToTarget(targetPosition, usePathfinding)
    if usePathfinding and Settings.AutoFarm.SmartPathfinding then
        local path = PathfindingSystem.CreatePath(Player.Position, targetPosition)
        if path then
            return PathfindingSystem.FollowPath(path)
        end
    end
    
    -- Fallback para movimento direto
    Player.Humanoid:MoveTo(targetPosition)
    return true
end

--// Sistema de Movimento Avançado
local MovementSystem = {}

function MovementSystem.Initialize()
    -- Speed Control
    Services.RunService.Heartbeat:Connect(function()
        if Settings.Movement.SpeedEnabled and Player.Humanoid then
            Player.Humanoid.WalkSpeed = Settings.Movement.SpeedValue
        end
    end)
    
    -- NoClip
    Services.RunService.Stepped:Connect(function()
        if Settings.Movement.NoClip and Player.Character then
            for _, part in ipairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    
    -- Anti-Stuck
    task.spawn(function()
        while State.IsRunning do
            if Settings.Movement.AntiStuck then
                MovementSystem.CheckStuck()
            end
            task.wait(2)
        end
    end)
    
    -- Auto Jump
    Services.RunService.Heartbeat:Connect(function()
        if Settings.Movement.AutoJump and Player.Humanoid then
            -- Detectar obstáculos à frente
            local ray = Ray.new(Player.Position, Player.RootPart.CFrame.LookVector * 5)
            local hit = Services.Workspace:FindPartOnRay(ray, Player.Character)
            
            if hit and hit.Size.Y > 5 then
                Player.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

function MovementSystem.CheckStuck()
    if not State.LastPosition then
        State.LastPosition = Player.Position
        return
    end
    
    local distance = Utils.GetDistance(State.LastPosition, Player.Position)
    
    if distance < 0.5 then
        State.StuckCounter = State.StuckCounter + 1
        
        if State.StuckCounter >= 3 then
            NotificationSystem.Create("Anti-Stuck", "Liberando personagem...", 2, "Warning")
            
            -- Estratégia de liberação
            Player.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            
            local escapeDirections = {
                Vector3.new(10, 5, 0),
                Vector3.new(-10, 5, 0),
                Vector3.new(0, 5, 10),
                Vector3.new(0, 5, -10)
            }
            
            for _, direction in ipairs(escapeDirections) do
                Player.RootPart.CFrame = Player.RootPart.CFrame + direction
                task.wait(0.2)
                
                if Utils.GetDistance(Player.Position, State.LastPosition) > 1 then
                    break
                end
            end
            
            State.StuckCounter = 0
        end
    else
        State.StuckCounter = 0
    end
    
    State.LastPosition = Player.Position
end

function MovementSystem.EnableFly()
    if not Settings.Movement.Fly then return end
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = Player.RootPart
    
    local connection
    connection = Services.RunService.RenderStepped:Connect(function()
        if not Settings.Movement.Fly then
            bodyVelocity:Destroy()
            connection:Disconnect()
            return
        end
        
        local moveDirection = Vector3.zero
        
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + Player.Camera.CFrame.LookVector
        end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - Player.Camera.CFrame.LookVector
        end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - Player.Camera.CFrame.RightVector
        end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + Player.Camera.CFrame.RightVector
        end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * Settings.Movement.FlySpeed
        end
        
        bodyVelocity.Velocity = moveDirection
    end)
end

--// Sistema de Combate Avançado
local CombatSystem = {}

function CombatSystem.Initialize()
    -- Kill Aura
    Services.RunService.Heartbeat:Connect(function()
        if Settings.Combat.KillAura then
            CombatSystem.ExecuteKillAura()
        end
    end)
    
    -- Aimbot
    Services.RunService.RenderStepped:Connect(function()
        if Settings.Combat.Aimbot then
            CombatSystem.ExecuteAimbot()
        end
    end)
    
    -- Auto Equip Best Weapon
    task.spawn(function()
        while State.IsRunning do
            if Settings.Combat.AutoEquipBestWeapon then
                CombatSystem.EquipBestWeapon()
            end
            task.wait(5)
        end
    end)
end

function CombatSystem.ExecuteKillAura()
    local enemiesInRange = {}
    
    for _, enemy in ipairs(State.Cache.Enemies) do
        if enemy.Distance <= Settings.Combat.KillAuraRange then
            table.insert(enemiesInRange, enemy)
        end
    end
    
    if #enemiesInRange == 0 then return end
    
    -- Priorizar inimigos mais perigosos
    if Settings.Combat.PrioritizeDangerous then
        table.sort(enemiesInRange, function(a, b)
            return a.Priority > b.Priority
        end)
    end
    
    -- Atacar múltiplos inimigos
    local maxTargets = math.min(#enemiesInRange, 3)
    
    for i = 1, maxTargets do
        local enemy = enemiesInRange[i]
        CombatSystem.AttackEnemy(enemy)
        task.wait(Utils.HumanizedDelay(0.08))
    end
end

function CombatSystem.AttackEnemy(enemy)
    if not Utils.IsValid(enemy.Model) then return end
    
    -- Equipar arma se necessário
    local tool = Player.Character:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
        
        -- Mira no inimigo
        Player.Camera.CFrame = CFrame.new(Player.Camera.CFrame.Position, enemy.Position)
    end
    
    -- Dano adicional via RemoteEvents se disponível
    local damageRemote = Services.ReplicatedStorage:FindFirstChild("DamageEnemy")
    if damageRemote then
        damageRemote:FireServer(enemy.Model, 25)
    end
    
    -- Atualizar estatísticas
    if enemy.Humanoid.Health <= 0 then
        State.Stats.EnemiesKilled = State.Stats.EnemiesKilled + 1
        NotificationSystem.Create("Kill", "Eliminado: " .. enemy.Type, 1.5, "Success")
    end
end

function CombatSystem.ExecuteAimbot()
    local nearestEnemy = nil
    local nearestDistance = math.huge
    
    for _, enemy in ipairs(State.Cache.Enemies) do
        if enemy.Distance < nearestDistance and enemy.Distance <= 100 then
            nearestDistance = enemy.Distance
            nearestEnemy = enemy
        end
    end
    
    if nearestEnemy then
        -- Suavizar mira
        local targetCFrame = CFrame.new(Player.Camera.CFrame.Position, nearestEnemy.Position)
        Player.Camera.CFrame = Player.Camera.CFrame:Lerp(targetCFrame, 0.3)
    end
end

function CombatSystem.EquipBestWeapon()
    local bestWeapon = nil
    local bestDamage = 0
    
    for _, tool in ipairs(Player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local damage = 0
            local toolName = tool.Name:lower()
            
            if toolName:match("jadesword") or toolName:match("excalibur") then
                damage = 100
            elseif toolName:match("vampireknife") then
                damage = 80
            elseif toolName:match("tomahawk") then
                damage = 60
            elseif toolName:match("cavalry") or toolName:match("sword") then
                damage = 50
            elseif toolName:match("shotgun") then
                damage = 70
            elseif toolName:match("rifle") then
                damage = 60
            elseif toolName:match("revolver") then
                damage = 40
            elseif toolName:match("shovel") then
                damage = 20
            end
            
            if damage > bestDamage then
                bestDamage = damage
                bestWeapon = tool
            end
        end
    end
    
    if bestWeapon then
        Player.Humanoid:EquipTool(bestWeapon)
    end
end

function CombatSystem.GetNearestEnemy(maxRange)
    maxRange = maxRange or math.huge
    
    local nearest = nil
    local minDistance = maxRange
    
    for _, enemy in ipairs(State.Cache.Enemies) do
        if enemy.Distance < minDistance then
            minDistance = enemy.Distance
            nearest = enemy
        end
    end
    
    return nearest, minDistance
end

--// Sistema de Auto Farm Inteligente
local FarmSystem = {}

function FarmSystem.Initialize()
    task.spawn(function()
        while State.IsRunning do
            if Settings.AutoFarm.Enabled then
                FarmSystem.ExecuteFarmCycle()
            end
            task.wait(Utils.HumanizedDelay(0.5))
        end
    end)
end

function FarmSystem.ExecuteFarmCycle()
    State.CurrentTask = "Farming"
    
    -- Atualizar cache
    CacheManager.UpdateItems()
    
    -- Coletar itens prioritários
    for _, item in ipairs(State.Cache.Items) do
        if not Settings.AutoFarm.Enabled then break end
        if not item.CanCollect then continue end
        
        -- Verificar se deve coletar
        local shouldCollect = FarmSystem.ShouldCollectItem(item)
        
        if shouldCollect then
            FarmSystem.CollectItem(item)
        end
    end
end

function FarmSystem.ShouldCollectItem(item)
    local filters = {
        Bond = Settings.AutoFarm.CollectBonds,
        GoldBar = Settings.AutoFarm.CollectValuables,
        SilverBar = Settings.AutoFarm.CollectValuables,
        GoldCup = Settings.AutoFarm.CollectValuables,
        SilverCup = Settings.AutoFarm.CollectValuables,
        Fuel = Settings.AutoFarm.CollectFuel,
        Ammo = Settings.AutoFarm.CollectAmmo,
        Weapon = Settings.AutoFarm.CollectWeapons,
        Heal = Settings.AutoFarm.CollectHeals,
        Special = true
    }
    
    local shouldCollect = filters[item.Type] or false
    
    -- Verificar valor mínimo
    if shouldCollect and item.Value < Settings.AutoFarm.MinValueThreshold then
        shouldCollect = false
    end
    
    return shouldCollect
end

function FarmSystem.CollectItem(item)
    if not Utils.IsValid(item.Part) then return end
    
    State.CurrentTask = "Coletando " .. item.Name
    State.CurrentTarget = item
    
    -- Mover até o item
    local success = PathfindingSystem.MoveToTarget(item.Position, true)
    
    if success then
        -- Tentar coletar
        local attempts = 0
        local maxAttempts = 3
        
        while attempts < maxAttempts do
            if not Utils.IsValid(item.Part) then break end
            
            -- Fire touch
            pcall(function()
                firetouchinterest(Player.RootPart, item.Part, 0)
                task.wait(0.05)
                firetouchinterest(Player.RootPart, item.Part, 1)
            end)
            
            -- Tentar usar RemoteEvents
            local collectRemote = Services.ReplicatedStorage:FindFirstChild("CollectItem")
            if collectRemote then
                collectRemote:FireServer(item.Part)
            end
            
            -- Verificar se coletou
            task.wait(Utils.HumanizedDelay(0.2))
            
            if not Utils.IsValid(item.Part) then
                -- Coletado com sucesso
                State.Stats.ItemsCollected = State.Stats.ItemsCollected + 1
                
                if item.Type == "Bond" then
                    State.Stats.BondsCollected = State.Stats.BondsCollected + 1
                end
                
                NotificationSystem.Create("Coletado", item.Name .. " ($" .. item.Value .. ")", 1.5, "Success")
                break
            end
            
            attempts = attempts + 1
        end
    end
    
    State.CurrentTarget = nil
end

--// Sistema Mega: Auto Win + Auto Bonds
local MegaSystem = {}

function MegaSystem.Initialize()
    task.spawn(function()
        while State.IsRunning do
            if Settings.MegaMode.Enabled then
                MegaSystem.ExecuteStrategy()
            end
            task.wait(Utils.HumanizedDelay(1))
        end
    end)
end

function MegaSystem.ExecuteStrategy()
    -- Analisar situação atual
    local situation = MegaSystem.AnalyzeSituation()
    
    -- Decidir ação baseada na situação
    if situation.IsNight and Settings.MegaMode.EscapeAtNight then
        MegaSystem.DefendTrain()
    elseif situation.EnemiesNearby then
        MegaSystem.CombatMode()
    elseif situation.LowFuel and Settings.MegaMode.FuelManagement then
        MegaSystem.FindFuel()
    elseif situation.NearCastle and Settings.MegaMode.AutoRaidCastle then
        MegaSystem.RaidCastle()
    elseif situation.NearFort and Settings.MegaMode.AutoRaidFort then
        MegaSystem.RaidFort()
    elseif situation.NearTesla and Settings.MegaMode.AutoRaidTesla then
        MegaSystem.RaidTeslaLab()
    elseif situation.NearSterling and Settings.MegaMode.AutoRaidSterling then
        MegaSystem.RaidSterling()
    elseif situation.NearTown and Settings.MegaMode.AutoRaidTowns then
        MegaSystem.RaidTown()
    elseif situation.AtFinalFort and Settings.MegaMode.AutoCompleteGame then
        MegaSystem.CompleteGame()
    else
        MegaSystem.Explore()
    end
end

function MegaSystem.AnalyzeSituation()
    local analysis = {
        IsNight = Utils.IsNightTime(),
        NightType = Utils.GetNightType(),
        EnemiesNearby = false,
        LowFuel = false,
        NearCastle = false,
        NearFort = false,
        NearTesla = false,
        NearSterling = false,
        NearTown = false,
        AtFinalFort = false
    }
    
    -- Verificar inimigos próximos
    local nearestEnemy, enemyDist = CombatSystem.GetNearestEnemy(30)
    analysis.EnemiesNearby = nearestEnemy ~= nil
    
    -- Verificar distância para locais importantes
    local distance = State.DistanceTraveled
    
    analysis.NearCastle = math.abs(distance - GameConstants.Locations.Castle) < 2000
    analysis.AtFinalFort = distance >= 78000
    
    for _, fortDist in ipairs(GameConstants.Locations.FortConstitution) do
        if math.abs(distance - fortDist) < 2000 then
            analysis.NearFort = true
            break
        end
    end
    
    for _, teslaDist in ipairs(GameConstants.Locations.TeslaLab) do
        if math.abs(distance - teslaDist) < 2000 then
            analysis.NearTesla = true
            break
        end
    end
    
    for _, sterlingDist in ipairs(GameConstants.Locations.Sterling) do
        if math.abs(distance - sterlingDist) < 2000 then
            analysis.NearSterling = true
            break
        end
    end
    
    -- Verificar edifícios próximos
    for _, building in ipairs(State.Cache.Buildings) do
        if building.Distance < 100 and building.Type == "House" then
            analysis.NearTown = true
            break
        end
    end
    
    return analysis
end

function MegaSystem.DefendTrain()
    State.CurrentTask = "Defendendo Trem"
    
    local train = State.Cache.Train
    if not train then return end
    
    -- Mover para posição defensiva
    local trainPos = State.TrainPosition
    local defendPos = trainPos + Vector3.new(0, 10, 0)
    
    PathfindingSystem.SmartTeleport(defendPos)
    
    -- Ativar kill aura
    local prevKillAura = Settings.Combat.KillAura
    Settings.Combat.KillAura = true
    
    -- Defender até amanhecer
    while Utils.IsNightTime() and Settings.MegaMode.Enabled do
        -- Manter posição
        if Utils.GetDistance(Player.Position, trainPos) > 30 then
            PathfindingSystem.SmartTeleport(defendPos)
        end
        
        -- Verificar se precisa de cura
        if Player.Health < Player.MaxHealth * 0.3 then
            MegaSystem.UseHeal()
        end
        
        task.wait(0.5)
    end
    
    Settings.Combat.KillAura = prevKillAura
    NotificationSystem.Create("Defesa", "Noite sobrevivida!", 3, "Success")
end

function MegaSystem.CombatMode()
    State.CurrentTask = "Modo Combate"
    
    Settings.Combat.KillAura = true
    Settings.Combat.Aimbot = true
    
    -- Esperar até não haver mais inimigos próximos
    while Settings.MegaMode.Enabled do
        local nearestEnemy, distance = CombatSystem.GetNearestEnemy(40)
        if not nearestEnemy then break end
        
        -- Atacar
        CombatSystem.AttackEnemy(nearestEnemy)
        
        -- Recuar se necessário
        if Player.Health < Player.MaxHealth * 0.4 then
            MegaSystem.Retreat()
        end
        
        task.wait(Utils.HumanizedDelay(0.1))
    end
    
    Settings.Combat.KillAura = false
    Settings.Combat.Aimbot = false
end

function MegaSystem.Retreat()
    local trainPos = State.TrainPosition
    if trainPos then
        local retreatPos = trainPos + Vector3.new(0, 15, 0)
        PathfindingSystem.SmartTeleport(retreatPos)
        MegaSystem.UseHeal()
    end
end

function MegaSystem.UseHeal()
    -- Procurar e usar cura
    for _, item in ipairs(State.Cache.Items) do
        if item.Type == "Heal" and item.Distance < 10 then
            FarmSystem.CollectItem(item)
            break
        end
    end
end

function MegaSystem.RaidCastle()
    State.CurrentTask = "Raiding Castle"
    NotificationSystem.Create("Raid", "Atacando Castelo...", 3, "Info")
    
    -- Encontrar castelo
    local castle = nil
    for _, building in ipairs(State.Cache.Buildings) do
        if building.Type == "Castle" then
            castle = building
            break
        end
    end
    
    if not castle then return end
    
    -- Preparar
    Settings.Combat.KillAura = true
    Settings.Combat.GodMode = true
    
    -- Explorar castelo
    PathfindingSystem.MoveToTarget(castle.Position, true)
    
    -- Procurar Vampire Knife
    task.wait(Utils.HumanizedDelay(2))
    
    for _, item in ipairs(State.Cache.Items) do
        if item.Name:lower():match("vampireknife") then
            FarmSystem.CollectItem(item)
            NotificationSystem.Create("Loot", "Vampire Knife encontrada!", 5, "Success")
            break
        end
    end
    
    -- Coletar tudo
    FarmSystem.ExecuteFarmCycle()
    
    Settings.Combat.GodMode = false
    State.LootedBuildings[castle.Model] = true
end

function MegaSystem.RaidFort()
    State.CurrentTask = "Raiding Fort Constitution"
    NotificationSystem.Create("Raid", "Atacando Fort Constitution...", 3, "Info")
    
    -- Encontrar forte
    local fort = nil
    for _, building in ipairs(State.Cache.Buildings) do
        if building.Type == "Fort" then
            fort = building
            break
        end
    end
    
    if not fort then return end
    
    Settings.Combat.KillAura = true
    
    -- Entrar no forte
    PathfindingSystem.MoveToTarget(fort.Position, true)
    
    -- Procurar Captain Prescott
    for _, enemy in ipairs(State.Cache.Enemies) do
        if enemy.Type == "CaptainPrescott" then
            -- Focar fogo no capitão
            while Utils.IsValid(enemy.Model) and enemy.Humanoid.Health > 0 do
                CombatSystem.AttackEnemy(enemy)
                task.wait(Utils.HumanizedDelay(0.1))
            end
            
            NotificationSystem.Create("Boss", "Captain Prescott derrotado!", 3, "Success")
            
            -- Pegar chave
            task.wait(Utils.HumanizedDelay(1))
            FarmSystem.ExecuteFarmCycle()
            break
        end
    end
    
    -- Abrir Supply Depot
    task.wait(Utils.HumanizedDelay(1))
    FarmSystem.ExecuteFarmCycle()
    
    State.LootedBuildings[fort.Model] = true
end

function MegaSystem.RaidTeslaLab()
    State.CurrentTask = "Raiding Tesla Lab"
    NotificationSystem.Create("Raid", "Atacando Tesla Lab...", 3, "Info")
    
    local lab = nil
    for _, building in ipairs(State.Cache.Buildings) do
        if building.Type == "TeslaLab" then
            lab = building
            break
        end
    end
    
    if not lab then return end
    
    PathfindingSystem.MoveToTarget(lab.Position, true)
    
    -- Ativar Tesla (encontrar alavanca)
    for _, obj in ipairs(lab.Model:GetDescendants()) do
        if obj.Name:lower():match("lever") or obj.Name:lower():match("switch") then
            local clickDetector = obj:FindFirstChildOfClass("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector)
                break
            end
        end
    end
    
    -- Defender
    local startTime = tick()
    Settings.Combat.KillAura = true
    
    while tick() - startTime < 60 do
        if not Settings.MegaMode.Enabled then break end
        task.wait(0.5)
    end
    
    -- Coletar recompensas
    FarmSystem.ExecuteFarmCycle()
    
    State.LootedBuildings[lab.Model] = true
end

function MegaSystem.RaidSterling()
    State.CurrentTask = "Raiding Sterling"
    NotificationSystem.Create("Raid", "Atacando Sterling...", 3, "Info")
    
    local sterling = nil
    for _, building in ipairs(State.Cache.Buildings) do
        if building.Type == "Sterling" then
            sterling = building
            break
        end
    end
    
    if not sterling then return end
    
    PathfindingSystem.MoveToTarget(sterling.Position, true)
    
    -- Procurar tablets jade
    local tablets = {}
    for _, obj in ipairs(sterling.Model:GetDescendants()) do
        if obj.Name:lower():match("tablet") or obj.Name:lower():match("jade") then
            table.insert(tablets, obj)
        end
    end
    
    for _, tablet in ipairs(tablets) do
        if tablet:IsA("BasePart") then
            PathfindingSystem.SmartTeleport(tablet.Position)
            firetouchinterest(Player.RootPart, tablet, 0)
            firetouchinterest(Player.RootPart, tablet, 1)
            task.wait(Utils.HumanizedDelay(0.3))
        end
    end
    
    -- Entrar na sala secreta e pegar Jade Sword
    task.wait(Utils.HumanizedDelay(2))
    FarmSystem.ExecuteFarmCycle()
    
    State.LootedBuildings[sterling.Model] = true
end

function MegaSystem.RaidTown()
    State.CurrentTask = "Raiding Town"
    
    -- Encontrar banco
    local bank = nil
    for _, building in ipairs(State.Cache.Buildings) do
        if building.Type == "Bank" and not building.Looted then
            bank = building
            break
        end
    end
    
    if bank then
        Settings.Combat.KillAura = true
        PathfindingSystem.MoveToTarget(bank.Position, true)
        
        -- Procurar código
        for _, enemy in ipairs(State.Cache.Enemies) do
            if enemy.Type:match("Banker") then
                while Utils.IsValid(enemy.Model) and enemy.Humanoid.Health > 0 do
                    CombatSystem.AttackEnemy(enemy)
                    task.wait(Utils.HumanizedDelay(0.1))
                end
                
                -- Código dropado, procurar
                task.wait(Utils.HumanizedDelay(1))
                break
            end
        end
        
        -- Abrir cofre e coletar
        FarmSystem.ExecuteFarmCycle()
        State.LootedBuildings[bank.Model] = true
    end
    
    -- Saquear outras construções
    for _, building in ipairs(State.Cache.Buildings) do
        if building.Distance < 200 and not building.Looted then
            PathfindingSystem.MoveToTarget(building.Position, true)
            FarmSystem.ExecuteFarmCycle()
            State.LootedBuildings[building.Model] = true
        end
    end
end

function MegaSystem.FindFuel()
    State.CurrentTask = "Procurando Combustível"
    
    -- Procurar Headframes (minas) - garantido ter coal
    for _, building in ipairs(State.Cache.Buildings) do
        if building.Type == "Headframe" and not building.Looted then
            PathfindingSystem.MoveToTarget(building.Position, true)
            FarmSystem.ExecuteFarmCycle()
            State.LootedBuildings[building.Model] = true
            return
        end
    end
    
    -- Procurar Furniture Stores
    for _, building in ipairs(State.Cache.Buildings) do
        if building.Type == "Furniture" and not building.Looted then
            PathfindingSystem.MoveToTarget(building.Position, true)
            FarmSystem.ExecuteFarmCycle()
            State.LootedBuildings[building.Model] = true
            return
        end
    end
end

function MegaSystem.Explore()
    State.CurrentTask = "Explorando"
    
    -- Seguir o trem ou explorar área
    if Settings.Movement.FollowTrain and State.Cache.Train then
        local followPos = State.TrainPosition + Vector3.new(0, 10, 0)
        PathfindingSystem.SmartTeleport(followPos)
    else
        -- Explorar edifícios não saqueados
        for _, building in ipairs(State.Cache.Buildings) do
            if not building.Looted and building.Distance < 300 then
                PathfindingSystem.MoveToTarget(building.Position, true)
                FarmSystem.ExecuteFarmCycle()
                State.LootedBuildings[building.Model] = true
                break
            end
        end
    end
end

function MegaSystem.CompleteGame()
    State.CurrentTask = "Completando Jogo"
    NotificationSystem.Create("FINAL", "Iniciando sequência de vitória!", 5, "Success")
    
    -- Ir para a ponte
    local bridge = Services.Workspace:FindFirstChild("Bridge") or Services.Workspace:FindFirstChild("FinalBridge")
    
    if bridge then
        local bridgePos = bridge:GetPivot().Position
        PathfindingSystem.MoveToTarget(bridgePos, true)
        
        -- Ativar ponte
        for _, obj in ipairs(bridge:GetDescendants()) do
            if obj.Name:lower():match("crank") or obj.Name:lower():match("lever") then
                local clickDetector = obj:FindFirstChildOfClass("ClickDetector")
                if clickDetector then
                    fireclickdetector(clickDetector)
                    break
                end
            end
        end
        
        -- Defender por 4 minutos
        local startTime = tick()
        Settings.Combat.KillAura = true
        Settings.Combat.GodMode = true
        
        NotificationSystem.Create("Defesa Final", "Defenda por 4 minutos!", 5, "Warning")
        
        while tick() - startTime < 240 do
            local remaining = 240 - (tick() - startTime)
            State.CurrentTask = "Defendendo: " .. Utils.FormatTime(remaining)
            
            -- Manter posição
            if Utils.GetDistance(Player.Position, bridgePos) > 50 then
                PathfindingSystem.SmartTeleport(bridgePos + Vector3.new(0, 15, 0))
            end
            
            task.wait(0.5)
        end
        
        NotificationSystem.Create("VITÓRIA!", "Jogo completado com sucesso!", 10, "Success")
        NotificationSystem.Create("Estatísticas", 
            "Bonds: " .. State.Stats.BondsCollected .. 
            " | Itens: " .. State.Stats.ItemsCollected .. 
            " | Kills: " .. State.Stats.EnemiesKilled, 10, "Info")
    end
end

--// Sistema de Segurança Avançado
local SecuritySystem = {}

function SecuritySystem.Initialize()
    -- Anti-AFK
    if Settings.Security.AntiAFK then
        Player.Instance.Idled:Connect(function()
            Services.VirtualUser:Button2Down(Vector2.new(0, 0), Player.Camera.CFrame)
            task.wait(1)
            Services.VirtualUser:Button2Up(Vector2.new(0, 0), Player.Camera.CFrame)
        end)
    end
    
    -- Pattern Breaker
    if Settings.Security.PatternBreaker then
        task.spawn(function()
            while State.IsRunning do
                task.wait(Utils.RandomInt(30, 60))
                
                if math.random() > 0.7 then
                    -- Pausa aleatória
                    local wasFarming = Settings.AutoFarm.Enabled
                    Settings.AutoFarm.Enabled = false
                    task.wait(Utils.RandomRange(1, 3))
                    Settings.AutoFarm.Enabled = wasFarming
                end
            end
        end)
    end
    
    -- Proteção contra kicks
    local mt = getrawmetatable(game)
    if mt then
        local oldNamecall = mt.__namecall
        
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            
            if method == "Kick" or method == "kick" then
                NotificationSystem.Create("Proteção", "Tentativa de kick bloqueada!", 3, "Warning")
                return nil
            end
            
            return oldNamecall(self, ...)
        end)
        
        setreadonly(mt, true)
    end
    
    -- Fake Lag (opcional)
    if Settings.Security.FakeLag then
        task.spawn(function()
            while State.IsRunning do
                task.wait(Utils.RandomRange(0.1, 0.3))
                -- Simular lag
            end
        end)
    end
end

--// Interface Gráfica Profissional
local GUI = {}

function GUI.Create()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LostRailsGUI"
    screenGui.Parent = Services.CoreGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Frame Principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 700, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = mainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(0, 150, 255)
    mainStroke.Thickness = 2
    mainStroke.Parent = mainFrame
    
    -- Gradiente de fundo
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
    })
    gradient.Parent = mainFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = header
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🚂 LOST RAILS"
    title.TextColor3 = Color3.fromRGB(0, 200, 255)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 24
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Subtítulo
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0.6, 0, 0.5, 0)
    subtitle.Position = UDim2.new(0, 20, 0.5, 0)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Professional Edition v4.0"
    subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 12
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = header
    
    -- Botões de controle
    local minimizeBtn = GUI.CreateButton(header, "_", UDim2.new(1, -70, 0.5, -12), UDim2.new(0, 25, 0, 25), Color3.fromRGB(255, 200, 0))
    local closeBtn = GUI.CreateButton(header, "X", UDim2.new(1, -35, 0.5, -12), UDim2.new(0, 25, 0, 25), Color3.fromRGB(255, 50, 50))
    
    minimizeBtn.MouseButton1Click:Connect(function()
        mainFrame.Size = mainFrame.Size.Y.Offset > 100 and UDim2.new(0, 700, 0, 50) or UDim2.new(0, 700, 0, 500)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui.Enabled = false
    end)
    
    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 160, 1, -50)
    sidebar.Position = UDim2.new(0, 0, 0, 50)
    sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame
    
    -- Abas
    local tabs = {
        {Name = "🏠 Início", Id = "Home"},
        {Name = "🤖 Auto Farm", Id = "Farm"},
        {Name = "👑 Mega Mode", Id = "Mega"},
        {Name = "🏃 Movimento", Id = "Movement"},
        {Name = "⚔️ Combate", Id = "Combat"},
        {Name = "🔒 Segurança", Id = "Security"}
    }
    
    local tabContent = Instance.new("Frame")
    tabContent.Name = "TabContent"
    tabContent.Size = UDim2.new(1, -160, 1, -50)
    tabContent.Position = UDim2.new(0, 160, 0, 50)
    tabContent.BackgroundTransparency = 1
    tabContent.Parent = mainFrame
    
    local currentTab = "Home"
    local tabFrames = {}
    
    for i, tabInfo in ipairs(tabs) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, -10, 0, 40)
        tabBtn.Position = UDim2.new(0, 5, 0, 10 + (i-1) * 45)
        tabBtn.BackgroundColor3 = tabInfo.Id == currentTab and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 45)
        tabBtn.Text = tabInfo.Name
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.Font = Enum.Font.GothamSemibold
        tabBtn.TextSize = 14
        tabBtn.Parent = sidebar
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = tabBtn
        
        -- Conteúdo da aba
        local content = Instance.new("ScrollingFrame")
        content.Name = tabInfo.Id .. "Content"
        content.Size = UDim2.new(1, -20, 1, -20)
        content.Position = UDim2.new(0, 10, 0, 10)
        content.BackgroundTransparency = 1
        content.ScrollBarThickness = 4
        content.Visible = tabInfo.Id == currentTab
        content.Parent = tabContent
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 10)
        layout.Parent = content
        
        tabFrames[tabInfo.Id] = content
        
        tabBtn.MouseButton1Click:Connect(function()
            for id, frame in pairs(tabFrames) do
                frame.Visible = id == tabInfo.Id
            end
            currentTab = tabInfo.Id
            
            -- Atualizar cores
            for _, btn in ipairs(sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                end
            end
            tabBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        end)
    end
    
    -- Preencher abas
    GUI.FillHomeTab(tabFrames.Home)
    GUI.FillFarmTab(tabFrames.Farm)
    GUI.FillMegaTab(tabFrames.Mega)
    GUI.FillMovementTab(tabFrames.Movement)
    GUI.FillCombatTab(tabFrames.Combat)
    GUI.FillSecurityTab(tabFrames.Security)
    
    -- Status Bar
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, 0, 0, 35)
    statusBar.Position = UDim2.new(0, 0, 1, -35)
    statusBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    statusBar.BorderSizePixel = 0
    statusBar.Parent = mainFrame
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 0)
    statusCorner.Parent = statusBar
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -20, 1, 0)
    statusLabel.Position = UDim2.new(0, 10, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Pronto para iniciar"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = statusBar
    
    -- Atualizar status
    task.spawn(function()
        while screenGui.Parent do
            local runtime = tick() - State.Stats.StartTime
            statusLabel.Text = string.format(
                "⏱️ %s | 💰 %s bonds | 📦 %s itens | ⚔️ %s kills | 📍 %s",
                Utils.FormatTime(runtime),
                State.Stats.BondsCollected,
                State.Stats.ItemsCollected,
                State.Stats.EnemiesKilled,
                State.CurrentTask
            )
            task.wait(0.5)
        end
    end)
    
    -- Botão flutuante
    local floatBtn = Instance.new("TextButton")
    floatBtn.Size = UDim2.new(0, 60, 0, 60)
    floatBtn.Position = UDim2.new(0, 20, 0, 20)
    floatBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    floatBtn.Text = "🚂"
    floatBtn.TextSize = 30
    floatBtn.Parent = screenGui
    
    local floatCorner = Instance.new("UICorner")
    floatCorner.CornerRadius = UDim.new(1, 0)
    floatCorner.Parent = floatBtn
    
    local floatStroke = Instance.new("UIStroke")
    floatStroke.Color = Color3.fromRGB(255, 255, 255)
    floatStroke.Thickness = 2
    floatStroke.Parent = floatBtn
    
    floatBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)
    
    -- Animação de entrada
    mainFrame.Position = UDim2.new(0.5, -350, 1.5, 0)
    Services.TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -350, 0.5, -250)
    }):Play()
    
    NotificationSystem.Create("Lost Rails", "Script carregado com sucesso!", 3, "Success")
end

function GUI.CreateButton(parent, text, position, size, color)
    local btn = Instance.new("TextButton")
    btn.Size = size
    btn.Position = position
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    return btn
end

function GUI.CreateToggle(parent, text, settingTable, settingKey, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 50, 0, 26)
    toggle.Position = UDim2.new(1, -55, 0.5, -13)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    toggle.Text = "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 12
    toggle.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 13)
    corner.Parent = toggle
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 20, 0, 20)
    circle.Position = UDim2.new(0, 3, 0.5, -10)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.Parent = toggle
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle
    
    local function updateState()
        local state = settingTable[settingKey]
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
        toggle.Text = state and "ON" or "OFF"
        
        Services.TweenService:Create(circle, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        }):Play()
        
        if callback then
            callback(state)
        end
    end
    
    toggle.MouseButton1Click:Connect(function()
        settingTable[settingKey] = not settingTable[settingKey]
        updateState()
    end)
    
    updateState()
    return toggle
end

function GUI.CreateSlider(parent, text, settingTable, settingKey, min, max)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. settingTable[settingKey]
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 10)
    sliderBg.Position = UDim2.new(0, 0, 0.5, 5)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 5)
    bgCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    local percent = (settingTable[settingKey] - min) / (max - min)
    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 5)
    fillCorner.Parent = sliderFill
    
    local dragging = false
    
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        
        local value = math.floor(min + (max - min) * pos)
        settingTable[settingKey] = value
        label.Text = text .. ": " .. value
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    Services.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function GUI.FillHomeTab(parent)
    local welcome = Instance.new("TextLabel")
    welcome.Size = UDim2.new(1, 0, 0, 30)
    welcome.BackgroundTransparency = 1
    welcome.Text = "Bem-vindo ao Lost Rails!"
    welcome.TextColor3 = Color3.fromRGB(0, 200, 255)
    welcome.Font = Enum.Font.GothamBold
    welcome.TextSize = 18
    welcome.Parent = parent
    
    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, 0, 0, 120)
    desc.Position = UDim2.new(0, 0, 0, 35)
    desc.BackgroundTransparency = 1
    desc.Text = [[
🎯 Funcionalidades Principais:

• Auto Farm Inteligente com IA avançada
• Mega Mode: Auto Win + Auto Bonds combinados
• Sistema de Combate Automático (Kill Aura, Aimbot)
• Movimento Avançado (Speed, Fly, NoClip, Teleporte)
• Anti-Detecção Profissional
• GUI Moderna e Intuitiva

💡 Dica: Use o Mega Mode para farmar bonds automaticamente!
    ]]
    desc.TextColor3 = Color3.fromRGB(200, 200, 200)
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 12
    desc.TextWrapped = true
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = parent
    
    -- Botões principais
    local startAll = GUI.CreateButton(parent, "▶ INICIAR TUDO", UDim2.new(0, 10, 0, 160), UDim2.new(1, -20, 0, 45), Color3.fromRGB(0, 200, 100))
    local stopAll = GUI.CreateButton(parent, "⏹ PARAR TUDO", UDim2.new(0, 10, 0, 210), UDim2.new(1, -20, 0, 45), Color3.fromRGB(200, 50, 50))
    
    startAll.MouseButton1Click:Connect(function()
        State.IsRunning = true
        State.Stats.StartTime = tick()
        
        Settings.AutoFarm.Enabled = true
        Settings.MegaMode.Enabled = true
        Settings.Combat.KillAura = true
        Settings.Movement.SpeedEnabled = true
        Settings.Movement.AntiStuck = true
        
        NotificationSystem.Create("Sistema", "Todos os sistemas ativados!", 3, "Success")
    end)
    
    stopAll.MouseButton1Click:Connect(function()
        State.IsRunning = false
        
        Settings.AutoFarm.Enabled = false
        Settings.MegaMode.Enabled = false
        Settings.Combat.KillAura = false
        Settings.Combat.Aimbot = false
        Settings.Movement.SpeedEnabled = false
        Settings.Movement.NoClip = false
        Settings.Movement.Fly = false
        
        NotificationSystem.Create("Sistema", "Todos os sistemas desativados!", 3, "Warning")
    end)
end

function GUI.FillFarmTab(parent)
    GUI.CreateToggle(parent, "Auto Farm Ativo", Settings.AutoFarm, "Enabled")
    GUI.CreateToggle(parent, "Coletar Bonds", Settings.AutoFarm, "CollectBonds")
    GUI.CreateToggle(parent, "Coletar Valores", Settings.AutoFarm, "CollectValuables")
    GUI.CreateToggle(parent, "Coletar Combustível", Settings.AutoFarm, "CollectFuel")
    GUI.CreateToggle(parent, "Coletar Munição", Settings.AutoFarm, "CollectAmmo")
    GUI.CreateToggle(parent, "Coletar Armas", Settings.AutoFarm, "CollectWeapons")
    GUI.CreateToggle(parent, "Coletar Cura", Settings.AutoFarm, "CollectHeals")
    GUI.CreateToggle(parent, "Sistema de Prioridade", Settings.AutoFarm, "PrioritySystem")
    GUI.CreateToggle(parent, "Auto Vender", Settings.AutoFarm, "AutoSell")
    GUI.CreateToggle(parent, "Pathfinding Inteligente", Settings.AutoFarm, "SmartPathfinding")
    GUI.CreateSlider(parent, "Raio de Coleta", Settings.AutoFarm, "CollectionRadius", 10, 200)
    GUI.CreateSlider(parent, "Valor Mínimo", Settings.AutoFarm, "MinValueThreshold", 0, 100)
end

function GUI.FillMegaTab(parent)
    GUI.CreateToggle(parent, "Mega Mode (Auto Win + Bonds)", Settings.MegaMode, "Enabled")
    GUI.CreateToggle(parent, "Auto Raid Cidades", Settings.MegaMode, "AutoRaidTowns")
    GUI.CreateToggle(parent, "Auto Raid Castelo", Settings.MegaMode, "AutoRaidCastle")
    GUI.CreateToggle(parent, "Auto Raid Fort Constitution", Settings.MegaMode, "AutoRaidFort")
    GUI.CreateToggle(parent, "Auto Raid Tesla Lab", Settings.MegaMode, "AutoRaidTesla")
    GUI.CreateToggle(parent, "Auto Raid Sterling", Settings.MegaMode, "AutoRaidSterling")
    GUI.CreateToggle(parent, "Auto Completar Jogo", Settings.MegaMode, "AutoCompleteGame")
    GUI.CreateToggle(parent, "Decisão Inteligente", Settings.MegaMode, "SmartDecisionMaking")
    GUI.CreateToggle(parent, "Avaliação de Risco", Settings.MegaMode, "RiskAssessment")
    GUI.CreateToggle(parent, "Escapar de Noite", Settings.MegaMode, "EscapeAtNight")
    GUI.CreateToggle(parent, "Defender Trem", Settings.MegaMode, "DefendTrain")
    GUI.CreateToggle(parent, "Gerenciar Combustível", Settings.MegaMode, "FuelManagement")
end

function GUI.FillMovementTab(parent)
    GUI.CreateToggle(parent, "Speed Hack", Settings.Movement, "SpeedEnabled")
    GUI.CreateSlider(parent, "Velocidade", Settings.Movement, "SpeedValue", 16, 150)
    GUI.CreateToggle(parent, "NoClip", Settings.Movement, "NoClip")
    GUI.CreateToggle(parent, "Fly Mode", Settings.Movement, "Fly", function(state)
        if state then MovementSystem.EnableFly() end
    end)
    GUI.CreateSlider(parent, "Velocidade Fly", Settings.Movement, "FlySpeed", 10, 300)
    GUI.CreateToggle(parent, "Auto Pular", Settings.Movement, "AutoJump")
    GUI.CreateToggle(parent, "Anti-Stuck", Settings.Movement, "AntiStuck")
    GUI.CreateToggle(parent, "Teleporte Suave", Settings.Movement, "SmoothTeleport")
    GUI.CreateToggle(parent, "Seguir Trem", Settings.Movement, "FollowTrain")
end

function GUI.FillCombatTab(parent)
    GUI.CreateToggle(parent, "Kill Aura", Settings.Combat, "KillAura")
    GUI.CreateSlider(parent, "Alcance Kill Aura", Settings.Combat, "KillAuraRange", 5, 100)
    GUI.CreateToggle(parent, "Aimbot", Settings.Combat, "Aimbot")
    GUI.CreateToggle(parent, "Auto Atacar", Settings.Combat, "AutoAttack")
    GUI.CreateToggle(parent, "Priorizar Perigosos", Settings.Combat, "PrioritizeDangerous")
    GUI.CreateToggle(parent, "Auto Recarregar", Settings.Combat, "AutoReload")
    GUI.CreateToggle(parent, "Munição Infinita", Settings.Combat, "InfiniteAmmo")
    GUI.CreateToggle(parent, "God Mode", Settings.Combat, "GodMode")
    GUI.CreateToggle(parent, "Auto Equipar Melhor Arma", Settings.Combat, "AutoEquipBestWeapon")
end

function GUI.FillSecurityTab(parent)
    GUI.CreateToggle(parent, "Anti-Detecção", Settings.Security, "AntiDetection")
    GUI.CreateToggle(parent, "Delay Aleatório", Settings.Security, "RandomDelays")
    GUI.CreateToggle(parent, "Movimento Humanizado", Settings.Security, "HumanLikeMovement")
    GUI.CreateToggle(parent, "Randomização de Ações", Settings.Security, "ActionRandomization")
    GUI.CreateToggle(parent, "Quebrador de Padrões", Settings.Security, "PatternBreaker")
    GUI.CreateToggle(parent, "Anti-AFK", Settings.Security, "AntiAFK")
    GUI.CreateToggle(parent, "Fake Lag", Settings.Security, "FakeLag")
    GUI.CreateToggle(parent, "Modo Seguro", Settings.Security, "SafeMode")
end

--// Inicialização Principal
local function Initialize()
    -- Aguardar personagem
    if not Player.Instance.Character then
        Player.Instance.CharacterAdded:Wait()
    end
    
    Player.Character = Player.Instance.Character
    Player.Humanoid = Player.Character:WaitForChild("Humanoid")
    Player.RootPart = Player.Character:WaitForChild("HumanoidRootPart")
    Player.Position = Player.RootPart.Position
    
    -- Atualizar dados do jogador
    Player.Instance.CharacterAdded:Connect(function(char)
        Player.Character = char
        Player.Humanoid = char:WaitForChild("Humanoid")
        Player.RootPart = char:WaitForChild("HumanoidRootPart")
    end)
    
    -- Atualizar posição
    Services.RunService.Heartbeat:Connect(function()
        if Player.RootPart then
            Player.Position = Player.RootPart.Position
            
            -- Calcular distância percorrida
            if State.LastPosition then
                local dist = Utils.GetDistance(State.LastPosition, Player.Position)
                State.Stats.DistanceMoved = State.Stats.DistanceMoved + dist
            end
            State.LastPosition = Player.Position
        end
        
        if Player.Humanoid then
            Player.Health = Player.Humanoid.Health
            Player.MaxHealth = Player.Humanoid.MaxHealth
        end
    end)
    
    -- Inicializar sistemas
    CacheManager.Initialize()
    MovementSystem.Initialize()
    CombatSystem.Initialize()
    FarmSystem.Initialize()
    MegaSystem.Initialize()
    SecuritySystem.Initialize()
    
    -- Criar GUI
    GUI.Create()
    
    -- Atualizar estado do jogo
    task.spawn(function()
        while true do
            State.GameTime = Utils.GetTimeOfDay()
            State.IsNight = Utils.IsNightTime()
            State.NightType = Utils.GetNightType()
            task.wait(1)
        end
    end)
    
    NotificationSystem.Create("Lost Rails", "Sistema inicializado com sucesso!", 5, "Success")
end

--// Iniciar
Initialize()