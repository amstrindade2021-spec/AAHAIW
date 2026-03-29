-- DEAD RAILS ULTRA HUB V5
-- Combina Skull Hub + Nat Hub + Kiciahook + Speed Hub X
-- Features: Auto Bond Farm, Bring All, Kill Aura, Gun Hacks, Aimbot, Hitbox Expander

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = Workspace.CurrentCamera

-- Rayfield UI Library (Embed)
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

local Window = Rayfield:CreateWindow({
    Name = "🔥 DEAD RAILS ULTRA V5 🔥",
    LoadingTitle = "Carregando Ultra Hub...",
    LoadingSubtitle = "by Anonymous",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "DeadRailsUltra",
       FileName = "Config"
    },
    Discord = {
       Enabled = false,
       Invite = "",
       RememberJoins = true
    },
    KeySystem = false
})

-- Tabs
local MainTab = Window:CreateTab("💰 Auto Farm", nil)
local CombatTab = Window:CreateTab("⚔️ Combat", nil)
local VisualTab = Window:CreateTab("👁️ Visual", nil)
local TeleportTab = Window:CreateTab("🚀 Teleport", nil)
local MiscTab = Window:CreateTab("⚙️ Misc", nil)

-- Variáveis
local Settings = {
    AutoBond = false,
    BringAllItems = false,
    KillAura = false,
    KillAuraRange = 50,
    GunMods = false,
    Aimbot = false,
    AimbotPart = "Head",
    HitboxExpander = false,
    HitboxSize = 50,
    AutoHeal = false,
    AutoHealThreshold = 50,
    NoRecoil = false,
    RapidFire = false,
    InstantReload = false,
    ESP = false,
    FullBright = false,
    NoFog = false,
    Speed = false,
    SpeedValue = 120,
    Fly = false,
    AutoDrive = false
}

-- Auto Bond Farm (Baseado nos scripts de farm)[^10^]
local function AutoBondFarm()
    if game.PlaceId == 116495829188952 then
        -- Lobby
        local CreateParty = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CreatePartyClient")
        local HRP = LocalPlayer.Character.HumanoidRootPart
        
        while task.wait(0.1) do
            if not Settings.AutoBond then break end
            for _, v in pairs(Workspace.TeleportZones:GetChildren()) do
                if v.Name == "TeleportZone" and v.BillboardGui.StateLabel.Text == "Waiting for players..." then
                    HRP.CFrame = v.ZoneContainer.CFrame
                    task.wait(1)
                    CreateParty:FireServer({["maxPlayers"] = 1})
                end
            end
        end
    else
        -- In Game
        local StartingTrack = Workspace.RailSegments:FindFirstChild("RailSegment")
        local CollectBond = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ActivateObjectClient")
        local Items = Workspace:WaitForChild("RuntimeItems")
        
        RootPart.Anchored = true
        
        while task.wait(0.1) do
            if not Settings.AutoBond then 
                RootPart.Anchored = false
                break 
            end
            
            if StartingTrack and StartingTrack:FindFirstChild("Guide") then
                RootPart.CFrame = StartingTrack.Guide.CFrame + Vector3.new(0, 250, 0)
                
                if StartingTrack.NextTrack.Value ~= nil then
                    StartingTrack = StartingTrack.NextTrack.Value
                else
                    game:GetService("TeleportService"):Teleport(116495829188952, LocalPlayer)
                end
            end
            
            -- Coletar TODOS os bonds[^10^]
            for _, v in pairs(Items:GetChildren()) do
                if v.Name == "Bond" or v.Name == "BondCalculated" then
                    pcall(function()
                        v.Part.CFrame = RootPart.CFrame
                        CollectBond:FireServer(v)
                    end)
                    v.Name = "BondCalculated"
                end
            end
        end
    end
end

-- Bring All Items (Sistema Lomu Hub style)[^11^]
local function BringItems()
    while task.wait(0.1) do
        if not Settings.BringAllItems then break end
        local Items = Workspace:FindFirstChild("RuntimeItems")
        if Items then
            for _, item in pairs(Items:GetChildren()) do
                if item:IsA("Model") or item:IsA("BasePart") then
                    local part = item:IsA("Model") and item:FindFirstChildWhichIsA("BasePart") or item
                    if part then
                        part.CFrame = RootPart.CFrame + Vector3.new(math.random(-5,5), 0, math.random(-5,5))
                    end
                end
            end
        end
    end
end

-- Kill Aura (Sistema Nat Hub)[^11^]
local function KillAura()
    while task.wait(0.1) do
        if not Settings.KillAura then break end
        
        for _, enemy in pairs(Workspace:GetDescendants()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                if enemy ~= Character then
                    local dist = (enemy.HumanoidRootPart.Position - RootPart.Position).Magnitude
                    if dist <= Settings.KillAuraRange then
                        -- Dano massivo
                        pcall(function()
                            enemy.Humanoid.Health = 0
                        end)
                        -- Usar arma se tiver
                        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if tool then
                            tool:Activate()
                        end
                    end
                end
            end
        end
    end
end

-- Gun Mods (No Recoil, Rapid Fire)[^11^]
local function ApplyGunMods()
    while task.wait(1) do
        if not Settings.GunMods then break end
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Configuration") then
            local config = tool.Configuration
            if Settings.RapidFire then
                config.FireRate = 0.01
            end
            if Settings.InstantReload then
                config.ReloadTime = 0.01
            end
            if Settings.NoRecoil then
                config.Recoil = 0
                config.MaxSpread = 0
                config.MinSpread = 0
            end
        end
    end
end

-- Aimbot (Sistema Speed Hub)[^10^]
local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = math.huge
    
    for _, enemy in pairs(Workspace:GetDescendants()) do
        if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
            if enemy ~= Character and enemy.Humanoid.Health > 0 then
                local pos = Camera:WorldToViewportPoint(enemy.HumanoidRootPart.Position)
                local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if dist < shortestDistance and dist < 400 then
                    shortestDistance = dist
                    closest = enemy
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if Settings.Aimbot then
        local target = GetClosestPlayer()
        if target and target:FindFirstChild(Settings.AimbotPart) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target[Settings.AimbotPart].Position)
        end
    end
end)

-- Hitbox Expander (Sistema SpiderX)[^11^]
local function ExpandHitbox()
    while task.wait(1) do
        if not Settings.HitboxExpander then 
            -- Reset hitboxes
            for _, enemy in pairs(Workspace:GetDescendants()) do
                if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") then
                    enemy.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                end
            end
            break 
        end
        
        for _, enemy in pairs(Workspace:GetDescendants()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") then
                if enemy ~= Character then
                    enemy.HumanoidRootPart.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                    enemy.HumanoidRootPart.Transparency = 0.7
                    enemy.HumanoidRootPart.BrickColor = BrickColor.new("Bright red")
                    enemy.HumanoidRootPart.CanCollide = false
                end
            end
        end
    end
end

-- Auto Heal
local function AutoHeal()
    while task.wait(0.5) do
        if not Settings.AutoHeal then break end
        if Humanoid.Health <= Settings.AutoHealThreshold then
            local tool = LocalPlayer.Backpack:FindFirstChild("Bandage") or LocalPlayer.Character:FindFirstChild("Bandage")
            if tool then
                Humanoid:EquipTool(tool)
                tool:Activate()
            end
        end
    end
end

-- ESP (Sistema Chams)[^10^]
local ESPObjects = {}
local function UpdateESP()
    if not Settings.ESP then
        for _, obj in pairs(ESPObjects) do
            if obj then obj:Destroy() end
        end
        ESPObjects = {}
        return
    end
    
    for _, obj in pairs(ESPObjects) do
        if obj then obj:Destroy() end
    end
    ESPObjects = {}
    
    -- ESP Inimigos
    for _, enemy in pairs(Workspace:GetDescendants()) do
        if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("Head") then
            if enemy ~= Character then
                local esp = Instance.new("BillboardGui")
                esp.Size = UDim2.new(0, 200, 0, 50)
                esp.AlwaysOnTop = true
                esp.StudsOffset = Vector3.new(0, 3, 0)
                
                local text = Instance.new("TextLabel")
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.Text = enemy.Name .. " [" .. math.floor(enemy.Humanoid.Health) .. "]"
                text.TextColor3 = Color3.fromRGB(255, 0, 0)
                text.TextStrokeTransparency = 0
                text.Parent = esp
                
                esp.Adornee = enemy.Head
                esp.Parent = game.CoreGui
                table.insert(ESPObjects, esp)
                
                -- Box ESP
                local box = Instance.new("BoxHandleAdornment")
                box.Size = enemy:GetExtentsSize()
                box.Adornee = enemy
                box.AlwaysOnTop = true
                box.ZIndex = 0
                box.Transparency = 0.5
                box.Color3 = Color3.fromRGB(255, 0, 0)
                box.Parent = game.CoreGui
                table.insert(ESPObjects, box)
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if tick() % 2 < 0.1 then -- Atualizar a cada 2 segundos
        if Settings.ESP then
            UpdateESP()
        end
    end
end)

-- Full Bright / No Fog
local OldBrightness = Lighting.Brightness
local OldFog = Lighting.FogEnd

-- UI ELEMENTS

-- Tab 1: Auto Farm
MainTab:CreateToggle({
    Name = "Auto Bond Farm (100k+/hora)",
    CurrentValue = false,
    Callback = function(Value)
        Settings.AutoBond = Value
        if Value then
            task.spawn(AutoBondFarm)
        end
    end
})

MainTab:CreateToggle({
    Name = "Bring All Items (Puxa tudo)",
    CurrentValue = false,
    Callback = function(Value)
        Settings.BringAllItems = Value
        if Value then
            task.spawn(BringItems)
        end
    end
})

MainTab:CreateButton({
    Name = "Collect All Bonds Instantly",
    Callback = function()
        local Items = Workspace:FindFirstChild("RuntimeItems")
        if Items then
            for _, v in pairs(Items:GetChildren()) do
                if v.Name == "Bond" then
                    pcall(function()
                        v.Part.CFrame = RootPart.CFrame
                        ReplicatedStorage.Packages.ActivateObjectClient:FireServer(v)
                    end)
                end
            end
        end
        Rayfield:Notify({
            Title = "Sucesso!",
            Content = "Todos os bonds coletados!",
            Duration = 2
        })
    end
})

-- Tab 2: Combat
CombatTab:CreateToggle({
    Name = "Kill Aura (Mata tudo ao redor)",
    CurrentValue = false,
    Callback = function(Value)
        Settings.KillAura = Value
        if Value then
            task.spawn(KillAura)
        end
    end
})

CombatTab:CreateSlider({
    Name = "Kill Aura Range",
    Range = {10, 100},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 50,
    Callback = function(Value)
        Settings.KillAuraRange = Value
    end
})

CombatTab:CreateToggle({
    Name = "Gun Mods (Rapid Fire + No Recoil)",
    CurrentValue = false,
    Callback = function(Value)
        Settings.GunMods = Value
        if Value then
            Settings.RapidFire = true
            Settings.NoRecoil = true
            Settings.InstantReload = true
            task.spawn(ApplyGunMods)
        end
    end
})

CombatTab:CreateToggle({
    Name = "Aimbot (Mira na Cabeça)",
    CurrentValue = false,
    Callback = function(Value)
        Settings.Aimbot = Value
    end
})

CombatTab:CreateDropdown({
    Name = "Aimbot Target",
    Options = {"Head", "HumanoidRootPart", "Torso"},
    CurrentOption = "Head",
    Callback = function(Option)
        Settings.AimbotPart = Option
    end
})

CombatTab:CreateToggle({
    Name = "Hitbox Expander (Hitbox Gigante)",
    CurrentValue = false,
    Callback = function(Value)
        Settings.HitboxExpander = Value
        if Value then
            task.spawn(ExpandHitbox)
        end
    end
})

CombatTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {10, 100},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 50,
    Callback = function(Value)
        Settings.HitboxSize = Value
    end
})

-- Tab 3: Visual
VisualTab:CreateToggle({
    Name = "ESP (Ver inimigos/itens)",
    CurrentValue = false,
    Callback = function(Value)
        Settings.ESP = Value
        if not Value then
            UpdateESP()
        end
    end
})

VisualTab:CreateToggle({
    Name = "Full Bright (Sem escuridão)",
    CurrentValue = false,
    Callback = function(Value)
        Settings.FullBright = Value
        if Value then
            Lighting.Brightness = 10
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = OldBrightness
            Lighting.GlobalShadows = true
        end
    end
})

VisualTab:CreateToggle({
    Name = "No Fog (Sem névoa)",
    CurrentValue = false,
    Callback = function(Value)
        Settings.NoFog = Value
        if Value then
            Lighting.FogEnd = 100000
        else
            Lighting.FogEnd = OldFog
        end
    end
})

-- Tab 4: Teleport
local Locations = {
    {"Início (0km)", Vector3.new(0, 50, 0)},
    {"Safe Zone 10km", Vector3.new(10000, 50, 0)},
    {"Safe Zone 20km", Vector3.new(20000, 50, 0)},
    {"Fort Constitution (35km)", Vector3.new(35000, 50, 0)},
    {"Castle (39km)", Vector3.new(39000, 50, 0)},
    {"Tesla Lab (45km)", Vector3.new(45000, 50, 0)},
    {"Sterling (60km)", Vector3.new(60000, 50, 0)},
    {"Final Bridge (78km)", Vector3.new(78000, 50, 0)}
}

for _, loc in pairs(Locations) do
    TeleportTab:CreateButton({
        Name = "TP: " .. loc[1],
        Callback = function()
            RootPart.CFrame = CFrame.new(loc[2])
            Rayfield:Notify({
                Title = "Teleportado!",
                Content = loc[1],
                Duration = 2
            })
        end
    })
end

-- Tab 5: Misc
MiscTab:CreateToggle({
    Name = "Super Speed",
    CurrentValue = false,
    Callback = function(Value)
        Settings.Speed = Value
        Humanoid.WalkSpeed = Value and Settings.SpeedValue or 16
    end
})

MiscTab:CreateSlider({
    Name = "Speed Value",
    Range = {16, 200},
    Increment = 5,
    Suffix = "walkspeed",
    CurrentValue = 120,
    Callback = function(Value)
        Settings.SpeedValue = Value
        if Settings.Speed then
            Humanoid.WalkSpeed = Value
        end
    end
})

MiscTab:CreateToggle({
    Name = "Auto Heal (Auto Bandage)",
    CurrentValue = false,
    Callback = function(Value)
        Settings.AutoHeal = Value
        if Value then
            task.spawn(AutoHeal)
        end
    end
})

MiscTab:CreateSlider({
    Name = "Auto Heal %",
    Range = {10, 90},
    Increment = 5,
    Suffix = "%",
    CurrentValue = 50,
    Callback = function(Value)
        Settings.AutoHealThreshold = Value
    end
})

MiscTab:CreateButton({
    Name = "Destroy GUI",
    Callback = function()
        Rayfield:Destroy()
    end
})

-- Auto atualização de Gun Mods
task.spawn(function()
    while task.wait(2) do
        if Settings.GunMods then
            ApplyGunMods()
        end
    end
end)

Rayfield:Notify({
    Title = "ULTRA HUB V5 CARREGADO!",
    Content = "by Anonymous | 100k+ Bonds/Hora",
    Duration = 5
})

print("ULTRA HUB V5 ATIVADO - DEAD RAILS DOMINATED")
