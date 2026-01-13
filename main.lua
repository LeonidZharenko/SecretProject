-- main.lua — полный рабочий вариант (inject'ь этот файл)

print("Загрузка модулей...")

-- Загрузка Aimbot
local AimbotSuccess, Aimbot = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/Aimbot.lua"))()
end)

if AimbotSuccess and Aimbot then
    print("Aimbot загружен")
else
    warn("Ошибка Aimbot: " .. tostring(Aimbot))
end

-- Загрузка ESP
local ESPSuccess, ESP = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/ESP.lua"))()
end)

if ESPSuccess and ESP then
    print("ESP загружен")
else
    warn("Ошибка ESP: " .. tostring(ESP))
end

-- Загрузка UI
local UISuccess, UI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/UI.lua"))()
end)

if UISuccess and UI then
    print("UI загружен")
else
    warn("Ошибка UI: " .. tostring(UI))
end

-- Инициализация (с pcall, чтобы не падало)
if Aimbot then
    pcall(Aimbot.Init)
end

if ESP then
    pcall(ESP.Init)
end

if UI and Aimbot and ESP then
    pcall(UI.Init, Aimbot, ESP)
else
    warn("UI не запустился — модули не все загружены")
end

print("Exploit запущен! INSERT — скрыть/показать UI")
