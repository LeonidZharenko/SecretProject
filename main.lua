-- main.lua — точка входа (inject'ишь только этот файл)

print("Загрузка модулей...")

-- Загрузка Aimbot
local AimbotSuccess, Aimbot = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/Aimbot.lua"))()
end)

if AimbotSuccess and Aimbot then
    Aimbot.Init()  -- если Init принимает аргументы — добавь, сейчас без
    print("Aimbot успешно загружен и инициализирован")
else
    warn("Ошибка загрузки Aimbot: " .. tostring(Aimbot))
end

-- Загрузка ESP
local ESPSuccess, ESP = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/ESP.lua"))()
end)

if ESPSuccess and ESP then
    ESP.Init()  -- если Init принимает аргументы — добавь
    print("ESP успешно загружен и инициализирован")
else
    warn("Ошибка загрузки ESP: " .. tostring(ESP))
end

print("Эксплойт запущен! Проверь работу Aimbot и ESP в игре.")
