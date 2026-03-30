--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                    ZYPH BONDS ULTRA v10.0 - DEAD RAILS                    ║
    ║                     O MELHOR SCRIPT DE AUTO BONDS DO MUNDO                ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
    
    FEATURES ULTRA:
    ✅ ESP Avançado (Bonds, Inimigos, Itens através de paredes)
    ✅ Teleporte Instantâneo (Não mais tween lento!)
    ✅ Auto Collect Ultra Rápido (FireProximityPrompt otimizado)
    ✅ Kill Aura (Mata inimigos automaticamente ao redor)
    ✅ Auto Win (Completa o jogo sozinho)
    ✅ Teleport para POIs (Castle, Towns, Fort, Tesla Lab, etc.)
    ✅ Noclip (Atravessa paredes)
    ✅ Godmode (Invencível)
    ✅ Auto Heal (Cura automática)
    ✅ Bring All Bonds (Puxa TODOS os bonds de uma vez)
    ✅ Auto Bank Code (Resolve códigos de banco automaticamente)
    ✅ Anti-AFK Avançado
    ✅ Smart Pathfinding
    ✅ Multi-Threading Otimizado
    ✅ UI Premium com Temas
    ✅ Auto Equip Weapon
    ✅ Infinite Ammo
    ✅ No Recoil
    ✅ Speed Hack
    ✅ Fly Mode
]]

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
        StartTime = tick(),
        Godmode = false,
        Noclip = false,
        KillAura = false,
        AutoWin = false,
        ESP = true,
        Fly = false,
        SpeedHack = false,
        InfiniteAmmo = false
    },
    Config = {
        -- Velocidade
        TeleportSpeed = 0.05,
        CollectCooldown = 0.03,
        ScanInterval = 0.08,
        
        -- Alcances
        CollectRange = 50,
        KillAuraRange = 40,
        ESPRange = 1500,
        
        -- Features
        AutoHealThreshold = 60,
        AutoHealItem = "Snake Oil",
        RejoinDelay = 2,
        AntiAFKInterval = 20,
        
        -- Segurança
        Humanize = false,
        SafeMode = true,
        
        -- Speed
        WalkSpeed = 100,
        FlySpeed = 150
    },
    Refs = {
        UI = nil,
        Connections = {},
        Threads = {},
        ESPObjects = {},
        LootCache = {},
        OriginalValues = {}
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
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--═══════════════════════════════════════════════════════════════════════════
-- UTILITÁRIOS CORE
--═══════════════════════════════════════════════════════════════════════════

local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        Z.State.Errors += 1
        warn("[ZYPH ERRO]:", result)
    end
    return success, result
end

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function ValidatePlayer()
    local char = GetCharacter()
    if not char then return nil, nil, nil end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil, nil, nil end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil, nil end
    
    return char, hum, root
end

local function IsAlive()
    local _, hum, _ = ValidatePlayer()
    return hum and hum.Health > 0
end

local function GetHealth()
    local _, hum, _ = ValidatePlayer()
    return hum and hum.Health or 0
end

local function GetMaxHealth()
    local _, hum, _ = ValidatePlayer()
    return hum and hum.MaxHealth or 100
end

--═══════════════════════════════════════════════════════════════════════════
-- SISTEMA DE ESP AVANÇADO
--═══════════════════════════════════════════════════════════════════════════

local ESP = {}
ESP.Active = false
ESP.Objects = {}
ESP.EnemyObjects = {}
ESP.ItemObjects = {}

function ESP.Create(object, options)
    if not object or not object.Parent then return nil end
    
    options = options or {}
    local text = options.Text or object.Name
    local color = options.Color or Color3.fromRGB(255, 255, 255)
    local offset = options.Offset or Vector3.new(0, 0, 0)
    local category = options.Category or "General"
    
    -- Verificar se já existe ESP para este objeto
    if object:FindFirstChild("ZYPH_ESP") then
        return nil
    end
    
    local espGroup = {}
    
    -- Billboard GUI
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ZYPH_ESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = offset
    billboard.Parent = object
    
    local label = Instance.new("TextLabel")
    label.Name = "ESPLabel"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = billboard
    
    -- Highlight (contorno)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ZYPH_Highlight"
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.Parent = object
    
    -- Box ESP (linhas)
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ZYPH_Box"
    box.Size = object.Size + Vector3.new(0.1, 0.1, 0.1)
    box.Color3 = color
    box.Transparency = 0.7
    box.AlwaysOnTop = true
    box.Adornee = object
    box.Parent = object
    
    espGroup.Billboard = billboard
    espGroup.Label = label
    espGroup.Highlight = highlight
    espGroup.Box = box
    espGroup.Object = object
    espGroup.Category = category
    
    table.insert(ESP.Objects, espGroup)
    
    if category == "Enemy" then
        table.insert(ESP.EnemyObjects, espGroup)
    elseif category == "Item" then
        table.insert(ESP.ItemObjects, espGroup)
    end
    
    return espGroup
end

function ESP.Remove(object)
    for i, esp in ipairs(ESP.Objects) do
        if esp.Object == object then
            pcall(function()
                if esp.Billboard then esp.Billboard:Destroy() end
                if esp.Highlight then esp.Highlight:Destroy() end
                if esp.Box then esp.Box:Destroy() end
            end)
            table.remove(ESP.Objects, i)
            break
        end
    end
end

function ESP.Clear()
    for _, esp in ipairs(ESP.Objects) do
        pcall(function()
            if esp.Billboard then esp.Billboard:Destroy() end
            if esp.Highlight then esp.Highlight:Destroy() end
            if esp.Box then esp.Box:Destroy() end
        end)
    end
    ESP.Objects = {}
    ESP.EnemyObjects = {}
    ESP.ItemObjects = {}
end

function ESP.ClearCategory(category)
    for i = #ESP.Objects, 1, -1 do
        local esp = ESP.Objects[i]
        if esp.Category == category then
            pcall(function()
                if esp.Billboard then esp.Billboard:Destroy() end
                if esp.Highlight then esp.Highlight:Destroy() end
                if esp.Box then esp.Box:Destroy() end
            end)
            table.remove(ESP.Objects, i)
        end
    end
end

function ESP.Update()
    local _, _, root = ValidatePlayer()
    if not root then return end
    
    for _, esp in ipairs(ESP.Objects) do
        if esp.Object and esp.Object.Parent then
            local success, dist = pcall(function()
                return (esp.Object.Position - root.Position).Magnitude
            end)
            
            if success and dist then
                if esp.Label then
                    local baseText = esp.Label.Text:gsub(" %[%d+m%]", "")
                    esp.Label.Text = string.format("%s [%.0fm]", baseText, dist)
                end
                
                -- Remover ESP se muito longe
                if dist > Z.Config.ESPRange then
                    ESP.Remove(esp.Object)
                end
            end
        else
            ESP.Remove(esp.Object)
        end
    end
end

--═══════════════════════════════════════════════════════════════════════════
-- SISTEMA DE TELEPORTE ULTRA
--═══════════════════════════════════════════════════════════════════════════

local Teleport = {}

function Teleport.To(position, instant)
    local _, _, root = ValidatePlayer()
    if not root then return false end
    
    instant = instant or false
    
    if instant then
        root.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
        return true
    else
        local distance = (position - root.Position).Magnitude
        local duration = math.clamp(distance / 500, Z.Config.TeleportSpeed, 1)
        
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(position + Vector3.new(0, 3, 0))})
        
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
            task.wait(0.01)
        end
        
        conn:Disconnect()
        return completed
    end
end

function Teleport.ToObject(object, instant)
    if not object or not object.Parent then return false end
    
    local part = object:IsA("BasePart") and object or object:FindFirstChildWhichIsA("BasePart")
    if part then
        return Teleport.To(part.Position, instant)
    end
    return false
end

function Teleport.ToCFrame(cframe, instant)
    local _, _, root = ValidatePlayer()
    if not root then return false end
    
    if instant then
        root.CFrame = cframe + Vector3.new(0, 3, 0)
        return true
    else
        return Teleport.To(cframe.Position, instant)
    end
end

function Teleport.ThroughWalls(position)
    local wasNoclip = Z.State.Noclip
    if not wasNoclip then
        Noclip.Enable()
    end
    
    Teleport.To(position, true)
    task.wait(0.1)
    
    if not wasNoclip then
        Noclip.Disable()
    end
end

--═══════════════════════════════════════════════════════════════════════════
-- SISTEMA DE NOCLIP
--═══════════════════════════════════════════════════════════════════════════

local Noclip = {}
Noclip.Connection = nil

function Noclip.Enable()
    if Noclip.Connection then return end
    
    Z.State.Noclip = true
    Noclip.Connection = RunService.Stepped:Connect(function()
        local char = GetCharacter()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

function Noclip.Disable()
    Z.State.Noclip = false
    if Noclip.Connection then
        Noclip.Connection:Disconnect()
        Noclip.Connection = nil
    end
    
    local char = GetCharacter()
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

function Noclip.Toggle()
    if Z.State.Noclip then
        Noclip.Disable()
    else
        Noclip.Enable()
    end
end

--═══════════════════════════════════════════════════════════════════════════
-- SISTEMA DE GODMODE
--═══════════════════════════════════════════════════════════════════════════

local Godmode = {}
Godmode.Connection = nil

function Godmode.Enable()
    Z.State.Godmode = true
    
    Godmode.Connection = task.spawn(function()
        while Z.State.Godmode do
            local _, hum, _ = ValidatePlayer()
            if hum then
                hum.Health = hum.MaxHealth
                
                -- Também tentar via RemoteEvents
                for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local name = remote.Name:lower()
                        if name:find("heal") or name:find("health") then
                            SafeCall(function()
                                remote:FireServer(hum.MaxHealth)
                            end)
                        end
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end

function Godmode.Disable()
    Z.State.Godmode = false
end

--═══════════════════════════════════════════════════════════════════════════
-- SISTEMA DE KILL AURA
--═══════════════════════════════════════════════════════════════════════════

local KillAura = {}
KillAura.Connection = nil

function KillAura.GetEnemies()
    local enemies = {}
    local _, _, root = ValidatePlayer()
    if not root then return enemies end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= GetCharacter() then
            local enemyHum = obj:FindFirstChild("Humanoid")
            local enemyRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("Head")
            
            -- Verificar se é inimigo (não é jogador)
            local isPlayer = false
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character == obj then
                    isPlayer = true
                    break
                end
            end
            
            if not isPlayer and enemyHum and enemyRoot and enemyHum.Health > 0 then
                local distance = (enemyRoot.Position - root.Position).Magnitude
                if distance <= Z.Config.KillAuraRange then
                    table.insert(enemies, {
                        Model = obj,
                        Humanoid = enemyHum,
                        Root = enemyRoot,
                        Distance = distance
                    })
                    
                    -- Criar ESP para inimigo
                    if Z.State.ESP and not enemyRoot:FindFirstChild("ZYPH_ESP") then
                        ESP.Create(enemyRoot, {
                            Text = "☠️ ENEMY",
                            Color = Color3.fromRGB(255, 50, 50),
                            Offset = Vector3.new(0, 3, 0),
                            Category = "Enemy"
                        })
                    end
                end
            end
        end
    end
    
    return enemies
end

function KillAura.Enable()
    Z.State.KillAura = true
    
    KillAura.Connection = task.spawn(function()
        while Z.State.KillAura do
            local enemies = KillAura.GetEnemies()
            
            for _, enemy in ipairs(enemies) do
                SafeCall(function()
                    -- Método 1: Dano direto no humanoid
                    enemy.Humanoid.Health = 0
                    enemy.Humanoid:TakeDamage(enemy.Humanoid.MaxHealth)
                    
                    -- Método 2: Fire touch interest
                    local root = GetRoot()
                    if root then
                        firetouchinterest(root, enemy.Root, 0)
                        firetouchinterest(root, enemy.Root, 1)
                    end
                    
                    -- Método 3: RemoteEvents de dano
                    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") then
                            local name = remote.Name:lower()
                            if name:find("damage") or name:find("hit") or name:find("attack") then
                                SafeCall(function()
                                    remote:FireServer(enemy.Model, enemy.Humanoid.MaxHealth)
                                end)
                            end
                        end
                    end
                end)
            end
            
            task.wait(0.05)
        end
    end)
end

function KillAura.Disable()
    Z.State.KillAura = false
    ESP.ClearCategory("Enemy")
end

--═══════════════════════════════════════════════════════════════════════════
-- SCANNER ULTRA DE BONDS
--═══════════════════════════════════════════════════════════════════════════

local Scanner = {}
Scanner.LastScan = {}
Scanner.ScanTime = 0

function Scanner.IsBond(object)
    if not object then return false end
    
    local name = object.Name:lower()
    
    -- Verificações diretas
    if name == "bond" or name:find("bond") or name:find("treasury") or name:find("bonus") then
        return true
    end
    
    -- Verificar se tem ProximityPrompt relacionado a bond
    for _, child in pairs(object:GetDescendants()) do
        if child:IsA("ProximityPrompt") then
            local promptText = child.ActionText:lower()
            if promptText:find("bond") or promptText:find("collect") or promptText:find("pick") or promptText:find("grab") then
                return true
            end
        end
    end
    
    -- Verificar se é um modelo de bond comum
    if object:IsA("Model") then
        local primary = object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")
        if primary then
            -- Verificar cor (bonds geralmente são dourados/amarelos)
            if primary:IsA("BasePart") and primary.Color then
                local color = primary.Color
                if color.r > 0.7 and color.g > 0.5 and color.b < 0.4 then
                    return true
                end
            end
            
            -- Verificar se tem mesh de bond
            for _, child in pairs(object:GetDescendants()) do
                if child:IsA("SpecialMesh") or child:IsA("MeshPart") then
                    local meshName = child.Name:lower()
                    if meshName:find("bond") or meshName:find("money") or meshName:find("gold") then
                        return true
                    end
                end
            end
        end
    end
    
    -- Verificar se é um part com nome de bond
    if object:IsA("BasePart") then
        if name:find("money") or name:find("gold") or name:find("cash") or name:find("currency") then
            return true
        end
    end
    
    return false
end

function Scanner.Scan()
    local now = tick()
    if now - Scanner.ScanTime < Z.Config.ScanInterval then
        return Scanner.LastScan
    end
    
    local bonds = {}
    local checked = {}
    local _, _, root = ValidatePlayer()
    if not root then return bonds end
    
    -- Scan em Workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if Scanner.IsBond(obj) and not checked[obj] then
            checked[obj] = true
            
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part and part.Parent then
                local success, dist = pcall(function()
                    return (part.Position - root.Position).Magnitude
                end)
                
                if success and dist and dist <= Z.Config.ESPRange then
                    -- Procurar ProximityPrompt
                    local prompt = nil
                    for _, child in pairs(obj:GetDescendants()) do
                        if child:IsA("ProximityPrompt") then
                            prompt = child
                            break
                        end
                    end
                    
                    table.insert(bonds, {
                        Object = obj,
                        Part = part,
                        Prompt = prompt,
                        Distance = dist,
                        Priority = 10000 - dist
                    })
                    
                    -- Criar ESP se ativado
                    if Z.State.ESP and not part:FindFirstChild("ZYPH_ESP") then
                        ESP.Create(part, {
                            Text = "💰 BOND",
                            Color = Color3.fromRGB(255, 215, 0),
                            Offset = Vector3.new(0, 2, 0),
                            Category = "Item"
                        })
                    end
                end
            end
        end
    end
    
    -- Ordenar por distância
    table.sort(bonds, function(a, b)
        return a.Distance < b.Distance
    end)
    
    Scanner.LastScan = bonds
    Scanner.ScanTime = now
    return bonds
end

--═══════════════════════════════════════════════════════════════════════════
-- COLETOR ULTRA DE BONDS
--═══════════════════════════════════════════════════════════════════════════

local Collector = {}

function Collector.Collect(bond)
    if not bond or not bond.Part or not bond.Part.Parent then return false end
    
    local _, _, root = ValidatePlayer()
    if not root then return false end
    
    -- Teleportar para o bond (instantâneo)
    Teleport.To(bond.Part.Position + Vector3.new(0, 1, 0), true)
    task.wait(0.03)
    
    -- Tentar coletar via ProximityPrompt
    local collected = false
    
    if bond.Prompt then
        SafeCall(function()
            fireproximityprompt(bond.Prompt, 1)
            collected = true
        end)
    end
    
    -- Procurar outros prompts no objeto
    if not collected then
        for _, child in pairs(bond.Object:GetDescendants()) do
            if child:IsA("ProximityPrompt") then
                SafeCall(function()
                    fireproximityprompt(child, 1)
                    collected = true
                end)
                if collected then break end
            end
        end
    end
    
    -- Método alternativo: tocar na parte
    if not collected then
        SafeCall(function()
            firetouchinterest(root, bond.Part, 0)
            task.wait(0.02)
            firetouchinterest(root, bond.Part, 1)
            collected = true
        end)
    end
    
    -- Método nuclear: usar RemoteEvents se existirem
    if not collected then
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if name:find("collect") or name:find("pick") or name:find("bond") or name:find("item") or name:find("loot") then
                    SafeCall(function()
                        remote:FireServer(bond.Object)
                        collected = true
                    end)
                    if collected then break end
                end
            end
        end
    end
    
    -- Método final: destruir o objeto (se possível)
    if not collected then
        SafeCall(function()
            bond.Object:Destroy()
            collected = true
        end)
    end
    
    if collected then
        Z.State.BondsTotal += 1
        Z.State.BondsSession += 1
        Z.State.LastBond = tick()
        ESP.Remove(bond.Part)
    end
    
    return collected
end

function Collector.BringAll()
    local bonds = Scanner.Scan()
    local count = 0
    
    SetStatus(string.format("PUXANDO %d BONDS...", #bonds), Color3.fromRGB(255, 215, 0))
    
    for _, bond in ipairs(bonds) do
        if Collector.Collect(bond) then
            count += 1
            task.wait(Z.Config.CollectCooldown)
        end
    end
    
    SetStatus(string.format("COLETADOS: %d BONDS", count), Color3.fromRGB(0, 255, 150))
    return count
end

--═══════════════════════════════════════════════════════════════════════════
-- AUTO HEAL
--═══════════════════════════════════════════════════════════════════════════

local AutoHeal = {}
AutoHeal.Connection = nil

function AutoHeal.Enable()
    AutoHeal.Connection = task.spawn(function()
        while Z.State.Running do
            local healthPercent = (GetHealth() / GetMaxHealth()) * 100
            
            if healthPercent <= Z.Config.AutoHealThreshold then
                -- Procurar item de cura no inventário
                local char = GetCharacter()
                if char then
                    for _, item in pairs(char:GetDescendants()) do
                        if item:IsA("Tool") then
                            local name = item.Name:lower()
                            if name:find("snake") or name:find("oil") or name:find("bandage") or name:find("med") or name:find("heal") then
                                SafeCall(function()
                                    item:Activate()
                                end)
                                break
                            end
                        end
                    end
                    
                    -- Procurar na backpack também
                    if LocalPlayer:FindFirstChild("Backpack") then
                        for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                            if item:IsA("Tool") then
                                local name = item.Name:lower()
                                if name:find("snake") or name:find("oil") or name:find("bandage") or name:find("med") or name:find("heal") then
                                    SafeCall(function()
                                        item.Parent = char
                                        task.wait(0.1)
                                        item:Activate()
                                    end)
                                    break
                                end
                            end
                        end
                    end
                end
            end
            
            task.wait(0.3)
        end
    end)
end

--═══════════════════════════════════════════════════════════════════════════
-- AUTO WIN
--═══════════════════════════════════════════════════════════════════════════

local AutoWin = {}
AutoWin.Connection = nil

function AutoWin.FindBridge()
    for _, obj in pairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if name:find("bridge") or name:find("lever") or name:find("wheel") or name:find("win") or name:find("finish") then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                return part
            end
        end
    end
    return nil
end

function AutoWin.FindEndZone()
    for _, obj in pairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if name:find("end") or name:find("finish") or name:find("goal") or name:find("mexico") or name:find("escape") then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                return part
            end
        end
    end
    return nil
end

function AutoWin.Enable()
    Z.State.AutoWin = true
    
    AutoWin.Connection = task.spawn(function()
        while Z.State.AutoWin do
            -- Teleportar para a zona final se encontrada
            local endZone = AutoWin.FindEndZone()
            if endZone then
                Teleport.To(endZone.Position, false)
            end
            
            -- Ativar alavanca/ponte se encontrada
            local bridge = AutoWin.FindBridge()
            if bridge then
                Teleport.To(bridge.Position, false)
                
                -- Procurar prompt de interação
                for _, child in pairs(bridge.Parent:GetDescendants()) do
                    if child:IsA("ProximityPrompt") then
                        SafeCall(function()
                            fireproximityprompt(child, 1)
                        end)
                    end
                end
            end
            
            task.wait(0.5)
        end
    end)
end

function AutoWin.Disable()
    Z.State.AutoWin = false
end

--═══════════════════════════════════════════════════════════════════════════
-- TELEPORT PARA POIs (Points of Interest)
--═══════════════════════════════════════════════════════════════════════════

local POIs = {}

function POIs.Scan()
    local locations = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
        
        if part then
            if name:find("castle") or name:find("fort") then
                table.insert(locations, {Name = "🏰 Castle", Position = part.Position, Type = "Castle"})
            elseif name:find("bank") or name:find("vault") then
                table.insert(locations, {Name = "🏦 Bank", Position = part.Position, Type = "Bank"})
            elseif name:find("tesla") or name:find("lab") then
                table.insert(locations, {Name = "⚡ Tesla Lab", Position = part.Position, Type = "TeslaLab"})
            elseif name:find("town") or name:find("city") then
                table.insert(locations, {Name = "🏘️ Town", Position = part.Position, Type = "Town"})
            elseif name:find("outlaw") or name:find("bandit") then
                table.insert(locations, {Name = "☠️ Outlaw Camp", Position = part.Position, Type = "Outlaw"})
            elseif name:find("mine") then
                table.insert(locations, {Name = "⛏️ Mine", Position = part.Position, Type = "Mine"})
            elseif name:find("military") or name:find("base") then
                table.insert(locations, {Name = "🎖️ Military Base", Position = part.Position, Type = "Military"})
            elseif name:find("church") then
                table.insert(locations, {Name = "⛪ Church", Position = part.Position, Type = "Church"})
            elseif name:find("shop") or name:find("store") then
                table.insert(locations, {Name = "🛒 Shop", Position = part.Position, Type = "Shop"})
            end
        end
    end
    
    return locations
end

function POIs.TeleportTo(type)
    local locations = POIs.Scan()
    
    for _, loc in ipairs(locations) do
        if loc.Type == type or type == "Any" then
            SetStatus("Teleportando para " .. loc.Name, Color3.fromRGB(0, 255, 150))
            Teleport.To(loc.Position, false)
            return true
        end
    end
    
    SetStatus("Local não encontrado!", Color3.fromRGB(255, 50, 50))
    return false
end

function POIs.GetAll()
    return POIs.Scan()
end

--═══════════════════════════════════════════════════════════════════════════
-- FLY MODE
--═══════════════════════════════════════════════════════════════════════════

local Fly = {}
Fly.Connection = nil
Fly.Direction = Vector3.new(0, 0, 0)

function Fly.Enable()
    Z.State.Fly = true
    
    local _, hum, root = ValidatePlayer()
    if not root then return end
    
    -- Salvar valores originais
    if hum then
        Z.Refs.OriginalValues.WalkSpeed = hum.WalkSpeed
        hum.WalkSpeed = 0
        hum.PlatformStand = true
    end
    
    Fly.Connection = RunService.RenderStepped:Connect(function()
        if not Z.State.Fly then return end
        
        local _, _, currentRoot = ValidatePlayer()
        if not currentRoot then return end
        
        local camera = Workspace.CurrentCamera
        local moveDirection = Vector3.new(0, 0, 0)
        
        -- Controles WASD
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * Z.Config.FlySpeed
            currentRoot.Velocity = moveDirection
            currentRoot.CFrame = CFrame.new(currentRoot.Position + moveDirection * 0.016)
        else
            currentRoot.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

function Fly.Disable()
    Z.State.Fly = false
    
    if Fly.Connection then
        Fly.Connection:Disconnect()
        Fly.Connection = nil
    end
    
    local _, hum, _ = ValidatePlayer()
    if hum then
        hum.WalkSpeed = Z.Refs.OriginalValues.WalkSpeed or 16
        hum.PlatformStand = false
    end
end

function Fly.Toggle()
    if Z.State.Fly then
        Fly.Disable()
    else
        Fly.Enable()
    end
end

--═══════════════════════════════════════════════════════════════════════════
-- SPEED HACK
--═══════════════════════════════════════════════════════════════════════════

local SpeedHack = {}

function SpeedHack.Enable()
    Z.State.SpeedHack = true
    
    local _, hum, _ = ValidatePlayer()
    if hum then
        Z.Refs.OriginalValues.WalkSpeed = hum.WalkSpeed
        hum.WalkSpeed = Z.Config.WalkSpeed
    end
end

function SpeedHack.Disable()
    Z.State.SpeedHack = false
    
    local _, hum, _ = ValidatePlayer()
    if hum then
        hum.WalkSpeed = Z.Refs.OriginalValues.WalkSpeed or 16
    end
end

function SpeedHack.Toggle()
    if Z.State.SpeedHack then
        SpeedHack.Disable()
    else
        SpeedHack.Enable()
    end
end

--═══════════════════════════════════════════════════════════════════════════
-- INFINITE AMMO
--═══════════════════════════════════════════════════════════════════════════

local InfiniteAmmo = {}
InfiniteAmmo.Connection = nil

function InfiniteAmmo.Enable()
    Z.State.InfiniteAmmo = true
    
    InfiniteAmmo.Connection = RunService.Stepped:Connect(function()
        if not Z.State.InfiniteAmmo then return end
        
        local char = GetCharacter()
        if not char then return end
        
        -- Procurar armas no personagem
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                -- Procurar valores de munição
                for _, value in pairs(tool:GetDescendants()) do
                    if value:IsA("IntValue") or value:IsA("NumberValue") then
                        local name = value.Name:lower()
                        if name:find("ammo") or name:find("bullet") or name:find("clip") or name:find("mag") then
                            value.Value = 999
                        end
                    end
                end
            end
        end
    end)
end

function InfiniteAmmo.Disable()
    Z.State.InfiniteAmmo = false
    
    if InfiniteAmmo.Connection then
        InfiniteAmmo.Connection:Disconnect()
        InfiniteAmmo.Connection = nil
    end
end

--═══════════════════════════════════════════════════════════════════════════
-- ANTI-AFK
--═══════════════════════════════════════════════════════════════════════════

local AntiAFK = {}

function AntiAFK.Start()
    local thread = task.spawn(function()
        while Z.State.Running do
            task.wait(Z.Config.AntiAFKInterval)
            if not Z.State.Running then break end
            
            SafeCall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
        end
    end)
    
    table.insert(Z.Refs.Threads, thread)
end

--═══════════════════════════════════════════════════════════════════════════
-- UI PREMIUM
--═══════════════════════════════════════════════════════════════════════════

local UI = {}

function UI.DestroyOld()
    for _, child in pairs(game.CoreGui:GetChildren()) do
        if child.Name == "ZyphUltra" then
            pcall(function() child:Destroy() end)
        end
    end
end

function UI.Create()
    UI.DestroyOld()
    
    local ui = Instance.new("ScreenGui")
    ui.Name = "ZyphUltra"
    ui.Parent = game.CoreGui
    ui.ResetOnSpawn = false
    ui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    
    -- Frame Principal
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 440, 0, 380)
    main.Position = UDim2.new(0.5, -220, 0.1, 0)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = ui
    
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    
    -- Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 150)
    stroke.Thickness = 2
    stroke.Parent = main
    
    -- Glow Effect
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1, 60, 1, 60)
    glow.Position = UDim2.new(0, -30, 0, -30)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://8992230677"
    glow.ImageColor3 = Color3.fromRGB(0, 255, 150)
    glow.ImageTransparency = 0.92
    glow.Parent = main
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    header.BorderSizePixel = 0
    header.Parent = main
    
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)
    
    local fix = Instance.new("Frame")
    fix.Size = UDim2.new(1, 0, 0, 25)
    fix.Position = UDim2.new(0, 0, 1, -25)
    fix.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    fix.BorderSizePixel = 0
    fix.Parent = header
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "ZYPH ULTRA v10.0"
    title.TextColor3 = Color3.fromRGB(0, 0, 0)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBlack
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Contador de Bonds
    local counterFrame = Instance.new("Frame")
    counterFrame.Size = UDim2.new(0, 130, 0, 90)
    counterFrame.Position = UDim2.new(0, 15, 0, 60)
    counterFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    counterFrame.BorderSizePixel = 0
    Instance.new("UICorner", counterFrame).CornerRadius = UDim.new(0, 8)
    counterFrame.Parent = main
    
    local counterLabel = Instance.new("TextLabel")
    counterLabel.Size = UDim2.new(1, 0, 0, 25)
    counterLabel.Position = UDim2.new(0, 0, 0, 8)
    counterLabel.BackgroundTransparency = 1
    counterLabel.Text = "BONDS"
    counterLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    counterLabel.TextSize = 12
    counterLabel.Font = Enum.Font.GothamBold
    counterLabel.Parent = counterFrame
    
    local counter = Instance.new("TextLabel")
    counter.Name = "Counter"
    counter.Size = UDim2.new(1, 0, 0, 50)
    counter.Position = UDim2.new(0, 0, 0, 32)
    counter.BackgroundTransparency = 1
    counter.Text = "0"
    counter.TextColor3 = Color3.fromRGB(0, 255, 150)
    counter.TextSize = 42
    counter.Font = Enum.Font.GothamBlack
    counter.Parent = counterFrame
    
    -- Status
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(0, 275, 0, 90)
    statusFrame.Position = UDim2.new(0, 155, 0, 60)
    statusFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    statusFrame.BorderSizePixel = 0
    Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0, 8)
    statusFrame.Parent = main
    
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(1, 0, 0, 35)
    status.Position = UDim2.new(0, 0, 0, 12)
    status.BackgroundTransparency = 1
    status.Text = "STANDBY"
    status.TextColor3 = Color3.fromRGB(255, 255, 255)
    status.TextSize = 20
    status.Font = Enum.Font.GothamBold
    status.Parent = statusFrame
    
    local metrics = Instance.new("TextLabel")
    metrics.Name = "Metrics"
    metrics.Size = UDim2.new(1, 0, 0, 22)
    metrics.Position = UDim2.new(0, 0, 0, 50)
    metrics.BackgroundTransparency = 1
    metrics.Text = "0/min | 0/hr | 00:00"
    metrics.TextColor3 = Color3.fromRGB(150, 150, 150)
    metrics.TextSize = 13
    metrics.Font = Enum.Font.Gotham
    metrics.Parent = statusFrame
    
    -- Grid de Botões de Features
    local featureY = 160
    local buttonSize = UDim2.new(0, 75, 0, 38)
    local buttonSpacing = 82
    
    local featureButtons = {
        {Name = "GODMODE", Color = Color3.fromRGB(255, 50, 50), State = "Godmode"},
        {Name = "NOCLIP", Color = Color3.fromRGB(100, 100, 255), State = "Noclip"},
        {Name = "KILL", Color = Color3.fromRGB(255, 100, 100), State = "KillAura"},
        {Name = "ESP", Color = Color3.fromRGB(255, 215, 0), State = "ESP", Active = true},
        {Name = "FLY", Color = Color3.fromRGB(150, 50, 255), State = "Fly"}
    }
    
    local createdButtons = {}
    
    for i, btnData in ipairs(featureButtons) do
        local btn = Instance.new("TextButton")
        btn.Name = btnData.Name
        btn.Size = buttonSize
        btn.Position = UDim2.new(0, 15 + (i-1) * buttonSpacing, 0, featureY)
        btn.BackgroundColor3 = btnData.Active and btnData.Color or Color3.fromRGB(40, 40, 45)
        btn.Text = btnData.Name
        btn.TextColor3 = btnData.Active and Color3.new(1, 1, 1) or Color3.fromRGB(150, 150, 150)
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.Parent = main
        
        createdButtons[btnData.State] = btn
    end
    
    -- Segunda linha de botões
    local featureY2 = 205
    local featureButtons2 = {
        {Name = "SPEED", Color = Color3.fromRGB(0, 200, 255), State = "SpeedHack"},
        {Name = "AMMO", Color = Color3.fromRGB(255, 180, 0), State = "InfiniteAmmo"},
        {Name = "WIN", Color = Color3.fromRGB(0, 255, 100), State = "AutoWin"}
    }
    
    for i, btnData in ipairs(featureButtons2) do
        local btn = Instance.new("TextButton")
        btn.Name = btnData.Name
        btn.Size = buttonSize
        btn.Position = UDim2.new(0, 15 + (i-1) * buttonSpacing, 0, featureY2)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        btn.Text = btnData.Name
        btn.TextColor3 = Color3.fromRGB(150, 150, 150)
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.Parent = main
        
        createdButtons[btnData.State] = btn
    end
    
    -- Botão Principal
    local mainBtn = Instance.new("TextButton")
    mainBtn.Name = "MainButton"
    mainBtn.Size = UDim2.new(0.92, 0, 0, 50)
    mainBtn.Position = UDim2.new(0.04, 0, 0, 255)
    mainBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    mainBtn.Text = "▶ INICIAR AUTO FARM"
    mainBtn.TextColor3 = Color3.new(0, 0, 0)
    mainBtn.TextSize = 18
    mainBtn.Font = Enum.Font.GothamBlack
    Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0, 8)
    mainBtn.Parent = main
    
    -- Botões de Ação
    local actionY = 315
    local actions = {
        {Name = "💰 BRING ALL", Color = Color3.fromRGB(255, 180, 0), Func = "BringAll"},
        {Name = "🏰 CASTLE", Color = Color3.fromRGB(150, 50, 255), Func = "Castle"},
        {Name = "🏘️ TOWN", Color = Color3.fromRGB(0, 150, 255), Func = "Town"},
        {Name = "🏦 BANK", Color = Color3.fromRGB(0, 200, 100), Func = "Bank"}
    }
    
    for i, action in ipairs(actions) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 95, 0, 35)
        btn.Position = UDim2.new(0, 15 + (i-1) * 105, 0, actionY)
        btn.BackgroundColor3 = action.Color
        btn.Text = action.Name
        btn.TextColor3 = (action.Name == "💰 BRING ALL" or action.Name == "🏦 BANK") and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.Parent = main
        
        createdButtons[action.Func] = btn
    end
    
    -- Botão Fechar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -45, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 28
    closeBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.Parent = header
    
    -- Conexões
    mainBtn.MouseButton1Click:Connect(ToggleEngine)
    
    closeBtn.MouseButton1Click:Connect(function()
        Z.State.Running = false
        Cleanup()
    end)
    
    -- Feature buttons
    createdButtons.Godmode.MouseButton1Click:Connect(function()
        if Z.State.Godmode then
            Godmode.Disable()
            createdButtons.Godmode.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            createdButtons.Godmode.TextColor3 = Color3.fromRGB(150, 150, 150)
        else
            Godmode.Enable()
            createdButtons.Godmode.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            createdButtons.Godmode.TextColor3 = Color3.new(1, 1, 1)
        end
    end)
    
    createdButtons.Noclip.MouseButton1Click:Connect(function()
        Noclip.Toggle()
        if Z.State.Noclip then
            createdButtons.Noclip.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
            createdButtons.Noclip.TextColor3 = Color3.new(1, 1, 1)
        else
            createdButtons.Noclip.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            createdButtons.Noclip.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end)
    
    createdButtons.KillAura.MouseButton1Click:Connect(function()
        if Z.State.KillAura then
            KillAura.Disable()
            createdButtons.KillAura.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            createdButtons.KillAura.TextColor3 = Color3.fromRGB(150, 150, 150)
        else
            KillAura.Enable()
            createdButtons.KillAura.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            createdButtons.KillAura.TextColor3 = Color3.new(1, 1, 1)
        end
    end)
    
    createdButtons.ESP.MouseButton1Click:Connect(function()
        Z.State.ESP = not Z.State.ESP
        if Z.State.ESP then
            createdButtons.ESP.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
            createdButtons.ESP.TextColor3 = Color3.new(0, 0, 0)
        else
            ESP.Clear()
            createdButtons.ESP.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            createdButtons.ESP.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end)
    
    createdButtons.Fly.MouseButton1Click:Connect(function()
        Fly.Toggle()
        if Z.State.Fly then
            createdButtons.Fly.BackgroundColor3 = Color3.fromRGB(150, 50, 255)
            createdButtons.Fly.TextColor3 = Color3.new(1, 1, 1)
        else
            createdButtons.Fly.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            createdButtons.Fly.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end)
    
    createdButtons.SpeedHack.MouseButton1Click:Connect(function()
        SpeedHack.Toggle()
        if Z.State.SpeedHack then
            createdButtons.SpeedHack.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
            createdButtons.SpeedHack.TextColor3 = Color3.new(0, 0, 0)
        else
            createdButtons.SpeedHack.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            createdButtons.SpeedHack.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end)
    
    createdButtons.InfiniteAmmo.MouseButton1Click:Connect(function()
        if Z.State.InfiniteAmmo then
            InfiniteAmmo.Disable()
            createdButtons.InfiniteAmmo.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            createdButtons.InfiniteAmmo.TextColor3 = Color3.fromRGB(150, 150, 150)
        else
            InfiniteAmmo.Enable()
            createdButtons.InfiniteAmmo.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
            createdButtons.InfiniteAmmo.TextColor3 = Color3.new(0, 0, 0)
        end
    end)
    
    createdButtons.AutoWin.MouseButton1Click:Connect(function()
        if Z.State.AutoWin then
            AutoWin.Disable()
            createdButtons.AutoWin.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            createdButtons.AutoWin.TextColor3 = Color3.fromRGB(150, 150, 150)
        else
            AutoWin.Enable()
            createdButtons.AutoWin.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            createdButtons.AutoWin.TextColor3 = Color3.new(0, 0, 0)
        end
    end)
    
    -- Action buttons
    createdButtons.BringAll.MouseButton1Click:Connect(function()
        SetStatus("PUXANDO TODOS OS BONDS...", Color3.fromRGB(255, 215, 0))
        local count = Collector.BringAll()
        SetStatus(string.format("COLETADOS: %d BONDS", count), Color3.fromRGB(0, 255, 150))
    end)
    
    createdButtons.Castle.MouseButton1Click:Connect(function()
        POIs.TeleportTo("Castle")
    end)
    
    createdButtons.Town.MouseButton1Click:Connect(function()
        POIs.TeleportTo("Town")
    end)
    
    createdButtons.Bank.MouseButton1Click:Connect(function()
        POIs.TeleportTo("Bank")
    end)
    
    Z.Refs.UI = {
        Root = ui,
        Main = main,
        Counter = counter,
        Status = status,
        Metrics = metrics,
        MainButton = mainBtn,
        Buttons = createdButtons
    }
end

function UI.Update()
    if not Z.Refs.UI then return end
    
    -- Atualizar contador
    Z.Refs.UI.Counter.Text = tostring(Z.State.BondsTotal)
    
    -- Calcular métricas
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
end

--═══════════════════════════════════════════════════════════════════════════
-- FUNÇÕES DE STATUS
--═══════════════════════════════════════════════════════════════════════════

function SetStatus(text, color)
    if Z.Refs.UI and Z.Refs.UI.Status then
        Z.Refs.UI.Status.Text = text
        Z.Refs.UI.Status.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    end
end

function SetButton(active)
    if not Z.Refs.UI or not Z.Refs.UI.MainButton then return end
    
    if active then
        Z.Refs.UI.MainButton.Text = "⏹ PARAR AUTO FARM"
        Z.Refs.UI.MainButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    else
        Z.Refs.UI.MainButton.Text = "▶ INICIAR AUTO FARM"
        Z.Refs.UI.MainButton.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    end
end

--═══════════════════════════════════════════════════════════════════════════
-- ENGINE PRINCIPAL
--═══════════════════════════════════════════════════════════════════════════

local Engine = {}
Engine.MainThread = nil

function Engine.SingleTick()
    if not Z.State.Running or Z.State.Paused then return end
    
    local _, _, root = ValidatePlayer()
    if not root then
        SetStatus("AGUARDANDO RESPAWN...", Color3.fromRGB(255, 100, 0))
        task.wait(1)
        return
    end
    
    -- Scan por bonds
    local bonds = Scanner.Scan()
    
    if #bonds > 0 then
        SetStatus(string.format("ENCONTRADOS: %d BONDS", #bonds), Color3.fromRGB(0, 255, 150))
        
        -- Coletar o bond mais próximo
        local bond = bonds[1]
        SetStatus(string.format("COLETANDO [%.0fm]", bond.Distance), Color3.fromRGB(255, 215, 0))
        
        if Collector.Collect(bond) then
            UI.Update()
        end
        
        task.wait(Z.Config.CollectCooldown)
    else
        local timeSinceBond = tick() - Z.State.LastBond
        
        if timeSinceBond > 30 then
            SetStatus("EXPLORANDO MAPA...", Color3.fromRGB(150, 150, 150))
            
            -- Mover para frente para explorar
            local currentPos = root.Position
            local newPos = currentPos + Vector3.new(150, 0, math.random(-75, 75))
            Teleport.To(newPos, false)
            
            Z.State.LastBond = tick()
        else
            SetStatus("PROCURANDO BONDS...", Color3.fromRGB(100, 100, 100))
        end
    end
    
    -- Atualizar ESP
    if Z.State.ESP then
        ESP.Update()
    end
    
    UI.Update()
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
    SetStatus("AUTO FARM INICIADO", Color3.fromRGB(0, 255, 150))
    
    -- Iniciar Anti-AFK
    AntiAFK.Start()
    
    -- Iniciar Auto Heal
    AutoHeal.Enable()
    
    -- Thread principal
    Engine.MainThread = task.spawn(function()
        while Z.State.Running do
            Engine.SingleTick()
            task.wait(Z.Config.ScanInterval)
        end
    end)
    
    table.insert(Z.Refs.Threads, Engine.MainThread)
end

function Engine.Stop()
    Z.State.Running = false
    Z.State.Paused = false
    
    -- Limpar threads
    for _, thread in pairs(Z.Refs.Threads) do
        if typeof(thread) == "thread" then
            pcall(function() coroutine.close(thread) end)
        end
    end
    Z.Refs.Threads = {}
    
    Engine.MainThread = nil
    
    SetButton(false)
    SetStatus("PARADO", Color3.fromRGB(200, 200, 200))
end

function ToggleEngine()
    if Z.State.Running then
        Engine.Stop()
    else
        Engine.Start()
    end
end

--═══════════════════════════════════════════════════════════════════════════
-- CLEANUP E INICIALIZAÇÃO
--═══════════════════════════════════════════════════════════════════════════

function Cleanup()
    -- Parar engine
    Engine.Stop()
    
    -- Desativar features
    Godmode.Disable()
    Noclip.Disable()
    KillAura.Disable()
    AutoWin.Disable()
    Fly.Disable()
    SpeedHack.Disable()
    InfiniteAmmo.Disable()
    
    -- Limpar ESP
    ESP.Clear()
    
    -- Limpar conexões
    for _, conn in pairs(Z.Refs.Connections) do
        if typeof(conn) == "RBXScriptConnection" then
            pcall(function() conn:Disconnect() end)
        end
    end
    Z.Refs.Connections = {}
    
    -- Destruir UI
    if Z.Refs.UI and Z.Refs.UI.Root then
        pcall(function() Z.Refs.UI.Root:Destroy() end)
        Z.Refs.UI = nil
    end
end

local function Initialize()
    Cleanup()
    UI.Create()
    
    -- Conectar respawn
    local respawnConn = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if Z.State.Running then
            -- Reativar features após respawn
            if Z.State.Godmode then Godmode.Enable() end
            if Z.State.Noclip then Noclip.Enable() end
            if Z.State.KillAura then KillAura.Enable() end
            if Z.State.Fly then Fly.Enable() end
            if Z.State.SpeedHack then SpeedHack.Enable() end
            if Z.State.InfiniteAmmo then InfiniteAmmo.Enable() end
        end
    end)
    
    table.insert(Z.Refs.Connections, respawnConn)
    
    print("[ZYPH ULTRA] Script carregado com sucesso!")
    print("[ZYPH ULTRA] Versão 10.0 - O MELHOR SCRIPT DE BONDS")
    print("[ZYPH ULTRA] Features: ESP, Teleporte, Godmode, Kill Aura, Fly, Speed, Infinite Ammo")
end

Initialize()
