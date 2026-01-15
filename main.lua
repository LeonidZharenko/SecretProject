-- main.lua (БЕЗ аимбота)
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/ESP.lua"))()

-- Передаем ESP и nil вместо аимбота
loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/Ui.lua"))(ESP, nil)
