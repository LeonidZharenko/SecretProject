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
        end,
        init = function() print("[ESP] Инициализирован") end
    }
end

local successAimbot, AimbotModule = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/Aimbot.lua"))()
end)

if not successAimbot or not AimbotModule then
    warn("❌ Не удалось загрузить Aimbot модуль!")
    AimbotModule = {
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
        loadSettings = function(settings)
            if type(settings) == "table" then
                for key, value in pairs(settings) do
                    AimbotModule.updateSetting(key, value)
                end
            end
        end,
        init = function()
            print("[Aimbot] Инициализирован")
            -- Создаем FOV круг если нужно
            if AimbotModule.getSetting("showFovCircle") and AimbotModule.getSetting("Enabled") then
                task.spawn(function()
                    wait(1)
                    print("[Aimbot] FOV круг должен быть виден")
                end)
            end
        end
    }
end

-- Локальные переменные для FOV круга
local FovCircle = nil
local FovCircleConnection = nil
local FovColor = Color3.fromRGB(255, 255, 255)

-- Функция для создания/обновления FOV круга
local function updateFovCircle()
    if FovCircleConnection then
        FovCircleConnection:Disconnect()
        FovCircleConnection = nil
    end
    
    if not AimbotModule.getSetting("showFovCircle") then
        if FovCircle then
            FovCircle:Remove()
            FovCircle = nil
        end
        return
    end
    
    if not AimbotModule.getSetting("Enabled") then
        if FovCircle then
            FovCircle:Remove()
            FovCircle = nil
        end
        return
    end
    
    -- Создаем круг
    if not FovCircle then
        FovCircle = Instance.new("Frame")
        FovCircle.Name = "FovCircle"
        FovCircle.BackgroundTransparency = 1
        FovCircle.Size = UDim2.new(1, 0, 1, 0)
        FovCircle.Parent = game:GetService("CoreGui")
        
        local circle = Instance.new("ImageLabel")
        circle.Name = "Circle"
        circle.BackgroundTransparency = 1
        circle.Size = UDim2.new(0, AimbotModule.getSetting("fovRadius") * 2, 0, AimbotModule.getSetting("fovRadius") * 2)
        circle.Position = UDim2.new(0.5, -AimbotModule.getSetting("fovRadius"), 0.5, -AimbotModule.getSetting("fovRadius"))
        circle.Image = "rbxassetid://3570695787"
        circle.ImageColor3 = FovColor
        circle.ScaleType = Enum.ScaleType.Slice
        circle.SliceScale = 0.01
        circle.Parent = FovCircle
        
        print("[FOV] Круг создан")
    else
        -- Обновляем существующий круг
        local circle = FovCircle:FindFirstChild("Circle")
        if circle then
            circle.Size = UDim2.new(0, AimbotModule.getSetting("fovRadius") * 2, 0, AimbotModule.getSetting("fovRadius") * 2)
            circle.Position = UDim2.new(0.5, -AimbotModule.getSetting("fovRadius"), 0.5, -AimbotModule.getSetting("fovRadius"))
            circle.ImageColor3 = FovColor
            print("[FOV] Круг обновлен")
        end
    end
    
    -- Обновляем в реальном времени
    FovCircleConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if FovCircle and FovCircle:FindFirstChild("Circle") then
            local circle = FovCircle.Circle
            circle.Visible = AimbotModule.getSetting("showFovCircle") and AimbotModule.getSetting("Enabled")
            if circle.Visible then
                circle.ImageColor3 = FovColor
            end
        end
    end)
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
local aimKeyText = AimbotModule.getBindText and AimbotModule.getBindText("Aim") or "Insert"
local targetKeyText = AimbotModule.getBindText and AimbotModule.getBindText("Target") or "RMB"

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

-- ... (остальные настройки ESP остаются без изменений) ...

-- Вкладка Aimbot
Tabs.Aimbot:AddToggle("AimbotEnabled", {
    Title = "Включить Aimbot",
    Description = "Активирует систему аимбота",
    Default = AimbotModule.getSetting and AimbotModule.getSetting("Enabled") or false,
    Callback = function(value)
        if AimbotModule.updateSetting then
            AimbotModule.updateSetting("Enabled", value)
            -- Обновляем FOV круг при включении/выключении
            updateFovCircle()
        end
    end
})

Tabs.Aimbot:AddToggle("HoldPkmMode", {
    Title = "Hold PKM Mode",
    Description = "Требовать удержание клавиши для работы",
    Default = AimbotModule.getSetting and AimbotModule.getSetting("holdPkmMode") or false,
    Callback = function(value)
        if AimbotModule.updateSetting then
            AimbotModule.updateSetting("holdPkmMode", value)
        end
    end
})

Tabs.Aimbot:AddDropdown("TargetPart", {
    Title = "Часть тела",
    Description = "Выберите часть тела для прицеливания",
    Values = {"Head", "UpperTorso", "HumanoidRootPart"},
    Default = AimbotModule.getSetting and AimbotModule.getSetting("targetPart") or "Head",
    Callback = function(value)
        if AimbotModule.updateSetting then
            AimbotModule.updateSetting("targetPart", value)
        end
    end
})

Tabs.Aimbot:AddDropdown("AimMethod", {
    Title = "Метод аима",
    Description = "Выберите метод прицеливания",
    Values = {"Mouse", "Camera"},
    Default = AimbotModule.getSetting and AimbotModule.getSetting("aimMethod") or "Mouse",
    Callback = function(value)
        if AimbotModule.updateSetting then
            AimbotModule.updateSetting("aimMethod", value)
        end
    end
})

Tabs.Aimbot:AddSlider("FovRadius", {
    Title = "Радиус FOV",
    Description = "Угол обзора для поиска цели",
    Default = AimbotModule.getSetting and AimbotModule.getSetting("fovRadius") or 120,
    Min = 50,
    Max = 600,
    Rounding = 0,
    Callback = function(value)
        if AimbotModule.updateSetting then
            AimbotModule.updateSetting("fovRadius", value)
            -- Обновляем размер FOV круга
            updateFovCircle()
        end
    end
})

Tabs.Aimbot:AddSlider("Smoothness", {
    Title = "Плавность",
    Description = "Уровень сглаживания прицеливания",
    Default = AimbotModule.getSetting and AimbotModule.getSetting("smoothness") or 0.15,
    Min = 0.05,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        if AimbotModule.updateSetting then
            AimbotModule.updateSetting("smoothness", value)
        end
    end
})

Tabs.Aimbot:AddToggle("ShowFovCircle", {
    Title = "Показывать FOV круг",
    Description = "Отображает круг радиуса FOV на экране",
    Default = AimbotModule.getSetting and AimbotModule.getSetting("showFovCircle") or false,
    Callback = function(value)
        if AimbotModule.updateSetting then
            AimbotModule.updateSetting("showFovCircle", value)
            -- Обновляем FOV круг
            updateFovCircle()
        end
    end
})

Tabs.Aimbot:AddToggle("WallCheck", {
    Title = "Проверка стен",
    Description = "Игнорировать цели за стенами",
    Default = AimbotModule.getSetting and AimbotModule.getSetting("wallCheck") or true,
    Callback = function(value)
        if AimbotModule.updateSetting then
            AimbotModule.updateSetting("wallCheck", value)
        end
    end
})

Tabs.Aimbot:AddToggle("FullTarget", {
    Title = "Full Target",
    Description = "Удерживать цель до выхода из FOV",
    Default = AimbotModule.getSetting and AimbotModule.getSetting("fullTarget") or false,
    Callback = function(value)
        if AimbotModule.updateSetting then
            AimbotModule.updateSetting("fullTarget", value)
        end
    end
})

Tabs.Aimbot:AddToggle("IgnoreTeams", {
    Title = "Игнорировать команды",
    Description = "Не целиться в союзников",
    Default = AimbotModule.getSetting and AimbotModule.getSetting("ignoreTeams") or true,
    Callback = function(value)
        if AimbotModule.updateSetting then
            AimbotModule.updateSetting("ignoreTeams", value)
        end
    end
})

-- Раздел биндов
Tabs.Aimbot:AddParagraph({
    Title = "Привязки клавиш",
    Content = "Назначьте клавиши для управления аимботом"
})

Tabs.Aimbot:AddButton({
    Title = "Назначить клавишу аима",
    Description = "Текущая: " .. aimKeyText,
    Callback = function()
        Library:Notify({
            Title = "Aimbot",
            Content = "Нажмите любую клавишу для назначения...",
            Duration = 3
        })
        if AimbotModule.startBind then
            AimbotModule.startBind("Aim")
        end
    end
})

Tabs.Aimbot:AddButton({
    Title = "Назначить клавишу удержания",
    Description = "Текущая: " .. targetKeyText,
    Callback = function()
        Library:Notify({
            Title = "Aimbot",
            Content = "Нажмите любую клавишу для назначения...",
            Duration = 3
        })
        if AimbotModule.startBind then
            AimbotModule.startBind("Target")
        end
    end
})

Tabs.Aimbot:AddButton({
    Title = "Сбросить бинды",
    Description = "Вернуть настройки по умолчанию",
    Callback = function()
        if AimbotModule.resetBinds then
            AimbotModule.resetBinds()
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

Tabs.Visual:AddColorpicker("FovCircleColor", {
    Title = "Цвет FOV круга",
    Default = FovColor,
    Callback = function(value)
        FovColor = value
        updateFovCircle() -- Обновляем цвет круга
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
            Enabled = AimbotModule.getSetting and AimbotModule.getSetting("Enabled") or false,
            holdPkmMode = AimbotModule.getSetting and AimbotModule.getSetting("holdPkmMode") or false,
            targetPart = AimbotModule.getSetting and AimbotModule.getSetting("targetPart") or "Head",
            aimMethod = AimbotModule.getSetting and AimbotModule.getSetting("aimMethod") or "Mouse",
            fovRadius = AimbotModule.getSetting and AimbotModule.getSetting("fovRadius") or 120,
            smoothness = AimbotModule.getSetting and AimbotModule.getSetting("smoothness") or 0.15,
            showFovCircle = AimbotModule.getSetting and AimbotModule.getSetting("showFovCircle") or false,
            wallCheck = AimbotModule.getSetting and AimbotModule.getSetting("wallCheck") or true,
            fullTarget = AimbotModule.getSetting and AimbotModule.getSetting("fullTarget") or false,
            ignoreTeams = AimbotModule.getSetting and AimbotModule.getSetting("ignoreTeams") or true
        },
        Visual = {
            fovColor = FovColor,
            extraSettings = extraSettings
        }
    }
    
    return settingsTable
end

-- Функция для загрузки всех настроек
local function loadAllSettings(settingsTable)
    if not settingsTable or type(settingsTable) ~= "table" then
        warn("⚠️ Настройки не загружены или повреждены")
        return
    end
    
    -- Загружаем настройки ESP
    if settingsTable.ESP and type(settingsTable.ESP) == "table" and ESP.updateSetting then
        for key, value in pairs(settingsTable.ESP) do
            ESP.updateSetting(key, value)
        end
    end
    
    -- Загружаем настройки Aimbot
    if settingsTable.Aimbot and type(settingsTable.Aimbot) == "table" then
        if AimbotModule.loadSettings then
            AimbotModule.loadSettings(settingsTable.Aimbot)
        elseif AimbotModule.updateSetting then
            for key, value in pairs(settingsTable.Aimbot) do
                AimbotModule.updateSetting(key, value)
            end
        end
    end
    
    -- Загружаем визуальные настройки
    if settingsTable.Visual and type(settingsTable.Visual) == "table" then
        if settingsTable.Visual.fovColor then
            FovColor = settingsTable.Visual.fovColor
        end
        if settingsTable.Visual.extraSettings then
            for key, value in pairs(settingsTable.Visual.extraSettings) do
                extraSettings[key] = value
            end
        end
    end
    
    -- Обновляем FOV круг после загрузки настроек
    updateFovCircle()
end

-- Загружаем настройки при старте
task.spawn(function()
    wait(1)
    local success, savedSettings = pcall(function()
        return SaveManager:Load("AllSettings")
    end)
    
    if success and savedSettings and type(savedSettings) == "table" then
        loadAllSettings(savedSettings)
        Library:Notify({
            Title = "Настройки",
            Content = "Все настройки успешно загружены",
            Duration = 3
        })
    else
        Library:Notify({
            Title = "Настройки",
            Content = "Используются настройки по умолчанию",
            Duration = 3
        })
    end
end)

-- Выбираем первую вкладку
Window:SelectTab(1)

-- Уведомление
local notificationText = "Меню успешно загружено!"
notificationText = notificationText .. "\nНажми " .. aimKeyText .. " для включения Aimbot"

Library:Notify({
    Title = "MM2 ESP + Aimbot Hub",
    Content = notificationText,
    Duration = 5
})

print("🎮 MM2 ESP + Aimbot Hub успешно загружен!")
print("📌 Нажми INSERT для скрытия/показа интерфейса")
print("🎯 Aimbot клавиша: " .. aimKeyText)
print("🎯 Target клавиша: " .. targetKeyText)

-- Инициализируем ESP и Aimbot
if ESP and ESP.init then
    ESP.init()
end

if AimbotModule and AimbotModule.init then
    task.spawn(function()
        wait(1)
        AimbotModule.init()
        -- Создаем FOV круг после инициализации
        updateFovCircle()
    end)
end

-- Функция для безопасного отключения скрипта
local function cleanup()
    -- Удаляем FOV круг
    if FovCircle then
        FovCircle:Remove()
        FovCircle = nil
    end
    
    if FovCircleConnection then
        FovCircleConnection:Disconnect()
        FovCircleConnection = nil
    end
    
    if AimbotModule and AimbotModule.cleanup then
        AimbotModule.cleanup()
    end
    
    -- Сохраняем настройки
    local success = pcall(function()
        SaveManager:Save("AllSettings", saveAllSettings())
    end)
    
    if success then
        print("✅ Настройки сохранены")
    end
end

-- Автосохранение каждые 30 секунд
task.spawn(function()
    while true do
        wait(30)
        local success = pcall(function()
            SaveManager:Save("AllSettings", saveAllSettings())
        end)
        if success then
            print("✅ Автосохранение настроек")
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
    Aimbot = AimbotModule,
    cleanup = cleanup
}
