-- ArenaHud.client.lua
-- 🎮 HUD da Allianz Brainrot Arena: rodada, kills, coins, anúncios globais

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui   = localPlayer:WaitForChild("PlayerGui")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Remotes    = ReplicatedStorage:WaitForChild("Remotes")

-- ============================================================
-- Cria HUD
-- ============================================================

local hud = Instance.new("ScreenGui")
hud.Name           = "ArenaHud"
hud.ResetOnSpawn   = false
hud.IgnoreGuiInset = true
hud.Parent         = playerGui

-- Helper: text stroke
local function addTextStroke(label, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(0, 0, 0)
    stroke.Thickness = thickness or 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    stroke.Parent = label
end

-- ── Painel superior direito (rodada + local) ──────────────
local topLeft = Instance.new("Frame")
topLeft.Size              = UDim2.new(0, 280, 0, 80)
topLeft.Position          = UDim2.new(1, -294, 0, 14)
topLeft.BackgroundColor3  = Color3.fromRGB(0, 50, 0)
topLeft.BackgroundTransparency = 0.25
topLeft.BorderSizePixel   = 0
topLeft.Parent            = hud
Instance.new("UICorner", topLeft).CornerRadius = UDim.new(0, 14)
local tlStroke = Instance.new("UIStroke", topLeft)
tlStroke.Color = Color3.fromRGB(0, 140, 0)
tlStroke.Thickness = 2

local roundLabel = Instance.new("TextLabel")
roundLabel.Name             = "RoundLabel"
roundLabel.Size             = UDim2.new(1, -12, 0, 36)
roundLabel.Position         = UDim2.new(0, 8, 0, 4)
roundLabel.BackgroundTransparency = 1
roundLabel.Text             = "🌊 Rodada 1"
roundLabel.TextColor3       = Color3.fromRGB(255, 200, 0)
roundLabel.Font             = Enum.Font.FredokaOne
roundLabel.TextSize         = 22
roundLabel.TextXAlignment   = Enum.TextXAlignment.Left
roundLabel.Parent           = topLeft
addTextStroke(roundLabel, Color3.fromRGB(80, 60, 0), 2)

local floorLabel = Instance.new("TextLabel")
floorLabel.Name             = "FloorLabel"
floorLabel.Size             = UDim2.new(1, -12, 0, 28)
floorLabel.Position         = UDim2.new(0, 8, 0, 40)
floorLabel.BackgroundTransparency = 1
floorLabel.Text             = "🏟️ Allianz Brainrot Arena"
floorLabel.TextColor3       = Color3.fromRGB(200, 200, 220)
floorLabel.Font             = Enum.Font.FredokaOne
floorLabel.TextSize         = 14
floorLabel.TextXAlignment   = Enum.TextXAlignment.Left
floorLabel.Parent           = topLeft
addTextStroke(floorLabel, Color3.fromRGB(0, 0, 0), 1)

-- (Kills/Coins removidos - agora no MainMenuClient)

-- ── Barra de HP do player ──────────────────────────────────
local hpBarBg = Instance.new("Frame")
hpBarBg.Size              = UDim2.new(0, 340, 0, 26)
hpBarBg.Position          = UDim2.new(0.5, -170, 1, -42)
hpBarBg.BackgroundColor3  = Color3.fromRGB(30, 10, 10)
hpBarBg.BorderSizePixel   = 0
hpBarBg.Parent            = hud
Instance.new("UICorner", hpBarBg).CornerRadius = UDim.new(0, 12)
local hpBgStroke = Instance.new("UIStroke", hpBarBg)
hpBgStroke.Color = Color3.fromRGB(0, 0, 0)
hpBgStroke.Thickness = 3

local hpBar = Instance.new("Frame")
hpBar.Name               = "HpBar"
hpBar.Size               = UDim2.new(1, 0, 1, 0)
hpBar.BackgroundColor3   = Color3.fromRGB(0, 180, 50)
hpBar.BorderSizePixel    = 0
hpBar.Parent             = hpBarBg
Instance.new("UICorner", hpBar).CornerRadius = UDim.new(0, 12)

local hpLabel = Instance.new("TextLabel")
hpLabel.Size              = UDim2.new(1, 0, 1, 0)
hpLabel.BackgroundTransparency = 1
hpLabel.Text              = "❤️ 100 / 100"
hpLabel.TextColor3        = Color3.fromRGB(255, 255, 255)
hpLabel.Font              = Enum.Font.FredokaOne
hpLabel.TextSize          = 14
hpLabel.Parent            = hpBarBg
addTextStroke(hpLabel, Color3.fromRGB(0, 0, 0), 2)

-- ── Kill Feed (baixo direito) ──────────────────────────────
local killFeed = Instance.new("Frame")
killFeed.Name             = "KillFeed"
killFeed.Size             = UDim2.new(0, 280, 0, 200)
killFeed.Position         = UDim2.new(1, -294, 1, -224)
killFeed.BackgroundTransparency = 1
killFeed.Parent           = hud
local killFeedLayout = Instance.new("UIListLayout")
killFeedLayout.SortOrder   = Enum.SortOrder.LayoutOrder
killFeedLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
killFeedLayout.Padding     = UDim.new(0, 4)
killFeedLayout.Parent      = killFeed

-- ── Anúncio Global (centro) ───────────────────────────────
local announceLabel = Instance.new("TextLabel")
announceLabel.Name             = "Announce"
announceLabel.Size             = UDim2.new(0, 600, 0, 60)
announceLabel.Position         = UDim2.new(0.5, -300, 0, 60)
announceLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
announceLabel.BackgroundTransparency = 0.2
announceLabel.Text             = ""
announceLabel.TextColor3       = Color3.fromRGB(255, 200, 0)
announceLabel.Font             = Enum.Font.FredokaOne
announceLabel.TextSize         = 26
announceLabel.Visible          = false
announceLabel.Parent           = hud
Instance.new("UICorner", announceLabel).CornerRadius = UDim.new(0, 14)
local annStroke = Instance.new("UIStroke", announceLabel)
annStroke.Color = Color3.fromRGB(80, 60, 0)
annStroke.Thickness = 3
addTextStroke(announceLabel, Color3.fromRGB(0, 0, 0), 2)

-- ── Contador de intermission (centro baixo) ────────────────
local intermissionLabel = Instance.new("TextLabel")
intermissionLabel.Name             = "Intermission"
intermissionLabel.Size             = UDim2.new(0, 320, 0, 44)
intermissionLabel.Position         = UDim2.new(0.5, -160, 0, 128)
intermissionLabel.BackgroundTransparency = 1
intermissionLabel.Text             = ""
intermissionLabel.TextColor3       = Color3.fromRGB(220, 220, 230)
intermissionLabel.Font             = Enum.Font.FredokaOne
intermissionLabel.TextSize         = 22
intermissionLabel.Visible          = false
intermissionLabel.Parent           = hud
addTextStroke(intermissionLabel, Color3.fromRGB(0, 0, 0), 2)

-- ============================================================
-- Lógica de atualização
-- ============================================================

local function showAnnounce(text, color)
    announceLabel.Text       = text
    announceLabel.TextColor3 = color or Color3.fromRGB(255, 200, 0)
    announceLabel.Visible    = true
    announceLabel.TextTransparency = 0

    local tween = TweenService:Create(
        announceLabel,
        TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { TextTransparency = 1, BackgroundTransparency = 1 }
    )
    tween:Play()
    tween.Completed:Connect(function()
        announceLabel.Visible = false
        announceLabel.BackgroundTransparency = 0.25
    end)
end

local function addKillFeedEntry(mobName, coins)
    local label = Instance.new("TextLabel")
    label.LayoutOrder       = #killFeed:GetChildren()
    label.Size              = UDim2.new(1, 0, 0, 28)
    label.BackgroundColor3  = Color3.fromRGB(20, 20, 20)
    label.BackgroundTransparency = 0.35
    label.Text              = "💀 " .. mobName .. "  +" .. coins .. "💰"
    label.TextColor3        = Color3.fromRGB(255, 120, 80)
    label.Font              = Enum.Font.FredokaOne
    label.TextSize          = 14
    addTextStroke(label, Color3.fromRGB(0, 0, 0), 1)
    label.TextXAlignment    = Enum.TextXAlignment.Right
    label.Parent            = killFeed
    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 6)

    TweenService:Create(label, TweenInfo.new(0.1), { TextTransparency = 0 }):Play()
    task.delay(4, function()
        TweenService:Create(label, TweenInfo.new(0.5), { TextTransparency = 1, BackgroundTransparency = 1 }).Completed:Connect(function()
            label:Destroy()
        end)
        TweenService:Create(label, TweenInfo.new(0.5), { TextTransparency = 1, BackgroundTransparency = 1 }):Play()
    end)
end

-- Atualiza HP da barra
local function updateHpBar(character)
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    hum.HealthChanged:Connect(function(health)
        local ratio = math.clamp(health / hum.MaxHealth, 0, 1)
        TweenService:Create(hpBar, TweenInfo.new(0.15), { Size = UDim2.new(ratio, 0, 1, 0) }):Play()
        hpLabel.Text = "❤️ " .. math.floor(health) .. " / " .. math.floor(hum.MaxHealth)

        -- Cor muda conforme HP
        local r = math.floor(220 * (1 - ratio) + 50 * ratio)
        local g = math.floor(50 * (1 - ratio) + 220 * ratio)
        TweenService:Create(hpBar, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(r, g, 50) }):Play()
    end)
end

-- (bindLeaderstats removido - stats agora no MainMenuClient)
local function bindLeaderstats() end

-- Mostra nome do estadio (layout unico)
local function updateFloorLabel(_character)
    floorLabel.Text = "🏟️ Allianz Brainrot Arena"
end

-- Intermission countdown
local function startIntermission(seconds)
    intermissionLabel.Visible = true
    for i = seconds, 1, -1 do
        intermissionLabel.Text = "⏳ Próxima rodada em " .. i .. "s"
        task.wait(1)
    end
    intermissionLabel.Visible = false
end

-- ============================================================
-- Conecta remotes
-- ============================================================

Remotes:WaitForChild("RoundStarted").OnClientEvent:Connect(function(round)
    roundLabel.Text = "🌊 Rodada " .. round
    showAnnounce("🌊 RODADA " .. round .. " INICIADA!", Color3.fromRGB(255, 200, 0))
end)

Remotes:WaitForChild("RoundEnded").OnClientEvent:Connect(function(round)
    showAnnounce("✅ Rodada " .. round .. " concluída!", Color3.fromRGB(100, 255, 150))
    startIntermission(GameConfig.INTERMISSION_TIME)
end)

Remotes:WaitForChild("MobKilled").OnClientEvent:Connect(function(mobName, coins)
    addKillFeedEntry(mobName, coins)
end)

Remotes:WaitForChild("GlobalAnnounce").OnClientEvent:Connect(function(text, color)
    showAnnounce(text, color)
end)

Remotes:WaitForChild("FloorUnlocked").OnClientEvent:Connect(function(floorId)
    local name = "Andar " .. floorId
    for _, f in GameConfig.FLOORS do
        if f.id == floorId then name = f.name; break end
    end
    showAnnounce("🔓 " .. name .. " desbloqueado!", Color3.fromRGB(80, 200, 255))
end)

-- ============================================================
-- Init
-- ============================================================

localPlayer.CharacterAdded:Connect(function(character)
    updateHpBar(character)
    updateFloorLabel(character)
end)

if localPlayer.Character then
    updateHpBar(localPlayer.Character)
    updateFloorLabel(localPlayer.Character)
end

bindLeaderstats()
