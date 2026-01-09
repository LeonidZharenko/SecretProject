local Aimbot = {}

function Aimbot.Init(config, tab)
    Aimbot.Config = config.Aimbot

    tab:AddToggle({
        Title = "Aimbot Enabled",
        Default = false,
        Callback = function(value)
            Aimbot.Enabled = value
        end
    })

    tab:AddSlider({
        Title = "FOV Radius",
        Min = 50,
        Max = 600,
        Default = Aimbot.Config.fovRadius,
        Callback = function(value)
            Aimbot.Config.fovRadius = value
        end
    })

    tab:AddSlider({
        Title = "Smoothness",
        Min = 0.05,
        Max = 1,
        Default = Aimbot.Config.smoothness,
        Rounding = 2,
        Callback = function(value)
            Aimbot.Config.smoothness = value
        end
    })

    tab:AddDropdown({
        Title = "Target Part",
        Values = {"Head", "Torso", "Legs"},
        Default = Aimbot.Config.targetPart,
        Callback = function(value)
            Aimbot.Config.targetPart = value
        end
    })

    tab:AddToggle({
        Title = "Show FOV Circle",
        Default = false,
        Callback = function(value)
            Aimbot.Config.showFovCircle = value
        end
    })

    tab:AddToggle({
        Title = "Hold Target (RMB)",
        Default = false,
        Callback = function(value)
            Aimbot.Config.holdPkmMode = value
        end
    })

    tab:AddToggle({
        Title = "Wall Check",
        Default = true,
        Callback = function(value)
            Aimbot.Config.wallCheck = value
        end
    })

    tab:AddToggle({
        Title = "Full Target (Lock)",
        Default = false,
        Callback = function(value)
            Aimbot.Config.fullTarget = value
        end
    })

    -- Весь твой код аимбота (updateFovCircle, isValidTarget, isInFov, findNearestEnemy, цикл)
    -- Замени AIM_SETTINGS на Aimbot.Config

    local RunService = game:GetService("RunService")
    RunService.Heartbeat:Connect(function()
        if Aimbot.Enabled then
            -- твой цикл аимбота здесь (вставь из своего кода)
        end
    end)
end

return Aimbot
