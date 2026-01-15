-- modules/Ui.lua (упрощенная рабочая версия)
return function(ESPModule)
    print("🔄 Загрузка Fluent UI...")
    
    -- Загружаем Fluent
    local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/Source.lua"))()
    print("✅ Fluent загружен")
    
    -- Создаем окно
    local Window = Fluent:CreateWindow({
        Title = "MM2 ESP Hub",
        SubTitle = "by LeonidZharenko",
        TabWidth = 160,
        Size = UDim2.fromOffset(550, 400),
        Acrylic = false, -- На время отключаем эффекты для стабильности
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.Insert
    })
    
    print("✅ Окно создано")
    
    -- Вкладка ESP
    local ESPTab = Window:AddTab({
        Title = "ESP",
        Icon = "eye"
    })
    
    -- Основные настройки
    ESPTab:AddSection("Основные")
    ESPTab:AddToggle("ESPEnabled", {
        Title = "Включить ESP",
        Default = ESPModule.getSetting("ESPEnabled"),
        Callback = function(value)
            ESPModule.updateSetting("ESPEnabled", value)
        end
    })
    
    ESPTab:AddToggle("BoxEnabled", {
        Title = "Box ESP",
        Default = ESPModule.getSetting("BoxEnabled"),
        Callback = function(value)
            ESPModule.updateSetting("BoxEnabled", value)
        end
    })
    
    ESPTab:AddToggle("TracerEnabled", {
        Title = "Tracers",
        Default = ESPModule.getSetting("TracerEnabled"),
        Callback = function(value)
            ESPModule.updateSetting("TracerEnabled", value)
        end
    })
    
    ESPTab:AddToggle("NameEnabled", {
        Title = "Имена игроков",
        Default = ESPModule.getSetting("NameEnabled"),
        Callback = function(value)
            ESPModule.updateSetting("NameEnabled", value)
        end
    })
    
    ESPTab:AddToggle("ShowDistance", {
        Title = "Показывать дистанцию",
        Default = ESPModule.getSetting("ShowDistance"),
        Callback = function(value)
            ESPModule.updateSetting("ShowDistance", value)
        end
    })
    
    ESPTab:AddToggle("TeamCheck", {
        Title = "Team Check",
        Default = ESPModule.getSetting("TeamCheck"),
        Callback = function(value)
            ESPModule.updateSetting("TeamCheck", value)
        end
    })
    
    -- MM2 Роли
    ESPTab:AddSection("MM2 Роли")
    ESPTab:AddToggle("MM2RoleESP", {
        Title = "Определять роли",
        Default = ESPModule.getSetting("MM2RoleESP"),
        Callback = function(value)
            ESPModule.updateSetting("MM2RoleESP", value)
        end
    })
    
    -- GunDrop ESP
    ESPTab:AddSection("Оружие")
    ESPTab:AddToggle("WeaponESP", {
        Title = "ESP оружия",
        Default = ESPModule.getSetting("WeaponESP"),
        Callback = function(value)
            ESPModule.updateSetting("WeaponESP", value)
        end
    })
    
    -- Дистанция
    ESPTab:AddSection("Дистанция")
    ESPTab:AddSlider("MaxRenderDistance", {
        Title = "Макс. дистанция",
        Default = ESPModule.getSetting("MaxRenderDistance"),
        Min = 500,
        Max = 10000,
        Rounding = 0,
        Callback = function(value)
            ESPModule.updateSetting("MaxRenderDistance", value)
        end
    })
    
    -- Вкладка цветов
    local VisualTab = Window:AddTab({
        Title = "Цвета",
        Icon = "palette"
    })
    
    VisualTab:AddSection("Настройки цветов")
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
    
    -- Вкладка информации
    local InfoTab = Window:AddTab({
        Title = "Инфо",
        Icon = "info"
    })
    
    InfoTab:AddSection("Управление")
    InfoTab:AddKeybind("ToggleKeybind", {
        Title = "Скрыть/показать UI",
        Mode = "Toggle",
        Default = "Insert",
        Callback = function(value)
            Window:Minimize()
        end
    })
    
    InfoTab:AddParagraph({
        Title = "MM2 ESP Hub",
        Content = "Оптимизированный ESP для Murder Mystery 2\n\nНажми INSERT для скрытия/показа интерфейса"
    })
    
    -- Уведомление
    Fluent:Notify({
        Title = "MM2 ESP Hub",
        Content = "Скрипт успешно загружен!",
        SubContent = "Нажми INSERT для меню",
        Duration = 5
    })
    
    print("🎮 Интерфейс загружен!")
    return Window
end
