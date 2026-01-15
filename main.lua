-- main.lua (МИНИМАЛЬНАЯ ВЕРСИЯ)
wait(1)

-- Создаем ESP объект
local ESP = {
    Settings = {
        ESPEnabled = true,
        BoxEnabled = true,
        TracerEnabled = true,
        NameEnabled = true,
        ShowDistance = true,
        TeamCheck = true,
        MM2RoleESP = false,
        WeaponESP = false,
        MaxRenderDistance = 5000,
    },
    updateSetting = function(key, value)
        ESP.Settings[key] = value
        print("Настройка изменена:", key, "=", value)
    end,
    getSetting = function(key)
        return ESP.Settings[key]
    end
}

-- Создаем простой UI
local player = game:GetService("Players").LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "MM2ESP"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 300)
frame.Position = UDim2.new(0.5, -125, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "MM2 ESP"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = frame

local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(1, -10, 1, -50)
container.Position = UDim2.new(0, 5, 0, 45)
container.BackgroundTransparency = 1
container.ScrollBarThickness = 4
container.AutomaticCanvasSize = Enum.AutomaticSize.Y
container.Parent = frame

-- Функция создания кнопок
local function makeButton(text, key, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, y)
    btn.BackgroundColor3 = ESP.getSetting(key) and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(80, 80, 100)
    btn.Text = text .. (ESP.getSetting(key) and " ✅" or " ❌")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = container
    
    btn.MouseButton1Click:Connect(function()
        local new = not ESP.getSetting(key)
        ESP.updateSetting(key, new)
        btn.BackgroundColor3 = new and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(80, 80, 100)
        btn.Text = text .. (new and " ✅" or " ❌")
    end)
    
    return y + 40
end

-- Создаем кнопки
local y = 0
y = makeButton("Включить ESP", "ESPEnabled", y)
y = makeButton("Box ESP", "BoxEnabled", y)
y = makeButton("Tracers", "TracerEnabled", y)
y = makeButton("Имена игроков", "NameEnabled", y)
y = makeButton("Показать дистанцию", "ShowDistance", y)
y = makeButton("Team Check", "TeamCheck", y)
y = makeButton("MM2 Роли", "MM2RoleESP", y)
y = makeButton("ESP GunDrop", "WeaponESP", y)

-- Бинд на INSERT
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        frame.Visible = not frame.Visible
    end
end)

print("✅ MM2 ESP загружен! Нажми INSERT")

-- Здесь вставьте ваш ESP код...
