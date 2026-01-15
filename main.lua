-- main.lua для MM2 ESP с Fluent UI + Aimbot
local Library = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Загружаем модули
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/ESP.lua"))()
local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/Aimbot.lua"))()

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

Tabs.Main:AddParagraph({
    Title = "Управление",
    Content = "Нажми INSERT для скрытия/показа интерфейса\n" .. 
             "Нажми " .. Aimbot.getBindText("Aim") .. " для включения Aimbot\n" ..
             "Нажми " .. Aimbot.getBindText("Target") .. " для удержания цели\n" ..
             "Настройки сохраняются автоматически"
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

-- Вкладка Aimbot
Tabs.Aimbot:AddToggle("AimbotEnabled", {
    Title = "Включить Aimbot",
    Description = "Активирует систему аимбота",
    Default = Aimbot.getSetting("Enabled"),
    Callback = function(value)
        Aimbot.updateSetting("Enabled", value)
    end
})

Tabs.Aimbot:AddToggle("HoldPkmMode", {
    Title = "Hold PKM Mode",
    Description = "Требовать удержание клавиши для работы",
    Default = Aimbot.getSetting("holdPkmMode"),
    Callback = function(value)
        Aimbot.updateSetting("holdPkmMode", value)
    end
})

Tabs.Aimbot:AddDropdown("TargetPart", {
    Title = "Часть тела",
    Description = "Выберите часть тела для прицеливания",
    Values = {"Head", "UpperTorso", "HumanoidRootPart"},
    Default = Aimbot.getSetting("targetPart"),
    Callback = function(value)
        Aimbot.updateSetting("targetPart", value)
    end
})

Tabs.Aimbot:AddDropdown("AimMethod", {
    Title = "Метод аима",
    Description = "Выберите метод прицеливания",
    Values = {"Mouse", "Camera"},
    Default = Aimbot.getSetting("aimMethod"),
    Callback = function(value)
        Aimbot.updateSetting("aimMethod", value)
    end
})

Tabs.Aimbot:AddSlider("FovRadius", {
    Title = "Радиус FOV",
    Description = "Угол обзора для поиска цели",
    Default = Aimbot.getSetting("fovRadius"),
    Min = 50,
    Max = 600,
    Rounding = 0,
    Callback = function(value)
        Aimbot.updateSetting("fovRadius", value)
    end
})

Tabs.Aimbot:AddSlider("Smoothness", {
    Title = "Плавность",
    Description = "Уровень сглаживания прицеливания",
    Default = Aimbot.getSetting("smoothness"),
    Min = 0.05,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        Aimbot.updateSetting("smoothness", value)
    end
})

Tabs.Aimbot:AddToggle("ShowFovCircle", {
    Title = "Показывать FOV круг",
    Description = "Отображает круг радиуса FOV на экране",
    Default = Aimbot.getSetting("showFovCircle"),
    Callback = function(value)
        Aimbot.updateSetting("showFovCircle", value)
    end
})

Tabs.Aimbot:AddToggle("WallCheck", {
    Title = "Проверка стен",
    Description = "Игнорировать цели за стенами",
    Default = Aimbot.getSetting("wallCheck"),
    Callback = function(value)
        Aimbot.updateSetting("wallCheck", value)
    end
})

Tabs.Aimbot:AddToggle("FullTarget", {
    Title = "Full Target",
    Description = "Удерживать цель до выхода из FOV",
    Default = Aimbot.getSetting("fullTarget"),
    Callback = function(value)
        Aimbot.updateSetting("fullTarget", value)
    end
})

Tabs.Aimbot:AddToggle("IgnoreTeams", {
    Title = "Игнорировать команды",
    Description = "Не целиться в союзников",
    Default = Aimbot.getSetting("ignoreTeams"),
    Callback = function(value)
        Aimbot.updateSetting("ignoreTeams", value)
    end
})

-- Раздел биндов
Tabs.Aimbot:AddSection({
    Title = "Привязки клавиш",
    Content = "Назначьте клавиши для управления аимботом"
})

Tabs.Aimbot:AddButton({
    Title = "Назначить клавишу аима",
    Description = "Текущая клавиша: " .. Aimbot.getBindText("Aim"),
    Callback = function()
        Library:Notify({
            Title = "Aimbot",
            Content = "Нажмите клавишу для назначения...",
            Duration = 3
        })
        Aimbot.startBind("Aim")
    end
})

Tabs.Aimbot:AddButton({
    Title = "Назначить клавишу удержания",
    Description = "Текущая клавиша: " .. Aimbot.getBindText("Target"),
    Callback = function()
        Library:Notify({
            Title = "Aimbot",
            Content = "Нажмите клавишу для назначения...",
            Duration = 3
        })
        Aimbot.startBind("Target")
    end
})

Tabs.Aimbot:AddButton({
    Title = "Сбросить бинды",
    Description = "Вернуть настройки клавиш по умолчанию",
    Callback = function()
        Aimbot.resetBinds()
        Library:Notify({
            Title = "Aimbot",
            Content = "Бинды сброшены на значения по умолчанию",
            Duration = 3
        })
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

-- Цвета Aimbot
Tabs.Visual:AddSection({
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

-- Дополнительные визуальные настройки
Tabs.Visual:AddSection({
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
        ESP = ESP.saveSettings and ESP.saveSettings() or nil,
        Aimbot = Aimbot.saveSettings and Aimbot.saveSettings() or nil,
        Visual = {
            fovColor = fovColor,
            extraSettings = extraSettings
        }
    }
    
    return settingsTable
end

-- Функция для загрузки всех настроек
local function loadAllSettings(settingsTable)
    if not settingsTable then return end
    
    -- Загружаем настройки ESP
    if settingsTable.ESP and ESP.loadSettings then
        ESP.loadSettings(settingsTable.ESP)
    end
    
    -- Загружаем настройки Aimbot
    if settingsTable.Aimbot and Aimbot.loadSettings then
        Aimbot.loadSettings(settingsTable.Aimbot)
    end
    
    -- Загружаем визуальные настройки
    if settingsTable.Visual then
        fovColor = settingsTable.Visual.fovColor or Color3.fromRGB(255, 255, 255)
        if settingsTable.Visual.extraSettings then
            for key, value in pairs(settingsTable.Visual.extraSettings) do
                extraSettings[key] = value
            end
        end
    end
end

-- Загружаем настройки при старте
task.spawn(function()
    wait(1)
    local success, savedSettings = pcall(function()
        return SaveManager:Load("AllSettings")
    end)
    
    if success and savedSettings then
        loadAllSettings(savedSettings)
        print("✅ Все настройки загружены")
    end
end)

-- Сохраняем настройки при изменении
local function saveSettingsOnChange()
    SaveManager:Save("AllSettings", saveAllSettings())
end

-- Подписываемся на изменения
for _, tab in pairs(Tabs) do
    if tab then
        -- Добавляем задержку для экономии ресурсов
        local debounce = false
        tab.Tab.MouseButton1Click:Connect(function()
            if not debounce then
                debounce = true
                saveSettingsOnChange()
                wait(0.5)
                debounce = false
            end
        end)
    end
end

-- Выбираем первую вкладку
Window:SelectTab(1)

-- Уведомление
Library:Notify({
    Title = "MM2 ESP + Aimbot Hub",
    Content = "Меню успешно загружено!",
    SubContent = "Нажми INSERT для скрытия меню\n" ..
                "Нажми " .. Aimbot.getBindText("Aim") .. " для включения Aimbot",
    Duration = 5
})

print("🎮 MM2 ESP + Aimbot Hub успешно загружен!")
print("📌 Нажми INSERT для скрытия/показа интерфейса")
print("🎯 Aimbot клавиша: " .. Aimbot.getBindText("Aim"))
print("🎯 Target клавиша: " .. Aimbot.getBindText("Target"))

-- Инициализируем ESP если есть функция init
if ESP.init then
    ESP.init()
end

-- Функция для безопасного отключения скрипта
local function cleanup()
    if Aimbot.cleanup then
        Aimbot.cleanup()
    end
    
    -- Сохраняем настройки перед выходом
    saveSettingsOnChange()
end

-- Обработка выхода из игры
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("UserId"):Connect(function()
    cleanup()
end)

-- Обработка закрытия
game:BindToClose(function()
    cleanup()
end)

-- Возвращаем объекты для внешнего доступа
return {
    Window = Window,
    ESP = ESP,
    Aimbot = Aimbot,
    cleanup = cleanup
}
