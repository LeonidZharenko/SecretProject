-- modules/ui.lua
return function(ESP, Aimbot)
    local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/Source.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

    -- Создаем главное окно
    local Window = Fluent:CreateWindow({
        Title = "MM2 ESP Hub | v2.0",
        SubTitle = "by YourName",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = true, -- Размытый фон
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.Insert
    })

    -- Вкладка ESP
    local ESPTab = Window:AddTab({
        Title = "ESP",
        Icon = "eye"
    })

    -- Секция основных настроек
    ESPTab:AddSection("Основные настройки")
    
    ESPTab:AddToggle("ESPEnabled", {
        Title = "Включить ESP",
        Description = "Активировать всю систему ESP",
        Default = ESP.getSetting("Enabled"),
        Callback = function(value)
            ESP.updateSetting("Enabled", value)
        end
    })

    ESPTab:AddToggle("BoxESP", {
        Title = "Box ESP",
        Description = "Рамки вокруг игроков",
        Default = ESP.getSetting("Box"),
        Callback = function(value)
            ESP.updateSetting("Box", value)
        end
    })

    ESPTab:AddToggle("TracerESP", {
        Title = "Tracers",
        Description = "Линии от центра экрана к игрокам",
        Default = ESP.getSetting("Tracer"),
        Callback = function(value)
            ESP.updateSetting("Tracer", value)
        end
    })

    ESPTab:AddToggle("NamesESP", {
        Title = "Имена игроков",
        Description = "Отображать ники над игроками",
        Default = ESP.getSetting("Names"),
        Callback = function(value)
            ESP.updateSetting("Names", value)
        end
    })

    ESPTab:AddToggle("DistanceESP", {
        Title = "Дистанция",
        Description = "Показывать расстояние до игроков",
        Default = ESP.getSetting("ShowDistance"),
        Callback = function(value)
            ESP.updateSetting("ShowDistance", value)
        end
    })

    ESPTab:AddToggle("TeamCheckESP", {
        Title = "Team Check",
        Description = "Игнорировать союзников",
        Default = ESP.getSetting("TeamCheck"),
        Callback = function(value)
            ESP.updateSetting("TeamCheck", value)
        end
    })

    -- Секция дистанции
    ESPTab:AddSection("Дистанция рендера")
    
    ESPTab:AddSlider("MaxDistance", {
        Title = "Макс. дистанция",
        Description = "Максимальное расстояние отрисовки",
        Default = ESP.getSetting("MaxDistance"),
        Min = 500,
        Max = 10000,
        Rounding = 0,
        Callback = function(value)
            ESP.updateSetting("MaxDistance", value)
        end
    })

    -- Секция MM2 Ролей
    ESPTab:AddSection("MM2 Роли")
    
    ESPTab:AddToggle("ShowRoles", {
        Title = "Показывать роли",
        Description = "Определять Murderer/Sheriff",
        Default = ESP.getSetting("ShowRoles"),
        Callback = function(value)
            ESP.updateSetting("ShowRoles", value)
        end
    })

    ESPTab:AddColorpicker("MurdererColor", {
        Title = "Цвет Murderer",
        Default = ESP.getSetting("MurdererColor"),
        Callback = function(value)
            ESP.updateSetting("MurdererColor", value)
        end
    })

    ESPTab:AddColorpicker("SheriffColor", {
        Title = "Цвет Sheriff",
        Default = ESP.getSetting("SheriffColor"),
        Callback = function(value)
            ESP.updateSetting("SheriffColor", value)
        end
    })

    -- Секция GunDrop ESP
    ESPTab:AddSection("GunDrop ESP")
    
    ESPTab:AddToggle("GunDropESP", {
        Title = "ESP оружия",
        Description = "Показывать оружие на земле",
        Default = ESP.getSetting("GunDropESP"),
        Callback = function(value)
            ESP.updateSetting("GunDropESP", value)
        end
    })

    ESPTab:AddColorpicker("GunDropColor", {
        Title = "Цвет оружия",
        Default = ESP.getSetting("GunDropColor"),
        Callback = function(value)
            ESP.updateSetting("GunDropColor", value)
        end
    })

    -- Вкладка Aimbot
    local AimbotTab = Window:AddTab({
        Title = "Aimbot",
        Icon = "target"
    })

    AimbotTab:AddSection("Настройки аимбота")
    
    if Aimbot and Aimbot.Settings then
        AimbotTab:AddToggle("AimbotEnabled", {
            Title = "Включить Aimbot",
            Default = Aimbot.Settings.Enabled or false,
            Callback = function(value)
                if Aimbot.updateSetting then
                    Aimbot.updateSetting("Enabled", value)
                end
            end
        })

        -- Добавляем другие настройки аимбота
        AimbotTab:AddSlider("AimbotFOV", {
            Title = "FOV",
            Description = "Поле зрения аимбота",
            Default = Aimbot.Settings.FOV or 100,
            Min = 10,
            Max = 360,
            Rounding = 0,
            Callback = function(value)
                if Aimbot.updateSetting then
                    Aimbot.updateSetting("FOV", value)
                end
            end
        })
    end

    -- Вкладка Визуал
    local VisualTab = Window:AddTab({
        Title = "Визуал",
        Icon = "palette"
    })

    VisualTab:AddSection("Цвета ESP")
    
    VisualTab:AddColorpicker("BoxColor", {
        Title = "Цвет рамок",
        Default = ESP.getSetting("BoxColor"),
        Callback = function(value)
            ESP.updateSetting("BoxColor", value)
        end
    })

    VisualTab:AddColorpicker("TracerColor", {
        Title = "Цвет линий",
        Default = ESP.getSetting("TracerColor"),
        Callback = function(value)
            ESP.updateSetting("TracerColor", value)
        end
    })

    VisualTab:AddColorpicker("NameColor", {
        Title = "Цвет имен",
        Default = ESP.getSetting("NameColor"),
        Callback = function(value)
            ESP.updateSetting("NameColor", value)
        end
    })

    -- Вкладка Информация
    local InfoTab = Window:AddTab({
        Title = "Инфо",
        Icon = "info"
    })

    InfoTab:AddSection("О скрипте")
    
    InfoTab:AddParagraph({
        Title = "MM2 ESP Hub",
        Content = "Оптимизированный ESP и Aimbot для Murder Mystery 2\n\nФункции:\n• ESP игроков с Box, Tracer, Names\n• Определение ролей (Murderer/Sheriff)\n• GunDrop ESP (оптимизированный)\n• Aimbot с настройками\n• Красивый интерфейс\n\nУправление:\n• INSERT - скрыть/показать интерфейс\n• Настройки сохраняются автоматически"
    })

    InfoTab:AddSection("Горячие клавиши")
    
    InfoTab:AddKeybind("ToggleKeybind", {
        Title = "Переключить UI",
        Mode = "Toggle",
        Default = "Insert",
        Callback = function(value)
            Window:Minimize()
        end
    })

    -- Включаем сохранение настроек
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({"MenuKeybind"})
    
    InterfaceManager:BuildInterfaceSection(InfoTab)
    SaveManager:BuildConfigSection(InfoTab)

    -- Загружаем сохраненные настройки
    SaveManager:LoadAutoloadConfig()

    -- Уведомление о загрузке
    Fluent:Notify({
        Title = "MM2 ESP Hub",
        Content = "Скрипт успешно загружен!",
        Duration = 5
    })

    print("🎮 MM2 ESP Hub загружен!")
    print("📌 Нажми INSERT для скрытия/показа интерфейса")
end
