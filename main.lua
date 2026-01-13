-- Universal Aimbot & ESP with Fluent UI (твой функционал)

local Library = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Library:CreateWindow({
    Title = "My Exploit | Aimbot + ESP",
    SubTitle = "by Steam",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Darker",
    AccentColor = Color3.fromRGB(255, 165, 0),
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Вкладки
local Tabs = {
    Main = Window:AddTab({ Title = "Welcome!", Icon = "home" }),
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "crosshair" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

-- Приветствие
local playerName = game.Players.LocalPlayer.Name
Tabs.Main:AddParagraph({
    Title = "Добро пожаловать, " .. playerName .. "!",
    Content = "Это твой универсальный Aimbot + ESP. Настройки сохраняются автоматически."
})

-- Загрузка модулей (твои Aimbot и ESP)
local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/Aimbot.lua"))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/ESP.lua"))()

-- Инициализация
Aimbot.Init()
ESP.Init()

-- Aimbot настройки в UI
Tabs.Aimbot:AddToggle("AimbotEnabled", {
    Title = "Aimbot Enabled",
    Description = "Вкл/выкл аимбот",
    Default = false,
    Callback = function(value)
        Aimbot.Enabled = value
        -- Обнови status label если есть
    end
})

Tabs.Aimbot:AddSlider("FOVRadius", {
    Title = "FOV Radius",
    Description = "Радиус поля зрения",
    Min = 50,
    Max = 600,
    Default = 150,
    Rounding = 0,
    Callback = function(value)
        Aimbot.Config.fovRadius = value
    end
})

Tabs.Aimbot:AddSlider("Smoothness", {
    Title = "Smoothness",
    Description = "Плавность аима",
    Min = 0.05,
    Max = 1,
    Default = 0.12,
    Rounding = 2,
    Callback = function(value)
        Aimbot.Config.smoothness = value
    end
})

Tabs.Aimbot:AddDropdown("TargetPart", {
    Title = "Target Part",
    Description = "Цель аима",
    Values = {"Head", "Torso", "Legs"},
    Default = 1,
    Callback = function(value)
        Aimbot.Config.targetPart = value
    end
})

Tabs.Aimbot:AddToggle("ShowFOV", {
    Title = "Show FOV Circle",
    Default = false,
    Callback = function(value)
        Aimbot.Config.showFovCircle = value
    end
})

Tabs.Aimbot:AddToggle("HoldTarget", {
    Title = "Hold Target (RMB)",
    Default = false,
    Callback = function(value)
        Aimbot.Config.holdPkmMode = value
    end
})

Tabs.Aimbot:AddToggle("WallCheck", {
    Title = "Wall Check",
    Default = true,
    Callback = function(value)
        Aimbot.Config.wallCheck = value
    end
})

Tabs.Aimbot:AddToggle("FullTarget", {
    Title = "Full Target (Lock)",
    Default = false,
    Callback = function(value)
        Aimbot.Config.fullTarget = value
    end
})

-- ESP настройки в UI
Tabs.ESP:AddToggle("ESPGlobal", {
    Title = "ESP Global",
    Description = "Вкл/выкл весь ESP",
    Default = true,
    Callback = function(value)
        ESP.Enabled = value  -- добавь в ESP.lua переменную ESP.Enabled
    end
})

Tabs.ESP:AddToggle("ESPBoxes", {
    Title = "Box ESP",
    Default = true,
    Callback = function(value)
        ESP.Config.BoxEnabled = value
    end
})

Tabs.ESP:AddToggle("ESPTracers", {
    Title = "Tracers",
    Default = true,
    Callback = function(value)
        ESP.Config.TracerEnabled = value
    end
})

Tabs.ESP:AddToggle("ESPNames", {
    Title = "Names",
    Default = true,
    Callback = function(value)
        ESP.Config.NameEnabled = value
    end
})

Tabs.ESP:AddToggle("ESPDistance", {
    Title = "Distance",
    Default = true,
    Callback = function(value)
        ESP.Config.ShowDistance = value
    end
})

Tabs.ESP:AddToggle("ESPTeamCheck", {
    Title = "Team Check",
    Default = true,
    Callback = function(value)
        ESP.Config.TeamCheck = value
    end
})

Tabs.ESP:AddSlider("ESPMaxDist", {
    Title = "Max Render Distance",
    Min = 100,
    Max = 10000,
    Default = 5000,
    Callback = function(value)
        ESP.Config.MaxRenderDistance = value
    end
})

-- Сохранение настроек
SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentMyExploit")
SaveManager:SetFolder("FluentMyExploit/saves")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()

print("Exploit полностью загружен! Используй LeftControl для скрытия окна.")
