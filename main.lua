-- main.lua (ВСЕ В ОДНОМ ФАЙЛЕ)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Ждем загрузки
if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

wait(1)

-- ==================== ESP МОДУЛЬ ====================
local ESP = {}

-- Настройки
ESP.Settings = {
    ESPEnabled = true,
    BoxEnabled = true,
    TracerEnabled = true,
    NameEnabled = true,
    ShowDistance = true,
    TeamCheck = true,
    MM2RoleESP = false,
    WeaponESP = false,
    MaxRenderDistance = 5000,
    BoxColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(255, 255, 255),
    NameColor = Color3.fromRGB(255, 255, 255),
}

-- Функции для UI
ESP.updateSetting = function(key, value)
    if ESP.Settings[key] ~= nil then
        ESP.Settings[key] = value
        print("[ESP] Настройка", key, "изменена на:", value)
    end
end

ESP.getSetting = function(key)
    return ESP.Settings[key]
end

ESP.updateColor = function(key, color)
    ESP.Settings[key] = color
end

-- ==================== UI МОДУЛЬ ====================
local function createUI(ESPModule)
    print("🔄 Создаем UI...")
    
    local player = Players.LocalPlayer
    local PlayerGui = player:WaitForChild("PlayerGui")
    
    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MM2ESPUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui
    
    -- Основное окно
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = true
    MainFrame.Parent = ScreenGui
    
    -- Стиль
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(60, 60, 80)
    UIStroke.Thickness = 2
    UIStroke.Parent = MainFrame
    
    -- Заголовок
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundTransparency = 1
    Title.Text = "MM2 ESP Hub"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    -- Контейнер
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Size = UDim2.new(1, -20, 1, -70)
    ScrollingFrame.Position = UDim2.new(0, 10, 0, 60)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.ScrollBarThickness = 4
    ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollingFrame.Parent = MainFrame
    
    -- Функция создания кнопок
    local function createToggle(text, settingKey, yPos)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, 0, 0, 42)
        toggleFrame.Position = UDim2.new(0, 0, 0, yPos)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Parent = ScrollingFrame
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 38)
        button.BackgroundColor3 = ESPModule.getSetting(settingKey) and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 80)
        button.BorderSizePixel = 0
        button.Text = text .. (ESPModule.getSetting(settingKey) and " ✅" or " ❌")
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.Gotham
        button.TextSize = 14
        button.Parent = toggleFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = button
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(100, 100, 120)
        stroke.Thickness = 1
        stroke.Parent = button
        
        -- Анимация при наведении
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = ESPModule.getSetting(settingKey) and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(80, 80, 100)
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = ESPModule.getSetting(settingKey) and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 80)
        end)
        
        -- Клик
        button.MouseButton1Click:Connect(function()
            local newValue = not ESPModule.getSetting(settingKey)
            ESPModule.updateSetting(settingKey, newValue)
            button.BackgroundColor3 = newValue and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 80)
            button.Text = text .. (newValue and " ✅" or " ❌")
        end)
        
        return yPos + 47
    end
    
    -- Создаем все toggle'ы
    local yPos = 0
    local toggles = {
        {"Включить ESP", "ESPEnabled"},
        {"Box ESP", "BoxEnabled"},
        {"Tracers", "TracerEnabled"},
        {"Имена игроков", "NameEnabled"},
        {"Показывать дистанцию", "ShowDistance"},
        {"Team Check", "TeamCheck"},
        {"MM2 Роли", "MM2RoleESP"},
        {"ESP GunDrop", "WeaponESP"}
    }
    
    for i, toggle in ipairs(toggles) do
        yPos = createToggle(toggle[1], toggle[2], yPos)
    end
    
    -- Бинд на INSERT
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
    
    print("✅ UI создан! Нажми INSERT")
    return ScreenGui
end

-- ==================== ЗАПУСК ====================
print("🎮 Загружаем MM2 ESP Hub...")

-- Создаем UI
local UI = createUI(ESP)

-- Здесь будет ваш ESP код...
-- (оставьте весь ваш оригинальный ESP код здесь)

print("✅ MM2 ESP Hub успешно загружен!")
print("📌 Нажми INSERT для показа/скрытия меню")
