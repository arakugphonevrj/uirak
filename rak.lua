-- ModernUILib.lua - All-in-One Modern Roblox GUI Library v3.1 (Mobile Optimized, Visual Enhancement)
-- By Copilot, 2025 (mod & enhanced by arakugphonevrj)
-- Fitur: Window, Tab, Section, Toggle, Button, Slider, Dropdown, InputBox, KeyPicker, ColorPicker,
-- List/Scrolling, Save-Load Config, Theme Manager, Modal/Popup, Notification, Auto Responsif
-- Enhanced: Rounded everywhere, more shadow & accent, less solid color, gradients, dragable modals & dropdown, subtle animations

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

--==[ Utility (Corners, Gradient, Shadow, Drag) ]==--
local function applyCorners(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 16)
    c.Parent = obj
end

local function applyGradient(obj, c1, c2)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, c1 or CUR_THEME.Main),
        ColorSequenceKeypoint.new(1, c2 or CUR_THEME.Tab)
    }
    grad.Rotation = 20
    grad.Parent = obj
end

local function shadow(obj, thick, z)
    local s = Instance.new("ImageLabel")
    s.Name = "Shadow"
    s.Image = "rbxassetid://1316045217"
    s.BackgroundTransparency = 1
    s.ImageTransparency = 0.7
    s.Size = UDim2.new(1,thick or 18,1,thick or 18)
    s.Position = UDim2.new(0,-(thick or 9),0,-(thick or 9))
    s.ZIndex = (z or obj.ZIndex or 1) - 1
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
    applyCorners(circle, 99)
    local max = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y)*1.5
    TweenService:Create(circle, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size=UDim2.new(0, max, 0, max), BackgroundTransparency=1}):Play()
    task.spawn(function() wait(0.45) circle:Destroy() end)
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
    -- 95% lebar, 88% tinggi, posisi benar-benar center (tengah layar)
    return UDim2.new(0.95,0,0.88,0), UDim2.new(0.5,0,0.5,0)
end

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
    main.AnchorPoint = Vector2.new(0.5,0.5)
    main.BackgroundColor3 = CUR_THEME.Main
    main.BackgroundTransparency = 0.32 -- lebih transparan
    main.BorderSizePixel = 0
    main.Active = true
    main.ZIndex = 2
    applyCorners(main, 22)
    applyGradient(main, CUR_THEME.Main, CUR_THEME.Tab)
    shadow(main, 28, 2)
    makeDraggable(main)

    -- === TOMBOL SHOW/HIDE ===
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.new(0, 38, 0, 38)
    toggleBtn.AnchorPoint = Vector2.new(0.5, 0)
    toggleBtn.Position = UDim2.new(0.5, 0, 0, 12)
    toggleBtn.BackgroundTransparency = 0.45
    toggleBtn.BackgroundColor3 = CUR_THEME.Accent
    toggleBtn.Text = "🗿"
    toggleBtn.Font = Enum.Font.GothamBlack
    toggleBtn.TextSize = 26
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.Parent = screen
    applyCorners(toggleBtn, 22)
    shadow(toggleBtn, 14, 100)
    local btnHighlight = Instance.new("UIStroke", toggleBtn)
    btnHighlight.Thickness = 1.2
    btnHighlight.Transparency = 0.47
    btnHighlight.Color = CUR_THEME.Button
    toggleBtn.ZIndex = 100

    local hidden = false
    toggleBtn.MouseButton1Click:Connect(function()
        hidden = not hidden
        TweenService:Create(main, TweenInfo.new(0.19), {BackgroundTransparency = hidden and 1 or 0.32}):Play()
        wait(0.14)
        main.Visible = not hidden
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.RightShift then
            hidden = not hidden
            TweenService:Create(main, TweenInfo.new(0.19), {BackgroundTransparency = hidden and 1 or 0.32}):Play()
            wait(0.14)
            main.Visible = not hidden
        end
    end)
    
    local titleBar = Instance.new("Frame", main)
    titleBar.Size = UDim2.new(1,0,0,38)
    titleBar.BackgroundColor3 = CUR_THEME.Accent
    titleBar.BackgroundTransparency = 0.11
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 3
    applyCorners(titleBar, 20)
    shadow(titleBar, 8, 3)
    makeDraggable(main, titleBar)

    local accentLine = Instance.new("Frame", titleBar)
    accentLine.Size = UDim2.new(1,0,0,2)
    accentLine.Position = UDim2.new(0,0,1,-2)
    accentLine.BackgroundColor3 = CUR_THEME.Button
    accentLine.BackgroundTransparency = 0.2
    accentLine.ZIndex = 4

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
    tabBar.BackgroundTransparency = 0.18
    tabBar.BorderSizePixel = 0
    tabBar.ZIndex = 3
    applyCorners(tabBar, 18)
    shadow(tabBar, 10, 3)

    main.ChildAdded:Connect(function(child)
        if child:IsA("Frame") and child.Name:find("^TAB_") then
            child.Position = UDim2.new(0,120,0,38)
            child.Size = UDim2.new(1,-120,1,-38)
            child.Visible = false
        end
    end)

    -- Patch: Use a Lua object to hold methods!
    local windowObj = {}
    windowObj.Main = main
    windowObj.Screen = screen

    -- Tab state
    local tabs, tabBtns, curTab = {}, {}, nil

    function windowObj:CreateTab(opts)
        local tabName = opts.Name or ("Tab"..tostring(#tabs+1))
        local tabFrame = Instance.new("Frame", main)
        tabFrame.Name = "TAB_"..tabName
        tabFrame.BackgroundColor3 = CUR_THEME.Tab
        tabFrame.BackgroundTransparency = 0.13
        tabFrame.BorderSizePixel = 0
        tabFrame.Size = UDim2.new(1,-120,1,-38)
        tabFrame.Position = UDim2.new(0,120,0,38)
        tabFrame.Visible = false
        tabFrame.ZIndex = 3
        applyCorners(tabFrame, 20)
        shadow(tabFrame, 12, 3)

        local layout = Instance.new("UIListLayout", tabFrame)
        layout.Padding = UDim.new(0,14)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        local btn = Instance.new("TextButton", tabBar)
        btn.Size = UDim2.new(1,0,0,44)
        btn.Position = UDim2.new(0,0,0,44*(#tabs))
        btn.BackgroundColor3 = (#tabs==0) and CUR_THEME.Accent or CUR_THEME.Tab
        btn.BackgroundTransparency = 0.08
        btn.TextColor3 = CUR_THEME.Text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 16
        btn.Text = "  "..tabName
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        btn.BorderSizePixel = 0
        btn.ZIndex = 4
        applyCorners(btn, 12)
        btn.MouseEnter:Connect(function()
            if curTab~=tabFrame then
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = CUR_THEME.Button}):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if curTab~=tabFrame then
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = CUR_THEME.Tab}):Play()
            end
        end)
        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(tabs) do t.Frame.Visible=false end
            for _, b in pairs(tabBtns) do TweenService:Create(b, TweenInfo.new(0.13), {BackgroundColor3 = CUR_THEME.Tab}):Play() end
            tabFrame.Visible=true
            TweenService:Create(btn, TweenInfo.new(0.13), {BackgroundColor3 = CUR_THEME.Accent}):Play()
            curTab = tabFrame
        end)
        table.insert(tabBtns, btn)
        table.insert(tabs, {Frame = tabFrame})
        if #tabs==1 then tabFrame.Visible=true curTab=tabFrame end

        -- Tab Lua object
        local tabObj = {}
        tabObj.Frame = tabFrame

        -- SEMUA method tab, parent ke tabFrame
        function tabObj:CreateSection(name)
            local sectionLbl = Instance.new("TextLabel", tabFrame)
            sectionLbl.Size = UDim2.new(1,0,0,26)
            sectionLbl.BackgroundTransparency = 1
            sectionLbl.Font = Enum.Font.GothamBold
            sectionLbl.TextColor3 = CUR_THEME.Section
            sectionLbl.Text = name or "Section"
            sectionLbl.TextSize = 17
            sectionLbl.LayoutOrder = 1000 + #tabFrame:GetChildren()
        end

        function tabObj:CreateToggle(opt)
            local holder = Instance.new("Frame", tabFrame)
            holder.Size = UDim2.new(1,-24,0,36)
            holder.BackgroundTransparency = 1
            holder.LayoutOrder = #tabFrame:GetChildren()

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
            tglBtn.BackgroundTransparency = 0.10
            tglBtn.Text = ""
            tglBtn.AutoButtonColor = false
            tglBtn.BorderSizePixel = 0
            tglBtn.ZIndex = 4
            applyCorners(tglBtn, 13)
            local st = Instance.new("UIStroke", tglBtn)
            st.Thickness = 1.1
            st.Transparency = 0.5
            st.Color = CUR_THEME.Button
            tglBtn.MouseButton1Click:Connect(function()
                opt.CurrentValue = not opt.CurrentValue
                TweenService:Create(tglBtn, TweenInfo.new(0.15), {BackgroundColor3 = opt.CurrentValue and CUR_THEME.Accent or CUR_THEME.Input}):Play()
                ripple(tglBtn)
                if opt.Callback then task.spawn(opt.Callback, opt.CurrentValue) end
            end)
            tglBtn.MouseEnter:Connect(function() TweenService:Create(tglBtn, TweenInfo.new(0.13), {BackgroundColor3 = CUR_THEME.Button}):Play() end)
            tglBtn.MouseLeave:Connect(function() TweenService:Create(tglBtn, TweenInfo.new(0.13), {BackgroundColor3 = opt.CurrentValue and CUR_THEME.Accent or CUR_THEME.Input}):Play() end)
        end

        function tabObj:CreateButton(opt)
            local btn = Instance.new("TextButton", tabFrame)
            btn.Size = UDim2.new(1,-24,0,36)
            btn.BackgroundColor3 = CUR_THEME.Button
            btn.BackgroundTransparency = 0.10
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 18
            btn.Text = opt.Name or "Button"
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            btn.LayoutOrder = #tabFrame:GetChildren()
            applyCorners(btn, 13)
            local st = Instance.new("UIStroke", btn)
            st.Thickness = 1.1
            st.Transparency = 0.45
            st.Color = CUR_THEME.Accent
            btn.MouseButton1Click:Connect(function()
                ripple(btn)
                if opt.Callback then task.spawn(opt.Callback) end
            end)
            btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.14), {BackgroundColor3 = CUR_THEME.Accent}):Play() end)
            btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.14), {BackgroundColor3 = CUR_THEME.Button}):Play() end)
        end

        function tabObj:CreateSlider(opt)
            local min, max, inc = opt.Range[1] or 0, opt.Range[2] or 100, opt.Increment or 1
            local value = opt.CurrentValue or min

            local holder = Instance.new("Frame", tabFrame)
            holder.Size = UDim2.new(1,-24,0,38)
            holder.BackgroundTransparency = 1
            holder.LayoutOrder = #tabFrame:GetChildren()

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
            bar.BackgroundTransparency = 0.14
            bar.BorderSizePixel = 0
            applyCorners(bar, 6)

            local fill = Instance.new("Frame", bar)
            fill.BackgroundColor3 = CUR_THEME.Accent
            fill.BackgroundTransparency = 0
            fill.BorderSizePixel = 0
            fill.Size = UDim2.new((value-min)/(max-min),0,1,0)
            applyCorners(fill, 5)

            local knob = Instance.new("Frame", bar)
            knob.Size = UDim2.new(0,18,0,18)
            knob.Position = UDim2.new((value-min)/(max-min),-9,0.5,-9)
            knob.BackgroundColor3 = CUR_THEME.Accent
            knob.BorderSizePixel = 0
            knob.ZIndex = 5
            knob.BackgroundTransparency = 0.05
            applyCorners(knob, 9)
            shadow(knob, 8, 5)

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

        function tabObj:CreateDropdown(opt)
            local holder = Instance.new("Frame", tabFrame)
            holder.Size = UDim2.new(1,-24,0,36)
            holder.BackgroundTransparency = 1
            holder.LayoutOrder = #tabFrame:GetChildren()

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
            drop.BackgroundTransparency = 0.09
            drop.BorderSizePixel = 0
            drop.Text = tostring(opt.CurrentOption and (type(opt.CurrentOption)=="table" and opt.CurrentOption[1] or opt.CurrentOption) or "Select")
            drop.TextColor3 = CUR_THEME.Text
            drop.Font = Enum.Font.Gotham
            drop.TextSize = 15
            drop.AutoButtonColor = false
            applyCorners(drop, 12)
            local st = Instance.new("UIStroke", drop)
            st.Thickness = 1.1
            st.Transparency = 0.4
            st.Color = CUR_THEME.Accent

            local open = false
            local list = Instance.new("Frame", holder)
            list.BackgroundColor3 = CUR_THEME.Scroll
            list.BackgroundTransparency = 0.07
            list.Size = UDim2.new(0.5,0,0,#opt.Options*28)
            list.Position = UDim2.new(0.5,0,1,0)
            list.Visible = false
            list.ZIndex = 6
            applyCorners(list, 12)
            shadow(list, 9, 7)
            makeDraggable(list, list)
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
                item.BackgroundTransparency = 0.12
                item.TextColor3 = CUR_THEME.Text
                item.Font = Enum.Font.Gotham
                item.TextSize = 15
                item.Text = o
                item.AutoButtonColor = false
                applyCorners(item, 10)
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
                item.MouseEnter:Connect(function() TweenService:Create(item, TweenInfo.new(0.12), {BackgroundColor3 = CUR_THEME.Accent}):Play() end)
                item.MouseLeave:Connect(function() TweenService:Create(item, TweenInfo.new(0.12), {BackgroundColor3 = CUR_THEME.Scroll}):Play() end)
            end

            drop.MouseButton1Click:Connect(function()
                open = not open
                TweenService:Create(list, TweenInfo.new(0.16), {BackgroundTransparency = open and 0.07 or 1}):Play()
                list.Visible = open
            end)
            updateText()
        end

        function tabObj:CreateInputBox(opt)
            local holder = Instance.new("Frame", tabFrame)
            holder.Size = UDim2.new(1,-24,0,38)
            holder.BackgroundTransparency = 1
            holder.LayoutOrder = #tabFrame:GetChildren()

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
            box.BackgroundTransparency = 0.13
            box.BorderSizePixel = 0
            box.TextColor3 = CUR_THEME.Text
            box.Font = Enum.Font.Gotham
            box.TextSize = 15
            box.Text = opt.Default or ""
            box.PlaceholderText = opt.Placeholder or "Type here..."
            box.ClearTextOnFocus = false
            applyCorners(box, 10)

            box.FocusLost:Connect(function(enter)
                if opt.Callback then
                    opt.Callback(box.Text)
                end
            end)
        end

        function tabObj:CreateKeyPicker(opt)
            local holder = Instance.new("Frame", tabFrame)
            holder.Size = UDim2.new(1,-24,0,36)
            holder.BackgroundTransparency = 1
            holder.LayoutOrder = #tabFrame:GetChildren()

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
            btn.BackgroundTransparency = 0.15
            btn.TextColor3 = CUR_THEME.Text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 15
            btn.Text = opt.DefaultKey or "None"
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            applyCorners(btn, 10)

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

        function tabObj:CreateColorPicker(opt)
            local holder = Instance.new("Frame", tabFrame)
            holder.Size = UDim2.new(1,-24,0,38)
            holder.BackgroundTransparency = 1
            holder.LayoutOrder = #tabFrame:GetChildren()

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
            box.BackgroundTransparency = 0.12
            box.BorderSizePixel = 0
            box.Text = ""
            box.AutoButtonColor = false
            applyCorners(box, 50)

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

        function tabObj:CreateList(opt)
            local holder = Instance.new("Frame", tabFrame)
            holder.Size = UDim2.new(1,-24,0,120)
            holder.BackgroundTransparency = 1
            holder.LayoutOrder = #tabFrame:GetChildren()

            local scroll = Instance.new("ScrollingFrame", holder)
            scroll.Size = UDim2.new(1,0,1,0)
            scroll.CanvasSize = UDim2.new(0,0,0,0)
            scroll.BackgroundColor3 = CUR_THEME.List
            scroll.BackgroundTransparency = 0.09
            scroll.BorderSizePixel = 0
            scroll.ScrollBarThickness = 4
            applyCorners(scroll, 13)

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

        return tabObj
    end

    function windowObj:Notification(opt)
        local notif = Instance.new("Frame", screen)
        notif.Size = UDim2.new(0,330,0,60)
        notif.Position = UDim2.new(0.5,-165,0.1,0)
        notif.BackgroundColor3 = CUR_THEME.Accent
        notif.BackgroundTransparency = 0.13
        notif.BorderSizePixel = 0
        notif.ZIndex = 30
        applyCorners(notif, 16)
        shadow(notif, 14, 30)
        makeDraggable(notif, notif)

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
        TweenService:Create(notif, TweenInfo.new(0.25), {BackgroundTransparency=0.13}):Play()
        TweenService:Create(notif, TweenInfo.new(0.25), {Position=UDim2.new(0.5,-165,0.16,0)}):Play()
        task.spawn(function()
            wait(2.5)
            TweenService:Create(notif, TweenInfo.new(0.35), {BackgroundTransparency=1, Position=UDim2.new(0.5,-165,0,0)}):Play()
            wait(0.4)
            notif:Destroy()
        end)
    end

    function windowObj:ShowModal(opt)
        local modal = Instance.new("Frame", screen)
        modal.Size = UDim2.new(0,320,0,140)
        modal.Position = UDim2.new(0.5,-160,0.45,-70)
        modal.BackgroundColor3 = CUR_THEME.Accent
        modal.BackgroundTransparency = 0.13
        modal.BorderSizePixel = 0
        modal.ZIndex = 30
        applyCorners(modal, 16)
        applyGradient(modal, CUR_THEME.Accent, CUR_THEME.Button)
        shadow(modal, 16, 30)
        makeDraggable(modal, modal)

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
        okBtn.BackgroundTransparency = 0.11
        okBtn.TextColor3 = Color3.new(1,1,1)
        okBtn.Font = Enum.Font.Gotham
        okBtn.TextSize = 16
        okBtn.Text = opt.OkText or "OK"
        okBtn.ZIndex = 32
        applyCorners(okBtn, 10)
        okBtn.MouseButton1Click:Connect(function()
            if opt.OnOK then opt.OnOK() end
            modal:Destroy()
        end)

        if opt.CancelText then
            local cancelBtn = Instance.new("TextButton", modal)
            cancelBtn.Size = UDim2.new(0.4,0,0,32)
            cancelBtn.Position = UDim2.new(0.5,0,0.8,0)
            cancelBtn.BackgroundColor3 = CUR_THEME.Accent
            cancelBtn.BackgroundTransparency = 0.22
            cancelBtn.TextColor3 = Color3.new(1,1,1)
            cancelBtn.Font = Enum.Font.Gotham
            cancelBtn.TextSize = 16
            cancelBtn.Text = opt.CancelText
            cancelBtn.ZIndex = 32
            applyCorners(cancelBtn, 10)
            cancelBtn.MouseButton1Click:Connect(function()
                if opt.OnCancel then opt.OnCancel() end
                modal:Destroy()
            end)
        end
    end

    return windowObj
end

return ModernUILib
