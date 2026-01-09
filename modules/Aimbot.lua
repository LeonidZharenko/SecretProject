local Aimbot = {}

function Aimbot.Init(config, tab)
    Aimbot.Config = config.Aimbot
    Aimbot.Enabled = false
    Aimbot.lockedTarget = nil
    Aimbot.isTargetHeld = false
    Aimbot.waitingForBind = nil

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local maxDist = 1000
    local fovCircle = nil

    -- Status Label (верх по центру)
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
    StatusLabel.Text = "Aimbot: OFF | Часть: Head | FullT: OFF"
    StatusLabel.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Fluent UI в вкладке tab
    tab:AddToggle({
        Title = "Aimbot Enabled",
        Default = false,
        Callback = function(value)
            Aimbot.Enabled = value
            StatusLabel.Text = "Aimbot: " .. (value and "ON" or "OFF") .. " | Часть: " .. Aimbot.Config.targetPart .. " | FullT: " .. (Aimbot.Config.fullTarget and "ON" or "OFF")
            StatusLabel.TextColor3 = value and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
            StatusLabel.BackgroundColor3 = value and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(0, 0, 0)
            if not value then
                Aimbot.lockedTarget = nil
            end
        end
    })

    tab:AddSlider({
        Title = "FOV Radius",
        Min = 50,
        Max = 600,
        Default = Aimbot.Config.fovRadius,
        Callback = function(value)
            Aimbot.Config.fovRadius = value
        end
    })

    tab:AddSlider({
        Title = "Smoothness",
        Min = 0.05,
        Max = 1,
        Default = Aimbot.Config.smoothness,
        Rounding = 2,
        Callback = function(value)
            Aimbot.Config.smoothness = value
        end
    })

    tab:AddDropdown({
        Title = "Target Part",
        Values = {"Head", "Torso", "Legs"},
        Default = Aimbot.Config.targetPart,
        Callback = function(value)
            Aimbot.Config.targetPart = value
            StatusLabel.Text = "Aimbot: " .. (Aimbot.Enabled and "ON" or "OFF") .. " | Часть: " .. value .. " | FullT: " .. (Aimbot.Config.fullTarget and "ON" or "OFF")
        end
    })

    tab:AddToggle({
        Title = "Show FOV Circle",
        Default = false,
        Callback = function(value)
            Aimbot.Config.showFovCircle = value
        end
    })

    tab:AddToggle({
        Title = "Hold Target (RMB)",
        Default = false,
        Callback = function(value)
            Aimbot.Config.holdPkmMode = value
        end
    })

    tab:AddToggle({
        Title = "Wall Check",
        Default = true,
        Callback = function(value)
            Aimbot.Config.wallCheck = value
        end
    })

    tab:AddToggle({
        Title = "Full Target (Lock)",
        Default = false,
        Callback = function(value)
            Aimbot.Config.fullTarget = value
            StatusLabel.Text = "Aimbot: " .. (Aimbot.Enabled and "ON" or "OFF") .. " | Часть: " .. Aimbot.Config.targetPart .. " | FullT: " .. (value and "ON" or "OFF")
        end
    })

    -- FOV Circle
    local function updateFovCircle()
        if Aimbot.Config.showFovCircle then
            if not fovCircle then
                fovCircle = Drawing.new("Circle")
                fovCircle.Color = Color3.fromRGB(255, 255, 255)
                fovCircle.Thickness = 2
                fovCircle.NumSides = 60
                fovCircle.Filled = false
                fovCircle.Transparency = 0.6
                fovCircle.Radius = Aimbot.Config.fovRadius
                fovCircle.Visible = true
            end
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            fovCircle.Radius = Aimbot.Config.fovRadius
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
        local partName = Aimbot.Config.targetPart == "Head" and "Head"
                     or Aimbot.Config.targetPart == "Torso" and ("UpperTorso" or "Torso")
                     or "HumanoidRootPart"
        
        local part = char:FindFirstChild(partName) or char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart")
        if not part then return false end
        
        local partScreen, onScreen = Camera:WorldToViewportPoint(part.Position)
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local screenDist = (Vector2.new(partScreen.X, partScreen.Y) - screenCenter).Magnitude
        
        return screenDist <= Aimbot.Config.fovRadius and onScreen
    end

    -- findNearestEnemy + Full Target
    local function findNearestEnemy()
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local myPos = LocalPlayer.Character and (LocalPlayer.Character.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
        if not myPos then return nil end
        myPos = myPos.Position
        
        if Aimbot.Config.fullTarget and Aimbot.lockedTarget then
            if isValidTarget(Aimbot.lockedTarget) and isInFov(Aimbot.lockedTarget) then
                if Aimbot.Config.wallCheck then
                    local part = Aimbot.lockedTarget.Character:FindFirstChild(Aimbot.Config.targetPart == "Head" and "Head" 
                                                                   or Aimbot.Config.targetPart == "Torso" and ("UpperTorso" or "Torso") 
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
                local partName = Aimbot.Config.targetPart == "Head" and "Head"
                             or Aimbot.Config.targetPart == "Torso" and ("UpperTorso" or "Torso")
                             or "HumanoidRootPart"
                
                local part = char:FindFirstChild(partName) or char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart")
                if part then
                    local partScreen, onScreen = Camera:WorldToViewportPoint(part.Position)
                    local screenDist = (Vector2.new(partScreen.X, partScreen.Y) - screenCenter).Magnitude
                    
                    if screenDist <= Aimbot.Config.fovRadius and onScreen then
                        local worldDist = (myPos - part.Position).Magnitude
                        if worldDist < nearestDist and worldDist < maxDist then
                            local canSee = true
                            if Aimbot.Config.wallCheck then
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
        
        if Aimbot.Config.fullTarget and nearest then
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
        
        local active = Aimbot.Enabled and (not Aimbot.Config.holdPkmMode or Aimbot.isTargetHeld)
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
        if Aimbot.Config.targetPart == "Head" then
            targetPos = char:FindFirstChild("Head") and char.Head.Position or char.PrimaryPart.Position
        elseif Aimbot.Config.targetPart == "Torso" then
            targetPos = (char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char.PrimaryPart).Position
        else
            targetPos = (char:FindFirstChild("LeftFoot") or char:FindFirstChild("RightFoot") or char:FindFirstChild("LowerTorso") or char.PrimaryPart).Position
        end
        
        local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Aimbot.Config.smoothness)
    end)
end

return Aimbot
