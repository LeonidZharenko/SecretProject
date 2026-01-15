-- main.lua для MM2 ESP с Fluent UI + Aimbot
local Library = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Загружаем модули
local successESP, ESP = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/ESP.lua"))()
end)

if not successESP or not ESP then
    warn("❌ Не удалось загрузить ESP модуль!")
    ESP = {
        getSetting = function(key) 
            local defaults = {
                ESPEnabled = false,
                BoxEnabled = false,
                TracerEnabled = false,
                NameEnabled = false,
                ShowDistance = false,
                TeamCheck = false,
                MM2RoleESP = false,
                WeaponESP = false,
                MaxRenderDistance = 5000,
                TracerFrom = "Bottom",
                BoxColor = Color3.fromRGB(255, 255, 255),
                TracerColor = Color3.fromRGB(255, 255, 255),
                NameColor = Color3.fromRGB(255, 255, 255)
            }
            return defaults[key]
        end,
        updateSetting = function(key, value) 
            print("[ESP] Настройка обновлена: " .. key .. " = " .. tostring(value)) 
        end,
        updateColor = function(key, value)
            print("[ESP] Цвет обновлен: " .. key .. " = " .. tostring(value))
        end
    }
end

local successAimbot, Aimbot = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/Aimbot.lua"))()
end)

if not successAimbot or not Aimbot then
    warn("❌ Не удалось загрузить Aimbot модуль!")
    Aimbot = {
        getSetting = function(key) 
            local defaults = {
                Enabled = false,
                targetPart = "Head",
                aimMethod = "Mouse",
                fovRadius = 120,
                smoothness = 0.15,
                showFovCircle = false,
                wallCheck = true,
                fullTarget = false,
                ignoreTeams = true,
                holdPkmMode = false
            }
            return defaults[key]
        end,
        updateSetting = function(key, value) 
            print("[Aimbot] Настройка обновлена: " .. key .. " = " .. tostring(value)) 
        end,
        getBindText = function(bindType) 
            if bindType == "Aim" then
                return "Insert"
            else
                return "RMB"
            end
        end,
        startBind = function(bindType) 
            print("[Aimbot] Ожидание клавиши для: " .. bindType) 
        end,
        resetBinds = function() 
            print("[Aimbot] Бинды сброшены") 
        end,
        cleanup = function() end,
        saveSettings = function() return {} end,
        loadSettings = function() end
    }
end

-- Создаем окно
local Window = Library:CreateWindow({
    Title = "MM2 ESP + Aimbot Hub",
    SubTitle = "by LeonidZharenko",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 460),
    Acrylic = true,
    Theme = "Darker",
    AccentColor = Color3.fromRGB(0, 120, 215),
    MinimizeKey = Enum.KeyCode.Insert
})

-- Создаем вкладки
local Tabs = {
    Main = Window:AddTab({ Title = "Главная", Icon = "home" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
    Visual = Window:AddTab({ Title = "Визуал", Icon = "palette" }),
    Settings = Window:AddTab({ Title = "Настройки", Icon = "settings" }),
}

-- Вкладка Главная
local playerName = game.Players.LocalPlayer.Name 
Tabs.Main:AddParagraph({
    Title = "Добро пожаловать, " .. playerName .. "!", 
    Content = "Полный набор для Murder Mystery 2\n\nФункции:\n• ESP игроков с Box, Tracer, Names\n• Aimbot с FOV и настройками\n• Определение ролей (Murderer/Sheriff)\n• GunDrop ESP (оптимизированный)\n• Настройка цветов\n• Сохранение настроек"
})

-- Управление
local aimKeyText = "Insert"
local targetKeyText = "RMB"

if Aimbot and Aimbot.getBindText then
    aimKeyText = Aimbot.getBindText("Aim") or "Insert"
    targetKeyText = Aimbot.getBindText("Target") or "RMB"
end

local managementText = "Нажми INSERT для скрытия/показа интерфейса\n" ..
                       "Нажми " .. aimKeyText .. " для включения Aimbot\n" ..
                       "Нажми " .. targetKeyText .. " для удержания цели\n" ..
                       "Настройки сохраняются автоматически"

Tabs.Main:AddParagraph({
    Title = "Управление",
    Content = managementText
})

-- Вкладка ESP
Tabs.ESP:AddToggle("ESPEnabled", {
    Title = "Включить ESP",
    Description = "Активировать всю систему ESP",
    Default = ESP.getSetting and ESP.getSetting("ESPEnabled") or false,
    Callback = function(value)
        if ESP.updateSetting then
            ESP.updateSetting("ESPEnabled", value)
        end
    end
})

Tabs.ESP:AddToggle("BoxEnabled", {
    Title = "Box ESP",
    Description = "Рамки вокруг игроков",
    Default = ESP.getSetting and ESP.getSetting("BoxEnabled") or false,
    Callback = function(value)
        if ESP.updateSetting then
            ESP.updateSetting("BoxEnabled", value)
        end
    end
})

Tabs.ESP:AddToggle("TracerEnabled", {
    Title = "Tracers",
    Description = "Линии от центра экрана к игрокам",
    Default = ESP.getSetting and ESP.getSetting("TracerEnabled") or false,
    Callback = function(value)
        if ESP.updateSetting then
            ESP.updateSetting("TracerEnabled", value)
        end
    end
})

Tabs.ESP:AddToggle("NameEnabled", {
    Title = "Имена игроков",
    Description = "Отображать ники над игроками",
    Default = ESP.getSetting and ESP.getSetting("NameEnabled") or false,
    Callback = function(value)
        if ESP.updateSetting then
            ESP.updateSetting("NameEnabled", value)
        end
    end
})

Tabs.ESP:AddToggle("ShowDistance", {
    Title = "Показывать дистанцию",
    Description = "Показывать расстояние до игроков",
    Default = ESP.getSetting and ESP.getSetting("ShowDistance") or false,
    Callback = function(value)
        if ESP.updateSetting then
            ESP.updateSetting("ShowDistance", value)
        end
    end
})

Tabs.ESP:AddToggle("TeamCheck", {
    Title = "Team Check",
    Description = "Игнорировать союзников",
    Default = ESP.getSetting and ESP.getSetting("TeamCheck") or false,
    Callback = function(value)
        if ESP.updateSetting then
            ESP.updateSetting("TeamCheck", value)
        end
    end
})

Tabs.ESP:AddToggle("MM2RoleESP", {
    Title = "MM2 Роли",
    Description = "Определять Murderer/Sheriff",
    Default = ESP.getSetting and ESP.getSetting("MM2RoleESP") or false,
    Callback = function(value)
        if ESP.updateSetting then
            ESP.updateSetting("MM2RoleESP", value)
        end
    end
})

Tabs.ESP:AddToggle("WeaponESP", {
    Title = "GunDrop ESP",
    Description = "Показывать оружие на земле",
    Default = ESP.getSetting and ESP.getSetting("WeaponESP") or false,
    Callback = function(value)
        if ESP.updateSetting then
            ESP.updateSetting("WeaponESP", value)
        end
    end
})

Tabs.ESP:AddSlider("MaxRenderDistance", {
    Title = "Макс. дистанция",
    Description = "Максимальное расстояние отрисовки",
    Default = ESP.getSetting and ESP.getSetting("MaxRenderDistance") or 5000,
    Min = 500,
    Max = 10000,
    Rounding = 0,
    Callback = function(value)
        if ESP.updateSetting then
            ESP.updateSetting("MaxRenderDistance", value)
        end
    end
})

Tabs.ESP:AddDropdown("TracerFrom", {
    Title = "Начало трассеров",
    Description = "Откуда идут линии",
    Values = {"Bottom", "Center", "Top"},
    Default = ESP.getSetting and (ESP.getSetting("TracerFrom") or "Bottom") or "Bottom",
    Callback = function(value)
        if ESP.updateSetting then
            ESP.updateSetting("TracerFrom", value)
        end
    end
})

-- Вкладка Aimbot
Tabs.Aimbot:AddToggle("AimbotEnabled", {
    Title = "Включить Aimbot",
    Description = "Активирует систему аимбота",
    Default = Aimbot.getSetting and Aimbot.getSetting("Enabled") or false,
    Callback = function(value)
        if Aimbot.updateSetting then
            Aimbot.updateSetting("Enabled", value)
        end
    end
})

Tabs.Aimbot:AddToggle("HoldPkmMode", {
    Title = "Hold PKM Mode",
    Description = "Требовать удержание клавиши для работы",
    Default = Aimbot.getSetting and Aimbot.getSetting("holdPkmMode") or false,
    Callback = function(value)
        if Aimbot.updateSetting then
            Aimbot.updateSetting("holdPkmMode", value)
        end
    end
})

Tabs.Aimbot:AddDropdown("TargetPart", {
    Title = "Часть тела",
    Description = "Выберите часть тела для прицеливания",
    Values = {"Head", "UpperTorso", "HumanoidRootPart"},
    Default = Aimbot.getSetting and Aimbot.getSetting("targetPart") or "Head",
    Callback = function(value)
        if Aimbot.updateSetting then
            Aimbot.updateSetting("targetPart", value)
        end
    end
})

Tabs.Aimbot:AddDropdown("AimMethod", {
    Title = "Метод аима",
    Description = "Выберите метод прицеливания",
    Values = {"Mouse", "Camera"},
    Default = Aimbot.getSetting and Aimbot.getSetting("aimMethod") or "Mouse",
    Callback = function(value)
        if Aimbot.updateSetting then
            Aimbot.updateSetting("aimMethod", value)
        end
    end
})

Tabs.Aimbot:AddSlider("FovRadius", {
    Title = "Радиус FOV",
    Description = "Угол обзора для поиска цели",
    Default = Aimbot.getSetting and Aimbot.getSetting("fovRadius") or 120,
    Min = 50,
    Max = 600,
    Rounding = 0,
    Callback = function(value)
        if Aimbot.updateSetting then
            Aimbot.updateSetting("fovRadius", value)
        end
    end
})

Tabs.Aimbot:AddSlider("Smoothness", {
    Title = "Плавность",
    Description = "Уровень сглаживания прицеливания",
    Default = Aimbot.getSetting and Aimbot.getSetting("smoothness") or 0.15,
    Min = 0.05,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        if Aimbot.updateSetting then
            Aimbot.updateSetting("smoothness", value)
        end
    end
})

Tabs.Aimbot:AddToggle("ShowFovCircle", {
    Title = "Показывать FOV круг",
    Description = "Отображает круг радиуса FOV на экране",
    Default = Aimbot.getSetting and Aimbot.getSetting("showFovCircle") or false,
    Callback = function(value)
        if Aimbot.updateSetting then
            Aimbot.updateSetting("showFovCircle", value)
        end
    end
})

Tabs.Aimbot:AddToggle("WallCheck", {
    Title = "Проверка стен",
    Description = "Игнорировать цели за стенами",
    Default = Aimbot.getSetting and Aimbot.getSetting("wallCheck") or true,
    Callback = function(value)
        if Aimbot.updateSetting then
            Aimbot.updateSetting("wallCheck", value)
        end
    end
})

Tabs.Aimbot:AddToggle("FullTarget", {
    Title = "Full Target",
    Description = "Удерживать цель до выхода из FOV",
    Default = Aimbot.getSetting and Aimbot.getSetting("fullTarget") or false,
    Callback = function(value)
        if Aimbot.updateSetting then
            Aimbot.updateSetting("fullTarget", value)
        end
    end
})

Tabs.Aimbot:AddToggle("IgnoreTeams", {
    Title = "Игнорировать команды",
    Description = "Не целиться в союзников",
    Default = Aimbot.getSetting and Aimbot.getSetting("ignoreTeams") or true,
    Callback = function(value)
        if Aimbot.updateSetting then
            Aimbot.updateSetting("ignoreTeams", value)
        end
    end
})

-- Раздел биндов (без AddSection)
Tabs.Aimbot:AddParagraph({
    Title = "Привязки клавиш",
    Content = "Назначьте клавиши для управления аимботом"
})

-- Локальные переменные для текста биндов
local currentAimBindText = aimKeyText
local currentTargetBindText = targetKeyText

Tabs.Aimbot:AddButton({
    Title = "Назначить клавишу аима",
    Description = "Текущая: " .. currentAimBindText,
    Callback = function()
        Library:Notify({
            Title = "Aimbot",
            Content = "Нажмите любую клавишу для назначения...",
            Duration = 3
        })
        if Aimbot.startBind then
            Aimbot.startBind("Aim")
        end
    end
})

Tabs.Aimbot:AddButton({
    Title = "Назначить клавишу удержания",
    Description = "Текущая: " .. currentTargetBindText,
    Callback = function()
        Library:Notify({
            Title = "Aimbot",
            Content = "Нажмите любую клавишу для назначения...",
            Duration = 3
        })
        if Aimbot.startBind then
            Aimbot.startBind("Target")
        end
    end
})

Tabs.Aimbot:AddButton({
    Title = "Сбросить бинды",
    Description = "Вернуть настройки по умолчанию",
    Callback = function()
        if Aimbot.resetBinds then
            Aimbot.resetBinds()
        end
        Library:Notify({
            Title = "Aimbot",
            Content = "Бинды сброшены на значения по умолчанию",
            Duration = 3
        })
    end
})

-- Вкладка Визуал
-- Цвета ESP
Tabs.Visual:AddParagraph({
    Title = "Цвета ESP",
    Content = "Настройка цветов для ESP элементов"
})

Tabs.Visual:AddColorpicker("BoxColor", {
    Title = "Цвет рамок",
    Default = ESP.getSetting and ESP.getSetting("BoxColor") or Color3.fromRGB(255, 255, 255),
    Callback = function(value)
        if ESP.updateColor then
            ESP.updateColor("BoxColor", value)
        elseif ESP.updateSetting then
            ESP.updateSetting("BoxColor", value)
        end
    end
})

Tabs.Visual:AddColorpicker("TracerColor", {
    Title = "Цвет линий",
    Default = ESP.getSetting and ESP.getSetting("TracerColor") or Color3.fromRGB(255, 255, 255),
    Callback = function(value)
        if ESP.updateColor then
            ESP.updateColor("TracerColor", value)
        elseif ESP.updateSetting then
            ESP.updateSetting("TracerColor", value)
        end
    end
})

Tabs.Visual:AddColorpicker("NameColor", {
    Title = "Цвет имен",
    Default = ESP.getSetting and ESP.getSetting("NameColor") or Color3.fromRGB(255, 255, 255),
    Callback = function(value)
        if ESP.updateColor then
            ESP.updateColor("NameColor", value)
        elseif ESP.updateSetting then
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

-- Цвета Aimbot
Tabs.Visual:AddParagraph({
    Title = "Цвета Aimbot",
    Content = "Настройки отображения аимбота"
})

local fovColor = Color3.fromRGB(255, 255, 255)
Tabs.Visual:AddColorpicker("FovCircleColor", {
    Title = "Цвет FOV круга",
    Default = fovColor,
    Callback = function(value)
        fovColor = value
    end
})

-- Дополнительные настройки
Tabs.Visual:AddParagraph({
    Title = "Дополнительные настройки",
    Content = "Дополнительные визуальные эффекты"
})

local extraSettings = {
    OutlineEnabled = true,
    ChamsEnabled = false,
    GlowEffect = false
}

Tabs.Visual:AddToggle("OutlineEnabled", {
    Title = "Outline эффект",
    Description = "Добавляет контур к ESP",
    Default = extraSettings.OutlineEnabled,
    Callback = function(value)
        extraSettings.OutlineEnabled = value
        if ESP.updateSetting then
            ESP.updateSetting("OutlineEnabled", value)
        end
    end
})

Tabs.Visual:AddToggle("ChamsEnabled", {
    Title = "Chams эффект",
    Description = "Заливка игроков цветом",
    Default = extraSettings.ChamsEnabled,
    Callback = function(value)
        extraSettings.ChamsEnabled = value
        if ESP.updateSetting then
            ESP.updateSetting("ChamsEnabled", value)
        end
    end
})

Tabs.Visual:AddToggle("GlowEffect", {
    Title = "Glow эффект",
    Description = "Свечение вокруг игроков",
    Default = extraSettings.GlowEffect,
    Callback = function(value)
        extraSettings.GlowEffect = value
        if ESP.updateSetting then
            ESP.updateSetting("GlowEffect", value)
        end
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

-- Функция для сохранения всех настроек
local function saveAllSettings()
    local settingsTable = {
        ESP = {
            ESPEnabled = ESP.getSetting and ESP.getSetting("ESPEnabled") or false,
            BoxEnabled = ESP.getSetting and ESP.getSetting("BoxEnabled") or false,
            TracerEnabled = ESP.getSetting and ESP.getSetting("TracerEnabled") or false,
            NameEnabled = ESP.getSetting and ESP.getSetting("NameEnabled") or false,
            ShowDistance = ESP.getSetting and ESP.getSetting("ShowDistance") or false,
            TeamCheck = ESP.getSetting and ESP.getSetting("TeamCheck") or false,
            MM2RoleESP = ESP.getSetting and ESP.getSetting("MM2RoleESP") or false,
            WeaponESP = ESP.getSetting and ESP.getSetting("WeaponESP") or false,
            MaxRenderDistance = ESP.getSetting and ESP.getSetting("MaxRenderDistance") or 5000,
            TracerFrom = ESP.getSetting and ESP.getSetting("TracerFrom") or "Bottom"
        },
        Aimbot = {
            Enabled = Aimbot.getSetting and Aimbot.getSetting("Enabled") or false,
            holdPkmMode = Aimbot.getSetting and Aimbot.getSetting("holdPkmMode") or false,
            targetPart = Aimbot.getSetting and Aimbot.getSetting("targetPart") or "Head",
            aimMethod = Aimbot.getSetting and Aimbot.getSetting("aimMethod") or "Mouse",
            fovRadius = Aimbot.getSetting and Aimbot.getSetting("fovRadius") or 120,
            smoothness = Aimbot.getSetting and Aimbot.getSetting("smoothness") or 0.15,
            showFovCircle = Aimbot.getSetting and Aimbot.getSetting("showFovCircle") or false,
            wallCheck = Aimbot.getSetting and Aimbot.getSetting("wallCheck") or true,
            fullTarget = Aimbot.getSetting and Aimbot.getSetting("fullTarget") or false,
            ignoreTeams = Aimbot.getSetting and Aimbot.getSetting("ignoreTeams") or true
        },
        Visual = {
            fovColor = fovColor,
            extraSettings = extraSettings
        }
    }
    
    return settingsTable
end

-- Функция для загрузки всех настроек (ИСПРАВЛЕНА)
local function loadAllSettings(settingsTable)
    -- Проверяем, что settingsTable является таблицей
    if type(settingsTable) ~= "table" then
        warn("⚠️ loadAllSettings: settingsTable не является таблицей, используется настройки по умолчанию")
        return
    end
    
    -- Загружаем настройки ESP (с проверкой)
    if type(settingsTable.ESP) == "table" and ESP.updateSetting then
        for key, value in pairs(settingsTable.ESP) do
            ESP.updateSetting(key, value)
        end
    else
        warn("⚠️ loadAllSettings: настройки ESP отсутствуют или некорректны")
    end
    
    -- Загружаем настройки Aimbot (с проверкой)
    if type(settingsTable.Aimbot) == "table" and Aimbot.updateSetting then
        for key, value in pairs(settingsTable.Aimbot) do
            Aimbot.updateSetting(key, value)
        end
    else
        warn("⚠️ loadAllSettings: настройки Aimbot отсутствуют или некорректны")
    end
    
    -- Загружаем визуальные настройки (с проверкой)
    if type(settingsTable.Visual) == "table" then
        if settingsTable.Visual.fovColor then
            fovColor = settingsTable.Visual.fovColor
        end
        if type(settingsTable.Visual.extraSettings) == "table" then
            for key, value in pairs(settingsTable.Visual.extraSettings) do
                extraSettings[key] = value
            end
        end
    end
end

-- Загружаем настройки при старте (ИСПРАВЛЕНО)
task.spawn(function()
    wait(1)
    local success, savedSettings = pcall(function()
        return SaveManager:Load("AllSettings")
    end)
    
    if success and savedSettings then
        -- Проверяем тип загруженных настроек
        if type(savedSettings) == "table" then
            loadAllSettings(savedSettings)
            Library:Notify({
                Title = "Настройки",
                Content = "Все настройки успешно загружены",
                Duration = 3
            })
        else
            warn("⚠️ Загруженные настройки не являются таблицей, используется настройки по умолчанию")
        end
    else
        warn("⚠️ Не удалось загрузить настройки: " .. (savedSettings or "неизвестная ошибка"))
    end
end)

-- Выбираем первую вкладку
Window:SelectTab(1)

-- Уведомление
local notificationText = "Меню успешно загружено!"
if aimKeyText ~= "Insert" then
    notificationText = notificationText .. "\nНажми " .. aimKeyText .. " для включения Aimbot"
end

Library:Notify({
    Title = "MM2 ESP + Aimbot Hub",
    Content = notificationText,
    Duration = 5
})

print("🎮 MM2 ESP + Aimbot Hub успешно загружен!")
print("📌 Нажми INSERT для скрытия/показа интерфейса")
print("🎯 Aimbot клавиша: " .. aimKeyText)
print("🎯 Target клавиша: " .. targetKeyText)

-- Инициализируем ESP если есть функция init
if ESP and ESP.init then
    ESP.init()
end

-- Функция для безопасного отключения скрипта
local function cleanup()
    if Aimbot and Aimbot.cleanup then
        Aimbot.cleanup()
    end
    
    -- Сохраняем настройки (с проверкой ошибок)
    local success = pcall(function()
        local settingsToSave = saveAllSettings()
        if type(settingsToSave) == "table" then
            SaveManager:Save("AllSettings", settingsToSave)
            print("✅ Настройки сохранены")
        else
            warn("⚠️ Не удалось сформировать таблицу настроек для сохранения")
        end
    end)
    
    if not success then
        warn("⚠️ Ошибка при сохранении настроек")
    end
end

-- Автосохранение каждые 30 секунд (с проверкой)
task.spawn(function()
    while true do
        wait(30)
        local success = pcall(function()
            local settingsToSave = saveAllSettings()
            if type(settingsToSave) == "table" then
                SaveManager:Save("AllSettings", settingsToSave)
                print("✅ Автосохранение настроек")
            end
        end)
        if not success then
            print("⚠️ Ошибка автосохранения настроек")
        end
    end
end)

-- Обработка выхода из игры
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not game:GetService("Players").LocalPlayer.Parent then
        cleanup()
    end
end)

-- Сохраняем при закрытии GUI (через сборку мусора)
local connection
connection = game:GetService("RunService").Heartbeat:Connect(function()
    -- Проверяем, существует ли GUI
    local guiExists = false
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name == "Fluent" then
            guiExists = true
            break
        end
    end
    
    if not guiExists then
        cleanup()
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end
end)

-- Возвращаем объекты для внешнего доступа
return {
    Window = Window,
    ESP = ESP,
    Aimbot = Aimbot,
    cleanup = cleanup
}
