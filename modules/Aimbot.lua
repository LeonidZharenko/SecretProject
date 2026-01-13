local Aimbot = {}

Aimbot.Enabled = false  -- будет управляться из UI
Aimbot.lockedTarget = nil
Aimbot.isTargetHeld = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local maxDist = 1000
local fovCircle = nil

local SETTINGS = {
    fovRadius     = 150,
    showFovCircle = false,
    targetPart    = "Head",
    smoothness    = 0.12,
    wallCheck     = true,
    fullTarget    = false,
    holdPkmMode   = false,  -- Hold Target (RMB)
}

-- FOV Circle
local function updateFovCircle()
    if SETTINGS.showFovCircle then
        if not fovCircle then
            fovCircle = Drawing.new("Circle")
            fovCircle.Color = Color3.fromRGB(255, 255, 255)
            fovCircle.Thickness = 2
            fovCircle.NumSides = 60
            fovCircle.Filled = false
            fovCircle.Transparency = 0.6
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

-- isValidTarget
local function isValidTarget(player)
    if player == LocalPlayer then return false end
    if not player.Character then return false end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then return false end
    
    return true
end

-- isInFov
local function isInFov(player)
    if not player or not player.Character then return false end
    
    local char = player.Character
    local partName = SETTINGS.targetPart == "Head" and "Head"
                 or SETTINGS.targetPart == "Torso" and ("UpperTorso" or "Torso")
                 or "HumanoidRootPart"
    
    local part = char:FindFirstChild(partName) or char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart")
    if not part then return false end
    
    local partScreen, onScreen = Camera:WorldToViewportPoint(part.Position)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local screenDist = (Vector2.new(partScreen.X, partScreen.Y) - screenCenter).Magnitude
    
    return screenDist <= SETTINGS.fovRadius and onScreen
end

-- findNearestEnemy + Full Target
local function findNearestEnemy()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local myPos = LocalPlayer.Character and (LocalPlayer.Character.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
    if not myPos then return nil end
    myPos = myPos.Position
    
    if SETTINGS.fullTarget and Aimbot.lockedTarget then
        if isValidTarget(Aimbot.lockedTarget) and isInFov(Aimbot.lockedTarget) then
            if SETTINGS.wallCheck then
                local part = Aimbot.lockedTarget.Character:FindFirstChild(SETTINGS.targetPart == "Head" and "Head" 
                                                               or SETTINGS.targetPart == "Torso" and ("UpperTorso" or "Torso") 
                                                               or "HumanoidRootPart")
                if part then
                    local rayParams = RaycastParams.new()
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                    rayParams.IgnoreWater = true
                    
                    local rayResult = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * maxDist, rayParams)
                    if rayResult and rayResult.Instance:IsDescendantOf(Aimbot.lockedTarget.Character) then
                        return Aimbot.lockedTarget
                    end
                end
            else
                return Aimbot.lockedTarget
            end
        end
        Aimbot.lockedTarget = nil
    end
    
    local nearest = nil
    local nearestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if isValidTarget(player) then
            local char = player.Character
            local partName = SETTINGS.targetPart == "Head" and "Head"
                         or SETTINGS.targetPart == "Torso" and ("UpperTorso" or "Torso")
                         or "HumanoidRootPart"
            
            local part = char:FindFirstChild(partName) or char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart")
            if part then
                local partScreen, onScreen = Camera:WorldToViewportPoint(part.Position)
                local screenDist = (Vector2.new(partScreen.X, partScreen.Y) - screenCenter).Magnitude
                
                if screenDist <= SETTINGS.fovRadius and onScreen then
                    local worldDist = (myPos - part.Position).Magnitude
                    if worldDist < nearestDist and worldDist < maxDist then
                        local canSee = true
                        if SETTINGS.wallCheck then
                            local rayParams = RaycastParams.new()
                            rayParams.FilterType = Enum.RaycastFilterType.Exclude
                            rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                            rayParams.IgnoreWater = true
                            
                            local rayResult = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * maxDist, rayParams)
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
        Aimbot.lockedTarget = nearest
    end
    
    return nearest or Aimbot.lockedTarget
end

-- Hold Target (RMB)
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Aimbot.isTargetHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Aimbot.isTargetHeld = false
    end
end)

-- Aimbot цикл
RunService.Heartbeat:Connect(function()
    updateFovCircle()
    
    local active = Aimbot.Enabled and (not SETTINGS.holdPkmMode or Aimbot.isTargetHeld)
    if not active or not LocalPlayer.Character then 
        Aimbot.lockedTarget = nil
        return 
    end
    
    local targetPlayer = findNearestEnemy()
    if not targetPlayer then 
        Aimbot.lockedTarget = nil
        return 
    end
    
    local char = targetPlayer.Character
    local targetPos
    if SETTINGS.targetPart == "Head" then
        targetPos = char:FindFirstChild("Head") and char.Head.Position or char.PrimaryPart.Position
    elseif SETTINGS.targetPart == "Torso" then
        targetPos = (char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char.PrimaryPart).Position
    else
        targetPos = (char:FindFirstChild("LeftFoot") or char:FindFirstChild("RightFoot") or char:FindFirstChild("LowerTorso") or char.PrimaryPart).Position
    end
    
    local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, SETTINGS.smoothness)
end)

-- Функция для обновления настроек из UI
function Aimbot.UpdateSettings(newSettings)
    SETTINGS = newSettings
end

print("Aimbot загружен (без старого GUI)")
return Aimbot
