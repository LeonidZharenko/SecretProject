-- main.lua (ДЕТАЛЬНАЯ ВЕРСИЯ)
print("=== НАЧАЛО ЗАГРУЗКИ MM2 ESP ===")

-- Ждем полной загрузки
wait(2)

-- Проверяем сервисы
local Players = game:GetService("Players")
local player = Players.LocalPlayer

if not player then
    print("⚠️ Игрок не найден, ждем...")
    player = Players.PlayerAdded:Wait()
end

print("✅ Игрок:", player.Name)

-- Ждем PlayerGui
if not player:WaitForChild("PlayerGui", 5) then
    warn("❌ PlayerGui не загрузился!")
    return
end

print("✅ PlayerGui загружен")

-- Загружаем ESP
print("📥 Загружаем ESP модуль...")
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/ESP.lua"))()
print("✅ ESP модуль загружен")

-- Проверяем функции ESP
if not ESP then
    warn("❌ ESP модуль вернул nil")
    return
end

if not ESP.updateSetting then
    warn("❌ ESP.updateSetting не найдена")
end

if not ESP.getSetting then
    warn("❌ ESP.getSetting не найдена")
end

print("✅ Функции ESP проверены")

-- Загружаем UI
print("📥 Загружаем UI модуль...")
local uiCode = game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/Ui.lua")
print("✅ Код UI получен, длина:", #uiCode)

-- Выполняем UI
local uiFunc = loadstring(uiCode)
if not uiFunc then
    warn("❌ Не удалось загрузить функцию UI")
    return
end

print("✅ UI функция загружена")

-- Вызываем UI
local success, window = pcall(uiFunc, ESP)
if not success then
    warn("❌ Ошибка при вызове UI функции:", window)
    return
end

if window then
    print("✅ UI функция вернула окно")
else
    warn("⚠️ UI функция вернула nil")
end

print("=== ЗАГРУЗКА ЗАВЕРШЕНА ===")
print("🎮 Нажмите INSERT для показа/скрытия меню")
