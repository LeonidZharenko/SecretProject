-- modules/Ui.lua (обновленная версия)
return function(ESPModule, AimbotModule)
    local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/Source.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

    local Window = Fluent:CreateWindow({
        Title = "MM2 ESP Hub | v2.0",
        SubTitle = "by LeonidZharenko",
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

    ESPTab:AddSection("Основные настройки")
    ESPTab:AddToggle("ESPEnabled", {
        Title = "Включить ESP",
        Default = ESPModule.getSetting("ESPEnabled"),
        Callback = function(value) ESPModule.updateSetting("ESPEnabled", value) end
    })
    
    ESPTab:AddToggle("BoxEnabled", {
        Title = "Box ESP",
        Default = ESPModule.getSetting("BoxEnabled"),
        Callback = function(value) ESPModule.updateSetting("BoxEnabled", value) end
    })
    
    ESPTab:AddToggle("TracerEnabled", {
        Title = "Tracers",
        Default = ESPModule.getSetting("TracerEnabled"),
        Callback = function(value) ESPModule.updateSetting("TracerEnabled", value) end
    })
    
    ESPTab:AddToggle("NameEnabled", {
        Title = "Имена игроков",
        Default = ESPModule.getSetting("NameEnabled"),
        Callback = function(value) ESPModule.updateSetting("NameEnabled", value) end
    })
    
    ESPTab:AddToggle("ShowDistance", {
        Title = "Показывать дистанцию",
        Default = ESPModule.getSetting("ShowDistance"),
        Callback = function(value) ESPModule.updateSetting("ShowDistance", value) end
    })
    
    ESPTab:AddToggle("TeamCheck", {
        Title = "Team Check",
        Default = ESPModule.getSetting("TeamCheck"),
        Callback = function(value) ESPModule.updateSetting("TeamCheck", value) end
    })

    ESPTab:AddSection("MM2 Роли")
    ESPTab:AddToggle("MM2RoleESP", {
        Title = "Определять роли",
        Default = ESPModule.getSetting("MM2RoleESP"),
        Callback = function(value) ESPModule.updateSetting("MM2RoleESP", value) end
    })

    ESPTab:AddSection("GunDrop ESP")
    ESPTab:AddToggle("WeaponESP", {
        Title = "ESP оружия",
        Default = ESPModule.getSetting("WeaponESP"),
        Callback = function(value) ESPModule.updateSetting("WeaponESP", value) end
    })

    ESPTab:AddSection("Дистанция рендера")
    ESPTab:AddSlider("MaxRenderDistance", {
        Title = "Макс. дистанция",
        Default = ESPModule.getSetting("MaxRenderDistance"),
        Min = 500,
        Max = 10000,
        Rounding = 0,
        Callback = function(value) ESPModule.updateSetting("MaxRenderDistance", value) end
    })

    -- ==================== ВКЛАДКА ВИЗУАЛ ====================
    local VisualTab = Window:AddTab({
        Title = "Визуал",
        Icon = "palette"
    })

    VisualTab:AddSection("Цвета ESP")
    VisualTab:AddColorpicker("BoxColor", {
        Title = "Цвет рамок",
        Default = ESPModule.getSetting("BoxColor"),
        Callback = function(value) ESPModule.updateColor("BoxColor", value) end
    })
    
    VisualTab:AddColorpicker("TracerColor", {
        Title = "Цвет линий",
        Default = ESPModule.getSetting("TracerColor"),
        Callback = function(value) ESPModule.updateColor("TracerColor", value) end
    })
    
    VisualTab:AddColorpicker("NameColor", {
        Title = "Цвет имен",
        Default = ESPModule.getSetting("NameColor"),
        Callback = function(value) ESPModule.updateColor("NameColor", value) end
    })

    -- ==================== ВКЛАДКА АИМБОТ (если есть) ====================
    if AimbotModule then
        local AimbotTab = Window:AddTab({
            Title = "Aimbot",
            Icon = "target"
        })
        
        AimbotTab:AddSection("Настройки аимбота")
        AimbotTab:AddToggle("AimbotEnabled", {
            Title = "Включить Aimbot",
            Default = AimbotModule.getSetting and AimbotModule.getSetting("Enabled") or false,
            Callback = function(value)
                if AimbotModule.updateSetting then
                    AimbotModule.updateSetting("Enabled", value)
                end
            end
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
        Content = "Оптимизированный ESP для Murder Mystery 2"
    })

    InfoTab:AddSection("Управление")
    InfoTab:AddKeybind("ToggleKeybind", {
        Title = "Переключить UI",
        Mode = "Toggle",
        Default = "Insert",
        Callback = function(value) Window:Minimize() end
    })

    -- Сохранение настроек
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:IgnoreThemeSettings()
    InterfaceManager:BuildInterfaceSection(InfoTab)
    SaveManager:BuildConfigSection(InfoTab)
    SaveManager:LoadAutoloadConfig()

    Fluent:Notify({
        Title = "MM2 ESP Hub",
        Content = "Скрипт успешно загружен!",
        Duration = 5
    })

    return Window
end
