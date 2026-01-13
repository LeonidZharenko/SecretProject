-- main.lua — полный рабочий вариант с красивым UI

print("Загрузка модулей...")

local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/Aimbot.lua"))()
print("Aimbot загружен")

local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeonidZharenko/SecretProject/main/modules/ESP.lua"))()
print("ESP загружен")

-- Запуск модулей
Aimbot.Init()
ESP.Init()

-- Красивый UI
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FluentLikeGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
}
UIGradient.Rotation = 90
UIGradient.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(60, 60, 80)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.5
UIStroke.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "My Exploit"
Title.TextColor3 = Color3.fromRGB(200, 200, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 28
Title.TextStrokeTransparency = 0.8
Title.Parent = MainFrame

-- Вкладки
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, 0, 0, 50)
TabFrame.Position = UDim2.new(0, 0, 0, 50)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

local AimbotTabBtn = Instance.new("TextButton")
AimbotTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
AimbotTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
AimbotTabBtn.Text = "Aimbot"
AimbotTabBtn.TextColor3 = Color3.new(1,1,1)
AimbotTabBtn.Font = Enum.Font.GothamBold
AimbotTabBtn.TextSize = 20
AimbotTabBtn.Parent = TabFrame

local AimbotCorner = Instance.new("UICorner")
AimbotCorner.CornerRadius = UDim.new(0, 12)
AimbotCorner.Parent = AimbotTabBtn

local ESPTabBtn = Instance.new("TextButton")
ESPTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
ESPTabBtn.Position = UDim2.new(0.5, 0, 0, 0)
ESPTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ESPTabBtn.Text = "ESP"
ESPTabBtn.TextColor3 = Color3.new(1,1,1)
ESPTabBtn.Font = Enum.Font.GothamBold
ESPTabBtn.TextSize = 20
ESPTabBtn.Parent = TabFrame

local ESPTabCorner = Instance.new("UICorner")
ESPTabCorner.CornerRadius = UDim.new(0, 12)
ESPTabCorner.Parent = ESPTabBtn

-- Контент
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -100)
ContentFrame.Position = UDim2.new(0, 0, 0, 100)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Вкладка Aimbot
local AimbotContent = Instance.new("Frame")
AimbotContent.Size = UDim2.new(1, 0, 1, 0)
AimbotContent.BackgroundTransparency = 1
AimbotContent.Visible = true
AimbotContent.Parent = ContentFrame

local AimbotToggle = Instance.new("TextButton")
AimbotToggle.Size = UDim2.new(0.8, 0, 0, 50)
AimbotToggle.Position = UDim2.new(0.1, 0, 0.1, 0)
AimbotToggle.BackgroundColor3 = Aimbot.Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
AimbotToggle.Text = "Aimbot: " .. (Aimbot.Enabled and "ON" or "OFF")
AimbotToggle.TextColor3 = Color3.new(1,1,1)
AimbotToggle.Font = Enum.Font.GothamBold
AimbotToggle.TextSize = 24
AimbotToggle.Parent = AimbotContent

local AimbotToggleCorner = Instance.new("UICorner")
AimbotToggleCorner.CornerRadius = UDim.new(0, 12)
AimbotToggleCorner.Parent = AimbotToggle

AimbotToggle.MouseButton1Click:Connect(function()
    Aimbot.Enabled = not Aimbot.Enabled
    AimbotToggle.Text = "Aimbot: " .. (Aimbot.Enabled and "ON" or "OFF")
    AimbotToggle.BackgroundColor3 = Aimbot.Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

-- Вкладка ESP (добавь больше настроек по желанию)
local ESPContent = Instance.new("Frame")
ESPContent.Size = UDim2.new(1, 0, 1, 0)
ESPContent.BackgroundTransparency = 1
ESPContent.Visible = false
ESPContent.Parent = ContentFrame

local ESPToggle = Instance.new("TextButton")
ESPToggle.Size = UDim2.new(0.8, 0, 0, 50)
ESPToggle.Position = UDim2.new(0.1, 0, 0.1, 0)
ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
ESPToggle.Text = "ESP: ON"  -- пока всегда ON, добавь переменную Enabled в ESP.lua
ESPToggle.TextColor3 = Color3.new(1,1,1)
ESPToggle.Font = Enum.Font.GothamBold
ESPToggle.TextSize = 24
ESPToggle.Parent = ESPContent

local ESPToggleCorner = Instance.new("UICorner")
ESPToggleCorner.CornerRadius = UDim.new(0, 12)
ESPToggleCorner.Parent = ESPToggle

ESPToggle.MouseButton1Click:Connect(function()
    -- Добавь в ESP.lua переменную ESP.Enabled = true/false
    -- ESP.Enabled = not ESP.Enabled
    ESPToggle.Text = "ESP: ON"  -- временно, добавь логику
end)

-- Переключение вкладок
AimbotTabBtn.MouseButton1Click:Connect(function()
    AimbotContent.Visible = true
    ESPContent.Visible = false
    AimbotTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    ESPTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
end)

ESPTabBtn.MouseButton1Click:Connect(function()
    AimbotContent.Visible = false
    ESPContent.Visible = true
    ESPTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    AimbotTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
end)

-- Скрытие/показ по INSERT
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("Exploit запущен! INSERT — скрыть/показать GUI")
