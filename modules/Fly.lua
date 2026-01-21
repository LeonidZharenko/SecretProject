-- modules/fly.lua - Чистый Fly модуль для интеграции
local FlyController = {}
FlyController.__index = FlyController

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Fly variables
local SPEED = 50
local MIN_SPEED = 10
local MAX_SPEED = 200
local isFlying = false

-- Internal variables
local player = Players.LocalPlayer
local character, humanoid, rootPart
local BV, BG -- BodyVelocity и BodyGyro

-- Функция получения персонажа
local function getCharacter()
    character = player.Character
    if character then
        humanoid = character:FindFirstChild("Humanoid")
        rootPart = character:FindFirstChild("HumanoidRootPart")
        return character, humanoid, rootPart
    end
    return nil, nil, nil
end

-- Функция включения/выключения полета
function FlyController.toggle()
    local char, hum, root = getCharacter()
    if not char or not hum or not root then 
        return false
    end
    
    isFlying = not isFlying
    
    if isFlying then
        -- ВКЛЮЧАЕМ ПОЛЕТ
        -- Включаем PlatformStand
        hum.PlatformStand = true
        
        -- Создаем BodyVelocity и BodyGyro
        BV = Instance.new("BodyVelocity")
        BG = Instance.new("BodyGyro")
        
        -- Настройка BodyVelocity
        BV.P = 100000
        BV.MaxForce = Vector3.new(100000, 100000, 100000)
        BV.Velocity = Vector3.new(0, 0, 0)
        
        -- Настройка BodyGyro
        BG.P = 100000
        BG.MaxTorque = Vector3.new(100000, 100000, 100000)
        BG.CFrame = root.CFrame
        
        -- Присоединяем к корневой части
        BV.Parent = root
        BG.Parent = root
        
        -- Запускаем цикл полета
        spawn(function()
            while isFlying and BV and BG do
                -- Проверяем что персонаж еще существует
                if not player.Character or not root.Parent then
                    break
                end
                
                -- Получаем векторы камеры
                local camera = workspace.CurrentCamera
                local lookVector = camera.CFrame.lookVector
                local rightVector = camera.CFrame.rightVector
                
                -- Рассчитываем направление движения
                local direction = Vector3.new(0, 0, 0)
                
                -- W - вперед
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    direction = direction + lookVector
                end
                
                -- S - назад
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    direction = direction - lookVector
                end
                
                -- A - влево
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    direction = direction - rightVector
                end
                
                -- D - вправо
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    direction = direction + rightVector
                end
                
                -- Применяем скорость
                if direction.Magnitude > 0 then
                    -- Нормализуем и умножаем на скорость
                    direction = direction.Unit * SPEED
                    BV.Velocity = direction
                else
                    -- Если клавиши не нажаты - останавливаемся
                    BV.Velocity = Vector3.new(0, 0, 0)
                end
                
                -- Обновляем поворот к камере
                BG.CFrame = CFrame.new(root.Position, root.Position + lookVector)
                
                -- Ждем следующий кадр
                RunService.RenderStepped:Wait()
            end
            
            -- Очистка после выхода из цикла
            if BV then
                BV:Destroy()
                BV = nil
            end
            if BG then
                BG:Destroy()
                BG = nil
            end
            if hum and hum.Parent then
                hum.PlatformStand = false
            end
        end)
        
    else
        -- ВЫКЛЮЧАЕМ ПОЛЕТ
        isFlying = false
        
        -- Уничтожаем BodyVelocity и BodyGyro
        if BV then
            BV:Destroy()
            BV = nil
        end
        if BG then
            BG:Destroy()
            BG = nil
        end
        
        -- Выключаем PlatformStand
        if hum then
            hum.PlatformStand = false
        end
    end
    
    return isFlying
end

-- Функция изменения скорости
function FlyController.setSpeed(newSpeed)
    if type(newSpeed) ~= "number" then return end
    SPEED = math.clamp(newSpeed, MIN_SPEED, MAX_SPEED)
    return SPEED
end

-- Получить текущую скорость
function FlyController.getSpeed()
    return SPEED
end

-- Проверить состояние полета
function FlyController.isFlying()
    return isFlying
end

-- Получить минимальную и максимальную скорость
function FlyController.getSpeedLimits()
    return MIN_SPEED, MAX_SPEED
end

-- Остановить полет принудительно
function FlyController.stop()
    if isFlying then
        isFlying = false
        if BV then
            BV:Destroy()
            BV = nil
        end
        if BG then
            BG:Destroy()
            BG = nil
        end
        if humanoid then
            humanoid.PlatformStand = false
        end
        return true
    end
    return false
end

-- Обработка респавна персонажа
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    
    if isFlying then
        isFlying = false
        if BV then BV:Destroy() end
        if BG then BG:Destroy() end
    end
end)

-- Инициализация
task.spawn(function()
    wait(2)
    getCharacter()
    print("[Fly Module] Загружен и готов к работе")
end)

return FlyController
