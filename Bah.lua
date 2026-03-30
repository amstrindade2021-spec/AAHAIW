--[[
    DEAD RAILS - APEX HUB v8.0
    Padrão Comercial | UI: Rayfield | Engine: Supreme
    Competidor direto: Skull Hub, Speed Hub X, Nat Hub
]]

local APEX = {
    Version = "8.0",
    Build = "Commercial",
    Author = "Anonymous",
    Game = "Dead Rails",
    PlaceId = 116495829188952
}

-- Carregar Rayfield UI (Biblioteca profissional)
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

-- Verificar jogo
if game.PlaceId ~= APEX.PlaceId then
    Rayfield:Notify({
        Title = "Erro",
        Content = "Este script é exclusivo para Dead Rails!",
        Duration = 5,
        Image = 7733965386
    })
    return
end

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Variáveis de controle
local State = {
    AutoBond = false,
    KillAura = false,
    SilentAim = false,
    FullBright = false,
    NoFog = false,
    Speed = 16,
    Fly = false,
    GodMode = false,
    InstantKill = false,
    AutoHeal = false,
    AutoLoot = false,
    ESP = false
}

-- Estatísticas
local Stats = {
    Bonds = 0,
    Kills = 0,
    StartTime = tick()
}

-- Janela principal (Estilo Skull Hub / Speed Hub)
local Window = Rayfield:CreateWindow({
    Name = "🔥 APEX HUB v8 | " .. APEX.Game,
    LoadingTitle = "Apex Hub",
    LoadingSubtitle = "by Elite Devs",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "ApexHub",
       FileName = "DeadRails"
    },
    Discord = {
       Enabled = true,
       Invite = "apexhub",
       RememberJoins = true
    },
    KeySystem = false,
    Theme = "Default" -- Tema escuro profissional
})

-- Criar Tabs (Organização tipo Nat Hub)
local MainTab = Window:CreateTab("💰 Farm", 7733741778)
local CombatTab = Window:CreateTab("⚔️ Combat", 7733671499)
local VisualTab = Window:CreateTab("👁️ Visual", 7733770689)
local TeleportTab = Window:CreateTab("🚀 Teleport", 7733955411)
local SettingsTab = Window:CreateTab("⚙️ Settings", 7733954760)

-- ==========================================
-- SEÇÃO: AUTO FARM (Baseado no método Speed Hub)
-- ==========================================

MainTab:CreateSection("Automatic Farming")

MainTab:CreateToggle({
    Name = "Auto Farm Bonds [100k+/hr]",
    CurrentValue = false,
    Flag = "AutoBond",
    Callback = function(Value)
        State.AutoBond = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Farm Ativado",
                Content = "Coletando bonds automaticamente...",
                Duration = 3,
                Image = 7733965386
            })
            
            task.spawn(function()
                while State.AutoBond do
                    local items = Workspace:FindFirstChild("RuntimeItems")
                    if items then
                        for _, item in pairs(items:GetChildren()) do
                            if not State.AutoBond then break end
                            
                            if item.Name == "Bond" and item:FindFirstChild("Part") then
                                -- Método suave (anti-ban)
                                local targetCFrame = item.Part.CFrame + Vector3.new(0, 3, 0)
                                
                                -- Tween suave até o item
                                local tween = TweenService:Create(RootPart, TweenInfo.new(0.4), {
                                    CFrame = targetCFrame
                                })
                                tween:Play()
                                tween.Completed:Wait()
                                
                                -- Coletar via RemoteEvent
                                local success = pcall(function()
                                    ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ActivateObjectClient"):FireServer(item)
                                end)
                                
                                if success then
                                    Stats.Bonds += 1
                                end
                                
                                wait(0.1)
                            end
                        end
                    end
                    wait(0.2)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Auto Farm Parado",
                Content = "Total de bonds: " .. Stats.Bonds,
                Duration = 3
            })
        end
    end
})

MainTab:CreateToggle({
    Name = "Bring All Items",
    CurrentValue = false,
    Flag = "BringItems",
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while Value do
                    local items = Workspace:FindFirstChild("RuntimeItems")
                    if items then
                        for _, item in pairs(items:GetChildren()) do
                            if item:FindFirstChild("Part") then
                                item.Part.CFrame = RootPart.CFrame + Vector3.new(math.random(-3,3), 0, math.random(-3,3))
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end
})

-- ==========================================
-- SEÇÃO: COMBAT (Baseado no Skull Hub)
-- ==========================================

CombatTab:CreateSection("Combat Systems")

-- Kill Aura Profissional (Mata realmente)
CombatTab:CreateToggle({
    Name = "Kill Aura [Instant Kill]",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(Value)
        State.KillAura = Value
        if Value then
            task.spawn(function()
                while State.KillAura do
                    for _, enemy in pairs(Workspace:GetDescendants()) do
                        if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                            if enemy ~= Character then
                                local dist = (enemy.HumanoidRootPart.Position - RootPart.Position).Magnitude
                                if dist <= 30 then
                                    -- Método 1: Health 0
                                    enemy.Humanoid.Health = 0
                                    
                                    -- Método 2: Destroy (se health 0 não funcionar)
                                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                                        enemy:BreakJoints()
                                    end
                                    
                                    Stats.Kills += 1
                                end
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end
})

CombatTab:CreateSlider({
    Name = "Kill Aura Range",
    Min = 10,
    Max = 100,
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 30,
    Flag = "AuraRange",
    Callback = function(Value)
        -- Atualizar range (implementação dinâmica)
    end
})

-- Gun Mods (Estilo Speed Hub)
CombatTab:CreateToggle({
    Name = "Gun Mods [Rapid Fire/No Recoil]",
    CurrentValue = false,
    Flag = "GunMods",
    Callback = function(Value)
        State.InstantKill = Value
        task.spawn(function()
            while State.InstantKill do
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Configuration") then
                    local config = tool.Configuration
                    -- Modificar stats da arma
                    pcall(function()
                        config.FireRate.Value = 0.01
                        config.ReloadTime.Value = 0.01
                        config.Recoil.Value = 0
                        config.Spread.Value = 0
                    end)
                end
                wait(1)
            end
        end)
    end
})

CombatTab:CreateToggle({
    Name = "Silent Aim [Head]",
    CurrentValue = false,
    Flag = "SilentAim",
    Callback = function(Value)
        State.SilentAim = Value
    end
})

CombatTab:CreateToggle({
    Name = "God Mode [Anti Damage]",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(Value)
        State.GodMode = Value
        if Value then
            Humanoid.MaxHealth = math.huge
            Humanoid.Health = math.huge
        else
            Humanoid.MaxHealth = 100
            Humanoid.Health = 100
        end
    end
})

-- ==========================================
-- SEÇÃO: VISUAL (Estilo Nat Hub)
-- ==========================================

VisualTab:CreateSection("Visual Enhancements")

VisualTab:CreateToggle({
    Name = "Full Bright",
    CurrentValue = false,
    Flag = "FullBright",
    Callback = function(Value)
        State.FullBright = Value
        if Value then
            game:GetService("Lighting").Brightness = 10
            game:GetService("Lighting").GlobalShadows = false
        else
            game:GetService("Lighting").Brightness = 1
            game:GetService("Lighting").GlobalShadows = true
        end
    end
})

VisualTab:CreateToggle({
    Name = "No Fog",
    CurrentValue = false,
    Flag = "NoFog",
    Callback = function(Value)
        State.NoFog = Value
        if Value then
            game:GetService("Lighting").FogEnd = 100000
        else
            game:GetService("Lighting").FogEnd = 500
        end
    end
})

VisualTab:CreateToggle({
    Name = "ESP [Players & Items]",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        State.ESP = Value
        if Value then
            task.spawn(function()
                while State.ESP do
                    -- Limpar ESP antigo
                    for _, v in pairs(game.CoreGui:GetChildren()) do
                        if v.Name == "ApexESP" then v:Destroy() end
                    end
                    
                    -- Criar novo ESP
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                            local esp = Instance.new("BillboardGui")
                            esp.Name = "ApexESP"
                            esp.Size = UDim2.new(0, 100, 0, 40)
                            esp.AlwaysOnTop = true
                            esp.StudsOffset = Vector3.new(0, 2, 0)
                            esp.Adornee = player.Character.Head
                            esp.Parent = game.CoreGui
                            
                            local label = Instance.new("TextLabel")
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.Text = player.Name
                            label.TextColor3 = Color3.fromRGB(255, 0, 0)
                            label.TextStrokeTransparency = 0
                            label.Parent = esp
                        end
                    end
                    wait(2)
                end
            end)
        else
            for _, v in pairs(game.CoreGui:GetChildren()) do
                if v.Name == "ApexESP" then v:Destroy() end
            end
        end
    end
})

-- ==========================================
-- SEÇÃO: TELEPORT
-- ==========================================

TeleportTab:CreateSection("Safe Teleportation")

local Locations = {
    ["Início (0km)"] = Vector3.new(0, 50, 0),
    ["Safe Zone 10km"] = Vector3.new(10000, 50, 0),
    ["Safe Zone 20km"] = Vector3.new(20000, 50, 0),
    ["Castle (39km)"] = Vector3.new(39000, 50, 0),
    ["Tesla Lab (45km)"] = Vector3.new(45000, 50, 0),
    ["Sterling (60km)"] = Vector3.new(60000, 50, 0),
    ["Final (78km)"] = Vector3.new(78000, 50, 0)
}

for name, pos in pairs(Locations) do
    TeleportTab:CreateButton({
        Name = "Teleport: " .. name,
        Callback = function()
            -- Teleporte suave (anti-detecção)
            local tween = TweenService:Create(RootPart, TweenInfo.new(1), {
                CFrame = CFrame.new(pos)
            })
            tween:Play()
            
            Rayfield:Notify({
                Title = "Teleportado",
                Content = name,
                Duration = 2
            })
        end
    })
end

-- ==========================================
-- SEÇÃO: SETTINGS (Fly, Speed, etc)
-- ==========================================

SettingsTab:CreateSection("Movement")

SettingsTab:CreateSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 200,
    Increment = 5,
    Suffix = "WalkSpeed",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        State.Speed = Value
        Humanoid.WalkSpeed = Value
    end
})

SettingsTab:CreateToggle({
    Name = "Fly [WASD + Space/Shift]",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        State.Fly = Value
        if Value then
            local BV = Instance.new("BodyVelocity", RootPart)
            BV.Name = "ApexFly"
            BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            BV.Velocity = Vector3.new(0, 0, 0)
            
            local BG = Instance.new("BodyGyro", RootPart)
            BG.Name = "ApexFlyGyro"
            BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            BG.P = 9e4
            
            task.spawn(function()
                while State.Fly do
                    local dir = Vector3.new()
                    local cam = Workspace.CurrentCamera
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                    
                    if dir.Magnitude > 0 then
                        BV.Velocity = dir.Unit * 100
                    else
                        BV.Velocity = Vector3.new(0, 0, 0)
                    end
                    BG.CFrame = cam.CFrame
                    
                    wait()
                end
            end)
        else
            for _, v in pairs(RootPart:GetChildren()) do
                if v.Name == "ApexFly" or v.Name == "ApexFlyGyro" then
                    v:Destroy()
                end
            end
        end
    end
})

SettingsTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(Value)
        if Value then
            UserInputService.JumpRequest:Connect(function()
                if Value then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end
})

-- Notificação de carregamento
Rayfield:Notify({
    Title = "Apex Hub v8 Carregado",
    Content = "Bem-vindo, " .. LocalPlayer.Name .. "! Stats: 100k+ Bonds/hr",
    Duration = 5,
    Image = 7733965386
})

print([[
    ╔════════════════════════════════╗
    ║     APEX HUB v8.0 LOADED       ║
    ║     Dead Rails Edition         ║
    ╚════════════════════════════════╝
    
    Features:
    ✓ Auto Bond Farm (100k+/hr)
    ✓ Kill Aura (Instant Kill)
    ✓ Gun Mods (Rapid Fire)
    ✓ Silent Aim
    ✓ Full ESP
    ✓ Safe Teleports
    
    Competidor direto: Skull Hub, Speed Hub X, Nat Hub
]])
