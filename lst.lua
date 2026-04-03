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
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function corner(parent, radius)
    return create("UICorner", {CornerRadius = UDim.new(0, radius or 12), Parent = parent})
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
    return create("ImageLabel", {
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
end

local function safeDestroy(name)
    local old = CoreGui:FindFirstChild(name)
    if old then old:Destroy() end
end

safeDestroy("LostHubLoading")
safeDestroy("LostHubKey")
safeDestroy("LostHubMain")
safeDestroy("LostHubNotify")

local function detectGame()
    local direct = PlaceAliases[game.PlaceId]
    if direct then return direct end
    local root = PlaceAliases[game.GameId]
    if root then return root end
    for id, data in pairs(PlaceAliases) do
        if tonumber(id) == tonumber(game.PlaceId) or tonumber(id) == tonumber(game.GameId) then
            return data
        end
    end
    local placeName = "Universal"
    pcall(function()
        if game:GetService("MarketplaceService") then
            local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
            if info and info.Name and info.Name ~= "" then placeName = info.Name end
        end
    end)
    return {Name = placeName, Script = "Universal"}
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

local function clampToViewport(frame, x, y)
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
    local w = frame.AbsoluteSize.X
    local h = frame.AbsoluteSize.Y
    local minX, minY = 8, 8
    local maxX = math.max(minX, viewport.X - w - 8)
    local maxY = math.max(minY, viewport.Y - h - 8)
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
    local targetX = leftDist < rightDist and 8 or (viewport.X - width - 8)
    local clampedY = math.clamp(posY, 8, viewport.Y - frame.AbsoluteSize.Y - 8)
    tween(frame, 0.32, {Position = UDim2.new(0, targetX, 0, clampedY)}, Enum.EasingStyle.Back)
end

local function makeDraggable(frame, dragHandle, onClick, onDragEnd)
    local dragging = false
    local dragStart, startPos, activeInput = nil, nil, nil
    local moved = false

    local function update(input)
        local delta = input.Position - dragStart
        local newX = startPos.X.Offset + delta.X
        local newY = startPos.Y.Offset + delta.Y
        local cx, cy = clampToViewport(frame, newX, newY)
        frame.Position = UDim2.new(startPos.X.Scale, cx, startPos.Y.Scale, cy)
        if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then moved = true end
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
        if dragging and input == activeInput then update(input) end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if dragging and input == activeInput then
            dragging = false
            activeInput = nil
            if moved then
                if onDragEnd then onDragEnd() end
            else
                if onClick then onClick() end
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
    if typ == "error" then accent = Theme.Error; icon = Icons.Error
    elseif typ == "warning" then accent = Theme.Warning; icon = Icons.Key end

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

    create("Frame", {Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = accent, Parent = card, ZIndex = 51})

    local iconFrame = create("Frame", {
        Size = UDim2.new(0, 42, 0, 42),
        Position = UDim2.new(0, 18, 0.5, -21),
        BackgroundColor3 = Color3.fromRGB(math.floor(accent.R*255*0.16), math.floor(accent.G*255*0.16), math.floor(accent.B*255*0.16)),
        Parent = card, ZIndex = 51
    })
    corner(iconFrame, 14)
    create("ImageLabel", {Size=UDim2.new(0,22,0,22), AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0), BackgroundTransparency=1, Image=icon, ImageColor3=accent, Parent=iconFrame, ZIndex=52})

    create("TextLabel", {BackgroundTransparency=1, Position=UDim2.new(0,72,0,16), Size=UDim2.new(1,-88,0,20), Text=title, Font=Enum.Font.GothamBold, TextSize=14, TextColor3=Theme.Text, TextXAlignment=Enum.TextXAlignment.Left, Parent=card, ZIndex=51})
    create("TextLabel", {BackgroundTransparency=1, Position=UDim2.new(0,72,0,38), Size=UDim2.new(1,-88,0,34), Text=message, Font=Enum.Font.Gotham, TextSize=12, TextWrapped=true, TextColor3=Theme.Text2, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, Parent=card, ZIndex=51})

    tween(card, 0.45, {Position = UDim2.new(1, -18, 1, -24)}, Enum.EasingStyle.Back)
    tween(iconFrame, 0.45, {Rotation = 10}, Enum.EasingStyle.Back)
    task.delay(0.15, function() tween(iconFrame, 0.25, {Rotation = 0}) end)
    task.delay(4, function()
        tween(card, 0.35, {Position = UDim2.new(1, 40, 1, -24)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.36)
        if card then card:Destroy() end
    end)
end

local function showLoadingScreen()
    local bg = create("Frame", {Size=UDim2.new(1,0,1,0), BackgroundColor3=Theme.Background, Parent=LoadingGui})

    local bgGrad = create("Frame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Parent=bg})
    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 15, 5)),
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(20, 10, 5)),
            ColorSequenceKeypoint.new(0.7, Theme.Background2),
            ColorSequenceKeypoint.new(1, Theme.Background)
        }),
        Rotation = 125, Parent = bgGrad
    })

    for i = 1, 18 do
        local isRail = i <= 4
        local dot = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = isRail and UDim2.new(0, math.random(40,80), 0, 3) or UDim2.new(0, math.random(2,5), 0, math.random(2,5)),
            Position = UDim2.new(math.random(), 0, math.random(), 0),
            BackgroundColor3 = isRail and Color3.fromRGB(120, 80, 40) or Theme.Accent,
            BackgroundTransparency = isRail and 0.7 or 0.82,
            Parent = bg
        })
        corner(dot, isRail and 0 or 999)
        task.spawn(function()
            while dot.Parent do
                tween(dot, math.random(4,8), {
                    Position = UDim2.new(math.random(), 0, math.random(), 0),
                    BackgroundTransparency = math.random(60, 88) / 100
                }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(math.random(3, 6))
            end
        end)
    end

    local center = create("Frame", {
        AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(0,480,0,280),
        Position=UDim2.new(0.5,0,0.5,0), BackgroundTransparency=1, Parent=bg
    })

    local glow = create("Frame", {
        AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(0,145,0,145),
        Position=UDim2.new(0.5,0,0.5,-50),
        BackgroundColor3=Color3.fromRGB(255, 140, 40),
        BackgroundTransparency=0.88, Parent=center
    })
    corner(glow, 999)

    local ring = create("ImageLabel", {
        AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(0,120,0,120),
        Position=UDim2.new(0.5,0,0.5,-50), BackgroundTransparency=1,
        Image="rbxassetid://266543268",
        ImageColor3=Color3.fromRGB(255,140,40), ImageTransparency=0.35, Parent=center
    })

    local logo = create("ImageLabel", {
        AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(0,64,0,64),
        Position=UDim2.new(0.5,0,0.5,-50), BackgroundTransparency=1,
        Image=Icons.Logo, ImageColor3=Color3.fromRGB(255,160,60), Parent=center
    })

    local titleLbl = create("TextLabel", {
        Size=UDim2.new(1,0,0,44), Position=UDim2.new(0,0,0,135),
        BackgroundTransparency=1, Text="DEAD RAILS", Font=Enum.Font.GothamBlack,
        TextSize=38, TextColor3=Theme.Text, Parent=center
    })
    create("UIGradient", {
        Color=ColorSequence.new(Color3.fromRGB(255,160,60), Color3.fromRGB(255,100,30)),
        Rotation=0, Parent=titleLbl
    })

    local sub = create("TextLabel", {
        Size=UDim2.new(1,0,0,18), Position=UDim2.new(0,0,0,180),
        BackgroundTransparency=1, Text="LOST HUB  ·  AUTO FARM",
        Font=Enum.Font.GothamBold, TextSize=12, TextColor3=Theme.Text2, Parent=center
    })

    local status = create("TextLabel", {
        Size=UDim2.new(1,0,0,16), Position=UDim2.new(0,0,1,-28),
        BackgroundTransparency=1, Text="Carregando Dead Rails...",
        Font=Enum.Font.Gotham, TextSize=12, TextColor3=Theme.Text3, Parent=center
    })

    local barBack = create("Frame", {
        AnchorPoint=Vector2.new(0.5,0), Size=UDim2.new(0,360,0,8),
        Position=UDim2.new(0.5,0,1,-58), BackgroundColor3=Theme.Background3, Parent=center
    })
    corner(barBack, 999)

    local bar = create("Frame", {Size=UDim2.new(0,0,1,0), BackgroundColor3=Color3.fromRGB(255,140,40), Parent=barBack})
    corner(bar, 999)
    create("UIGradient", {Color=ColorSequence.new(Color3.fromRGB(255,160,60), Color3.fromRGB(255,80,20)), Rotation=0, Parent=bar})

    task.spawn(function()
        while ring.Parent do
            tween(ring, 6, {Rotation=360}, Enum.EasingStyle.Linear)
            task.wait(6)
            ring.Rotation = 0
        end
    end)

    task.spawn(function()
        while glow.Parent do
            tween(glow, 1.4, {BackgroundTransparency=0.80, Size=UDim2.new(0,160,0,160)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.4)
            tween(glow, 1.4, {BackgroundTransparency=0.90, Size=UDim2.new(0,145,0,145)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.4)
        end
    end)

    local steps = {
        {"Carregando Dead Rails...", 0.18},
        {"Sincronizando trilhos...", 0.38},
        {"Montando interface...", 0.62},
        {"Aplicando animações...", 0.84},
        {"Pronto para partir!", 1}
    }

    for _, step in ipairs(steps) do
        status.Text = step[1]
        tween(bar, 0.45, {Size=UDim2.new(step[2],0,1,0)})
        task.wait(0.5)
    end

    tween(center, 0.35, {Position=UDim2.new(0.5,0,0.48,0), BackgroundTransparency=1}, Enum.EasingStyle.Quad)
    tween(bg, 0.45, {BackgroundTransparency=1})
    for _, v in ipairs(center:GetDescendants()) do
        if v:IsA("TextLabel") then tween(v, 0.3, {TextTransparency=1})
        elseif v:IsA("ImageLabel") then tween(v, 0.3, {ImageTransparency=1})
        elseif v:IsA("Frame") then tween(v, 0.3, {BackgroundTransparency=1}) end
    end
    task.wait(0.5)
    LoadingGui:Destroy()
end

local function showKeySystem(onValidated)
    local bg = create("Frame", {
        Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.fromRGB(0,0,0),
        BackgroundTransparency=0.22, Parent=KeyGui
    })

    local blurLayer = create("Frame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Parent=bg})
    create("UIGradient", {
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 18, 5)),
            ColorSequenceKeypoint.new(0.5, Theme.Background),
            ColorSequenceKeypoint.new(1, Theme.Background2)
        }),
        Rotation=135,
        Transparency=NumberSequence.new(0.25, 0.05),
        Parent=blurLayer
    })

    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local width = isMobile and 520 or 620
    local height = isMobile and 340 or 350

    local main = create("Frame", {
        AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(0,width,0,height),
        Position=UDim2.new(0.5,0,0.5,0), BackgroundColor3=Theme.Card, Parent=bg
    })
    corner(main, 22)
    stroke(main, Theme.Stroke, 1.2)
    shadow(main, 56, 0.45)

    local left = create("Frame", {
        Size=UDim2.new(0, isMobile and 182 or 210, 1, 0),
        BackgroundColor3=Theme.Card2, Parent=main
    })
    corner(left, 22)

    create("Frame", {
        Size=UDim2.new(0,26,1,0), Position=UDim2.new(1,-26,0,0),
        BackgroundColor3=Theme.Card2, BorderSizePixel=0, Parent=left
    })

    local logoWrap = create("Frame", {
        AnchorPoint=Vector2.new(0.5,0), Size=UDim2.new(0,74,0,74),
        Position=UDim2.new(0.5,0,0,28),
        BackgroundColor3=Color3.fromRGB(255,140,40), BackgroundTransparency=0.82, Parent=left
    })
    corner(logoWrap, 999)

    local logo = create("ImageLabel", {
        AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(0,42,0,42),
        Position=UDim2.new(0.5,0,0.5,0), BackgroundTransparency=1,
        Image=Icons.Logo, ImageColor3=Color3.fromRGB(255,160,60), Parent=logoWrap
    })

    local titleLbl = create("TextLabel", {
        Size=UDim2.new(1,-18,0,28), Position=UDim2.new(0,9,0,118),
        BackgroundTransparency=1, Text="LOST HUB", Font=Enum.Font.GothamBlack,
        TextSize=24, TextColor3=Theme.Text, Parent=left
    })
    create("UIGradient", {Color=ColorSequence.new(Color3.fromRGB(255,160,60), Color3.fromRGB(255,100,30)), Rotation=0, Parent=titleLbl})

    create("TextLabel", {
        Size=UDim2.new(1,-18,0,16), Position=UDim2.new(0,9,0,146),
        BackgroundTransparency=1, Text="KEY SYSTEM", Font=Enum.Font.GothamBold,
        TextSize=11, TextColor3=Theme.Text2, Parent=left
    })

    local gameBadge = create("Frame", {
        AnchorPoint=Vector2.new(0.5,0), Size=UDim2.new(1,-28,0,72),
        Position=UDim2.new(0.5,0,0,184), BackgroundColor3=Theme.Background3, Parent=left
    })
    corner(gameBadge, 16)
    stroke(gameBadge, Theme.Stroke, 1)

    create("ImageLabel", {
        Size=UDim2.new(0,24,0,24), Position=UDim2.new(0,12,0,12),
        BackgroundTransparency=1, Image=Icons.Game,
        ImageColor3=Color3.fromRGB(255,140,40), Parent=gameBadge
    })

    create("TextLabel", {
        Size=UDim2.new(1,-50,0,12), Position=UDim2.new(0,42,0,12),
        BackgroundTransparency=1, Text="JOGO", Font=Enum.Font.GothamBold,
        TextSize=10, TextColor3=Theme.Text3, TextXAlignment=Enum.TextXAlignment.Left, Parent=gameBadge
    })

    create("TextLabel", {
        Size=UDim2.new(1,-24,0,22), Position=UDim2.new(0,12,0,30),
        BackgroundTransparency=1, Text=string.upper(CurrentGame.Name or "UNIVERSAL"),
        Font=Enum.Font.GothamBold, TextSize=14, TextColor3=Theme.Text,
        TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left, Parent=gameBadge
    })

    local right = create("Frame", {
        Size=UDim2.new(1,-(isMobile and 182 or 210),1,0),
        Position=UDim2.new(0, isMobile and 182 or 210, 0, 0),
        BackgroundTransparency=1, Parent=main
    })
    padding(right, 24, 24, 24, 24)

    create("TextLabel", {
        Size=UDim2.new(1,0,0,24), BackgroundTransparency=1, Text="Insira sua key",
        Font=Enum.Font.GothamBold, TextSize=18, TextColor3=Theme.Text,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=right
    })

    create("TextLabel", {
        Size=UDim2.new(1,0,0,18), Position=UDim2.new(0,0,0,28),
        BackgroundTransparency=1, Text="Dead Rails • Auto Farm Premium",
        Font=Enum.Font.Gotham, TextSize=12, TextColor3=Theme.Text2,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=right
    })

    local inputWrap = create("Frame", {
        Size=UDim2.new(1,0,0,56), Position=UDim2.new(0,0,0,70),
        BackgroundColor3=Theme.Background3, Parent=right
    })
    corner(inputWrap, 16)
    stroke(inputWrap, Theme.Stroke, 1)

    local inputIconWrap = create("Frame", {
        Size=UDim2.new(0,40,0,40), Position=UDim2.new(0,8,0.5,-20),
        BackgroundColor3=Color3.fromRGB(255,140,40), BackgroundTransparency=0.84, Parent=inputWrap
    })
    corner(inputIconWrap, 14)

    create("ImageLabel", {
        AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0,18,0,18), BackgroundTransparency=1,
        Image=Icons.Key, ImageColor3=Color3.fromRGB(255,160,60), Parent=inputIconWrap
    })

    local keyInput = create("TextBox", {
        Size=UDim2.new(1,-62,1,0), Position=UDim2.new(0,54,0,0),
        BackgroundTransparency=1, Text="", PlaceholderText="Cole sua key aqui",
        Font=Enum.Font.GothamBold, TextSize=17, TextXAlignment=Enum.TextXAlignment.Left,
        TextColor3=Theme.Text, PlaceholderColor3=Theme.Text3, ClearTextOnFocus=false, Parent=inputWrap
    })

    local statusWrap = create("Frame", {
        Size=UDim2.new(1,0,0,48), Position=UDim2.new(0,0,0,138),
        BackgroundColor3=Theme.Background3, Parent=right
    })
    corner(statusWrap, 14)
    stroke(statusWrap, Theme.Stroke, 1)

    local statusIcon = create("ImageLabel", {
        Size=UDim2.new(0,20,0,20), Position=UDim2.new(0,14,0.5,-10),
        BackgroundTransparency=1, Image=Icons.Sparkles, ImageColor3=Theme.Text3, Parent=statusWrap
    })

    local statusText = create("TextLabel", {
        Size=UDim2.new(1,-44,1,0), Position=UDim2.new(0,40,0,0),
        BackgroundTransparency=1, Text="Aguardando validação...",
        Font=Enum.Font.Gotham, TextSize=12, TextColor3=Theme.Text2,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=statusWrap
    })

    local buttons = create("Frame", {
        Size=UDim2.new(1,0,0,50), Position=UDim2.new(0,0,0,198),
        BackgroundTransparency=1, Parent=right
    })

    local validateBtn = create("TextButton", {
        Size=UDim2.new(0.46,0,1,0), BackgroundColor3=Color3.fromRGB(255,140,40),
        Text="VALIDAR", Font=Enum.Font.GothamBlack, TextSize=13,
        TextColor3=Color3.fromRGB(0,0,0), AutoButtonColor=false, Parent=buttons
    })
    corner(validateBtn, 14)

    local getKeyBtn = create("TextButton", {
        Size=UDim2.new(0.26,0,1,0), Position=UDim2.new(0.49,0,0,0),
        BackgroundColor3=Theme.Background3, Text="OBTER KEY",
        Font=Enum.Font.GothamBold, TextSize=12, TextColor3=Theme.Text,
        AutoButtonColor=false, Parent=buttons
    })
    corner(getKeyBtn, 14)
    stroke(getKeyBtn, Theme.Stroke, 1)

    local discordBtn = create("TextButton", {
        Size=UDim2.new(0.22,0,1,0), Position=UDim2.new(0.78,0,0,0),
        BackgroundColor3=Theme.Background3, Text="DISCORD",
        Font=Enum.Font.GothamBold, TextSize=12, TextColor3=Theme.Text,
        AutoButtonColor=false, Parent=buttons
    })
    corner(discordBtn, 14)
    stroke(discordBtn, Theme.Stroke, 1)

    create("TextLabel", {
        Size=UDim2.new(1,0,0,16), Position=UDim2.new(0,0,1,-18),
        BackgroundTransparency=1, Text="© Lost Hub UI • Dead Rails Edition",
        Font=Enum.Font.Gotham, TextSize=10, TextColor3=Theme.Text3,
        TextXAlignment=Enum.TextXAlignment.Right, Parent=right
    })

    local function pulseButton(btn, a, b)
        btn.MouseEnter:Connect(function() tween(btn, 0.18, {BackgroundColor3=b}) end)
        btn.MouseLeave:Connect(function() tween(btn, 0.18, {BackgroundColor3=a}) end)
    end

    pulseButton(validateBtn, Color3.fromRGB(255,140,40), Color3.fromRGB(255,170,80))
    pulseButton(getKeyBtn, Theme.Background3, Theme.Card2)
    pulseButton(discordBtn, Theme.Background3, Theme.Card2)

    local function setStatus(text, mode)
        statusText.Text = text
        if mode == "error" then
            statusIcon.Image = Icons.Error; statusIcon.ImageColor3 = Theme.Error
            tween(statusWrap, 0.2, {BackgroundColor3=Color3.fromRGB(40,22,26)})
        elseif mode == "success" then
            statusIcon.Image = Icons.Check; statusIcon.ImageColor3 = Theme.Success
            tween(statusWrap, 0.2, {BackgroundColor3=Color3.fromRGB(20,38,30)})
        elseif mode == "warning" then
            statusIcon.Image = Icons.Key; statusIcon.ImageColor3 = Theme.Warning
            tween(statusWrap, 0.2, {BackgroundColor3=Color3.fromRGB(42,35,22)})
        else
            statusIcon.Image = Icons.Sparkles; statusIcon.ImageColor3 = Theme.Text3
            tween(statusWrap, 0.2, {BackgroundColor3=Theme.Background3})
        end
    end

    local function validateKey()
        local key = keyInput.Text:gsub("%s+", "")
        if key == "" then
            setStatus("Digite uma key para continuar.", "error")
            tween(main, 0.08, {Position=UDim2.new(0.5,6,0.5,0)}, Enum.EasingStyle.Sine)
            task.wait(0.08)
            tween(main, 0.08, {Position=UDim2.new(0.5,-6,0.5,0)}, Enum.EasingStyle.Sine)
            task.wait(0.08)
            tween(main, 0.08, {Position=UDim2.new(0.5,0,0.5,0)}, Enum.EasingStyle.Sine)
            return
        end

        setStatus("Key validada! Carregando Dead Rails...", "success")
        task.wait(0.55)

        tween(main, 0.35, {
            Size=UDim2.new(0,math.floor(width*0.82),0,math.floor(height*0.82)),
            BackgroundTransparency=1
        }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        tween(bg, 0.3, {BackgroundTransparency=1})

        for _, v in ipairs(main:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                tween(v, 0.2, {TextTransparency=1})
            elseif v:IsA("ImageLabel") then
                tween(v, 0.2, {ImageTransparency=1})
            elseif v:IsA("Frame") then
                tween(v, 0.2, {BackgroundTransparency=1})
            elseif v:IsA("UIStroke") then
                tween(v, 0.2, {Transparency=1})
            end
        end

        task.wait(0.36)
        KeyGui:Destroy()
        if onValidated then onValidated() end
    end

    validateBtn.MouseButton1Click:Connect(validateKey)
    keyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then validateKey() end
    end)
    getKeyBtn.MouseButton1Click:Connect(function() setStatus("Defina aqui sua ação de obtenção de key.", "warning") end)
    discordBtn.MouseButton1Click:Connect(function() setStatus("Defina aqui sua ação de Discord.", "warning") end)

    logoWrap.Size = UDim2.new(0,40,0,40)
    logoWrap.BackgroundTransparency = 1
    main.Size = UDim2.new(0,math.floor(width*0.86),0,math.floor(height*0.86))
    main.BackgroundTransparency = 1

    tween(main, 0.5, {Size=UDim2.new(0,width,0,height), BackgroundTransparency=0}, Enum.EasingStyle.Back)
    tween(logoWrap, 0.5, {Size=UDim2.new(0,74,0,74), BackgroundTransparency=0.82}, Enum.EasingStyle.Back)

    task.spawn(function()
        while logo.Parent do
            tween(logo, 6, {Rotation=360}, Enum.EasingStyle.Linear)
            task.wait(6)
            logo.Rotation = 0
        end
    end)

    task.spawn(function()
        while logoWrap.Parent do
            tween(logoWrap, 1.2, {BackgroundTransparency=0.72}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
            tween(logoWrap, 1.2, {BackgroundTransparency=0.82}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.2)
        end
    end)
end

local function createPageScroll(parent)
    local scroll = create("ScrollingFrame", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0,
        AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new(),
        ScrollBarThickness=3, ScrollBarImageColor3=Theme.Accent,
        Visible=false, Parent=parent
    })
    padding(scroll, 0, 4, 0, 4)
    list(scroll, 10)
    return scroll
end

local DR_Accent = Color3.fromRGB(255, 140, 40)
local DR_Accent2 = Color3.fromRGB(255, 100, 30)

local function createMainHub()
    local hub = {Tabs={}, ActiveTab=nil, Minimized=false}

    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local width = isMobile and 540 or 820
    local height = isMobile and 380 or 500
    local sidebarWidth = isMobile and 94 or 198
    local topHeight = 68

    local root = create("Frame", {
        Name="MainHub", AnchorPoint=Vector2.new(0.5,0.5),
        Size=UDim2.new(0,width,0,height), Position=UDim2.new(0.5,0,0.52,0),
        BackgroundColor3=Theme.Card, Parent=MainGui
    })
    corner(root, 24)
    stroke(root, Theme.Stroke, 1.2)
    shadow(root, 66, 0.42)

    local rootGlow = create("Frame", {
        AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(1,18,1,18),
        Position=UDim2.new(0.5,0,0.5,0), BackgroundColor3=DR_Accent,
        BackgroundTransparency=0.94, ZIndex=0, Parent=root
    })
    corner(rootGlow, 30)

    local top = create("Frame", {Size=UDim2.new(1,0,0,topHeight), BackgroundColor3=Theme.Card2, Parent=root})
    corner(top, 24)

    create("Frame", {
        Size=UDim2.new(1,0,0,26), Position=UDim2.new(0,0,1,-26),
        BackgroundColor3=Theme.Card2, BorderSizePixel=0, Parent=top
    })

    local topGradient = create("Frame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Parent=top})
    create("UIGradient", {
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Card2),
            ColorSequenceKeypoint.new(1, Theme.Background3)
        }), Rotation=0, Parent=topGradient
    })

    local brandWrap = create("Frame", {
        Size=UDim2.new(0,44,0,44), Position=UDim2.new(0,14,0.5,-22),
        BackgroundColor3=DR_Accent, BackgroundTransparency=0.8, Parent=top
    })
    corner(brandWrap, 15)

    local brandRing = create("ImageLabel", {
        AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(1,12,1,12), BackgroundTransparency=1,
        Image="rbxassetid://266543268", ImageColor3=DR_Accent, ImageTransparency=0.55, Parent=brandWrap
    })

    local brandLogo = create("ImageLabel", {
        AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0,22,0,22), BackgroundTransparency=1,
        Image=Icons.Logo, ImageColor3=DR_Accent, Parent=brandWrap
    })

    local brandTitle = create("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,68,0,12),
        Size=UDim2.new(0,170,0,20), Text="LOST HUB",
        Font=Enum.Font.GothamBlack, TextSize=18, TextColor3=Theme.Text,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=top
    })
    create("UIGradient", {Color=ColorSequence.new(DR_Accent, DR_Accent2), Rotation=0, Parent=brandTitle})

    create("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,68,0,36),
        Size=UDim2.new(0,240,0,14), Text="• DEAD RAILS",
        Font=Enum.Font.GothamBold, TextSize=11, TextColor3=Theme.Text2,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=top
    })

    local userCard = create("Frame", {
        AnchorPoint=Vector2.new(1,0.5),
        Size=UDim2.new(0, isMobile and 140 or 210, 0, 44),
        Position=UDim2.new(1,-106,0.5,0), BackgroundColor3=Theme.Background3, Parent=top
    })
    corner(userCard, 15)
    stroke(userCard, Theme.Stroke, 1)

    local userGlow = create("Frame", {
        AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(1,8,1,8),
        Position=UDim2.new(0.5,0,0.5,0), BackgroundColor3=DR_Accent,
        BackgroundTransparency=0.95, Parent=userCard
    })
    corner(userGlow, 18)

    local avatar = create("ImageLabel", {
        Size=UDim2.new(0,30,0,30), Position=UDim2.new(0,7,0.5,-15),
        BackgroundTransparency=1, Image=getThumb(), Parent=userCard
    })
    corner(avatar, 999)
    stroke(avatar, Theme.Stroke, 1)

    create("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,43,0,8),
        Size=UDim2.new(1,-51,0,14), Text=LocalPlayer.DisplayName,
        Font=Enum.Font.GothamBold, TextSize=12, TextColor3=Theme.Text,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=userCard
    })

    create("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,43,0,22),
        Size=UDim2.new(1,-51,0,12), Text="@"..LocalPlayer.Name,
        Font=Enum.Font.Gotham, TextSize=10, TextColor3=Theme.Text3,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=userCard
    })

    local minimizeBtn = create("TextButton", {
        AnchorPoint=Vector2.new(1,0.5), Size=UDim2.new(0,38,0,38),
        Position=UDim2.new(1,-58,0.5,0), BackgroundColor3=Theme.Background3,
        Text="–", Font=Enum.Font.GothamBold, TextSize=22, TextColor3=Theme.Text2,
        AutoButtonColor=false, Parent=top
    })
    corner(minimizeBtn, 13)
    stroke(minimizeBtn, Theme.Stroke, 1)

    local closeBtn = create("TextButton", {
        AnchorPoint=Vector2.new(1,0.5), Size=UDim2.new(0,38,0,38),
        Position=UDim2.new(1,-14,0.5,0), BackgroundColor3=Theme.Background3,
        Text="×", Font=Enum.Font.GothamBold, TextSize=22, TextColor3=Theme.Error,
        AutoButtonColor=false, Parent=top
    })
    corner(closeBtn, 13)
    stroke(closeBtn, Theme.Stroke, 1)

    local sidebar = create("Frame", {
        Size=UDim2.new(0,sidebarWidth,1,-topHeight), Position=UDim2.new(0,0,0,topHeight),
        BackgroundColor3=Theme.Card2, Parent=root
    })
    corner(sidebar, 24)

    create("Frame", {
        Size=UDim2.new(0,24,1,0), Position=UDim2.new(1,-24,0,0),
        BackgroundColor3=Theme.Card2, BorderSizePixel=0, Parent=sidebar
    })

    local sidebarGradient = create("Frame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Parent=sidebar})
    create("UIGradient", {
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Card2),
            ColorSequenceKeypoint.new(1, Theme.Background3)
        }), Rotation=90, Parent=sidebarGradient
    })

    local tabsWrap = create("ScrollingFrame", {
        Size=UDim2.new(1,-12,1,-12), Position=UDim2.new(0,6,0,6),
        BackgroundTransparency=1, BorderSizePixel=0,
        AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new(),
        ScrollBarThickness=2, ScrollBarImageColor3=DR_Accent, Parent=sidebar
    })
    padding(tabsWrap, 0, 0, 6, 6)
    list(tabsWrap, 8)

    local content = create("Frame", {
        Size=UDim2.new(1,-sidebarWidth,1,-topHeight), Position=UDim2.new(0,sidebarWidth,0,topHeight),
        BackgroundTransparency=1, Parent=root
    })

    local contentBack = create("Frame", {
        Size=UDim2.new(1,-10,1,-10), Position=UDim2.new(0,5,0,5),
        BackgroundColor3=Color3.fromRGB(14,16,24), BackgroundTransparency=0.18, Parent=content
    })
    corner(contentBack, 20)
    stroke(contentBack, Theme.Stroke, 1, 0.35)

    local pages = create("Frame", {
        Size=UDim2.new(1,-18,1,-18), Position=UDim2.new(0,9,0,9),
        BackgroundTransparency=1, Parent=content
    })

    local bubble = create("Frame", {
        Visible=false, AnchorPoint=Vector2.new(0.5,0.5),
        Size=UDim2.new(0,76,0,76), Position=UDim2.new(0,0,0,0),
        BackgroundColor3=Theme.Card, Parent=MainGui
    })
    corner(bubble, 999)
    stroke(bubble, Theme.Stroke, 1.2)
    shadow(bubble, 56, 0.4)

    local bubbleGlow = create("Frame", {
        AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(1,18,1,18),
        Position=UDim2.new(0.5,0,0.5,0), BackgroundColor3=DR_Accent,
        BackgroundTransparency=0.9, Parent=bubble
    })
    corner(bubbleGlow, 999)

    local bubbleRing1 = create("ImageLabel", {
        AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(1,10,1,10),
        Position=UDim2.new(0.5,0,0.5,0), BackgroundTransparency=1,
        Image="rbxassetid://266543268", ImageColor3=DR_Accent, ImageTransparency=0.62, Parent=bubble
    })

    local bubbleRing2 = create("ImageLabel", {
        AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(1,-8,1,-8),
        Position=UDim2.new(0.5,0,0.5,0), BackgroundTransparency=1,
        Image="rbxassetid://266543268", ImageColor3=DR_Accent2, ImageTransparency=0.72, Parent=bubble
    })

    local bubbleInner = create("Frame", {
        AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(1,-10,1,-10),
        Position=UDim2.new(0.5,0,0.5,0), BackgroundColor3=Theme.Background3, Parent=bubble
    })
    corner(bubbleInner, 999)
    stroke(bubbleInner, Theme.Stroke, 1, 0.25)

    local bubbleButton = create("TextButton", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", AutoButtonColor=false, Parent=bubble
    })

    local bubbleIconBack = create("Frame", {
        AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(0,44,0,44),
        Position=UDim2.new(0.5,0,0.5,0), BackgroundColor3=DR_Accent,
        BackgroundTransparency=0.85, Parent=bubble
    })
    corner(bubbleIconBack, 999)

    local bubbleIcon = create("ImageLabel", {
        AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(0,26,0,26),
        Position=UDim2.new(0.5,0,0.5,0), BackgroundTransparency=1,
        Image=Icons.Logo, ImageColor3=DR_Accent, Parent=bubble
    })

    local bubbleDot = create("Frame", {
        Size=UDim2.new(0,12,0,12), Position=UDim2.new(1,-16,0,10),
        BackgroundColor3=Theme.Success, Parent=bubble
    })
    corner(bubbleDot, 999)
    stroke(bubbleDot, Color3.fromRGB(255,255,255), 1)

    local bubbleAvatar = create("ImageLabel", {
        Size=UDim2.new(0,18,0,18), Position=UDim2.new(0,8,1,-26),
        BackgroundTransparency=1, Image=getThumb(), Parent=bubble
    })
    corner(bubbleAvatar, 999)

    local bubbleTip = create("Frame", {
        Visible=false, AnchorPoint=Vector2.new(1,0.5),
        Size=UDim2.new(0,154,0,44), Position=UDim2.new(0,-10,0.5,0),
        BackgroundColor3=Theme.Card, Parent=bubble
    })
    corner(bubbleTip, 14)
    stroke(bubbleTip, Theme.Stroke, 1)
    shadow(bubbleTip, 42, 0.46)

    create("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,12,0,7),
        Size=UDim2.new(1,-24,0,14), Text="Lost Hub • Dead Rails",
        Font=Enum.Font.GothamBold, TextSize=12, TextColor3=Theme.Text,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=bubbleTip
    })

    create("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,12,0,21),
        Size=UDim2.new(1,-24,0,14), Text="Toque para restaurar",
        Font=Enum.Font.Gotham, TextSize=11, TextColor3=Theme.Text2,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=bubbleTip
    })

    bubble.MouseEnter:Connect(function()
        bubbleTip.Visible = true
        tween(bubble, 0.18, {Size=UDim2.new(0,82,0,82)}, Enum.EasingStyle.Back)
    end)

    bubble.MouseLeave:Connect(function()
        bubbleTip.Visible = false
        tween(bubble, 0.18, {Size=UDim2.new(0,76,0,76)}, Enum.EasingStyle.Back)
    end)

    closeBtn.MouseEnter:Connect(function() tween(closeBtn, 0.18, {BackgroundColor3=Color3.fromRGB(55,22,26)}) end)
    closeBtn.MouseLeave:Connect(function() tween(closeBtn, 0.18, {BackgroundColor3=Theme.Background3}) end)
    minimizeBtn.MouseEnter:Connect(function() tween(minimizeBtn, 0.18, {BackgroundColor3=Theme.Card}) end)
    minimizeBtn.MouseLeave:Connect(function() tween(minimizeBtn, 0.18, {BackgroundColor3=Theme.Background3}) end)

    local function playBubbleLoop()
        task.spawn(function()
            while bubble.Visible and bubble.Parent do
                tween(bubbleGlow, 1.25, {BackgroundTransparency=0.84, Size=UDim2.new(1,28,1,28)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                tween(bubbleIconBack, 1.25, {BackgroundTransparency=0.78, Size=UDim2.new(0,48,0,48)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(1.25)
                tween(bubbleGlow, 1.25, {BackgroundTransparency=0.92, Size=UDim2.new(1,18,1,18)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                tween(bubbleIconBack, 1.25, {BackgroundTransparency=0.85, Size=UDim2.new(0,44,0,44)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(1.25)
            end
        end)

        task.spawn(function()
            while bubble.Visible and bubble.Parent do
                tween(bubbleRing1, 5.5, {Rotation=360}, Enum.EasingStyle.Linear)
                tween(bubbleRing2, 7.5, {Rotation=-360}, Enum.EasingStyle.Linear)
                tween(bubbleIcon, 4.8, {Rotation=360}, Enum.EasingStyle.Linear)
                task.wait(7.5)
                bubbleRing1.Rotation = 0; bubbleRing2.Rotation = 0; bubbleIcon.Rotation = 0
            end
        end)

        task.spawn(function()
            while bubble.Visible and bubble.Parent do
                tween(bubbleDot, 0.75, {BackgroundTransparency=0.15}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(0.75)
                tween(bubbleDot, 0.75, {BackgroundTransparency=0}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(0.75)
            end
        end)
    end

    local function showBubble()
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
        bubble.Visible = true
        bubble.Size = UDim2.new(0,42,0,42)
        bubble.BackgroundTransparency = 1
        bubble.Position = UDim2.new(0, viewport.X-90, 0, viewport.Y-120)
        tween(bubble, 0.36, {Size=UDim2.new(0,76,0,76), BackgroundTransparency=0}, Enum.EasingStyle.Back)
        snapBubbleToEdge(bubble)
        playBubbleLoop()
    end

    local function hideBubble()
        if not bubble.Visible then return end
        tween(bubble, 0.22, {Size=UDim2.new(0,42,0,42), BackgroundTransparency=1}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.23)
        bubble.Visible = false
    end

    local function minimize()
        if hub.Minimized then return end
        hub.Minimized = true
        tween(root, 0.3, {
            Size=UDim2.new(0,math.floor(width*0.9),0,0),
            Position=UDim2.new(root.Position.X.Scale, root.Position.X.Offset, root.Position.Y.Scale, root.Position.Y.Offset+20)
        }, Enum.EasingStyle.Back, Enum.EasingDirection.In)

        for _, v in ipairs(root:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                tween(v, 0.18, {TextTransparency=1})
            elseif v:IsA("ImageLabel") then
                tween(v, 0.18, {ImageTransparency=1})
            elseif v:IsA("Frame") and v ~= root and v ~= rootGlow then
                tween(v, 0.18, {BackgroundTransparency=1})
            elseif v:IsA("UIStroke") then
                tween(v, 0.18, {Transparency=1})
            end
        end

        task.wait(0.22)
        root.Visible = false
        showBubble()
    end

    local function restore()
        if not hub.Minimized then return end
        hideBubble()
        hub.Minimized = false
        root.Visible = true
        root.Size = UDim2.new(0, math.floor(width*0.9), 0, 0)
        tween(root, 0.4, {Size=UDim2.new(0,width,0,height), Position=UDim2.new(0.5,0,0.52,0)}, Enum.EasingStyle.Back)

        for _, v in ipairs(root:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                tween(v, 0.22, {TextTransparency=0})
            elseif v:IsA("ImageLabel") then
                tween(v, 0.22, {ImageTransparency=0})
            elseif v:IsA("Frame") then
                if v == root then tween(v, 0.22, {BackgroundTransparency=0})
                elseif v == pages or v == content then
                elseif v == rootGlow then tween(v, 0.22, {BackgroundTransparency=0.94})
                else tween(v, 0.22, {BackgroundTransparency=0}) end
            elseif v:IsA("UIStroke") then
                tween(v, 0.22, {Transparency=0})
            end
        end
    end

    makeDraggable(root, top, nil, nil)
    makeDraggable(bubble, bubbleButton, function() restore() end, function() snapBubbleToEdge(bubble) end)

    bubbleButton.MouseEnter:Connect(function() tween(bubbleInner, 0.18, {BackgroundColor3=Theme.Card}) end)
    bubbleButton.MouseLeave:Connect(function() tween(bubbleInner, 0.18, {BackgroundColor3=Theme.Background3}) end)

    minimizeBtn.MouseButton1Click:Connect(minimize)

    closeBtn.MouseButton1Click:Connect(function()
        tween(root, 0.28, {Size=UDim2.new(0,0,0,0)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.28)
        MainGui:Destroy()
        NotifyGui:Destroy()
    end)

    root.Size = UDim2.new(0, math.floor(width*0.86), 0, math.floor(height*0.86))
    root.BackgroundTransparency = 1
    tween(root, 0.45, {Size=UDim2.new(0,width,0,height), BackgroundTransparency=0}, Enum.EasingStyle.Back)

    task.spawn(function()
        while brandLogo.Parent do
            tween(brandLogo, 7, {Rotation=360}, Enum.EasingStyle.Linear)
            tween(brandRing, 6, {Rotation=-360}, Enum.EasingStyle.Linear)
            task.wait(7)
            brandLogo.Rotation = 0; brandRing.Rotation = 0
        end
    end)

    task.spawn(function()
        while brandWrap.Parent do
            tween(brandWrap, 1.3, {BackgroundTransparency=0.7}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            tween(userGlow, 1.3, {BackgroundTransparency=0.91}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.3)
            tween(brandWrap, 1.3, {BackgroundTransparency=0.8}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            tween(userGlow, 1.3, {BackgroundTransparency=0.95}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.3)
        end
    end)

    task.spawn(function()
        while rootGlow.Parent do
            tween(rootGlow, 2.2, {BackgroundTransparency=0.91, Size=UDim2.new(1,28,1,28)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(2.2)
            tween(rootGlow, 2.2, {BackgroundTransparency=0.95, Size=UDim2.new(1,18,1,18)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
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
        Size=UDim2.new(1,0,0,50), BackgroundColor3=Theme.Background3,
        Text=isMobile and "" or ("   "..name), Font=Enum.Font.GothamBold,
        TextSize=12, TextColor3=Theme.Text2, AutoButtonColor=false, Parent=hub.Sidebar
    })
    corner(button, 16)
    stroke(button, Theme.Stroke, 1)

    local btnGlow = create("Frame", {
        Size=UDim2.new(1,0,1,0), BackgroundColor3=DR_Accent,
        BackgroundTransparency=0.96, Parent=button
    })
    corner(btnGlow, 16)

    local img = create("ImageLabel", {
        Size=UDim2.new(0,18,0,18),
        Position=isMobile and UDim2.new(0.5,-9,0.5,-9) or UDim2.new(0,14,0.5,-9),
        BackgroundTransparency=1, Image=icon or Icons.Home,
        ImageColor3=Theme.Text3, Parent=button
    })

    local activeBar = create("Frame", {
        Visible=false, Size=UDim2.new(0,3,0.62,0),
        AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,0,0.5,0),
        BackgroundColor3=DR_Accent, Parent=button
    })
    corner(activeBar, 999)

    local page = createPageScroll(hub.Pages)

    local tab = {Button=button, Icon=img, Page=page, ActiveBar=activeBar, Glow=btnGlow, Name=name}

    local function activate()
        if hub.ActiveTab == tab then return end
        if hub.ActiveTab then
            hub.ActiveTab.Page.Visible = false
            hub.ActiveTab.ActiveBar.Visible = false
            tween(hub.ActiveTab.Button, 0.18, {BackgroundColor3=Theme.Background3})
            tween(hub.ActiveTab.Icon, 0.18, {ImageColor3=Theme.Text3})
            tween(hub.ActiveTab.Glow, 0.18, {BackgroundTransparency=0.96})
            hub.ActiveTab.Button.TextColor3 = Theme.Text2
        end
        hub.ActiveTab = tab
        tab.Page.Visible = true
        tab.ActiveBar.Visible = true
        tween(tab.Button, 0.18, {BackgroundColor3=Theme.Card})
        tween(tab.Icon, 0.18, {ImageColor3=DR_Accent})
        tween(tab.Glow, 0.18, {BackgroundTransparency=0.92})
        tab.Button.TextColor3 = Theme.Text
    end

    button.MouseEnter:Connect(function()
        if hub.ActiveTab ~= tab then
            tween(button, 0.16, {BackgroundColor3=Theme.Card})
            tween(img, 0.16, {ImageColor3=Theme.Text2})
            tween(btnGlow, 0.16, {BackgroundTransparency=0.94})
        end
    end)

    button.MouseLeave:Connect(function()
        if hub.ActiveTab ~= tab then
            tween(button, 0.16, {BackgroundColor3=Theme.Background3})
            tween(img, 0.16, {ImageColor3=Theme.Text3})
            tween(btnGlow, 0.16, {BackgroundTransparency=0.96})
        end
    end)

    button.MouseButton1Click:Connect(activate)
    table.insert(hub.Tabs, tab)
    if not hub.ActiveTab then activate() end

    return page
end

local function createSection(parent, titleText, descText)
    local section = create("Frame", {
        Size=UDim2.new(1,-4,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundColor3=Theme.Card2, Parent=parent
    })
    corner(section, 20)
    stroke(section, Theme.Stroke, 1)

    create("Frame", {Size=UDim2.new(1,0,0,1), BackgroundColor3=DR_Accent, BackgroundTransparency=0.78, Parent=section})

    local topFade = create("Frame", {Size=UDim2.new(1,0,0,54), BackgroundTransparency=1, Parent=section})
    create("UIGradient", {
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(40,20,5)),
            ColorSequenceKeypoint.new(1, Theme.Card2)
        }),
        Rotation=90, Transparency=NumberSequence.new(0.72, 1), Parent=topFade
    })

    padding(section, 16, 16, 16, 16)
    list(section, 12)

    create("TextLabel", {
        Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text=titleText,
        Font=Enum.Font.GothamBold, TextSize=15, TextColor3=Theme.Text,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=section
    })

    if descText and descText ~= "" then
        create("TextLabel", {
            Size=UDim2.new(1,0,0,16), BackgroundTransparency=1, Text=descText,
            Font=Enum.Font.Gotham, TextSize=12, TextColor3=Theme.Text2,
            TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left, Parent=section
        })
    end

    return section
end

local function createInfoCard(parent, titleText, valueText, icon)
    local frame = create("Frame", {
        Size=UDim2.new(1,0,0,68), BackgroundColor3=Theme.Background3, Parent=parent
    })
    corner(frame, 17)
    stroke(frame, Theme.Stroke, 1)

    local bgLine = create("Frame", {
        Size=UDim2.new(0,3,1,-14), Position=UDim2.new(0,10,0,7),
        BackgroundColor3=DR_Accent, Parent=frame
    })
    corner(bgLine, 999)

    local iconWrap = create("Frame", {
        Size=UDim2.new(0,40,0,40), Position=UDim2.new(0,18,0.5,-20),
        BackgroundColor3=DR_Accent, BackgroundTransparency=0.84, Parent=frame
    })
    corner(iconWrap, 13)

    create("ImageLabel", {
        AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0,18,0,18), BackgroundTransparency=1,
        Image=icon or Icons.Sparkles, ImageColor3=DR_Accent, Parent=iconWrap
    })

    create("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,68,0,13),
        Size=UDim2.new(1,-80,0,14), Text=titleText,
        Font=Enum.Font.GothamBold, TextSize=11, TextColor3=Theme.Text3,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=frame
    })

    create("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,68,0,30),
        Size=UDim2.new(1,-80,0,20), Text=valueText,
        Font=Enum.Font.GothamBold, TextSize=14, TextColor3=Theme.Text,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=frame
    })

    return frame
end

local function createButton(parent, text, callback, accent)
    local accentColor = accent or DR_Accent
    local btn = create("TextButton", {
        Size=UDim2.new(1,0,0,46), BackgroundColor3=accentColor,
        Text=text, Font=Enum.Font.GothamBlack, TextSize=13,
        TextColor3=Color3.fromRGB(0,0,0), AutoButtonColor=false, Parent=parent
    })
    corner(btn, 14)

    btn.MouseEnter:Connect(function() tween(btn, 0.16, {BackgroundColor3=DR_Accent2}) end)
    btn.MouseLeave:Connect(function() tween(btn, 0.16, {BackgroundColor3=accentColor}) end)
    btn.MouseButton1Click:Connect(function() if callback then callback() end end)

    return btn
end

local function createLabel(parent, text)
    return create("TextLabel", {
        Size=UDim2.new(1,0,0,18), BackgroundTransparency=1, Text=text,
        Font=Enum.Font.Gotham, TextSize=12, TextColor3=Theme.Text2,
        TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left, Parent=parent
    })
end

local function createToggle(parent, text, default, callback)
    local enabled = default == true

    local frame = create("TextButton", {
        Size=UDim2.new(1,0,0,54), BackgroundColor3=Theme.Background3,
        Text="", AutoButtonColor=false, Parent=parent
    })
    corner(frame, 16)
    stroke(frame, Theme.Stroke, 1)

    create("TextLabel", {
        Size=UDim2.new(1,-88,1,0), Position=UDim2.new(0,14,0,0),
        BackgroundTransparency=1, Text=text, Font=Enum.Font.GothamBold,
        TextSize=13, TextColor3=Theme.Text, TextXAlignment=Enum.TextXAlignment.Left, Parent=frame
    })

    local switch = create("Frame", {
        Size=UDim2.new(0,50,0,28), Position=UDim2.new(1,-64,0.5,-14),
        BackgroundColor3=Theme.Card, Parent=frame
    })
    corner(switch, 999)
    stroke(switch, Theme.Stroke, 1)

    local knob = create("Frame", {
        Size=UDim2.new(0,22,0,22), Position=UDim2.new(0,3,0.5,-11),
        BackgroundColor3=Theme.Text3, Parent=switch
    })
    corner(knob, 999)

    local function render()
        if enabled then
            tween(switch, 0.18, {BackgroundColor3=DR_Accent})
            tween(knob, 0.18, {Position=UDim2.new(0,25,0.5,-11), BackgroundColor3=Color3.fromRGB(0,0,0)})
        else
            tween(switch, 0.18, {BackgroundColor3=Theme.Card})
            tween(knob, 0.18, {Position=UDim2.new(0,3,0.5,-11), BackgroundColor3=Theme.Text3})
        end
        if callback then callback(enabled) end
    end

    frame.MouseButton1Click:Connect(function() enabled = not enabled; render() end)
    render()

    return frame
end

local function createStatRow(parent, leftText, rightText)
    local row = create("Frame", {Size=UDim2.new(1,0,0,36), BackgroundTransparency=1, Parent=parent})
    create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(0.5,0,1,0), Text=leftText, Font=Enum.Font.Gotham, TextSize=12, TextColor3=Theme.Text2, TextXAlignment=Enum.TextXAlignment.Left, Parent=row})
    create("TextLabel", {BackgroundTransparency=1, Position=UDim2.new(0.5,0,0,0), Size=UDim2.new(0.5,0,1,0), Text=rightText, Font=Enum.Font.GothamBold, TextSize=12, TextColor3=Theme.Text, TextXAlignment=Enum.TextXAlignment.Right, Parent=row})
    return row
end

local function createDivider(parent)
    return create("Frame", {Size=UDim2.new(1,0,0,1), BackgroundColor3=Theme.Stroke, BorderSizePixel=0, Parent=parent})
end

local G = {
    running = false,
    mode = nil,
    bonds = 0,
    wins = 0,
    runs = 0,
    t0 = tick(),
}

local Settings = {
    antiAfk = true,
    autoCollect = true,
    fastMode = false,
}

local statusLabelRef = nil
local statusDotRef = nil
local bondsLabelRef = nil
local winsLabelRef = nil
local runsLabelRef = nil
local timeLabelRef = nil
local locLabelRef = nil
local modeLabelRef = nil
local logListRef = nil
local activityLog = {}

local function pushLog(text, color)
    table.insert(activityLog, 1, {text=text, color=color or Theme.Text2, time=os.date("%H:%M:%S")})
    while #activityLog > 20 do table.remove(activityLog) end
    if not logListRef then return end
    for _, c in ipairs(logListRef:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    for i, entry in ipairs(activityLog) do
        local row = create("Frame", {
            Size=UDim2.new(1,0,0,28),
            BackgroundColor3=i%2==0 and Theme.Card or Theme.Background3,
            BorderSizePixel=0, Parent=logListRef
        })
        corner(row, 8)

        local dot = create("Frame", {Size=UDim2.new(0,6,0,6), Position=UDim2.new(0,8,0.5,-3), BackgroundColor3=entry.color, BorderSizePixel=0, Parent=row})
        corner(dot, 999)

        create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(0,45,1,0), Position=UDim2.new(0,18,0,0), Text=entry.time, Font=Enum.Font.Gotham, TextSize=9, TextColor3=Theme.Text3, TextXAlignment=Enum.TextXAlignment.Left, Parent=row})
        local tl = create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,-70,1,0), Position=UDim2.new(0,66,0,0), Text=entry.text, Font=Enum.Font.Gotham, TextSize=10, TextColor3=Theme.Text2, TextXAlignment=Enum.TextXAlignment.Left, Parent=row})
        tl.TextTruncate = Enum.TextTruncate.AtEnd
    end

    if logListRef.Parent and logListRef.Parent:IsA("ScrollingFrame") then
        logListRef.Parent.CanvasSize = UDim2.new(0, 0, 0, #activityLog * 34)
    end
end

local function setStatus(txt, color)
    if statusLabelRef then
        statusLabelRef.Text = txt
        statusLabelRef.TextColor3 = color or Theme.Text2
    end
    if statusDotRef then
        tween(statusDotRef, 0.2, {BackgroundColor3 = color or Theme.Text3})
    end
    pushLog(txt, color)
end

local function setDetail(name, text)
    if name == "time" and timeLabelRef then timeLabelRef.Text = text
    elseif name == "loc" and locLabelRef then locLabelRef.Text = text
    elseif name == "mode" and modeLabelRef then modeLabelRef.Text = text end
end

local function updateStats()
    if bondsLabelRef then bondsLabelRef.Text = tostring(G.bonds) end
    if winsLabelRef then winsLabelRef.Text = tostring(G.wins) end
    if runsLabelRef then runsLabelRef.Text = tostring(G.runs) end
end

local function loadDeadRailsScript()
    if not game:IsLoaded() then game.Loaded:Wait() end

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TeleportService = game:GetService("TeleportService")
    local VirtualUser = game:GetService("VirtualUser")

    local LOBBY = 116495829188952
    local GAME = 70876832253163

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HRP = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    local Alive = true

    LocalPlayer.CharacterAdded:Connect(function(c)
        character = c
        HRP = c:WaitForChild("HumanoidRootPart")
        humanoid = c:WaitForChild("Humanoid")
    end)

    local RAIL_X = -424
    local RAIL_Y = 35
    local RAIL_END_Z = -52000

    local activateRemote = nil
    task.spawn(function()
        local ok, result = pcall(function()
            return ReplicatedStorage
                :WaitForChild("Shared", 15)
                :WaitForChild("Network", 15)
                :WaitForChild("RemotePromise", 15)
                :WaitForChild("Remotes", 15)
                :WaitForChild("C_ActivateObject", 15)
        end)
        if ok and result then activateRemote = result end
    end)

    local function isUnanchored(m)
        for _, p in pairs(m:GetDescendants()) do
            if p:IsA("BasePart") and not p.Anchored then return true end
        end
        return false
    end

    local function findCannonModel()
        local exclude = nil
        local fort = workspace:FindFirstChild("FortConstitution")
        if fort then exclude = fort:FindFirstChild("Cannon", true) end
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("Model") and d.Name == "Cannon" and d ~= exclude then return d end
        end
        return nil
    end

    local function doCannonSync()
        setStatus("Sincronizando via canhão...", DR_Accent)
        local savedCF = HRP.CFrame
        local done = false

        local tInfo = TweenInfo.new(20, Enum.EasingStyle.Linear)
        local syncTween = TweenService:Create(HRP, tInfo, {CFrame = CFrame.new(-9, 3, -50000)})
        syncTween:Play()

        local conn
        conn = RunService.RenderStepped:Connect(function()
            if done then return end
            local can = findCannonModel()
            if can and isUnanchored(can) then
                local seat = can:FindFirstChildWhichIsA("VehicleSeat", true)
                if seat and not seat.Occupant then
                    syncTween:Cancel()
                    conn:Disconnect()
                    HRP.CFrame = seat.CFrame
                    seat:Sit(humanoid)
                    task.delay(1, function()
                        humanoid.Sit = false
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        task.delay(1, function()
                            seat:Sit(humanoid)
                            task.delay(1, function()
                                HRP.CFrame = savedCF
                                humanoid.JumpPower = 50
                                humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                                done = true
                            end)
                        end)
                    end)
                end
            end
        end)

        local t0 = tick()
        while not done and tick()-t0 < 30 and G.running do task.wait(0.1) end
        pcall(function() conn:Disconnect() end)
        syncTween:Cancel()

        if done then
            setStatus("Sincronização completa!", Theme.Success)
        else
            setStatus("Canhão não encontrado, continuando...", Theme.Warning)
        end
        return done
    end

    local function findNearestBond()
        local runtimeItems = workspace:FindFirstChild("RuntimeItems")
        if not runtimeItems then return nil end
        local closest, shortestDist = nil, math.huge
        for _, item in ipairs(runtimeItems:GetDescendants()) do
            if item:IsA("Model") and item.Name:lower() == "bond" then
                local primary = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                if primary then
                    local dist = (primary.Position - HRP.Position).Magnitude
                    if dist < shortestDist then shortestDist = dist; closest = item end
                end
            end
        end
        return closest
    end

    local function collectBond(bond)
        if not bond or not bond.Parent then return end
        local primary = bond.PrimaryPart or bond:FindFirstChildWhichIsA("BasePart")
        if not primary then return end
        HRP.CFrame = primary.CFrame + Vector3.new(0, 5, 0)
        local startTime = os.clock()
        while bond.Parent and os.clock()-startTime < 1 do
            if activateRemote then pcall(function() activateRemote:FireServer(bond) end) end
            task.wait(0.1)
        end
        if not bond.Parent then
            G.bonds = G.bonds + 1
            updateStats()
        end
    end

    local activeTween2 = nil
    local function tweenToPos(pos)
        if activeTween2 then activeTween2:Cancel() end
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
        activeTween2 = TweenService:Create(HRP, tweenInfo, {CFrame = CFrame.new(pos)})
        local finished = false
        local c2 = activeTween2.Completed:Connect(function() finished = true end)
        activeTween2:Play()
        local t0 = os.clock()
        while not finished and G.running do
            local bond = findNearestBond()
            if bond then activeTween2:Cancel(); c2:Disconnect(); collectBond(bond); return end
            if os.clock()-t0 > 5 then break end
            task.wait(0.1)
        end
        c2:Disconnect()
    end

    local function findLever()
        local leverKeywords = {"lever","crank","drawbridge","bridge","winch","alavanca","handle","pull","gate","switch","activate","wheel"}
        local bestLever, bestPart, bestScore = nil, nil, 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local parent = obj.Parent
                if parent then
                    local score = 0
                    local pName = parent.Name:lower()
                    local gpName = parent.Parent and parent.Parent.Name:lower() or ""
                    for _, kw in ipairs(leverKeywords) do
                        if pName:find(kw) then score = score + 20 end
                        if gpName:find(kw) then score = score + 10 end
                    end
                    if obj.ActionText:lower():find("pull") or obj.ActionText:lower():find("activate") or obj.ActionText:lower():find("lower") then score = score + 15 end
                    local partPos = nil
                    if parent:IsA("BasePart") then partPos = parent.Position
                    elseif parent:FindFirstChildWhichIsA("BasePart") then partPos = parent:FindFirstChildWhichIsA("BasePart").Position end
                    if partPos and partPos.Z < -48000 then score = score + 50 end
                    if score > bestScore then bestScore = score; bestLever = obj; bestPart = parent end
                end
            end
        end
        return bestLever, bestPart
    end

    local function activateLeverProperly(leverPrompt)
        if not leverPrompt then return false end
        local holdTime = leverPrompt.HoldDuration or 15
        if holdTime <= 0 then holdTime = 15 end
        setStatus(string.format("Ativando alavanca: %.0fs...", holdTime), Theme.Success)
        leverPrompt.Enabled = true
        leverPrompt.RequiresLineOfSight = false
        local success = pcall(function() leverPrompt:InputHoldBegin() end)
        if not success then pcall(function() fireproximityprompt(leverPrompt) end); return true end
        local startTime = tick()
        while tick()-startTime < holdTime+2 do
            if not G.running then pcall(function() leverPrompt:InputHoldEnd() end); return false end
            local remaining = math.max(0, holdTime-(tick()-startTime))
            setStatus(string.format("Segurando alavanca: %.1fs", remaining), Theme.Success)
            pcall(function() HRP.AssemblyLinearVelocity = Vector3.zero; HRP.AssemblyAngularVelocity = Vector3.zero end)
            task.wait(0.1)
        end
        pcall(function() leverPrompt:InputHoldEnd() end)
        task.wait(0.5)
        for i = 1, 5 do pcall(function() fireproximityprompt(leverPrompt) end); task.wait(0.2) end
        setStatus("Alavanca ativada!", Theme.Success)
        return true
    end

    local function doBondsRun()
        setStatus("Auto Bonds iniciando...", Theme.Warning)
        setDetail("mode", "Auto Bonds")
        setDetail("loc", "Partida")
        G.runs = G.runs + 1
        updateStats()

        doCannonSync()
        if not G.running then return end

        local lockedY = HRP.Position.Y
        local lockConn = RunService.RenderStepped:Connect(function()
            if HRP and HRP.Parent then
                HRP.Velocity = Vector3.new(HRP.Velocity.X, 0, HRP.Velocity.Z)
                HRP.CFrame = CFrame.new(HRP.Position.X, lockedY, HRP.Position.Z)
            end
        end)

        local bondCount = 0
        local targetCount = 123

        local bond = findNearestBond()
        while bond and bondCount < targetCount and G.running do
            collectBond(bond); bondCount = G.bonds; bond = findNearestBond(); task.wait(0.05)
        end

        local layerSize = 2048
        local halfSize = layerSize/2
        local y = -50
        local z = 30000
        local zEnd = -49872
        local zStep = -layerSize
        local direction = 1

        while bondCount < targetCount and G.running and z >= zEnd do
            local xS = direction==1 and -halfSize or halfSize
            local xE = direction==1 and halfSize or -halfSize
            tweenToPos(Vector3.new(xS, y, z))
            tweenToPos(Vector3.new(xE, y, z))
            bond = findNearestBond()
            while bond and bondCount < targetCount and G.running do
                collectBond(bond); bondCount = G.bonds; bond = findNearestBond()
            end
            z = z + zStep; direction = direction * -1
            setStatus(string.format("Varrendo mapa... Bonds: %d/%d | Z: %.0f", bondCount, targetCount, z), Theme.Warning)
        end

        lockConn:Disconnect()
        setStatus(string.format("%d bonds coletados! Teleportando...", G.bonds), Theme.Success)
        task.wait(3)
        pcall(function() TeleportService:Teleport(LOBBY, LocalPlayer) end)
        task.wait(10)
    end

    local function doWinRun(skipBonds)
        local modeLabel = skipBonds and "Auto Win" or "Win + Bonds"
        setDetail("mode", modeLabel)
        setDetail("loc", "Partida")
        G.runs = G.runs + 1
        updateStats()

        doCannonSync()
        if not G.running then return end

        setStatus("Percorrendo trilhos...", Theme.Success)
        HRP.Anchored = true
        local startZ = HRP.Position.Z
        local travelTime = 25
        local mainTween = TweenService:Create(HRP, TweenInfo.new(travelTime, Enum.EasingStyle.Linear), {CFrame = CFrame.new(RAIL_X, RAIL_Y, RAIL_END_Z)})
        mainTween:Play()
        local travelStart = tick()

        if not skipBonds then
            while mainTween.PlaybackState == Enum.PlaybackState.Playing and G.running do
                local bond = findNearestBond()
                if bond then
                    mainTween:Cancel()
                    collectBond(bond)
                    local remaining = math.abs(HRP.Position.Z - RAIL_END_Z)
                    local total = math.max(1, math.abs(startZ - RAIL_END_Z))
                    local remTime = math.max(2, travelTime*(remaining/total))
                    mainTween = TweenService:Create(HRP, TweenInfo.new(remTime, Enum.EasingStyle.Linear), {CFrame = CFrame.new(RAIL_X, RAIL_Y, RAIL_END_Z)})
                    mainTween:Play()
                end
                local progress = math.clamp((tick()-travelStart)/travelTime*100, 0, 100)
                setStatus(string.format("Viajando %d%% | Bonds: %d", math.floor(progress), G.bonds), DR_Accent)
                task.wait(0.5)
            end
        else
            while mainTween.PlaybackState == Enum.PlaybackState.Playing and G.running do
                local progress = math.clamp((tick()-travelStart)/travelTime*100, 0, 100)
                setStatus(string.format("Trilhos... %d%%", math.floor(progress)), Theme.Success)
                task.wait(0.5)
            end
        end

        if not G.running then HRP.Anchored = false; return end

        HRP.CFrame = CFrame.new(RAIL_X, RAIL_Y, RAIL_END_Z)
        task.wait(1)

        setStatus("Chegou ao final! Procurando alavanca...", Theme.Success)
        local lever, leverPart, tries = nil, nil, 0

        while G.running and not lever and tries < 300 do
            lever, leverPart = findLever()
            if lever then break end
            tries = tries + 1
            if tries % 30 == 0 then
                local offset = (tries/30)*40
                HRP.CFrame = CFrame.new(RAIL_X+offset, RAIL_Y, RAIL_END_Z)
                setStatus(string.format("Procurando alavanca... (%d)", tries), Theme.Success)
            end
            task.wait(0.1)
        end

        if lever then
            setStatus("Alavanca encontrada!", Theme.Success)
            local lPos = nil
            if leverPart then
                if leverPart:IsA("BasePart") then lPos = leverPart.Position
                else local p = leverPart:FindFirstChildWhichIsA("BasePart"); if p then lPos = p.Position end end
            end
            if lPos then
                HRP.CFrame = CFrame.new(lPos+Vector3.new(0,10,12)); task.wait(0.3)
                HRP.CFrame = CFrame.new(lPos+Vector3.new(0,6,8)); task.wait(0.3)
                HRP.CFrame = CFrame.new(lPos+Vector3.new(0,4,5)); task.wait(0.4)
            end
            activateLeverProperly(lever)
        else
            setStatus("Alavanca não encontrada!", Theme.Error)
        end

        HRP.Anchored = false

        local waited, waitTime = 0, 250
        while G.running and waited < waitTime do
            task.wait(1); waited = waited + 1
            local rem = waitTime - waited
            setStatus(string.format("Aguardando vitória... %dm%02ds", math.floor(rem/60), rem%60), Theme.Success)
            if waited % 20 == 0 then
                local bond = findNearestBond()
                while bond do collectBond(bond); bond = findNearestBond() end
            end
        end

        if G.running then
            G.wins = G.wins + 1
            updateStats()
            setStatus("VITÓRIA! Voltando ao lobby...", Theme.Success)
            notify("Vitória!", "Win registrado. Total: "..G.wins, "success")
            task.wait(2)
            pcall(function() TeleportService:Teleport(LOBBY, LocalPlayer) end)
            task.wait(10)
        end
    end

    local function lobby_createParty()
        setStatus("Procurando sistema de party...", DR_Accent)
        setDetail("loc", "Lobby")

        local shared = ReplicatedStorage:WaitForChild("Shared", 20)
        if not shared then
            setStatus("Shared não encontrado! Teleportando...", Theme.Warning)
            pcall(function() TeleportService:Teleport(GAME, LocalPlayer) end)
            task.wait(10); return
        end

        local partyRemote = shared:FindFirstChild("CreatePartyClient")
        if not partyRemote then
            for _, v in ipairs(shared:GetDescendants()) do
                if v:IsA("RemoteEvent") and v.Name:lower():find("party") then partyRemote = v; break end
            end
        end

        if not partyRemote then
            setStatus("Remote não encontrado!", Theme.Warning)
            pcall(function() TeleportService:Teleport(GAME, LocalPlayer) end)
            task.wait(10); return
        end

        local zones = workspace:FindFirstChild("TeleportZones") or workspace:FindFirstChild("Zones")
        if not zones then
            pcall(function() partyRemote:FireServer({maxPlayers=1}) end)
            task.wait(3)
            pcall(function() TeleportService:Teleport(GAME, LocalPlayer) end)
            task.wait(10); return
        end

        local found, attempts = false, 0
        while G.running and not found do
            attempts = attempts + 1
            for _, z in ipairs(zones:GetChildren()) do
                if not G.running then break end
                local isZone = z.Name:lower():find("zone") or z.Name:lower():find("teleport")
                if isZone or z:IsA("BasePart") or z:FindFirstChildWhichIsA("BasePart") then
                    local zonePart = z:IsA("BasePart") and z or z:FindFirstChildWhichIsA("BasePart")
                    local billboard = z:FindFirstChildOfClass("BillboardGui")
                    local stateLabel = billboard and billboard:FindFirstChild("StateLabel")
                    local canUse = true
                    if stateLabel then
                        local txt = stateLabel.Text:lower()
                        if txt:find("full") or txt:find("cheio") or txt:find("in") then canUse = false end
                    end
                    if zonePart and canUse then
                        HRP.CFrame = zonePart.CFrame + Vector3.new(0,3,0)
                        task.wait(0.5)
                        pcall(function() partyRemote:FireServer({maxPlayers=1, isPublic=false}) end)
                        setStatus("Party criada! Aguardando...", Theme.Warning)
                        found = true; task.wait(6); break
                    end
                end
            end
            if not found then
                setStatus(string.format("Procurando zona... (%d)", attempts), DR_Accent)
                task.wait(1.5)
            end
            if attempts > 20 then
                pcall(function() partyRemote:FireServer({maxPlayers=1}) end)
                task.wait(3)
                pcall(function() TeleportService:Teleport(GAME, LocalPlayer) end)
                task.wait(10); break
            end
        end
    end

    task.spawn(function()
        while Alive and MainGui.Parent do
            task.wait(50)
            if Settings.antiAfk then
                pcall(function()
                    VirtualUser:Button1Down(Vector2.zero, workspace.CurrentCamera.CFrame)
                    task.wait(0.1)
                    VirtualUser:Button1Up(Vector2.zero, workspace.CurrentCamera.CFrame)
                end)
            end
        end
    end)

    task.spawn(function()
        while Alive and MainGui.Parent do
            task.wait(0.5)
            local el = math.floor(tick()-G.t0)
            setDetail("time", string.format("%dm %02ds", math.floor(el/60), el%60))
            local pid = game.PlaceId
            setDetail("loc", pid == LOBBY and "Lobby" or pid == GAME and "Partida" or "Outro")
            updateStats()
        end
    end)

    return {
        doBondsRun = doBondsRun,
        doWinRun = doWinRun,
        lobby_createParty = lobby_createParty,
        LOBBY = LOBBY,
        GAME = GAME,
    }
end

local function loadGameUI()
    local hub = createMainHub()
    local farmPage = createTab(hub, "Farm", Icons.Home)
    local statsPage = createTab(hub, "Stats", Icons.Sparkles)
    local settingsPage = createTab(hub, "Config", Icons.Settings)

    local DR = nil

    local farmSection = createSection(farmPage, "Auto Farm", "Selecione o modo e inicie o farm automático.")

    local statusCard = create("Frame", {
        Size=UDim2.new(1,0,0,54), BackgroundColor3=Theme.Background3, Parent=farmSection
    })
    corner(statusCard, 16)
    stroke(statusCard, Theme.Stroke, 1)

    statusDotRef = create("Frame", {
        Size=UDim2.new(0,10,0,10), Position=UDim2.new(0,14,0.5,-5),
        BackgroundColor3=Theme.Text3, BorderSizePixel=0, Parent=statusCard
    })
    corner(statusDotRef, 999)

    statusLabelRef = create("TextLabel", {
        Size=UDim2.new(1,-42,1,0), Position=UDim2.new(0,32,0,0),
        BackgroundTransparency=1, Text="Selecione um modo para iniciar",
        Font=Enum.Font.GothamBold, TextSize=13, TextColor3=Theme.Text2,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=statusCard
    })

    local modeSection = createSection(farmPage, "Modo de Operação", "")

    local modeColors = {
        bonds = Theme.Warning,
        win = Theme.Success,
        both = DR_Accent,
    }
    local modeNames = {bonds="Auto Bonds", win="Auto Win", both="Win + Bonds"}
    local activeCards = {}

    local function modeCard(id, title, desc)
        local accent = modeColors[id]
        local card = create("Frame", {
            Size=UDim2.new(1,0,0,62), BackgroundColor3=Theme.Background3, Parent=modeSection
        })
        corner(card, 16)
        local cardStroke = stroke(card, Theme.Stroke, 1)

        local indicator = create("Frame", {
            Size=UDim2.new(0,4,0.6,0), Position=UDim2.new(0,0,0.2,0),
            BackgroundColor3=accent, BorderSizePixel=0, Parent=card
        })
        corner(indicator, 999)

        create("TextLabel", {
            BackgroundTransparency=1, Position=UDim2.new(0,18,0,12),
            Size=UDim2.new(1,-60,0,20), Text=title,
            Font=Enum.Font.GothamBold, TextSize=14, TextColor3=Theme.Text,
            TextXAlignment=Enum.TextXAlignment.Left, Parent=card
        })

        create("TextLabel", {
            BackgroundTransparency=1, Position=UDim2.new(0,18,0,34),
            Size=UDim2.new(1,-60,0,16), Text=desc,
            Font=Enum.Font.Gotham, TextSize=11, TextColor3=Theme.Text3,
            TextXAlignment=Enum.TextXAlignment.Left, Parent=card
        })

        local selectDot = create("Frame", {
            Size=UDim2.new(0,12,0,12), Position=UDim2.new(1,-24,0.5,-6),
            BackgroundColor3=Theme.Card, BorderSizePixel=0, Parent=card
        })
        corner(selectDot, 999)

        local hit = create("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", Parent=card})

        hit.MouseEnter:Connect(function()
            if G.mode ~= id then tween(card, 0.15, {BackgroundColor3=Theme.Card}) end
        end)
        hit.MouseLeave:Connect(function()
            if G.mode ~= id then tween(card, 0.15, {BackgroundColor3=Theme.Background3}) end
        end)

        hit.MouseButton1Click:Connect(function()
            G.mode = id
            for _, d in ipairs(activeCards) do
                tween(d.card, 0.2, {BackgroundColor3=Theme.Background3})
                tween(d.stroke, 0.2, {Color=Theme.Stroke})
                tween(d.dot, 0.2, {BackgroundColor3=Theme.Card})
            end
            tween(card, 0.2, {BackgroundColor3=Theme.Card})
            tween(cardStroke, 0.2, {Color=accent})
            tween(selectDot, 0.2, {BackgroundColor3=accent})
            setStatus("Modo: "..title, accent)
        end)

        table.insert(activeCards, {card=card, stroke=cardStroke, dot=selectDot})
    end

    modeCard("bonds", "AUTO BONDS", "Voa pelos trilhos e farm estruturas")
    modeCard("win", "AUTO WIN", "Percorre 80km e ativa alavanca")
    modeCard("both", "WIN + BONDS", "Coleta bonds durante a viagem + vitória")

    local btnSection = createSection(farmPage, "Controles", "")

    local startBtn = createButton(btnSection, "▶  INICIAR FARM", nil, DR_Accent)
    local stopBtn = createButton(btnSection, "■  PARAR", nil, Theme.Error)

    startBtn.MouseEnter:Connect(function() tween(startBtn, 0.16, {BackgroundColor3=DR_Accent2}) end)
    startBtn.MouseLeave:Connect(function() tween(startBtn, 0.16, {BackgroundColor3=DR_Accent}) end)
    stopBtn.MouseEnter:Connect(function() tween(stopBtn, 0.16, {BackgroundColor3=Color3.fromRGB(200,50,50)}) end)
    stopBtn.MouseLeave:Connect(function() tween(stopBtn, 0.16, {BackgroundColor3=Theme.Error}) end)

    startBtn.MouseButton1Click:Connect(function()
        if G.running then return end
        if not G.mode then
            setStatus("Selecione um modo primeiro!", Theme.Error)
            notify("Atenção", "Selecione um modo antes de iniciar.", "error")
            return
        end

        if not DR then
            setStatus("Iniciando módulo Dead Rails...", DR_Accent)
            DR = loadDeadRailsScript()
        end

        G.running = true
        G.t0 = tick()
        setDetail("mode", modeNames[G.mode] or G.mode)

        task.spawn(function()
            while G.running do
                local ok, err = pcall(function()
                    local pid = game.PlaceId
                    if pid == DR.LOBBY then
                        DR.lobby_createParty()
                    elseif pid == DR.GAME then
                        if G.mode == "bonds" then DR.doBondsRun()
                        elseif G.mode == "win" then DR.doWinRun(true)
                        elseif G.mode == "both" then DR.doWinRun(false) end
                    else
                        setStatus("Execute no lobby ou na partida!", Theme.Error)
                        task.wait(3)
                    end
                end)
                if not ok then
                    setStatus("Erro: "..tostring(err):sub(1,55), Theme.Error)
                    task.wait(3)
                end
                if G.running then task.wait(2) end
            end
        end)
    end)

    stopBtn.MouseButton1Click:Connect(function()
        G.running = false
        G.mode = nil
        for _, d in ipairs(activeCards) do
            tween(d.card, 0.2, {BackgroundColor3=Theme.Background3})
            tween(d.stroke, 0.2, {Color=Theme.Stroke})
            tween(d.dot, 0.2, {BackgroundColor3=Theme.Card})
        end
        setStatus("Parado pelo usuário.", Theme.Text3)
        setDetail("loc", "—")
        setDetail("mode", "—")
        notify("Farm parado", "Auto farm interrompido.", "warning")
    end)

    local statsSection = createSection(statsPage, "Estatísticas", "Progresso da sessão atual.")

    local statCards = {
        {label="BONDS", key="bonds", color=Theme.Warning},
        {label="WINS", key="wins", color=Theme.Success},
        {label="RUNS", key="runs", color=DR_Accent},
    }

    local statFrame = create("Frame", {Size=UDim2.new(1,0,0,80), BackgroundTransparency=1, Parent=statsSection})
    create("UIGridLayout", {CellSize=UDim2.new(0.31,-4,1,0), CellPadding=UDim2.new(0,8,0,0), Parent=statFrame})

    for _, stat in ipairs(statCards) do
        local card = create("Frame", {BackgroundColor3=Theme.Background3, BorderSizePixel=0, Parent=statFrame})
        corner(card, 14)
        stroke(card, Theme.Stroke, 1)

        local topBar = create("Frame", {Size=UDim2.new(1,0,0,3), BackgroundColor3=stat.color, BorderSizePixel=0, Parent=card})
        corner(topBar, 14)

        local valLbl = create("TextLabel", {
            Size=UDim2.new(1,0,0,34), Position=UDim2.new(0,0,0,10),
            BackgroundTransparency=1, Text="0", Font=Enum.Font.GothamBlack,
            TextSize=24, TextColor3=stat.color, Parent=card
        })

        create("TextLabel", {
            Size=UDim2.new(1,0,0,16), Position=UDim2.new(0,0,0,48),
            BackgroundTransparency=1, Text=stat.label, Font=Enum.Font.GothamBold,
            TextSize=10, TextColor3=Theme.Text3, Parent=card
        })

        if stat.key == "bonds" then bondsLabelRef = valLbl
        elseif stat.key == "wins" then winsLabelRef = valLbl
        elseif stat.key == "runs" then runsLabelRef = valLbl end
    end

    local sessionSection = createSection(statsPage, "Sessão", "")

    local function makeDetailRow(parent, label)
        local row = create("Frame", {Size=UDim2.new(1,0,0,32), BackgroundTransparency=1, Parent=parent})
        create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(0,80,1,0), Text=label, Font=Enum.Font.GothamBold, TextSize=11, TextColor3=Theme.Text3, TextXAlignment=Enum.TextXAlignment.Left, Parent=row})
        local val = create("TextLabel", {BackgroundTransparency=1, Position=UDim2.new(0,86,0,0), Size=UDim2.new(1,-90,1,0), Text="—", Font=Enum.Font.Gotham, TextSize=11, TextColor3=Theme.Text2, TextXAlignment=Enum.TextXAlignment.Left, Parent=row})
        return val
    end

    timeLabelRef = makeDetailRow(sessionSection, "Tempo:")
    locLabelRef = makeDetailRow(sessionSection, "Local:")
    modeLabelRef = makeDetailRow(sessionSection, "Modo:")

    local logSection = createSection(statsPage, "Log de Atividade", "")

    local logScroll = create("ScrollingFrame", {
        Size=UDim2.new(1,0,0,180), BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=3, ScrollBarImageColor3=DR_Accent,
        CanvasSize=UDim2.new(0,0,0,0), Parent=logSection
    })
    logListRef = logScroll

    local configSection = createSection(settingsPage, "Configurações", "Personalize o comportamento do auto farm.")

    createToggle(configSection, "Anti AFK", Settings.antiAfk, function(v) Settings.antiAfk = v end)
    createToggle(configSection, "Auto Coletar Bonds", Settings.autoCollect, function(v) Settings.autoCollect = v end)
    createToggle(configSection, "Modo Rápido", Settings.fastMode, function(v) Settings.fastMode = v end)

    local infoSection = createSection(settingsPage, "Sobre", "Dead Rails • Lost Hub")
    createInfoCard(infoSection, "Jogo", "Dead Rails", Icons.Game)
    createInfoCard(infoSection, "Versão", "Lost Hub • DR Edition", Icons.Sparkles)
    createInfoCard(infoSection, "Jogador", LocalPlayer.DisplayName, Icons.User)

    notify("Dead Rails", "Auto farm carregado e pronto!", "success")
    setStatus("Pronto! Selecione um modo para iniciar.", Theme.Text3)
    setDetail("time", "0m 00s")
    setDetail("loc", "—")
    setDetail("mode", "—")
end

showLoadingScreen()
task.wait(0.2)
showKeySystem(function()
    if CurrentGame.Script == "DeadRails" then
        loadGameUI()
    else
        local hub = createMainHub()
        local home = createTab(hub, "Início", Icons.Home)
        local s = createSection(home, "Jogo não suportado", "")
        createLabel(s, "Este script é exclusivo para Dead Rails.")
        createLabel(s, "Jogo detectado: "..(CurrentGame.Name or "Desconhecido"))
        notify("Atenção", "Jogo não suportado por este script.", "error")
    end
end)
