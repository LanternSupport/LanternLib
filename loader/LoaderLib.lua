-- ==============================================================================
-- LANTERNLIB - OFFICIAL LOADER LIBRARY (ENGINE)
-- Design: Modern Minimal Dark Cyan (Strict 1:1 with Loaderdesign.svg)
-- Dimensions: 550 x 180 px | Font: Enum.Font.Code | Corner: 2px
-- ==============================================================================

local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)

local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService = cloneref(game:GetService("TweenService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local Players = cloneref(game:GetService("Players"))
local HttpService = cloneref(game:GetService("HttpService"))
local AnalyticsService = cloneref(game:GetService("RbxAnalyticsService"))

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local setclipboard = setclipboard or (syn and syn.write_clipboard) or function() end

-- ------------------------------------------------------------------------------
-- [1] Design Tokens (Matched 1:1 with Library.lua)
-- ------------------------------------------------------------------------------
local Tokens = {
    -- Colors
    MainColor           = Color3.fromRGB(20, 20, 20),      -- #141414 (Root Background & Buttons)
    DarkBackgroundColor = Color3.fromRGB(18, 18, 18),      -- #121212 (Input Box Inner)
    HoverColor          = Color3.fromRGB(28, 28, 28),      -- #1C1C1C (Button Hover)
    
    AccentColor         = Color3.fromRGB(255, 0, 0),       -- #ff0000 (Red Accent)
    AccentColorDark     = Color3.fromRGB(30, 130, 180),    -- Hover Accent
    
    OutlineColor        = Color3.fromRGB(50, 50, 50),      -- #323232 (Subtle Borders)
    HoverOutlineColor   = Color3.fromRGB(80, 80, 80),      -- #505050 (Hover Borders)
    
    FontColor           = Color3.fromRGB(255, 255, 255),    -- #FFFFFF (Title, Button Text)
    SubTextColor        = Color3.fromRGB(160, 160, 160),    -- #A0A0A0 (Subtitle)
    MutedTextColor      = Color3.fromRGB(115, 115, 115),    -- #737373 (Device Text / Placeholder)
    
    SuccessColor        = Color3.fromRGB(52, 211, 153),    -- #34D399 (Emerald Success)
    DangerColor         = Color3.fromRGB(244, 63, 94),     -- #F43F5E (Rose Error)
    
    -- Typography & Geometry
    Font                = Enum.Font.Code,
    CornerRadius        = UDim.new(0, 2),                  -- 2px matching Library.lua
    StrokeThickness     = 1,
}

local LoaderLib = {}

-- ------------------------------------------------------------------------------
-- [2] Hardware ID Helper
-- ------------------------------------------------------------------------------
function LoaderLib:GetHWID()
    local hwid = nil
    pcall(function()
        if gethwid then
            hwid = gethwid()
        elseif identifyexecutor and rbx_gethwid then
            hwid = rbx_gethwid()
        elseif AnalyticsService and AnalyticsService.GetClientId then
            hwid = AnalyticsService:GetClientId()
        end
    end)

    if not hwid or #tostring(hwid) == 0 then
        hwid = string.format("LX-%d-%d", LocalPlayer.UserId, math.floor(os.time() / 86400))
    end
    return tostring(hwid)
end

-- ------------------------------------------------------------------------------
-- [3] Helper: Parent GUI safely into protected CoreGui / gethui
-- ------------------------------------------------------------------------------
local function SafeParent(gui)
    local target = (gethui and gethui()) or CoreGui
    local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
    pcall(ProtectGui, gui)
    pcall(function()
        gui.Parent = target
    end)
    if not gui.Parent then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5)
    end
end

-- ------------------------------------------------------------------------------
-- [4] Main Window Constructor
-- ------------------------------------------------------------------------------
function LoaderLib:CreateWindow(config)
    config = config or {}

    local TitleText       = config.Title or "LanternLib - Key Verification"
    local SubtitleText    = config.Subtitle or "Please enter your authentication key below."
    local HWID            = config.HWID or self:GetHWID()
    local GetKeyURL       = config.GetKeyURL or "https://www.lanternsupport.xyz/"
    local PlaceholderText = config.PlaceholderText or "Enter Key here (e.g. LX-XXXX-XXXX-XXXX) . . . ."
    local OnSubmit        = config.OnSubmit or function() end
    local GuiName         = config.GuiName or "LanternLib_LoaderUI"

    -- Clean up any existing loader instance
    local existing = ((gethui and gethui()) or CoreGui):FindFirstChild(GuiName)
    if existing then
        existing:Destroy()
    end

    -- 1. ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = GuiName
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 1000
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    SafeParent(ScreenGui)

    -- 2. Root Window (550 x 180 px as defined in Loaderdesign.svg)
    local Root = Instance.new("Frame")
    Root.Name = "LoaderWindow"
    Root.AnchorPoint = Vector2.new(0.5, 0.5)
    Root.Position = UDim2.fromScale(0.5, 0.5)
    Root.Size = UDim2.fromOffset(550, 180)
    Root.BackgroundColor3 = Tokens.MainColor
    Root.BorderSizePixel = 0
    Root.ClipsDescendants = false
    Root.Parent = ScreenGui

    local RootCorner = Instance.new("UICorner")
    RootCorner.CornerRadius = Tokens.CornerRadius
    RootCorner.Parent = Root

    local RootStroke = Instance.new("UIStroke")
    RootStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    RootStroke.Thickness = Tokens.StrokeThickness
    RootStroke.Color = Tokens.AccentColor -- Cyan accent outline
    RootStroke.Parent = Root

    -- 3. Header: Title (Exact Y: 24 in SVG)
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Position = UDim2.fromOffset(0, 20)
    Title.Size = UDim2.new(1, 0, 0, 18)
    Title.BackgroundTransparency = 1
    Title.Font = Tokens.Font
    Title.Text = TitleText
    Title.TextColor3 = Tokens.FontColor
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Center
    Title.Parent = Root

    -- 4. Header: Subtitle (Exact Y: 46 in SVG)
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Position = UDim2.fromOffset(0, 42)
    Subtitle.Size = UDim2.new(1, 0, 0, 16)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Tokens.Font
    Subtitle.Text = SubtitleText
    Subtitle.TextColor3 = Tokens.SubTextColor
    Subtitle.TextSize = 12
    Subtitle.TextXAlignment = Enum.TextXAlignment.Center
    Subtitle.Parent = Root

    -- 5. Key Input Box Container (Exact in SVG: X=32, Y=72.5, W=486, H=29)
    local InputFrame = Instance.new("Frame")
    InputFrame.Name = "InputFrame"
    InputFrame.Position = UDim2.fromOffset(32, 72)
    InputFrame.Size = UDim2.fromOffset(486, 30)
    InputFrame.BackgroundColor3 = Tokens.DarkBackgroundColor
    InputFrame.BorderSizePixel = 0
    InputFrame.Parent = Root

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = Tokens.CornerRadius
    InputCorner.Parent = InputFrame

    local InputStroke = Instance.new("UIStroke")
    InputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    InputStroke.Thickness = Tokens.StrokeThickness
    InputStroke.Color = Tokens.OutlineColor
    InputStroke.Parent = InputFrame

    local KeyInput = Instance.new("TextBox")
    KeyInput.Name = "KeyInput"
    KeyInput.Position = UDim2.fromOffset(12, 0)
    KeyInput.Size = UDim2.new(1, -24, 1, 0)
    KeyInput.BackgroundTransparency = 1
    KeyInput.Font = Tokens.Font
    KeyInput.PlaceholderText = PlaceholderText
    KeyInput.PlaceholderColor3 = Tokens.MutedTextColor
    KeyInput.Text = ""
    KeyInput.TextColor3 = Tokens.FontColor
    KeyInput.TextSize = 12
    KeyInput.TextXAlignment = Enum.TextXAlignment.Left
    KeyInput.ClearTextOnFocus = false
    KeyInput.Parent = InputFrame

    -- Focus animations for input box
    KeyInput.Focused:Connect(function()
        TweenService:Create(InputStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Color = Tokens.AccentColor }):Play()
    end)

    KeyInput.FocusLost:Connect(function()
        TweenService:Create(InputStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Color = Tokens.OutlineColor }):Play()
    end)

    -- 6. Left Button: "Get Key" (Exact in SVG: X=32, Y=112.5, W=233, H=26.5)
    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Name = "GetKeyButton"
    GetKeyBtn.Position = UDim2.fromOffset(32, 112)
    GetKeyBtn.Size = UDim2.fromOffset(233, 28)
    GetKeyBtn.BackgroundColor3 = Tokens.MainColor
    GetKeyBtn.BorderSizePixel = 0
    GetKeyBtn.AutoButtonColor = false
    GetKeyBtn.Text = ""
    GetKeyBtn.Parent = Root

    local GetKeyCorner = Instance.new("UICorner")
    GetKeyCorner.CornerRadius = Tokens.CornerRadius
    GetKeyCorner.Parent = GetKeyBtn

    local GetKeyStroke = Instance.new("UIStroke")
    GetKeyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    GetKeyStroke.Thickness = Tokens.StrokeThickness
    GetKeyStroke.Color = Tokens.OutlineColor
    GetKeyStroke.Parent = GetKeyBtn

    -- Get Key Icon (Lucide / Roblox Key Icon)
    local GetKeyIcon = Instance.new("ImageLabel")
    GetKeyIcon.Name = "Icon"
    GetKeyIcon.AnchorPoint = Vector2.new(0, 0.5)
    GetKeyIcon.Position = UDim2.new(0.5, -42, 0.5, 0)
    GetKeyIcon.Size = UDim2.fromOffset(13, 13)
    GetKeyIcon.BackgroundTransparency = 1
    GetKeyIcon.Image = "rbxassetid://10723426722" -- Key Icon
    GetKeyIcon.ImageColor3 = Tokens.FontColor
    GetKeyIcon.Parent = GetKeyBtn

    local GetKeyLabel = Instance.new("TextLabel")
    GetKeyLabel.Name = "Label"
    GetKeyLabel.Position = UDim2.new(0.5, -24, 0, 0)
    GetKeyLabel.Size = UDim2.new(0.5, 24, 1, 0)
    GetKeyLabel.BackgroundTransparency = 1
    GetKeyLabel.Font = Tokens.Font
    GetKeyLabel.Text = "Get Key"
    GetKeyLabel.TextColor3 = Tokens.FontColor
    GetKeyLabel.TextSize = 12
    GetKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
    GetKeyLabel.Parent = GetKeyBtn

    -- 7. Right Button: "Submit Key" (Exact in SVG: X=284, Y=112.5, W=234, H=26.5)
    local SubmitBtn = Instance.new("TextButton")
    SubmitBtn.Name = "SubmitButton"
    SubmitBtn.Position = UDim2.fromOffset(284, 112)
    SubmitBtn.Size = UDim2.fromOffset(234, 28)
    SubmitBtn.BackgroundColor3 = Tokens.MainColor
    SubmitBtn.BorderSizePixel = 0
    SubmitBtn.AutoButtonColor = false
    SubmitBtn.Text = ""
    SubmitBtn.Parent = Root

    local SubmitCorner = Instance.new("UICorner")
    SubmitCorner.CornerRadius = Tokens.CornerRadius
    SubmitCorner.Parent = SubmitBtn

    local SubmitStroke = Instance.new("UIStroke")
    SubmitStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    SubmitStroke.Thickness = Tokens.StrokeThickness
    SubmitStroke.Color = Tokens.AccentColor -- Cyan Accent Highlighted Border
    SubmitStroke.Parent = SubmitBtn

    local SubmitLabel = Instance.new("TextLabel")
    SubmitLabel.Name = "Label"
    SubmitLabel.Position = UDim2.fromOffset(0, 0)
    SubmitLabel.Size = UDim2.fromScale(1, 1)
    SubmitLabel.BackgroundTransparency = 1
    SubmitLabel.Font = Tokens.Font
    SubmitLabel.Text = "Submit Key"
    SubmitLabel.TextColor3 = Tokens.FontColor
    SubmitLabel.TextSize = 12
    SubmitLabel.TextXAlignment = Enum.TextXAlignment.Center
    SubmitLabel.Parent = SubmitBtn

    -- 8. Footer: Device HWID / Status Text (Exact in SVG: Y=154)
    local DeviceHWIDLabel = Instance.new("TextLabel")
    DeviceHWIDLabel.Name = "DeviceStatusLabel"
    DeviceHWIDLabel.Position = UDim2.fromOffset(0, 150)
    DeviceHWIDLabel.Size = UDim2.new(1, 0, 0, 18)
    DeviceHWIDLabel.BackgroundTransparency = 1
    DeviceHWIDLabel.Font = Tokens.Font
    DeviceHWIDLabel.Text = "Device : " .. tostring(HWID)
    DeviceHWIDLabel.TextColor3 = Tokens.MutedTextColor
    DeviceHWIDLabel.TextSize = 11
    DeviceHWIDLabel.TextXAlignment = Enum.TextXAlignment.Center
    DeviceHWIDLabel.Parent = Root

    -- --------------------------------------------------------------------------
    -- [5] Hover Animations (Matching Library.lua standards)
    -- --------------------------------------------------------------------------
    local function SetupButtonHover(btn, stroke, baseColor, hoverColor, baseStroke, hoverStroke)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundColor3 = hoverColor }):Play()
            if stroke then
                TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Color = hoverStroke }):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundColor3 = baseColor }):Play()
            if stroke then
                TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Color = baseStroke }):Play()
            end
        end)
    end

    SetupButtonHover(GetKeyBtn, GetKeyStroke, Tokens.MainColor, Tokens.HoverColor, Tokens.OutlineColor, Tokens.HoverOutlineColor)
    SetupButtonHover(SubmitBtn, SubmitStroke, Tokens.MainColor, Tokens.HoverColor, Tokens.AccentColor, Tokens.FontColor)

    -- --------------------------------------------------------------------------
    -- [6] Dragging System
    -- --------------------------------------------------------------------------
    local dragging = false
    local dragInput, dragStart, startPos

    Root.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Root.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Root.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Root.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- --------------------------------------------------------------------------
    -- [7] Controller API
    -- --------------------------------------------------------------------------
    local Controller = {}
    local isVerifying = false

    function Controller:SetStatus(text, color)
        DeviceHWIDLabel.Text = text or ("Device : " .. tostring(HWID))
        DeviceHWIDLabel.TextColor3 = color or Tokens.MutedTextColor
    end

    function Controller:SetVerifying(state, customText)
        isVerifying = state
        if state then
            SubmitBtn.Active = false
            SubmitLabel.Text = customText or "Checking..."
            SubmitStroke.Color = Tokens.AccentColor
            self:SetStatus(customText or "Verifying key...", Tokens.AccentColor)
        else
            SubmitBtn.Active = true
            SubmitLabel.Text = "Submit Key"
            SubmitStroke.Color = Tokens.AccentColor
        end
    end

    function Controller:SetSuccess(customText)
        SubmitLabel.Text = customText or "Verified!"
        SubmitStroke.Color = Tokens.SuccessColor
        self:SetStatus("Key Verified! Launching...", Tokens.SuccessColor)
    end

    function Controller:SetKeyText(key)
        KeyInput.Text = tostring(key or "")
    end

    function Controller:GetKeyText()
        return KeyInput.Text:gsub("%s+", "")
    end

    function Controller:Close(fadeTime)
        fadeTime = fadeTime or 0.3
        
        -- Smooth fade-out matching Library.lua MenuFadeTime
        local tweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        for _, desc in ipairs(Root:GetDescendants()) do
            if desc:IsA("TextLabel") or desc:IsA("TextBox") then
                TweenService:Create(desc, tweenInfo, { TextTransparency = 1 }):Play()
            elseif desc:IsA("UIStroke") then
                TweenService:Create(desc, tweenInfo, { Transparency = 1 }):Play()
            elseif desc:IsA("Frame") or desc:IsA("TextButton") then
                TweenService:Create(desc, tweenInfo, { BackgroundTransparency = 1 }):Play()
            elseif desc:IsA("ImageLabel") then
                TweenService:Create(desc, tweenInfo, { ImageTransparency = 1 }):Play()
            end
        end

        local rootTween = TweenService:Create(Root, tweenInfo, { BackgroundTransparency = 1 })
        rootTween:Play()
        rootTween.Completed:Connect(function()
            ScreenGui:Destroy()
        end)
    end

    function Controller:Destroy()
        ScreenGui:Destroy()
    end

    -- --------------------------------------------------------------------------
    -- [8] Button Actions
    -- --------------------------------------------------------------------------
    -- Get Key Action
    GetKeyBtn.MouseButton1Click:Connect(function()
        pcall(setclipboard, GetKeyURL)
        local origText = GetKeyLabel.Text
        GetKeyLabel.Text = "Copied URL!"
        GetKeyStroke.Color = Tokens.SuccessColor
        task.delay(1.5, function()
            GetKeyLabel.Text = origText
            GetKeyStroke.Color = Tokens.OutlineColor
        end)
    end)

    -- Submit Action
    local function TriggerSubmit()
        if isVerifying then return end
        local submittedKey = Controller:GetKeyText()
        OnSubmit(submittedKey, Controller, function()
            Controller:SetVerifying(false)
        end)
    end

    SubmitBtn.MouseButton1Click:Connect(TriggerSubmit)
    KeyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            TriggerSubmit()
        end
    end)

    -- Initial Window Fade-In Animation (Library-matching)
    Root.BackgroundTransparency = 1
    RootStroke.Transparency = 1
    Title.TextTransparency = 1
    Subtitle.TextTransparency = 1
    InputFrame.BackgroundTransparency = 1
    InputStroke.Transparency = 1
    KeyInput.TextTransparency = 1
    GetKeyBtn.BackgroundTransparency = 1
    GetKeyStroke.Transparency = 1
    GetKeyLabel.TextTransparency = 1
    GetKeyIcon.ImageTransparency = 1
    SubmitBtn.BackgroundTransparency = 1
    SubmitStroke.Transparency = 1
    SubmitLabel.TextTransparency = 1
    DeviceHWIDLabel.TextTransparency = 1

    local fadeIn = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(Root, fadeIn, { BackgroundTransparency = 0 }):Play()
    TweenService:Create(RootStroke, fadeIn, { Transparency = 0 }):Play()
    TweenService:Create(Title, fadeIn, { TextTransparency = 0 }):Play()
    TweenService:Create(Subtitle, fadeIn, { TextTransparency = 0 }):Play()
    TweenService:Create(InputFrame, fadeIn, { BackgroundTransparency = 0 }):Play()
    TweenService:Create(InputStroke, fadeIn, { Transparency = 0 }):Play()
    TweenService:Create(KeyInput, fadeIn, { TextTransparency = 0 }):Play()
    TweenService:Create(GetKeyBtn, fadeIn, { BackgroundTransparency = 0 }):Play()
    TweenService:Create(GetKeyStroke, fadeIn, { Transparency = 0 }):Play()
    TweenService:Create(GetKeyLabel, fadeIn, { TextTransparency = 0 }):Play()
    TweenService:Create(GetKeyIcon, fadeIn, { ImageTransparency = 0 }):Play()
    TweenService:Create(SubmitBtn, fadeIn, { BackgroundTransparency = 0 }):Play()
    TweenService:Create(SubmitStroke, fadeIn, { Transparency = 0 }):Play()
    TweenService:Create(SubmitLabel, fadeIn, { TextTransparency = 0 }):Play()
    TweenService:Create(DeviceHWIDLabel, fadeIn, { TextTransparency = 0 }):Play()

    return Controller
end

return LoaderLib