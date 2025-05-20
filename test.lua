--[[
    RedzUI All-in-One (Gabungan Semua Komponen UI) - Roblox
    Versi: 2.0
    Author: Copilot + arakugphonevrj
--]]

-- Service references
local Services = {
    MarketplaceService = game:GetService("MarketplaceService"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    HttpService = game:GetService("HttpService"),
    RunService = game:GetService("RunService"),
    CoreGui = game:GetService("CoreGui"),
    Players = game:GetService("Players"),
}

local Player = Services.Players.LocalPlayer
local Mouse = Player and Player:GetMouse()
local Camera = workspace.CurrentCamera

-------------------------------------------------------------------------------
-- RedzUI Core
-------------------------------------------------------------------------------
local RedzUI = {
    Version = "2.0.0",
    Theme = {
        Default = {
            Background = Color3.fromRGB(32, 34, 37),
            Accent = Color3.fromRGB(88, 101, 242),
            Border = Color3.fromRGB(40, 40, 40),
            Text = Color3.fromRGB(240, 240, 240),
            SubText = Color3.fromRGB(180, 180, 180),
        },
        Light = {
            Background = Color3.fromRGB(230, 230, 230),
            Accent = Color3.fromRGB(88, 101, 242),
            Border = Color3.fromRGB(180, 180, 180),
            Text = Color3.fromRGB(25, 25, 25),
            SubText = Color3.fromRGB(100, 100, 100),
        },
        Purple = {
            Background = Color3.fromRGB(40, 34, 56),
            Accent = Color3.fromRGB(150, 0, 255),
            Border = Color3.fromRGB(60, 40, 80),
            Text = Color3.fromRGB(230, 230, 255),
            SubText = Color3.fromRGB(190, 180, 220),
        }
    },
    Icons = {
        ["settings"] = "rbxassetid://10734950309",
        ["user"] = "rbxassetid://10747373176",
        ["home"] = "rbxassetid://10723407389",
        ["save"] = "rbxassetid://10734941499",
        ["search"] = "rbxassetid://10734943674",
        -- Tambahkan sesuai kebutuhan
    },
    Config = {
        WindowSize = Vector2.new(600, 400),
        Theme = "Default"
    },
    _instances = {},
    _flags = {},
    _connections = {},
}

function RedzUI:SetTheme(name)
    if self.Theme[name] then
        self.Config.Theme = name
        return true
    end
    return false
end

function RedzUI:GetThemeColor(key)
    local theme = self.Theme[self.Config.Theme] or self.Theme.Default
    return theme[key] or Color3.new(1,1,1)
end

function RedzUI:GetIcon(name)
    return self.Icons[name] or ""
end

function RedzUI:SaveConfig(file)
    if writefile then
        local data = {
            WindowSize = {self.Config.WindowSize.X, self.Config.WindowSize.Y},
            Theme = self.Config.Theme,
        }
        writefile(file or "RedzUI-Config.json", Services.HttpService:JSONEncode(data))
    end
end

function RedzUI:LoadConfig(file)
    if readfile and isfile and isfile(file or "RedzUI-Config.json") then
        local data = Services.HttpService:JSONDecode(readfile(file or "RedzUI-Config.json"))
        if type(data) == "table" then
            if type(data.WindowSize) == "table" then
                self.Config.WindowSize = Vector2.new(data.WindowSize[1], data.WindowSize[2])
            end
            if data.Theme and self.Theme[data.Theme] then
                self.Config.Theme = data.Theme
            end
        end
    end
end

function RedzUI:Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end
    table.insert(self._instances, inst)
    return inst
end

-------------------------------------------------------------------------------
-- Window & Tab System
-------------------------------------------------------------------------------
local Window = {}
Window.__index = Window

function RedzUI:Window(title, options)
    options = options or {}
    local self = setmetatable({}, Window)

    self.Title = title or "RedzUI"
    self.Size = options.Size or RedzUI.Config.WindowSize or Vector2.new(600, 400)
    self.Theme = options.Theme or RedzUI.Config.Theme or "Default"
    self.Tabs = {}

    self.ScreenGui = RedzUI:Create("ScreenGui", {
        Name = "RedzUI_Main",
        ResetOnSpawn = false,
        Parent = game:GetService("CoreGui")
    })

    self.MainFrame = RedzUI:Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, self.Size.X, 0, self.Size.Y),
        Position = UDim2.new(0.5, -self.Size.X/2, 0.5, -self.Size.Y/2),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = RedzUI:GetThemeColor("Background"),
        BorderColor3 = RedzUI:GetThemeColor("Border"),
        Parent = self.ScreenGui
    })

    self.TitleLabel = RedzUI:Create("TextLabel", {
        Name = "TitleLabel",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = self.Title,
        Font = Enum.Font.GothamBold,
        TextColor3 = RedzUI:GetThemeColor("Text"),
        TextSize = 24,
        Parent = self.MainFrame
    })

    self.TabHolder = RedzUI:Create("Frame", {
        Name = "TabHolder",
        Size = UDim2.new(0, 120, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = self.MainFrame
    })

    self.TabList = RedzUI:Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.TabHolder
    })

    self.ContentHolder = RedzUI:Create("Frame", {
        Name = "ContentHolder",
        Size = UDim2.new(1, -120, 1, -40),
        Position = UDim2.new(0, 120, 0, 40),
        BackgroundTransparency = 1,
        Parent = self.MainFrame
    })

    return self
end

function Window:AddTab(tabName, iconName)
    local tab = {}

    tab.Name = tabName
    tab.Icon = RedzUI:GetIcon(iconName or "home")
    tab.Button = RedzUI:Create("TextButton", {
        Name = tabName.."_TabButton",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = RedzUI:GetThemeColor("Accent"),
        BorderSizePixel = 0,
        Text = "   " .. tabName,
        Font = Enum.Font.Gotham,
        TextColor3 = RedzUI:GetThemeColor("Text"),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TabHolder,
        AutoButtonColor = true
    })

    local icon = RedzUI:Create("ImageLabel", {
        Name = "Icon",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 4, 0.5, -12),
        BackgroundTransparency = 1,
        Image = tab.Icon,
        Parent = tab.Button
    })

    tab.ContentFrame = RedzUI:Create("Frame", {
        Name = tabName.."_Content",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self.ContentHolder
    })

    tab.Button.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            if t.ContentFrame then t.ContentFrame.Visible = false end
        end
        tab.ContentFrame.Visible = true
    end)

    if #self.Tabs == 0 then
        tab.ContentFrame.Visible = true
    end

    table.insert(self.Tabs, tab)
    return tab
end

-------------------------------------------------------------------------------
-- Komponen Dasar: Button, Toggle, Input
-------------------------------------------------------------------------------
function RedzUI:Button(parent, props)
    local btn = RedzUI:Create("TextButton", {
        Name = props.Name or "Button",
        Size = props.Size or UDim2.new(0, 160, 0, 36),
        BackgroundColor3 = RedzUI:GetThemeColor("Accent"),
        BorderSizePixel = 0,
        Text = props.Text or "Button",
        Font = Enum.Font.GothamBold,
        TextColor3 = RedzUI:GetThemeColor("Text"),
        Parent = parent
    })
    if props.Callback then
        btn.MouseButton1Click:Connect(props.Callback)
    end
    return btn
end

function RedzUI:Toggle(parent, props)
    local value = props.Default or false
    local frame = RedzUI:Create("Frame", {
        Name = props.Name or "Toggle",
        Size = props.Size or UDim2.new(0, 160, 0, 36),
        BackgroundTransparency = 1,
        Parent = parent
    })
    local box = RedzUI:Create("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(0, 0, 0.5, -16),
        BackgroundColor3 = value and RedzUI:GetThemeColor("Accent") or RedzUI:GetThemeColor("Border"),
        BorderSizePixel = 0,
        Text = value and "✔" or "",
        Font = Enum.Font.GothamBold,
        TextColor3 = RedzUI:GetThemeColor("Text"),
        Parent = frame
    })
    local label = RedzUI:Create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        BackgroundTransparency = 1,
        Text = props.Text or "Toggle",
        Font = Enum.Font.Gotham,
        TextColor3 = RedzUI:GetThemeColor("Text"),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    box.MouseButton1Click:Connect(function()
        value = not value
        box.BackgroundColor3 = value and RedzUI:GetThemeColor("Accent") or RedzUI:GetThemeColor("Border")
        box.Text = value and "✔" or ""
        if props.Callback then
            props.Callback(value)
        end
    end)
    return frame
end

function RedzUI:Input(parent, props)
    local frame = RedzUI:Create("Frame", {
        Name = props.Name or "Input",
        Size = props.Size or UDim2.new(0, 200, 0, 36),
        BackgroundTransparency = 1,
        Parent = parent
    })
    local box = RedzUI:Create("TextBox", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = RedzUI:GetThemeColor("Border"),
        BorderSizePixel = 0,
        Text = props.Default or "",
        Font = Enum.Font.Gotham,
        TextColor3 = RedzUI:GetThemeColor("Text"),
        PlaceholderText = props.Placeholder or "Type here...",
        Parent = frame
    })
    if props.Callback then
        box.FocusLost:Connect(function(enter)
            if enter then
                props.Callback(box.Text)
            end
        end)
    end
    return frame
end

-------------------------------------------------------------------------------
-- Slider & Dropdown
-------------------------------------------------------------------------------
function RedzUI:Slider(parent, props)
    local min = props.Min or 0
    local max = props.Max or 100
    local value = props.Default or min

    local frame = RedzUI:Create("Frame", {
        Name = props.Name or "Slider",
        Size = props.Size or UDim2.new(0, 200, 0, 40),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local label = RedzUI:Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = (props.Text or "Slider") .. ": " .. tostring(value),
        Font = Enum.Font.Gotham,
        TextColor3 = RedzUI:GetThemeColor("Text"),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })

    local bar = RedzUI:Create("Frame", {
        Size = UDim2.new(1, -16, 0, 8),
        Position = UDim2.new(0, 8, 0, 28),
        BackgroundColor3 = RedzUI:GetThemeColor("Border"),
        BorderSizePixel = 0,
        Parent = frame
    })

    local fill = RedzUI:Create("Frame", {
        Size = UDim2.new((value-min)/(max-min), 0, 1, 0),
        BackgroundColor3 = RedzUI:GetThemeColor("Accent"),
        BorderSizePixel = 0,
        Parent = bar
    })

    local drag = RedzUI:Create("TextButton", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new((value-min)/(max-min), -8, 0.5, -8),
        BackgroundColor3 = RedzUI:GetThemeColor("Accent"),
        BorderSizePixel = 0,
        Text = "",
        Parent = bar,
        AutoButtonColor = false
    })

    local dragging = false

    drag.MouseButton1Down:Connect(function()
        dragging = true
    end)
    Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    Services.RunService.RenderStepped:Connect(function()
        if dragging then
            local mouseX = Services.UserInputService:GetMouseLocation().X
            local barAbsPos = bar.AbsolutePosition.X
            local barAbsSize = bar.AbsoluteSize.X
            local percent = math.clamp((mouseX - barAbsPos) / barAbsSize, 0, 1)
            value = math.floor(min + (max - min) * percent + 0.5)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            drag.Position = UDim2.new(percent, -8, 0.5, -8)
            label.Text = (props.Text or "Slider") .. ": " .. tostring(value)
            if props.Callback then
                props.Callback(value)
            end
        end
    end)
    return frame
end

function RedzUI:Dropdown(parent, props)
    local options = props.Options or {}
    local selected = props.Default or options[1] or ""
    local open = false

    local frame = RedzUI:Create("Frame", {
        Name = props.Name or "Dropdown",
        Size = props.Size or UDim2.new(0, 160, 0, 36),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local main = RedzUI:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = RedzUI:GetThemeColor("Border"),
        BorderSizePixel = 0,
        Text = selected,
        Font = Enum.Font.Gotham,
        TextColor3 = RedzUI:GetThemeColor("Text"),
        Parent = frame,
        AutoButtonColor = true
    })

    local dropFrame = RedzUI:Create("Frame", {
        Size = UDim2.new(1, 0, 0, #options*28),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = RedzUI:GetThemeColor("Background"),
        BorderColor3 = RedzUI:GetThemeColor("Border"),
        Visible = false,
        Parent = frame,
        ZIndex = 2
    })

    local list = RedzUI:Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = dropFrame
    })

    for _, opt in ipairs(options) do
        local btn = RedzUI:Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = RedzUI:GetThemeColor("Border"),
            BorderSizePixel = 0,
            Text = opt,
            Font = Enum.Font.Gotham,
            TextColor3 = RedzUI:GetThemeColor("Text"),
            Parent = dropFrame
        })
        btn.MouseButton1Click:Connect(function()
            selected = opt
            main.Text = opt
            dropFrame.Visible = false
            open = false
            if props.Callback then
                props.Callback(selected)
            end
        end)
    end

    main.MouseButton1Click:Connect(function()
        open = not open
        dropFrame.Visible = open
    end)
    return frame
end

-------------------------------------------------------------------------------
-- Color Picker
-------------------------------------------------------------------------------
function RedzUI:ColorPicker(parent, props)
    local value = props.Default or Color3.new(1, 1, 1)
    local open = false

    local frame = RedzUI:Create("Frame", {
        Name = props.Name or "ColorPicker",
        Size = props.Size or UDim2.new(0, 160, 0, 36),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local button = RedzUI:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = value,
        BorderSizePixel = 0,
        Text = "",
        Parent = frame,
        AutoButtonColor = true
    })

    local popup = RedzUI:Create("Frame", {
        Size = UDim2.new(0, 180, 0, 180),
        Position = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = RedzUI:GetThemeColor("Background"),
        BorderColor3 = RedzUI:GetThemeColor("Border"),
        Visible = false,
        Parent = frame,
        ZIndex = 2
    })

    local lastColor = value
    local sliders = {}
    local function addSlider(name, color, val, yPos)
        local lbl = RedzUI:Create("TextLabel", {
            Size = UDim2.new(0, 30, 0, 24),
            Position = UDim2.new(0, 8, 0, yPos),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = color,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            Parent = popup,
            ZIndex = 3
        })
        local bar = RedzUI:Create("Frame", {
            Size = UDim2.new(0, 110, 0, 8),
            Position = UDim2.new(0, 44, 0, yPos + 6),
            BackgroundColor3 = Color3.fromRGB(60,60,60),
            BorderSizePixel = 0,
            Parent = popup,
            ZIndex = 3
        })
        local fill = RedzUI:Create("Frame", {
            Size = UDim2.new(val, 0, 1, 0),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Parent = bar,
            ZIndex = 4
        })
        local drag = RedzUI:Create("TextButton", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(val, -8, 0.5, -8),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Text = "",
            Parent = bar,
            AutoButtonColor = false,
            ZIndex = 5
        })
        sliders[name] = {bar = bar, fill = fill, drag = drag}
    end

    addSlider("R", Color3.fromRGB(255,0,0), value.R, 12)
    addSlider("G", Color3.fromRGB(0,255,0), value.G, 52)
    addSlider("B", Color3.fromRGB(0,0,255), value.B, 92)

    for _, name in ipairs({"R", "G", "B"}) do
        local s = sliders[name]
        local dragging = false
        s.drag.MouseButton1Down:Connect(function() dragging = true end)
        Services.UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        Services.RunService.RenderStepped:Connect(function()
            if dragging then
                local mouseX = Services.UserInputService:GetMouseLocation().X
                local barAbsPos = s.bar.AbsolutePosition.X
                local barAbsSize = s.bar.AbsoluteSize.X
                local percent = math.clamp((mouseX - barAbsPos) / barAbsSize, 0, 1)
                s.fill.Size = UDim2.new(percent, 0, 1, 0)
                s.drag.Position = UDim2.new(percent, -8, 0.5, -8)
                if name == "R" then value = Color3.new(percent, value.G, value.B) end
                if name == "G" then value = Color3.new(value.R, percent, value.B) end
                if name == "B" then value = Color3.new(value.R, value.G, percent) end
                button.BackgroundColor3 = value
                if props.Callback and tostring(lastColor) ~= tostring(value) then
                    lastColor = value
                    props.Callback(value)
                end
            end
        end)
    end

    button.MouseButton1Click:Connect(function()
        open = not open
        popup.Visible = open
    end)

    return frame
end

-------------------------------------------------------------------------------
-- Return RedzUI, Window untuk penggunaan OOP
-------------------------------------------------------------------------------
RedzUI.WindowClass = Window
return RedzUI
