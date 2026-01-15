-- main.lua (ФИНАЛЬНАЯ ВЕРСИЯ С ESP И AIMBOT)
local Library = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Загружаем ESP модуль
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/esp.lua"))()

-- Загружаем Aimbot модуль
local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/aimbot.lua"))()

-- Проверяем загрузку модулей
if not ESP then
    error("❌ Не удалось загрузить ESP модуль!")
end

if not Aimbot then
    warn("⚠️ Aimbot модуль не загружен, будет работать только ESP")
end

-- Создаем окно Fluent
local Window = Library:CreateWindow({
    Title = "MM2 ESP Hub",
    SubTitle = "by LeonidZharenko",
    TabWidth = 160,
    Size = UDim2.fromOffset(620, 460),
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
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
    Settings = Window:AddTab({ Title = "Настройки", Icon = "settings" }),
}

-- Вкладка Главная
local playerName = game.Players.LocalPlayer.Name 
Tabs.Main:AddParagraph({
    Title = "Добро пожаловать, " .. playerName .. "!", 
    Content = "Оптимизированный ESP и Aimbot для Murder Mystery 2\n\nФункции:\n• ESP игроков с Box, Tracer, Names\n• Определение ролей (Murderer/Sheriff)\n• GunDrop ESP (оптимизированный)\n• Aimbot с несколькими методами\n• Настройка цветов и биндов\n• Сохранение настроек"
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
    Default = ESP.getSetting("TracerFrom"),
    Callback = function(value)
        ESP.updateSetting("TracerFrom", value)
    end
})

-- Вкладка Визуал
Tabs.Visual:AddColorpicker("BoxColor", {
    Title = "Цвет рамок",
    Default = ESP.getSetting("BoxColor"),
    Callback = function(value)
        ESP.updateColor("BoxColor", value)
    end
})

Tabs.Visual:AddColorpicker("TracerColor", {
    Title = "Цвет линий",
    Default = ESP.getSetting("TracerColor"),
    Callback = function(value)
        ESP.updateColor("TracerColor", value)
    end
})

Tabs.Visual:AddColorpicker("NameColor", {
    Title = "Цвет имен",
    Default = ESP.getSetting("NameColor"),
    Callback = function(value)
        ESP.updateColor("NameColor", value)
    end
})

Tabs.Visual:AddColorpicker("MurdererColor", {
    Title = "Цвет Murderer",
    Default = ESP.getSetting("MurdererColor") or Color3.fromRGB(255, 0, 0),
    Callback = function(value)
        ESP.updateColor("MurdererColor", value)
    end
})

Tabs.Visual:AddColorpicker("SheriffColor", {
    Title = "Цвет Sheriff",
    Default = ESP.getSetting("SheriffColor") or Color3.fromRGB(0, 100, 255),
    Callback = function(value)
        ESP.updateColor("SheriffColor", value)
    end
})

Tabs.Visual:AddColorpicker("GunDropColor", {
    Title = "Цвет оружия",
    Default = ESP.getSetting("GunDropColor") or Color3.fromRGB(0, 255, 0),
    Callback = function(value)
        ESP.updateColor("GunDropColor", value)
    end
})

-- Вкладка Aimbot (только если модуль загружен)
if Aimbot then
    -- Основные настройки аимбота
    Tabs.Aimbot:AddSection("Основные настройки")
    
    Tabs.Aimbot:AddToggle("AimbotEnabled", {
        Title = "Включить Aimbot",
        Description = "Активировать систему аимбота",
        Default = Aimbot.getSetting("Enabled"),
        Callback = function(value)
            Aimbot.updateSetting("Enabled", value)
        end
    })
    
    Tabs.Aimbot:AddToggle("showFovCircle", {
        Title = "Показывать FOV круг",
        Description = "Отображать круг поля зрения",
        Default = Aimbot.getSetting("showFovCircle"),
        Callback = function(value)
            Aimbot.updateSetting("showFovCircle", value)
        end
    })
    
    Tabs.Aimbot:AddToggle("wallCheck", {
        Title = "Проверка стен",
        Description = "Игнорировать игроков за стенами",
        Default = Aimbot.getSetting("wallCheck"),
        Callback = function(value)
            Aimbot.updateSetting("wallCheck", value)
        end
    })
    
    Tabs.Aimbot:AddToggle("fullTarget", {
        Title = "Full Target",
        Description = "Закреплять цель при выборе",
        Default = Aimbot.getSetting("fullTarget"),
        Callback = function(value)
            Aimbot.updateSetting("fullTarget", value)
        end
    })
    
    Tabs.Aimbot:AddToggle("ignoreTeams", {
        Title = "Игнорировать команды",
        Description = "Не целиться в союзников",
        Default = Aimbot.getSetting("ignoreTeams"),
        Callback = function(value)
            Aimbot.updateSetting("ignoreTeams", value)
        end
    })
    
    Tabs.Aimbot:AddToggle("holdPkmMode", {
        Title = "Режим удержания",
        Description = "Активировать аимбот только при удержании кнопки",
        Default = Aimbot.getSetting("holdPkmMode"),
        Callback = function(value)
            Aimbot.updateSetting("holdPkmMode", value)
        end
    })
    
    -- Настройки аимбота
    Tabs.Aimbot:AddSection("Параметры аимбота")
    
    Tabs.Aimbot:AddSlider("fovRadius", {
        Title = "FOV Радиус",
        Description = "Радиус поля зрения аимбота",
        Default = Aimbot.getSetting("fovRadius"),
        Min = 50,
        Max = 600,
        Rounding = 0,
        Callback = function(value)
            Aimbot.updateSetting("fovRadius", value)
        end
    })
    
    Tabs.Aimbot:AddSlider("smoothness", {
        Title = "Плавность",
        Description = "Плавность движения аимбота",
        Default = Aimbot.getSetting("smoothness"),
        Min = 0.05,
        Max = 1,
        Rounding = 2,
        Callback = function(value)
            Aimbot.updateSetting("smoothness", value)
        end
    })
    
    Tabs.Aimbot:AddSlider("maxDist", {
        Title = "Макс. дистанция",
        Description = "Максимальная дистанция аимбота",
        Default = Aimbot.getSetting("maxDist"),
        Min = 100,
        Max = 5000,
        Rounding = 0,
        Callback = function(value)
            Aimbot.updateSetting("maxDist", value)
        end
    })
    
    -- Выбор части тела
    local partDisplayNames = {
        Head = "Голова",
        UpperTorso = "Грудь",
        HumanoidRootPart = "Тело"
    }
    
    Tabs.Aimbot:AddDropdown("targetPart", {
        Title = "Целевая часть",
        Description = "Часть тела для прицеливания",
        Values = {"Head", "UpperTorso", "HumanoidRootPart"},
        Default = Aimbot.getSetting("targetPart"),
        Callback = function(value)
            Aimbot.updateSetting("targetPart", value)
        end
    })
    
    -- Выбор метода аима
    Tabs.Aimbot:AddDropdown("aimMethod", {
        Title = "Метод аима",
        Description = "Способ прицеливания",
        Values = {"Auto", "Mouse", "Camera"},
        Default = Aimbot.getSetting("aimMethod"),
        Callback = function(value)
            Aimbot.updateSetting("aimMethod", value)
        end
    })
    
    -- Настройки биндов
    Tabs.Aimbot:AddSection("Настройки биндов")
    
    local keyOptions = {}
    for _, key in pairs(Enum.KeyCode:GetEnumItems()) do
        table.insert(keyOptions, key.Name)
    end
    
    Tabs.Aimbot:AddDropdown("AimKey", {
        Title = "Клавиша аимбота",
        Description = "Клавиша включения/выключения",
        Values = keyOptions,
        Default = Aimbot.getBinding("AimKey").Name,
        Callback = function(value)
            local keyCode = Enum.KeyCode[value]
            if keyCode then
                Aimbot.updateBinding("AimKey", keyCode)
            end
        end
    })
    
    Tabs.Aimbot:AddDropdown("TargetKey", {
        Title = "Клавиша прицеливания",
        Description = "Клавиша удержания цели",
        Values = {"MouseButton1", "MouseButton2", "MouseButton3"},
        Default = Aimbot.getBinding("TargetKey").Name,
        Callback = function(value)
            local inputType = Enum.UserInputType[value]
            if inputType then
                Aimbot.updateBinding("TargetKey", inputType)
            end
        end
    })
    
else
    -- Если аимбот не загружен
    Tabs.Aimbot:AddSection("Информация")
    Tabs.Aimbot:AddParagraph({
        Title = "Aimbot не загружен",
        Content = "Модуль аимбота не был загружен или произошла ошибка."
    })
end

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

-- Уведомление о загрузке
Library:Notify({
    Title = "MM2 ESP Hub",
    Content = "ESP и Aimbot успешно загружены!",
    SubContent = "Нажми INSERT для скрытия меню",
    Duration = 5
})

print("🎮 MM2 ESP Hub успешно загружен!")
print("📌 Нажми INSERT для скрытия/показа интерфейса")

-- Инициализируем ESP если есть функция init
if ESP.init then
    ESP.init()
end
