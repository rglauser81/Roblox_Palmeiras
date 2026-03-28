-- FootballClient.client.lua
-- ⚽ Cliente do sistema de futebol: carga do chute, power meter, efeitos de gol

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui   = localPlayer:WaitForChild("PlayerGui")
local camera      = workspace.CurrentCamera

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Remotes    = ReplicatedStorage:WaitForChild("Remotes")
local FB         = GameConfig.FOOTBALL

-- ============================================================
-- GUI: Power Meter (barra de carga do chute)
-- ============================================================

local footballGui = Instance.new("ScreenGui")
footballGui.Name           = "FootballGui"
footballGui.ResetOnSpawn   = false
footballGui.IgnoreGuiInset = true
footballGui.Parent         = playerGui

-- Mira central (crosshair de chute)
local crosshair = Instance.new("ImageLabel")
crosshair.Name               = "Crosshair"
crosshair.Size               = UDim2.new(0, 40, 0, 40)
crosshair.Position           = UDim2.new(0.5, -20, 0.5, -20)
crosshair.BackgroundTransparency = 1
crosshair.Image              = "rbxassetid://6764432293" -- crosshair genérico
crosshair.ImageColor3        = Color3.fromRGB(255, 255, 255)
crosshair.ImageTransparency  = 0.3
crosshair.Visible            = false
crosshair.Parent             = footballGui

-- Power meter container
local meterBg = Instance.new("Frame")
meterBg.Name               = "PowerMeterBg"
meterBg.Size               = UDim2.new(0, 12, 0, 120)
meterBg.Position           = UDim2.new(0.5, 30, 0.5, -60)
meterBg.BackgroundColor3   = Color3.fromRGB(30, 30, 30)
meterBg.BackgroundTransparency = 0.3
meterBg.BorderSizePixel    = 0
meterBg.Visible            = false
meterBg.Parent             = footballGui
Instance.new("UICorner", meterBg).CornerRadius = UDim.new(0, 6)

local meterFill = Instance.new("Frame")
meterFill.Name             = "Fill"
meterFill.Size             = UDim2.new(1, 0, 0, 0)
meterFill.Position         = UDim2.new(0, 0, 1, 0)
meterFill.AnchorPoint      = Vector2.new(0, 1)
meterFill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
meterFill.BorderSizePixel  = 0
meterFill.Parent           = meterBg
Instance.new("UICorner", meterFill).CornerRadius = UDim.new(0, 6)

-- Power label
local meterLabel = Instance.new("TextLabel")
meterLabel.Name             = "PowerLabel"
meterLabel.Size             = UDim2.new(0, 60, 0, 24)
meterLabel.Position         = UDim2.new(0.5, 50, 0.5, -12)
meterLabel.BackgroundTransparency = 1
meterLabel.Text             = ""
meterLabel.TextColor3       = Color3.fromRGB(255, 255, 255)
meterLabel.Font             = Enum.Font.GothamBold
meterLabel.TextSize         = 14
meterLabel.Visible          = false
meterLabel.Parent           = footballGui

-- ── GOL! Popup ─────────────────────────────────────────────
local golPopup = Instance.new("TextLabel")
golPopup.Name               = "GolPopup"
golPopup.Size               = UDim2.new(0, 500, 0, 120)
golPopup.Position           = UDim2.new(0.5, -250, 0.4, -60)
golPopup.BackgroundTransparency = 1
golPopup.Text               = "⚽ GOOOOL! ⚽"
golPopup.TextColor3         = Color3.fromRGB(255, 215, 0)
golPopup.Font               = Enum.Font.GothamBold
golPopup.TextSize           = 64
golPopup.TextStrokeTransparency = 0
golPopup.TextStrokeColor3   = Color3.fromRGB(0, 0, 0)
golPopup.Visible            = false
golPopup.Parent             = footballGui

-- ── Desafio de Gol: painel ─────────────────────────────────
local challengePanel = Instance.new("Frame")
challengePanel.Name               = "GoalChallengePanel"
challengePanel.Size               = UDim2.new(0, 260, 0, 100)
challengePanel.Position           = UDim2.new(0.5, -130, 0, 160)
challengePanel.BackgroundColor3   = Color3.fromRGB(0, 50, 0)
challengePanel.BackgroundTransparency = 0.2
challengePanel.BorderSizePixel    = 0
challengePanel.Visible            = false
challengePanel.Parent             = footballGui
Instance.new("UICorner", challengePanel).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", challengePanel).Color = Color3.fromRGB(0, 200, 0)

local challengeTitle = Instance.new("TextLabel")
challengeTitle.Size             = UDim2.new(1, 0, 0, 30)
challengeTitle.BackgroundTransparency = 1
challengeTitle.Text             = "⚽ DESAFIO DE GOL ⚽"
challengeTitle.TextColor3       = Color3.fromRGB(255, 215, 0)
challengeTitle.Font             = Enum.Font.GothamBold
challengeTitle.TextSize         = 18
challengeTitle.Parent           = challengePanel

local challengeGoals = Instance.new("TextLabel")
challengeGoals.Name             = "Goals"
challengeGoals.Size             = UDim2.new(0.5, 0, 0, 30)
challengeGoals.Position         = UDim2.new(0, 8, 0, 34)
challengeGoals.BackgroundTransparency = 1
challengeGoals.Text             = "Gols: 0"
challengeGoals.TextColor3       = Color3.fromRGB(100, 255, 100)
challengeGoals.Font             = Enum.Font.GothamBold
challengeGoals.TextSize         = 20
challengeGoals.TextXAlignment   = Enum.TextXAlignment.Left
challengeGoals.Parent           = challengePanel

local challengeTimer = Instance.new("TextLabel")
challengeTimer.Name             = "Timer"
challengeTimer.Size             = UDim2.new(0.5, -8, 0, 30)
challengeTimer.Position         = UDim2.new(0.5, 0, 0, 34)
challengeTimer.BackgroundTransparency = 1
challengeTimer.Text             = "⏱ 18s"
challengeTimer.TextColor3       = Color3.fromRGB(255, 200, 100)
challengeTimer.Font             = Enum.Font.GothamBold
challengeTimer.TextSize         = 20
challengeTimer.TextXAlignment   = Enum.TextXAlignment.Right
challengeTimer.Parent           = challengePanel

local challengeCombo = Instance.new("TextLabel")
challengeCombo.Name             = "Combo"
challengeCombo.Size             = UDim2.new(1, 0, 0, 24)
challengeCombo.Position         = UDim2.new(0, 0, 0, 68)
challengeCombo.BackgroundTransparency = 1
challengeCombo.Text             = ""
challengeCombo.TextColor3       = Color3.fromRGB(255, 150, 50)
challengeCombo.Font             = Enum.Font.GothamBold
challengeCombo.TextSize         = 16
challengeCombo.Parent           = challengePanel

-- ── Hit Marker (ao acertar mob) ────────────────────────────
local hitMarker = Instance.new("TextLabel")
hitMarker.Name               = "HitMarker"
hitMarker.Size               = UDim2.new(0, 120, 0, 30)
hitMarker.Position           = UDim2.new(0.5, -60, 0.5, 30)
hitMarker.BackgroundTransparency = 1
hitMarker.Text               = ""
hitMarker.TextColor3         = Color3.fromRGB(255, 80, 80)
hitMarker.Font               = Enum.Font.GothamBold
hitMarker.TextSize           = 18
hitMarker.TextStrokeTransparency = 0.3
hitMarker.Visible            = false
hitMarker.Parent             = footballGui

-- ============================================================
-- Lógica de chute (carga)
-- ============================================================

local isCharging = false
local chargeStart = 0
local isToolEquipped = false
local chargeConnection = nil

local function getChargeLevel()
    if not isCharging then return 0 end
    local elapsed = tick() - chargeStart
    return math.clamp(elapsed / FB.CHARGE_TIME, 0, 1)
end

local function updatePowerMeter()
    local charge = getChargeLevel()
    local height = charge * 120

    meterFill.Size = UDim2.new(1, 0, 0, height)

    -- Cor: verde → amarelo → vermelho
    local r = math.floor(charge * 255)
    local g = math.floor((1 - charge * 0.7) * 255)
    meterFill.BackgroundColor3 = Color3.fromRGB(r, g, 0)

    if charge >= 0.95 then
        meterLabel.Text = "MAX!"
        meterLabel.TextColor3 = Color3.fromRGB(255, 80, 0)
    else
        meterLabel.Text = math.floor(charge * 100) .. "%"
        meterLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

local function startCharge()
    if isCharging then return end
    isCharging = true
    chargeStart = tick()
    meterBg.Visible = true
    meterLabel.Visible = true

    if chargeConnection then chargeConnection:Disconnect() end
    chargeConnection = RunService.RenderStepped:Connect(function()
        if isCharging then
            updatePowerMeter()
        end
    end)
end

local function releaseKick()
    if not isCharging then return end

    local charge = getChargeLevel()
    isCharging = false
    meterBg.Visible = false
    meterLabel.Visible = false

    if chargeConnection then
        chargeConnection:Disconnect()
        chargeConnection = nil
    end

    -- Reset meter
    meterFill.Size = UDim2.new(1, 0, 0, 0)

    -- Calcula direção: para onde o player está olhando (camera lookVector)
    local direction = camera.CFrame.LookVector

    -- Envia para o servidor
    Remotes.KickBall:FireServer(direction, charge)

    -- Feedback local: recoil visual leve
    local character = localPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Animação de chute rápida (piscar o FOV)
            local origFOV = camera.FieldOfView
            TweenService:Create(camera, TweenInfo.new(0.05), { FieldOfView = origFOV + 3 }):Play()
            task.delay(0.05, function()
                TweenService:Create(camera, TweenInfo.new(0.1), { FieldOfView = origFOV }):Play()
            end)
        end
    end
end

-- ============================================================
-- Detecta equipar/desequipar da Chuteira
-- ============================================================

local function onToolEquipped()
    isToolEquipped = true
    crosshair.Visible = true
end

local function onToolUnequipped()
    isToolEquipped = false
    crosshair.Visible = false
    -- Cancela carga se estava carregando
    if isCharging then
        isCharging = false
        meterBg.Visible = false
        meterLabel.Visible = false
        if chargeConnection then chargeConnection:Disconnect(); chargeConnection = nil end
    end
end

local function watchForTool(character)
    for _, child in character:GetChildren() do
        if child:IsA("Tool") and (child.Name:match("Chuteira") or child.Name:match("Palmeiras")) then
            child.Equipped:Connect(onToolEquipped)
            child.Unequipped:Connect(onToolUnequipped)
        end
    end
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and (child.Name:match("Chuteira") or child.Name:match("Palmeiras")) then
            child.Equipped:Connect(onToolEquipped)
            child.Unequipped:Connect(onToolUnequipped)
        end
    end)
end

-- Input: mouse down = start charge, mouse up = kick
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not isToolEquipped then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        startCharge()
    end
end)

UserInputService.InputEnded:Connect(function(input, _gameProcessed)
    if not isToolEquipped then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        releaseKick()
    end
end)

-- ============================================================
-- Efeitos visuais: BallHitMob
-- ============================================================

Remotes:WaitForChild("BallHitMob").OnClientEvent:Connect(function(mobName, damage)
    hitMarker.Text = "-" .. math.floor(damage) .. " " .. mobName
    hitMarker.Visible = true
    hitMarker.TextTransparency = 0
    hitMarker.Position = UDim2.new(0.5, -60 + math.random(-20, 20), 0.5, 20 + math.random(-10, 10))

    local tween = TweenService:Create(hitMarker, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 1,
        Position = hitMarker.Position + UDim2.new(0, 0, 0, -30),
    })
    tween:Play()
    tween.Completed:Connect(function()
        hitMarker.Visible = false
    end)
end)

-- ============================================================
-- Desafio de Gol: UI
-- ============================================================

local goalCount = 0
local challengeActive = false

Remotes:WaitForChild("GoalChallengeStart").OnClientEvent:Connect(function(duration)
    challengeActive = true
    goalCount = 0
    challengePanel.Visible = true
    challengeGoals.Text = "Gols: 0"
    challengeCombo.Text = "Chute no gol para ganhar coins!"

    -- Countdown do timer
    task.spawn(function()
        for i = duration, 1, -1 do
            if not challengeActive then break end
            challengeTimer.Text = "⏱ " .. i .. "s"
            if i <= 5 then
                challengeTimer.TextColor3 = Color3.fromRGB(255, 80, 80)
            else
                challengeTimer.TextColor3 = Color3.fromRGB(255, 200, 100)
            end
            task.wait(1)
        end
    end)
end)

Remotes:WaitForChild("GoalScored").OnClientEvent:Connect(function(coins, combo)
    goalCount += 1
    challengeGoals.Text = "Gols: " .. goalCount

    if combo > 1 then
        challengeCombo.Text = "🔥 COMBO x" .. combo .. "! +" .. coins .. " coins"
        challengeCombo.TextColor3 = Color3.fromRGB(255, math.max(0, 200 - combo * 30), 0)
    else
        challengeCombo.Text = "+" .. coins .. " coins"
        challengeCombo.TextColor3 = Color3.fromRGB(255, 215, 0)
    end

    -- GOL! popup
    golPopup.Visible = true
    golPopup.TextTransparency = 0
    golPopup.TextSize = 64

    local scaleUp = TweenService:Create(golPopup, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        TextSize = 80,
    })
    scaleUp:Play()
    scaleUp.Completed:Connect(function()
        local fadeOut = TweenService:Create(golPopup, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            TextTransparency = 1,
            TextSize = 50,
        })
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            golPopup.Visible = false
        end)
    end)
end)

Remotes:WaitForChild("GoalChallengeEnd").OnClientEvent:Connect(function(totalGoals, totalCoins)
    challengeActive = false
    challengePanel.Visible = false

    if totalGoals > 0 then
        -- Mostra resultado final
        golPopup.Text = "🏆 " .. totalGoals .. " gols = " .. totalCoins .. " coins!"
        golPopup.TextColor3 = Color3.fromRGB(100, 255, 150)
        golPopup.Visible = true
        golPopup.TextTransparency = 0
        golPopup.TextSize = 40

        task.delay(3, function()
            TweenService:Create(golPopup, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
            task.delay(0.5, function()
                golPopup.Visible = false
                golPopup.Text = "⚽ GOOOOL! ⚽"
                golPopup.TextColor3 = Color3.fromRGB(255, 215, 0)
            end)
        end)
    end
end)

-- ============================================================
-- Init: vincula a ferramenta
-- ============================================================

localPlayer.CharacterAdded:Connect(function(character)
    task.wait(1)
    watchForTool(character)
end)

if localPlayer.Character then
    task.spawn(function()
        watchForTool(localPlayer.Character)
    end)
end

-- Também monitora o backpack
local backpack = localPlayer:WaitForChild("Backpack")
backpack.ChildAdded:Connect(function(child)
    if child:IsA("Tool") and child.Name:match("Chuteira") then
        child.Equipped:Connect(onToolEquipped)
        child.Unequipped:Connect(onToolUnequipped)
    end
end)
