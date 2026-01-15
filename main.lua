-- main.lua - РАБОЧАЯ ВЕРСИЯ
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Ждем загрузку игрока и его GUI
if not player then
    player = Players.PlayerAdded:Wait()
end

if not player:WaitForChild("PlayerGui", 10) then
    warn("PlayerGui не загрузился, ждем...")
    wait(2)
end

print("🎮 Начинаем загрузку MM2 ESP Hub...")

-- Загружаем ESP модуль
local ESP
local success1, err1 = pcall(function()
    ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/ESP.lua"))()
end)

if not success1 then
    warn("❌ Ошибка загрузки ESP:", err1)
    return
end

print("✅ ESP модуль загружен")

-- Загружаем UI модуль
local success2, err2 = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/Ui.lua"))(ESP, nil)
end)

if not success2 then
    warn("❌ Ошибка загрузки UI:", err2)
    
    -- Попробуем альтернативный способ
    print("🔄 Пробуем альтернативную загрузку Fluent...")
    
    -- Прямая загрузка Fluent
    local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/Source.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    
    -- Создаем простой UI для теста
    local Window = Fluent:CreateWindow({
        Title = "MM2 ESP Hub | Тест",
        SubTitle = "LeonidZharenko",
        TabWidth = 160,
        Size = UDim2.fromOffset(500, 400),
        Acrylic = true,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.Insert
    })
    
    local ESPTab = Window:AddTab({Title = "ESP", Icon = "eye"})
    ESPTab:AddToggle("ESPEnabled", {
        Title = "Включить ESP",
        Default = true,
        Callback = function(value)
            ESP.updateSetting("ESPEnabled", value)
        end
    })
    
    Fluent:Notify({
        Title = "MM2 ESP Hub",
        Content = "Загружен в упрощенном режиме!",
        Duration = 5
    })
end

print("✅ MM2 ESP Hub успешно загружен!")
print("📌 Нажми INSERT для показа/скрытия меню")
