-- main.lua — запускает всё

print("Загрузка модулей...")

local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/Aimbot.lua"))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/ESP.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/UI.lua"))()

print("Модули загружены")

Aimbot.Init()
ESP.Init()
UI.Init(Aimbot, ESP)

print("Exploit полностью запущен! INSERT — скрыть/показать GUI")
