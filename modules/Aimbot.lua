-- modules/Aimbot.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Aimbot = {}

-- ПОЛНЫЙ ФИКС для работы с мышью в любом executor'е
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
end

function Aimbot.toggle()
    SETTINGS.Enabled = not SETTINGS.Enabled
    return SETTINGS.Enabled
end

function Aimbot.setBind(bindType, input)
    if bindType == "Aim" then
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            SETTINGS.AimKey = input.KeyCode
        elseif input.UserInputType then
            SETTINGS.AimKey = input.UserInputType
        end
    elseif bindType == "Target" then
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            SETTINGS.TargetKey = input.KeyCode
        elseif input.UserInputType then
            SETTINGS.TargetKey = input.UserInputType
        end
    end
end

function Aimbot.getBindText(bindType)
    if bindType == "Aim" then
        return SETTINGS.AimKey.Name or "Insert"
    elseif bindType == "Target" then
        return SETTINGS.TargetKey == Enum.UserInputType.MouseButton2 and "RMB" or 
               (SETTINGS.TargetKey.Name or "RMB")
    end
    return ""
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

local function findNearestEnemy()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    
    local myPos = myChar:FindFirstChild("HumanoidRootPart") or myChar.PrimaryPart
    if not myPos then return nil end
    myPos = myPos.Position
    
    -- Full Target проверка
    if SETTINGS.fullTarget and lockedTarget then
        if isValidTarget(lockedTarget) then
            local part = getTargetPart(lockedTarget)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if screenDist <= SETTINGS.fovRadius then
                        if SETTINGS.wallCheck then
                            local rayParams = RaycastParams.new()
                            rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                            rayParams.FilterType = Enum.RaycastFilterType.Exclude
                            local ray = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, rayParams)
                            if not ray or ray.Instance:IsDescendantOf(lockedTarget.Character) then
                                return lockedTarget
                            end
                        else
                            return lockedTarget
                        end
                    end
                end
            end
        end
        lockedTarget = nil
    end
    
    -- Поиск новой цели
    local nearest = nil
    local nearestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if isValidTarget(player) then
            local part = getTargetPart(player)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if screenDist <= SETTINGS.fovRadius then
                        local worldDist = (myPos - part.Position).Magnitude
                        if worldDist < nearestDist and worldDist < 1000 then
                            if SETTINGS.wallCheck then
                                local rayParams = RaycastParams.new()
                                rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                local ray = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, rayParams)
                                if not ray or ray.Instance:IsDescendantOf(player.Character) then
                                    nearestDist = worldDist
                                    nearest = player
                                end
                            else
                                nearestDist = worldDist
                                nearest = player
                            end
                        end
                    end
                end
            end
        end
    end
    
    if nearest and SETTINGS.fullTarget then
        lockedTarget = nearest
    end
    
    return nearest
end

-- Методы аима
local function aimWithMouse(targetPos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
    if not onScreen then return end
    
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local targetPos2D = Vector2.new(screenPos.X, screenPos.Y)
    local delta = targetPos2D - screenCenter
    
    delta = delta * SETTINGS.smoothness
    mouseMoveFunc(delta.X, delta.Y)
end

local function aimWithCamera(targetPos)
    local targetCF = CFrame.lookAt(Camera.CFrame.Position, targetPos)
    Camera.CFrame = Camera.CFrame:Lerp(targetCF, SETTINGS.smoothness)
end

-- Обработка ввода
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if waitingForBind then
        Aimbot.setBind(waitingForBind, input)
        waitingForBind = nil
        return
    end
    
    if gameProcessed then return end
    
    -- Проверка Aim Key
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

-- Основной цикл
RunService.Heartbeat:Connect(function()
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

-- Функция для начала перебинда
function Aimbot.startBind(bindType)
    waitingForBind = bindType
end

-- Функция для сброса биндов
function Aimbot.resetBinds()
    SETTINGS.AimKey = Enum.KeyCode.Insert
    SETTINGS.TargetKey = Enum.UserInputType.MouseButton2
end

-- Функция очистки
function Aimbot.cleanup()
    if fovCircle then
        fovCircle:Remove()
        fovCircle = nil
    end
end

-- Сохранение настроек
function Aimbot.saveSettings()
    return SETTINGS
end

-- Загрузка настроек
function Aimbot.loadSettings(savedSettings)
    if savedSettings then
        for key, value in pairs(savedSettings) do
            if SETTINGS[key] ~= nil then
                SETTINGS[key] = value
            end
        end
    end
end

print("✅ Aimbot модуль загружен")
return Aimbot
