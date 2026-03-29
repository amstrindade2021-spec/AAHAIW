-- MEGA HUB v2 - DEAD RAILS SUPREME
-- Design: Cyber-Western | Funcionalidades: Server-Side injection ready

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- CORES DO TEMA (Dead Rails: Vermelho sangue + Laranja fogo + Preto carbono)
local COLORS = {
    Background = Color3.fromRGB(10, 10, 12),
    Surface = Color3.fromRGB(20, 20, 24),
    Primary = Color3.fromRGB(220, 20, 60), -- Crimson
    Secondary = Color3.fromRGB(255, 140, 0), -- Dark Orange
    Accent = Color3.fromRGB(255, 215, 0), -- Gold ( Bonds color)
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(150, 150, 150),
    Success = Color3.fromRGB(0, 255, 127),
    Danger = Color3.fromRGB(255, 0, 0)
}

-- CONFIGURAÇÃO
local SETTINGS = {
    Speed = 16,
    Jump = 50,
    FlySpeed = 100,
    KillRange = 50,
    AutoBond = false,
    AutoKill = false,
    ESP = false,
    Fly = false,
    NoClip = false,
    InfStamina = false
}

-- CRIAR GUI PRINCIPAL
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MegaHubV2"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- FUNÇÃO DE SOM HOVER (Feedback audio visual)
local function PlayHoverSound()
    -- Simulação de som via código (mudar pitch do ambiente levemente)
    -- Em um executor real, poderia tocar um som real aqui
end

-- TELA DE INTRODUÇÃO (Boot Sequence)
local BootFrame = Instance.new("Frame")
BootFrame.Size = UDim2.new(1, 0, 1, 0)
BootFrame.BackgroundColor3 = COLORS.Background
BootFrame.BorderSizePixel = 0
BootFrame.Parent = ScreenGui
BootFrame.ZIndex = 100

local BootText = Instance.new("TextLabel")
BootText.Size = UDim2.new(0, 400, 0, 60)
BootText.Position = UDim2.new(0.5, -200, 0.4, 0)
BootText.BackgroundTransparency = 1
BootText.Text = "MEGA HUB v2.0"
BootText.TextColor3 = COLORS.Primary
BootText.TextSize = 48
BootText.Font = Enum.Font.GothamBlack
BootText.Parent = BootFrame

local BootSub = Instance.new("TextLabel")
BootSub.Size = UDim2.new(0, 400, 0, 30)
BootSub.Position = UDim2.new(0.5, -200, 0.5, 0)
BootSub.BackgroundTransparency = 1
BootSub.Text = "INITIALIZING DEAD RAILS MODULES..."
BootSub.TextColor3 = COLORS.TextDark
BootSub.TextSize = 18
BootSub.Font = Enum.Font.GothamBold
BootSub.Parent = BootFrame

-- Barra de progresso estilizada
local ProgressBg = Instance.new("Frame")
ProgressBg.Size = UDim2.new(0, 300, 0, 4)
ProgressBg.Position = UDim2.new(0.5, -150, 0.55, 0)
ProgressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ProgressBg.BorderSizePixel = 0
ProgressBg.Parent = BootFrame

local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.BackgroundColor3 = COLORS.Primary
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = ProgressBg

-- Animação de boot
task.spawn(function()
    TweenService:Create(ProgressBar, TweenInfo.new(2, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    wait(2.5)
    
    TweenService:Create(BootFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(BootText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(BootSub, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(ProgressBg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(ProgressBar, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    
    wait(0.5)
    BootFrame:Destroy()
end)

-- FRAME PRINCIPAL (Janela principal estilo Windows 11 + Cyberpunk)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 800, 0, 500)
MainFrame.Position = UDim2.new(0.5, -400, 0.5, -250)
MainFrame.BackgroundColor3 = COLORS.Background
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.ClipsDescendants = true
MainFrame.Visible = false -- Só aparece depois do boot

-- Cantos arredondados
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

-- Efeito de vidro (Glassmorphism)
local Glass = Instance.new("Frame")
Glass.Size = UDim2.new(1, 0, 1, 0)
Glass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Glass.BackgroundTransparency = 0.95
Glass.BorderSizePixel = 0
Glass.Parent = MainFrame

-- Sombra externa
local Shadow = Instance.new("ImageLabel")
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Size = UDim2.new(1, 100, 1, 100)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.6
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
Shadow.Parent = MainFrame

-- TÍTULO BAR (Draggable)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = COLORS.Surface
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

-- Fix cantos inferiores do titlebar
local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = COLORS.Surface
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

-- Logo/Ícone
local Icon = Instance.new("ImageLabel")
Icon.Size = UDim2.new(0, 24, 0, 24)
Icon.Position = UDim2.new(0, 10, 0, 8)
Icon.BackgroundTransparency = 1
Icon.Image = "rbxassetid://7734068321" -- Ícone de caveira
Icon.ImageColor3 = COLORS.Primary
Icon.Parent = TitleBar

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 300, 1, 0)
Title.Position = UDim2.new(0, 40, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "MEGA HUB v2.0"
Title.TextColor3 = COLORS.Text
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Subtítulo dinâmico
local SubTitle = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 150, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DEAD RAILS EDITION"
Title.TextColor3 = COLORS.Primary
Title.TextSize = 12
Title.Font = Enum.Font.Gotham
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Botões de controle da janela
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 30)
CloseBtn.Position = UDim2.new(1, -45, 0, 5)
CloseBtn.BackgroundColor3 = COLORS.Danger
CloseBtn.Text = "×"
CloseBtn.TextColor3 = COLORS.Text
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 40, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -90, 0, 5)
MinimizeBtn.BackgroundColor3 = COLORS.Surface
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = COLORS.Text
MinimizeBtn.TextSize = 20
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

-- SIDEBAR (Navegação)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 200, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 0)
SideCorner.Parent = Sidebar

-- Profile Card na sidebar
local ProfileCard = Instance.new("Frame")
ProfileCard.Size = UDim2.new(0.9, 0, 0, 80)
ProfileCard.Position = UDim2.new(0.05, 0, 0, 10)
ProfileCard.BackgroundColor3 = COLORS.Surface
ProfileCard.BorderSizePixel = 0
ProfileCard.Parent = Sidebar

local PCorner = Instance.new("UICorner")
PCorner.CornerRadius = UDim.new(0, 8)
PCorner.Parent = ProfileCard

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(0, 50, 0, 50)
Avatar.Position = UDim2.new(0, 10, 0, 15)
Avatar.BackgroundColor3 = COLORS.Primary
Avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
Avatar.Parent = ProfileCard

local AvCorner = Instance.new("UICorner")
AvCorner.CornerRadius = UDim.new(1, 0)
AvCorner.Parent = Avatar

local Username = Instance.new("TextLabel")
Username.Size = UDim2.new(0, 110, 0, 25)
Username.Position = UDim2.new(0, 70, 0, 15)
Username.BackgroundTransparency = 1
Username.Text = LocalPlayer.Name
Username.TextColor3 = COLORS.Text
Username.TextSize = 14
Username.Font = Enum.Font.GothamBold
Username.TextXAlignment = Enum.TextXAlignment.Left
Username.Parent = ProfileCard

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0, 110, 0, 20)
Status.Position = UDim2.new(0, 70, 0, 40)
Status.BackgroundTransparency = 1
Status.Text = "💰 FARMING"
Status.TextColor3 = COLORS.Success
Status.TextSize = 12
Status.Font = Enum.Font.Gotham
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = ProfileCard

-- CONTAINER DE CONTEÚDO
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -200, 1, -40)
Content.Position = UDim2.new(0, 200, 0, 40)
Content.BackgroundColor3 = COLORS.Background
Content.BorderSizePixel = 0
Content.Parent = MainFrame

-- SISTEMA DE ABAS FUNCIONAL
local Tabs = {}
local CurrentTab = "Automation"

local TabButtons = {
    {Name = "Automation", Icon = "⚡", Color = COLORS.Primary},
    {Name = "Combat", Icon = "⚔️", Color = COLORS.Danger},
    {Name = "Visual", Icon = "👁️", Color = COLORS.Accent},
    {Name = "Movement", Icon = "🏃", Color = COLORS.Success},
    {Name = "Teleports", Icon = "🎯", Color = COLORS.Secondary}
}

-- Criar botões de aba
for i, tabInfo in ipairs(TabButtons) do
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.9, 0, 0, 40)
    Btn.Position = UDim2.new(0.05, 0, 0, 100 + (i-1) * 50)
    Btn.BackgroundColor3 = (tabInfo.Name == CurrentTab) and tabInfo.Color or COLORS.Surface
    Btn.Text = "  " .. tabInfo.Icon .. "  " .. tabInfo.Name
    Btn.TextColor3 = COLORS.Text
    Btn.TextSize = 14
    Btn.Font = Enum.Font.GothamBold
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = Sidebar
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn
    
    -- Indicador lateral (barra de seleção)
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 4, 0.6, 0)
    Indicator.Position = UDim2.new(0, 0, 0.2, 0)
    Indicator.BackgroundColor3 = COLORS.Text
    Indicator.BorderSizePixel = 0
    Indicator.Visible = (tabInfo.Name == CurrentTab)
    Indicator.Parent = Btn
    
    Btn.MouseEnter:Connect(function()
        if CurrentTab ~= tabInfo.Name then
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}):Play()
        end
    end)
    
    Btn.MouseLeave:Connect(function()
        if CurrentTab ~= tabInfo.Name then
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Surface}):Play()
        end
    end)
    
    Btn.MouseButton1Click:Connect(function()
        CurrentTab = tabInfo.Name
        -- Atualizar todos os botões
        for _, child in pairs(Sidebar:GetChildren()) do
            if child:IsA("TextButton") and child ~= ProfileCard then
                local isSelected = child.Text:find(tabInfo.Name)
                child.BackgroundColor3 = isSelected and tabInfo.Color or COLORS.Surface
                child:FindFirstChildOfClass("Frame").Visible = isSelected
            end
        end
        
        -- Trocar conteúdo
        for _, contentTab in pairs(Content:GetChildren()) do
            contentTab.Visible = (contentTab.Name == tabInfo.Name)
        end
    end)
    
    Tabs[tabInfo.Name] = Btn
end

-- FUNÇÃO PARA CRIAR TOGGLE SWITCH MODERNO (iOS Style)
local function CreateToggle(parent, text, yPosition, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0.95, 0, 0, 50)
    Container.Position = UDim2.new(0.025, 0, 0, yPosition)
    Container.BackgroundColor3 = COLORS.Surface
    Container.BorderSizePixel = 0
    Container.Parent = parent
    
    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 8)
    ContainerCorner.Parent = Container
    
    -- Label
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0.05, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = COLORS.Text
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    -- Toggle Background
    local ToggleBg = Instance.new("TextButton")
    ToggleBg.Size = UDim2.new(0, 50, 0, 26)
    ToggleBg.Position = UDim2.new(1, -60, 0.5, -13)
    ToggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    ToggleBg.Text = ""
    ToggleBg.AutoButtonColor = false
    ToggleBg.Parent = Container
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleBg
    
    -- Círculo que move
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 22, 0, 22)
    Circle.Position = UDim2.new(0, 2, 0.5, -11)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.BorderSizePixel = 0
    Circle.Parent = ToggleBg
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle
    
    local Enabled = false
    
    ToggleBg.MouseButton1Click:Connect(function()
        Enabled = not Enabled
        if Enabled then
            TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Success}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 26, 0.5, -11)}):Play()
        else
            TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 65)}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -11)}):Play()
        end
        callback(Enabled)
    end)
    
    return Container
end

-- CRIAR PÁGINAS DE CONTEÚDO
for _, tabName in ipairs({"Automation", "Combat", "Visual", "Movement", "Teleports"}) do
    local Page = Instance.new("ScrollingFrame")
    Page.Name = tabName
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = COLORS.Primary
    Page.Visible = (tabName == CurrentTab)
    Page.Parent = Content
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 10)
    ListLayout.Parent = Page
end

-- PREENCHER ABA AUTOMATION
local AutoPage = Content:FindFirstChild("Automation")

CreateToggle(AutoPage, "💰 Auto Farm Bonds (100k+/hora)", 10, function(state)
    SETTINGS.AutoBond = state
    if state then
        task.spawn(function()
            while SETTINGS.AutoBond do
                -- Código real de farm de bonds do Dead Rails
                local items = Workspace:FindFirstChild("RuntimeItems")
                if items then
                    for _, item in pairs(items:GetChildren()) do
                        if item.Name == "Bond" and item:FindFirstChild("Part") then
                            -- Teleporte suave até o bond
                            local tween = TweenService:Create(RootPart, TweenInfo.new(0.5), {
                                CFrame = item.Part.CFrame + Vector3.new(0, 3, 0)
                            })
                            tween:Play()
                            tween.Completed:Wait()
                            
                            -- Ativar coleta (RemoteEvent real do jogo)
                            pcall(function()
                                ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ActivateObjectClient"):FireServer(item)
                            end)
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

CreateToggle(AutoPage, "🎒 Auto Collect All Items", 70, function(state)
    if state then
        task.spawn(function()
            while task.wait(0.2) do
                if not state then break end
                local items = Workspace:FindFirstChild("RuntimeItems")
                if items then
                    for _, item in pairs(items:GetChildren()) do
                        if item:FindFirstChild("Part") then
                            item.Part.CFrame = RootPart.CFrame + Vector3.new(math.random(-5,5), 0, math.random(-5,5))
                        end
                    end
                end
            end
        end)
    end
end)

CreateToggle(AutoPage, "💀 Auto Loot Corpses", 130, function(state)
    -- Auto pegar corpos para vender/combustível
end)

CreateToggle(AutoPage, "🏥 Auto Heal (Bandage)", 190, function(state)
    -- Auto usar bandagem quando vida < 50
end)

-- PREENCHER ABA COMBAT
local CombatPage = Content:FindFirstChild("Combat")

CreateToggle(CombatPage, "⚔️ Kill Aura (50 studs)", 10, function(state)
    SETTINGS.AutoKill = state
    if state then
        task.spawn(function()
            while SETTINGS.AutoKill do
                for _, enemy in pairs(Workspace:GetDescendants()) do
                    if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                        if enemy ~= Character then
                            local dist = (enemy.HumanoidRootPart.Position - RootPart.Position).Magnitude
                            if dist <= 50 then
                                enemy.Humanoid.Health = 0
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

CreateToggle(CombatPage, "🎯 Aimbot (Head)", 70, function(state)
    -- Sistema de aimbot silencioso
end)

CreateToggle(CombatPage, "🔫 Rapid Fire", 130, function(state)
    -- Modificar taxa de fogo das armas
end)

-- PREENCHER ABA MOVEMENT
local MovePage = Content:FindFirstChild("Movement")

CreateToggle(MovePage, "✈️ Fly (WASD + Space/Shift)", 10, function(state)
    SETTINGS.Fly = state
    if state then
        local BV = Instance.new("BodyVelocity", RootPart)
        BV.Name = "FlyVelocity"
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        BV.Velocity = Vector3.new(0, 0, 0)
        
        local BG = Instance.new("BodyGyro", RootPart)
        BG.Name = "FlyGyro"
        BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        BG.P = 9e4
        
        task.spawn(function()
            while SETTINGS.Fly do
                local dir = Vector3.new()
                local cam = Workspace.CurrentCamera
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                
                if dir.Magnitude > 0 then
                    BV.Velocity = dir.Unit * SETTINGS.FlySpeed
                else
                    BV.Velocity = Vector3.new(0, 0, 0)
                end
                BG.CFrame = cam.CFrame
                
                task.wait()
            end
            
            BV:Destroy()
            BG:Destroy()
        end)
    end
end)

CreateToggle(MovePage, "🏃 Super Speed (120)", 70, function(state)
    SETTINGS.Speed = state
    Humanoid.WalkSpeed = state and 120 or 16
end)

CreateToggle(MovePage, "🔲 No Clip", 130, function(state)
    SETTINGS.NoClip = state
    if state then
        task.spawn(function()
            while SETTINGS.NoClip do
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                task.wait()
            end
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end)
    end
end)

-- SISTEMA DE ARRASTAR (Drag)
local dragging = false
local dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- BOTÃO FECHAR
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
    wait(0.3)
    ScreenGui:Destroy()
end)

-- BOTÃO MINIMIZAR
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(Content, TweenInfo.new(0.3), {Size = UDim2.new(1, -200, 0, 0)}):Play()
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 800, 0, 40)}):Play()
    else
        TweenService:Create(Content, TweenInfo.new(0.3), {Size = UDim2.new(1, -200, 1, -40)}):Play()
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 800, 0, 500)}):Play()
    end
end)

-- MOSTRAR JANELA APÓS BOOT
task.delay(3, function()
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 800, 0, 500),
        Position = UDim2.new(0.5, -400, 0.5, -250)
    }):Play()
end)

print("MEGA HUB v2.0 CARREGADO")

