-- MinigameClient.client.lua
-- UI do cliente para mini-games: mostra timer, instrucoes, progresso e resultado

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- ============================================================
-- Cria GUI do minigame
-- ============================================================

local mgGui = Instance.new("ScreenGui")
mgGui.Name = "MinigameGui"
mgGui.ResetOnSpawn = false
mgGui.IgnoreGuiInset = true
mgGui.Parent = playerGui

-- Painel principal (aparece durante minigame)
local panel = Instance.new("Frame")
panel.Name = "MinigamePanel"
panel.Size = UDim2.new(0, 320, 0, 140)
panel.Position = UDim2.new(0.5, -160, 0, 150)
panel.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
panel.BackgroundTransparency = 0.2
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = mgGui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", panel).Color = Color3.fromRGB(0, 200, 150)

-- Nome do minigame
local nameLabel = Instance.new("TextLabel")
nameLabel.Name = "MgName"
nameLabel.Size = UDim2.new(1, -16, 0, 28)
nameLabel.Position = UDim2.new(0, 8, 0, 8)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "Mini-Game"
nameLabel.TextColor3 = Color3.fromRGB(0, 255, 180)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextSize = 20
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Parent = panel

-- Descricao
local descLabel = Instance.new("TextLabel")
descLabel.Name = "MgDesc"
descLabel.Size = UDim2.new(1, -16, 0, 22)
descLabel.Position = UDim2.new(0, 8, 0, 38)
descLabel.BackgroundTransparency = 1
descLabel.Text = ""
descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
descLabel.Font = Enum.Font.Gotham
descLabel.TextSize = 14
descLabel.TextXAlignment = Enum.TextXAlignment.Left
descLabel.Parent = panel

-- Timer
local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "Timer"
timerLabel.Size = UDim2.new(1, -16, 0, 30)
timerLabel.Position = UDim2.new(0, 8, 0, 64)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "00:00"
timerLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
timerLabel.Font = Enum.Font.GothamBold
timerLabel.TextSize = 26
timerLabel.TextXAlignment = Enum.TextXAlignment.Center
timerLabel.Parent = panel

-- Progresso / Score
local scoreLabel = Instance.new("TextLabel")
scoreLabel.Name = "Score"
scoreLabel.Size = UDim2.new(1, -16, 0, 24)
scoreLabel.Position = UDim2.new(0, 8, 0, 98)
scoreLabel.BackgroundTransparency = 1
scoreLabel.Text = ""
scoreLabel.TextColor3 = Color3.fromRGB(255, 150, 50)
scoreLabel.Font = Enum.Font.GothamBold
scoreLabel.TextSize = 16
scoreLabel.TextXAlignment = Enum.TextXAlignment.Center
scoreLabel.Parent = panel

-- Barra de timer
local timerBarBg = Instance.new("Frame")
timerBarBg.Size = UDim2.new(1, -16, 0, 6)
timerBarBg.Position = UDim2.new(0, 8, 0, 128)
timerBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
timerBarBg.BorderSizePixel = 0
timerBarBg.Parent = panel
Instance.new("UICorner", timerBarBg).CornerRadius = UDim.new(0, 3)

local timerBar = Instance.new("Frame")
timerBar.Name = "TimerBar"
timerBar.Size = UDim2.new(1, 0, 1, 0)
timerBar.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
timerBar.BorderSizePixel = 0
timerBar.Parent = timerBarBg
Instance.new("UICorner", timerBar).CornerRadius = UDim.new(0, 3)

-- ── Painel de resultado (aparece ao final) ──────────────────
local resultPanel = Instance.new("Frame")
resultPanel.Name = "ResultPanel"
resultPanel.Size = UDim2.new(0, 300, 0, 120)
resultPanel.Position = UDim2.new(0.5, -150, 0.35, 0)
resultPanel.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
resultPanel.BackgroundTransparency = 0.15
resultPanel.BorderSizePixel = 0
resultPanel.Visible = false
resultPanel.Parent = mgGui
Instance.new("UICorner", resultPanel).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", resultPanel).Color = Color3.fromRGB(255, 215, 0)

local resultTitle = Instance.new("TextLabel")
resultTitle.Size = UDim2.new(1, 0, 0, 36)
resultTitle.Position = UDim2.new(0, 0, 0, 10)
resultTitle.BackgroundTransparency = 1
resultTitle.Text = "COMPLETO!"
resultTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
resultTitle.Font = Enum.Font.GothamBold
resultTitle.TextSize = 24
resultTitle.Parent = resultPanel

local resultReward = Instance.new("TextLabel")
resultReward.Name = "Reward"
resultReward.Size = UDim2.new(1, 0, 0, 30)
resultReward.Position = UDim2.new(0, 0, 0, 48)
resultReward.BackgroundTransparency = 1
resultReward.Text = "+0 Coins"
resultReward.TextColor3 = Color3.fromRGB(255, 200, 0)
resultReward.Font = Enum.Font.GothamBold
resultReward.TextSize = 22
resultReward.Parent = resultPanel

local resultScore = Instance.new("TextLabel")
resultScore.Name = "ScoreResult"
resultScore.Size = UDim2.new(1, 0, 0, 24)
resultScore.Position = UDim2.new(0, 0, 0, 82)
resultScore.BackgroundTransparency = 1
resultScore.Text = ""
resultScore.TextColor3 = Color3.fromRGB(180, 180, 180)
resultScore.Font = Enum.Font.Gotham
resultScore.TextSize = 15
resultScore.Parent = resultPanel

-- ============================================================
-- Estado
-- ============================================================
local currentTimerThread = nil

-- ============================================================
-- Eventos
-- ============================================================

Remotes:WaitForChild("MinigameStart").OnClientEvent:Connect(function(mgId, mgName, mgDesc, duration, reward)
    panel.Visible = true
    resultPanel.Visible = false
    nameLabel.Text = mgName
    descLabel.Text = mgDesc
    scoreLabel.Text = "Recompensa: " .. reward .. " coins"
    timerBar.Size = UDim2.new(1, 0, 1, 0)
    timerBar.BackgroundColor3 = Color3.fromRGB(0, 255, 150)

    -- Cancela thread anterior se existir
    if currentTimerThread then
        task.cancel(currentTimerThread)
    end

    -- Countdown
    currentTimerThread = task.spawn(function()
        local startTime = tick()
        while true do
            local elapsed = tick() - startTime
            local remaining = math.max(0, duration - elapsed)
            local ratio = remaining / duration

            timerLabel.Text = string.format("%02d:%02d", math.floor(remaining), math.floor((remaining % 1) * 100))
            timerBar.Size = UDim2.new(math.clamp(ratio, 0, 1), 0, 1, 0)

            -- Cor muda perto do fim
            if ratio < 0.25 then
                timerBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            elseif ratio < 0.5 then
                timerBar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
            end

            if remaining <= 0 then break end
            task.wait(0.05)
        end
    end)
end)

Remotes:WaitForChild("MinigameProgress").OnClientEvent:Connect(function(mgId, score)
    scoreLabel.Text = "Pontos: " .. tostring(score)
end)

Remotes:WaitForChild("MinigameEnd").OnClientEvent:Connect(function(mgId, reward, score)
    panel.Visible = false

    if currentTimerThread then
        task.cancel(currentTimerThread)
        currentTimerThread = nil
    end

    -- Mostra resultado
    resultPanel.Visible = true
    resultReward.Text = "+" .. reward .. " Coins!"
    resultScore.Text = "Score: " .. tostring(score)

    -- Animacao de entrada
    resultPanel.Position = UDim2.new(0.5, -150, 0.3, -20)
    resultPanel.BackgroundTransparency = 0.8
    TweenService:Create(resultPanel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -150, 0.35, 0),
        BackgroundTransparency = 0.15,
    }):Play()

    -- Esconde apos 4 segundos
    task.delay(4, function()
        local fadeOut = TweenService:Create(resultPanel, TweenInfo.new(0.5), {
            BackgroundTransparency = 1,
        })
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            resultPanel.Visible = false
            resultPanel.BackgroundTransparency = 0.15
        end)
    end)
end)

print("[MinigameClient] UI de minigames carregada!")
