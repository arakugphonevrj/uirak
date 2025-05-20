-- ModernUI_Pro_Full.lua - Modern Glass Roblox GUI Library v1.0 (All Widgets, Enhanced Visuals, Mobile Friendly)
-- By Copilot & arakugphonevrj

local ModernUI = {}
ModernUI.__index = ModernUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

--==[ THEME ]==--
local THEMES = {
    ["Glass"] = {
        Main = Color3.fromRGB(34,37,54), Accent = Color3.fromRGB(120,165,255),
        Tab = Color3.fromRGB(28,30,44), Button = Color3.fromRGB(120,165,255),
        Text = Color3.fromRGB(245,245,255), Section = Color3.fromRGB(180,200,255),
        Input = Color3.fromRGB(42,45,70), List = Color3.fromRGB(40,42,60),
        Dropdown = Color3.fromRGB(56,60,82), Scroll = Color3.fromRGB(54,58,84)
    }
}
local CUR_THEME = THEMES.Glass
function ModernUI.SetTheme(name) CUR_THEME = THEMES[name] or THEMES.Glass end
function ModernUI.GetTheme() return CUR_THEME end

--==[ UTILS ]==--
local function addFrostedGlass(parent, blur)
    local glass = Instance.new("Frame")
    glass.Size = UDim2.fromScale(1,1)
    glass.BackgroundTransparency = 0.65
    glass.BackgroundColor3 = CUR_THEME.Main
    glass.BorderSizePixel = 0
    glass.ZIndex = 0
    glass.Parent = parent
    local img = Instance.new("ImageLabel", glass)
    img.BackgroundTransparency = 1
    img.Image = "rbxassetid://2717487667"
    img.Size = UDim2.fromScale(1,1)
    img.Position = UDim2.fromOffset(0,0)
    img.ZIndex = 1
    img.ImageTransparency = blur or 0.82
    return glass
end
local function applyCorners(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 18)
    c.Parent = obj
end
local function applyGradient(obj, c1, c2)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, c1 or CUR_THEME.Main),
        ColorSequenceKeypoint.new(1, c2 or CUR_THEME.Accent)
    }
    grad.Rotation = 30
    grad.Parent = obj
end
local function softShadow(obj)
    local s = Instance.new("ImageLabel")
    s.Name = "Shadow"
    s.Image = "rbxassetid://1316045217"
    s.BackgroundTransparency = 1
    s.ImageTransparency = 0.85
    s.Size = UDim2.new(1,18,1,18)
    s.Position = UDim2.new(0,-9,0,-9)
    s.ZIndex = (obj.ZIndex or 1) - 1
    s.Parent = obj
end
local function ripple(btn)
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0,0,0,0)
    circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    circle.BackgroundTransparency = 0.75
    circle.BorderSizePixel = 0
    circle.AnchorPoint = Vector2.new(0.5, 0.5)
    circle.Position = UDim2.new(0.5,0,0.5,0)
    circle.ClipsDescendants = true
    circle.ZIndex = 15
    circle.Parent = btn
    applyCorners(circle, 99)
    local max = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y)*1.4
    TweenService:Create(circle, TweenInfo.new(0.37, Enum.EasingStyle.Quint), {Size=UDim2.new(0, max, 0, max), BackgroundTransparency=1}):Play()
    task.spawn(function() wait(0.4) circle:Destroy() end)
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

--==[ WINDOW ]==--
function ModernUI:CreateWindow(opts)
    opts = opts or {}
    local screen = Instance.new("ScreenGui", game:GetService("CoreGui"))
    screen.Name = opts.Name or "ModernUI_Pro"
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screen.IgnoreGuiInset = true

    -- Main Glass Window
    local main = Instance.new("Frame", screen)
    main.Size = UDim2.new(0.93,0,0.86,0)
    main.Position = UDim2.new(0.5,0,0.5,0)
    main.AnchorPoint = Vector2.new(0.5,0.5)
    main.BackgroundTransparency = 1
    main.BorderSizePixel = 0
    main.ZIndex = 1
    applyCorners(main, 28)
    addFrostedGlass(main, 0.83)
    softShadow(main)
    applyGradient(main, CUR_THEME.Main, CUR_THEME.Tab)

    -- Mini Header with Avatar/Icon
    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1,0,0,62)
    header.BackgroundTransparency = 1
    header.Position = UDim2.fromOffset(0,0)
    header.ZIndex = 3

    local avatar = Instance.new("ImageLabel", header)
    avatar.Image = opts.Avatar or "rbxassetid://8560488317"
    avatar.Size = UDim2.new(0,42,0,42)
    avatar.Position = UDim2.new(0,16,0.5,-21)
    avatar.BackgroundTransparency = 1
    avatar.ZIndex = 4

    local title = Instance.new("TextLabel", header)
    title.Text = "<b>"..(opts.Name or "Modern UI Pro").."</b>\n<font size='14'>"..(opts.Subtitle or "Enhanced Library").."</font>"
    title.RichText = true
    title.Size = UDim2.new(1,-80,1,0)
    title.Position = UDim2.new(0,68,0,0)
    title.BackgroundTransparency = 1
    title.TextColor3 = CUR_THEME.Text
    title.Font = Enum.Font.Gotham
    title.TextSize = 24
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center
    title.ZIndex = 4

    -- Tab Bar with Icon
    local tabBar = Instance.new("Frame", main)
    tabBar.Size = UDim2.new(0,104,1,-62)
    tabBar.Position = UDim2.new(0,0,0,62)
    tabBar.BackgroundTransparency = 0.8
    tabBar.BackgroundColor3 = CUR_THEME.Tab
    tabBar.BorderSizePixel = 0
    tabBar.ZIndex = 2
    applyCorners(tabBar, 22)
    softShadow(tabBar)
    local tabBarLayout = Instance.new("UIListLayout", tabBar)
    tabBarLayout.Padding = UDim.new(0, 8)
    tabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local tabs, tabBtns, curTab = {}, {}, nil

    function ModernUI:CreateTab(opts)
        local tabName = opts.Name or ("Tab"..tostring(#tabs+1))
        local tabIcon = opts.Icon or "rbxassetid://7734099795"
        -- Main tab frame ("card" style)
        local tabFrame = Instance.new("Frame", main)
        tabFrame.Name = "TAB_"..tabName
        tabFrame.BackgroundColor3 = CUR_THEME.Tab
        tabFrame.BackgroundTransparency = 0.11
        tabFrame.BorderSizePixel = 0
        tabFrame.Size = UDim2.new(1,-104,1,-62)
        tabFrame.Position = UDim2.new(0,104,0,62)
        tabFrame.Visible = false
        tabFrame.ZIndex = 3
        applyCorners(tabFrame, 22)
        softShadow(tabFrame)
        applyGradient(tabFrame, CUR_THEME.Tab, CUR_THEME.Accent)

        local layout = Instance.new("UIListLayout", tabFrame)
        layout.Padding = UDim.new(0,17)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        -- Tab button on side with icon
        local btn = Instance.new("TextButton", tabBar)
        btn.Size = UDim2.new(1,0,0,56)
        btn.BackgroundColor3 = (#tabs==0) and CUR_THEME.Accent or CUR_THEME.Tab
        btn.BackgroundTransparency = 0.13
        btn.TextColor3 = CUR_THEME.Text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        btn.Text = "   "..tabName
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        btn.BorderSizePixel = 0
        btn.LayoutOrder = #tabs
        btn.ZIndex = 5
        applyCorners(btn, 16)
        local icon = Instance.new("ImageLabel", btn)
        icon.Image = tabIcon
        icon.Size = UDim2.new(0,22,0,22)
        icon.Position = UDim2.new(0,8,0.5,-11)
        icon.BackgroundTransparency = 1
        icon.ZIndex = 6

        btn.MouseEnter:Connect(function()
            if curTab~=tabFrame then TweenService:Create(btn, TweenInfo.new(0.14), {BackgroundColor3 = CUR_THEME.Button}):Play() end
        end)
        btn.MouseLeave:Connect(function()
            if curTab~=tabFrame then TweenService:Create(btn, TweenInfo.new(0.14), {BackgroundColor3 = CUR_THEME.Tab}):Play() end
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

        --==[ SECTION SYSTEM ]==--
        local tabObj = {}
        tabObj.Frame = tabFrame

        function tabObj:CreateSection(name)
            local section = Instance.new("Frame", tabFrame)
            section.Size = UDim2.new(1, -36, 0, 42)
            section.BackgroundColor3 = CUR_THEME.Scroll
            section.BackgroundTransparency = 0.18
            section.BorderSizePixel = 0
            section.ZIndex = 5
            section.LayoutOrder = #tabFrame:GetChildren()*2
            applyCorners(section, 17)
            softShadow(section)
            local lbl = Instance.new("TextLabel", section)
            lbl.Text = name or "Section"
            lbl.Size = UDim2.new(1,0,1,0)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = CUR_THEME.Section
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 18
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Position = UDim2.new(0,14,0,0)
            lbl.ZIndex = 6
        end

        function tabObj:CreateButton(opt)
            local btn = Instance.new("TextButton", tabFrame)
            btn.Size = UDim2.new(1,-38,0,38)
            btn.BackgroundColor3 = CUR_THEME.Button
            btn.BackgroundTransparency = 0.10
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 18
            btn.Text = opt.Name or "Button"
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            btn.LayoutOrder = #tabFrame:GetChildren()
            applyCorners(btn, 15)
            softShadow(btn)
            local st = Instance.new("UIStroke", btn)
            st.Thickness = 1.1
            st.Transparency = 0.38
            st.Color = CUR_THEME.Accent
            btn.MouseButton1Click:Connect(function()
                ripple(btn)
                if opt.Callback then task.spawn(opt.Callback) end
            end)
            btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.14), {BackgroundColor3 = CUR_THEME.Accent}):Play() end)
            btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.14), {BackgroundColor3 = CUR_THEME.Button}):Play() end)
        end

        function tabObj:CreateToggle(opt)
            local holder = Instance.new("Frame", tabFrame)
            holder.Size = UDim2.new(1,-38,0,36)
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
            tglBtn.Size = UDim2.new(0,44,0,24)
            tglBtn.Position = UDim2.new(1,-54,0.5,-12)
            tglBtn.BackgroundColor3 = opt.CurrentValue and CUR_THEME.Accent or CUR_THEME.Input
            tglBtn.BackgroundTransparency = 0.10
            tglBtn.Text = ""
            tglBtn.AutoButtonColor = false
            tglBtn.BorderSizePixel = 0
            tglBtn.ZIndex = 6
            applyCorners(tglBtn, 13)
            softShadow(tglBtn)
            local st = Instance.new("UIStroke", tglBtn)
            st.Thickness = 1.1
            st.Transparency = 0.4
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

        function tabObj:CreateSlider(opt)
            local min, max, inc = opt.Range[1] or 0, opt.Range[2] or 100, opt.Increment or 1
            local value = opt.CurrentValue or min
            local holder = Instance.new("Frame", tabFrame)
            holder.Size = UDim2.new(1,-38,0,38)
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
            bar.Size = UDim2.new(1, -98, 0, 8)
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
            knob.Size = UDim2.new(0,20,0,20)
            knob.Position = UDim2.new((value-min)/(max-min),-10,0.5,-10)
            knob.BackgroundColor3 = CUR_THEME.Accent
            knob.BorderSizePixel = 0
            knob.ZIndex = 8
            knob.BackgroundTransparency = 0.05
            applyCorners(knob, 10)
            softShadow(knob)
            local dragging = false
            bar.InputBegan:Connect(function(input)
                if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end
            end)
            bar.InputEnded:Connect(function(input)
                if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
                    local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
                    local new = math.floor((min + (max-min)*rel)/inc+0.5)*inc
                    fill.Size = UDim2.new((new-min)/(max-min),0,1,0)
                    knob.Position = UDim2.new((new-min)/(max-min),-10,0.5,-10)
                    lbl.Text = (opt.Name or "Slider")..": "..tostring(new)
                    value = new
                    if opt.Callback then task.spawn(opt.Callback, new) end
                end
            end)
        end

        function tabObj:CreateDropdown(opt)
            local holder = Instance.new("Frame", tabFrame)
            holder.Size = UDim2.new(1,-38,0,36)
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
            applyCorners(drop, 13)
            softShadow(drop)
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
            list.ZIndex = 14
            applyCorners(list, 13)
            softShadow(list)
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
                item.MouseEnter:Connect(function() TweenService:Create(item, TweenInfo.new(0.13), {BackgroundColor3 = CUR_THEME.Accent}):Play() end)
                item.MouseLeave:Connect(function() TweenService:Create(item, TweenInfo.new(0.13), {BackgroundColor3 = CUR_THEME.Scroll}):Play() end)
            end
            drop.MouseButton1Click:Connect(function()
                open = not open
                TweenService:Create(list, TweenInfo.new(0.17), {BackgroundTransparency = open and 0.07 or 1}):Play()
                list.Visible = open
            end)
            updateText()
        end

        function tabObj:CreateInputBox(opt)
            local holder = Instance.new("Frame", tabFrame)
            holder.Size = UDim2.new(1,-38,0,38)
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
            softShadow(box)
            box.FocusLost:Connect(function(enter)
                if opt.Callback then opt.Callback(box.Text) end
            end)
        end

        function tabObj:CreateKeyPicker(opt)
            local holder = Instance.new("Frame", tabFrame)
            holder.Size = UDim2.new(1,-38,0,36)
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
            softShadow(btn)
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
            holder.Size = UDim2.new(1,-38,0,38)
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
            box.Size = UDim2.new(0,38,0,28)
            box.Position = UDim2.new(0.7,0,0.5,-14)
            box.BackgroundColor3 = opt.Default or CUR_THEME.Accent
            box.BackgroundTransparency = 0.12
            box.BorderSizePixel = 0
            box.Text = ""
            box.AutoButtonColor = false
            applyCorners(box, 50)
            softShadow(box)
            box.MouseButton1Click:Connect(function()
                local colors = {Color3.fromRGB(255,0,0),Color3.fromRGB(0,255,0),Color3.fromRGB(0,0,255),
                    Color3.fromRGB(255,255,0),Color3.fromRGB(255,255,255),CUR_THEME.Accent}
                local idx = 1
                while true do
                    box.BackgroundColor3 = colors[idx]
                    if opt.Callback then opt.Callback(colors[idx]) end
                    idx = idx+1
                    if idx > #colors then idx = 1 end
                    wait(0.18)
                    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then break end
                end
            end)
        end

        function tabObj:CreateList(opt)
            local holder = Instance.new("Frame", tabFrame)
            holder.Size = UDim2.new(1,-38,0,120)
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
            softShadow(scroll)
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

    --==[ NOTIF/MODAL ]==--
    function ModernUI:Notification(opt)
        local notif = Instance.new("Frame", screen)
        notif.Size = UDim2.new(0,340,0,62)
        notif.Position = UDim2.new(0.5,-170,0.1,0)
        notif.BackgroundColor3 = CUR_THEME.Accent
        notif.BackgroundTransparency = 0.13
        notif.BorderSizePixel = 0
        notif.ZIndex = 30
        applyCorners(notif, 16)
        softShadow(notif)
        makeDraggable(notif, notif)
        local icon = Instance.new("ImageLabel", notif)
        icon.BackgroundTransparency = 1
        icon.Size = UDim2.new(0,38,0,38)
        icon.Position = UDim2.new(0,10,0,13)
        icon.Image = opt.Icon or "rbxassetid://77339698"
        icon.ImageColor3 = CUR_THEME.Button
        icon.ZIndex = 31
        local txt = Instance.new("TextLabel", notif)
        txt.Text = (opt.Title or "Notification").."\n"..(opt.Content or "")
        txt.TextColor3 = CUR_THEME.Text
        txt.Font = Enum.Font.Gotham
        txt.TextSize = 17
        txt.TextWrapped = true
        txt.BackgroundTransparency = 1
        txt.Position = UDim2.new(0,56,0,10)
        txt.Size = UDim2.new(1,-64,1,-20)
        txt.ZIndex = 31
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.TextYAlignment = Enum.TextYAlignment.Top
        notif.BackgroundTransparency = 1
        TweenService:Create(notif, TweenInfo.new(0.24), {BackgroundTransparency=0.13}):Play()
        TweenService:Create(notif, TweenInfo.new(0.24), {Position=UDim2.new(0.5,-170,0.16,0)}):Play()
        task.spawn(function()
            wait(2.7)
            TweenService:Create(notif, TweenInfo.new(0.33), {BackgroundTransparency=1, Position=UDim2.new(0.5,-170,0,0)}):Play()
            wait(0.41)
            notif:Destroy()
        end)
    end

    function ModernUI:ShowModal(opt)
        local modal = Instance.new("Frame", screen)
        modal.Size = UDim2.new(0,340,0,150)
        modal.Position = UDim2.new(0.5,-170,0.45,-75)
        modal.BackgroundColor3 = CUR_THEME.Accent
        modal.BackgroundTransparency = 0.13
        modal.BorderSizePixel = 0
        modal.ZIndex = 30
        applyCorners(modal, 18)
        applyGradient(modal, CUR_THEME.Accent, CUR_THEME.Button)
        softShadow(modal)
        makeDraggable(modal, modal)
        local txt = Instance.new("TextLabel", modal)
        txt.Text = (opt.Title or "Modal").."\n"..(opt.Content or "")
        txt.TextColor3 = CUR_THEME.Text
        txt.Font = Enum.Font.Gotham
        txt.TextSize = 18
        txt.TextWrapped = true
        txt.BackgroundTransparency = 1
        txt.Position = UDim2.new(0,22,0,22)
        txt.Size = UDim2.new(1,-44,0.7,0)
        txt.ZIndex = 31
        local okBtn = Instance.new("TextButton", modal)
        okBtn.Size = UDim2.new(0.4,0,0,34)
        okBtn.Position = UDim2.new(0.1,0,0.8,0)
        okBtn.BackgroundColor3 = CUR_THEME.Button
        okBtn.BackgroundTransparency = 0.11
        okBtn.TextColor3 = Color3.new(1,1,1)
        okBtn.Font = Enum.Font.Gotham
        okBtn.TextSize = 17
        okBtn.Text = opt.OkText or "OK"
        okBtn.ZIndex = 32
        applyCorners(okBtn, 12)
        softShadow(okBtn)
        okBtn.MouseButton1Click:Connect(function()
            if opt.OnOK then opt.OnOK() end
            modal:Destroy()
        end)
        if opt.CancelText then
            local cancelBtn = Instance.new("TextButton", modal)
            cancelBtn.Size = UDim2.new(0.4,0,0,34)
            cancelBtn.Position = UDim2.new(0.5,0,0.8,0)
            cancelBtn.BackgroundColor3 = CUR_THEME.Accent
            cancelBtn.BackgroundTransparency = 0.23
            cancelBtn.TextColor3 = Color3.new(1,1,1)
            cancelBtn.Font = Enum.Font.Gotham
            cancelBtn.TextSize = 17
            cancelBtn.Text = opt.CancelText
            cancelBtn.ZIndex = 32
            applyCorners(cancelBtn, 12)
            softShadow(cancelBtn)
            cancelBtn.MouseButton1Click:Connect(function()
                if opt.OnCancel then opt.OnCancel() end
                modal:Destroy()
            end)
        end
    end

    return ModernUI
end

return ModernUI
