local ESP = {}

ESP.Enabled = true  -- будет управляться из Fluent UI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local espElements = {}

local SETTINGS = {
    BoxEnabled        = true,
    TracerEnabled     = true,
    NameEnabled       = true,
    ShowDistance      = true,
    TeamCheck         = true,
    MaxRenderDistance = 5000,
    BoxColor          = Color3.fromRGB(255, 255, 255),
    TracerColor       = Color3.fromRGB(255, 255, 255),
    NameColor         = Color3.fromRGB(255, 255, 255),
    TracerFrom        = "Bottom",
    MaxDepth          = math.huge,
    ReinitInterval    = 1.5,
}

-- Основная логика ESP (без изменений)
local function removeElements(player)
    local elements = espElements[player]
    if elements then
        for _, obj in pairs(elements) do
            pcall(function()
                obj.Visible = false
                obj:Remove()
            end)
        end
        espElements[player] = nil
    end
end

local function isValidTarget(player)
    if player == LocalPlayer then return false end
    if not player.Character then return false end

    local root = player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart or player.Character:FindFirstChildWhichIsA("BasePart")
    local head = player.Character:FindFirstChild("Head") or player.Character:FindFirstChildWhichIsA("BasePart")
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

    if not (root and head and humanoid) or humanoid.Health <= 0 then return false end

    if SETTINGS.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        return false
    end

    return true
end

local function getScreenPosition(worldPos)
    local vec, onScreen = Camera:WorldToViewportPoint(worldPos)
    return Vector2.new(vec.X, vec.Y), onScreen, vec.Z
end

local function createDrawing(typeName)
    if typeName == "Box" then
        local sq = Drawing.new("Square")
        sq.Thickness = 2
        sq.Color = SETTINGS.BoxColor
        sq.Filled = false
        sq.Transparency = 1
        sq.Visible = false
        return sq
    elseif typeName == "Tracer" then
        local ln = Drawing.new("Line")
        ln.Thickness = 2
        ln.Color = SETTINGS.TracerColor
        ln.Transparency = 1
        ln.Visible = false
        return ln
    elseif typeName == "Name" then
        local txt = Drawing.new("Text")
        txt.Size = 14
        txt.Color = SETTINGS.NameColor
        txt.Outline = true
        txt.Center = true
        txt.Font = 2
        txt.Visible = false
        return txt
    end
end

local function updateESP()
    if not ESP.Enabled then
        for _, elements in pairs(espElements) do
            for _, obj in pairs(elements) do if obj then obj.Visible = false end end
        end
        return
    end

    local now = tick()

    if now % SETTINGS.ReinitInterval < 0.2 then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and isValidTarget(player) then
                removeElements(player)
                local elements = {}
                if SETTINGS.BoxEnabled    then elements.box    = createDrawing("Box") end
                if SETTINGS.TracerEnabled then elements.tracer = createDrawing("Tracer") end
                if SETTINGS.NameEnabled   then elements.name   = createDrawing("Name") end
                espElements[player] = elements
            else
                removeElements(player)
            end
        end
    end

    for player, elements in pairs(espElements) do
        if not player.Parent or not player.Character or not isValidTarget(player) then
            removeElements(player)
            continue
        end

        local char = player.Character
        local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart")
        local head = char:FindFirstChild("Head") or char:FindFirstChildWhichIsA("BasePart")

        if not (root and head) then
            removeElements(player)
            continue
        end

        local rootPos = root.Position
        local headPos = head.Position + Vector3.new(0, 0.6, 0)
        local feetPos = root.Position - Vector3.new(0, 3.5, 0)

        local root2d, rootVisible, rootDepth = getScreenPosition(rootPos)
        local head2d = getScreenPosition(headPos)
        local feet2d = getScreenPosition(feetPos)

        if not rootVisible or rootDepth > SETTINGS.MaxDepth or rootDepth < 0.1 then
            for _, obj in pairs(elements) do if obj then obj.Visible = false end end
            continue
        end

        local dist = (Camera.CFrame.Position - rootPos).Magnitude
        if dist > SETTINGS.MaxRenderDistance then
            for _, obj in pairs(elements) do if obj then obj.Visible = false end end
            continue
        end

        local scale = math.clamp(2500 / dist, 12, 450)
        local boxW = scale * 0.6
        local boxH = scale

        if SETTINGS.BoxEnabled and elements.box then
            elements.box.Size = Vector2.new(boxW, boxH)
            elements.box.Position = Vector2.new(root2d.X - boxW/2, head2d.Y - boxH*0.05)
            elements.box.Visible = true
        end

        if SETTINGS.TracerEnabled and elements.tracer then
            local fromY = Camera.ViewportSize.Y
            if SETTINGS.TracerFrom == "Top" then fromY = 0 elseif SETTINGS.TracerFrom == "Center" then fromY = Camera.ViewportSize.Y / 2 end
            local fromPos = Vector2.new(Camera.ViewportSize.X / 2, fromY)
            elements.tracer.From = fromPos
            elements.tracer.To = Vector2.new(feet2d.X, feet2d.Y)
            elements.tracer.Visible = true
        end

        if SETTINGS.NameEnabled and elements.name then
            local nameText = player.Name
            if SETTINGS.ShowDistance then nameText = nameText .. " [" .. math.floor(dist) .. "]" end
            elements.name.Text = nameText
            elements.name.Position = Vector2.new(root2d.X, head2d.Y - 25)
            elements.name.Visible = true
        end
    end
end

-- Инициализация ESP
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(function()
        task.wait(0.8)
        if player.Character and isValidTarget(player) then
            removeElements(player)
            local elements = {}
            if SETTINGS.BoxEnabled    then elements.box    = createDrawing("Box") end
            if SETTINGS.TracerEnabled then elements.tracer = createDrawing("Tracer") end
            if SETTINGS.NameEnabled   then elements.name   = createDrawing("Name") end
            espElements[player] = elements
        end
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.8)
        removeElements(player)
        if isValidTarget(player) then
            local elements = {}
            if SETTINGS.BoxEnabled    then elements.box    = createDrawing("Box") end
            if SETTINGS.TracerEnabled then elements.tracer = createDrawing("Tracer") end
            if SETTINGS.NameEnabled   then elements.name   = createDrawing("Name") end
            espElements[player] = elements
        end
    end)
end)

Players.PlayerRemoving:Connect(removeElements)

RunService.Heartbeat:Connect(updateESP)

print("ESP загружен (без старого GUI)")
return ESP
