local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/4y6kX7kL"))()

local Window = OrionLib:MakeWindow({
    Name = "My Exploit | Aimbot + ESP",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MyExploit"
})

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

-- Загрузка твоих модулей (они уже работают, как показал тест)
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/config.lua"))()

local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/Aimbot.lua"))()
Aimbot.Init(Config, AimbotTab)

local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/ESP.lua"))()
ESP.Init(Config, VisualTab)

OrionLib:MakeNotification({
    Name = "Success",
    Content = "Exploit загружен! Нажми RightControl для скрытия окна",
    Time = 5
})
