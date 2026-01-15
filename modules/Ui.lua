-- modules/ui.lua
return function(ESPModule, AimbotModule)
    -- Загружаем Fluent библиотеку
    local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/Source.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

    -- Создаем окно
    local Window = Fluent:CreateWindow({
        Title = "MM2 ESP Hub | v2.0",
        SubTitle = "by YourName",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = true,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.Insert
    })

    -- ==================== ВКЛАДКА ESP ====================
    local ESPTab = Window:AddTab({
        Title = "ESP",
        Icon = "eye"
    })

    -- Секция: Основные настройки ESP
    ESPTab:AddSection("Основные настройки")
    
    ESPTab:AddToggle("ESPEnabled", {
        Title = "Включить ESP",
        Description = "Активировать всю систему ESP",
        Default = ESPModule.getSetting("ESPEnabled"),
        Callback = function(value)
            ESPModule.updateSetting("ESPEnabled", value)
        end
    })
    
    ESPTab:AddToggle("BoxEnabled", {
        Title = "Box ESP",
        Description = "Рамки вокруг игроков",
        Default = ESPModule.getSetting("BoxEnabled"),
        Callback = function(value)
            ESPModule.updateSetting("BoxEnabled", value)
        end
    })
    
    ESPTab:AddToggle("TracerEnabled", {
        Title = "Tracers",
        Description = "Линии от центра экрана к игрокам",
        Default = ESPModule.getSetting("TracerEnabled"),
        Callback = function(value)
            ESPModule.updateSetting("TracerEnabled", value)
        end
    })
    
    ESPTab:AddToggle("NameEnabled", {
        Title = "Имена игроков",
        Description = "Отображать ники над игроками",
        Default = ESPModule.getSetting("NameEnabled"),
        Callback = function(value)
            ESPModule.updateSetting("NameEnabled", value)
        end
    })
    
    ESPTab:AddToggle("ShowDistance", {
        Title = "Показывать дистанцию",
        Description = "Показывать расстояние до игроков",
        Default = ESPModule.getSetting("ShowDistance"),
        Callback = function(value)
            ESPModule.updateSetting("ShowDistance", value)
        end
    })
    
    ESPTab:AddToggle("TeamCheck", {
        Title = "Team Check",
        Description = "Игнорировать союзников",
        Default = ESPModule.getSetting("TeamCheck"),
        Callback = function(value)
            ESPModule.updateSetting("TeamCheck", value)
        end
    })

    -- Секция: MM2 Роли
    ESPTab:AddSection("MM2 Роли")
    
    ESPTab:AddToggle("MM2RoleESP", {
        Title = "Определять роли",
        Description = "Показывать Murderer/Sheriff",
        Default = ESPModule.getSetting("MM2RoleESP"),
        Callback = function(value)
            ESPModule.updateSetting("MM2RoleESP", value)
        end
    })

    -- Секция: GunDrop ESP
    ESPTab:AddSection("GunDrop ESP")
    
    ESPTab:AddToggle("WeaponESP", {
        Title = "ESP оружия",
        Description = "Показывать оружие на земле",
        Default = ESPModule.getSetting("WeaponESP"),
        Callback = function(value)
            ESPModule.updateSetting("WeaponESP", value)
        end
    })

    -- Секция: Дистанция
    ESPTab:AddSection("Дистанция рендера")
    
    ESPTab:AddSlider("MaxRenderDistance", {
        Title = "Макс. дистанция",
        Description = "Максимальное расстояние отрисовки",
        Default = ESPModule.getSetting("MaxRenderDistance"),
        Min = 500,
        Max = 10000,
        Rounding = 0,
        Callback = function(value)
            ESPModule.updateSetting("MaxRenderDistance", value)
        end
    })

    -- ==================== ВКЛАДКА ВИЗУАЛ ====================
    local VisualTab = Window:AddTab({
        Title = "Визуал",
        Icon = "palette"
    })

    -- Секция: Цвета ESP
    VisualTab:AddSection("Цвета ESP")
    
    VisualTab:AddColorpicker("BoxColor", {
        Title = "Цвет рамок",
        Default = ESPModule.getSetting("BoxColor"),
        Callback = function(value)
            ESPModule.updateColor("BoxColor", value)
        end
    })
    
    VisualTab:AddColorpicker("TracerColor", {
        Title = "Цвет линий",
        Default = ESPModule.getSetting("TracerColor"),
        Callback = function(value)
            ESPModule.updateColor("TracerColor", value)
        end
    })
    
    VisualTab:AddColorpicker("NameColor", {
        Title = "Цвет имен",
        Default = ESPModule.getSetting("NameColor"),
        Callback = function(value)
            ESPModule.updateColor("NameColor", value)
        end
    })

    -- Секция: Настройки отображения
    VisualTab:AddSection("Настройки отображения")
    
    VisualTab:AddDropdown("TracerFrom", {
        Title = "Начало линий",
        Description = "Откуда идут трассеры",
        Default = ESPModule.getSetting("TracerFrom"),
        Values = {"Bottom", "Center", "Top"},
        Callback = function(value)
            ESPModule.updateSetting("TracerFrom", value)
        end
    })
    
    VisualTab:AddSlider("ReinitInterval", {
        Title = "Интервал обновления",
        Description = "Частота обновления ESP (сек)",
        Default = ESPModule.getSetting("ReinitInterval"),
        Min = 0.5,
        Max = 5,
        Rounding = 1,
        Callback = function(value)
            ESPModule.updateSetting("ReinitInterval", value)
        end
    })

    -- ==================== ВКЛАДКА АИМБОТ ====================
    local AimbotTab = Window:AddTab({
        Title = "Aimbot",
        Icon = "target"
    })

    if AimbotModule then
        AimbotTab:AddSection("Основные настройки")
        
        AimbotTab:AddToggle("AimbotEnabled", {
            Title = "Включить Aimbot",
            Description = "Активировать систему аимбота",
            Default = AimbotModule.getSetting and AimbotModule.getSetting("Enabled") or false,
            Callback = function(value)
                if AimbotModule.updateSetting then
                    AimbotModule.updateSetting("Enabled", value)
                end
            end
        })
        
        -- Добавьте другие настройки аимбота здесь
    else
        AimbotTab:AddSection("Информация")
        AimbotTab:AddParagraph({
            Title = "Aimbot не загружен",
            Content = "Модуль аимбота не был загружен или произошла ошибка."
        })
    end

    -- ==================== ВКЛАДКА ИНФО ====================
    local InfoTab = Window:AddTab({
        Title = "Информация",
        Icon = "info"
    })

    InfoTab:AddSection("О скрипте")
    
    InfoTab:AddParagraph({
        Title = "MM2 ESP Hub",
        Content = "Оптимизированный ESP для Murder Mystery 2\n\nФункции:\n• ESP игроков с Box, Tracer, Names\n• Определение ролей (Murderer/Sheriff)\n• GunDrop ESP (оптимизированный)\n• Aimbot с настройками\n• Красивый интерфейс\n\nУправление:\n• INSERT - скрыть/показать интерфейс\n• Настройки сохраняются автоматически"
    })

    InfoTab:AddSection("Управление")
    
    InfoTab:AddKeybind("ToggleKeybind", {
        Title = "Переключить UI",
        Mode = "Toggle",
        Default = "Insert",
        Callback = function(value)
            Window:Minimize()
        end
    })
    
    InfoTab:AddButton({
        Title = "Перезагрузить ESP",
        Description = "Перезагрузить систему ESP",
        Callback = function()
            -- Можно добавить функцию перезагрузки
            Fluent:Notify({
                Title = "MM2 ESP",
                Content = "ESP перезагружен!",
                SubContent = "Все настройки сохранены",
                Duration = 3
            })
        end
    })

    -- Включаем сохранение настроек
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({"ToggleKeybind"})
    
    InterfaceManager:BuildInterfaceSection(InfoTab)
    SaveManager:BuildConfigSection(InfoTab)

    -- Загружаем сохраненные настройки
    SaveManager:LoadAutoloadConfig()

    -- Уведомление о загрузке
    Fluent:Notify({
        Title = "MM2 ESP Hub",
        Content = "Скрипт успешно загружен!",
        SubContent = "Нажми INSERT для скрытия/показа интерфейса",
        Duration = 5
    })

    print("🎮 MM2 ESP Hub загружен!")
    print("📌 Нажми INSERT для скрытия/показа интерфейса")
    
    return Window
end
