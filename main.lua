local Players = game:GetService("Players")
while not Players.LocalPlayer do wait() end

-- 1 строка для ESP
loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/ESP.lua"))()

-- 2 строка для Aimbot (опционально)
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/ваш_юзернейм/mm2-esp/main/modules/aimbot.lua"))()
