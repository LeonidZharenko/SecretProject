-- main.lua для MM2 ESP с Fluent UI
local Library = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Загружаем ваш ESP модуль
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/ESP.lua"))()

-- Загружаем Fly модуль
local FlyController = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/fly.lua"))()

-- Создаем окно
local Window = Library:CreateWindow({
    Title = "MM2 ESP Hub",
    SubTitle = "by Best Script",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
    AccentColor = Color3.fromRGB(0, 120, 215),
    MinimizeKey = Enum.KeyCode.Insert
})

-- Создаем вкладки
local Tabs = {
    Main = Window:AddTab({ Title = "Главная", Icon = "home" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Visual = Window:AddTab({ Title = "Визуал", Icon = "palette" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
    Settings = Window:AddTab({ Title = "Настройки", Icon = "settings" }),
}

-- Вкладка Главная
local playerName = game.Players.LocalPlayer.Name 
Tabs.Main:AddParagraph({
    Title = "Добро пожаловать, " .. playerName .. "!", 
    Content = "Best MM2 Script"
})

Tabs.Main:AddParagraph({
    Title = "Управление",
    Content = "Нажми INSERT для скрытия/показа интерфейса\n\nНастройки сохраняются автоматически"
})

-- Вкладка ESP
Tabs.ESP:AddToggle("ESPEnabled", {
    Title = "Включить ESP",
    Description = "Активировать всю систему ESP",
    Default = ESP.getSetting("ESPEnabled"),
    Callback = function(value)
        ESP.updateSetting("ESPEnabled", value)
    end
})

Tabs.ESP:AddToggle("BoxEnabled", {
    Title = "Box ESP",
    Description = "Рамки вокруг игроков",
    Default = ESP.getSetting("BoxEnabled"),
    Callback = function(value)
        ESP.updateSetting("BoxEnabled", value)
    end
})

Tabs.ESP:AddToggle("TracerEnabled", {
    Title = "Tracers",
    Description = "Линии от центра экрана к игрокам",
    Default = ESP.getSetting("TracerEnabled"),
    Callback = function(value)
        ESP.updateSetting("TracerEnabled", value)
    end
})

Tabs.ESP:AddToggle("NameEnabled", {
    Title = "Имена игроков",
    Description = "Отображать ники над игроками",
    Default = ESP.getSetting("NameEnabled"),
    Callback = function(value)
        ESP.updateSetting("NameEnabled", value)
    end
})

Tabs.ESP:AddToggle("ShowDistance", {
    Title = "Показывать дистанцию",
    Description = "Показывать расстояние до игроков",
    Default = ESP.getSetting("ShowDistance"),
    Callback = function(value)
        ESP.updateSetting("ShowDistance", value)
    end
})

Tabs.ESP:AddToggle("TeamCheck", {
    Title = "Team Check",
    Description = "Игнорировать союзников",
    Default = ESP.getSetting("TeamCheck"),
    Callback = function(value)
        ESP.updateSetting("TeamCheck", value)
    end
})

Tabs.ESP:AddToggle("MM2RoleESP", {
    Title = "MM2 Роли",
    Description = "Определять Murderer/Sheriff",
    Default = ESP.getSetting("MM2RoleESP"),
    Callback = function(value)
        ESP.updateSetting("MM2RoleESP", value)
    end
})

Tabs.ESP:AddToggle("WeaponESP", {
    Title = "GunDrop ESP",
    Description = "Показывать оружие на земле",
    Default = ESP.getSetting("WeaponESP"),
    Callback = function(value)
        ESP.updateSetting("WeaponESP", value)
    end
})

Tabs.ESP:AddSlider("MaxRenderDistance", {
    Title = "Макс. дистанция",
    Description = "Максимальное расстояние отрисовки",
    Default = ESP.getSetting("MaxRenderDistance"),
    Min = 500,
    Max = 10000,
    Rounding = 0,
    Callback = function(value)
        ESP.updateSetting("MaxRenderDistance", value)
    end
})

Tabs.ESP:AddDropdown("TracerFrom", {
    Title = "Начало трассеров",
    Description = "Откуда идут линии",
    Values = {"Bottom", "Center", "Top"},
    Default = ESP.getSetting("TracerFrom") or "Bottom",
    Callback = function(value)
        ESP.updateSetting("TracerFrom", value)
    end
})

-- Вкладка Визуал
Tabs.Visual:AddColorpicker("BoxColor", {
    Title = "Цвет рамок",
    Default = ESP.getSetting("BoxColor"),
    Callback = function(value)
        if ESP.updateColor then
            ESP.updateColor("BoxColor", value)
        else
            ESP.updateSetting("BoxColor", value)
        end
    end
})

Tabs.Visual:AddColorpicker("TracerColor", {
    Title = "Цвет линий",
    Default = ESP.getSetting("TracerColor"),
    Callback = function(value)
        if ESP.updateColor then
            ESP.updateColor("TracerColor", value)
        else
            ESP.updateSetting("TracerColor", value)
        end
    end
})

Tabs.Visual:AddColorpicker("NameColor", {
    Title = "Цвет имен",
    Default = ESP.getSetting("NameColor"),
    Callback = function(value)
        if ESP.updateColor then
            ESP.updateColor("NameColor", value)
        else
            ESP.updateSetting("NameColor", value)
        end
    end
})

Tabs.Visual:AddColorpicker("MurdererColor", {
    Title = "Цвет Murderer",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(value)
        if ESP.updateColor then
            ESP.updateColor("MurdererColor", value)
        end
    end
})

Tabs.Visual:AddColorpicker("SheriffColor", {
    Title = "Цвет Sheriff",
    Default = Color3.fromRGB(0, 100, 255),
    Callback = function(value)
        if ESP.updateColor then
            ESP.updateColor("SheriffColor", value)
        end
    end
})

Tabs.Visual:AddColorpicker("GunDropColor", {
    Title = "Цвет оружия",
    Default = Color3.fromRGB(0, 255, 0),
    Callback = function(value)
        if ESP.updateColor then
            ESP.updateColor("GunDropColor", value)
        end
    end
})

-- Вкладка Misc (Fly функции)
local minSpeed, maxSpeed = FlyController.getSpeedLimits()

-- Переменные для управления состоянием Fly
local flyToggle = Tabs.Misc:AddToggle("FlyEnabled", {
    Title = "Включить Fly",
    Description = "Активировать режим полета",
    Default = false,
    Callback = function(value)
        local success, result = pcall(function()
            if value then
                FlyController.toggle()
            else
                if FlyController.isFlying() then
                    FlyController.toggle()
                end
            end
            return true
        end)
        
        if not success then
            print("[ERROR] Fly toggle error:", result)
        end
    end
})

Tabs.Misc:AddSlider("FlySpeed", {
    Title = "Скорость полета",
    Description = "Регулировка скорости Fly",
    Default = FlyController.getSpeed(),
    Min = minSpeed,
    Max = maxSpeed,
    Rounding = 1,
    Callback = function(value)
        FlyController.setSpeed(value)
    end
})

Tabs.Misc:AddKeybind("FlyToggleKey", {
    Title = "Клавиша Fly",
    Description = "Привязка клавиши для включения/выключения Fly",
    Default = "F",
    Callback = function(key)
        local isFlying = FlyController.toggle()
        -- Безопасное обновление UI состояния
        task.spawn(function()
            if Library and Library.Flags and flyToggle then
                Library.Flags["FlyEnabled"] = isFlying
            end
        end)
    end
})

-- Вкладка Настройки
SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("MM2ESPHub")
SaveManager:SetFolder("MM2ESPHub/settings")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Выбираем первую вкладку
Window:SelectTab(1)

-- Загружаем сохраненные настройки
SaveManager:LoadAutoloadConfig()

-- Уведомление
Library:Notify({
    Title = "MM2 ESP Hub",
    Content = "ESP и Fly успешно загружены!",
    SubContent = "Нажми INSERT для скрытия меню",
    Duration = 5
})

print("🎮 MM2 ESP Hub успешно загружен!")
print("🎮 Fly Module загружен из modules/fly.lua")
print("📌 Нажми INSERT для скрытия/показа интерфейса")
print("🔄 Нажми F для включения/выключения Fly")

-- Инициализируем ESP если есть функция init
if ESP.init then
    ESP.init()
end

-- Обработка клавиши Fly через интерфейс
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Безопасная проверка клавиши Fly
    local flyKeybind = Library.Flags and Library.Flags.FlyToggleKey
    if flyKeybind and input.KeyCode == Enum.KeyCode[flyKeybind] then
        local isFlying = FlyController.toggle()
        
        -- Обновляем UI только если библиотека загружена
        task.spawn(function()
            if Library and Library.Flags then
                Library.Flags["FlyEnabled"] = isFlying
                Library:Notify({
                    Title = "Fly",
                    Content = isFlying and "Fly включен" or "Fly выключен",
                    Duration = 2
                })
            end
        end)
    end
end)
