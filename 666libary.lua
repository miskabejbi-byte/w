local Library = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local CustomFont = Enum.Font.Code

function Library:AddStroke(parent, color, thickness)
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = thickness or 1
    Stroke.Color = color or Color3.fromRGB(255, 255, 255)
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = parent
    return Stroke
end

function Library:CreateWindow(titleText)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "pained_CustomUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    if CoreGui:FindFirstChild("pained_CustomUI") then
        CoreGui:FindFirstChild("pained_CustomUI"):Destroy()
    end

    local ContextMenu = Instance.new("Frame")
    ContextMenu.Name = "ContextMenu"
    ContextMenu.Parent = ScreenGui
    ContextMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ContextMenu.Size = UDim2.new(0, 80, 0, 44)
    ContextMenu.Visible = false
    ContextMenu.ZIndex = 11000
    self:AddStroke(ContextMenu, Color3.fromRGB(80, 80, 80), 1)

    local ContextList = Instance.new("UIListLayout", ContextMenu)
    ContextList.Padding = UDim.new(0, 2)

    local currentBindTable = nil
    local currentBindModeIndex = nil

    local function CreateContextBtn(text, mode)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 20)
        b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        b.BorderSizePixel = 0
        b.Font = CustomFont
        b.Text = text
        b.TextColor3 = Color3.new(1, 1, 1)
        b.TextSize = 12
        b.ZIndex = 11005
        b.Parent = ContextMenu
        b.MouseButton1Click:Connect(function()
            if currentBindTable and currentBindModeIndex then
                currentBindTable[currentBindModeIndex] = mode
            end
            ContextMenu.Visible = false
        end)
    end

    CreateContextBtn("HOLD", "Hold")
    CreateContextBtn("TOGGLE", "Toggle")

    local NavBar = Instance.new("Frame")
    NavBar.Name = "NavBar"
    NavBar.Parent = ScreenGui
    NavBar.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    NavBar.BorderSizePixel = 0
    NavBar.Position = UDim2.new(0.5, -60, 0, 0)
    NavBar.Size = UDim2.new(0, 120, 0, 40)
    local NavCorner = Instance.new("UICorner")
    NavCorner.CornerRadius = UDim.new(0, 6)
    NavCorner.Parent = NavBar
    self:AddStroke(NavBar, Color3.fromRGB(60, 60, 60), 1)

    local NavList = Instance.new("UIListLayout")
    NavList.Parent = NavBar
    NavList.FillDirection = Enum.FillDirection.Horizontal
    NavList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    NavList.VerticalAlignment = Enum.VerticalAlignment.Center
    NavList.Padding = UDim.new(0, 6)

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, -300, 0.5, -300)
    Main.Size = UDim2.new(0, 600, 0, 600)
    Main.Active = true
    self:AddStroke(Main, Color3.fromRGB(255, 255, 255), 2)

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = Main
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    self:AddStroke(TopBar, Color3.fromRGB(80, 80, 80), 1)

    -- Dragging Logic
    local dragToggle, dragStart, startPosMain
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPosMain = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragToggle and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragToggle = false end
    end)

    local Title = Instance.new("TextLabel")
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.Font = CustomFont
    Title.Text = titleText
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14

    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Parent = Main
    TabBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    TabBar.BorderSizePixel = 0
    TabBar.Position = UDim2.new(0, 0, 0, 35)
    TabBar.Size = UDim2.new(1, 0, 0, 35)
    self:AddStroke(TabBar, Color3.fromRGB(60, 60, 60), 1)

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabBar
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local Pages = Instance.new("Frame")
    Pages.Name = "Pages"
    Pages.Parent = Main
    Pages.BackgroundTransparency = 1
    Pages.Position = UDim2.new(0, 10, 0, 75)
    Pages.Size = UDim2.new(1, -20, 1, -85)

    local TabPages = {}
    local TabButtons = {}

    local WindowObj = {
        ScreenGui = ScreenGui,
        Main = Main,
        NavBar = NavBar,
        TabBar = TabBar,
        Pages = Pages,
        ContextMenu = ContextMenu,
        TabPages = TabPages,
        TabButtons = TabButtons
    }

    function WindowObj:CreateTab(name, order)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0.1666, 0, 1, 0)
        TabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        TabBtn.BorderSizePixel = 0
        TabBtn.Font = CustomFont
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.TextSize = 12
        TabBtn.LayoutOrder = order
        TabBtn.Parent = TabBar
        Library:AddStroke(TabBtn, Color3.fromRGB(55, 55, 55), 1)

        local Indicator = Instance.new("Frame")
        Indicator.Name = "Indicator"
        Indicator.Size = UDim2.new(1, 0, 0, 2)
        Indicator.Position = UDim2.new(0, 0, 0, -1)
        Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Indicator.BorderSizePixel = 0
        Indicator.Visible = false
        Indicator.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Name = name .. "_Page"
        Page.Parent = Pages
        Page.BackgroundTransparency = 1
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.ScrollBarThickness = 2
        Page.Visible = false

        local LeftColumn = Instance.new("Frame")
        LeftColumn.Name = "LeftColumn"
        LeftColumn.Size = UDim2.new(0.5, -7, 1, 0)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.Parent = Page

        local RightColumn = Instance.new("Frame")
        RightColumn.Name = "RightColumn"
        RightColumn.Position = UDim2.new(0.5, 7, 0, 0)
        RightColumn.Size = UDim2.new(0.5, -7, 1, 0)
        RightColumn.BackgroundTransparency = 1
        RightColumn.Parent = Page

        Instance.new("UIListLayout", LeftColumn).Padding = UDim.new(0, 20)
        Instance.new("UIListLayout", RightColumn).Padding = UDim.new(0, 20)
        Instance.new("UIPadding", Page).PaddingTop = UDim.new(0, 25)

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(TabPages) do p.Visible = false end
            for _, b in pairs(TabButtons) do 
                b.TextColor3 = Color3.fromRGB(150, 150, 150) 
                b.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                b.Indicator.Visible = false
            end 
            Page.Visible = true
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Indicator.Visible = true
        end)

        table.insert(TabPages, Page)
        table.insert(TabButtons, TabBtn)
        
        local TabObj = {Left = LeftColumn, Right = RightColumn}

        function TabObj:CreateSection(parentCol, title)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Size = UDim2.new(1, 0, 0, 0)
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y 
            SectionFrame.Parent = parentCol
            Library:AddStroke(SectionFrame, Color3.fromRGB(80, 80, 80), 1)

            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Text = " " .. title:upper() .. " "
            SectionTitle.Font = CustomFont
            SectionTitle.TextSize = 11
            SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            SectionTitle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            SectionTitle.Position = UDim2.new(0, 12, 0, -8)
            SectionTitle.AutomaticSize = Enum.AutomaticSize.X
            SectionTitle.Size = UDim2.new(0, 0, 0, 16)
            SectionTitle.ZIndex = 100
            SectionTitle.Parent = SectionFrame

            local Container = Instance.new("Frame")
            Container.BackgroundTransparency = 1
            Container.Position = UDim2.new(0, 10, 0, 12)
            Container.Size = UDim2.new(1, -20, 0, 0)
            Container.AutomaticSize = Enum.AutomaticSize.Y 
            Container.Parent = SectionFrame

            Instance.new("UIListLayout", Container).Padding = UDim.new(0, 12)
            Instance.new("UIPadding", Container).PaddingBottom = UDim.new(0, 15)

            local SecObj = {Container = Container}

            function SecObj:CreateToggle(text, callback, bindTable, bindKeyIndex, bindModeIndex)
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 20)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Parent = Container

                local Checkbox = Instance.new("Frame")
                Checkbox.Size = UDim2.new(0, 14, 0, 14)
                Checkbox.Position = UDim2.new(0, 0, 0.5, -7)
                Checkbox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                Checkbox.Parent = ToggleFrame
                Library:AddStroke(Checkbox, Color3.fromRGB(255, 255, 255), 1)

                local CheckFill = Instance.new("Frame")
                CheckFill.Size = UDim2.new(1, -4, 1, -4)
                CheckFill.Position = UDim2.new(0, 2, 0, 2)
                CheckFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                CheckFill.Visible = false
                CheckFill.Parent = Checkbox

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -70, 1, 0)
                Label.Position = UDim2.new(0, 25, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Font = CustomFont
                Label.Text = text
                Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = ToggleFrame

                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(1, -70, 1, 0)
                Button.BackgroundTransparency = 1
                Button.Text = ""
                Button.Parent = ToggleFrame

                local enabled = false
                Button.MouseButton1Click:Connect(function()
                    enabled = not enabled
                    CheckFill.Visible = enabled
                    callback(enabled)
                end)

                if bindTable and bindKeyIndex then
                    local BindBtn = Instance.new("TextButton")
                    BindBtn.Size = UDim2.new(0, 60, 0, 16)
                    BindBtn.Position = UDim2.new(1, -60, 0.5, -8)
                    BindBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    BindBtn.Font = CustomFont
                    BindBtn.Text = bindTable[bindKeyIndex] and bindTable[bindKeyIndex].Name or "NONE"
                    BindBtn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
                    BindBtn.TextSize = 10
                    BindBtn.Parent = ToggleFrame
                    Library:AddStroke(BindBtn, Color3.fromRGB(80, 80, 80), 1)

                    local binding = false
                    BindBtn.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            binding = true
                            BindBtn.Text = "..."
                        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                            currentBindTable = bindTable
                            currentBindModeIndex = bindModeIndex
                            ContextMenu.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)
                            ContextMenu.Visible = true
                        end
                    end)

                    UserInputService.InputBegan:Connect(function(input)
                        if binding and (input.UserInputType == Enum.UserInputType.Keyboard or input.UserInputType.Name:find("MouseButton")) then
                            local key = (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType)
                            if key ~= Enum.UserInputType.MouseButton1 then
                                bindTable[bindKeyIndex] = key
                                BindBtn.Text = key.Name:upper()
                                binding = false
                            end
                        end
                    end)
                end
                return ToggleFrame
            end

            function SecObj:CreateSlider(text, min, max, default, callback)
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 45)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = Container

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 15)
                Label.Text = text .. ": " .. default
                Label.BackgroundTransparency = 1
                Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                Label.Font = CustomFont
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = SliderFrame

                local Bar = Instance.new("Frame")
                Bar.Size = UDim2.new(1, 0, 0, 10)
                Bar.Position = UDim2.new(0, 0, 0, 25)
                Bar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                Bar.Parent = SliderFrame
                Library:AddStroke(Bar, Color3.fromRGB(255, 255, 255), 1)

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Fill.BorderSizePixel = 0
                Fill.Parent = Bar

                local dragging = false
                local function update(input)
                    local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    local value = math.floor(min + (max - min) * pos)
                    Label.Text = text .. ": " .. value
                    callback(value)
                end

                Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
            end

            function SecObj:CreateButton(text, callback)
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 30)
                Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                Btn.Font = CustomFont
                Btn.Text = text:upper()
                Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                Btn.TextSize = 12
                Btn.Parent = Container
                Library:AddStroke(Btn, Color3.fromRGB(255, 255, 255), 1)
                Btn.MouseButton1Click:Connect(callback)
                return Btn
            end

            function SecObj:CreateBind(text, default, callback)
                local BindBtn = Instance.new("TextButton")
                BindBtn.Size = UDim2.new(1, 0, 0, 28)
                BindBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                BindBtn.Text = "  " .. text:upper() .. ": " .. (default and default.Name or "NONE")
                BindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                BindBtn.Font = CustomFont
                BindBtn.TextSize = 11
                BindBtn.TextXAlignment = Enum.TextXAlignment.Left
                BindBtn.Parent = Container
                Library:AddStroke(BindBtn, Color3.fromRGB(255, 255, 255), 1)

                local binding = false
                BindBtn.MouseButton1Click:Connect(function() binding = true BindBtn.Text = "  " .. text:upper() .. ": PRESS KEY..." end)
                UserInputService.InputBegan:Connect(function(i)
                    if binding and (i.UserInputType == Enum.UserInputType.Keyboard or i.UserInputType.Name:find("MouseButton")) then
                        local key = (i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode or i.UserInputType)
                        BindBtn.Text = "  " .. text:upper() .. ": " .. key.Name:upper()
                        callback(key)
                        binding = false
                    end
                end)
            end

            function SecObj:CreateColorPicker(parentBtn, default, callback)
                Library:CreateAdvancedColorPicker(parentBtn, default, callback)
            end

            return SecObj
        end
        return TabObj
    end

    function WindowObj:CreateNavBtn(text, mode, imageId, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 32, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
        btn.Text = imageId and "" or text
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = CustomFont
        btn.TextSize = 14
        btn.Parent = NavBar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        Library:AddStroke(btn, Color3.fromRGB(60, 60, 60), 1)
        
        if imageId then
            local img = Instance.new("ImageLabel")
            img.Size = UDim2.new(0, 20, 0, 20)
            img.Position = UDim2.new(0.5, -10, 0.5, -10)
            img.BackgroundTransparency = 1
            img.Image = "rbxassetid://" .. imageId
            img.Parent = btn
        end
        
        btn.MouseButton1Click:Connect(callback)
    end

    return WindowObj
end

function Library:CreateAdvancedColorPicker(parent, default, callback)
    local PickerBtn = Instance.new("TextButton")
    PickerBtn.Size = UDim2.new(0, 20, 0, 12)
    PickerBtn.Position = UDim2.new(1, -25, 0.5, -6)
    PickerBtn.BackgroundColor3 = default
    PickerBtn.Text = ""
    PickerBtn.Parent = parent
    PickerBtn.ZIndex = 9999
    self:AddStroke(PickerBtn, Color3.new(1,1,1), 1)

    local PickerWindow = Instance.new("Frame")
    PickerWindow.Size = UDim2.new(0, 160, 0, 180)
    PickerWindow.Position = UDim2.new(1, 10, 0, 0)
    PickerWindow.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    PickerWindow.Visible = false
    PickerWindow.ZIndex = 10000
    PickerWindow.Parent = PickerBtn
    self:AddStroke(PickerWindow, Color3.new(1,1,1), 1)

    local SatValFrame = Instance.new("ImageLabel")
    SatValFrame.Size = UDim2.new(0, 130, 0, 130)
    SatValFrame.Position = UDim2.new(0, 5, 0, 5)
    SatValFrame.Image = "rbxassetid://4155801252"
    SatValFrame.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
    SatValFrame.ZIndex = 10001
    SatValFrame.Parent = PickerWindow
    self:AddStroke(SatValFrame, Color3.new(1,1,1), 1)

    local HueFrame = Instance.new("Frame")
    HueFrame.Size = UDim2.new(0, 12, 0, 130)
    HueFrame.Position = UDim2.new(0, 140, 0, 5)
    HueFrame.ZIndex = 10001
    HueFrame.Parent = PickerWindow
    self:AddStroke(HueFrame, Color3.new(1,1,1), 1)
    
    local HueGrad = Instance.new("UIGradient")
    HueGrad.Rotation = 90
    HueGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(0,1,1)), ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5,1,1)), ColorSequenceKeypoint.new(1, Color3.fromHSV(1,1,1))})
    HueGrad.Parent = HueFrame

    local h, s, v = default:ToHSV()
    local draggingSV, draggingH = false, false

    local function update()
        local clr = Color3.fromHSV(h, s, v)
        PickerBtn.BackgroundColor3 = clr
        SatValFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        callback(clr)
    end

    SatValFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = true end end)
    HueFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingH = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV, draggingH = false, false end end)
    UserInputService.InputChanged:Connect(function(i)
        if draggingSV then
            s = math.clamp((i.Position.X - SatValFrame.AbsolutePosition.X) / SatValFrame.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp((i.Position.Y - SatValFrame.AbsolutePosition.Y) / SatValFrame.AbsoluteSize.Y, 0, 1)
            update()
        elseif draggingH then
            h = 1 - math.clamp((i.Position.Y - HueFrame.AbsolutePosition.Y) / HueFrame.AbsoluteSize.Y, 0, 1)
            update()
        end
    end)
    PickerBtn.MouseButton1Click:Connect(function() PickerWindow.Visible = not PickerWindow.Visible end)
end
return Library
