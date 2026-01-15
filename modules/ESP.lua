-- modules/esp.lua
local ESP = {}

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ESP элементы
local espElements = {}
local weaponElements = {}
local weaponCache = {}
local lastWeaponScan = 0
local weaponScanInterval = 2
local cachedWeapons = {}
local lastCacheUpdate = 0

-- Настройки ESP (все копируем из оригинального SETTINGS)
ESP.Settings = {
    ESPEnabled        = true,
    BoxEnabled        = true,
    TracerEnabled     = true,
    NameEnabled       = true,
    ShowDistance      = true,
    TeamCheck         = true,
    MM2RoleESP        = false,
    WeaponESP         = false,
    MaxRenderDistance = 5000,
    BoxColor          = Color3.fromRGB(255, 255, 255),
    TracerColor       = Color3.fromRGB(255, 255, 255),
    NameColor         = Color3.fromRGB(255, 255, 255),
    TracerFrom        = "Bottom",
    DebugPrint        = false,
    MaxDepth          = math.huge,
    ReinitInterval    = 1.5,
}

-- Экспортируем функции для UI
ESP.updateSetting = function(key, value)
    if ESP.Settings[key] ~= nil then
        ESP.Settings[key] = value
        print("[ESP] Настройка обновлена:", key, "=", tostring(value))
        
        -- Дополнительные действия при изменении определенных настроек
        if key == "WeaponESP" then
            -- Очищаем weapon ESP если выключили
            if not value then
                for _, elements in pairs(weaponElements) do
                    if elements.box then elements.box.Visible = false end
                    if elements.text then elements.text.Visible = false end
                end
            end
        elseif key == "ESPEnabled" then
            -- Очищаем все ESP если выключили
            if not value then
                for _, elements in pairs(espElements) do
                    for _, obj in pairs(elements) do
                        if obj then obj.Visible = false end
                    end
                end
            end
        end
    end
end

ESP.getSetting = function(key)
    return ESP.Settings[key]
end

ESP.getAllSettings = function()
    return ESP.Settings
end

-- Вспомогательная функция для обновления цветов в реальном времени
ESP.updateColor = function(colorKey, colorValue)
    ESP.Settings[colorKey] = colorValue
    -- Можно добавить логику для мгновенного обновления цветов
end

-- ==============================================
-- ВСЕ ОСТАЛЬНЫЕ ФУНКЦИИ ИЗ ОРИГИНАЛЬНОГО СКРИПТА
-- (копируем без изменений, только заменяем SETTINGS на ESP.Settings)
-- ==============================================

-- УЛУЧШЕННАЯ ФУНКЦИЯ: Определение роли в MM2
local function getMM2Role(player)
    if not player or not player.Character then return "Innocent" end
    
    local char = player.Character
    
    -- Проверяем на Murderer (ищем нож)
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            local toolName = string.lower(child.Name)
            if toolName:find("knife") or toolName:find("murder") or toolName:find("blood") then
                return "Murderer"
            end
        end
    end
    
    -- Проверяем Backpack на нож
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = string.lower(tool.Name)
                if toolName:find("knife") or toolName:find("murder") or toolName:find("blood") then
                    return "Murderer"
                end
            end
        end
    end
    
    -- Проверяем на Sheriff (ищем пистолет)
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            local toolName = string.lower(child.Name)
            if toolName:find("gun") or toolName:find("pistol") or toolName:find("revolver") 
               or toolName:find("sheriff") or toolName:find("handgun") then
                return "Sheriff"
            end
        end
    end
    
    -- Проверяем Backpack на пистолет
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = string.lower(tool.Name)
                if toolName:find("gun") or toolName:find("pistol") or toolName:find("revolver") 
                   or toolName:find("sheriff") or toolName:find("handgun") then
                    return "Sheriff"
                end
            end
        end
    end
    
    return "Innocent"
end

-- Оптимизированная функция поиска оружия
local function quickFindWeapons()
    local currentTime = tick()
    
    -- Используем кэш если прошло меньше 5 секунд
    if currentTime - lastCacheUpdate < 5 and #cachedWeapons > 0 then
        return cachedWeapons
    end
    
    -- Сканируем раз в weaponScanInterval секунд
    if currentTime - lastWeaponScan < weaponScanInterval then
        return weaponCache
    end
    
    lastWeaponScan = currentTime
    local weapons = {}
    local foundGuids = {}
    
    -- Оптимизация: проверяем только детей workspace и некоторые папки
    local workspaceChildren = workspace:GetChildren()
    
    for _, obj in ipairs(workspaceChildren) do
        -- Быстрая проверка имени перед дальнейшими проверками
        if obj.Name == "GunDrop" and (obj:IsA("Part") or obj:IsA("MeshPart")) then
            local guid = tostring(obj:GetDebugId()) -- Уникальный идентификатор
            
            if not foundGuids[guid] then
                foundGuids[guid] = true
                
                -- Быстрая проверка на Display
                local isDisplay = false
                local parent = obj.Parent
                
                for i = 1, 2 do -- Проверяем только 2 уровня вверх
                    if not parent then break end
                    if string.find(string.lower(parent.Name), "display") or parent.Name == "WeaponDisplays" then
                        isDisplay = true
                        break
                    end
                    parent = parent.Parent
                end
                
                -- Проверяем, не держит ли оружие игрок
                local isHeldByPlayer = false
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Character and obj:IsDescendantOf(player.Character) then
                        isHeldByPlayer = true
                        break
                    end
                end
                
                if not isDisplay and not isHeldByPlayer then
                    table.insert(weapons, {
                        object = obj,
                        name = "GunDrop",
                        isGun = true,
                        position = obj.Position
                    })
                end
            end
        end
        
        -- Пропускаем папку WeaponDisplays полностью
        if obj.Name == "WeaponDisplays" and obj:IsA("Folder") then
            continue
        elseif obj:IsA("Folder") or obj:IsA("Model") then
            -- Проверяем детей папок/моделей
            local children = obj:GetChildren()
            for _, child in ipairs(children) do
                if child.Name == "GunDrop" and (child:IsA("Part") or child:IsA("MeshPart")) then
                    local guid = tostring(child:GetDebugId())
                    
                    if not foundGuids[guid] then
                        foundGuids[guid] = true
                        
                        -- Проверяем, не держит ли оружие игрок
                        local isHeldByPlayer = false
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player.Character and child:IsDescendantOf(player.Character) then
                                isHeldByPlayer = true
                                break
                            end
                        end
                        
                        if not isHeldByPlayer then
                            table.insert(weapons, {
                                object = child,
                                name = "GunDrop",
                                isGun = true,
                                position = child.Position
                            })
                        end
                    end
                end
            end
        end
    end
    
    -- Обновляем кэш
    cachedWeapons = weapons
    lastCacheUpdate = currentTime
    weaponCache = weapons
    
    return weapons
end

-- Оптимизированная функция обновления ESP для оружия
local function updateWeaponESP()
    if not ESP.Settings.WeaponESP then
        -- Быстрая очистка если функция выключена
        for weaponId, elements in pairs(weaponElements) do
            if elements.box then
                elements.box.Visible = false
                elements.box:Remove()
            end
            if elements.text then
                elements.text.Visible = false
                elements.text:Remove()
            end
            weaponElements[weaponId] = nil
        end
        weaponElements = {}
        return
    end
    
    -- Получаем оружие (используется кэш)
    local weapons = quickFindWeapons()
    
    -- Таблица для отслеживания существующих оружий
    local existingWeapons = {}
    
    -- Обновляем ESP для всех найденных оружий
    for _, weapon in ipairs(weapons) do
        if weapon.object and weapon.object.Parent then
            -- Получаем экранные координаты
            local screenPos, onScreen = Camera:WorldToViewportPoint(weapon.position)
            
            if onScreen then
                local dist = (Camera.CFrame.Position - weapon.position).Magnitude
                
                if dist <= ESP.Settings.MaxRenderDistance then
                    local weaponId = tostring(weapon.object:GetDebugId())
                    existingWeapons[weaponId] = true
                    
                    -- Получаем или создаём элементы
                    local elements = weaponElements[weaponId]
                    
                    if not elements then
                        elements = {}
                        
                        -- Создаем бокс
                        elements.box = Drawing.new("Square")
                        elements.box.Visible = true
                        elements.box.Thickness = 2
                        elements.box.Filled = false
                        elements.box.Transparency = 0.7
                        elements.box.Color = Color3.fromRGB(0, 255, 0)
                        
                        -- Создаем текст
                        elements.text = Drawing.new("Text")
                        elements.text.Visible = true
                        elements.text.Size = 16
                        elements.text.Outline = true
                        elements.text.Center = true
                        elements.text.Font = 2
                        elements.text.Color = Color3.fromRGB(0, 255, 0)
                        
                        weaponElements[weaponId] = elements
                    end
                    
                    -- Оптимизация: вычисляем один раз
                    local scale = math.clamp(500 / dist, 20, 80)
                    local halfScale = scale / 2
                    
                    -- Обновляем позиции
                    elements.box.Size = Vector2.new(scale, scale)
                    elements.box.Position = Vector2.new(screenPos.X - halfScale, screenPos.Y - halfScale)
                    
                    -- Обновляем текст
                    elements.text.Text = weapon.name .. " [" .. math.floor(dist) .. "]"
                    elements.text.Position = Vector2.new(screenPos.X, screenPos.Y + halfScale + 5)
                    
                    -- Делаем видимым
                    elements.box.Visible = true
                    elements.text.Visible = true
                else
                    -- Скрываем если слишком далеко
                    local weaponId = tostring(weapon.object:GetDebugId())
                    local elements = weaponElements[weaponId]
                    if elements then
                        elements.box.Visible = false
                        elements.text.Visible = false
                    end
                end
            else
                -- Скрываем если не на экране
                local weaponId = tostring(weapon.object:GetDebugId())
                local elements = weaponElements[weaponId]
                if elements then
                    elements.box.Visible = false
                    elements.text.Visible = false
                end
            end
        end
    end
    
    -- Очищаем ESP для оружия, которое больше не существует
    for weaponId, elements in pairs(weaponElements) do
        if not existingWeapons[weaponId] then
            if elements.box then
                elements.box.Visible = false
                elements.box:Remove()
            end
            if elements.text then
                elements.text.Visible = false
                elements.text:Remove()
            end
            weaponElements[weaponId] = nil
        end
    end
end

-- Основные функции ESP
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

    if ESP.Settings.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
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
        sq.Thickness = 2 sq.Color = ESP.Settings.BoxColor sq.Filled = false sq.Transparency = 1 sq.Visible = false
        return sq
    elseif typeName == "Tracer" then
        local ln = Drawing.new("Line")
        ln.Thickness = 2 ln.Color = ESP.Settings.TracerColor ln.Transparency = 1 ln.Visible = false
        return ln
    elseif typeName == "Name" then
        local txt = Drawing.new("Text")
        txt.Size = 14 txt.Color = ESP.Settings.NameColor txt.Outline = true txt.Center = true txt.Font = 2 txt.Visible = false
        return txt
    end
end

local function updateESP()
    if not ESP.Settings.ESPEnabled then
        for _, elements in pairs(espElements) do
            for _, obj in pairs(elements) do if obj then obj.Visible = false end end
        end
        return
    end

    local now = tick()

    if now % ESP.Settings.ReinitInterval < 0.2 then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and isValidTarget(player) then
                removeElements(player)
                local elements = {}
                if ESP.Settings.BoxEnabled    then elements.box    = createDrawing("Box") end
                if ESP.Settings.TracerEnabled then elements.tracer = createDrawing("Tracer") end
                if ESP.Settings.NameEnabled   then elements.name   = createDrawing("Name") end
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

        if not rootVisible or rootDepth > ESP.Settings.MaxDepth or rootDepth < 0.1 then
            for _, obj in pairs(elements) do if obj then obj.Visible = false end end
            continue
        end

        local dist = (Camera.CFrame.Position - rootPos).Magnitude
        if dist > ESP.Settings.MaxRenderDistance then
            for _, obj in pairs(elements) do if obj then obj.Visible = false end end
            continue
        end

        local scale = math.clamp(2500 / dist, 12, 450)
        local boxW = scale * 0.6
        local boxH = scale
        
        -- Определяем цвет в зависимости от роли в MM2
        local boxColor = ESP.Settings.BoxColor
        local tracerColor = ESP.Settings.TracerColor
        local nameColor = ESP.Settings.NameColor
        
        if ESP.Settings.MM2RoleESP then
            local role = getMM2Role(player)
            if role == "Murderer" then
                boxColor = Color3.fromRGB(255, 0, 0)
                tracerColor = Color3.fromRGB(255, 0, 0)
                nameColor = Color3.fromRGB(255, 0, 0)
            elseif role == "Sheriff" then
                boxColor = Color3.fromRGB(0, 100, 255)
                tracerColor = Color3.fromRGB(0, 100, 255)
                nameColor = Color3.fromRGB(0, 100, 255)
            end
        end

        if ESP.Settings.BoxEnabled and elements.box then
            elements.box.Size = Vector2.new(boxW, boxH)
            elements.box.Position = Vector2.new(root2d.X - boxW/2, head2d.Y - boxH*0.05)
            elements.box.Color = boxColor
            elements.box.Visible = true
        end

        if ESP.Settings.TracerEnabled and elements.tracer then
            local fromY = Camera.ViewportSize.Y
            if ESP.Settings.TracerFrom == "Top" then fromY = 0 elseif ESP.Settings.TracerFrom == "Center" then fromY = Camera.ViewportSize.Y / 2 end
            local fromPos = Vector2.new(Camera.ViewportSize.X / 2, fromY)
            elements.tracer.From = fromPos
            elements.tracer.To = Vector2.new(feet2d.X, feet2d.Y)
            elements.tracer.Color = tracerColor
            elements.tracer.Visible = true
        end

        if ESP.Settings.NameEnabled and elements.name then
            local nameText = player.Name
            if ESP.Settings.ShowDistance then nameText = nameText .. " [" .. math.floor(dist) .. "]" end
            
            if ESP.Settings.MM2RoleESP then
                local role = getMM2Role(player)
                if role == "Murderer" then
                    nameText = "[MURDERER] " .. nameText
                elseif role == "Sheriff" then
                    nameText = "[SHERIFF] " .. nameText
                end
            end
            
            elements.name.Text = nameText
            elements.name.Position = Vector2.new(root2d.X, head2d.Y - 25)
            elements.name.Color = nameColor
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
            if ESP.Settings.BoxEnabled    then elements.box    = createDrawing("Box") end
            if ESP.Settings.TracerEnabled then elements.tracer = createDrawing("Tracer") end
            if ESP.Settings.NameEnabled   then elements.name   = createDrawing("Name") end
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
            if ESP.Settings.BoxEnabled    then elements.box    = createDrawing("Box") end
            if ESP.Settings.TracerEnabled then elements.tracer = createDrawing("Tracer") end
            if ESP.Settings.NameEnabled   then elements.name   = createDrawing("Name") end
            espElements[player] = elements
        end
    end)
end)

Players.PlayerRemoving:Connect(removeElements)

-- Главный цикл
RunService.RenderStepped:Connect(function()
    updateESP()
    updateWeaponESP()
end)

-- Экспортируем ESP
return ESP
