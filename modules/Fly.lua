--[[
    Чистый Fly Script для Roblox с регулировкой скорости
    Только логика полета, без привязок клавиш
    Подходит для интеграции в UI-библиотеки
    
    Публичные методы:
    FlyController.toggle() - включить/выключить полет
    FlyController.setSpeed(number) - установить скорость
    FlyController.getSpeed() - получить текущую скорость
    FlyController.setKeys(table) - установить активные клавиши
    
    Использование:
    1. Импортируйте этот скрипт
    2. Вызывайте методы из вашей UI
    3. Передавайте состояние клавиш через setKeys()
]]

local FlyController = {}
FlyController.__index = FlyController

-- Services
local RunService = game:GetService("RunService")

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
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    
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
    
    -- Get camera direction
    local camera = workspace.CurrentCamera
    local lookVector = camera.CFrame.LookVector
    local rightVector = camera.CFrame.RightVector
    
    -- Calculate movement direction
    local direction = Vector3.new(0, 0, 0)
    
    if activeKeys.forward then direction = direction + lookVector end
    if activeKeys.backward then direction = direction - lookVector end
    if activeKeys.left then direction = direction - rightVector end
    if activeKeys.right then direction = direction + rightVector end
    if activeKeys.up then direction = direction + Vector3.new(0, 1, 0) end
    if activeKeys.down then direction = direction + Vector3.new(0, -1, 0) end
    
    -- Normalize and apply speed
    if direction.Magnitude > 0 then
        direction = direction.Unit * speed
    end
    
    -- Update velocity
    bodyVelocity.Velocity = direction
    
    -- Update gyro to face camera direction
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
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
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
}

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
    -- Clamp current speed to new limits
    speed = math.clamp(speed, minSpeed, maxSpeed)
end

-- Public method: Stop fly immediately
function FlyController.stop()
    if flying then
        flying = false
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
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
    
    -- Reset fly on respawn
    if flying then
        FlyController.stop()
        flying = false
    end
end)

-- Initial character setup
task.spawn(function()
    ensureCharacter()
end)

-- Update loop
RunService.RenderStepped:Connect(function()
    if flying then
        updateFly()
    end
end)

-- Initialize controller
FlyController.initialized = true

return FlyController
