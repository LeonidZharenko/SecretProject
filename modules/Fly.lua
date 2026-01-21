-- modules/fly.lua - Оптимизированный модуль Fly с фиксом вертикального полета
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
local lastCameraCFrame = nil

-- Флаги для отслеживания вертикального движения
local verticalMoveActive = false
local verticalStopTimer = 0

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

-- Optimized function to create fly objects
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
    
    verticalMoveActive = false
    verticalStopTimer = 0
end

-- Функция для мгновенной остановки вертикального движения
local function stopVerticalMovement()
    if bodyVelocity then
        local currentVelocity = bodyVelocity.Velocity
        bodyVelocity.Velocity = Vector3.new(currentVelocity.X, 0, currentVelocity.Z)
    end
end

-- Optimized function to update fly movement
local function updateFly()
    if not flying or not bodyVelocity or not bodyGyro then return end
    
    -- Get camera direction
    local camera = workspace.CurrentCamera
    local lookVector = camera.CFrame.LookVector
    local rightVector = camera.CFrame.RightVector
    
    -- Рассчитываем горизонтальное направление
    local horizontalDirection = Vector3.new(0, 0, 0)
    
    if activeKeys.forward then 
        horizontalDirection = horizontalDirection + lookVector 
    elseif activeKeys.backward then 
        horizontalDirection = horizontalDirection - lookVector 
    end
    
    if activeKeys.left then 
        horizontalDirection = horizontalDirection - rightVector 
    elseif activeKeys.right then 
        horizontalDirection = horizontalDirection + rightVector 
    end
    
    -- Нормализуем горизонтальное направление
    if horizontalDirection.Magnitude > 0 then
        horizontalDirection = horizontalDirection.Unit * speed
    end
    
    -- Обрабатываем вертикальное движение отдельно с более строгим контролем
    local verticalSpeed = 0
    local currentVerticalMoveActive = false
    
    if activeKeys.up then 
        verticalSpeed = speed
        currentVerticalMoveActive = true
    elseif activeKeys.down then 
        verticalSpeed = -speed
        currentVerticalMoveActive = true
    end
    
    -- Если вертикальное движение изменилось (началось или закончилось)
    if verticalMoveActive ~= currentVerticalMoveActive then
        verticalMoveActive = currentVerticalMoveActive
        
        -- Если вертикальное движение прекратилось, немедленно останавливаем вертикальную скорость
        if not verticalMoveActive then
            stopVerticalMovement()
            verticalStopTimer = 3 -- 3 кадра для гарантированной остановки
        end
    end
    
    -- Если таймер активен, продолжаем гарантировать отсутствие вертикального движения
    if verticalStopTimer > 0 then
        stopVerticalMovement()
        verticalStopTimer = verticalStopTimer - 1
    end
    
    -- Создаем финальный вектор скорости
    local finalVelocity = Vector3.new(horizontalDirection.X, verticalSpeed, horizontalDirection.Z)
    
    -- Если нет вертикального движения, убеждаемся что Y = 0
    if not currentVerticalMoveActive then
        finalVelocity = Vector3.new(finalVelocity.X, 0, finalVelocity.Z)
    end
    
    -- Применяем скорость
    bodyVelocity.Velocity = finalVelocity
    
    -- Обновляем гироскоп для направления камеры
    bodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + lookVector)
end

-- Public method: Toggle fly on/off
function FlyController.toggle()
    ensureCharacter()
    flying = not flying
    
    if flying then
        createFlyObjects()
        humanoid.PlatformStand = true
        print("Fly: ON")
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
        lastCameraCFrame = nil
        verticalMoveActive = false
        verticalStopTimer = 0
        print("Fly: OFF")
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
        lastCameraCFrame = nil
        verticalMoveActive = false
        verticalStopTimer = 0
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

-- Optimized update loop for fly movement
RunService.RenderStepped:Connect(function(deltaTime)
    if flying then
        updateFly()
    end
end)

-- Optimized key updates
local lastKeyUpdate = tick()
local keyUpdateInterval = 0.01

RunService.Heartbeat:Connect(function(deltaTime)
    if flying then
        local now = tick()
        if now - lastKeyUpdate > keyUpdateInterval then
            local keys = {
                forward = UserInputService:IsKeyDown(Enum.KeyCode.W),
                backward = UserInputService:IsKeyDown(Enum.KeyCode.S),
                left = UserInputService:IsKeyDown(Enum.KeyCode.A),
                right = UserInputService:IsKeyDown(Enum.KeyCode.D),
                up = UserInputService:IsKeyDown(Enum.KeyCode.Space),
                down = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
            }
            FlyController.setKeys(keys)
            lastKeyUpdate = now
        end
    end
end)

return FlyController
