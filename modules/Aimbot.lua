-- modules/Aimbot.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Aimbot = {}

-- ПОЛНЫЙ ФИКС для работы с мышью
local mouseMoveFunc
if mousemoverel then
    mouseMoveFunc = mousemoverel
else
    mouseMoveFunc = function(dx, dy)
        local currentCF = Camera.CFrame
        local sensitivity = 0.002
        local newCF = currentCF * CFrame.Angles(-dy * sensitivity, -dx * sensitivity, 0)
        Camera.CFrame = newCF
    end
end

-- Настройки по умолчанию
local SETTINGS = {
    Enabled = false,
    fovRadius = 120,
    targetPart = "Head",
    smoothness = 0.15,
    wallCheck = true,
    fullTarget = false,
    aimMethod = "Mouse",
    ignoreTeams = true,
    showFovCircle = false,
    holdPkmMode = false,
    
    -- Бинды
    AimKey = Enum.KeyCode.Insert,
    TargetKey = Enum.UserInputType.MouseButton2,
}

-- Состояние
local isTargetHeld = false
local fovCircle = nil
local lockedTarget = nil
local waitingForBind = nil

-- Экспортируемые функции
function Aimbot.getSetting(key)
    return SETTINGS[key]
end

function Aimbot.updateSetting(key, value)
    SETTINGS[key] = value
    print("[Aimbot] Настройка обновлена: " .. key .. " = " .. tostring(value))
end

function Aimbot.toggle()
    SETTINGS.Enabled = not SETTINGS.Enabled
    print("[Aimbot] " .. (SETTINGS.Enabled and "Включен" or "Выключен"))
    return SETTINGS.Enabled
end

function Aimbot.getBindText(bindType)
    if bindType == "Aim" then
        if type(SETTINGS.AimKey) == "userdata" then
            return SETTINGS.AimKey.Name or "Insert"
        end
        return "Insert"
    elseif bindType == "Target" then
        if SETTINGS.TargetKey == Enum.UserInputType.MouseButton2 then
            return "RMB"
        elseif type(SETTINGS.TargetKey) == "userdata" then
            return SETTINGS.TargetKey.Name or "RMB"
        end
        return "RMB"
    end
    return ""
end

function Aimbot.startBind(bindType)
    waitingForBind = bindType
    print("[Aimbot] Ожидание клавиши для: " .. bindType)
end

function Aimbot.resetBinds()
    SETTINGS.AimKey = Enum.KeyCode.Insert
    SETTINGS.TargetKey = Enum.UserInputType.MouseButton2
    print("[Aimbot] Бинды сброшены")
end

-- Функции для сохранения/загрузки
function Aimbot.saveSettings()
    local saved = {}
    for key, value in pairs(SETTINGS) do
        saved[key] = value
    end
    return saved
end

function Aimbot.loadSettings(savedSettings)
    if not savedSettings then return end
    for key, value in pairs(savedSettings) do
        if SETTINGS[key] ~= nil then
            SETTINGS[key] = value
        end
    end
end

-- Вспомогательные функции
local function updateFovCircle()
    if SETTINGS.showFovCircle then
        if not fovCircle then
            fovCircle = Drawing.new("Circle")
            fovCircle.Color = Color3.fromRGB(255, 255, 255)
            fovCircle.Thickness = 1
            fovCircle.NumSides = 60
            fovCircle.Filled = false
            fovCircle.Transparency = 0.5
            fovCircle.Radius = SETTINGS.fovRadius
            fovCircle.Visible = true
        end
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        fovCircle.Radius = SETTINGS.fovRadius
    elseif fovCircle then
        fovCircle:Remove()
        fovCircle = nil
    end
end

local function getTargetPart(player)
    if not player or not player.Character then return nil end
    local char = player.Character
    
    local part = char:FindFirstChild(SETTINGS.targetPart)
    if part then return part end
    
    local alternatives = {
        Head = {"Head", "HeadHB", "HeadHitbox"},
        UpperTorso = {"UpperTorso", "Torso", "Chest"},
        HumanoidRootPart = {"HumanoidRootPart", "RootPart", "Torso"}
    }
    
    for _, alt in ipairs(alternatives[SETTINGS.targetPart] or {}) do
        part = char:FindFirstChild(alt)
        if part then return part end
    end
    
    return char:FindFirstChildOfClass("BasePart")
end

local function isValidTarget(player)
    if player == LocalPlayer then return false end
    if not player.Character then return false end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    if SETTINGS.ignoreTeams and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        return false
    end
    
    return true
end

local function isInFov(player)
    if not player or not player.Character then return false end
    
    local part = getTargetPart(player)
    if not part then return false end
    
    local partScreen, onScreen = Camera:WorldToViewportPoint(part.Position)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local screenDist = (Vector2.new(partScreen.X, partScreen.Y) - screenCenter).Magnitude
    
    return screenDist <= SETTINGS.fovRadius and onScreen
end

local function findNearestEnemy()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    
    local myPos = myChar:FindFirstChild("HumanoidRootPart") or myChar.PrimaryPart
    if not myPos then return nil end
    myPos = myPos.Position
    
    -- Full Target проверка
    if SETTINGS.fullTarget and lockedTarget then
        if isValidTarget(lockedTarget) and isInFov(lockedTarget) then
            if SETTINGS.wallCheck then
                local part = getTargetPart(lockedTarget)
                if part then
                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                    rayParams.IgnoreWater = true
                    
                    local rayResult = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, rayParams)
                    if rayResult and rayResult.Instance:IsDescendantOf(lockedTarget.Character) then
                        return lockedTarget
                    end
                end
            else
                return lockedTarget
            end
        end
        lockedTarget = nil
    end
    
    -- Обычный поиск
    local nearest = nil
    local nearestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if isValidTarget(player) then
            local char = player.Character
            local part = getTargetPart(player)
            if part then
                local partScreen, onScreen = Camera:WorldToViewportPoint(part.Position)
                local screenDist = (Vector2.new(partScreen.X, partScreen.Y) - screenCenter).Magnitude
                
                if screenDist <= SETTINGS.fovRadius and onScreen then
                    local worldDist = (myPos - part.Position).Magnitude
                    if worldDist < nearestDist and worldDist < 1000 then
                        local canSee = true
                        if SETTINGS.wallCheck then
                            local rayParams = RaycastParams.new()
                            rayParams.FilterType = Enum.RaycastFilterType.Exclude
                            rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                            rayParams.IgnoreWater = true
                            
                            local rayResult = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, rayParams)
                            canSee = rayResult and rayResult.Instance:IsDescendantOf(char)
                        end
                        
                        if canSee then
                            nearestDist = worldDist
                            nearest = player
                        end
                    end
                end
            end
        end
    end
    
    if SETTINGS.fullTarget and nearest then
        lockedTarget = nearest
    end
    
    return nearest or lockedTarget
end

-- Методы аима
local function aimWithMouse(targetPos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
    if not onScreen then return end
    
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
    
    local delta = targetScreenPos - screenCenter
    delta = delta * SETTINGS.smoothness
    mouseMoveFunc(delta.X, delta.Y)
end

local function aimWithCamera(targetPos)
    local direction = (targetPos - Camera.CFrame.Position).Unit
    local targetCF = CFrame.lookAt(Camera.CFrame.Position, targetPos)
    Camera.CFrame = Camera.CFrame:Lerp(targetCF, SETTINGS.smoothness)
end

-- Обработка ввода (ПОЛНЫЙ ФИКС для всех клавиш)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if waitingForBind then
        local newBind = nil
        if input.UserInputType == Enum.UserInputType.Keyboard then
            newBind = input.KeyCode
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.MouseButton2 then
            newBind = input.UserInputType
        end
        
        if newBind then
            if waitingForBind == "Aim" then
                SETTINGS.AimKey = newBind
                print("[Aimbot] Aim key установлен: " .. (input.KeyCode and input.KeyCode.Name or "Mouse"))
            elseif waitingForBind == "Target" then
                SETTINGS.TargetKey = newBind
                print("[Aimbot] Target key установлен: " .. (input.KeyCode and input.KeyCode.Name or "Mouse"))
            end
            waitingForBind = nil
        end
        return
    end
    
    if gameProcessed then return end
    
    -- Проверка Aim Key (работает для ВСЕХ клавиш)
    local isAimKey = false
    if input.KeyCode ~= Enum.KeyCode.Unknown then
        if input.KeyCode == SETTINGS.AimKey then
            isAimKey = true
        end
    elseif input.UserInputType == SETTINGS.AimKey then
        isAimKey = true
    end
    
    if isAimKey then
        SETTINGS.Enabled = not SETTINGS.Enabled
        print("[Aimbot] " .. (SETTINGS.Enabled and "ВКЛЮЧЕН" or "ВЫКЛЮЧЕН") .. " на " .. Aimbot.getBindText("Aim"))
    end
    
    -- Проверка Target Key
    local isTargetKey = false
    if input.KeyCode ~= Enum.KeyCode.Unknown then
        if input.KeyCode == SETTINGS.TargetKey then
            isTargetKey = true
        end
    elseif input.UserInputType == SETTINGS.TargetKey then
        isTargetKey = true
    end
    
    if isTargetKey then
        isTargetHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local isTargetKey = false
    if input.KeyCode ~= Enum.KeyCode.Unknown then
        if input.KeyCode == SETTINGS.TargetKey then
            isTargetKey = true
        end
    elseif input.UserInputType == SETTINGS.TargetKey then
        isTargetKey = true
    end
    
    if isTargetKey then
        isTargetHeld = false
    end
end)

-- Основной цикл Aimbot
local aimbotConnection = RunService.Heartbeat:Connect(function()
    updateFovCircle()
    
    local active = SETTINGS.Enabled and (not SETTINGS.holdPkmMode or isTargetHeld)
    if not active or not LocalPlayer.Character then 
        if lockedTarget and not SETTINGS.fullTarget then
            lockedTarget = nil
        end
        return 
    end
    
    local target = findNearestEnemy()
    if not target then return end
    
    local part = getTargetPart(target)
    if not part then return end
    
    if SETTINGS.aimMethod == "Mouse" then
        aimWithMouse(part.Position)
    else
        aimWithCamera(part.Position)
    end
end)

-- Функция очистки
function Aimbot.cleanup()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    
    if fovCircle then
        fovCircle:Remove()
        fovCircle = nil
    end
end

-- Функция для получения всех настроек (для GUI)
function Aimbot.getAllSettings()
    local settings = {}
    for key, value in pairs(SETTINGS) do
        settings[key] = value
    end
    return settings
end

-- Функция для обновления цвета FOV круга
function Aimbot.updateFovColor(color)
    if fovCircle then
        fovCircle.Color = color
    end
end

-- Инициализация
print("✅ Aimbot модуль загружен")
print("🎯 Aim Key: " .. Aimbot.getBindText("Aim"))
print("🎯 Target Key: " .. Aimbot.getBindText("Target"))
print("⚙️ Метод: " .. SETTINGS.aimMethod)
print("🎯 Часть: " .. SETTINGS.targetPart)

return Aimbot
