-- modules/fly.lua - Чистый Fly (куда смотришь - туда летишь)
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
    right = false
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

-- Function to update fly movement
local function updateFly()
    if not flying or not bodyVelocity or not bodyGyro then return end
    
    -- Получаем векторы направления камеры
    local camera = workspace.CurrentCamera
    local cameraCFrame = camera.CFrame
    
    -- Основные векторы камеры
    local lookVector = cameraCFrame.LookVector  -- Куда смотрим
    local rightVector = cameraCFrame.RightVector -- Вправо от камеры
    
    -- Рассчитываем направление движения
    local direction = Vector3.new(0, 0, 0)
    
    -- W - вперед по направлению взгляда
    if activeKeys.forward then 
        direction = direction + lookVector 
    end
    
    -- S - назад по направлению взгляда
    if activeKeys.backward then 
        direction = direction - lookVector 
    end
    
    -- A - влево относительно камеры
    if activeKeys.left then 
        direction = direction - rightVector 
    end
    
    -- D - вправо относительно камеры
    if activeKeys.right then 
        direction = direction + rightVector 
    end
    
    -- Нормализуем и применяем скорость
    if direction.Magnitude > 0 then
        direction = direction.Unit * speed
        bodyVelocity.Velocity = direction
    else
        -- Если клавиши не нажаты - останавливаемся
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    end
    
    -- Поворачиваем персонажа в сторону взгляда (опционально)
    bodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + lookVector)
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

-- Update key states every frame
RunService.Heartbeat:Connect(function()
    if flying then
        local keys = {
            forward = UserInputService:IsKeyDown(Enum.KeyCode.W),
            backward = UserInputService:IsKeyDown(Enum.KeyCode.S),
            left = UserInputService:IsKeyDown(Enum.KeyCode.A),
            right = UserInputService:IsKeyDown(Enum.KeyCode.D)
        }
        FlyController.setKeys(keys)
    end
end)

return FlyController
