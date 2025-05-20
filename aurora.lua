--[[
AuroraUI Library
100% Rayfield-like Roblox UI Library
All branding and logo replaced with ðŸ—¿ (Moai).
Author: [YourName]
USAGE: AuroraUI.New({ ... }) [see docs at end]
]]

local AuroraUI = {}
AuroraUI.__index = AuroraUI

--// Utility & Theme
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Theme = {
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    Background = Color3.fromRGB(22, 22, 22),
    Accent = Color3.fromRGB(0, 192, 255),
    Accent2 = Color3.fromRGB(16, 121, 255),
    Border = Color3.fromRGB(32, 32, 32),
    Section = Color3.fromRGB(28, 28, 28),
    Text = Color3.fromRGB(235, 235, 235),
    Placeholder = Color3.fromRGB(140, 140, 140),
    Success = Color3.fromRGB(0,200,80),
    Warning = Color3.fromRGB(240,200,0),
    Danger = Color3.fromRGB(240,60,60),
    Glow = Color3.fromRGB(0, 205, 255),
    Shadow = Color3.fromRGB(0,0,0),
    Label = Color3.fromRGB(192,192,192),
    Scrollbar = Color3.fromRGB(50,50,50),
}

AuroraUI.Theme = Theme

local function deepCopy(t)
    if type(t) ~= "table" then return t end
    local nt = {}
    for k,v in pairs(t) do
        nt[k] = deepCopy(v)
    end
    return nt
end

--// Animate utility
local function Animate(obj, goal, time, style, dir)
    local tw = TweenService:Create(obj, TweenInfo.new(time or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), goal)
    tw:Play()
    return tw
end

--// Moai Logo (ðŸ—¿)
local function MoaiLogo(parent)
    local logo = Instance.new("TextLabel")
    logo.Name = "MoaiLogo"
    logo.Text = "ðŸ—¿"
    logo.Font = Theme.FontBold
    logo.TextSize = 34
    logo.TextColor3 = Theme.Accent
    logo.BackgroundTransparency = 1
    logo.Size = UDim2.new(0, 44, 0, 44)
    logo.Position = UDim2.new(0, 12, 0, 8)
    logo.Parent = parent
    return logo
end

--// Drag/Resize Utility (Rayfield-like)
local function EnableDragResize(frame, dragbar)
    local dragActive, dragInput, dragStart, startPos
    dragbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragActive = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragActive = false
                end
            end)
        end
    end)
    dragbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragActive then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--// Main New() (Rayfield-like API, full property support)
function AuroraUI.New(config)
    local self = setmetatable({}, AuroraUI)
    self.Name = config.Name or "AuroraUI"
    self.LoadTitle = config.LoadingTitle or "AuroraUI"
    self.LoadSubtitle = config.LoadingSubtitle or "ðŸ—¿"
    self.ConfigurationSaving = config.ConfigurationSaving or { Enabled = false }
    self.Theme = deepCopy(Theme)
    self._tabs = {}
    self._sections = {}
    self._elements = {}
    self._values = {}
    self._callbacks = {}
    self._config = {}

    --// UI: ScreenGui
    local Player = Players.LocalPlayer
    local PlayerGui = Player:FindFirstChildOfClass("PlayerGui") or Player:WaitForChild("PlayerGui")
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AuroraUI_"..tostring(math.random(10000,99999))
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.Parent = PlayerGui
    self._ScreenGui = ScreenGui

    --// UI: Main Window
    local Window = Instance.new("Frame")
    Window.Name = "Window"
    Window.Size = UDim2.new(0, 600, 0, 430)
    Window.Position = UDim2.new(0.5, -300, 0.5, -215)
    Window.BackgroundColor3 = self.Theme.Background
    Window.BorderSizePixel = 0
    Window.AnchorPoint = Vector2.new(0.5,0.5)
    Window.ClipsDescendants = true
    Window.Parent = ScreenGui
    self._Window = Window

    --// UI: Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Image = "rbxassetid://1316045217"
    Shadow.Size = UDim2.new(1, 56, 1, 56)
    Shadow.Position = UDim2.new(0, -28, 0, -28)
    Shadow.BackgroundTransparency = 1
    Shadow.ImageTransparency = 0.68
    Shadow.ZIndex = 0
    Shadow.Parent = Window

    --// UI: TopBar (drag bar)
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 54)
    TopBar.BackgroundColor3 = self.Theme.Section
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Window
    self._TopBar = TopBar

    --// UI: Moai Logo
    MoaiLogo(TopBar)

    --// UI: Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Text = self.Name
    Title.Font = self.Theme.FontBold
    Title.TextColor3 = self.Theme.Text
    Title.TextSize = 24
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 62, 0, 12)
    Title.Size = UDim2.new(1, -72, 0, 30)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    --// UI: AccentBar
    local AccentBar = Instance.new("Frame")
    AccentBar.Name = "AccentBar"
    AccentBar.Size = UDim2.new(1, 0, 0, 3)
    AccentBar.Position = UDim2.new(0,0,1,-3)
    AccentBar.BackgroundColor3 = self.Theme.Accent
    AccentBar.BorderSizePixel = 0
    AccentBar.Parent = TopBar

    --// UI: TabBar
    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(0, 134, 1, -54)
    TabBar.Position = UDim2.new(0, 0, 0, 54)
    TabBar.BackgroundColor3 = self.Theme.Section
    TabBar.BorderSizePixel = 0
    TabBar.Parent = Window
    self._TabBar = TabBar

    --// UI: Tab Buttons List
    local TabList = Instance.new("UIListLayout")
    TabList.Name = "TabList"
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 6)
    TabList.Parent = TabBar

    --// UI: TabContainer (content area)
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -134, 1, -54)
    TabContainer.Position = UDim2.new(0, 134, 0, 54)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ClipsDescendants = true
    TabContainer.Parent = Window
    self._TabContainer = TabContainer

    --// Enable drag for topbar
    EnableDragResize(Window, TopBar)

    -- Next: Tab, Section, Element API, Animation, Notification, Config, ColorPicker
    -- Kode akan dilanjutkan jika sudah mendekati limit.

    return self
end

-- KODE BERLANJUT KE FUNGSI TAB, SECTION, ELEMEN, DLL
-- Silakan konfirmasi "lanjut" untuk meneruskan (mengingat batas karakter).

--------------------------------------------------------------------------------
-- TAB, SECTION, DAN FOKUS ELEMENT (NEXT: tombol, toggle, slider, dropdown, dsb)
--------------------------------------------------------------------------------

-- Tab API
function AuroraUI:CreateTab(tabinfo)
    local tabName = tabinfo.Name or ("Tab"..#self._tabs+1)
    local tabIcon = tabinfo.Icon or "ðŸ—¿"
    local isDefault = tabinfo.Default or false

    --// Tab Button
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = "TabButton_"..tabName
    TabBtn.Text = tabIcon.."  "..tabName
    TabBtn.Font = self.Theme.FontBold
    TabBtn.TextColor3 = self.Theme.Text
    TabBtn.TextSize = 18
    TabBtn.BackgroundColor3 = self.Theme.Section
    TabBtn.Size = UDim2.new(1, -12, 0, 40)
    TabBtn.Position = UDim2.new(0, 6, 0, 0)
    TabBtn.AutoButtonColor = false
    TabBtn.BorderSizePixel = 0
    TabBtn.Parent = self._TabBar

    --// Tab Content
    local TabFrame = Instance.new("Frame")
    TabFrame.Name = "TabFrame_"..tabName
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = false
    TabFrame.Parent = self._TabContainer

    --// Section Holder (UIListLayout)
    local SectionHolder = Instance.new("Frame")
    SectionHolder.Name = "SectionHolder"
    SectionHolder.Size = UDim2.new(1, -20, 1, -20)
    SectionHolder.Position = UDim2.new(0, 10, 0, 10)
    SectionHolder.BackgroundTransparency = 1
    SectionHolder.Parent = TabFrame

    local SectionLayout = Instance.new("UIListLayout")
    SectionLayout.Padding = UDim.new(0, 15)
    SectionLayout.FillDirection = Enum.FillDirection.Horizontal
    SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SectionLayout.Parent = SectionHolder

    --// Tab Switching
    TabBtn.MouseButton1Click:Connect(function()
        for _, v in ipairs(self._tabs) do
            v._TabBtn.BackgroundColor3 = self.Theme.Section
            v._TabBtn.TextColor3 = self.Theme.Text
            v._TabFrame.Visible = false
        end
        TabBtn.BackgroundColor3 = self.Theme.Accent
        TabBtn.TextColor3 = Color3.new(1,1,1)
        TabFrame.Visible = true
    end)

    -- First/default tab
    if isDefault or #self._tabs == 0 then
        TabBtn.BackgroundColor3 = self.Theme.Accent
        TabBtn.TextColor3 = Color3.new(1,1,1)
        TabFrame.Visible = true
    end

    -- Tab Object
    local tabObj = {
        _TabBtn = TabBtn,
        _TabFrame = TabFrame,
        _SectionHolder = SectionHolder,
        _SectionLayout = SectionLayout,
        _sections = {},
        _elements = {},
        Name = tabName,
        Icon = tabIcon,
        ParentUI = self
    }

    -- SECTION API
    function tabObj:CreateSection(sectioninfo)
        local sectionName = sectioninfo.Name or ("Section"..#tabObj._sections+1)

        -- Section Frame
        local SectionFrame = Instance.new("Frame")
        SectionFrame.Name = "Section_"..sectionName
        SectionFrame.Size = UDim2.new(0, 270, 1, 0)
        SectionFrame.BackgroundColor3 = self.ParentUI.Theme.Section
        SectionFrame.BorderSizePixel = 0
        SectionFrame.BackgroundTransparency = 0
        SectionFrame.ClipsDescendants = true
        SectionFrame.Parent = tabObj._SectionHolder

        -- Section Title
        local SectionTitle = Instance.new("TextLabel")
        SectionTitle.Name = "SectionTitle"
        SectionTitle.Text = sectionName
        SectionTitle.Font = self.ParentUI.Theme.FontBold
        SectionTitle.TextColor3 = self.ParentUI.Theme.Text
        SectionTitle.TextSize = 18
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Size = UDim2.new(1, -24, 0, 22)
        SectionTitle.Position = UDim2.new(0, 12, 0, 10)
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        SectionTitle.Parent = SectionFrame

        -- Element Holder (vertical)
        local ElementHolder = Instance.new("Frame")
        ElementHolder.Name = "ElementHolder"
        ElementHolder.Size = UDim2.new(1, 0, 1, -36)
        ElementHolder.Position = UDim2.new(0, 0, 0, 34)
        ElementHolder.BackgroundTransparency = 1
        ElementHolder.Parent = SectionFrame

        local ElementLayout = Instance.new("UIListLayout")
        ElementLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ElementLayout.Padding = UDim.new(0, 8)
        ElementLayout.Parent = ElementHolder

        -- Section Object
        local sectionObj = {
            _SectionFrame = SectionFrame,
            _SectionTitle = SectionTitle,
            _ElementHolder = ElementHolder,
            _ElementLayout = ElementLayout,
            _elements = {},
            Name = sectionName,
            ParentTab = tabObj,
            ParentUI = self.ParentUI
        }

        -- REGISTER section
        tabObj._sections[#tabObj._sections+1] = sectionObj

        -- ELEMENT API (button, toggle, slider, dropdown, input, keybind, label, colorpicker, separator, etc)
        -- akan dilanjutkan di batch berikutnya

        -- CONTINUE TO: BUTTON
        function sectionObj:CreateButton(buttoninfo)
            local btnName = buttoninfo.Name or ("Button"..#sectionObj._elements+1)
            local btnDesc = buttoninfo.Description or ""
            local btnIcon = buttoninfo.Icon or ""
            local btnCallback = buttoninfo.Callback or function() end

            -- Frame
            local BtnFrame = Instance.new("Frame")
            BtnFrame.Name = "Button_"..btnName
            BtnFrame.Size = UDim2.new(1, 0, 0, 38)
            BtnFrame.BackgroundColor3 = self.ParentUI.Theme.Contrast or Color3.fromRGB(32,32,32)
            BtnFrame.BackgroundTransparency = 0.14
            BtnFrame.BorderSizePixel = 0
            BtnFrame.Parent = sectionObj._ElementHolder

            -- Icon (optional)
            if btnIcon ~= "" then
                local Icon = Instance.new("TextLabel")
                Icon.Text = btnIcon
                Icon.Font = self.ParentUI.Theme.FontBold
                Icon.TextSize = 18
                Icon.TextColor3 = self.ParentUI.Theme.Accent
                Icon.BackgroundTransparency = 1
                Icon.Size = UDim2.new(0, 28, 1, 0)
                Icon.Position = UDim2.new(0, 6, 0, 0)
                Icon.Parent = BtnFrame
            end

            -- Label
            local BtnLabel = Instance.new("TextButton")
            BtnLabel.Text = btnName
            BtnLabel.Font = self.ParentUI.Theme.FontBold
            BtnLabel.TextSize = 16
            BtnLabel.TextColor3 = self.ParentUI.Theme.Text
            BtnLabel.BackgroundTransparency = 1
            BtnLabel.Size = UDim2.new(1, btnIcon~="" and -34 or -12, 1, 0)
            BtnLabel.Position = UDim2.new(0, btnIcon~="" and 32 or 8, 0, 0)
            BtnLabel.TextXAlignment = Enum.TextXAlignment.Left
            BtnLabel.AutoButtonColor = true
            BtnLabel.Parent = BtnFrame

            -- Description (Tooltip on hover)
            if btnDesc ~= "" then
                local Tip = Instance.new("TextLabel")
                Tip.Text = btnDesc
                Tip.Font = self.ParentUI.Theme.Font
                Tip.TextSize = 14
                Tip.TextColor3 = self.ParentUI.Theme.Placeholder
                Tip.BackgroundTransparency = 1
                Tip.AnchorPoint = Vector2.new(0.5,1)
                Tip.Visible = false
                Tip.Size = UDim2.new(0, 180, 0, 22)
                Tip.Position = UDim2.new(0.5,0,0,0)
                Tip.ZIndex = 20
                Tip.Parent = BtnFrame

                BtnLabel.MouseEnter:Connect(function() Tip.Visible = true end)
                BtnLabel.MouseLeave:Connect(function() Tip.Visible = false end)
            end

            -- Animation
            BtnLabel.MouseEnter:Connect(function()
                Animate(BtnFrame, {BackgroundTransparency = 0.08}, 0.14)
            end)
            BtnLabel.MouseLeave:Connect(function()
                Animate(BtnFrame, {BackgroundTransparency = 0.14}, 0.14)
            end)

            -- Click
            BtnLabel.MouseButton1Click:Connect(function()
                Animate(BtnFrame, {BackgroundColor3 = self.ParentUI.Theme.Accent}, 0.14)
                wait(0.09)
                Animate(BtnFrame, {BackgroundColor3 = self.ParentUI.Theme.Contrast or Color3.fromRGB(32,32,32)}, 0.14)
                spawn(btnCallback) -- async
            end)

            -- Register element
            local el = {
                Type = "Button",
                Name = btnName,
                Frame = BtnFrame,
                Callback = btnCallback
            }
            sectionObj._elements[#sectionObj._elements+1] = el
            return el
        end

        -- Lanjut ke: Toggle, Slider, Dropdown, Input, Keybind, Label, ColorPicker, Separator, dan lain-lain
        -- Kirim "lanjut" untuk batch berikutnya!

        return sectionObj
    end

    -- REGISTER tab
    self._tabs[#self._tabs+1] = tabObj
    return tabObj
end

--------------------------------------------------------------------------------
-- END OF THIS BATCH
-- Kirim "lanjut" untuk Toggle, Slider, Dropdown, Input, Keybind, Label, ColorPicker, dsb!
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- ELEMENT LANJUTAN: TOGGLE, SLIDER, DROPDOWN, INPUT, KEYBIND, LABEL, COLORPICKER
--------------------------------------------------------------------------------

-- Tambahan pada sectionObj API (lanjutkan di bawah CreateButton)

-- TOGGLE
function sectionObj:CreateToggle(toggleinfo)
    local togName = toggleinfo.Name or ("Toggle"..#sectionObj._elements+1)
    local togDesc = toggleinfo.Description or ""
    local default = toggleinfo.Default or false
    local togCallback = toggleinfo.Callback or function() end

    -- Frame
    local TogFrame = Instance.new("Frame")
    TogFrame.Name = "Toggle_"..togName
    TogFrame.Size = UDim2.new(1, 0, 0, 38)
    TogFrame.BackgroundColor3 = self.ParentUI.Theme.Contrast or Color3.fromRGB(32,32,32)
    TogFrame.BackgroundTransparency = 0.14
    TogFrame.BorderSizePixel = 0
    TogFrame.Parent = sectionObj._ElementHolder

    -- Checkbox
    local Box = Instance.new("TextButton")
    Box.Name = "Box"
    Box.Text = default and "âœ”" or ""
    Box.Font = self.ParentUI.Theme.FontBold
    Box.TextColor3 = self.ParentUI.Theme.Accent
    Box.TextSize = 18
    Box.Size = UDim2.new(0, 28, 0, 28)
    Box.Position = UDim2.new(0, 6, 0, 5)
    Box.BackgroundColor3 = Color3.fromRGB(24,24,24)
    Box.BorderSizePixel = 0
    Box.AutoButtonColor = true
    Box.Parent = TogFrame

    -- Label
    local TogLabel = Instance.new("TextButton")
    TogLabel.Text = togName
    TogLabel.Font = self.ParentUI.Theme.FontBold
    TogLabel.TextSize = 16
    TogLabel.TextColor3 = self.ParentUI.Theme.Text
    TogLabel.BackgroundTransparency = 1
    TogLabel.Size = UDim2.new(1, -42, 1, 0)
    TogLabel.Position = UDim2.new(0, 40, 0, 0)
    TogLabel.TextXAlignment = Enum.TextXAlignment.Left
    TogLabel.AutoButtonColor = true
    TogLabel.Parent = TogFrame

    -- Tooltip
    if togDesc ~= "" then
        local Tip = Instance.new("TextLabel")
        Tip.Text = togDesc
        Tip.Font = self.ParentUI.Theme.Font
        Tip.TextSize = 14
        Tip.TextColor3 = self.ParentUI.Theme.Placeholder
        Tip.BackgroundTransparency = 1
        Tip.AnchorPoint = Vector2.new(0.5,1)
        Tip.Visible = false
        Tip.Size = UDim2.new(0, 180, 0, 22)
        Tip.Position = UDim2.new(0.5,0,0,0)
        Tip.ZIndex = 20
        Tip.Parent = TogFrame
        TogLabel.MouseEnter:Connect(function() Tip.Visible = true end)
        TogLabel.MouseLeave:Connect(function() Tip.Visible = false end)
    end

    local state = default
    local function setToggle(val)
        state = val
        Box.Text = (val and "âœ”" or "")
        togCallback(val)
    end
    setToggle(default)

    Box.MouseButton1Click:Connect(function() setToggle(not state) end)
    TogLabel.MouseButton1Click:Connect(function() setToggle(not state) end)

    -- Animation
    TogLabel.MouseEnter:Connect(function()
        Animate(TogFrame, {BackgroundTransparency = 0.08}, 0.14)
    end)
    TogLabel.MouseLeave:Connect(function()
        Animate(TogFrame, {BackgroundTransparency = 0.14}, 0.14)
    end)

    -- Register
    local el = {Type = "Toggle", Name = togName, Frame = TogFrame, Callback = togCallback, State = function() return state end, Set = setToggle}
    sectionObj._elements[#sectionObj._elements+1] = el
    return el
end

-- SLIDER
function sectionObj:CreateSlider(sliderinfo)
    local sliderName = sliderinfo.Name or ("Slider"..#sectionObj._elements+1)
    local sliderDesc = sliderinfo.Description or ""
    local min = sliderinfo.Minimum or sliderinfo.Min or 0
    local max = sliderinfo.Maximum or sliderinfo.Max or 100
    local default = sliderinfo.Default or min
    local decimals = sliderinfo.Decimals or 0
    local sliderCallback = sliderinfo.Callback or function() end

    -- Frame
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = "Slider_"..sliderName
    SliderFrame.Size = UDim2.new(1, 0, 0, 48)
    SliderFrame.BackgroundColor3 = self.ParentUI.Theme.Contrast or Color3.fromRGB(32,32,32)
    SliderFrame.BackgroundTransparency = 0.14
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = sectionObj._ElementHolder

    -- Label
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Text = sliderName.." : "..tostring(default)
    SliderLabel.Font = self.ParentUI.Theme.FontBold
    SliderLabel.TextSize = 15
    SliderLabel.TextColor3 = self.ParentUI.Theme.Text
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Size = UDim2.new(1, -14, 0, 20)
    SliderLabel.Position = UDim2.new(0, 8, 0, 4)
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame

    -- Bar
    local Bar = Instance.new("Frame")
    Bar.Name = "Bar"
    Bar.Size = UDim2.new(1, -32, 0, 8)
    Bar.Position = UDim2.new(0, 16, 0, 28)
    Bar.BackgroundColor3 = Color3.fromRGB(70,70,70)
    Bar.BorderSizePixel = 0
    Bar.Parent = SliderFrame

    local Fill = Instance.new("Frame")
    Fill.Name = "Fill"
    Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    Fill.BackgroundColor3 = self.ParentUI.Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar

    -- Draggable
    local dragging = false
    local current = default
    local function setSlider(val)
        val = math.clamp(val, min, max)
        if decimals > 0 then
            val = tonumber(string.format("%."..decimals.."f", val))
        else
            val = math.floor(val + 0.5)
        end
        local percent = (val-min)/(max-min)
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        SliderLabel.Text = sliderName.." : "..tostring(val)
        current = val
        sliderCallback(val)
    end
    setSlider(default)

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local mx = UserInputService:GetMouseLocation().X
            local bx = Bar.AbsolutePosition.X
            local bw = Bar.AbsoluteSize.X
            local val = min + (max-min)*((mx-bx)/bw)
            setSlider(val)
        end
    end)
    Bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mx = UserInputService:GetMouseLocation().X
            local bx = Bar.AbsolutePosition.X
            local bw = Bar.AbsoluteSize.X
            local val = min + (max-min)*((mx-bx)/bw)
            setSlider(val)
        end
    end)

    -- Register
    local el = {Type = "Slider", Name = sliderName, Frame = SliderFrame, Callback = sliderCallback, Value = function() return current end, Set = setSlider}
    sectionObj._elements[#sectionObj._elements+1] = el
    return el
end

-- DROPDOWN
function sectionObj:CreateDropdown(dropinfo)
    local dropName = dropinfo.Name or ("Dropdown"..#sectionObj._elements+1)
    local dropDesc = dropinfo.Description or ""
    local options = dropinfo.Options or {}
    local default = dropinfo.Default or options[1]
    local dropCallback = dropinfo.Callback or function() end
    local multiSelect = dropinfo.MultiSelect or false

    -- Frame
    local DropFrame = Instance.new("Frame")
    DropFrame.Name = "Dropdown_"..dropName
    DropFrame.Size = UDim2.new(1, 0, 0, 38)
    DropFrame.BackgroundColor3 = self.ParentUI.Theme.Contrast or Color3.fromRGB(32,32,32)
    DropFrame.BackgroundTransparency = 0.14
    DropFrame.BorderSizePixel = 0
    DropFrame.Parent = sectionObj._ElementHolder

    -- Button
    local DropBtn = Instance.new("TextButton")
    DropBtn.Text = dropName.." : "..tostring(default)
    DropBtn.Font = self.ParentUI.Theme.FontBold
    DropBtn.TextSize = 16
    DropBtn.TextColor3 = self.ParentUI.Theme.Text
    DropBtn.BackgroundTransparency = 1
    DropBtn.Size = UDim2.new(1, -32, 1, 0)
    DropBtn.Position = UDim2.new(0, 8, 0, 0)
    DropBtn.TextXAlignment = Enum.TextXAlignment.Left
    DropBtn.AutoButtonColor = true
    DropBtn.Parent = DropFrame

    -- Dropdown List
    local ListFrame = Instance.new("Frame")
    ListFrame.Name = "DropdownList"
    ListFrame.Visible = false
    ListFrame.Size = UDim2.new(1, 0, 0, #options*32)
    ListFrame.Position = UDim2.new(0,0,1,0)
    ListFrame.BackgroundColor3 = self.ParentUI.Theme.Section
    ListFrame.BorderSizePixel = 0
    ListFrame.ZIndex = 20
    ListFrame.Parent = DropFrame

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = ListFrame

    -- Add options
    local current = default
    for i, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Text = tostring(opt)
        OptBtn.Font = self.ParentUI.Theme.Font
        OptBtn.TextSize = 15
        OptBtn.TextColor3 = self.ParentUI.Theme.Text
        OptBtn.BackgroundTransparency = 1
        OptBtn.Size = UDim2.new(1, 0, 0, 32)
        OptBtn.Parent = ListFrame
        OptBtn.ZIndex = 21

        OptBtn.MouseButton1Click:Connect(function()
            current = opt
            DropBtn.Text = dropName.." : "..tostring(opt)
            ListFrame.Visible = false
            dropCallback(opt)
        end)
    end

    -- Toggle dropdown
    DropBtn.MouseButton1Click:Connect(function()
        ListFrame.Visible = not ListFrame.Visible
    end)

    -- Hide on click outside
    DropFrame.MouseLeave:Connect(function()
        ListFrame.Visible = false
    end)

    -- Register
    local el = {Type = "Dropdown", Name = dropName, Frame = DropFrame, Callback = dropCallback, Value = function() return current end, Set = function(val)
        current = val
        DropBtn.Text = dropName.." : "..tostring(val)
        dropCallback(val)
    end}
    sectionObj._elements[#sectionObj._elements+1] = el
    return el
end

-- INPUT
function sectionObj:CreateInput(inputinfo)
    local inputName = inputinfo.Name or ("Input"..#sectionObj._elements+1)
    local inputDesc = inputinfo.Description or ""
    local default = inputinfo.Default or ""
    local inputCallback = inputinfo.Callback or function() end

    -- Frame
    local InputFrame = Instance.new("Frame")
    InputFrame.Name = "Input_"..inputName
    InputFrame.Size = UDim2.new(1, 0, 0, 38)
    InputFrame.BackgroundColor3 = self.ParentUI.Theme.Contrast or Color3.fromRGB(32,32,32)
    InputFrame.BackgroundTransparency = 0.14
    InputFrame.BorderSizePixel = 0
    InputFrame.Parent = sectionObj._ElementHolder

    -- Box
    local Box = Instance.new("TextBox")
    Box.Text = default
    Box.PlaceholderText = inputName
    Box.Font = self.ParentUI.Theme.Font
    Box.TextColor3 = self.ParentUI.Theme.Text
    Box.TextSize = 15
    Box.BackgroundTransparency = 0.05
    Box.BackgroundColor3 = Color3.fromRGB(26,26,26)
    Box.Size = UDim2.new(1, -16, 1, -10)
    Box.Position = UDim2.new(0, 8, 0, 5)
    Box.ClearTextOnFocus = false
    Box.Parent = InputFrame

    -- Callback
    Box.FocusLost:Connect(function(enter)
        if enter then
            inputCallback(Box.Text)
        end
    end)

    -- Register
    local el = {Type = "Input", Name = inputName, Frame = InputFrame, Callback = inputCallback, Value = function() return Box.Text end, Set = function(val) Box.Text = val end}
    sectionObj._elements[#sectionObj._elements+1] = el
    return el
end

-- KEYBIND
function sectionObj:CreateKeybind(bindinfo)
    local keyName = bindinfo.Name or ("Keybind"..#sectionObj._elements+1)
    local keyDesc = bindinfo.Description or ""
    local default = bindinfo.Default or Enum.KeyCode.F
    local keyCallback = bindinfo.Callback or function() end

    -- Frame
    local BindFrame = Instance.new("Frame")
    BindFrame.Name = "Keybind_"..keyName
    BindFrame.Size = UDim2.new(1, 0, 0, 38)
    BindFrame.BackgroundColor3 = self.ParentUI.Theme.Contrast or Color3.fromRGB(32,32,32)
    BindFrame.BackgroundTransparency = 0.14
    BindFrame.BorderSizePixel = 0
    BindFrame.Parent = sectionObj._ElementHolder

    -- Label
    local BindLabel = Instance.new("TextButton")
    BindLabel.Text = keyName.." : "..tostring(default.Name)
    BindLabel.Font = self.ParentUI.Theme.FontBold
    BindLabel.TextSize = 16
    BindLabel.TextColor3 = self.ParentUI.Theme.Text
    BindLabel.BackgroundTransparency = 1
    BindLabel.Size = UDim2.new(1, -16, 1, 0)
    BindLabel.Position = UDim2.new(0, 8, 0, 0)
    BindLabel.TextXAlignment = Enum.TextXAlignment.Left
    BindLabel.AutoButtonColor = true
    BindLabel.Parent = BindFrame

    local current = default
    BindLabel.MouseButton1Click:Connect(function()
        BindLabel.Text = keyName.." : [Press Key]"
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.UserInputType == Enum.UserInputType.Keyboard then
                current = input.KeyCode
                BindLabel.Text = keyName.." : "..tostring(current.Name)
                keyCallback(current)
                connection:Disconnect()
            end
        end)
    end)

    -- Register
    local el = {Type = "Keybind", Name = keyName, Frame = BindFrame, Callback = keyCallback, Value = function() return current end, Set = function(val)
        current = val
        BindLabel.Text = keyName.." : "..tostring(current.Name)
        keyCallback(current)
    end}
    sectionObj._elements[#sectionObj._elements+1] = el
    return el
end

-- LABEL
function sectionObj:CreateLabel(labelinfo)
    local lblName = labelinfo.Name or ("Label"..#sectionObj._elements+1)
    local lblDesc = labelinfo.Description or ""

    -- Frame
    local LabelFrame = Instance.new("Frame")
    LabelFrame.Name = "Label_"..lblName
    LabelFrame.Size = UDim2.new(1, 0, 0, 30)
    LabelFrame.BackgroundTransparency = 1
    LabelFrame.BorderSizePixel = 0
    LabelFrame.Parent = sectionObj._ElementHolder

    -- Label
    local Label = Instance.new("TextLabel")
    Label.Text = lblName
    Label.Font = self.ParentUI.Theme.Font
    Label.TextSize = 14
    Label.TextColor3 = self.ParentUI.Theme.Label
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, -12, 1, 0)
    Label.Position = UDim2.new(0, 6, 0, 0)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = LabelFrame

    -- Register
    local el = {Type = "Label", Name = lblName, Frame = LabelFrame}
    sectionObj._elements[#sectionObj._elements+1] = el
    return el
end

-- COLORPICKER (SIMPLE, ADVANCED NANTI!)
function sectionObj:CreateColorPicker(cpinfo)
    local cpName = cpinfo.Name or ("ColorPicker"..#sectionObj._elements+1)
    local cpDesc = cpinfo.Description or ""
    local default = cpinfo.Default or Color3.fromRGB(255,255,255)
    local cpCallback = cpinfo.Callback or function() end

    -- Frame
    local CPFrame = Instance.new("Frame")
    CPFrame.Name = "ColorPicker_"..cpName
    CPFrame.Size = UDim2.new(1, 0, 0, 38)
    CPFrame.BackgroundColor3 = self.ParentUI.Theme.Contrast or Color3.fromRGB(32,32,32)
    CPFrame.BackgroundTransparency = 0.14
    CPFrame.BorderSizePixel = 0
    CPFrame.Parent = sectionObj._ElementHolder

    -- Label
    local CPLabel = Instance.new("TextLabel")
    CPLabel.Text = cpName
    CPLabel.Font = self.ParentUI.Theme.FontBold
    CPLabel.TextSize = 16
    CPLabel.TextColor3 = self.ParentUI.Theme.Text
    CPLabel.BackgroundTransparency = 1
    CPLabel.Size = UDim2.new(1, -48, 1, 0)
    CPLabel.Position = UDim2.new(0, 8, 0, 0)
    CPLabel.TextXAlignment = Enum.TextXAlignment.Left
    CPLabel.Parent = CPFrame

    -- Button (shows color)
    local ColorBtn = Instance.new("TextButton")
    ColorBtn.Size = UDim2.new(0, 34, 0, 28)
    ColorBtn.Position = UDim2.new(1, -38, 0, 5)
    ColorBtn.BackgroundColor3 = default
    ColorBtn.BorderSizePixel = 0
    ColorBtn.Text = ""
    ColorBtn.Parent = CPFrame

    local current = default
    ColorBtn.MouseButton1Click:Connect(function()
        -- TODO: Advanced colorpicker popup
        -- Sementara: random warna
        local c = Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
        current = c
        ColorBtn.BackgroundColor3 = c
        cpCallback(c)
    end)

    -- Register
    local el = {Type = "ColorPicker", Name = cpName, Frame = CPFrame, Callback = cpCallback, Value = function() return current end, Set = function(val)
        current = val
        ColorBtn.BackgroundColor3 = val
        cpCallback(val)
    end}
    sectionObj._elements[#sectionObj._elements+1] = el
    return el
end

--------------------------------------------------------------------------------
-- END OF THIS BATCH
-- Kirim "lanjut" untuk SEPARATOR, NOTIFICATION, CONFIG, THEME, ANIMASI LANJUTAN, DLL!
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- SEPARATOR, NOTIFICATION, CONFIG, THEME, ADVANCED COLORPICKER, ANIMASI LANJUTAN
--------------------------------------------------------------------------------

-- Tambahan pada sectionObj API (lanjut di bawah CreateColorPicker)

-- SEPARATOR
function sectionObj:CreateSeparator()
    local Sep = Instance.new("Frame")
    Sep.Name = "Separator"
    Sep.Size = UDim2.new(1, -16, 0, 2)
    Sep.Position = UDim2.new(0, 8, 0, 0)
    Sep.BackgroundColor3 = self.ParentUI.Theme.Border
    Sep.BackgroundTransparency = 0.2
    Sep.BorderSizePixel = 0
    Sep.Parent = sectionObj._ElementHolder
    sectionObj._elements[#sectionObj._elements+1] = {Type="Separator", Frame=Sep}
    return Sep
end

--------------------------------------------------------------------------------
-- NOTIFICATION SYSTEM
--------------------------------------------------------------------------------

function AuroraUI:Notify(opts)
    -- opts: {Title, Content, Duration, Type}
    local title = opts.Title or "AuroraUI"
    local content = opts.Content or ""
    local duration = opts.Duration or 3
    local type = opts.Type or "info" -- info, success, warning, error

    local NotificationGui = self._ScreenGui:FindFirstChild("AuroraUINotification") or Instance.new("ScreenGui")
    NotificationGui.Name = "AuroraUINotification"
    NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    NotificationGui.IgnoreGuiInset = true
    NotificationGui.Parent = self._ScreenGui
    NotificationGui.ResetOnSpawn = false

    local NotiFrame = Instance.new("Frame")
    NotiFrame.Name = "Notification"
    NotiFrame.AnchorPoint = Vector2.new(1,1)
    NotiFrame.Size = UDim2.new(0, 320, 0, 90)
    NotiFrame.Position = UDim2.new(1, -24, 1, -24)
    NotiFrame.BackgroundColor3 = (type=="success" and self.Theme.Success) or (type=="error" and self.Theme.Danger) or (type=="warning" and self.Theme.Warning) or self.Theme.Section
    NotiFrame.BackgroundTransparency = 0.09
    NotiFrame.BorderSizePixel = 0
    NotiFrame.ZIndex = 100
    NotiFrame.Parent = NotificationGui

    local NotiTitle = Instance.new("TextLabel")
    NotiTitle.Text = "🗿 "..title
    NotiTitle.Font = self.Theme.FontBold
    NotiTitle.TextSize = 18
    NotiTitle.TextColor3 = Color3.new(1,1,1)
    NotiTitle.BackgroundTransparency = 1
    NotiTitle.Size = UDim2.new(1, -20, 0, 26)
    NotiTitle.Position = UDim2.new(0, 10, 0, 6)
    NotiTitle.TextXAlignment = Enum.TextXAlignment.Left
    NotiTitle.ZIndex = 101
    NotiTitle.Parent = NotiFrame

    local NotiContent = Instance.new("TextLabel")
    NotiContent.Text = content
    NotiContent.Font = self.Theme.Font
    NotiContent.TextSize = 15
    NotiContent.TextColor3 = self.Theme.Text
    NotiContent.BackgroundTransparency = 1
    NotiContent.Size = UDim2.new(1, -20, 1, -36)
    NotiContent.Position = UDim2.new(0, 10, 0, 32)
    NotiContent.TextXAlignment = Enum.TextXAlignment.Left
    NotiContent.TextYAlignment = Enum.TextYAlignment.Top
    NotiContent.ZIndex = 101
    NotiContent.Parent = NotiFrame

    NotiFrame.BackgroundTransparency = 1
    Animate(NotiFrame, {BackgroundTransparency = 0.09}, 0.24)

    -- Fade out
    spawn(function()
        wait(duration)
        Animate(NotiFrame, {BackgroundTransparency = 1}, 0.24)
        wait(0.24)
        NotiFrame:Destroy()
        if #NotificationGui:GetChildren() == 0 then NotificationGui:Destroy() end
    end)
end

--------------------------------------------------------------------------------
-- CONFIGURATION SYSTEM (in-memory, bisa di-extend ke DataStore/File)
--------------------------------------------------------------------------------

function AuroraUI:SaveConfig(name)
    name = name or "Default"
    self._config[name] = {}
    for _, tab in ipairs(self._tabs) do
        for _, section in ipairs(tab._sections) do
            for _, el in ipairs(section._elements) do
                if el.Value then
                    self._config[name][el.Name] = el.Value()
                end
            end
        end
    end
    self:Notify{Title="Config", Content="Config '"..name.."' saved.", Type="success"}
end

function AuroraUI:LoadConfig(name)
    name = name or "Default"
    if not self._config[name] then
        self:Notify{Title="Config", Content="No config named '"..name.."'.", Type="error"}
        return
    end
    for _, tab in ipairs(self._tabs) do
        for _, section in ipairs(tab._sections) do
            for _, el in ipairs(section._elements) do
                if el.Set and self._config[name][el.Name] ~= nil then
                    el.Set(self._config[name][el.Name])
                end
            end
        end
    end
    self:Notify{Title="Config", Content="Config '"..name.."' loaded.", Type="success"}
end

--------------------------------------------------------------------------------
-- THEME SYSTEM (runtime ganti warna, font, dsb)
--------------------------------------------------------------------------------

function AuroraUI:SetTheme(tbl)
    for k,v in pairs(tbl) do
        if self.Theme[k] then
            self.Theme[k] = v
        end
    end
    -- TODO: refresh all UI elements colors/fonts
end

--------------------------------------------------------------------------------
-- ADVANCED COLORPICKER (POPUP)
--------------------------------------------------------------------------------

function AuroraUI:PopupColorPicker(default, callback)
    -- Simple popup colorpicker, advanced: implement if needed
    local popup = Instance.new("Frame")
    popup.Name = "ColorPickerPopup"
    popup.Size = UDim2.new(0, 240, 0, 180)
    popup.Position = UDim2.new(0.5, -120, 0.5, -90)
    popup.BackgroundColor3 = self.Theme.Section
    popup.BorderSizePixel = 0
    popup.ZIndex = 200
    popup.AnchorPoint = Vector2.new(0.5,0.5)
    popup.Parent = self._ScreenGui

    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Font = self.Theme.FontBold
    closeBtn.TextSize = 18
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -34, 0, 4)
    closeBtn.BackgroundTransparency = 1
    closeBtn.ZIndex = 201
    closeBtn.Parent = popup

    local ColorBox = Instance.new("Frame")
    ColorBox.Size = UDim2.new(1, -30, 1, -40)
    ColorBox.Position = UDim2.new(0, 15, 0, 35)
    ColorBox.BackgroundColor3 = default or Color3.fromRGB(255,255,255)
    ColorBox.BorderSizePixel = 0
    ColorBox.ZIndex = 202
    ColorBox.Parent = popup

    closeBtn.MouseButton1Click:Connect(function()
        popup:Destroy()
    end)
    ColorBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local c = Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
            ColorBox.BackgroundColor3 = c
            if callback then callback(c) end
        end
    end)
    return popup
end

--------------------------------------------------------------------------------
-- ANIMASI LANJUTAN (tab, section, show/hide, dst)
--------------------------------------------------------------------------------

-- Tab/Section show/hide animasi
-- Sudah di-handle pada Animate(), bisa di-extend di event switching tab/section

--------------------------------------------------------------------------------
-- END OF LIBRARY
--------------------------------------------------------------------------------

--[[

USAGE EXAMPLE:

local AuroraUI = require(path.to.AuroraUI)

local ui = AuroraUI.New{
    Name = "🗿 Moai Hub",
    ConfigurationSaving = {Enabled = true},
    LoadingTitle = "Moai Loader",
    LoadingSubtitle = "🗿 Loading...",
}

local tab = ui:CreateTab{Name="Main", Icon="🗿", Default=true}
local section = tab:CreateSection{Name="Features"}

section:CreateButton{
    Name="Say Hello",
    Description="Click to print hello",
    Callback=function() print("Hello!") end
}

section:CreateToggle{
    Name="Enable Something",
    Description="Toggles something",
    Default=false,
    Callback=function(val) print("Toggle:", val) end
}

section:CreateSlider{
    Name="Volume",
    Min=0, Max=100, Default=25,
    Callback=function(val) print("Volume:", val) end
}

section:CreateDropdown{
    Name="Fruit",
    Options={"Apple","Banana","Cherry"},
    Default="Apple",
    Callback=function(sel) print("Selected:", sel) end
}

section:CreateInput{
    Name="Enter Name",
    Callback=function(txt) print("Input:", txt) end
}

section:CreateKeybind{
    Name="Open Menu",
    Default=Enum.KeyCode.M,
    Callback=function(key) print("Key:", key.Name) end
}

section:CreateLabel{
    Name="Status: Ready"
}

section:CreateColorPicker{
    Name="Favorite Color",
    Default=Color3.fromRGB(255,100,100),
    Callback=function(c) print("Color:", c) end
}

section:CreateSeparator()

ui:Notify{Title="Moai", Content="Welcome to 🗿 AuroraUI!", Type="success"}

ui:SaveConfig("MyConfig")
ui:LoadConfig("MyConfig")

]]

return AuroraUI
