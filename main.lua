local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "My Exploit | Aimbot + ESP"
})

local Config = loadstring(game:HttpGet("https://github.com/LeonidZharenko/SecretProject/blob/main/config.lua"))()

local Aimbot = loadstring(game:HttpGet("ТВОЯ_RAW_ССЫЛКА_НА_modules/Aimbot.lua"))()
Aimbot.Init(Config, Window:AddTab({Title = "Aimbot"}))

local ESP = loadstring(game:HttpGet("ТВОЯ_RAW_ССЫЛКА_НА_modules/ESP.lua"))()
ESP.Init(Config, Window:AddTab({Title = "Visual"}))

Fluent:Notify({
    Title = "Success",
    Content = "Exploit загружен!",
    Duration = 5
})
