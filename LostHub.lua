local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local PlaceAliases = {
    [6839171747] = {Name = "Dead Rails", Script = "DeadRails"},
    [142823291] = {Name = "Murder Mystery 2", Script = "MM2"},
    [286090429] = {Name = "Arsenal", Script = "Arsenal"},
    [3101667897] = {Name = "Legends of Speed", Script = "LegendsOfSpeed"},
    [537413528] = {Name = "Build A Boat", Script = "BuildABoat"},
    [292439477] = {Name = "Phantom Forces", Script = "PhantomForces"},
    [3233893879] = {Name = "Bad Business", Script = "BadBusiness"},
    [3527629287] = {Name = "Big Paintball 2", Script = "BigPaintball2"},
    [4581966615] = {Name = "Anomic", Script = "Anomic"},
    [5094651510] = {Name = "Total Roblox Drama", Script = "TotalRobloxDrama"},
}

local Theme = {
    Background = Color3.fromRGB(10, 12, 18),
    Background2 = Color3.fromRGB(16, 18, 28),
    Background3 = Color3.fromRGB(22, 24, 36),
    Card = Color3.fromRGB(18, 21, 31),
    Card2 = Color3.fromRGB(23, 26, 38),
    Stroke = Color3.fromRGB(46, 51, 73),
    Accent = Color3.fromRGB(0, 255, 153),
    Accent2 = Color3.fromRGB(0, 210, 130),
    AccentSoft = Color3.fromRGB(0, 255, 153),
    Text = Color3.fromRGB(245, 247, 255),
    Text2 = Color3.fromRGB(182, 188, 204),
    Text3 = Color3.fromRGB(124, 132, 154),
    Error = Color3.fromRGB(255, 95, 95),
    Warning = Color3.fromRGB(255, 190, 60),
    Success = Color3.fromRGB(0, 255, 153),
    Shadow = Color3.fromRGB(0, 0, 0),
}

local Icons = {
    Logo = "rbxassetid://7733965380",
    Home = "rbxassetid://7733963888",
    Settings = "rbxassetid://7733975302",
    User = "rbxassetid://7733975935",
    Key = "rbxassetid://7733970524",
    Sparkles = "rbxassetid://7733976616",
    Check = "rbxassetid://7733973348",
    Error = "rbxassetid://7733975008",
    Game = "rbxassetid://7733968885",
}

local function create(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

local function corner(parent, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 12),
        Parent = parent
    })
end

local function stroke(parent, color, thickness, transparency)
    return create("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = parent
    })
end

local function gradient(parent, c1, c2, rotation)
    return create("UIGradient", {
        Color = ColorSequence.new(c1 or Theme.Accent, c2 or Theme.Accent2),
        Rotation = rotation or 90,
        Parent = parent
    })
end

local function padding(parent, l, r, t, b)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0),
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        Parent = parent
    })
end

local function list(parent, pad, sort)
    return create("UIListLayout", {
        Padding = UDim.new(0, pad or 0),
        SortOrder = sort or Enum.SortOrder.LayoutOrder,
        Parent = parent
    })
end

local function tween(obj, time, props, style, dir)
    local tw = TweenService:Create(
        obj,
        TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props
    )
    tw:Play()
    return tw
end

local function shadow(parent, size, transparency)
    local s = create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 8),
        Size = UDim2.new(1, size or 42, 1, size or 42),
        ZIndex = math.max(parent.ZIndex - 1, 0),
        Image = "rbxassetid://6015897843",
        ImageColor3 = Theme.Shadow,
        ImageTransparency = transparency or 0.45,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = parent
    })
    return s
end

local function safeDestroy(name)
    local old = CoreGui:FindFirstChild(name)
    if old then
        old:Destroy()
    end
end

safeDestroy("LostHubLoading")
safeDestroy("LostHubKey")
safeDestroy("LostHubMain")
safeDestroy("LostHubNotify")

local function detectGame()
    local direct = PlaceAliases[game.PlaceId]
    if direct then
        return direct
    end
    local root = PlaceAliases[game.GameId]
    if root then
        return root
    end
    for id, data in pairs(PlaceAliases) do
        if tonumber(id) == tonumber(game.PlaceId) or tonumber(id) == tonumber(game.GameId) then
            return data
        end
    end
    local placeName = "Universal"
    pcall(function()
        if game:GetService("MarketplaceService") then
            local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
            if info and info.Name and info.Name ~= "" then
                placeName = info.Name
            end
        end
    end)
    return {
        Name = placeName,
        Script = "Universal"
    }
end

local CurrentGame = detectGame()

local LoadingGui = create("ScreenGui", {
    Name = "LostHubLoading",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999997,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = CoreGui
})

local KeyGui = create("ScreenGui", {
    Name = "LostHubKey",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999998,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = CoreGui
})

local MainGui = create("ScreenGui", {
    Name = "LostHubMain",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = CoreGui
})

local NotifyGui = create("ScreenGui", {
    Name = "LostHubNotify",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 1000000,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = CoreGui
})

local function makeResponsive(sizeXDesktop, sizeYDesktop, sizeXMobile, sizeYMobile)
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    return isMobile and UDim2.new(0, sizeXMobile, 0, sizeYMobile) or UDim2.new(0, sizeXDesktop, 0, sizeYDesktop)
end

local function centerFrame(frame)
    frame.Position = UDim2.new(0.5, -frame.AbsoluteSize.X / 2, 0.5, -frame.AbsoluteSize.Y / 2)
end

local function clampToViewport(frame, x, y)
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
    local width = frame.AbsoluteSize.X
    local height = frame.AbsoluteSize.Y
    local minX = 8
    local minY = 8
    local maxX = math.max(minX, viewport.X - width - 8)
    local maxY = math.max(minY, viewport.Y - height - 8)
    return math.clamp(x, minX, maxX), math.clamp(y, minY, maxY)
end

local function snapBubbleToEdge(frame)
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
    local posX = frame.Position.X.Offset
    local posY = frame.Position.Y.Offset
    local width = frame.AbsoluteSize.X
    local leftDist = posX
    local rightDist = viewport.X - (posX + width)
    local targetX
    if leftDist < rightDist then
        targetX = 8
    else
        targetX = viewport.X - width - 8
    end
    local clampedY = math.clamp(posY, 8, viewport.Y - frame.AbsoluteSize.Y - 8)
    tween(frame, 0.32, {
        Position = UDim2.new(0, targetX, 0, clampedY)
    }, Enum.EasingStyle.Back)
end

local function makeDraggable(frame, dragHandle, onClick, onDragEnd)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local activeInput = nil
    local moved = false

    local function update(input)
        local delta = input.Position - dragStart
        local newX = startPos.X.Offset + delta.X
        local newY = startPos.Y.Offset + delta.Y
        local cx, cy = clampToViewport(frame, newX, newY)
        frame.Position = UDim2.new(startPos.X.Scale, cx, startPos.Y.Scale, cy)
        if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then
            moved = true
        end
    end

    local function begin(input)
        dragging = true
        moved = false
        dragStart = input.Position
        startPos = frame.Position
        activeInput = input
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            begin(input)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            activeInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == activeInput then
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if dragging and input == activeInput then
            dragging = false
            activeInput = nil
            if moved then
                if onDragEnd then
                    onDragEnd()
                end
            else
                if onClick then
                    onClick()
                end
            end
        end
    end)
end

local function getThumb()
    local img = ""
    pcall(function()
        img = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
    end)
    return img
end

local function notify(title, message, typ)
    local accent = Theme.Success
    local icon = Icons.Check

    if typ == "error" then
        accent = Theme.Error
        icon = Icons.Error
    elseif typ == "warning" then
        accent = Theme.Warning
        icon = Icons.Key
    end

    local card = create("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        Size = UDim2.new(0, 320, 0, 92),
        Position = UDim2.new(1, 40, 1, -24),
        BackgroundColor3 = Theme.Card,
        Parent = NotifyGui,
        ZIndex = 50
    })
    corner(card, 16)
    stroke(card, accent, 1.5)
    shadow(card, 50, 0.5)

    local bar = create("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = accent,
        Parent = card,
        ZIndex = 51
    })
    corner(bar, 12)

    local iconFrame = create("Frame", {
        Size = UDim2.new(0, 42, 0, 42),
        Position = UDim2.new(0, 18, 0.5, -21),
        BackgroundColor3 = Color3.fromRGB(
            math.floor(accent.R * 255 * 0.16),
            math.floor(accent.G * 255 * 0.16),
            math.floor(accent.B * 255 * 0.16)
        ),
        Parent = card,
        ZIndex = 51
    })
    corner(iconFrame, 14)

    local iconImg = create("ImageLabel", {
        Size = UDim2.new(0, 22, 0, 22),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1,
        Image = icon,
        ImageColor3 = accent,
        Parent = iconFrame,
        ZIndex = 52
    })

    local t1 = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 72, 0, 16),
        Size = UDim2.new(1, -88, 0, 20),
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
        ZIndex = 51
    })

    local t2 = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 72, 0, 38),
        Size = UDim2.new(1, -88, 0, 34),
        Text = message,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextWrapped = true,
        TextColor3 = Theme.Text2,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = card,
        ZIndex = 51
    })

    tween(card, 0.45, {Position = UDim2.new(1, -18, 1, -24)}, Enum.EasingStyle.Back)
    tween(iconFrame, 0.45, {Rotation = 10}, Enum.EasingStyle.Back)
    task.delay(0.15, function()
        tween(iconFrame, 0.25, {Rotation = 0})
    end)

    task.delay(4, function()
        tween(card, 0.35, {Position = UDim2.new(1, 40, 1, -24)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.36)
        if card then
            card:Destroy()
        end
    end)
end

local function showLoadingScreen()
    local bg = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Background,
        Parent = LoadingGui
    })

    local bgGrad = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = bg
    })
    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 50, 35)),
            ColorSequenceKeypoint.new(0.35, Theme.Background2),
            ColorSequenceKeypoint.new(1, Theme.Background)
        }),
        Rotation = 125,
        Parent = bgGrad
    })

    for i = 1, 12 do
        local dot = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, math.random(3, 7), 0, math.random(3, 7)),
            Position = UDim2.new(math.random(), 0, math.random(), 0),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0.82,
            Parent = bg
        })
        corner(dot, 999)
        task.spawn(function()
            while dot.Parent do
                local newPos = UDim2.new(math.random(), 0, math.random(), 0)
                tween(dot, math.random(3, 6), {
                    Position = newPos,
                    BackgroundTransparency = math.random(65, 90) / 100
                }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(math.random(2, 4))
            end
        end)
    end

    local center = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 460, 0, 260),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1,
        Parent = bg
    })

    local glow = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 140, 0, 140),
        Position = UDim2.new(0.5, 0, 0.5, -42),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.86,
        Parent = center
    })
    corner(glow, 999)

    local ring = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 116, 0, 116),
        Position = UDim2.new(0.5, 0, 0.5, -42),
        BackgroundTransparency = 1,
        Image = "rbxassetid://266543268",
        ImageColor3 = Theme.Accent,
        ImageTransparency = 0.3,
        Parent = center
    })

    local logo = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 62, 0, 62),
        Position = UDim2.new(0.5, 0, 0.5, -42),
        BackgroundTransparency = 1,
        Image = Icons.Logo,
        ImageColor3 = Theme.Accent,
        Parent = center
    })

    local title = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 42),
        Position = UDim2.new(0, 0, 0, 128),
        BackgroundTransparency = 1,
        Text = "LOST HUB",
        Font = Enum.Font.GothamBlack,
        TextSize = 36,
        TextColor3 = Theme.Text,
        Parent = center
    })
    gradient(title, Theme.Accent, Theme.Accent2, 0)

    local sub = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 170),
        BackgroundTransparency = 1,
        Text = (CurrentGame.Name or "Universal"):upper(),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Theme.Text2,
        Parent = center
    })

    local status = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 1, -26),
        BackgroundTransparency = 1,
        Text = "Inicializando interface...",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Theme.Text3,
        Parent = center
    })

    local barBack = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(0, 340, 0, 8),
        Position = UDim2.new(0.5, 0, 1, -54),
        BackgroundColor3 = Theme.Background3,
        Parent = center
    })
    corner(barBack, 999)

    local bar = create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        Parent = barBack
    })
    corner(bar, 999)
    gradient(bar, Theme.Accent, Theme.Accent2, 0)

    task.spawn(function()
        while ring.Parent do
            tween(ring, 6, {Rotation = 360}, Enum.EasingStyle.Linear)
            task.wait(6)
            ring.Rotation = 0
        end
    end)

    task.spawn(function()
        while glow.Parent do
            tween(glow, 1.4, {BackgroundTransparency = 0.78, Size = UDim2.new(0, 155, 0, 155)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.4)
            tween(glow, 1.4, {BackgroundTransparency = 0.88, Size = UDim2.new(0, 140, 0, 140)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.4)
        end
    end)

    local steps = {
        {"Sincronizando dados", 0.22},
        {"Detectando jogo", 0.42},
        {"Montando interface", 0.68},
        {"Aplicando animações", 0.86},
        {"Pronto", 1}
    }

    for _, step in ipairs(steps) do
        status.Text = step[1]
        tween(bar, 0.45, {Size = UDim2.new(step[2], 0, 1, 0)})
        task.wait(0.5)
    end

    tween(center, 0.35, {Position = UDim2.new(0.5, 0, 0.48, 0), BackgroundTransparency = 1}, Enum.EasingStyle.Quad)
    tween(bg, 0.45, {BackgroundTransparency = 1})
    for _, v in ipairs(center:GetDescendants()) do
        if v:IsA("TextLabel") then
            tween(v, 0.3, {TextTransparency = 1})
        elseif v:IsA("ImageLabel") then
            tween(v, 0.3, {ImageTransparency = 1})
        elseif v:IsA("Frame") then
            tween(v, 0.3, {BackgroundTransparency = 1})
        end
    end
    task.wait(0.5)
    LoadingGui:Destroy()
end

local function showKeySystem(onValidated)
    local bg = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.22,
        Parent = KeyGui
    })

    local blurLayer = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = bg
    })
    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 40, 28)),
            ColorSequenceKeypoint.new(0.5, Theme.Background),
            ColorSequenceKeypoint.new(1, Theme.Background2)
        }),
        Rotation = 135,
        Transparency = NumberSequence.new(0.25, 0.05),
        Parent = blurLayer
    })

    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local width = isMobile and 520 or 620
    local height = isMobile and 340 or 350

    local main = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, width, 0, height),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Theme.Card,
        Parent = bg
    })
    corner(main, 22)
    stroke(main, Theme.Stroke, 1.2)
    shadow(main, 56, 0.45)

    local left = create("Frame", {
        Size = UDim2.new(0, isMobile and 182 or 210, 1, 0),
        BackgroundColor3 = Theme.Card2,
        Parent = main
    })
    corner(left, 22)

    local leftFix = create("Frame", {
        Size = UDim2.new(0, 26, 1, 0),
        Position = UDim2.new(1, -26, 0, 0),
        BackgroundColor3 = Theme.Card2,
        BorderSizePixel = 0,
        Parent = left
    })

    local logoWrap = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(0, 74, 0, 74),
        Position = UDim2.new(0.5, 0, 0, 28),
        BackgroundColor3 = Color3.fromRGB(0, 255, 153),
        BackgroundTransparency = 0.82,
        Parent = left
    })
    corner(logoWrap, 999)

    local logo = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 42, 0, 42),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1,
        Image = Icons.Logo,
        ImageColor3 = Theme.Accent,
        Parent = logoWrap
    })

    local title = create("TextLabel", {
        Size = UDim2.new(1, -18, 0, 28),
        Position = UDim2.new(0, 9, 0, 118),
        BackgroundTransparency = 1,
        Text = "LOST HUB",
        Font = Enum.Font.GothamBlack,
        TextSize = 24,
        TextColor3 = Theme.Text,
        Parent = left
    })
    gradient(title, Theme.Accent, Theme.Accent2, 0)

    local subtitle = create("TextLabel", {
        Size = UDim2.new(1, -18, 0, 16),
        Position = UDim2.new(0, 9, 0, 146),
        BackgroundTransparency = 1,
        Text = "KEY SYSTEM",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Theme.Text2,
        Parent = left
    })

    local gameBadge = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(1, -28, 0, 72),
        Position = UDim2.new(0.5, 0, 0, 184),
        BackgroundColor3 = Theme.Background3,
        Parent = left
    })
    corner(gameBadge, 16)
    stroke(gameBadge, Theme.Stroke, 1)

    local gameIcon = create("ImageLabel", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 12, 0, 12),
        BackgroundTransparency = 1,
        Image = Icons.Game,
        ImageColor3 = Theme.Accent,
        Parent = gameBadge
    })

    local gameMini = create("TextLabel", {
        Size = UDim2.new(1, -50, 0, 12),
        Position = UDim2.new(0, 42, 0, 12),
        BackgroundTransparency = 1,
        Text = "JOGO",
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = Theme.Text3,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = gameBadge
    })

    local gameName = create("TextLabel", {
        Size = UDim2.new(1, -24, 0, 22),
        Position = UDim2.new(0, 12, 0, 30),
        BackgroundTransparency = 1,
        Text = string.upper(CurrentGame.Name or "UNIVERSAL"),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.Text,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = gameBadge
    })

    local right = create("Frame", {
        Size = UDim2.new(1, -(isMobile and 182 or 210), 1, 0),
        Position = UDim2.new(0, isMobile and 182 or 210, 0, 0),
        BackgroundTransparency = 1,
        Parent = main
    })

    padding(right, 24, 24, 24, 24)

    local rightTitle = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = "Insira sua key",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = right
    })

    local rightSub = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 28),
        BackgroundTransparency = 1,
        Text = "Painel horizontal, compacto e mais limpo.",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Theme.Text2,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = right
    })

    local inputWrap = create("Frame", {
        Size = UDim2.new(1, 0, 0, 56),
        Position = UDim2.new(0, 0, 0, 70),
        BackgroundColor3 = Theme.Background3,
        Parent = right
    })
    corner(inputWrap, 16)
    stroke(inputWrap, Theme.Stroke, 1)

    local inputIconWrap = create("Frame", {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0, 8, 0.5, -20),
        BackgroundColor3 = Color3.fromRGB(0, 255, 153),
        BackgroundTransparency = 0.84,
        Parent = inputWrap
    })
    corner(inputIconWrap, 14)

    local inputIcon = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 18, 0, 18),
        BackgroundTransparency = 1,
        Image = Icons.Key,
        ImageColor3 = Theme.Accent,
        Parent = inputIconWrap
    })

    local keyInput = create("TextBox", {
        Size = UDim2.new(1, -62, 1, 0),
        Position = UDim2.new(0, 54, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Cole sua key aqui",
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.Text3,
        ClearTextOnFocus = false,
        Parent = inputWrap
    })

    local statusWrap = create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        Position = UDim2.new(0, 0, 0, 138),
        BackgroundColor3 = Theme.Background3,
        Parent = right
    })
    corner(statusWrap, 14)
    stroke(statusWrap, Theme.Stroke, 1)

    local statusIcon = create("ImageLabel", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 14, 0.5, -10),
        BackgroundTransparency = 1,
        Image = Icons.Sparkles,
        ImageColor3 = Theme.Text3,
        Parent = statusWrap
    })

    local statusText = create("TextLabel", {
        Size = UDim2.new(1, -44, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        BackgroundTransparency = 1,
        Text = "Aguardando validação...",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Theme.Text2,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = statusWrap
    })

    local buttons = create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0, 198),
        BackgroundTransparency = 1,
        Parent = right
    })

    local validateBtn = create("TextButton", {
        Size = UDim2.new(0.46, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        Text = "VALIDAR",
        Font = Enum.Font.GothamBlack,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(0, 0, 0),
        AutoButtonColor = false,
        Parent = buttons
    })
    corner(validateBtn, 14)

    local getKeyBtn = create("TextButton", {
        Size = UDim2.new(0.26, 0, 1, 0),
        Position = UDim2.new(0.49, 0, 0, 0),
        BackgroundColor3 = Theme.Background3,
        Text = "OBTER KEY",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Theme.Text,
        AutoButtonColor = false,
        Parent = buttons
    })
    corner(getKeyBtn, 14)
    stroke(getKeyBtn, Theme.Stroke, 1)

    local discordBtn = create("TextButton", {
        Size = UDim2.new(0.22, 0, 1, 0),
        Position = UDim2.new(0.78, 0, 0, 0),
        BackgroundColor3 = Theme.Background3,
        Text = "DISCORD",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Theme.Text,
        AutoButtonColor = false,
        Parent = buttons
    })
    corner(discordBtn, 14)
    stroke(discordBtn, Theme.Stroke, 1)

    local footer = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 1, -18),
        BackgroundTransparency = 1,
        Text = "© Lost Hub UI",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Theme.Text3,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = right
    })

    local function pulseButton(btn, a, b)
        btn.MouseEnter:Connect(function()
            tween(btn, 0.18, {BackgroundColor3 = b})
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, 0.18, {BackgroundColor3 = a})
        end)
    end

    pulseButton(validateBtn, Theme.Accent, Theme.Accent2)
    pulseButton(getKeyBtn, Theme.Background3, Theme.Card2)
    pulseButton(discordBtn, Theme.Background3, Theme.Card2)

    local function setStatus(text, mode)
        statusText.Text = text
        if mode == "error" then
            statusIcon.Image = Icons.Error
            statusIcon.ImageColor3 = Theme.Error
            tween(statusWrap, 0.2, {BackgroundColor3 = Color3.fromRGB(40, 22, 26)})
        elseif mode == "success" then
            statusIcon.Image = Icons.Check
            statusIcon.ImageColor3 = Theme.Success
            tween(statusWrap, 0.2, {BackgroundColor3 = Color3.fromRGB(20, 38, 30)})
        elseif mode == "warning" then
            statusIcon.Image = Icons.Key
            statusIcon.ImageColor3 = Theme.Warning
            tween(statusWrap, 0.2, {BackgroundColor3 = Color3.fromRGB(42, 35, 22)})
        else
            statusIcon.Image = Icons.Sparkles
            statusIcon.ImageColor3 = Theme.Text3
            tween(statusWrap, 0.2, {BackgroundColor3 = Theme.Background3})
        end
    end

    local function validateKey()
        local key = keyInput.Text:gsub("%s+", "")
        if key == "" then
            setStatus("Digite uma key para continuar.", "error")
            tween(main, 0.08, {Position = UDim2.new(0.5, 6, 0.5, 0)}, Enum.EasingStyle.Sine)
            task.wait(0.08)
            tween(main, 0.08, {Position = UDim2.new(0.5, -6, 0.5, 0)}, Enum.EasingStyle.Sine)
            task.wait(0.08)
            tween(main, 0.08, {Position = UDim2.new(0.5, 0, 0.5, 0)}, Enum.EasingStyle.Sine)
            return
        end

        setStatus("Key validada localmente.", "success")
        task.wait(0.55)

        tween(main, 0.35, {
            Size = UDim2.new(0, math.floor(width * 0.82), 0, math.floor(height * 0.82)),
            BackgroundTransparency = 1
        }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        tween(bg, 0.3, {BackgroundTransparency = 1})

        for _, v in ipairs(main:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                tween(v, 0.2, {TextTransparency = 1})
            elseif v:IsA("ImageLabel") then
                tween(v, 0.2, {ImageTransparency = 1})
            elseif v:IsA("Frame") then
                tween(v, 0.2, {BackgroundTransparency = 1})
            elseif v:IsA("UIStroke") then
                tween(v, 0.2, {Transparency = 1})
            end
        end

        task.wait(0.36)
        KeyGui:Destroy()
        if onValidated then
            onValidated()
        end
    end

    validateBtn.MouseButton1Click:Connect(validateKey)
    keyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            validateKey()
        end
    end)

    getKeyBtn.MouseButton1Click:Connect(function()
        setStatus("Defina aqui sua ação de obtenção de key.", "warning")
    end)

    discordBtn.MouseButton1Click:Connect(function()
        setStatus("Defina aqui sua ação de Discord.", "warning")
    end)

    logoWrap.Size = UDim2.new(0, 40, 0, 40)
    logoWrap.BackgroundTransparency = 1
    main.Size = UDim2.new(0, math.floor(width * 0.86), 0, math.floor(height * 0.86))
    main.BackgroundTransparency = 1

    tween(main, 0.5, {Size = UDim2.new(0, width, 0, height), BackgroundTransparency = 0}, Enum.EasingStyle.Back)
    tween(logoWrap, 0.5, {Size = UDim2.new(0, 74, 0, 74), BackgroundTransparency = 0.82}, Enum.EasingStyle.Back)

    task.spawn(function()
        while logo.Parent do
            tween(logo, 6, {Rotation = 360}, Enum.EasingStyle.Linear)
            task.wait(6)
            logo.Rotation = 0
        end
    end)

    task.spawn(function()
        while logoWrap.Parent do
            tween(logoWrap, 1.2, {BackgroundTransparency = 0.72}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
            tween(logoWrap, 1.2, {BackgroundTransparency = 0.82}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
        end
    end)
end

local function createPageScroll(parent)
    local scroll = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        Visible = false,
        Parent = parent
    })
    padding(scroll, 0, 4, 0, 4)
    list(scroll, 10)
    return scroll
end

local function createMainHub()
    local hub = {
        Tabs = {},
        ActiveTab = nil,
        Minimized = false
    }

    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local width = isMobile and 540 or 820
    local height = isMobile and 380 or 500
    local sidebarWidth = isMobile and 94 or 198
    local topHeight = 68

    local root = create("Frame", {
        Name = "MainHub",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, width, 0, height),
        Position = UDim2.new(0.5, 0, 0.52, 0),
        BackgroundColor3 = Theme.Card,
        Parent = MainGui
    })
    corner(root, 24)
    stroke(root, Theme.Stroke, 1.2)
    shadow(root, 66, 0.42)

    local rootGlow = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, 18, 1, 18),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.94,
        ZIndex = 0,
        Parent = root
    })
    corner(rootGlow, 30)

    local top = create("Frame", {
        Size = UDim2.new(1, 0, 0, topHeight),
        BackgroundColor3 = Theme.Card2,
        Parent = root
    })
    corner(top, 24)

    local topFix = create("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        Position = UDim2.new(0, 0, 1, -26),
        BackgroundColor3 = Theme.Card2,
        BorderSizePixel = 0,
        Parent = top
    })

    local topGradient = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = top
    })
    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Card2),
            ColorSequenceKeypoint.new(1, Theme.Background3)
        }),
        Rotation = 0,
        Parent = topGradient
    })

    local brandWrap = create("Frame", {
        Size = UDim2.new(0, 44, 0, 44),
        Position = UDim2.new(0, 14, 0.5, -22),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.8,
        Parent = top
    })
    corner(brandWrap, 15)

    local brandRing = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 12, 1, 12),
        BackgroundTransparency = 1,
        Image = "rbxassetid://266543268",
        ImageColor3 = Theme.Accent,
        ImageTransparency = 0.55,
        Parent = brandWrap
    })

    local brandLogo = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 22, 0, 22),
        BackgroundTransparency = 1,
        Image = Icons.Logo,
        ImageColor3 = Theme.Accent,
        Parent = brandWrap
    })

    local brandTitle = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 68, 0, 12),
        Size = UDim2.new(0, 170, 0, 20),
        Text = "LOST HUB",
        Font = Enum.Font.GothamBlack,
        TextSize = 18,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = top
    })
    gradient(brandTitle, Theme.Accent, Theme.Accent2, 0)

    local brandSub = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 68, 0, 36),
        Size = UDim2.new(0, 240, 0, 14),
        Text = "• " .. string.upper(CurrentGame.Name or "UNIVERSAL"),
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Theme.Text2,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = top
    })

    local userCard = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Size = UDim2.new(0, isMobile and 140 or 210, 0, 44),
        Position = UDim2.new(1, -106, 0.5, 0),
        BackgroundColor3 = Theme.Background3,
        Parent = top
    })
    corner(userCard, 15)
    stroke(userCard, Theme.Stroke, 1)

    local userGlow = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, 8, 1, 8),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.95,
        Parent = userCard
    })
    corner(userGlow, 18)

    local avatar = create("ImageLabel", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 7, 0.5, -15),
        BackgroundTransparency = 1,
        Image = getThumb(),
        Parent = userCard
    })
    corner(avatar, 999)

    local avatarStroke = stroke(avatar, Theme.Stroke, 1)

    local username = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 43, 0, 8),
        Size = UDim2.new(1, -51, 0, 14),
        Text = LocalPlayer.DisplayName,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = userCard
    })

    local handle = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 43, 0, 22),
        Size = UDim2.new(1, -51, 0, 12),
        Text = "@" .. LocalPlayer.Name,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Theme.Text3,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = userCard
    })

    local minimizeBtn = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Size = UDim2.new(0, 38, 0, 38),
        Position = UDim2.new(1, -58, 0.5, 0),
        BackgroundColor3 = Theme.Background3,
        Text = "–",
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextColor3 = Theme.Text2,
        AutoButtonColor = false,
        Parent = top
    })
    corner(minimizeBtn, 13)
    stroke(minimizeBtn, Theme.Stroke, 1)

    local closeBtn = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Size = UDim2.new(0, 38, 0, 38),
        Position = UDim2.new(1, -14, 0.5, 0),
        BackgroundColor3 = Theme.Background3,
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextColor3 = Theme.Error,
        AutoButtonColor = false,
        Parent = top
    })
    corner(closeBtn, 13)
    stroke(closeBtn, Theme.Stroke, 1)

    local sidebar = create("Frame", {
        Size = UDim2.new(0, sidebarWidth, 1, -topHeight),
        Position = UDim2.new(0, 0, 0, topHeight),
        BackgroundColor3 = Theme.Card2,
        Parent = root
    })
    corner(sidebar, 24)

    local sidebarFix = create("Frame", {
        Size = UDim2.new(0, 24, 1, 0),
        Position = UDim2.new(1, -24, 0, 0),
        BackgroundColor3 = Theme.Card2,
        BorderSizePixel = 0,
        Parent = sidebar
    })

    local sidebarGradient = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = sidebar
    })
    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Card2),
            ColorSequenceKeypoint.new(1, Theme.Background3)
        }),
        Rotation = 90,
        Parent = sidebarGradient
    })

    local tabsWrap = create("ScrollingFrame", {
        Size = UDim2.new(1, -12, 1, -12),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        Parent = sidebar
    })
    padding(tabsWrap, 0, 0, 6, 6)
    list(tabsWrap, 8)

    local content = create("Frame", {
        Size = UDim2.new(1, -sidebarWidth, 1, -topHeight),
        Position = UDim2.new(0, sidebarWidth, 0, topHeight),
        BackgroundTransparency = 1,
        Parent = root
    })

    local contentBack = create("Frame", {
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundColor3 = Color3.fromRGB(14, 16, 24),
        BackgroundTransparency = 0.18,
        Parent = content
    })
    corner(contentBack, 20)
    stroke(contentBack, Theme.Stroke, 1, 0.35)

    local pages = create("Frame", {
        Size = UDim2.new(1, -18, 1, -18),
        Position = UDim2.new(0, 9, 0, 9),
        BackgroundTransparency = 1,
        Parent = content
    })

    local bubble = create("Frame", {
        Visible = false,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 76, 0, 76),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Card,
        Parent = MainGui
    })
    corner(bubble, 999)
    stroke(bubble, Theme.Stroke, 1.2)
    shadow(bubble, 56, 0.4)

    local bubbleGlow = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, 18, 1, 18),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.9,
        Parent = bubble
    })
    corner(bubbleGlow, 999)

    local bubbleRing1 = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://266543268",
        ImageColor3 = Theme.Accent,
        ImageTransparency = 0.62,
        Parent = bubble
    })

    local bubbleRing2 = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://266543268",
        ImageColor3 = Theme.Accent2,
        ImageTransparency = 0.72,
        Parent = bubble
    })

    local bubbleInner = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Theme.Background3,
        Parent = bubble
    })
    corner(bubbleInner, 999)
    stroke(bubbleInner, Theme.Stroke, 1, 0.25)

    local bubbleButton = create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = bubble
    })

    local bubbleIconBack = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 44, 0, 44),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.85,
        Parent = bubble
    })
    corner(bubbleIconBack, 999)

    local bubbleIcon = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1,
        Image = Icons.Logo,
        ImageColor3 = Theme.Accent,
        Parent = bubble
    })

    local bubbleDot = create("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(1, -16, 0, 10),
        BackgroundColor3 = Theme.Success,
        Parent = bubble
    })
    corner(bubbleDot, 999)
    stroke(bubbleDot, Color3.fromRGB(255, 255, 255), 1)

    local bubbleAvatar = create("ImageLabel", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 8, 1, -26),
        BackgroundTransparency = 1,
        Image = getThumb(),
        Parent = bubble
    })
    corner(bubbleAvatar, 999)

    local bubbleTip = create("Frame", {
        Visible = false,
        AnchorPoint = Vector2.new(1, 0.5),
        Size = UDim2.new(0, 154, 0, 44),
        Position = UDim2.new(0, -10, 0.5, 0),
        BackgroundColor3 = Theme.Card,
        Parent = bubble
    })
    corner(bubbleTip, 14)
    stroke(bubbleTip, Theme.Stroke, 1)
    shadow(bubbleTip, 42, 0.46)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 7),
        Size = UDim2.new(1, -24, 0, 14),
        Text = "Lost Hub",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = bubbleTip
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 21),
        Size = UDim2.new(1, -24, 0, 14),
        Text = "Toque para restaurar",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.Text2,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = bubbleTip
    })

    local bubbleHover = false

    bubble.MouseEnter:Connect(function()
        bubbleHover = true
        bubbleTip.Visible = true
        tween(bubbleTip, 0.16, {BackgroundTransparency = 0})
        tween(bubble, 0.18, {Size = UDim2.new(0, 82, 0, 82)}, Enum.EasingStyle.Back)
    end)

    bubble.MouseLeave:Connect(function()
        bubbleHover = false
        bubbleTip.Visible = false
        tween(bubble, 0.18, {Size = UDim2.new(0, 76, 0, 76)}, Enum.EasingStyle.Back)
    end)

    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, 0.18, {BackgroundColor3 = Color3.fromRGB(55, 22, 26)})
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, 0.18, {BackgroundColor3 = Theme.Background3})
    end)
    minimizeBtn.MouseEnter:Connect(function()
        tween(minimizeBtn, 0.18, {BackgroundColor3 = Theme.Card})
    end)
    minimizeBtn.MouseLeave:Connect(function()
        tween(minimizeBtn, 0.18, {BackgroundColor3 = Theme.Background3})
    end)

    local function playBubbleLoop()
        task.spawn(function()
            while bubble.Visible and bubble.Parent do
                tween(bubbleGlow, 1.25, {
                    BackgroundTransparency = 0.84,
                    Size = UDim2.new(1, 28, 1, 28)
                }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                tween(bubbleIconBack, 1.25, {
                    BackgroundTransparency = 0.78,
                    Size = UDim2.new(0, 48, 0, 48)
                }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(1.25)
                tween(bubbleGlow, 1.25, {
                    BackgroundTransparency = 0.92,
                    Size = UDim2.new(1, 18, 1, 18)
                }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                tween(bubbleIconBack, 1.25, {
                    BackgroundTransparency = 0.85,
                    Size = UDim2.new(0, 44, 0, 44)
                }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(1.25)
            end
        end)

        task.spawn(function()
            while bubble.Visible and bubble.Parent do
                tween(bubbleRing1, 5.5, {Rotation = 360}, Enum.EasingStyle.Linear)
                tween(bubbleRing2, 7.5, {Rotation = -360}, Enum.EasingStyle.Linear)
                tween(bubbleIcon, 4.8, {Rotation = 360}, Enum.EasingStyle.Linear)
                task.wait(7.5)
                bubbleRing1.Rotation = 0
                bubbleRing2.Rotation = 0
                bubbleIcon.Rotation = 0
            end
        end)

        task.spawn(function()
            while bubble.Visible and bubble.Parent do
                tween(bubbleDot, 0.75, {BackgroundTransparency = 0.15}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(0.75)
                tween(bubbleDot, 0.75, {BackgroundTransparency = 0}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(0.75)
            end
        end)
    end

    local function showBubble()
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
        bubble.Visible = true
        bubble.Size = UDim2.new(0, 42, 0, 42)
        bubble.BackgroundTransparency = 1
        bubble.Position = UDim2.new(0, viewport.X - 90, 0, viewport.Y - 120)
        tween(bubble, 0.36, {
            Size = UDim2.new(0, 76, 0, 76),
            BackgroundTransparency = 0
        }, Enum.EasingStyle.Back)
        snapBubbleToEdge(bubble)
        playBubbleLoop()
    end

    local function hideBubble()
        if not bubble.Visible then
            return
        end
        tween(bubble, 0.22, {
            Size = UDim2.new(0, 42, 0, 42),
            BackgroundTransparency = 1
        }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.23)
        bubble.Visible = false
    end

    local function minimize()
        if hub.Minimized then
            return
        end
        hub.Minimized = true
        tween(root, 0.3, {
            Size = UDim2.new(0, math.floor(width * 0.9), 0, 0),
            Position = UDim2.new(root.Position.X.Scale, root.Position.X.Offset, root.Position.Y.Scale, root.Position.Y.Offset + 20)
        }, Enum.EasingStyle.Back, Enum.EasingDirection.In)

        for _, v in ipairs(root:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                tween(v, 0.18, {TextTransparency = 1})
            elseif v:IsA("ImageLabel") then
                tween(v, 0.18, {ImageTransparency = 1})
            elseif v:IsA("Frame") and v ~= root and v ~= rootGlow then
                tween(v, 0.18, {BackgroundTransparency = 1})
            elseif v:IsA("UIStroke") then
                tween(v, 0.18, {Transparency = 1})
            end
        end

        task.wait(0.22)
        root.Visible = false
        showBubble()
    end

    local function restore()
        if not hub.Minimized then
            return
        end
        hideBubble()
        hub.Minimized = false
        root.Visible = true
        root.Size = UDim2.new(0, math.floor(width * 0.9), 0, 0)
        tween(root, 0.4, {
            Size = UDim2.new(0, width, 0, height),
            Position = UDim2.new(0.5, 0, 0.52, 0)
        }, Enum.EasingStyle.Back)

        for _, v in ipairs(root:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                tween(v, 0.22, {TextTransparency = 0})
            elseif v:IsA("ImageLabel") then
                tween(v, 0.22, {ImageTransparency = 0})
            elseif v:IsA("Frame") then
                if v == root then
                    tween(v, 0.22, {BackgroundTransparency = 0})
                elseif v == pages or v == content then
                elseif v == rootGlow then
                    tween(v, 0.22, {BackgroundTransparency = 0.94})
                else
                    tween(v, 0.22, {BackgroundTransparency = 0})
                end
            elseif v:IsA("UIStroke") then
                tween(v, 0.22, {Transparency = 0})
            end
        end
    end

    makeDraggable(root, top, nil, nil)
    makeDraggable(bubble, bubbleButton, function()
        restore()
    end, function()
        snapBubbleToEdge(bubble)
    end)

    bubbleButton.MouseEnter:Connect(function()
        tween(bubbleInner, 0.18, {BackgroundColor3 = Theme.Card})
    end)

    bubbleButton.MouseLeave:Connect(function()
        tween(bubbleInner, 0.18, {BackgroundColor3 = Theme.Background3})
    end)

    minimizeBtn.MouseButton1Click:Connect(minimize)

    closeBtn.MouseButton1Click:Connect(function()
        tween(root, 0.28, {Size = UDim2.new(0, 0, 0, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.28)
        MainGui:Destroy()
        NotifyGui:Destroy()
    end)

    root.Size = UDim2.new(0, math.floor(width * 0.86), 0, math.floor(height * 0.86))
    root.BackgroundTransparency = 1
    tween(root, 0.45, {Size = UDim2.new(0, width, 0, height), BackgroundTransparency = 0}, Enum.EasingStyle.Back)

    task.spawn(function()
        while brandLogo.Parent do
            tween(brandLogo, 7, {Rotation = 360}, Enum.EasingStyle.Linear)
            tween(brandRing, 6, {Rotation = -360}, Enum.EasingStyle.Linear)
            task.wait(7)
            brandLogo.Rotation = 0
            brandRing.Rotation = 0
        end
    end)

    task.spawn(function()
        while brandWrap.Parent do
            tween(brandWrap, 1.3, {BackgroundTransparency = 0.7}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            tween(userGlow, 1.3, {BackgroundTransparency = 0.91}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.3)
            tween(brandWrap, 1.3, {BackgroundTransparency = 0.8}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            tween(userGlow, 1.3, {BackgroundTransparency = 0.95}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.3)
        end
    end)

    task.spawn(function()
        while rootGlow.Parent do
            tween(rootGlow, 2.2, {
                BackgroundTransparency = 0.91,
                Size = UDim2.new(1, 28, 1, 28)
            }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(2.2)
            tween(rootGlow, 2.2, {
                BackgroundTransparency = 0.95,
                Size = UDim2.new(1, 18, 1, 18)
            }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(2.2)
        end
    end)

    hub.Root = root
    hub.Top = top
    hub.Sidebar = tabsWrap
    hub.Pages = pages

    return hub
end

local function createTab(hub, name, icon)
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

    local button = create("TextButton", {
        Size = UDim2.new(1, 0, 0, isMobile and 50 or 50),
        BackgroundColor3 = Theme.Background3,
        Text = isMobile and "" or ("   " .. name),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Theme.Text2,
        AutoButtonColor = false,
        Parent = hub.Sidebar
    })
    corner(button, 16)
    stroke(button, Theme.Stroke, 1)

    local btnGlow = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.96,
        Parent = button
    })
    corner(btnGlow, 16)

    local img = create("ImageLabel", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = isMobile and UDim2.new(0.5, -9, 0.5, -9) or UDim2.new(0, 14, 0.5, -9),
        BackgroundTransparency = 1,
        Image = icon or Icons.Home,
        ImageColor3 = Theme.Text3,
        Parent = button
    })

    local activeBar = create("Frame", {
        Visible = false,
        Size = UDim2.new(0, 3, 0.62, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Theme.Accent,
        Parent = button
    })
    corner(activeBar, 999)

    local page = createPageScroll(hub.Pages)

    local tab = {
        Button = button,
        Icon = img,
        Page = page,
        ActiveBar = activeBar,
        Glow = btnGlow,
        Name = name
    }

    local function activate()
        if hub.ActiveTab == tab then
            return
        end

        if hub.ActiveTab then
            hub.ActiveTab.Page.Visible = false
            hub.ActiveTab.ActiveBar.Visible = false
            tween(hub.ActiveTab.Button, 0.18, {BackgroundColor3 = Theme.Background3})
            tween(hub.ActiveTab.Icon, 0.18, {ImageColor3 = Theme.Text3})
            tween(hub.ActiveTab.Glow, 0.18, {BackgroundTransparency = 0.96})
            hub.ActiveTab.Button.TextColor3 = Theme.Text2
        end

        hub.ActiveTab = tab
        tab.Page.Visible = true
        tab.ActiveBar.Visible = true
        tween(tab.Button, 0.18, {BackgroundColor3 = Theme.Card})
        tween(tab.Icon, 0.18, {ImageColor3 = Theme.Accent})
        tween(tab.Glow, 0.18, {BackgroundTransparency = 0.92})
        tab.Button.TextColor3 = Theme.Text
    end

    button.MouseEnter:Connect(function()
        if hub.ActiveTab ~= tab then
            tween(button, 0.16, {BackgroundColor3 = Theme.Card})
            tween(img, 0.16, {ImageColor3 = Theme.Text2})
            tween(btnGlow, 0.16, {BackgroundTransparency = 0.94})
        end
    end)

    button.MouseLeave:Connect(function()
        if hub.ActiveTab ~= tab then
            tween(button, 0.16, {BackgroundColor3 = Theme.Background3})
            tween(img, 0.16, {ImageColor3 = Theme.Text3})
            tween(btnGlow, 0.16, {BackgroundTransparency = 0.96})
        end
    end)

    button.MouseButton1Click:Connect(function()
        activate()
    end)

    table.insert(hub.Tabs, tab)

    if not hub.ActiveTab then
        activate()
    end

    return page
end

local function createSection(parent, titleText, descText)
    local section = create("Frame", {
        Size = UDim2.new(1, -4, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Card2,
        Parent = parent
    })
    corner(section, 20)
    stroke(section, Theme.Stroke, 1)

    local glow = create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.78,
        Parent = section
    })

    local topFade = create("Frame", {
        Size = UDim2.new(1, 0, 0, 54),
        BackgroundTransparency = 1,
        Parent = section
    })
    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 40, 28)),
            ColorSequenceKeypoint.new(1, Theme.Card2)
        }),
        Rotation = 90,
        Transparency = NumberSequence.new(0.72, 1),
        Parent = topFade
    })

    padding(section, 16, 16, 16, 16)
    list(section, 12)

    local title = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = titleText,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section
    })

    if descText and descText ~= "" then
        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Text = descText,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Theme.Text2,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = section
        })
    end

    return section
end

local function createInfoCard(parent, titleText, valueText, icon)
    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 68),
        BackgroundColor3 = Theme.Background3,
        Parent = parent
    })
    corner(frame, 17)
    stroke(frame, Theme.Stroke, 1)

    local bgLine = create("Frame", {
        Size = UDim2.new(0, 3, 1, -14),
        Position = UDim2.new(0, 10, 0, 7),
        BackgroundColor3 = Theme.Accent,
        Parent = frame
    })
    corner(bgLine, 999)

    local iconWrap = create("Frame", {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0, 18, 0.5, -20),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.84,
        Parent = frame
    })
    corner(iconWrap, 13)

    create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 18, 0, 18),
        BackgroundTransparency = 1,
        Image = icon or Icons.Sparkles,
        ImageColor3 = Theme.Accent,
        Parent = iconWrap
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 68, 0, 13),
        Size = UDim2.new(1, -80, 0, 14),
        Text = titleText,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Theme.Text3,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 68, 0, 30),
        Size = UDim2.new(1, -80, 0, 20),
        Text = valueText,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })

    return frame
end

local function createButton(parent, text, callback)
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Theme.Accent,
        Text = text,
        Font = Enum.Font.GothamBlack,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(0, 0, 0),
        AutoButtonColor = false,
        Parent = parent
    })
    corner(btn, 14)

    btn.MouseEnter:Connect(function()
        tween(btn, 0.16, {BackgroundColor3 = Theme.Accent2})
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.16, {BackgroundColor3 = Theme.Accent})
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)

    return btn
end

local function createLabel(parent, text)
    local label = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Theme.Text2,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = parent
    })
    return label
end

local function createToggle(parent, text, default, callback)
    local enabled = default == true

    local frame = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 54),
        BackgroundColor3 = Theme.Background3,
        Text = "",
        AutoButtonColor = false,
        Parent = parent
    })
    corner(frame, 16)
    stroke(frame, Theme.Stroke, 1)

    local label = create("TextLabel", {
        Size = UDim2.new(1, -88, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })

    local switch = create("Frame", {
        Size = UDim2.new(0, 50, 0, 28),
        Position = UDim2.new(1, -64, 0.5, -14),
        BackgroundColor3 = Theme.Card,
        Parent = frame
    })
    corner(switch, 999)
    stroke(switch, Theme.Stroke, 1)

    local knob = create("Frame", {
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, 3, 0.5, -11),
        BackgroundColor3 = Theme.Text3,
        Parent = switch
    })
    corner(knob, 999)

    local function render()
        if enabled then
            tween(switch, 0.18, {BackgroundColor3 = Theme.Accent})
            tween(knob, 0.18, {Position = UDim2.new(0, 25, 0.5, -11), BackgroundColor3 = Color3.fromRGB(255,255,255)})
        else
            tween(switch, 0.18, {BackgroundColor3 = Theme.Card})
            tween(knob, 0.18, {Position = UDim2.new(0, 3, 0.5, -11), BackgroundColor3 = Theme.Text3})
        end
        if callback then
            callback(enabled)
        end
    end

    frame.MouseButton1Click:Connect(function()
        enabled = not enabled
        render()
    end)

    render()

    return frame
end

local function createSlider(parent, text, min, max, default, callback)
    local dragging = false
    local current = math.clamp(default or min, min, max)

    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 76),
        BackgroundColor3 = Theme.Background3,
        Parent = parent
    })
    corner(frame, 16)
    stroke(frame, Theme.Stroke, 1)

    local label = create("TextLabel", {
        Size = UDim2.new(0.6, 0, 0, 16),
        Position = UDim2.new(0, 14, 0, 12),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })

    local value = create("TextLabel", {
        Size = UDim2.new(0.4, -14, 0, 16),
        Position = UDim2.new(0.6, 0, 0, 12),
        BackgroundTransparency = 1,
        Text = tostring(current),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = frame
    })

    local barBg = create("Frame", {
        Size = UDim2.new(1, -28, 0, 8),
        Position = UDim2.new(0, 14, 0, 44),
        BackgroundColor3 = Theme.Card,
        Parent = frame
    })
    corner(barBg, 999)

    local fill = create("Frame", {
        Size = UDim2.new((current - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        Parent = barBg
    })
    corner(fill, 999)
    gradient(fill, Theme.Accent, Theme.Accent2, 0)

    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = fill
    })
    corner(knob, 999)

    local range = math.max(max - min, 1)

    local function setRatio(ratio, fireCallback)
        ratio = math.clamp(ratio, 0, 1)
        current = math.floor(min + (range * ratio) + 0.5)
        fill.Size = UDim2.new((current - min) / range, 0, 1, 0)
        value.Text = tostring(current)
        if fireCallback and callback then
            callback(current)
        end
    end

    local function updateFromInput(input)
        local ratio = (input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X
        setRatio(ratio, true)
    end

    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
        end
    end)

    barBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    setRatio((current - min) / range, false)

    return frame
end

local function createDivider(parent)
    local d = create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Stroke,
        BorderSizePixel = 0,
        Parent = parent
    })
    return d
end

local function createUserBanner(parent)
    local card = create("Frame", {
        Size = UDim2.new(1, 0, 0, 86),
        BackgroundColor3 = Theme.Background3,
        Parent = parent
    })
    corner(card, 18)
    stroke(card, Theme.Stroke, 1)

    local avatarWrap = create("Frame", {
        Size = UDim2.new(0, 56, 0, 56),
        Position = UDim2.new(0, 14, 0.5, -28),
        BackgroundColor3 = Theme.Card,
        Parent = card
    })
    corner(avatarWrap, 16)
    stroke(avatarWrap, Theme.Stroke, 1)

    local avatar = create("ImageLabel", {
        Size = UDim2.new(1, -6, 1, -6),
        Position = UDim2.new(0, 3, 0, 3),
        BackgroundTransparency = 1,
        Image = getThumb(),
        Parent = avatarWrap
    })
    corner(avatar, 14)

    local name = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 82, 0, 18),
        Size = UDim2.new(1, -96, 0, 18),
        Text = LocalPlayer.DisplayName,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card
    })

    local handleText = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 82, 0, 40),
        Size = UDim2.new(1, -96, 0, 14),
        Text = "@" .. LocalPlayer.Name .. " • " .. string.upper(CurrentGame.Name or "UNIVERSAL"),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.Text2,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card
    })

    return card
end

local function createStatRow(parent, leftText, rightText)
    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = parent
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, 0, 1, 0),
        Text = leftText,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Theme.Text2,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Text = rightText,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row
    })

    return row
end

local function createChipRow(parent, items)
    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local layout = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = row
    })

    for _, txt in ipairs(items) do
        local bounds = TextService:GetTextSize(txt, 12, Enum.Font.GothamBold, Vector2.new(9999, 9999))
        local chip = create("Frame", {
            Size = UDim2.new(0, bounds.X + 24, 0, 30),
            BackgroundColor3 = Theme.Background3,
            Parent = row
        })
        corner(chip, 999)
        stroke(chip, Theme.Stroke, 1)

        create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = txt,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextColor3 = Theme.Text2,
            Parent = chip
        })
    end

    return row
end

local function populateOverview(page, titleText)
    local hero = createSection(page, titleText, "Interface responsiva, compacta e otimizada para desktop e mobile.")
    createUserBanner(hero)
    createDivider(hero)
    createInfoCard(hero, "Usuário", LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")", Icons.User)
    createInfoCard(hero, "Jogo detectado", CurrentGame.Name or "Universal", Icons.Game)
    createInfoCard(hero, "Modo", UserInputService.TouchEnabled and "Mobile / Touch" or "Desktop", Icons.Settings)

    local quick = createSection(page, "Atalhos", "Ações visuais de demonstração da interface.")
    createButton(quick, "Mostrar notificação de sucesso", function()
        notify("Tudo certo", "A interface foi carregada com sucesso.", "success")
    end)
    createButton(quick, "Mostrar notificação de aviso", function()
        notify("Aviso", "Este é um aviso de exemplo da UI.", "warning")
    end)
    createButton(quick, "Mostrar notificação de erro", function()
        notify("Erro", "Este é um erro de exemplo da UI.", "error")
    end)

    local meta = createSection(page, "Informações", "Resumo do ambiente atual.")
    createStatRow(meta, "Display Name", LocalPlayer.DisplayName)
    createStatRow(meta, "Username", "@" .. LocalPlayer.Name)
    createStatRow(meta, "PlaceId", tostring(game.PlaceId))
    createStatRow(meta, "GameId", tostring(game.GameId))
end

local function populateSettings(page)
    local section = createSection(page, "Ajustes", "Elementos interativos prontos para integração.")
    createToggle(section, "Animações suaves", true, function(state)
        notify("Configuração", state and "Animações ativadas." or "Animações desativadas.", state and "success" or "warning")
    end)
    createToggle(section, "Somente modo compacto", false, function(state)
        notify("Configuração", state and "Modo compacto ativado." or "Modo compacto desativado.", "success")
    end)
    createSlider(section, "Escala da interface", 70, 130, 100, function(value)
    end)
    createSlider(section, "Transparência de fundo", 0, 50, 12, function(value)
    end)

    local chips = createSection(page, "Características", "Resumo visual da nova base.")
    createChipRow(chips, {
        "fullscreen loading",
        "drag mobile",
        "bubble minimize",
        "user card",
        "responsive tabs"
    })
end

local function populateAbout(page)
    local section = createSection(page, "Sobre", "Painel visual com estrutura pronta para expansão.")
    createLabel(section, "Essa base mantém o foco em interface, navegação e experiência visual.")
    createLabel(section, "A detecção de jogo usa PlaceId, GameId e fallback por nome do place.")
    createLabel(section, "A bolha flutuante pode ser arrastada no mobile e no desktop.")
    createLabel(section, "As páginas utilizam scroll automático e componentes reutilizáveis.")
end

local function loadGameUI()
    local hub = createMainHub()

    local home = createTab(hub, "Início", Icons.Home)
    local settings = createTab(hub, "Ajustes", Icons.Settings)
    local about = createTab(hub, "Usuário", Icons.User)

    populateOverview(home, "Painel principal")
    populateSettings(settings)
    populateAbout(about)

    notify("Bem-vindo", "UI carregada para " .. (CurrentGame.Name or "Universal") .. ".", "success")
end

showLoadingScreen()
task.wait(0.2)
showKeySystem(function()
    loadGameUI()
end)
