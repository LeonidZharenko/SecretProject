-- main.lua - ДЕБАГ версия
print("=== НАЧАЛО ЗАГРУЗКИ ===")

-- Ждем игрока
while not game:GetService("Players").LocalPlayer do
    wait()
end

local player = game:GetService("Players").LocalPlayer
print("Игрок:", player.Name)

-- Ждем PlayerGui
if not player:FindFirstChild("PlayerGui") then
    player:WaitForChild("PlayerGui")
end
print("PlayerGui загружен")

-- Загружаем ESP
print("Загружаем ESP модуль...")
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/ESP.lua"))()
print("ESP загружен. Тип:", typeof(ESP))
print("ESP имеет updateSetting?", ESP.updateSetting ~= nil)

-- Загружаем и выполняем UI
print("Загружаем UI модуль...")
local uiCode = game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/Ui.lua")
print("Длина UI кода:", #uiCode)

local uiFunc = loadstring(uiCode)
print("UI функция загружена:", uiFunc ~= nil)

print("Вызываем UI функцию...")
local success, err = pcall(uiFunc, ESP)
if not success then
    warn("ОШИБКА при вызове UI:", err)
else
    print("✅ UI успешно вызван!")
end

print("=== ЗАГРУЗКА ЗАВЕРШЕНА ===")
