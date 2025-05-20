-- ModernUILib.lua - All-in-One Modern Roblox GUI Library v3.0 (Mobile Optimized)
-- By Copilot, 2025 (mod by arakugphonevrj)
-- Fitur: Window, Tab, Section, Toggle, Button, Slider, Dropdown, InputBox, KeyPicker, ColorPicker,
-- List/Scrolling, Save-Load Config, Theme Manager, Modal/Popup, Notification, Auto Responsif

local ModernUILib = {}
ModernUILib.__index = ModernUILib

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

--==[ Theme Manager ]==--
local THEMES = {
    ["Dark"] = {
        Main = Color3.fromRGB(33,36,55), Accent = Color3.fromRGB(72,103,197),
        Tab = Color3.fromRGB(38,41,65), Button = Color3.fromRGB(76,62,179),
        Text = Color3.fromRGB(230,230,255), Section = Color3.fromRGB(150,180,255),
        Input = Color3.fromRGB(60,60,90), List = Color3.fromRGB(50,50,70),
        Dropdown = Color3.fromRGB(60,60,90), Scroll = Color3.fromRGB(50,60,100)
    },
    ["Light"] = {
        Main = Color3.fromRGB(240,240,255), Accent = Color3.fromRGB(90,120,220),
        Tab = Color3.fromRGB(210,210,255), Button = Color3.fromRGB(120,140,220),
        Text = Color3.fromRGB(48,48,64), Section = Color3.fromRGB(90,120,220),
        Input = Color3.fromRGB(220,220,240), List = Color3.fromRGB(210,210,255),
        Dropdown = Color3.fromRGB(200,200,220), Scroll = Color3.fromRGB(180,190,230)
    }
}
local CUR_THEME = THEMES.Dark
function ModernUILib.SetTheme(name)
    CUR_THEME = THEMES[name] or THEMES.Dark
end
function ModernUILib.GetTheme()
    return CUR_THEME
end

--==[ Utility ]==--
local function ripple(btn)
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0,0,0,0)
    circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    circle.BackgroundTransparency = 0.7
    circle.BorderSizePixel = 0
    circle.AnchorPoint = Vector2.new(0.5, 0.5)
    circle.Position = UDim2.new(0.5,0,0.5,0)
    circle.ClipsDescendants = true
    circle.ZIndex = 6
    circle.Parent = btn
    local max = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y)*1.5
    TweenService:Create(circle, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size=UDim2.new(0, max, 0, max), BackgroundTransparency=1}):Play()
    task.spawn(function() wait(0.45) circle:Destroy() end)
end

local function shadow(obj)
    local s = Instance.new("ImageLabel")
    s.Name = "Shadow"
    s.Image = "rbxassetid://1316045217"
    s.BackgroundTransparency = 1
    s.ImageTransparency = 0.7
    s.Size = UDim2.new(1,18,1,18)
    s.Position = UDim2.new(0,-9,0,-9)
    s.ZIndex = obj.ZIndex-1
    s.Parent = obj
end

local function makeDraggable(frame, dragHandle)
    local dragToggle, dragInput, start, pos
    dragHandle = dragHandle or frame
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            start = input.Position
            pos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            local delta = input.Position - start
            frame.Position = UDim2.new(pos.X.Scale, pos.X.Offset + delta.X, pos.Y.Scale, pos.Y.Offset + delta.Y)
        end
    end)
end

--==[ Save/Load Config ]==--
function ModernUILib.SaveConfig(filename, tableData)
    writefile(filename..".json", HttpService:JSONEncode(tableData))
end
function ModernUILib.LoadConfig(filename)
    if isfile(filename..".json") then
        return HttpService:JSONDecode(readfile(filename..".json"))
    else
        return {}
    end
end

--==[ Responsif Layout Helper ]==--
local function getWindowSize()
    -- Lebar 95%, tinggi 88%, posisi tengah
    return UDim2.new(0.95,0,0.88,0), UDim2.new(0.5,-0.475*workspace.CurrentCamera.ViewportSize.X,0.5,-0.44*workspace.CurrentCamera.ViewportSize.Y)
end

--==[ Main API ]==--
function ModernUILib:CreateWindow(opts)
    opts = opts or {}
    local screen = Instance.new("ScreenGui", game:GetService("CoreGui"))
    screen.Name = opts.Name or "ModernUI"
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screen.IgnoreGuiInset = true

    local winSize, winPos = getWindowSize()
    local main = Instance.new("Frame", screen)
    main.Size = winSize
    main.Position = winPos
    main.BackgroundColor3 = CUR_THEME.Main
    main.BackgroundTransparency = 0.23 -- Sedikit transparan
    main.BorderSizePixel = 0
    main.AnchorPoint = Vector2.new(0.5,0.5)
    main.Active = true
    main.ZIndex = 2

    -- Rounded corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 18)
    corner.Parent = main

    shadow(main)
    makeDraggable(main)

    -- === TOMBOL SHOW/HIDE ===
    -- Pakai tombol bulat di pojok kiri atas, emoji 🗿
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.new(0, 38, 0, 38)
    toggleBtn.Position = UDim2.new(0, 12, 0, 12)
    toggleBtn.BackgroundTransparency = 0.35
    toggleBtn.BackgroundColor3 = CUR_THEME.Accent
    toggleBtn.Text = "🗿"
    toggleBtn.Font = Enum.Font.GothamBlack
    toggleBtn.TextSize = 26
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.Parent = screen
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1,0)
    btnCorner.Parent = toggleBtn
    toggleBtn.ZIndex = 100

    local hidden = false
    toggleBtn.MouseButton1Click:Connect(function()
        hidden = not hidden
        main.Visible = not hidden
    end)

    -- Jika mau: hide GUI via RightShift juga (opsional, untuk test di PC/dev)
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.RightShift then
            hidden = not hidden
            main.Visible = not hidden
        end
    end)
    
    local titleBar = Instance.new("Frame", main)
    titleBar.Size = UDim2.new(1,0,0,38)
    titleBar.BackgroundColor3 = CUR_THEME.Accent
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 3

    local title = Instance.new("TextLabel", titleBar)
    title.Text = (opts.Name or "Modern UI")..(opts.Subtitle and (" - "..opts.Subtitle) or "")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1,0,1,0)
    title.TextColor3 = CUR_THEME.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Position = UDim2.new(0,14,0,0)
    title.ZIndex = 4

    local tabBar = Instance.new("Frame", main)
    tabBar.Size = UDim2.new(0,120,1,-38)
    tabBar.Position = UDim2.new(0,0,0,38)
    tabBar.BackgroundColor3 = CUR_THEME.Tab
    tabBar.BorderSizePixel = 0
    tabBar.ZIndex = 3

    main.ChildAdded:Connect(function(child)
        if child:IsA("Frame") and child.Name:find("^TAB_") then
            child.Position = UDim2.new(0,120,0,38)
            child.Size = UDim2.new(1,-120,1,-38)
            child.Visible = false
        end
    end)

    local tabs, tabBtns, curTab = {}, {}, nil

    function main:CreateTab(opts)
        local tabName = opts.Name or ("Tab"..tostring(#tabs+1))
        local tab = Instance.new("Frame", main)
        tab.Name = "TAB_"..tabName
        tab.BackgroundColor3 = CUR_THEME.Tab
        tab.BorderSizePixel = 0
        tab.Size = UDim2.new(1,-120,1,-38)
        tab.Position = UDim2.new(0,120,0,38)
        tab.Visible = false
        tab.ZIndex = 3

        local layout = Instance.new("UIListLayout", tab)
        layout.Padding = UDim.new(0,14)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        local btn = Instance.new("TextButton", tabBar)
        btn.Size = UDim2.new(1,0,0,44)
        btn.Position = UDim2.new(0,0,0,44*(#tabs))
        btn.BackgroundColor3 = (#tabs==0) and CUR_THEME.Accent or CUR_THEME.Tab
        btn.TextColor3 = CUR_THEME.Text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 16
        btn.Text = "  "..tabName
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        btn.BorderSizePixel = 0
        btn.ZIndex = 4
        btn.MouseEnter:Connect(function()
            if curTab~=tab then btn.BackgroundColor3 = CUR_THEME.Button end
        end)
        btn.MouseLeave:Connect(function()
            if curTab~=tab then btn.BackgroundColor3 = CUR_THEME.Tab end
        end)
        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(tabs) do t.Visible=false end
            for _, b in pairs(tabBtns) do b.BackgroundColor3 = CUR_THEME.Tab end
            tab.Visible=true
            btn.BackgroundColor3 = CUR_THEME.Accent
            curTab = tab
        end)
        table.insert(tabBtns, btn)
        table.insert(tabs, tab)
        if #tabs==1 then tab.Visible=true curTab=tab end

        --==[ Section ]==--
        function tab:CreateSection(name)
            local sectionLbl = Instance.new("TextLabel", tab)
            sectionLbl.Size = UDim2.new(1,0,0,26)
            sectionLbl.BackgroundTransparency = 1
            sectionLbl.Font = Enum.Font.GothamBold
            sectionLbl.TextColor3 = CUR_THEME.Section
            sectionLbl.Text = name or "Section"
            sectionLbl.TextSize = 17
            sectionLbl.LayoutOrder = 1000 + #tab:GetChildren()
        end

        --==[ Toggle ]==--
        function tab:CreateToggle(opt)
            local holder = Instance.new("Frame", tab)
            holder.Size = UDim2.new(1,-24,0,36)
            holder.BackgroundTransparency = 1
            holder.LayoutOrder = #tab:GetChildren()

            local name = Instance.new("TextLabel", holder)
            name.Text = opt.Name or "Toggle"
            name.Size = UDim2.new(0.7,0,1,0)
            name.BackgroundTransparency = 1
            name.Font = Enum.Font.Gotham
            name.TextColor3 = CUR_THEME.Text
            name.TextSize = 16
            name.TextXAlignment = Enum.TextXAlignment.Left

            local tglBtn = Instance.new("TextButton", holder)
            tglBtn.Size = UDim2.new(0,42,0,24)
            tglBtn.Position = UDim2.new(1,-54,0.5,-12)
            tglBtn.BackgroundColor3 = opt.CurrentValue and CUR_THEME.Accent or CUR_THEME.Input
            tglBtn.Text = ""
            tglBtn.AutoButtonColor = false
            tglBtn.BorderSizePixel = 0
            tglBtn.ZIndex = 4
            tglBtn.MouseButton1Click:Connect(function()
                opt.CurrentValue = not opt.CurrentValue
                tglBtn.BackgroundColor3 = opt.CurrentValue and CUR_THEME.Accent or CUR_THEME.Input
                ripple(tglBtn)
                if opt.Callback then task.spawn(opt.Callback, opt.CurrentValue) end
            end)
            tglBtn.MouseEnter:Connect(function() tglBtn.BackgroundColor3 = CUR_THEME.Button end)
            tglBtn.MouseLeave:Connect(function() tglBtn.BackgroundColor3 = opt.CurrentValue and CUR_THEME.Accent or CUR_THEME.Input end)
        end

        --==[ Button ]==--
        function tab:CreateButton(opt)
            local btn = Instance.new("TextButton", tab)
            btn.Size = UDim2.new(1,-24,0,36)
            btn.BackgroundColor3 = CUR_THEME.Button
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 18
            btn.Text = opt.Name or "Button"
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            btn.LayoutOrder = #tab:GetChildren()
            btn.MouseButton1Click:Connect(function()
                ripple(btn)
                if opt.Callback then task.spawn(opt.Callback) end
            end)
            btn.MouseEnter:Connect(function() btn.BackgroundColor3 = CUR_THEME.Accent end)
            btn.MouseLeave:Connect(function() btn.BackgroundColor3 = CUR_THEME.Button end)
        end

        --==[ Slider ]==--
        function tab:CreateSlider(opt)
            local min, max, inc = opt.Range[1] or 0, opt.Range[2] or 100, opt.Increment or 1
            local value = opt.CurrentValue or min

            local holder = Instance.new("Frame", tab)
            holder.Size = UDim2.new(1,-24,0,38)
            holder.BackgroundTransparency = 1
            holder.LayoutOrder = #tab:GetChildren()

            local lbl = Instance.new("TextLabel", holder)
            lbl.Size = UDim2.new(1,0,0,16)
            lbl.Position = UDim2.new(0,0,0,0)
            lbl.TextColor3 = CUR_THEME.Text
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 15
            lbl.Text = (opt.Name or "Slider")..": "..tostring(value)

            local bar = Instance.new("Frame", holder)
            bar.Size = UDim2.new(1, -95, 0, 8)
            bar.Position = UDim2.new(0,0,0,24)
            bar.BackgroundColor3 = CUR_THEME.Input
            bar.BorderSizePixel = 0

            local fill = Instance.new("Frame", bar)
            fill.BackgroundColor3 = CUR_THEME.Accent
            fill.BorderSizePixel = 0
            fill.Size = UDim2.new((value-min)/(max-min),0,1,0)

            local knob = Instance.new("Frame", bar)
            knob.Size = UDim2.new(0,18,0,18)
            knob.Position = UDim2.new((value-min)/(max-min),-9,0.5,-9)
            knob.BackgroundColor3 = CUR_THEME.Accent
            knob.BorderSizePixel = 0
            knob.ZIndex = 5
            shadow(knob)

            local dragging = false
            bar.InputBegan:Connect(function(input)
                if input.UserInputType==Enum.UserInputType.MouseButton1 then
                    dragging=true
                end
            end)
            bar.InputEnded:Connect(function(input)
                if input.UserInputType==Enum.UserInputType.MouseButton1 then
                    dragging=false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
                    local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
                    local new = math.floor((min + (max-min)*rel)/inc+0.5)*inc
                    fill.Size = UDim2.new((new-min)/(max-min),0,1,0)
                    knob.Position = UDim2.new((new-min)/(max-min),-9,0.5,-9)
                    lbl.Text = (opt.Name or "Slider")..": "..tostring(new)
                    value = new
                    if opt.Callback then task.spawn(opt.Callback, new) end
                end
            end)
        end

        --==[ Dropdown (Single/Multi) ]==--
        function tab:CreateDropdown(opt)
            local holder = Instance.new("Frame", tab)
            holder.Size = UDim2.new(1,-24,0,36)
            holder.BackgroundTransparency = 1
            holder.LayoutOrder = #tab:GetChildren()

            local lbl = Instance.new("TextLabel", holder)
            lbl.Size = UDim2.new(0.5,0,1,0)
            lbl.TextColor3 = CUR_THEME.Text
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 15
            lbl.Text = opt.Name or "Dropdown"
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local drop = Instance.new("TextButton", holder)
            drop.Size = UDim2.new(0.5,0,1,0)
            drop.Position = UDim2.new(0.5,0,0,0)
            drop.BackgroundColor3 = CUR_THEME.Dropdown
            drop.BorderSizePixel = 0
            drop.Text = tostring(opt.CurrentOption and (type(opt.CurrentOption)=="table" and opt.CurrentOption[1] or opt.CurrentOption) or "Select")
            drop.TextColor3 = CUR_THEME.Text
            drop.Font = Enum.Font.Gotham
            drop.TextSize = 15
            drop.AutoButtonColor = false

            local open = false
            local list = Instance.new("Frame", holder)
            list.BackgroundColor3 = CUR_THEME.Scroll
            list.Size = UDim2.new(0.5,0,0,#opt.Options*28)
            list.Position = UDim2.new(0.5,0,1,0)
            list.Visible = false
            list.ZIndex = 6
            local layout = Instance.new("UIListLayout", list)
            layout.Padding = UDim.new(0,0)
            layout.SortOrder = Enum.SortOrder.LayoutOrder

            local sel = (type(opt.CurrentOption)=="table" and opt.CurrentOption) or {}

            local function updateText()
                drop.Text = (type(sel)=="table" and #sel>0) and table.concat(sel, ", ") or "Select"
            end

            for i, o in ipairs(opt.Options or {}) do
                local item = Instance.new("TextButton", list)
                item.Size = UDim2.new(1,0,0,28)
                item.BackgroundColor3 = CUR_THEME.Scroll
                item.TextColor3 = CUR_THEME.Text
                item.Font = Enum.Font.Gotham
                item.TextSize = 15
                item.Text = o
                item.AutoButtonColor = false
                item.MouseButton1Click:Connect(function()
                    if opt.MultipleOptions then
                        if table.find(sel, o) then
                            for idx, op in ipairs(sel) do if op==o then table.remove(sel, idx) break end end
                        else
                            table.insert(sel, o)
                        end
                    else
                        sel = {o}
                        open=false
                        list.Visible=false
                    end
                    updateText()
                    if opt.Callback then task.spawn(opt.Callback, sel) end
                end)
                item.MouseEnter:Connect(function() item.BackgroundColor3 = CUR_THEME.Accent end)
                item.MouseLeave:Connect(function() item.BackgroundColor3 = CUR_THEME.Scroll end)
            end

            drop.MouseButton1Click:Connect(function()
                open = not open
                list.Visible = open
            end)
            updateText()
        end

        --==[ InputBox/TextBox ]==--
        function tab:CreateInputBox(opt)
            local holder = Instance.new("Frame", tab)
            holder.Size = UDim2.new(1,-24,0,38)
            holder.BackgroundTransparency = 1
            holder.LayoutOrder = #tab:GetChildren()

            local lbl = Instance.new("TextLabel", holder)
            lbl.Size = UDim2.new(0.5,0,1,0)
            lbl.TextColor3 = CUR_THEME.Text
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 15
            lbl.Text = opt.Name or "Input"
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local box = Instance.new("TextBox", holder)
            box.Size = UDim2.new(0.5,0,1,0)
            box.Position = UDim2.new(0.5,0,0,0)
            box.BackgroundColor3 = CUR_THEME.Input
            box.BorderSizePixel = 0
            box.TextColor3 = CUR_THEME.Text
            box.Font = Enum.Font.Gotham
            box.TextSize = 15
            box.Text = opt.Default or ""
            box.PlaceholderText = opt.Placeholder or "Type here..."
            box.ClearTextOnFocus = false

            box.FocusLost:Connect(function(enter)
                if opt.Callback then
                    opt.Callback(box.Text)
                end
            end)
        end

        --==[ KeyPicker ]==--
        function tab:CreateKeyPicker(opt)
            local holder = Instance.new("Frame", tab)
            holder.Size = UDim2.new(1,-24,0,36)
            holder.BackgroundTransparency = 1
            holder.LayoutOrder = #tab:GetChildren()

            local lbl = Instance.new("TextLabel", holder)
            lbl.Size = UDim2.new(0.5,0,1,0)
            lbl.TextColor3 = CUR_THEME.Text
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 15
            lbl.Text = opt.Name or "KeyPicker"
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local btn = Instance.new("TextButton", holder)
            btn.Size = UDim2.new(0.5,0,1,0)
            btn.Position = UDim2.new(0.5,0,0,0)
            btn.BackgroundColor3 = CUR_THEME.Input
            btn.TextColor3 = CUR_THEME.Text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 15
            btn.Text = opt.DefaultKey or "None"
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false

            btn.MouseButton1Click:Connect(function()
                btn.Text = "Press key..."
                local conn
                conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
                        btn.Text = tostring(input.KeyCode):gsub("Enum.KeyCode.","")
                        if opt.Callback then opt.Callback(input.KeyCode) end
                        conn:Disconnect()
                    end
                end)
            end)
        end

        --==[ ColorPicker (Simple) ]==--
        function tab:CreateColorPicker(opt)
            local holder = Instance.new("Frame", tab)
            holder.Size = UDim2.new(1,-24,0,38)
            holder.BackgroundTransparency = 1
            holder.LayoutOrder = #tab:GetChildren()

            local lbl = Instance.new("TextLabel", holder)
            lbl.Size = UDim2.new(0.5,0,1,0)
            lbl.TextColor3 = CUR_THEME.Text
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 15
            lbl.Text = opt.Name or "ColorPicker"
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local box = Instance.new("TextButton", holder)
            box.Size = UDim2.new(0,38,0,26)
            box.Position = UDim2.new(0.7,0,0.5,-13)
            box.BackgroundColor3 = opt.Default or CUR_THEME.Accent
            box.BorderSizePixel = 0
            box.Text = ""
            box.AutoButtonColor = false

            box.MouseButton1Click:Connect(function()
                local colors = {Color3.fromRGB(255,0,0),Color3.fromRGB(0,255,0),Color3.fromRGB(0,0,255),
                    Color3.fromRGB(255,255,0),Color3.fromRGB(255,255,255),CUR_THEME.Accent}
                local idx = 1
                while true do
                    box.BackgroundColor3 = colors[idx]
                    if opt.Callback then opt.Callback(colors[idx]) end
                    idx = idx+1
                    if idx > #colors then idx = 1 end
                    wait(0.17)
                    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then break end
                end
            end)
        end

        --==[ List/ScrollingList ]==--
        function tab:CreateList(opt)
            local holder = Instance.new("Frame", tab)
            holder.Size = UDim2.new(1,-24,0,120)
            holder.BackgroundTransparency = 1
            holder.LayoutOrder = #tab:GetChildren()

            local scroll = Instance.new("ScrollingFrame", holder)
            scroll.Size = UDim2.new(1,0,1,0)
            scroll.CanvasSize = UDim2.new(0,0,0,0)
            scroll.BackgroundColor3 = CUR_THEME.List
            scroll.BorderSizePixel = 0
            scroll.ScrollBarThickness = 4

            local layout = Instance.new("UIListLayout", scroll)
            layout.SortOrder = Enum.SortOrder.LayoutOrder

            for i, v in ipairs(opt.Items or {}) do
                local item = Instance.new("TextLabel", scroll)
                item.Size = UDim2.new(1,0,0,28)
                item.BackgroundTransparency = 1
                item.Text = tostring(v)
                item.TextColor3 = CUR_THEME.Text
                item.Font = Enum.Font.Gotham
                item.TextSize = 15
            end

            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y)
            end)
        end

        return tab
    end

    --==[ Notification ]==--
    function main:Notification(opt)
        local notif = Instance.new("Frame", screen)
        notif.Size = UDim2.new(0,330,0,60)
        notif.Position = UDim2.new(0.5,-165,0.1,0)
        notif.BackgroundColor3 = CUR_THEME.Accent
        notif.BorderSizePixel = 0
        notif.ZIndex = 30
        shadow(notif)

        local icon = Instance.new("ImageLabel", notif)
        icon.BackgroundTransparency = 1
        icon.Size = UDim2.new(0,36,0,36)
        icon.Position = UDim2.new(0,8,0,12)
        icon.Image = "rbxassetid://77339698"
        icon.ImageColor3 = CUR_THEME.Button
        icon.ZIndex = 31

        local txt = Instance.new("TextLabel", notif)
        txt.Text = (opt.Title or "Notification").."\n"..(opt.Content or "")
        txt.TextColor3 = CUR_THEME.Text
        txt.Font = Enum.Font.Gotham
        txt.TextSize = 17
        txt.TextWrapped = true
        txt.BackgroundTransparency = 1
        txt.Position = UDim2.new(0,52,0,10)
        txt.Size = UDim2.new(1,-60,1,-20)
        txt.ZIndex = 31
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.TextYAlignment = Enum.TextYAlignment.Top

        notif.BackgroundTransparency = 1
        TweenService:Create(notif, TweenInfo.new(0.25), {BackgroundTransparency=0}):Play()
        TweenService:Create(notif, TweenInfo.new(0.25), {Position=UDim2.new(0.5,-165,0.16,0)}):Play()
        task.spawn(function()
            wait(2.5)
            TweenService:Create(notif, TweenInfo.new(0.35), {BackgroundTransparency=1, Position=UDim2.new(0.5,-165,0,0)}):Play()
            wait(0.4)
            notif:Destroy()
        end)
    end

    --==[ Modal/Popup ]==--
    function main:ShowModal(opt)
        local modal = Instance.new("Frame", screen)
        modal.Size = UDim2.new(0,320,0,140)
        modal.Position = UDim2.new(0.5,-160,0.45,-70)
        modal.BackgroundColor3 = CUR_THEME.Accent
        modal.BorderSizePixel = 0
        modal.ZIndex = 30
        shadow(modal)

        local txt = Instance.new("TextLabel", modal)
        txt.Text = (opt.Title or "Modal").."\n"..(opt.Content or "")
        txt.TextColor3 = CUR_THEME.Text
        txt.Font = Enum.Font.Gotham
        txt.TextSize = 17
        txt.TextWrapped = true
        txt.BackgroundTransparency = 1
        txt.Position = UDim2.new(0,20,0,20)
        txt.Size = UDim2.new(1,-40,0.7,0)
        txt.ZIndex = 31

        local okBtn = Instance.new("TextButton", modal)
        okBtn.Size = UDim2.new(0.4,0,0,32)
        okBtn.Position = UDim2.new(0.1,0,0.8,0)
        okBtn.BackgroundColor3 = CUR_THEME.Button
        okBtn.TextColor3 = Color3.new(1,1,1)
        okBtn.Font = Enum.Font.Gotham
        okBtn.TextSize = 16
        okBtn.Text = opt.OkText or "OK"
        okBtn.ZIndex = 32
        okBtn.MouseButton1Click:Connect(function()
            if opt.OnOK then opt.OnOK() end
            modal:Destroy()
        end)

        if opt.CancelText then
            local cancelBtn = Instance.new("TextButton", modal)
            cancelBtn.Size = UDim2.new(0.4,0,0,32)
            cancelBtn.Position = UDim2.new(0.5,0,0.8,0)
            cancelBtn.BackgroundColor3 = CUR_THEME.Accent
            cancelBtn.TextColor3 = Color3.new(1,1,1)
            cancelBtn.Font = Enum.Font.Gotham
            cancelBtn.TextSize = 16
            cancelBtn.Text = opt.CancelText
            cancelBtn.ZIndex = 32
            cancelBtn.MouseButton1Click:Connect(function()
                if opt.OnCancel then opt.OnCancel() end
                modal:Destroy()
            end)
        end
    end

    return main
end

return ModernUILib
