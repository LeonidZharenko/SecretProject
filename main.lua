-- main.lua (исправленная версия)
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Ждем загрузки
wait(2)

-- Загружаем ESP модуль
local ESP
local success1, err1 = pcall(function()
    local espCode = game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/ESP.lua", true)
    ESP = load(espCode)()
end)

if not success1 or not ESP then
    warn("Ошибка загрузки ESP:", err1)
    -- Создаем простой ESP модуль для теста
    ESP = {
        Settings = {
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
        },
        updateSetting = function(key, value)
            print("Настройка", key, "изменена на:", value)
            ESP.Settings[key] = value
        end,
        getSetting = function(key)
            return ESP.Settings[key]
        end,
        updateColor = function(key, color)
            ESP.Settings[key] = color
        end
    }
end

print("✅ ESP модуль готов")

-- Загружаем и выполняем UI модуль
local success2, err2 = pcall(function()
    local uiCode = game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/SimpleUi.lua", true)
    local uiFunc = load(uiCode)
    if uiFunc then
        uiFunc(ESP)
    else
        error("Не удалось загрузить функцию UI")
    end
end)

if not success2 then
    warn("Ошибка загрузки UI:", err2)
    -- Создаем простой UI вручную
    createSimpleUI(ESP)
end

print("🎮 MM2 ESP загружен! Нажми INSERT")

-- Функция для создания простого UI
function createSimpleUI(ESPModule)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MM2ESPSimpleUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = true
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = "MM2 ESP"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Size = UDim2.new(1, -20, 1, -60)
    ScrollingFrame.Position = UDim2.new(0, 10, 0, 50)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.ScrollBarThickness = 4
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollingFrame.Parent = MainFrame
    
    -- Кнопка включения ESP
    local createToggle = function(text, settingKey, yPos)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, 0, 0, 40)
        toggleFrame.Position = UDim2.new(0, 0, 0, yPos)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Parent = ScrollingFrame
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 36)
        button.BackgroundColor3 = ESPModule.getSetting(settingKey) and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(80, 80, 100)
        button.BorderSizePixel = 0
        button.Text = text .. (ESPModule.getSetting(settingKey) and " ✅" or " ❌")
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.Gotham
        button.TextSize = 14
        button.Parent = toggleFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = button
        
        button.MouseButton1Click:Connect(function()
            local newValue = not ESPModule.getSetting(settingKey)
            ESPModule.updateSetting(settingKey, newValue)
            button.BackgroundColor3 = newValue and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(80, 80, 100)
            button.Text = text .. (newValue and " ✅" or " ❌")
        end)
        
        return yPos + 45
    end
    
    local yPos = 0
    yPos = createToggle("Включить ESP", "ESPEnabled", yPos)
    yPos = createToggle("Box ESP", "BoxEnabled", yPos)
    yPos = createToggle("Tracers", "TracerEnabled", yPos)
    yPos = createToggle("Имена игроков", "NameEnabled", yPos)
    yPos = createToggle("Показывать дистанцию", "ShowDistance", yPos)
    yPos = createToggle("Team Check", "TeamCheck", yPos)
    yPos = createToggle("MM2 Роли", "MM2RoleESP", yPos)
    yPos = createToggle("ESP GunDrop", "WeaponESP", yPos)
    
    -- Бинд на INSERT
    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
    
    return ScreenGui
end
