-- ArenaHud.client.lua
-- 🎮 HUD da arena: rodada, andar atual, kills, coins, anúncios globais

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

-- ── Painel superior esquerdo (rodada + andar) ──────────────
local topLeft = Instance.new("Frame")
topLeft.Size              = UDim2.new(0, 220, 0, 90)
topLeft.Position          = UDim2.new(0, 14, 0, 14)
topLeft.BackgroundColor3  = Color3.fromRGB(15, 15, 20)
topLeft.BackgroundTransparency = 0.3
topLeft.BorderSizePixel   = 0
topLeft.Parent            = hud
Instance.new("UICorner", topLeft).CornerRadius = UDim.new(0, 12)

local roundLabel = Instance.new("TextLabel")
roundLabel.Name             = "RoundLabel"
roundLabel.Size             = UDim2.new(1, -10, 0, 36)
roundLabel.Position         = UDim2.new(0, 8, 0, 4)
roundLabel.BackgroundTransparency = 1
roundLabel.Text             = "🌊 Rodada 1"
roundLabel.TextColor3       = Color3.fromRGB(255, 200, 0)
roundLabel.Font             = Enum.Font.GothamBold
roundLabel.TextSize         = 22
roundLabel.TextXAlignment   = Enum.TextXAlignment.Left
roundLabel.Parent           = topLeft

local floorLabel = Instance.new("TextLabel")
floorLabel.Name             = "FloorLabel"
floorLabel.Size             = UDim2.new(1, -10, 0, 28)
floorLabel.Position         = UDim2.new(0, 8, 0, 44)
floorLabel.BackgroundTransparency = 1
floorLabel.Text             = "🏟️ Piso da Arquibancada"
floorLabel.TextColor3       = Color3.fromRGB(200, 200, 200)
floorLabel.Font             = Enum.Font.Gotham
floorLabel.TextSize         = 15
floorLabel.TextXAlignment   = Enum.TextXAlignment.Left
floorLabel.Parent           = topLeft

-- ── Painel superior direito (kills + coins) ────────────────
local topRight = Instance.new("Frame")
topRight.Size              = UDim2.new(0, 190, 0, 90)
topRight.Position          = UDim2.new(1, -204, 0, 14)
topRight.BackgroundColor3  = Color3.fromRGB(15, 15, 20)
topRight.BackgroundTransparency = 0.3
topRight.BorderSizePixel   = 0
topRight.Parent            = hud
Instance.new("UICorner", topRight).CornerRadius = UDim.new(0, 12)

local killsLabel = Instance.new("TextLabel")
killsLabel.Name             = "KillsLabel"
killsLabel.Size             = UDim2.new(1, -10, 0, 36)
killsLabel.Position         = UDim2.new(0, 8, 0, 4)
killsLabel.BackgroundTransparency = 1
killsLabel.Text             = "⚔️ Kills: 0"
killsLabel.TextColor3       = Color3.fromRGB(255, 80, 80)
killsLabel.Font             = Enum.Font.GothamBold
killsLabel.TextSize         = 20
killsLabel.TextXAlignment   = Enum.TextXAlignment.Left
killsLabel.Parent           = topRight

local coinsLabel = Instance.new("TextLabel")
coinsLabel.Name             = "CoinsLabel"
coinsLabel.Size             = UDim2.new(1, -10, 0, 28)
coinsLabel.Position         = UDim2.new(0, 8, 0, 44)
coinsLabel.BackgroundTransparency = 1
coinsLabel.Text             = "💰 Coins: 0"
coinsLabel.TextColor3       = Color3.fromRGB(255, 215, 0)
coinsLabel.Font             = Enum.Font.GothamBold
coinsLabel.TextSize         = 17
coinsLabel.TextXAlignment   = Enum.TextXAlignment.Left
coinsLabel.Parent           = topRight

-- ── Barra de HP do player ──────────────────────────────────
local hpBarBg = Instance.new("Frame")
hpBarBg.Size              = UDim2.new(0, 300, 0, 20)
hpBarBg.Position          = UDim2.new(0.5, -150, 1, -44)
hpBarBg.BackgroundColor3  = Color3.fromRGB(40, 10, 10)
hpBarBg.BorderSizePixel   = 0
hpBarBg.Parent            = hud
Instance.new("UICorner", hpBarBg).CornerRadius = UDim.new(0, 10)

local hpBar = Instance.new("Frame")
hpBar.Name               = "HpBar"
hpBar.Size               = UDim2.new(1, 0, 1, 0)
hpBar.BackgroundColor3   = Color3.fromRGB(220, 50, 50)
hpBar.BorderSizePixel    = 0
hpBar.Parent             = hpBarBg
Instance.new("UICorner", hpBar).CornerRadius = UDim.new(0, 10)

local hpLabel = Instance.new("TextLabel")
hpLabel.Size              = UDim2.new(1, 0, 1, 0)
hpLabel.BackgroundTransparency = 1
hpLabel.Text              = "❤️ 100 / 100"
hpLabel.TextColor3        = Color3.fromRGB(255, 255, 255)
hpLabel.Font              = Enum.Font.GothamBold
hpLabel.TextSize          = 13
hpLabel.Parent            = hpBarBg

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
announceLabel.Size             = UDim2.new(0, 600, 0, 56)
announceLabel.Position         = UDim2.new(0.5, -300, 0, 80)
announceLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
announceLabel.BackgroundTransparency = 0.25
announceLabel.Text             = ""
announceLabel.TextColor3       = Color3.fromRGB(255, 200, 0)
announceLabel.Font             = Enum.Font.GothamBold
announceLabel.TextSize         = 24
announceLabel.Visible          = false
announceLabel.Parent           = hud
Instance.new("UICorner", announceLabel).CornerRadius = UDim.new(0, 12)

-- ── Contador de intermission (centro baixo) ────────────────
local intermissionLabel = Instance.new("TextLabel")
intermissionLabel.Name             = "Intermission"
intermissionLabel.Size             = UDim2.new(0, 300, 0, 44)
intermissionLabel.Position         = UDim2.new(0.5, -150, 0, 144)
intermissionLabel.BackgroundTransparency = 1
intermissionLabel.Text             = ""
intermissionLabel.TextColor3       = Color3.fromRGB(200, 200, 200)
intermissionLabel.Font             = Enum.Font.GothamBold
intermissionLabel.TextSize         = 20
intermissionLabel.Visible          = false
intermissionLabel.Parent           = hud

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
    label.Font              = Enum.Font.GothamBold
    label.TextSize          = 14
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

-- Atualiza kills e coins do leaderstats
local function bindLeaderstats()
    local ls = localPlayer:WaitForChild("leaderstats", 10)
    if not ls then return end

    local kills = ls:WaitForChild("Kills", 5)
    local coins = ls:WaitForChild("Coins", 5)

    if kills then
        killsLabel.Text = "⚔️ Kills: " .. kills.Value
        kills.Changed:Connect(function(v) killsLabel.Text = "⚔️ Kills: " .. v end)
    end
    if coins then
        coinsLabel.Text = "💰 Coins: " .. coins.Value
        coins.Changed:Connect(function(v) coinsLabel.Text = "💰 Coins: " .. v end)
    end
end

-- Detecta em qual andar o player está (por posição Y)
local function updateFloorLabel(character)
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    RunService.Heartbeat:Connect(function()
        local y = root.Position.Y
        local current = GameConfig.FLOORS[1]
        for _, f in GameConfig.FLOORS do
            if y >= f.spawnHeight - 10 then
                current = f
            end
        end
        floorLabel.Text = "🏟️ " .. current.name
    end)
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
