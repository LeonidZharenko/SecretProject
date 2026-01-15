-- main.lua (самая простая версия)
wait(2) -- Ждем загрузку игры

local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/ESP.lua"))()

-- Загружаем UI (без аимбота)
loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/Ui.lua"))(ESP)
