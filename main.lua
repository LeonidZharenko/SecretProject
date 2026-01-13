-- Orion Lib вместо Fluent (работает, где Fluent блочат)
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Window = OrionLib:MakeWindow({
    Name = "My Exploit | Aimbot + ESP",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MyExploit"
})

-- Tabs
local AimbotTab = Window:MakeTab({
    Name = "Aimbot",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local VisualTab = Window:MakeTab({
    Name = "Visual",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Загрузка конфига
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/config.lua"))()

-- Aimbot модуль
local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/Aimbot.lua"))()
Aimbot.Init(Config, AimbotTab)  -- передаём вкладку Orion

-- ESP модуль
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/ESP.lua"))()
ESP.Init(Config, VisualTab)  -- передаём вкладку Orion

OrionLib:MakeNotification({
    Name = "Success",
    Content = "Exploit загружен! Нажми RightControl для скрытия окна",
    Time = 5
})
