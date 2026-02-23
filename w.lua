-- hanet Script
-- Credits: @hanet0_0

local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local flying = false
local flySpeed = 50
local bv, bg

-- Красивое уведомление при запуске
local function startupNotification()
    game.StarterGui:SetCore("SendNotification", {
        Title = "✨ hanet Script",
        Text = "Successfully loaded!\nBy @hanet0_0",
        Icon = "rbxassetid://6023426926",
        Duration = 7
    })

    print([[
        ____________________________________________
        
           HANET SCRIPT OPTIMIZED
           Author: @hanet0_0
           Status: Instant Execution Enabled
        ____________________________________________
    ]])
end

startupNotification()

-- Оптимизированная функция полета (мгновенный отклик)
local function startFlying()
    if flying then return end
    flying = true
    
    task.spawn(function()
        local char = player.Character or player.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")
        
        -- Удаляем старые объекты если остались
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end

        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = root
        
        bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 9000
        bg.CFrame = root.CFrame
        bg.Parent = root
        
        -- Цикл движения привязан к RenderStepped для максимальной плавности
        while flying and root and root.Parent do
            local cam = workspace.CurrentCamera.CFrame
            local direction = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + cam.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - cam.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - cam.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + cam.RightVector
            end
            
            bv.Velocity = direction * flySpeed
            bg.CFrame = cam
            RunService.RenderStepped:Wait()
        end
        
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end)
end

local function stopFlying()
    flying = false
end

-- Мгновенная телепортация
local function teleportToPlayer(targetName)
    local target = nil
    local searchName = targetName:lower()
    
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and (p.Name:lower():sub(1, #searchName) == searchName or p.DisplayName:lower():sub(1, #searchName) == searchName) then
            target = p
            break
        end
    end

    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            -- Используем task.defer для обхода лагов физики
            task.defer(function()
                root.CFrame = target.Character.HumanoidRootPart.CFrame
            end)
            
            game.StarterGui:SetCore("SendNotification", {
                Title = "Teleport",
                Text = "Instant TP to " .. target.DisplayName,
                Duration = 2
            })
        end
    end
end

-- Оптимизированный обработчик команд (выполняется локально до синхронизации с сервером)
local function handleCommand(msg)
    local args = string.split(msg, " ")
    if #args == 0 then return end
    
    local command = args[1]:lower()

    -- Используем task.spawn для мгновенного выполнения без ожидания очереди потоков
    task.spawn(function()
        if command == "/fly" then
            startFlying()
        elseif command == "/unfly" then
            stopFlying()
        elseif command == "/flyspeed" then
            if args[2] then
                flySpeed = tonumber(args[2]) or 50
            end
        elseif command == "/tp" then
            if args[2] then
                teleportToPlayer(args[2])
            end
        end
    end)
end

-- СЛУШАТЕЛИ ЧАТА (Приоритет на локальное выполнение)

-- 1. Стандартный Chatted (быстрее всего на старых движках)
player.Chatted:Connect(handleCommand)

-- 2. TextChatService (Для новых игр, работает быстрее при плохом пинге)
if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    -- Используем SendingMessage для перехвата ДО отправки на сервер
    TextChatService.SendingMessage:Connect(function(data)
        handleCommand(data.Text)
    end)
    
    -- Запасной вариант
    TextChatService.MessageReceived:Connect(function(data)
        if data.TextSource and data.TextSource.UserId == player.UserId then
            handleCommand(data.Text)
        end
    end)
end

-- Авто-обновление персонажа при смерти (чтобы команды не ломались)
player.CharacterAdded:Connect(function(newChar)
    if flying then
        flying = false
        task.wait(0.1)
        startFlying()
    end
end)
