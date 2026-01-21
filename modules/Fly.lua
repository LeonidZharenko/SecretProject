-- modules/fly.lua - Классический Fly с фиксом инерции
local FlyController = {}
FlyController.__index = FlyController

-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Fly variables
local flying = false
local speed = 50
local minSpeed = 10
local maxSpeed = 200
local bodyVelocity, bodyGyro

-- Active keys state
local activeKeys = {
    forward = false,
    backward = false,
    left = false,
    right = false,
    up = false,
    down = false
}

-- Character references
local character, humanoid, rootPart

-- Internal function to get character parts
local function ensureCharacter()
    if not character or not character.Parent then
        local player = game.Players.LocalPlayer
        character = player.Character or player.CharacterAdded:Wait()
        humanoid = character:WaitForChild("Humanoid")
        rootPart = character:WaitForChild("HumanoidRootPart")
    end
    return character, humanoid, rootPart
end

-- Function to create fly objects
local function createFlyObjects()
    if bodyVelocity then 
        bodyVelocity:Destroy() 
        bodyVelocity = nil
    end
    if bodyGyro then 
        bodyGyro:Destroy() 
        bodyGyro = nil
    end
    
    ensureCharacter()
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyGyro = Instance.new("BodyGyro")
    
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyVelocity.P = 1250
    
    bodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
    bodyGyro.P = 1250
    bodyGyro.D = 250
    
    bodyVelocity.Parent = rootPart
    bodyGyro.Parent = rootPart
end

-- Function to update fly movement (классический полет)
local function updateFly()
    if not flying or not bodyVelocity or not bodyGyro then return end
    
    -- Получаем векторы направления камеры
    local camera = workspace.CurrentCamera
    local cameraCFrame = camera.CFrame
    
    -- Основные векторы камеры
    local lookVector = cameraCFrame.LookVector  -- Куда смотрим
    local rightVector = cameraCFrame.RightVector -- Вправо от камеры
    local upVector = cameraCFrame.UpVector       -- Вверх от камеры
    
    -- Рассчитываем направление движения
    local direction = Vector3.new(0, 0, 0)
    
    -- W/S - вперед/назад по направлению взгляда
    if activeKeys.forward then 
        direction = direction + lookVector 
    end
    if activeKeys.backward then 
        direction = direction - lookVector 
    end
    
    -- A/D - влево/вправо относительно камеры
    if activeKeys.left then 
        direction = direction - rightVector 
    end
    if activeKeys.right then 
        direction = direction + rightVector 
    end
    
    -- Space/Shift - вверх/вниз относительно камеры
    if activeKeys.up then 
        direction = direction + upVector 
    end
    if activeKeys.down then 
        direction = direction - upVector 
    end
    
    -- Нормализуем и применяем скорость
    if direction.Magnitude > 0 then
        direction = direction.Unit * speed
    end
    
    -- ФИКС: Получаем текущую позицию персонажа
    local currentPosition = rootPart.Position
    
    -- ФИКС: Применяем скорость с учетом возможной инерции
    -- Если направление близко к нулю, сбрасываем скорость полностью
    if direction.Magnitude < 0.1 then
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    else
        -- ФИКС: Отдельно обрабатываем вертикальную компоненту
        -- Если не нажаты вверх/вниз, устанавливаем вертикальную скорость в 0
        if not activeKeys.up and not activeKeys.down then
            -- Сохраняем горизонтальную скорость, но сбрасываем вертикальную
            local horizontalVelocity = Vector3.new(direction.X, 0, direction.Z)
            -- Проверяем, нужно ли вообще применять горизонтальную скорость
            if horizontalVelocity.Magnitude > 0 then
                bodyVelocity.Velocity = horizontalVelocity.Unit * speed
            else
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        else
            -- Если нажаты вверх/вниз, применяем полную скорость
            bodyVelocity.Velocity = direction
        end
    end
    
    -- Поворачиваем персонажа в сторону взгляда
    bodyGyro.CFrame = CFrame.new(currentPosition, currentPosition + lookVector)
end

-- Функция для принудительной остановки движения
local function forceStopMovement()
    if bodyVelocity then
        -- ФИКС: Полностью сбрасываем скорость и пересоздаем BodyVelocity
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        
        -- Создаем новый BodyVelocity для гарантированного сброса инерции
        local newBodyVelocity = Instance.new("BodyVelocity")
        newBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        newBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        newBodyVelocity.P = 1250
        
        if bodyVelocity.Parent then
            bodyVelocity:Destroy()
            newBodyVelocity.Parent = rootPart
            bodyVelocity = newBodyVelocity
        end
    end
end

-- Public method: Toggle fly on/off
function FlyController.toggle()
    ensureCharacter()
    flying = not flying
    
    if flying then
        createFlyObjects()
        humanoid.PlatformStand = true
    else
        if bodyVelocity then 
            bodyVelocity:Destroy() 
            bodyVelocity = nil
        end
        if bodyGyro then 
            bodyGyro:Destroy() 
            bodyGyro = nil
        end
        humanoid.PlatformStand = false
    end
    
    return flying
end

-- Public method: Set fly speed
function FlyController.setSpeed(newSpeed)
    if type(newSpeed) ~= "number" then return end
    speed = math.clamp(newSpeed, minSpeed, maxSpeed)
    return speed
end

-- Public method: Get current speed
function FlyController.getSpeed()
    return speed
end

-- Public method: Set active keys
function FlyController.setKeys(keys)
    if type(keys) ~= "table" then return end
    for key, value in pairs(keys) do
        if activeKeys[key] ~= nil then
            activeKeys[key] = value == true
        end
    end
end

-- Public method: Set specific key state
function FlyController.setKey(key, state)
    if activeKeys[key] ~= nil then
        activeKeys[key] = state == true
    end
end

-- Public method: Check if flying
function FlyController.isFlying()
    return flying
end

-- Public method: Get min/max speed
function FlyController.getSpeedLimits()
    return minSpeed, maxSpeed
end

-- Public method: Set speed limits
function FlyController.setSpeedLimits(min, max)
    if type(min) == "number" then minSpeed = math.max(1, min) end
    if type(max) == "number" then maxSpeed = math.max(minSpeed, max) end
    speed = math.clamp(speed, minSpeed, maxSpeed)
end

-- Public method: Stop fly immediately
function FlyController.stop()
    if flying then
        flying = false
        if bodyVelocity then 
            bodyVelocity:Destroy() 
            bodyVelocity = nil
        end
        if bodyGyro then 
            bodyGyro:Destroy() 
            bodyGyro = nil
        end
        if humanoid then
            humanoid.PlatformStand = false
        end
        return true
    end
    return false
end

-- Character respawn handling
game.Players.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    if flying then
        FlyController.stop()
        flying = false
    end
end)

-- Initial character setup
task.spawn(function()
    ensureCharacter()
end)

-- Update loop for fly movement
RunService.RenderStepped:Connect(function()
    if flying then
        updateFly()
    end
end)

-- Update key states with forced stop fix
RunService.Heartbeat:Connect(function()
    if flying then
        local keys = {
            forward = UserInputService:IsKeyDown(Enum.KeyCode.W),
            backward = UserInputService:IsKeyDown(Enum.KeyCode.S),
            left = UserInputService:IsKeyDown(Enum.KeyCode.A),
            right = UserInputService:IsKeyDown(Enum.KeyCode.D),
            up = UserInputService:IsKeyDown(Enum.KeyCode.Space),
            down = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
        }
        
        -- ФИКС: Проверяем, отпустили ли клавиши вверх/вниз
        local wasVerticalPressed = activeKeys.up or activeKeys.down
        local isVerticalPressed = keys.up or keys.down
        
        -- Если отпустили вертикальные клавиши, принудительно останавливаем движение
        if wasVerticalPressed and not isVerticalPressed then
            forceStopMovement()
        end
        
        FlyController.setKeys(keys)
    end
end)

return FlyController
