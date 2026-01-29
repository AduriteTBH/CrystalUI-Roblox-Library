--[[
    CrystalUI - A Glass Morphism UI Library for Roblox
    Inspired by ObsidianUI's architecture with modern glass aesthetics
    
    Features:
    - Glass morphism with blur effects
    - Smooth TweenService animations
    - Full customization/theming
    - Window → Tab → Groupbox → Element hierarchy
    - Callbacks with :OnChanged pattern
    - Notifications, Tooltips, Keybinds
    
    Usage:
    local Library = loadstring(...)()
    local Window = Library:CreateWindow({ Title = "My UI" })
    local Tab = Window:AddTab("Main", "home")
    local Group = Tab:AddLeftGroupbox("Settings")
    Group:AddToggle("MyToggle", { Text = "Enable Feature" })
]]

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Library Setup
local Library = {
    -- State
    Toggled = true,
    Windows = {},
    
    -- Element References
    Options = {},
    Toggles = {},
    
    -- Settings
    ToggleKeybind = Enum.KeyCode.RightControl,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 8,
    AnimationSpeed = 0.25,
    
    -- Mobile Detection
    IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled,
    
    -- Theme
    Scheme = {
        -- Main Colors
        Background = Color3.fromRGB(15, 15, 20),
        Surface = Color3.fromRGB(25, 25, 35),
        SurfaceLight = Color3.fromRGB(35, 35, 50),
        
        -- Glass Effect Colors
        GlassBackground = Color3.fromRGB(30, 30, 45),
        GlassBorder = Color3.fromRGB(60, 60, 80),
        GlassHighlight = Color3.fromRGB(255, 255, 255),
        
        -- Accent Colors
        Accent = Color3.fromRGB(100, 140, 255),
        AccentDark = Color3.fromRGB(70, 100, 200),
        AccentLight = Color3.fromRGB(130, 170, 255),
        
        -- Text Colors
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 200),
        TextMuted = Color3.fromRGB(120, 120, 140),
        
        -- Status Colors
        Success = Color3.fromRGB(100, 200, 120),
        Warning = Color3.fromRGB(255, 180, 80),
        Error = Color3.fromRGB(255, 100, 100),
        
        -- Effects
        Shadow = Color3.fromRGB(0, 0, 0),
        GlowColor = Color3.fromRGB(100, 140, 255),
        
        -- Transparency
        GlassTransparency = 0.15,
        BorderTransparency = 0.5,
    },
    
    -- Fonts
    Font = {
        Regular = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular),
        Medium = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
        Bold = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
    }
}

-- Utility Functions
local function Create(instanceType, properties, children)
    local instance = Instance.new(instanceType)
    
    for prop, value in pairs(properties or {}) do
        if prop ~= "Parent" then
            instance[prop] = value
        end
    end
    
    for _, child in ipairs(children or {}) do
        child.Parent = instance
    end
    
    if properties and properties.Parent then
        instance.Parent = properties.Parent
    end
    
    return instance
end

local function Tween(instance, properties, duration, easingStyle, easingDirection)
    duration = duration or Library.AnimationSpeed
    easingStyle = easingStyle or Enum.EasingStyle.Quint
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration, easingStyle, easingDirection),
        properties
    )
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or Library.CornerRadius),
        Parent = parent
    })
end

local function AddStroke(parent, color, thickness, transparency)
    return Create("UIStroke", {
        Color = color or Library.Scheme.GlassBorder,
        Thickness = thickness or 1,
        Transparency = transparency or Library.Scheme.BorderTransparency,
        Parent = parent
    })
end

local function AddPadding(parent, padding)
    padding = padding or 8
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, padding),
        PaddingBottom = UDim.new(0, padding),
        PaddingLeft = UDim.new(0, padding),
        PaddingRight = UDim.new(0, padding),
        Parent = parent
    })
end

local function AddShadow(parent, transparency)
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 4),
        Size = UDim2.new(1, 24, 1, 24),
        ZIndex = parent.ZIndex - 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Library.Scheme.Shadow,
        ImageTransparency = transparency or 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = parent
    })
    return shadow
end

local function AddGradient(parent, rotation, colors)
    rotation = rotation or 90
    colors = colors or {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
    }
    
    return Create("UIGradient", {
        Rotation = rotation,
        Color = ColorSequence.new(colors),
        Parent = parent
    })
end

-- Create glass-like blur effect using layered frames
local function CreateGlassEffect(parent)
    -- Base blur layer
    local blurLayer = Create("Frame", {
        Name = "BlurLayer",
        BackgroundColor3 = Library.Scheme.GlassBackground,
        BackgroundTransparency = Library.Scheme.GlassTransparency,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = parent.ZIndex,
        Parent = parent
    })
    AddCorner(blurLayer)
    
    -- Highlight layer (top edge glow)
    local highlight = Create("Frame", {
        Name = "Highlight",
        BackgroundColor3 = Library.Scheme.GlassHighlight,
        BackgroundTransparency = 0.9,
        Size = UDim2.new(1, -2, 0, 1),
        Position = UDim2.new(0, 1, 0, 1),
        ZIndex = parent.ZIndex + 1,
        Parent = parent
    })
    
    -- Inner shadow
    local innerShadow = Create("Frame", {
        Name = "InnerShadow",
        BackgroundColor3 = Library.Scheme.Shadow,
        BackgroundTransparency = 0.95,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = parent.ZIndex + 1,
        Parent = parent
    })
    AddCorner(innerShadow)
    AddGradient(innerShadow, 90, {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(0.1, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    
    return blurLayer
end

-- Generate unique ID
local function GenerateId()
    return HttpService:GenerateGUID(false)
end

-- Deep copy table
local function DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

--[[ ============================================
    NOTIFICATION SYSTEM
============================================ ]]--

local NotificationHolder

function Library:Notify(options, duration)
    -- Handle simple string notification
    if type(options) == "string" then
        options = {
            Title = "Notification",
            Description = options,
            Time = duration or 5
        }
    end
    
    options.Title = options.Title or "Notification"
    options.Description = options.Description or ""
    options.Time = options.Time or 5
    
    -- Create holder if needed
    if not NotificationHolder then
        NotificationHolder = Create("Frame", {
            Name = "CrystalUI_Notifications",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 300, 1, -20),
            Position = Library.NotifySide == "Right" 
                and UDim2.new(1, -310, 0, 10) 
                or UDim2.new(0, 10, 0, 10),
            Parent = Library.ScreenGui
        })
        
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Parent = NotificationHolder
        })
    end
    
    -- Create notification
    local notif = Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = Library.Scheme.Surface,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        Parent = NotificationHolder
    })
    AddCorner(notif)
    AddStroke(notif)
    AddShadow(notif)
    CreateGlassEffect(notif)
    
    local content = Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 5,
        Parent = notif
    })
    AddPadding(content, 12)
    
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = content
    })
    
    -- Accent bar
    Create("Frame", {
        Name = "AccentBar",
        BackgroundColor3 = Library.Scheme.Accent,
        Size = UDim2.new(0, 3, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        ZIndex = 6,
        Parent = notif
    })
    
    -- Title
    Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        FontFace = Library.Font.Bold,
        Text = options.Title,
        TextColor3 = Library.Scheme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
        LayoutOrder = 1,
        Parent = content
    })
    
    -- Description
    Create("TextLabel", {
        Name = "Description",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        FontFace = Library.Font.Regular,
        Text = options.Description,
        TextColor3 = Library.Scheme.TextSecondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 6,
        LayoutOrder = 2,
        Parent = content
    })
    
    -- Progress bar
    local progressBg = Create("Frame", {
        Name = "ProgressBg",
        BackgroundColor3 = Library.Scheme.SurfaceLight,
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 1, -3),
        ZIndex = 6,
        Parent = notif
    })
    
    local progress = Create("Frame", {
        Name = "Progress",
        BackgroundColor3 = Library.Scheme.Accent,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 7,
        Parent = progressBg
    })
    AddCorner(progress, 2)
    
    -- Animate in
    notif.Size = UDim2.new(1, 0, 0, 0)
    notif.BackgroundTransparency = 1
    
    task.spawn(function()
        task.wait(0.05)
        Tween(notif, {BackgroundTransparency = 0}, 0.3)
        Tween(progress, {Size = UDim2.new(0, 0, 1, 0)}, options.Time, Enum.EasingStyle.Linear)
        
        task.wait(options.Time)
        
        Tween(notif, {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0)}, 0.3)
        task.wait(0.35)
        notif:Destroy()
    end)
    
    -- Return notification object for manipulation
    local NotifObject = {}
    
    function NotifObject:ChangeTitle(text)
        local title = content:FindFirstChild("Title")
        if title then title.Text = text end
    end
    
    function NotifObject:ChangeDescription(text)
        local desc = content:FindFirstChild("Description")
        if desc then desc.Text = text end
    end
    
    function NotifObject:Destroy()
        Tween(notif, {BackgroundTransparency = 1}, 0.2)
        task.wait(0.25)
        notif:Destroy()
    end
    
    return NotifObject
end

--[[ ============================================
    TOOLTIP SYSTEM
============================================ ]]--

local TooltipFrame

function Library:AddTooltip(element, text, disabledText)
    if not text then return end
    
    -- Create tooltip frame if needed
    if not TooltipFrame then
        TooltipFrame = Create("Frame", {
            Name = "Tooltip",
            BackgroundColor3 = Library.Scheme.Surface,
            Size = UDim2.new(0, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.XY,
            Visible = false,
            ZIndex = 1000,
            Parent = Library.ScreenGui
        })
        AddCorner(TooltipFrame, 6)
        AddStroke(TooltipFrame)
        AddShadow(TooltipFrame, 0.7)
        
        local padding = AddPadding(TooltipFrame, 8)
        
        Create("TextLabel", {
            Name = "Text",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.XY,
            FontFace = Library.Font.Regular,
            Text = "",
            TextColor3 = Library.Scheme.TextPrimary,
            TextSize = 12,
            ZIndex = 1001,
            Parent = TooltipFrame
        })
    end
    
    local showTooltip = false
    
    element.MouseEnter:Connect(function()
        showTooltip = true
        local displayText = element:FindFirstChild("Disabled") and element.Disabled.Value and disabledText or text
        if not displayText then return end
        
        TooltipFrame.Text.Text = displayText
        TooltipFrame.Visible = true
        TooltipFrame.BackgroundTransparency = 1
        Tween(TooltipFrame, {BackgroundTransparency = 0}, 0.15)
    end)
    
    element.MouseLeave:Connect(function()
        showTooltip = false
        Tween(TooltipFrame, {BackgroundTransparency = 1}, 0.15)
        task.wait(0.15)
        if not showTooltip then
            TooltipFrame.Visible = false
        end
    end)
    
    element.MouseMoved:Connect(function(x, y)
        if TooltipFrame.Visible then
            TooltipFrame.Position = UDim2.new(0, x + 15, 0, y + 10)
        end
    end)
end

--[[ ============================================
    WINDOW
============================================ ]]--

function Library:CreateWindow(options)
    options = options or {}
    options.Title = options.Title or "CrystalUI"
    options.Footer = options.Footer or ""
    options.Size = options.Size or UDim2.fromOffset(680, 520)
    options.Position = options.Position or UDim2.fromOffset(100, 100)
    options.Center = options.Center ~= false
    options.AutoShow = options.AutoShow ~= false
    options.ToggleKeybind = options.ToggleKeybind or Enum.KeyCode.RightControl
    options.Resizable = options.Resizable ~= false
    
    Library.ToggleKeybind = options.ToggleKeybind
    
    -- Create ScreenGui
    local screenGui = Create("ScreenGui", {
        Name = "CrystalUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999
    })
    
    -- Try to parent to CoreGui, fallback to PlayerGui
    local success = pcall(function()
        screenGui.Parent = CoreGui
    end)
    if not success then
        screenGui.Parent = Player:WaitForChild("PlayerGui")
    end
    
    Library.ScreenGui = screenGui
    
    -- Main Window Frame
    local window = Create("Frame", {
        Name = "Window",
        BackgroundColor3 = Library.Scheme.Background,
        Size = options.Size,
        Position = options.Center 
            and UDim2.new(0.5, -options.Size.X.Offset/2, 0.5, -options.Size.Y.Offset/2)
            or options.Position,
        ClipsDescendants = true,
        Visible = options.AutoShow,
        Parent = screenGui
    })
    AddCorner(window, 12)
    AddStroke(window, Library.Scheme.GlassBorder, 1)
    AddShadow(window, 0.4)
    
    Library.Toggled = options.AutoShow
    
    -- Title Bar
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = Library.Scheme.Surface,
        Size = UDim2.new(1, 0, 0, 40),
        ZIndex = 2,
        Parent = window
    })
    AddCorner(titleBar, 12)
    
    -- Fix bottom corners of title bar
    Create("Frame", {
        Name = "BottomFix",
        BackgroundColor3 = Library.Scheme.Surface,
        Size = UDim2.new(1, 0, 0, 15),
        Position = UDim2.new(0, 0, 1, -15),
        ZIndex = 2,
        BorderSizePixel = 0,
        Parent = titleBar
    })
    
    -- Title Text
    Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        FontFace = Library.Font.Bold,
        Text = options.Title,
        TextColor3 = Library.Scheme.TextPrimary,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = titleBar
    })
    
    -- Close Button
    local closeBtn = Create("TextButton", {
        Name = "Close",
        BackgroundColor3 = Library.Scheme.Error,
        BackgroundTransparency = 0.8,
        Position = UDim2.new(1, -35, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Text = "×",
        FontFace = Library.Font.Bold,
        TextColor3 = Library.Scheme.TextPrimary,
        TextSize = 18,
        ZIndex = 3,
        Parent = titleBar
    })
    AddCorner(closeBtn, 6)
    
    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, {BackgroundTransparency = 0.4}, 0.15)
    end)
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, {BackgroundTransparency = 0.8}, 0.15)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        Library:Toggle(false)
    end)
    
    -- Minimize Button
    local minimizeBtn = Create("TextButton", {
        Name = "Minimize",
        BackgroundColor3 = Library.Scheme.Warning,
        BackgroundTransparency = 0.8,
        Position = UDim2.new(1, -60, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Text = "−",
        FontFace = Library.Font.Bold,
        TextColor3 = Library.Scheme.TextPrimary,
        TextSize = 18,
        ZIndex = 3,
        Parent = titleBar
    })
    AddCorner(minimizeBtn, 6)
    
    minimizeBtn.MouseEnter:Connect(function()
        Tween(minimizeBtn, {BackgroundTransparency = 0.4}, 0.15)
    end)
    minimizeBtn.MouseLeave:Connect(function()
        Tween(minimizeBtn, {BackgroundTransparency = 0.8}, 0.15)
    end)
    
    -- Tab Container (Left side)
    local tabContainer = Create("Frame", {
        Name = "TabContainer",
        BackgroundColor3 = Library.Scheme.Surface,
        BackgroundTransparency = 0.5,
        Position = UDim2.new(0, 8, 0, 48),
        Size = UDim2.new(0, 140, 1, -56),
        ZIndex = 2,
        Parent = window
    })
    AddCorner(tabContainer)
    AddStroke(tabContainer, nil, 1, 0.7)
    
    local tabList = Create("ScrollingFrame", {
        Name = "TabList",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Library.Scheme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 3,
        Parent = tabContainer
    })
    AddPadding(tabList, 6)
    
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = tabList
    })
    
    -- Content Container (Right side)
    local contentContainer = Create("Frame", {
        Name = "ContentContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 156, 0, 48),
        Size = UDim2.new(1, -164, 1, -56),
        ClipsDescendants = true,
        ZIndex = 2,
        Parent = window
    })
    
    -- Footer
    if options.Footer ~= "" then
        local footer = Create("TextLabel", {
            Name = "Footer",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 1, -25),
            Size = UDim2.new(1, -30, 0, 20),
            FontFace = Library.Font.Regular,
            Text = options.Footer,
            TextColor3 = Library.Scheme.TextMuted,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 3,
            Parent = window
        })
    end
    
    -- Dragging
    local dragging, dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Toggle Keybind
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Library.ToggleKeybind then
            Library:Toggle()
        end
    end)
    
    -- Window Object
    local Window = {
        Frame = window,
        Tabs = {},
        ActiveTab = nil
    }
    
    -- Minimize functionality
    local minimized = false
    local originalSize = options.Size
    
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(window, {Size = UDim2.new(0, originalSize.X.Offset, 0, 40)}, 0.25)
            contentContainer.Visible = false
            tabContainer.Visible = false
        else
            Tween(window, {Size = originalSize}, 0.25)
            task.wait(0.15)
            contentContainer.Visible = true
            tabContainer.Visible = true
        end
    end)
    
    --[[ ============================================
        TAB
    ============================================ ]]--
    
    function Window:AddTab(name, icon)
        local tabIndex = #self.Tabs + 1
        
        -- Tab Button
        local tabBtn = Create("TextButton", {
            Name = "Tab_" .. name,
            BackgroundColor3 = Library.Scheme.Accent,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 36),
            Text = "",
            ZIndex = 4,
            LayoutOrder = tabIndex,
            Parent = tabList
        })
        AddCorner(tabBtn, 8)
        
        -- Tab Icon (using text for now, can be replaced with ImageLabel)
        local iconLabel = Create("TextLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            FontFace = Library.Font.Medium,
            Text = icon and "●" or "",
            TextColor3 = Library.Scheme.TextSecondary,
            TextSize = 12,
            ZIndex = 5,
            Parent = tabBtn
        })
        
        -- Tab Name
        local nameLabel = Create("TextLabel", {
            Name = "Name",
            BackgroundTransparency = 1,
            Position = icon and UDim2.new(0, 32, 0, 0) or UDim2.new(0, 12, 0, 0),
            Size = icon and UDim2.new(1, -42, 1, 0) or UDim2.new(1, -24, 1, 0),
            FontFace = Library.Font.Medium,
            Text = name,
            TextColor3 = Library.Scheme.TextSecondary,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
            Parent = tabBtn
        })
        
        -- Tab Content
        local tabContent = Create("ScrollingFrame", {
            Name = "Content_" .. name,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Library.Scheme.Accent,
            Visible = tabIndex == 1,
            ZIndex = 3,
            Parent = contentContainer
        })
        AddPadding(tabContent, 4)
        
        -- Two column layout
        local columns = Create("Frame", {
            Name = "Columns",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = tabContent
        })
        
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = columns
        })
        
        local leftColumn = Create("Frame", {
            Name = "Left",
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -4, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            Parent = columns
        })
        
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = leftColumn
        })
        
        local rightColumn = Create("Frame", {
            Name = "Right",
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -4, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 2,
            Parent = columns
        })
        
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = rightColumn
        })
        
        -- Tab Object
        local Tab = {
            Button = tabBtn,
            Content = tabContent,
            LeftColumn = leftColumn,
            RightColumn = rightColumn,
            Name = name,
            Index = tabIndex
        }
        
        -- Tab Selection
        local function selectTab()
            for _, t in ipairs(Window.Tabs) do
                t.Content.Visible = false
                Tween(t.Button, {BackgroundTransparency = 1}, 0.15)
                t.Button.Name.TextColor3 = Library.Scheme.TextSecondary
            end
            
            Tab.Content.Visible = true
            Tween(tabBtn, {BackgroundTransparency = 0.85}, 0.15)
            nameLabel.TextColor3 = Library.Scheme.TextPrimary
            iconLabel.TextColor3 = Library.Scheme.Accent
            Window.ActiveTab = Tab
        end
        
        tabBtn.MouseButton1Click:Connect(selectTab)
        
        tabBtn.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(tabBtn, {BackgroundTransparency = 0.9}, 0.1)
            end
        end)
        
        tabBtn.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(tabBtn, {BackgroundTransparency = 1}, 0.1)
            end
        end)
        
        -- Select first tab by default
        if tabIndex == 1 then
            selectTab()
        end
        
        --[[ ============================================
            GROUPBOX
        ============================================ ]]--
        
        local function CreateGroupbox(name, parent)
            local groupbox = Create("Frame", {
                Name = "Groupbox_" .. name,
                BackgroundColor3 = Library.Scheme.Surface,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = 4,
                Parent = parent
            })
            AddCorner(groupbox)
            AddStroke(groupbox, nil, 1, 0.7)
            CreateGlassEffect(groupbox)
            
            -- Title
            local title = Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -24, 0, 32),
                FontFace = Library.Font.Bold,
                Text = name,
                TextColor3 = Library.Scheme.TextPrimary,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 6,
                Parent = groupbox
            })
            
            -- Divider under title
            Create("Frame", {
                Name = "Divider",
                BackgroundColor3 = Library.Scheme.GlassBorder,
                BackgroundTransparency = 0.5,
                Position = UDim2.new(0, 8, 0, 32),
                Size = UDim2.new(1, -16, 0, 1),
                ZIndex = 6,
                Parent = groupbox
            })
            
            -- Content
            local content = Create("Frame", {
                Name = "Content",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 40),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = 5,
                Parent = groupbox
            })
            AddPadding(content, 8)
            
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6),
                Parent = content
            })
            
            local Groupbox = {
                Frame = groupbox,
                Content = content,
                ElementCount = 0
            }
            
            -- Add elements to groupbox
            function Groupbox:AddLabel(options)
                if type(options) == "string" then
                    options = { Text = options }
                end
                options.Text = options.Text or "Label"
                options.DoesWrap = options.DoesWrap or false
                
                self.ElementCount = self.ElementCount + 1
                
                local label = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    FontFace = Library.Font.Regular,
                    Text = options.Text,
                    TextColor3 = Library.Scheme.TextSecondary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = options.DoesWrap,
                    ZIndex = 6,
                    LayoutOrder = self.ElementCount,
                    Parent = self.Content
                })
                
                local LabelObject = {}
                
                function LabelObject:SetText(text)
                    label.Text = text
                end
                
                function LabelObject:SetVisible(visible)
                    label.Visible = visible
                end
                
                return LabelObject
            end
            
            function Groupbox:AddDivider()
                self.ElementCount = self.ElementCount + 1
                
                Create("Frame", {
                    Name = "Divider",
                    BackgroundColor3 = Library.Scheme.GlassBorder,
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, 0, 0, 1),
                    ZIndex = 6,
                    LayoutOrder = self.ElementCount,
                    Parent = self.Content
                })
            end
            
            function Groupbox:AddButton(options)
                options = options or {}
                options.Text = options.Text or "Button"
                options.Func = options.Func or function() end
                options.DoubleClick = options.DoubleClick or false
                options.Disabled = options.Disabled or false
                options.Risky = options.Risky or false
                
                self.ElementCount = self.ElementCount + 1
                
                local btn = Create("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = options.Risky and Library.Scheme.Error or Library.Scheme.SurfaceLight,
                    BackgroundTransparency = options.Risky and 0.7 or 0,
                    Size = UDim2.new(1, 0, 0, 32),
                    Text = "",
                    ZIndex = 6,
                    LayoutOrder = self.ElementCount,
                    Parent = self.Content
                })
                AddCorner(btn, 6)
                AddStroke(btn, nil, 1, 0.8)
                
                local btnText = Create("TextLabel", {
                    Name = "Text",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    FontFace = Library.Font.Medium,
                    Text = options.Text,
                    TextColor3 = options.Disabled and Library.Scheme.TextMuted or Library.Scheme.TextPrimary,
                    TextSize = 13,
                    ZIndex = 7,
                    Parent = btn
                })
                
                if options.Tooltip then
                    Library:AddTooltip(btn, options.Tooltip, options.DisabledTooltip)
                end
                
                local lastClick = 0
                local disabled = options.Disabled
                
                btn.MouseEnter:Connect(function()
                    if not disabled then
                        Tween(btn, {BackgroundTransparency = 0.3}, 0.1)
                    end
                end)
                
                btn.MouseLeave:Connect(function()
                    Tween(btn, {BackgroundTransparency = options.Risky and 0.7 or 0}, 0.1)
                end)
                
                btn.MouseButton1Click:Connect(function()
                    if disabled then return end
                    
                    if options.DoubleClick then
                        local now = tick()
                        if now - lastClick < 0.4 then
                            options.Func()
                            lastClick = 0
                        else
                            lastClick = now
                        end
                    else
                        options.Func()
                    end
                    
                    -- Click animation
                    Tween(btn, {BackgroundTransparency = 0.5}, 0.05)
                    task.wait(0.05)
                    Tween(btn, {BackgroundTransparency = options.Risky and 0.7 or 0}, 0.1)
                end)
                
                local ButtonObject = {
                    Button = btn
                }
                
                function ButtonObject:SetText(text)
                    btnText.Text = text
                end
                
                function ButtonObject:SetDisabled(state)
                    disabled = state
                    btnText.TextColor3 = state and Library.Scheme.TextMuted or Library.Scheme.TextPrimary
                end
                
                function ButtonObject:SetVisible(visible)
                    btn.Visible = visible
                end
                
                function ButtonObject:AddButton(subOptions)
                    -- Create sub-button next to main button
                    local container = btn.Parent
                    btn.Size = UDim2.new(0.5, -2, 0, 32)
                    
                    subOptions = subOptions or {}
                    subOptions.Text = subOptions.Text or "Sub Button"
                    subOptions.Func = subOptions.Func or function() end
                    
                    local subBtn = Create("TextButton", {
                        Name = "SubButton",
                        BackgroundColor3 = Library.Scheme.SurfaceLight,
                        Size = UDim2.new(0.5, -2, 0, 32),
                        Position = UDim2.new(0.5, 2, 0, 0),
                        Text = "",
                        ZIndex = 6,
                        LayoutOrder = btn.LayoutOrder,
                        Parent = container
                    })
                    AddCorner(subBtn, 6)
                    AddStroke(subBtn, nil, 1, 0.8)
                    
                    Create("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        FontFace = Library.Font.Medium,
                        Text = subOptions.Text,
                        TextColor3 = Library.Scheme.TextPrimary,
                        TextSize = 13,
                        ZIndex = 7,
                        Parent = subBtn
                    })
                    
                    subBtn.MouseEnter:Connect(function()
                        Tween(subBtn, {BackgroundTransparency = 0.3}, 0.1)
                    end)
                    subBtn.MouseLeave:Connect(function()
                        Tween(subBtn, {BackgroundTransparency = 0}, 0.1)
                    end)
                    subBtn.MouseButton1Click:Connect(function()
                        subOptions.Func()
                    end)
                    
                    return ButtonObject
                end
                
                return ButtonObject
            end
            
            function Groupbox:AddToggle(idx, options)
                options = options or {}
                options.Text = options.Text or "Toggle"
                options.Default = options.Default or false
                options.Callback = options.Callback or function() end
                options.Disabled = options.Disabled or false
                
                self.ElementCount = self.ElementCount + 1
                
                local container = Create("Frame", {
                    Name = "Toggle_" .. idx,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 28),
                    ZIndex = 6,
                    LayoutOrder = self.ElementCount,
                    Parent = self.Content
                })
                
                local label = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    FontFace = Library.Font.Regular,
                    Text = options.Text,
                    TextColor3 = options.Disabled and Library.Scheme.TextMuted or Library.Scheme.TextSecondary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 7,
                    Parent = container
                })
                
                -- Toggle switch
                local switchBg = Create("Frame", {
                    Name = "SwitchBg",
                    BackgroundColor3 = Library.Scheme.SurfaceLight,
                    Position = UDim2.new(1, -44, 0.5, -10),
                    Size = UDim2.new(0, 44, 0, 20),
                    ZIndex = 7,
                    Parent = container
                })
                AddCorner(switchBg, 10)
                AddStroke(switchBg, nil, 1, 0.8)
                
                local switchKnob = Create("Frame", {
                    Name = "Knob",
                    BackgroundColor3 = Library.Scheme.TextSecondary,
                    Position = UDim2.new(0, 3, 0.5, -7),
                    Size = UDim2.new(0, 14, 0, 14),
                    ZIndex = 8,
                    Parent = switchBg
                })
                AddCorner(switchKnob, 7)
                
                if options.Tooltip then
                    Library:AddTooltip(container, options.Tooltip, options.DisabledTooltip)
                end
                
                local state = options.Default
                local disabled = options.Disabled
                local callbacks = {options.Callback}
                
                local function updateVisual()
                    if state then
                        Tween(switchBg, {BackgroundColor3 = Library.Scheme.Accent}, 0.2)
                        Tween(switchKnob, {
                            Position = UDim2.new(1, -17, 0.5, -7),
                            BackgroundColor3 = Library.Scheme.TextPrimary
                        }, 0.2)
                    else
                        Tween(switchBg, {BackgroundColor3 = Library.Scheme.SurfaceLight}, 0.2)
                        Tween(switchKnob, {
                            Position = UDim2.new(0, 3, 0.5, -7),
                            BackgroundColor3 = Library.Scheme.TextSecondary
                        }, 0.2)
                    end
                end
                
                local function toggle()
                    if disabled then return end
                    state = not state
                    updateVisual()
                    for _, callback in ipairs(callbacks) do
                        task.spawn(callback, state)
                    end
                end
                
                -- Make clickable
                local clickBtn = Create("TextButton", {
                    Name = "Click",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 9,
                    Parent = container
                })
                
                clickBtn.MouseButton1Click:Connect(toggle)
                
                -- Initialize visual
                if state then
                    switchBg.BackgroundColor3 = Library.Scheme.Accent
                    switchKnob.Position = UDim2.new(1, -17, 0.5, -7)
                    switchKnob.BackgroundColor3 = Library.Scheme.TextPrimary
                end
                
                local Toggle = {
                    Value = state,
                    Container = container
                }
                
                function Toggle:SetValue(value)
                    if state ~= value then
                        state = value
                        self.Value = value
                        updateVisual()
                        for _, callback in ipairs(callbacks) do
                            task.spawn(callback, state)
                        end
                    end
                end
                
                function Toggle:GetValue()
                    return state
                end
                
                function Toggle:SetText(text)
                    label.Text = text
                end
                
                function Toggle:SetDisabled(value)
                    disabled = value
                    label.TextColor3 = value and Library.Scheme.TextMuted or Library.Scheme.TextSecondary
                end
                
                function Toggle:SetVisible(visible)
                    container.Visible = visible
                end
                
                function Toggle:OnChanged(callback)
                    table.insert(callbacks, callback)
                end
                
                function Toggle:AddKeyPicker(keyIdx, keyOptions)
                    return Groupbox:AddKeyPicker(keyIdx, keyOptions, Toggle)
                end
                
                function Toggle:AddColorPicker(colorIdx, colorOptions)
                    return Groupbox:AddColorPicker(colorIdx, colorOptions, container)
                end
                
                -- Register
                Library.Toggles[idx] = Toggle
                Library.Options[idx] = Toggle
                
                return Toggle
            end
            
            function Groupbox:AddCheckbox(idx, options)
                -- Same as toggle but with checkbox style
                return self:AddToggle(idx, options)
            end
            
            function Groupbox:AddSlider(idx, options)
                options = options or {}
                options.Text = options.Text or "Slider"
                options.Default = options.Default or 0
                options.Min = options.Min or 0
                options.Max = options.Max or 100
                options.Rounding = options.Rounding or 0
                options.Suffix = options.Suffix or ""
                options.Prefix = options.Prefix or ""
                options.Callback = options.Callback or function() end
                options.Disabled = options.Disabled or false
                
                self.ElementCount = self.ElementCount + 1
                
                local container = Create("Frame", {
                    Name = "Slider_" .. idx,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40),
                    ZIndex = 6,
                    LayoutOrder = self.ElementCount,
                    Parent = self.Content
                })
                
                -- Label and value
                local label = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(0.6, 0, 0, 20),
                    FontFace = Library.Font.Regular,
                    Text = options.Text,
                    TextColor3 = Library.Scheme.TextSecondary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 7,
                    Parent = container
                })
                
                local valueLabel = Create("TextLabel", {
                    Name = "Value",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.6, 0, 0, 0),
                    Size = UDim2.new(0.4, 0, 0, 20),
                    FontFace = Library.Font.Medium,
                    Text = options.Prefix .. tostring(options.Default) .. options.Suffix,
                    TextColor3 = Library.Scheme.TextPrimary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 7,
                    Parent = container
                })
                
                -- Slider track
                local track = Create("Frame", {
                    Name = "Track",
                    BackgroundColor3 = Library.Scheme.SurfaceLight,
                    Position = UDim2.new(0, 0, 0, 26),
                    Size = UDim2.new(1, 0, 0, 8),
                    ZIndex = 7,
                    Parent = container
                })
                AddCorner(track, 4)
                
                -- Slider fill
                local fill = Create("Frame", {
                    Name = "Fill",
                    BackgroundColor3 = Library.Scheme.Accent,
                    Size = UDim2.new(0, 0, 1, 0),
                    ZIndex = 8,
                    Parent = track
                })
                AddCorner(fill, 4)
                AddGradient(fill, 0, {
                    ColorSequenceKeypoint.new(0, Library.Scheme.AccentLight),
                    ColorSequenceKeypoint.new(1, Library.Scheme.Accent)
                })
                
                -- Slider knob
                local knob = Create("Frame", {
                    Name = "Knob",
                    BackgroundColor3 = Library.Scheme.TextPrimary,
                    Position = UDim2.new(0, -6, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12),
                    ZIndex = 9,
                    Parent = fill
                })
                AddCorner(knob, 6)
                AddStroke(knob, Library.Scheme.Accent, 2, 0)
                
                if options.Tooltip then
                    Library:AddTooltip(container, options.Tooltip, options.DisabledTooltip)
                end
                
                local value = options.Default
                local disabled = options.Disabled
                local dragging = false
                local callbacks = {options.Callback}
                
                local function round(num, decimals)
                    local mult = 10^(decimals or 0)
                    return math.floor(num * mult + 0.5) / mult
                end
                
                local function updateValue(newValue)
                    newValue = math.clamp(newValue, options.Min, options.Max)
                    newValue = round(newValue, options.Rounding)
                    
                    if value ~= newValue then
                        value = newValue
                        local percent = (value - options.Min) / (options.Max - options.Min)
                        
                        Tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                        valueLabel.Text = options.Prefix .. tostring(value) .. options.Suffix
                        
                        for _, callback in ipairs(callbacks) do
                            task.spawn(callback, value)
                        end
                    end
                end
                
                local function getValueFromPosition(x)
                    local trackPos = track.AbsolutePosition.X
                    local trackSize = track.AbsoluteSize.X
                    local percent = math.clamp((x - trackPos) / trackSize, 0, 1)
                    return options.Min + (options.Max - options.Min) * percent
                end
                
                -- Click/drag interaction
                local clickBtn = Create("TextButton", {
                    Name = "Click",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 20),
                    Size = UDim2.new(1, 0, 0, 20),
                    Text = "",
                    ZIndex = 10,
                    Parent = container
                })
                
                clickBtn.InputBegan:Connect(function(input)
                    if disabled then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        updateValue(getValueFromPosition(input.Position.X))
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateValue(getValueFromPosition(input.Position.X))
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                
                -- Initialize
                local initPercent = (value - options.Min) / (options.Max - options.Min)
                fill.Size = UDim2.new(initPercent, 0, 1, 0)
                
                local Slider = {
                    Value = value,
                    Container = container
                }
                
                function Slider:SetValue(newValue)
                    updateValue(newValue)
                    self.Value = value
                end
                
                function Slider:GetValue()
                    return value
                end
                
                function Slider:SetText(text)
                    label.Text = text
                end
                
                function Slider:SetMin(min)
                    options.Min = min
                    updateValue(value)
                end
                
                function Slider:SetMax(max)
                    options.Max = max
                    updateValue(value)
                end
                
                function Slider:SetDisabled(state)
                    disabled = state
                    label.TextColor3 = state and Library.Scheme.TextMuted or Library.Scheme.TextSecondary
                end
                
                function Slider:SetVisible(visible)
                    container.Visible = visible
                end
                
                function Slider:OnChanged(callback)
                    table.insert(callbacks, callback)
                end
                
                -- Register
                Library.Options[idx] = Slider
                
                return Slider
            end
            
            function Groupbox:AddInput(idx, options)
                options = options or {}
                options.Text = options.Text or "Input"
                options.Default = options.Default or ""
                options.Placeholder = options.Placeholder or ""
                options.Numeric = options.Numeric or false
                options.Finished = options.Finished or false
                options.Callback = options.Callback or function() end
                options.Disabled = options.Disabled or false
                
                self.ElementCount = self.ElementCount + 1
                
                local container = Create("Frame", {
                    Name = "Input_" .. idx,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50),
                    ZIndex = 6,
                    LayoutOrder = self.ElementCount,
                    Parent = self.Content
                })
                
                local label = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 20),
                    FontFace = Library.Font.Regular,
                    Text = options.Text,
                    TextColor3 = Library.Scheme.TextSecondary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 7,
                    Parent = container
                })
                
                local inputBg = Create("Frame", {
                    Name = "InputBg",
                    BackgroundColor3 = Library.Scheme.SurfaceLight,
                    Position = UDim2.new(0, 0, 0, 24),
                    Size = UDim2.new(1, 0, 0, 28),
                    ZIndex = 7,
                    Parent = container
                })
                AddCorner(inputBg, 6)
                AddStroke(inputBg, nil, 1, 0.8)
                
                local inputBox = Create("TextBox", {
                    Name = "Input",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(1, -16, 1, 0),
                    FontFace = Library.Font.Regular,
                    Text = options.Default,
                    PlaceholderText = options.Placeholder,
                    PlaceholderColor3 = Library.Scheme.TextMuted,
                    TextColor3 = Library.Scheme.TextPrimary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    ZIndex = 8,
                    Parent = inputBg
                })
                
                if options.Tooltip then
                    Library:AddTooltip(container, options.Tooltip, options.DisabledTooltip)
                end
                
                local value = options.Default
                local callbacks = {options.Callback}
                
                -- Focus styling
                inputBox.Focused:Connect(function()
                    Tween(inputBg:FindFirstChildOfClass("UIStroke"), {Color = Library.Scheme.Accent}, 0.15)
                end)
                
                inputBox.FocusLost:Connect(function(enterPressed)
                    Tween(inputBg:FindFirstChildOfClass("UIStroke"), {Color = Library.Scheme.GlassBorder}, 0.15)
                    
                    local newValue = inputBox.Text
                    
                    if options.Numeric then
                        newValue = tonumber(newValue) or value
                        inputBox.Text = tostring(newValue)
                    end
                    
                    if options.Finished then
                        if enterPressed then
                            value = newValue
                            for _, callback in ipairs(callbacks) do
                                task.spawn(callback, value)
                            end
                        end
                    else
                        value = newValue
                        for _, callback in ipairs(callbacks) do
                            task.spawn(callback, value)
                        end
                    end
                end)
                
                if not options.Finished then
                    inputBox:GetPropertyChangedSignal("Text"):Connect(function()
                        local newValue = inputBox.Text
                        if options.Numeric then
                            newValue = tonumber(newValue)
                            if not newValue then return end
                        end
                        value = newValue
                        for _, callback in ipairs(callbacks) do
                            task.spawn(callback, value)
                        end
                    end)
                end
                
                local Input = {
                    Value = value,
                    Container = container
                }
                
                function Input:SetValue(newValue)
                    value = newValue
                    inputBox.Text = tostring(newValue)
                    self.Value = value
                end
                
                function Input:GetValue()
                    return value
                end
                
                function Input:SetText(text)
                    label.Text = text
                end
                
                function Input:SetDisabled(state)
                    inputBox.TextEditable = not state
                    label.TextColor3 = state and Library.Scheme.TextMuted or Library.Scheme.TextSecondary
                end
                
                function Input:SetVisible(visible)
                    container.Visible = visible
                end
                
                function Input:OnChanged(callback)
                    table.insert(callbacks, callback)
                end
                
                -- Register
                Library.Options[idx] = Input
                
                return Input
            end
            
            function Groupbox:AddDropdown(idx, options)
                options = options or {}
                options.Text = options.Text or "Dropdown"
                options.Values = options.Values or {}
                options.Default = options.Default or (options.Multi and {} or nil)
                options.Multi = options.Multi or false
                options.Callback = options.Callback or function() end
                options.Disabled = options.Disabled or false
                
                self.ElementCount = self.ElementCount + 1
                
                local container = Create("Frame", {
                    Name = "Dropdown_" .. idx,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50),
                    ZIndex = 6,
                    LayoutOrder = self.ElementCount,
                    ClipsDescendants = false,
                    Parent = self.Content
                })
                
                local label = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 20),
                    FontFace = Library.Font.Regular,
                    Text = options.Text,
                    TextColor3 = Library.Scheme.TextSecondary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 7,
                    Parent = container
                })
                
                local dropdownBtn = Create("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = Library.Scheme.SurfaceLight,
                    Position = UDim2.new(0, 0, 0, 24),
                    Size = UDim2.new(1, 0, 0, 28),
                    Text = "",
                    ZIndex = 7,
                    Parent = container
                })
                AddCorner(dropdownBtn, 6)
                AddStroke(dropdownBtn, nil, 1, 0.8)
                
                local selectedLabel = Create("TextLabel", {
                    Name = "Selected",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(1, -30, 1, 0),
                    FontFace = Library.Font.Regular,
                    Text = "Select...",
                    TextColor3 = Library.Scheme.TextMuted,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 8,
                    Parent = dropdownBtn
                })
                
                local arrow = Create("TextLabel", {
                    Name = "Arrow",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -22, 0, 0),
                    Size = UDim2.new(0, 14, 1, 0),
                    FontFace = Library.Font.Bold,
                    Text = "▼",
                    TextColor3 = Library.Scheme.TextSecondary,
                    TextSize = 10,
                    ZIndex = 8,
                    Parent = dropdownBtn
                })
                
                -- Dropdown list
                local dropdownList = Create("Frame", {
                    Name = "List",
                    BackgroundColor3 = Library.Scheme.Surface,
                    Position = UDim2.new(0, 0, 1, 4),
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 100,
                    Parent = dropdownBtn
                })
                AddCorner(dropdownList, 6)
                AddStroke(dropdownList)
                AddShadow(dropdownList, 0.6)
                
                local listContent = Create("Frame", {
                    Name = "Content",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    ZIndex = 101,
                    Parent = dropdownList
                })
                AddPadding(listContent, 4)
                
                Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2),
                    Parent = listContent
                })
                
                if options.Tooltip then
                    Library:AddTooltip(container, options.Tooltip, options.DisabledTooltip)
                end
                
                local isOpen = false
                local selected = options.Multi and {} or nil
                local callbacks = {options.Callback}
                
                -- Initialize multi-select
                if options.Multi and options.Default then
                    for _, v in ipairs(options.Default) do
                        selected[v] = true
                    end
                else
                    selected = options.Default
                end
                
                local function updateDisplay()
                    if options.Multi then
                        local items = {}
                        for value, isSelected in pairs(selected) do
                            if isSelected then
                                table.insert(items, value)
                            end
                        end
                        if #items == 0 then
                            selectedLabel.Text = "Select..."
                            selectedLabel.TextColor3 = Library.Scheme.TextMuted
                        else
                            selectedLabel.Text = table.concat(items, ", ")
                            selectedLabel.TextColor3 = Library.Scheme.TextPrimary
                        end
                    else
                        if selected then
                            selectedLabel.Text = tostring(selected)
                            selectedLabel.TextColor3 = Library.Scheme.TextPrimary
                        else
                            selectedLabel.Text = "Select..."
                            selectedLabel.TextColor3 = Library.Scheme.TextMuted
                        end
                    end
                end
                
                local function createOptions()
                    -- Clear existing
                    for _, child in ipairs(listContent:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    for i, value in ipairs(options.Values) do
                        local optionBtn = Create("TextButton", {
                            Name = "Option_" .. value,
                            BackgroundColor3 = Library.Scheme.Accent,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 26),
                            Text = "",
                            ZIndex = 102,
                            LayoutOrder = i,
                            Parent = listContent
                        })
                        AddCorner(optionBtn, 4)
                        
                        local optionLabel = Create("TextLabel", {
                            Name = "Label",
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 8, 0, 0),
                            Size = UDim2.new(1, -16, 1, 0),
                            FontFace = Library.Font.Regular,
                            Text = tostring(value),
                            TextColor3 = Library.Scheme.TextSecondary,
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 103,
                            Parent = optionBtn
                        })
                        
                        -- Check indicator for multi-select
                        if options.Multi then
                            local check = Create("TextLabel", {
                                Name = "Check",
                                BackgroundTransparency = 1,
                                Position = UDim2.new(1, -20, 0.5, -6),
                                Size = UDim2.new(0, 12, 0, 12),
                                FontFace = Library.Font.Bold,
                                Text = selected[value] and "✓" or "",
                                TextColor3 = Library.Scheme.Accent,
                                TextSize = 12,
                                ZIndex = 103,
                                Parent = optionBtn
                            })
                        end
                        
                        optionBtn.MouseEnter:Connect(function()
                            Tween(optionBtn, {BackgroundTransparency = 0.85}, 0.1)
                            optionLabel.TextColor3 = Library.Scheme.TextPrimary
                        end)
                        
                        optionBtn.MouseLeave:Connect(function()
                            Tween(optionBtn, {BackgroundTransparency = 1}, 0.1)
                            optionLabel.TextColor3 = Library.Scheme.TextSecondary
                        end)
                        
                        optionBtn.MouseButton1Click:Connect(function()
                            if options.Multi then
                                selected[value] = not selected[value]
                                local check = optionBtn:FindFirstChild("Check")
                                if check then
                                    check.Text = selected[value] and "✓" or ""
                                end
                                updateDisplay()
                                for _, callback in ipairs(callbacks) do
                                    task.spawn(callback, selected)
                                end
                            else
                                selected = value
                                updateDisplay()
                                for _, callback in ipairs(callbacks) do
                                    task.spawn(callback, selected)
                                end
                                -- Close dropdown
                                isOpen = false
                                dropdownList.Visible = false
                                Tween(arrow, {Rotation = 0}, 0.15)
                            end
                        end)
                    end
                end
                
                -- Toggle dropdown
                dropdownBtn.MouseButton1Click:Connect(function()
                    if options.Disabled then return end
                    isOpen = not isOpen
                    dropdownList.Visible = isOpen
                    Tween(arrow, {Rotation = isOpen and 180 or 0}, 0.15)
                end)
                
                -- Close when clicking elsewhere
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local pos = input.Position
                        local btnPos = dropdownBtn.AbsolutePosition
                        local btnSize = dropdownBtn.AbsoluteSize
                        local listPos = dropdownList.AbsolutePosition
                        local listSize = dropdownList.AbsoluteSize
                        
                        local inBtn = pos.X >= btnPos.X and pos.X <= btnPos.X + btnSize.X
                            and pos.Y >= btnPos.Y and pos.Y <= btnPos.Y + btnSize.Y
                        local inList = pos.X >= listPos.X and pos.X <= listPos.X + listSize.X
                            and pos.Y >= listPos.Y and pos.Y <= listPos.Y + listSize.Y
                        
                        if not inBtn and not inList and isOpen then
                            isOpen = false
                            dropdownList.Visible = false
                            Tween(arrow, {Rotation = 0}, 0.15)
                        end
                    end
                end)
                
                createOptions()
                updateDisplay()
                
                local Dropdown = {
                    Value = selected,
                    Container = container
                }
                
                function Dropdown:SetValue(value)
                    if options.Multi then
                        selected = value
                    else
                        selected = value
                    end
                    self.Value = selected
                    updateDisplay()
                    for _, callback in ipairs(callbacks) do
                        task.spawn(callback, selected)
                    end
                end
                
                function Dropdown:GetValue()
                    return selected
                end
                
                function Dropdown:SetValues(values)
                    options.Values = values
                    createOptions()
                end
                
                function Dropdown:AddValues(values)
                    if type(values) == "table" then
                        for _, v in ipairs(values) do
                            table.insert(options.Values, v)
                        end
                    else
                        table.insert(options.Values, values)
                    end
                    createOptions()
                end
                
                function Dropdown:SetText(text)
                    label.Text = text
                end
                
                function Dropdown:SetDisabled(state)
                    options.Disabled = state
                    label.TextColor3 = state and Library.Scheme.TextMuted or Library.Scheme.TextSecondary
                end
                
                function Dropdown:SetVisible(visible)
                    container.Visible = visible
                end
                
                function Dropdown:OnChanged(callback)
                    table.insert(callbacks, callback)
                end
                
                -- Register
                Library.Options[idx] = Dropdown
                
                return Dropdown
            end
            
            function Groupbox:AddKeyPicker(idx, options, toggleRef)
                options = options or {}
                options.Text = options.Text or "Keybind"
                options.Default = options.Default or "None"
                options.Mode = options.Mode or "Toggle"
                options.Callback = options.Callback or function() end
                options.SyncToggleState = options.SyncToggleState or false
                
                self.ElementCount = self.ElementCount + 1
                
                local container = Create("Frame", {
                    Name = "KeyPicker_" .. idx,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 28),
                    ZIndex = 6,
                    LayoutOrder = self.ElementCount,
                    Parent = self.Content
                })
                
                local label = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -80, 1, 0),
                    FontFace = Library.Font.Regular,
                    Text = options.Text,
                    TextColor3 = Library.Scheme.TextSecondary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 7,
                    Parent = container
                })
                
                local keyBtn = Create("TextButton", {
                    Name = "KeyButton",
                    BackgroundColor3 = Library.Scheme.SurfaceLight,
                    Position = UDim2.new(1, -70, 0, 2),
                    Size = UDim2.new(0, 70, 0, 24),
                    Text = "",
                    ZIndex = 7,
                    Parent = container
                })
                AddCorner(keyBtn, 6)
                AddStroke(keyBtn, nil, 1, 0.8)
                
                local keyLabel = Create("TextLabel", {
                    Name = "Key",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    FontFace = Library.Font.Medium,
                    Text = options.Default,
                    TextColor3 = Library.Scheme.TextPrimary,
                    TextSize = 11,
                    ZIndex = 8,
                    Parent = keyBtn
                })
                
                local currentKey = Enum.KeyCode[options.Default] or nil
                local mode = options.Mode
                local state = false
                local listening = false
                local callbacks = {options.Callback}
                
                local function updateState(newState)
                    state = newState
                    for _, callback in ipairs(callbacks) do
                        task.spawn(callback, state)
                    end
                    
                    if options.SyncToggleState and toggleRef then
                        toggleRef:SetValue(state)
                    end
                end
                
                keyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    keyLabel.Text = "..."
                    Tween(keyBtn:FindFirstChildOfClass("UIStroke"), {Color = Library.Scheme.Accent}, 0.15)
                end)
                
                UserInputService.InputBegan:Connect(function(input, processed)
                    if listening then
                        listening = false
                        Tween(keyBtn:FindFirstChildOfClass("UIStroke"), {Color = Library.Scheme.GlassBorder}, 0.15)
                        
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode
                            keyLabel.Text = input.KeyCode.Name
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                            currentKey = Enum.UserInputType.MouseButton1
                            keyLabel.Text = "MB1"
                        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                            currentKey = Enum.UserInputType.MouseButton2
                            keyLabel.Text = "MB2"
                        end
                        return
                    end
                    
                    if processed then return end
                    
                    local matched = false
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                        matched = true
                    elseif input.UserInputType == currentKey then
                        matched = true
                    end
                    
                    if matched then
                        if mode == "Toggle" then
                            updateState(not state)
                        elseif mode == "Hold" then
                            updateState(true)
                        elseif mode == "Always" then
                            updateState(true)
                        end
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if mode == "Hold" then
                        local matched = false
                        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                            matched = true
                        elseif input.UserInputType == currentKey then
                            matched = true
                        end
                        
                        if matched then
                            updateState(false)
                        end
                    end
                end)
                
                local KeyPicker = {
                    Value = currentKey,
                    Container = container
                }
                
                function KeyPicker:SetValue(value)
                    if type(value) == "table" then
                        currentKey = value[1] or currentKey
                        mode = value[2] or mode
                    else
                        currentKey = value
                    end
                    keyLabel.Text = currentKey and currentKey.Name or "None"
                    self.Value = currentKey
                end
                
                function KeyPicker:GetState()
                    return state
                end
                
                function KeyPicker:SetText(text)
                    label.Text = text
                end
                
                function KeyPicker:OnChanged(callback)
                    table.insert(callbacks, callback)
                end
                
                -- Register
                Library.Options[idx] = KeyPicker
                
                return KeyPicker
            end
            
            function Groupbox:AddColorPicker(idx, options, parentElement)
                options = options or {}
                options.Default = options.Default or Color3.fromRGB(255, 255, 255)
                options.Title = options.Title or "Color Picker"
                options.Callback = options.Callback or function() end
                
                -- Create color picker button
                local colorBtn
                if parentElement then
                    colorBtn = Create("Frame", {
                        Name = "ColorPicker_" .. idx,
                        BackgroundColor3 = options.Default,
                        Position = UDim2.new(1, -24, 0.5, -8),
                        Size = UDim2.new(0, 16, 0, 16),
                        ZIndex = 10,
                        Parent = parentElement
                    })
                else
                    self.ElementCount = self.ElementCount + 1
                    
                    local container = Create("Frame", {
                        Name = "ColorPicker_" .. idx,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 28),
                        ZIndex = 6,
                        LayoutOrder = self.ElementCount,
                        Parent = self.Content
                    })
                    
                    Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, -30, 1, 0),
                        FontFace = Library.Font.Regular,
                        Text = options.Title,
                        TextColor3 = Library.Scheme.TextSecondary,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 7,
                        Parent = container
                    })
                    
                    colorBtn = Create("Frame", {
                        Name = "ColorButton",
                        BackgroundColor3 = options.Default,
                        Position = UDim2.new(1, -24, 0.5, -8),
                        Size = UDim2.new(0, 16, 0, 16),
                        ZIndex = 8,
                        Parent = container
                    })
                end
                
                AddCorner(colorBtn, 4)
                AddStroke(colorBtn, nil, 1, 0.5)
                
                local currentColor = options.Default
                local callbacks = {options.Callback}
                
                -- Simple color picker popup
                local pickerOpen = false
                local pickerFrame
                
                local function openPicker()
                    if pickerFrame then pickerFrame:Destroy() end
                    
                    pickerFrame = Create("Frame", {
                        Name = "ColorPickerPopup",
                        BackgroundColor3 = Library.Scheme.Surface,
                        Position = UDim2.new(0, colorBtn.AbsolutePosition.X - 100, 0, colorBtn.AbsolutePosition.Y + 20),
                        Size = UDim2.new(0, 200, 0, 150),
                        ZIndex = 200,
                        Parent = Library.ScreenGui
                    })
                    AddCorner(pickerFrame)
                    AddStroke(pickerFrame)
                    AddShadow(pickerFrame, 0.5)
                    
                    local title = Create("TextLabel", {
                        Name = "Title",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 5),
                        Size = UDim2.new(1, -20, 0, 20),
                        FontFace = Library.Font.Bold,
                        Text = options.Title,
                        TextColor3 = Library.Scheme.TextPrimary,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 201,
                        Parent = pickerFrame
                    })
                    
                    -- Color preview
                    local preview = Create("Frame", {
                        Name = "Preview",
                        BackgroundColor3 = currentColor,
                        Position = UDim2.new(0, 10, 0, 30),
                        Size = UDim2.new(1, -20, 0, 30),
                        ZIndex = 201,
                        Parent = pickerFrame
                    })
                    AddCorner(preview, 6)
                    
                    -- RGB Sliders
                    local function createColorSlider(name, yPos, component, defaultVal)
                        local sliderBg = Create("Frame", {
                            Name = name,
                            BackgroundColor3 = Library.Scheme.SurfaceLight,
                            Position = UDim2.new(0, 10, 0, yPos),
                            Size = UDim2.new(1, -20, 0, 20),
                            ZIndex = 201,
                            Parent = pickerFrame
                        })
                        AddCorner(sliderBg, 4)
                        
                        local sliderFill = Create("Frame", {
                            Name = "Fill",
                            BackgroundColor3 = component == "R" and Color3.fromRGB(255, 100, 100)
                                or component == "G" and Color3.fromRGB(100, 255, 100)
                                or Color3.fromRGB(100, 100, 255),
                            Size = UDim2.new(defaultVal/255, 0, 1, 0),
                            ZIndex = 202,
                            Parent = sliderBg
                        })
                        AddCorner(sliderFill, 4)
                        
                        local label = Create("TextLabel", {
                            Name = "Label",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            FontFace = Library.Font.Medium,
                            Text = component .. ": " .. math.floor(defaultVal),
                            TextColor3 = Library.Scheme.TextPrimary,
                            TextSize = 11,
                            ZIndex = 203,
                            Parent = sliderBg
                        })
                        
                        local clickBtn = Create("TextButton", {
                            Name = "Click",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            Text = "",
                            ZIndex = 204,
                            Parent = sliderBg
                        })
                        
                        local dragging = false
                        
                        clickBtn.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                dragging = true
                            end
                        end)
                        
                        UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                dragging = false
                            end
                        end)
                        
                        UserInputService.InputChanged:Connect(function(input)
                            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                                local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                                local value = math.floor(percent * 255)
                                
                                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                                label.Text = component .. ": " .. value
                                
                                local r, g, b = currentColor.R * 255, currentColor.G * 255, currentColor.B * 255
                                if component == "R" then r = value
                                elseif component == "G" then g = value
                                else b = value end
                                
                                currentColor = Color3.fromRGB(r, g, b)
                                preview.BackgroundColor3 = currentColor
                                colorBtn.BackgroundColor3 = currentColor
                                
                                for _, callback in ipairs(callbacks) do
                                    task.spawn(callback, currentColor)
                                end
                            end
                        end)
                        
                        return sliderBg
                    end
                    
                    createColorSlider("R", 70, "R", currentColor.R * 255)
                    createColorSlider("G", 95, "G", currentColor.G * 255)
                    createColorSlider("B", 120, "B", currentColor.B * 255)
                    
                    pickerOpen = true
                end
                
                local function closePicker()
                    if pickerFrame then
                        pickerFrame:Destroy()
                        pickerFrame = nil
                    end
                    pickerOpen = false
                end
                
                -- Click handler
                local clickBtn = Create("TextButton", {
                    Name = "Click",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 11,
                    Parent = colorBtn
                })
                
                clickBtn.MouseButton1Click:Connect(function()
                    if pickerOpen then
                        closePicker()
                    else
                        openPicker()
                    end
                end)
                
                -- Close when clicking elsewhere
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and pickerOpen and pickerFrame then
                        local pos = input.Position
                        local framePos = pickerFrame.AbsolutePosition
                        local frameSize = pickerFrame.AbsoluteSize
                        
                        local inFrame = pos.X >= framePos.X and pos.X <= framePos.X + frameSize.X
                            and pos.Y >= framePos.Y and pos.Y <= framePos.Y + frameSize.Y
                        
                        if not inFrame then
                            task.wait(0.1)
                            closePicker()
                        end
                    end
                end)
                
                local ColorPicker = {
                    Value = currentColor,
                    Button = colorBtn
                }
                
                function ColorPicker:SetValue(color)
                    currentColor = color
                    colorBtn.BackgroundColor3 = color
                    self.Value = color
                    for _, callback in ipairs(callbacks) do
                        task.spawn(callback, color)
                    end
                end
                
                function ColorPicker:SetValueRGB(color)
                    self:SetValue(color)
                end
                
                function ColorPicker:OnChanged(callback)
                    table.insert(callbacks, callback)
                end
                
                -- Register
                Library.Options[idx] = ColorPicker
                
                return ColorPicker
            end
            
            return Groupbox
        end
        
        function Tab:AddLeftGroupbox(name)
            return CreateGroupbox(name, self.LeftColumn)
        end
        
        function Tab:AddRightGroupbox(name)
            return CreateGroupbox(name, self.RightColumn)
        end
        
        function Tab:AddLeftTabbox(name)
            -- Create a tabbox (groupbox with internal tabs)
            local tabbox = CreateGroupbox(name, self.LeftColumn)
            
            -- Override with tabbox functionality
            local tabs = {}
            local activeTab = nil
            
            local tabButtons = Create("Frame", {
                Name = "TabButtons",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 24),
                ZIndex = 7,
                LayoutOrder = 0,
                Parent = tabbox.Content
            })
            
            Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4),
                Parent = tabButtons
            })
            
            function tabbox:AddTab(tabName)
                local tabIndex = #tabs + 1
                
                local tabBtn = Create("TextButton", {
                    Name = "Tab_" .. tabName,
                    BackgroundColor3 = Library.Scheme.Accent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 1, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    Text = "",
                    ZIndex = 8,
                    LayoutOrder = tabIndex,
                    Parent = tabButtons
                })
                AddCorner(tabBtn, 4)
                AddPadding(tabBtn, 6)
                
                local tabLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 1, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    FontFace = Library.Font.Medium,
                    Text = tabName,
                    TextColor3 = Library.Scheme.TextSecondary,
                    TextSize = 11,
                    ZIndex = 9,
                    Parent = tabBtn
                })
                
                local tabContent = Create("Frame", {
                    Name = "TabContent_" .. tabName,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Visible = tabIndex == 1,
                    ZIndex = 7,
                    LayoutOrder = 1,
                    Parent = tabbox.Content
                })
                
                Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 6),
                    Parent = tabContent
                })
                
                local tab = {
                    Button = tabBtn,
                    Content = tabContent,
                    Name = tabName,
                    ElementCount = 0
                }
                
                -- Copy all element methods from groupbox
                for name, func in pairs(tabbox) do
                    if type(func) == "function" and name:match("^Add") then
                        tab[name] = function(self, ...)
                            local oldContent = tabbox.Content
                            tabbox.Content = tabContent
                            tabbox.ElementCount = self.ElementCount
                            local result = func(tabbox, ...)
                            self.ElementCount = tabbox.ElementCount
                            tabbox.Content = oldContent
                            return result
                        end
                    end
                end
                
                local function selectTab()
                    for _, t in ipairs(tabs) do
                        t.Content.Visible = false
                        Tween(t.Button, {BackgroundTransparency = 1}, 0.15)
                        t.Button.Label.TextColor3 = Library.Scheme.TextSecondary
                    end
                    
                    tab.Content.Visible = true
                    Tween(tabBtn, {BackgroundTransparency = 0.85}, 0.15)
                    tabLabel.TextColor3 = Library.Scheme.TextPrimary
                    activeTab = tab
                end
                
                tabBtn.MouseButton1Click:Connect(selectTab)
                
                if tabIndex == 1 then
                    selectTab()
                end
                
                table.insert(tabs, tab)
                return tab
            end
            
            return tabbox
        end
        
        function Tab:AddRightTabbox(name)
            local tabbox = self:AddLeftGroupbox(name)
            tabbox.Frame.Parent = self.RightColumn
            
            -- Add tabbox functionality (same as AddLeftTabbox)
            local tabs = {}
            
            local tabButtons = Create("Frame", {
                Name = "TabButtons",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 24),
                ZIndex = 7,
                LayoutOrder = 0,
                Parent = tabbox.Content
            })
            
            Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4),
                Parent = tabButtons
            })
            
            function tabbox:AddTab(tabName)
                local tabIndex = #tabs + 1
                
                local tabBtn = Create("TextButton", {
                    Name = "Tab_" .. tabName,
                    BackgroundColor3 = Library.Scheme.Accent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 1, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    Text = "",
                    ZIndex = 8,
                    LayoutOrder = tabIndex,
                    Parent = tabButtons
                })
                AddCorner(tabBtn, 4)
                AddPadding(tabBtn, 6)
                
                local tabLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 1, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    FontFace = Library.Font.Medium,
                    Text = tabName,
                    TextColor3 = Library.Scheme.TextSecondary,
                    TextSize = 11,
                    ZIndex = 9,
                    Parent = tabBtn
                })
                
                local tabContent = Create("Frame", {
                    Name = "TabContent_" .. tabName,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Visible = tabIndex == 1,
                    ZIndex = 7,
                    LayoutOrder = 1,
                    Parent = tabbox.Content
                })
                
                Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 6),
                    Parent = tabContent
                })
                
                local tab = {
                    Button = tabBtn,
                    Content = tabContent,
                    Name = tabName,
                    ElementCount = 0
                }
                
                for name, func in pairs(tabbox) do
                    if type(func) == "function" and name:match("^Add") then
                        tab[name] = function(self, ...)
                            local oldContent = tabbox.Content
                            tabbox.Content = tabContent
                            tabbox.ElementCount = self.ElementCount
                            local result = func(tabbox, ...)
                            self.ElementCount = tabbox.ElementCount
                            tabbox.Content = oldContent
                            return result
                        end
                    end
                end
                
                local function selectTab()
                    for _, t in ipairs(tabs) do
                        t.Content.Visible = false
                        Tween(t.Button, {BackgroundTransparency = 1}, 0.15)
                        t.Button.Label.TextColor3 = Library.Scheme.TextSecondary
                    end
                    
                    tab.Content.Visible = true
                    Tween(tabBtn, {BackgroundTransparency = 0.85}, 0.15)
                    tabLabel.TextColor3 = Library.Scheme.TextPrimary
                end
                
                tabBtn.MouseButton1Click:Connect(selectTab)
                
                if tabIndex == 1 then
                    selectTab()
                end
                
                table.insert(tabs, tab)
                return tab
            end
            
            return tabbox
        end
        
        table.insert(Window.Tabs, Tab)
        return Tab
    end
    
    table.insert(Library.Windows, Window)
    return Window
end

--[[ ============================================
    LIBRARY METHODS
============================================ ]]--

function Library:Toggle(state)
    if state == nil then
        state = not Library.Toggled
    end
    
    Library.Toggled = state
    
    for _, window in ipairs(Library.Windows) do
        if state then
            window.Frame.Visible = true
            Tween(window.Frame, {BackgroundTransparency = 0}, 0.2)
        else
            Tween(window.Frame, {BackgroundTransparency = 1}, 0.2)
            task.wait(0.2)
            window.Frame.Visible = false
        end
    end
end

function Library:SetTheme(scheme)
    for key, value in pairs(scheme) do
        Library.Scheme[key] = value
    end
    -- TODO: Update all existing elements
end

function Library:SetFont(font)
    Library.Font.Regular = Font.new("rbxasset://fonts/families/" .. font .. ".json", Enum.FontWeight.Regular)
    Library.Font.Medium = Font.new("rbxasset://fonts/families/" .. font .. ".json", Enum.FontWeight.Medium)
    Library.Font.Bold = Font.new("rbxasset://fonts/families/" .. font .. ".json", Enum.FontWeight.Bold)
end

function Library:Unload()
    for _, window in ipairs(Library.Windows) do
        window.Frame:Destroy()
    end
    
    if Library.ScreenGui then
        Library.ScreenGui:Destroy()
    end
    
    Library.Windows = {}
    Library.Options = {}
    Library.Toggles = {}
end

function Library:OnUnload(callback)
    Library.UnloadCallback = callback
end

-- Return the library
return Library
