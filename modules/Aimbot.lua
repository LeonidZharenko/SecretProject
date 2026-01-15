local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ПОЛНЫЙ ФИКС для работы с мышью в любом executor'е
local mouseMoveFunc
if mousemoverel then
    mouseMoveFunc = mousemoverel
else
    mouseMoveFunc = function(dx, dy)
        -- Универсальный метод через изменение углов камеры
        local currentCF = Camera.CFrame
        local sensitivity = 0.002 -- Чувствительность
        local newCF = currentCF * CFrame.Angles(-dy * sensitivity, -dx * sensitivity, 0)
        Camera.CFrame = newCF
    end
    warn("mousemoverel не найден, используется камерный метод")
end

-- Основные настройки
local aimbotEnabled = false
local maxDist = 1000

local SETTINGS = {
    fovRadius     = 120,
    showFovCircle = false,
    targetPart    = "Head",
    smoothness    = 0.15,
    wallCheck     = true,
    fullTarget    = false,
    aimMethod     = "Mouse", -- "Mouse" или "Camera"
    ignoreTeams   = true,
}

-- Бинды с ПОЛНЫМ ФИКСОМ для всех клавиш
local BINDINGS = {
    AimKey = Enum.KeyCode.Insert,
    TargetKey = Enum.UserInputType.MouseButton2,
}

-- Переменные состояния
local isTargetHeld = false
local fovCircle = nil
local lockedTarget = nil
local waitingForBind = nil
local statusText = "Aimbot: OFF"

-- Удаляем старый GUI если существует
if LocalPlayer:FindFirstChild("PlayerGui") then
    local oldGui = LocalPlayer.PlayerGui:FindFirstChild("AimbotGUI")
    if oldGui then
        oldGui:Destroy()
    end
end

-- Создаем новый MINI UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Статус лейбл (компактный)
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 300, 0, 40)
StatusLabel.Position = UDim2.new(0.5, -150, 0, 5)
StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
StatusLabel.BackgroundTransparency = 0.3
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 14
StatusLabel.Text = statusText
StatusLabel.TextStrokeTransparency = 0.7
StatusLabel.BorderSizePixel = 0
StatusLabel.Parent = ScreenGui

local UICorner1 = Instance.new("UICorner")
UICorner1.CornerRadius = UDim.new(0, 8)
UICorner1.Parent = StatusLabel

-- MINI UI Панель (скрываемая)
local MiniUI = Instance.new("Frame")
MiniUI.Size = UDim2.new(0, 220, 0, 320)
MiniUI.Position = UDim2.new(1, -230, 0.5, -160)
MiniUI.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MiniUI.BorderSizePixel = 0
MiniUI.Visible = false -- Скрыта по умолчанию
MiniUI.Parent = ScreenGui

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 12)
UICorner2.Parent = MiniUI

-- Кнопка показа/скрытия UI
local ToggleUI = Instance.new("TextButton")
ToggleUI.Size = UDim2.new(0, 40, 0, 40)
ToggleUI.Position = UDim2.new(1, -50, 0, 50)
ToggleUI.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
ToggleUI.Text = "⚙️"
ToggleUI.TextColor3 = Color3.new(1, 1, 1)
ToggleUI.Font = Enum.Font.GothamBold
ToggleUI.TextSize = 18
ToggleUI.BorderSizePixel = 0
ToggleUI.Parent = ScreenGui

local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(0, 8)
UICorner3.Parent = ToggleUI

ToggleUI.MouseButton1Click:Connect(function()
    MiniUI.Visible = not MiniUI.Visible
    ToggleUI.Text = MiniUI.Visible and "✕" or "⚙️"
end)

-- Функция создания тогглов
local function createToggle(yPos, text, varKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 28)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = SETTINGS[varKey] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 0, 0)
    btn.Text = text .. (SETTINGS[varKey] and " ✓" or " ✗")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.Parent = MiniUI
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        SETTINGS[varKey] = not SETTINGS[varKey]
        btn.BackgroundColor3 = SETTINGS[varKey] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 0, 0)
        btn.Text = text .. (SETTINGS[varKey] and " ✓" or " ✗")
        updateStatus()
    end)
end

-- Функция создания кнопок биндов
local function createBindButton(yPos, label, bindType)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 28)
    frame.Position = UDim2.new(0.05, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = MiniUI
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.6, 0, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(200, 200, 255)
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.35, 0, 1, 0)
    btn.Position = UDim2.new(0.65, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
    btn.Text = bindType == "Aim" and BINDINGS.AimKey.Name or "RMB"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        waitingForBind = bindType
        btn.Text = "..."
    end)
    
    return btn
end

-- Создаем элементы UI
createToggle(40, "Показ FOV", "showFovCircle")
createToggle(75, "Проверка стен", "wallCheck")
createToggle(110, "Full Target", "fullTarget")
createToggle(145, "Игнор команд", "ignoreTeams")

local AimBindBtn = createBindButton(180, "Aim Key:", "Aim")
local TargetBindBtn = createBindButton(215, "Target Key:", "Target")

-- Выбор части тела
local parts = {"Head", "UpperTorso", "HumanoidRootPart"}
local partDisplay = {Head = "Голова", UpperTorso = "Грудь", HumanoidRootPart = "Тело"}

for i, part in ipairs(parts) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.28, 0, 0, 25)
    btn.Position = UDim2.new(0.05 + (i-1)*0.32, 0, 0, 250)
    btn.BackgroundColor3 = (SETTINGS.targetPart == part) and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(50, 50, 70)
    btn.Text = partDisplay[part] or part
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.Parent = MiniUI
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        SETTINGS.targetPart = part
        for _, child in ipairs(MiniUI:GetChildren()) do
            if child:IsA("TextButton") and (child.Text == "Голова" or child.Text == "Грудь" or child.Text == "Тело") then
                child.BackgroundColor3 = (child.Text == (partDisplay[part] or part)) and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(50, 50, 70)
            end
        end
        updateStatus()
    end)
end

-- Функция обновления статуса
function updateStatus()
    statusText = string.format("Aimbot: %s | Часть: %s | Метод: %s", 
        aimbotEnabled and "ON" or "OFF", 
        partDisplay[SETTINGS.targetPart] or SETTINGS.targetPart,
        SETTINGS.aimMethod)
    StatusLabel.Text = statusText
end

-- ПОЛНЫЙ ФИКС обработки клавиш
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
                BINDINGS.AimKey = newBind
                AimBindBtn.Text = input.KeyCode and input.KeyCode.Name or "Mouse"
                print("Aim key установлен:", AimBindBtn.Text)
            elseif waitingForBind == "Target" then
                BINDINGS.TargetKey = newBind
                TargetBindBtn.Text = input.KeyCode and input.KeyCode.Name or "Mouse"
                print("Target key установлен:", TargetBindBtn.Text)
            end
            waitingForBind = nil
        end
        return
    end
    
    if gameProcessed then return end
    
    -- Проверка Aim Key (работает для ВСЕХ клавиш)
    local isAimKey = false
    if input.KeyCode ~= Enum.KeyCode.Unknown then
        if input.KeyCode == BINDINGS.AimKey then
            isAimKey = true
        end
    elseif input.UserInputType == BINDINGS.AimKey then
        isAimKey = true
    end
    
    if isAimKey then
        aimbotEnabled = not aimbotEnabled
        StatusLabel.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 80, 0) or Color3.fromRGB(20, 20, 30)
        updateStatus()
        print("Aimbot:", aimbotEnabled and "ВКЛЮЧЕН" or "ВЫКЛЮЧЕН")
    end
    
    -- Проверка Target Key
    local isTargetKey = false
    if input.KeyCode ~= Enum.KeyCode.Unknown then
        if input.KeyCode == BINDINGS.TargetKey then
            isTargetKey = true
        end
    elseif input.UserInputType == BINDINGS.TargetKey then
        isTargetKey = true
    end
    
    if isTargetKey then
        isTargetHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local isTargetKey = false
    if input.KeyCode ~= Enum.KeyCode.Unknown then
        if input.KeyCode == BINDINGS.TargetKey then
            isTargetKey = true
        end
    elseif input.UserInputType == BINDINGS.TargetKey then
        isTargetKey = true
    end
    
    if isTargetKey then
        isTargetHeld = false
    end
end)

-- FOV Circle
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

-- Вспомогательные функции
local function getTargetPart(player)
    if not player or not player.Character then return nil end
    local char = player.Character
    
    -- Ищем нужную часть
    local part = char:FindFirstChild(SETTINGS.targetPart)
    if part then return part end
    
    -- Альтернативы
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
                            local ray = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * maxDist, rayParams)
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
                        if worldDist < nearestDist and worldDist < maxDist then
                            if SETTINGS.wallCheck then
                                local rayParams = RaycastParams.new()
                                rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                local ray = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * maxDist, rayParams)
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
    
    -- Применяем сглаживание
    delta = delta * SETTINGS.smoothness
    mouseMoveFunc(delta.X, delta.Y)
end

local function aimWithCamera(targetPos)
    local direction = (targetPos - Camera.CFrame.Position).Unit
    local targetCF = CFrame.lookAt(Camera.CFrame.Position, targetPos)
    Camera.CFrame = Camera.CFrame:Lerp(targetCF, SETTINGS.smoothness)
end

-- Главный цикл
RunService.Heartbeat:Connect(function()
    updateFovCircle()
    
    local active = aimbotEnabled and (not isTargetHeld or isTargetHeld)
    if not active or not LocalPlayer.Character then 
        if lockedTarget and not SETTINGS.fullTarget then
            lockedTarget = nil
        end
        return 
    end
    
    local target = findNearestEnemy()
    if not target then 
        updateStatus()
        return 
    end
    
    local part = getTargetPart(target)
    if not part then return end
    
    if SETTINGS.aimMethod == "Mouse" then
        aimWithMouse(part.Position)
    else
        aimWithCamera(part.Position)
    end
end)

-- Инициализация
updateStatus()
print("✅ Aimbot загружен!")
print("⚙️ Настройки в MINI UI")
print("🎯 Aim Key:", BINDINGS.AimKey.Name)
print("🖱️ Метод:", SETTINGS.aimMethod)
print("📌 FIXED: Работает на ВСЕХ клавишах")
