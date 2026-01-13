-- Aimbot на голову/туловище/ноги + MINI UI + Full Target + ПОЛНЫЙ ФИКС Aim toggle (работает на ВСЕХ клавишах)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local aimbotEnabled = false
local maxDist = 1000

local SETTINGS = {
    fovRadius     = 150,
    showFovCircle = false,
    targetPart    = "Head",
    smoothness    = 0.12,
    wallCheck     = true,
    fullTarget    = false,
}

local BINDINGS = {
    AimKey = Enum.KeyCode.Insert,
    TargetKey = Enum.UserInputType.MouseButton2,
}

local isTargetHeld = false
local fovCircle = nil
local lockedTarget = nil
local waitingForBind = nil  -- "Aim" or "Target"

-- GUI индикатор
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 320, 0, 50)
StatusLabel.Position = UDim2.new(0.5, -160, 0, 10)
StatusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StatusLabel.BackgroundTransparency = 0.4
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextStrokeTransparency = 0.6
StatusLabel.TextStrokeColor3 = Color3.new(0,0,0)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 18
StatusLabel.Text = "Aimbot: OFF | Часть: Head | FullT: OFF\n" .. BINDINGS.AimKey.Name
StatusLabel.Parent = ScreenGui

-- MINI UI
local MiniUI = Instance.new("Frame")
MiniUI.Size = UDim2.new(0, 220, 0, 420)
MiniUI.Position = UDim2.new(1, -230, 1, -440)
MiniUI.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
MiniUI.BorderSizePixel = 0
MiniUI.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MiniUI

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Aimbot Settings"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MiniUI

-- Toggle функция
local function createToggle(yPos, text, varKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 28)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = SETTINGS[varKey] and Color3.fromRGB(0,180,0) or Color3.fromRGB(80,0,0)
    btn.Text = text .. (SETTINGS[varKey] and " ✅" or " ❌")
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = MiniUI
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        SETTINGS[varKey] = not SETTINGS[varKey]
        btn.BackgroundColor3 = SETTINGS[varKey] and Color3.fromRGB(0,180,0) or Color3.fromRGB(80,0,0)
        btn.Text = text .. (SETTINGS[varKey] and " ✅" or " ❌")
    end)
end

createToggle(40, "Показывать FOV круг", "showFovCircle")
createToggle(75, "Hold Target", "holdPkmMode")
createToggle(110, "Проверка стен", "wallCheck")
createToggle(145, "Full Target (лок)", "fullTarget")

-- Bind функция
local function createBind(yPos, labelText, bindType)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0, 28)
    label.Position = UDim2.new(0.05, 0, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(200,200,255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = MiniUI
    
    local bindBtn = Instance.new("TextButton")
    bindBtn.Name = bindType .. "BindBtn"
    bindBtn.Size = UDim2.new(0.35, 0, 0, 28)
    bindBtn.Position = UDim2.new(0.6, 0, 0, yPos)
    bindBtn.BackgroundColor3 = Color3.fromRGB(40,40,70)
    bindBtn.Text = bindType == "Aim" and BINDINGS.AimKey.Name or (BINDINGS.TargetKey == Enum.UserInputType.MouseButton2 and "RMB" or BINDINGS.TargetKey.Name or "?")
    bindBtn.TextColor3 = Color3.new(1,1,1)
    bindBtn.Font = Enum.Font.GothamSemibold
    bindBtn.TextSize = 14
    bindBtn.BorderSizePixel = 0
    bindBtn.Parent = MiniUI
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = bindBtn
    
    bindBtn.MouseButton1Click:Connect(function()
        waitingForBind = bindType
        bindBtn.Text = "Нажми..."
    end)
    
    return bindBtn
end

local AimBindBtn = createBind(180, "Aim (toggle):", "Aim")
local TargetBindBtn = createBind(215, "Target (hold):", "Target")

-- Выбор части тела
local parts = {"Head", "Torso", "Legs"}
local partButtons = {}

for i, part in ipairs(parts) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.28, 0, 0, 28)
    btn.Position = UDim2.new(0.05 + (i-1)*0.32, 0, 0, 250)
    btn.BackgroundColor3 = (SETTINGS.targetPart == part) and Color3.fromRGB(0,140,255) or Color3.fromRGB(50,50,70)
    btn.Text = part
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = MiniUI
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        SETTINGS.targetPart = part
        for _, b in ipairs(partButtons) do
            b.BackgroundColor3 = (b.Text == part) and Color3.fromRGB(0,140,255) or Color3.fromRGB(50,50,70)
        end
        StatusLabel.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF") .. " | Часть: " .. part .. " | FullT: " .. (SETTINGS.fullTarget and "ON" or "OFF")
    end)
    
    table.insert(partButtons, btn)
end

-- FOV TextBox
local FovLabel = Instance.new("TextLabel")
FovLabel.Size = UDim2.new(0.9, 0, 0, 20)
FovLabel.Position = UDim2.new(0.05, 0, 0, 285)
FovLabel.BackgroundTransparency = 1
FovLabel.Text = "FOV Радиус:"
FovLabel.TextColor3 = Color3.fromRGB(180,180,255)
FovLabel.Font = Enum.Font.Gotham
FovLabel.TextSize = 13
FovLabel.Parent = MiniUI

local FovBox = Instance.new("TextBox")
FovBox.Size = UDim2.new(0.9, 0, 0, 28)
FovBox.Position = UDim2.new(0.05, 0, 0, 305)
FovBox.BackgroundColor3 = Color3.fromRGB(35,35,50)
FovBox.Text = tostring(SETTINGS.fovRadius)
FovBox.TextColor3 = Color3.new(1,1,1)
FovBox.Font = Enum.Font.GothamSemibold
FovBox.TextSize = 14
FovBox.Parent = MiniUI

local FovCorner = Instance.new("UICorner")
FovCorner.CornerRadius = UDim.new(0, 8)
FovCorner.Parent = FovBox

FovBox.FocusLost:Connect(function()
    local num = tonumber(FovBox.Text)
    if num and num >= 50 and num <= 600 then
        SETTINGS.fovRadius = num
    else
        FovBox.Text = tostring(SETTINGS.fovRadius)
    end
end)

-- Smoothness TextBox
local SmoothLabel = Instance.new("TextLabel")
SmoothLabel.Size = UDim2.new(0.9, 0, 0, 20)
SmoothLabel.Position = UDim2.new(0.05, 0, 0, 340)
SmoothLabel.BackgroundTransparency = 1
SmoothLabel.Text = "Smoothness (0.05-1):"
SmoothLabel.TextColor3 = Color3.fromRGB(180,180,255)
SmoothLabel.Font = Enum.Font.Gotham
SmoothLabel.TextSize = 13
SmoothLabel.Parent = MiniUI

local SmoothBox = Instance.new("TextBox")
SmoothBox.Size = UDim2.new(0.9, 0, 0, 28)
SmoothBox.Position = UDim2.new(0.05, 0, 0, 360)
SmoothBox.BackgroundColor3 = Color3.fromRGB(35,35,50)
SmoothBox.Text = tostring(SETTINGS.smoothness)
SmoothBox.TextColor3 = Color3.new(1,1,1)
SmoothBox.Font = Enum.Font.GothamSemibold
SmoothBox.TextSize = 14
SmoothBox.Parent = MiniUI

local SmoothCorner = Instance.new("UICorner")
SmoothCorner.CornerRadius = UDim.new(0, 8)
SmoothCorner.Parent = SmoothBox

SmoothBox.FocusLost:Connect(function()
    local num = tonumber(SmoothBox.Text)
    if num and num >= 0.05 and num <= 1 then
        SETTINGS.smoothness = num
    else
        SmoothBox.Text = tostring(SETTINGS.smoothness)
    end
end)

-- Перебинд клавиш + ФИКС Aim toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if waitingForBind then
        local newBind, bindText
        if input.UserInputType == Enum.UserInputType.Keyboard then
            newBind = input.KeyCode
            bindText = newBind.Name
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            newBind = Enum.UserInputType.MouseButton2
            bindText = "RMB"
        end
        
        if newBind then
            if waitingForBind == "Aim" then
                BINDINGS.AimKey = newBind
                AimBindBtn.Text = bindText
                print("Aim toggle теперь на:", bindText)
            elseif waitingForBind == "Target" then
                BINDINGS.TargetKey = newBind
                TargetBindBtn.Text = bindText
                print("Target hold теперь на:", bindText)
            end
            waitingForBind = nil
        end
        return
    end
    
    -- Aim toggle — ПОЛНЫЙ ФИКС: проверка по KeyCode и Name
    local isAimKey = false
    if input.KeyCode ~= Enum.KeyCode.Unknown then
        if input.KeyCode == BINDINGS.AimKey or input.KeyCode.Name == BINDINGS.AimKey.Name then
            isAimKey = true
        end
    elseif input.UserInputType == BINDINGS.AimKey then
        isAimKey = true
    end
    
    if isAimKey then
        aimbotEnabled = not aimbotEnabled
        StatusLabel.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF") .. " | Часть: " .. SETTINGS.targetPart .. " | FullT: " .. (SETTINGS.fullTarget and "ON" or "OFF")
        StatusLabel.TextColor3 = aimbotEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
        StatusLabel.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(0, 0, 0)
        print("Aimbot toggle:", aimbotEnabled and "ВКЛ" or "ВЫКЛ", "на", BINDINGS.AimKey.Name or "RMB")
        
        if not aimbotEnabled then
            lockedTarget = nil
        end
    end
    
    -- Target hold
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

-- Reset Bind
local ResetAim = Instance.new("TextButton")
ResetAim.Size = UDim2.new(0.2, 0, 0, 28)
ResetAim.Position = UDim2.new(0.95, 0, 0, 180)
ResetAim.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
ResetAim.Text = "Reset"
ResetAim.TextColor3 = Color3.new(1,1,1)
ResetAim.Font = Enum.Font.Gotham
ResetAim.TextSize = 12
ResetAim.Parent = MiniUI

ResetAim.MouseButton1Click:Connect(function()
    BINDINGS.AimKey = Enum.KeyCode.Insert
    AimBindBtn.Text = "Ins"
end)

local ResetTarget = Instance.new("TextButton")
ResetTarget.Size = UDim2.new(0.2, 0, 0, 28)
ResetTarget.Position = UDim2.new(0.95, 0, 0, 215)
ResetTarget.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
ResetTarget.Text = "Reset"
ResetTarget.TextColor3 = Color3.new(1,1,1)
ResetTarget.Font = Enum.Font.Gotham
ResetTarget.TextSize = 12
ResetTarget.Parent = MiniUI

ResetTarget.MouseButton1Click:Connect(function()
    BINDINGS.TargetKey = Enum.UserInputType.MouseButton2
    TargetBindBtn.Text = "RMB"
end)

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

-- Проверка, находится ли игрок в FOV
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
    
    -- Full Target: если цель всё ещё валидна и в FOV — держим её
    if SETTINGS.fullTarget and lockedTarget then
        if isValidTarget(lockedTarget) and isInFov(lockedTarget) then
            if SETTINGS.wallCheck then
                local part = lockedTarget.Character:FindFirstChild(SETTINGS.targetPart == "Head" and "Head" 
                                                               or SETTINGS.targetPart == "Torso" and ("UpperTorso" or "Torso") 
                                                               or "HumanoidRootPart")
                if part then
                    local rayParams = RaycastParams.new()
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                    rayParams.IgnoreWater = true
                    
                    local rayResult = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * maxDist, rayParams)
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
        lockedTarget = nearest
    end
    
    return nearest or lockedTarget
end

-- Aimbot цикл
RunService.Heartbeat:Connect(function()
    updateFovCircle()
    
    local active = aimbotEnabled and (not SETTINGS.holdPkmMode or isTargetHeld)
    if not active or not LocalPlayer.Character then 
        lockedTarget = nil
        return 
    end
    
    local targetPlayer = findNearestEnemy()
    if not targetPlayer then 
        lockedTarget = nil
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

print("✅ Aimbot с ПОЛНЫМ ФИКСОМ Aim toggle готов!")
print("Теперь Aim работает на ЛЮБОЙ клавише (Insert, F, H, Space, RightShift, CapsLock и т.д.)")
print("Проверь в консоли (F9) — при нажатии клавиши будет print")
