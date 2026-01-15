-- modules/aimbot.lua
local Aimbot = {}

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Глобальная функция mousemoverel
local mousemoverel = mousemoverel or function(dx, dy)
    local currentCF = Camera.CFrame
    local dxRad = dx * 0.0005
    local dyRad = dy * 0.0005
    local newCF = currentCF * CFrame.Angles(-dyRad, -dxRad, 0)
    Camera.CFrame = newCF
end

-- Настройки
Aimbot.Settings = {
    Enabled = false,
    fovRadius = 150,
    showFovCircle = false,
    targetPart = "Head",
    smoothness = 0.12,
    wallCheck = true,
    fullTarget = false,
    aimMethod = "Auto",
    ignoreTeams = true,
    holdPkmMode = false,
    maxDist = 1000
}

-- Бинды
Aimbot.Bindings = {
    AimKey = Enum.KeyCode.Insert,
    TargetKey = Enum.UserInputType.MouseButton2
}

-- Внутренние переменные
local isTargetHeld = false
local fovCircle = nil
local lockedTarget = nil
local currentGameMode = "Lobby"

-- Экспортируемые функции для UI
Aimbot.updateSetting = function(key, value)
    if Aimbot.Settings[key] ~= nil then
        Aimbot.Settings[key] = value
        print("[Aimbot] Настройка обновлена:", key, "=", tostring(value))
        
        -- Обновляем FOV круг если нужно
        if key == "showFovCircle" then
            if value and not fovCircle then
                createFovCircle()
            elseif not value and fovCircle then
                fovCircle:Remove()
                fovCircle = nil
            end
        elseif key == "fovRadius" and fovCircle then
            fovCircle.Radius = value
        end
    end
end

Aimbot.getSetting = function(key)
    return Aimbot.Settings[key]
end

Aimbot.updateBinding = function(bindingType, value)
    if bindingType == "AimKey" then
        Aimbot.Bindings.AimKey = value
    elseif bindingType == "TargetKey" then
        Aimbot.Bindings.TargetKey = value
    end
    print("[Aimbot] Бинд обновлен:", bindingType, "=", tostring(value))
end

Aimbot.getBinding = function(bindingType)
    return Aimbot.Bindings[bindingType]
end

-- Вспомогательные функции
local function getGameMode()
    if workspace:FindFirstChild("Match") or workspace:FindFirstChild("Round") then
        return "Match"
    end
    
    local playerCount = #Players:GetPlayers()
    if playerCount <= 2 then
        return "Lobby"
    end
    
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then return "Match" end
    end
    
    return "Lobby"
end

local function createFovCircle()
    if not fovCircle then
        fovCircle = Drawing.new("Circle")
        fovCircle.Color = Color3.fromRGB(255, 255, 255)
        fovCircle.Thickness = 2
        fovCircle.NumSides = 60
        fovCircle.Filled = false
        fovCircle.Transparency = 0.6
        fovCircle.Radius = Aimbot.Settings.fovRadius
        fovCircle.Visible = true
    end
end

local function updateFovCircle()
    if Aimbot.Settings.showFovCircle then
        if not fovCircle then
            createFovCircle()
        end
        if fovCircle then
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            fovCircle.Radius = Aimbot.Settings.fovRadius
        end
    elseif fovCircle then
        fovCircle:Remove()
        fovCircle = nil
    end
end

local function getTargetPart(player)
    if not player or not player.Character then return nil end
    
    local char = player.Character
    local part = char:FindFirstChild(Aimbot.Settings.targetPart)
    if part then return part end
    
    local alternatives = {}
    if Aimbot.Settings.targetPart == "Head" then
        alternatives = {"Head", "HeadHB", "HeadHitbox", "HeadBox"}
    elseif Aimbot.Settings.targetPart == "UpperTorso" then
        alternatives = {"UpperTorso", "Torso", "Chest", "Spine"}
    elseif Aimbot.Settings.targetPart == "HumanoidRootPart" then
        alternatives = {"HumanoidRootPart", "RootPart", "Torso"}
    end
    
    for _, alt in ipairs(alternatives) do
        part = char:FindFirstChild(alt)
        if part then return part end
    end
    
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("BasePart") and not child.Name:find("Handle") then
            return child
        end
    end
    
    return nil
end

local function isValidTarget(player)
    if player == LocalPlayer then return false end
    if not player.Character then return false end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    if Aimbot.Settings.ignoreTeams then
        if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then 
            return false 
        end
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
    
    return screenDist <= Aimbot.Settings.fovRadius and onScreen
end

local function findNearestEnemy()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    
    local myPos = myChar:FindFirstChild("HumanoidRootPart") or myChar.PrimaryPart
    if not myPos then return nil end
    myPos = myPos.Position
    
    if Aimbot.Settings.fullTarget and lockedTarget then
        if isValidTarget(lockedTarget) and isInFov(lockedTarget) then
            if Aimbot.Settings.wallCheck then
                local part = getTargetPart(lockedTarget)
                if part then
                    local rayParams = RaycastParams.new()
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                    rayParams.IgnoreWater = true
                    
                    local rayResult = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * Aimbot.Settings.maxDist, rayParams)
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
    
    local nearest = nil
    local nearestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if isValidTarget(player) then
            local char = player.Character
            local part = getTargetPart(player)
            if part then
                local partScreen, onScreen = Camera:WorldToViewportPoint(part.Position)
                local screenDist = (Vector2.new(partScreen.X, partScreen.Y) - screenCenter).Magnitude
                
                if screenDist <= Aimbot.Settings.fovRadius and onScreen then
                    local worldDist = (myPos - part.Position).Magnitude
                    if worldDist < nearestDist and worldDist < Aimbot.Settings.maxDist then
                        local canSee = true
                        if Aimbot.Settings.wallCheck then
                            local rayParams = RaycastParams.new()
                            rayParams.FilterType = Enum.RaycastFilterType.Exclude
                            rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                            rayParams.IgnoreWater = true
                            
                            local rayResult = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * Aimbot.Settings.maxDist, rayParams)
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
    
    if Aimbot.Settings.fullTarget and nearest then
        lockedTarget = nearest
    end
    
    return nearest or lockedTarget
end

local function aimWithMouse(targetPos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
    if not onScreen then return end
    
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
    local delta = targetScreenPos - screenCenter
    delta = delta * Aimbot.Settings.smoothness
    mousemoverel(delta.X, delta.Y)
end

local function aimWithCamera(targetPos)
    local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Aimbot.Settings.smoothness)
end

local function getActiveAimMethod()
    if Aimbot.Settings.aimMethod == "Auto" then
        if currentGameMode == "Match" then
            return "Mouse"
        else
            return "Camera"
        end
    end
    return Aimbot.Settings.aimMethod
end

-- Обработка ввода
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Aim toggle
    local isAimKey = false
    if input.KeyCode ~= Enum.KeyCode.Unknown then
        if input.KeyCode == Aimbot.Bindings.AimKey then
            isAimKey = true
        end
    elseif input.UserInputType == Aimbot.Bindings.AimKey then
        isAimKey = true
    end
    
    if isAimKey then
        Aimbot.Settings.Enabled = not Aimbot.Settings.Enabled
        if not Aimbot.Settings.Enabled then
            lockedTarget = nil
        end
        print("[Aimbot] Включен:", Aimbot.Settings.Enabled)
    end
    
    -- Target hold
    local isTargetKey = false
    if input.KeyCode ~= Enum.KeyCode.Unknown then
        if input.KeyCode == Aimbot.Bindings.TargetKey then
            isTargetKey = true
        end
    elseif input.UserInputType == Aimbot.Bindings.TargetKey then
        isTargetKey = true
    end
    
    if isTargetKey then
        isTargetHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local isTargetKey = false
    if input.KeyCode ~= Enum.KeyCode.Unknown then
        if input.KeyCode == Aimbot.Bindings.TargetKey then
            isTargetKey = true
        end
    elseif input.UserInputType == Aimbot.Bindings.TargetKey then
        isTargetKey = true
    end
    
    if isTargetKey then
        isTargetHeld = false
    end
end)

-- Основной цикл
RunService.Heartbeat:Connect(function()
    updateFovCircle()
    currentGameMode = getGameMode()
    
    local active = Aimbot.Settings.Enabled and (not Aimbot.Settings.holdPkmMode or isTargetHeld)
    if not active or not LocalPlayer.Character then 
        lockedTarget = nil
        return 
    end
    
    local targetPlayer = findNearestEnemy()
    if not targetPlayer then 
        lockedTarget = nil
        return 
    end
    
    local targetPart = getTargetPart(targetPlayer)
    if not targetPart then return end
    
    local targetPos = targetPart.Position
    local aimMethod = getActiveAimMethod()
    
    if aimMethod == "Mouse" then
        aimWithMouse(targetPos)
    else
        aimWithCamera(targetPos)
    end
end)

-- Инициализация
print("[Aimbot] Модуль загружен")

return Aimbot
