-- Загрузка Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "My Exploit | Aimbot + ESP",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark"
})

-- Загрузка конфига и модулей (замени на свои raw ссылки после загрузки файлов)
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/config.lua"))()

local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/Aimbot.lua"))()
Aimbot.Init(Config, Window:AddTab({Title = "Aimbot"}))

local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/ESP.lua"))()
ESP.Init(Config, Window:AddTab({Title = "Visual"}))

Fluent:Notify({
    Title = "Exploit",
    Content = "Загружен успешно!",
    Duration = 5
})
