-- modules/Ui.lua (ДЕБАГ версия)
return function(ESPModule)
    print("🔄 Начинаю загрузку Fluent UI...")
    
    -- Пробуем загрузить Fluent
    local success, fluent = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/Source.lua"))()
    end)
    
    if not success then
        warn("❌ Не удалось загрузить Fluent библиотеку")
        -- Попробуем альтернативный источник
        fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Source.lua"))()
    end
    
    if not fluent then
        warn("❌ Fluent не загрузился вообще")
        return nil
    end
    
    print("✅ Fluent загружен успешно")
    
    -- Создаем окно с БЕЗ эффектов
    local Window = fluent:CreateWindow({
        Title = "MM2 ESP Hub",
        SubTitle = "Тестовая версия",
        TabWidth = 160,
        Size = UDim2.fromOffset(500, 350),
        Acrylic = false, -- ОТКЛЮЧАЕМ эффекты
        Transparency = 0,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.Insert
    })
    
    print("✅ Окно создано")
    
    -- Создаем простую вкладку
    local Tab = Window:AddTab({
        Title = "ESP",
        Icon = "eye"
    })
    
    Tab:AddSection("Тест")
    Tab:AddToggle("TestToggle", {
        Title = "Тестовая кнопка",
        Default = false,
        Callback = function(value)
            print("Тестовая кнопка:", value)
        end
    })
    
    Tab:AddButton({
        Title = "Тестовая кнопка",
        Callback = function()
            print("Кнопка нажата!")
            fluent:Notify({
                Title = "Тест",
                Content = "Уведомление работает!",
                Duration = 3
            })
        end
    })
    
    -- Сразу показываем окно
    Window:Show()
    
    print("✅ UI полностью создан и показан")
    print("📌 Если не видно окно, нажмите INSERT")
    
    return Window
end
