-- ShopClient.client.lua
-- 🛍️ UI completa da loja — abre ao entrar no trigger da loja

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local playerGui   = localPlayer:WaitForChild("PlayerGui")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Remotes    = ReplicatedStorage:WaitForChild("Remotes")

-- ============================================================
-- Cria GUI programaticamente
-- ============================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name            = "ShopGui"
screenGui.ResetOnSpawn    = false
screenGui.IgnoreGuiInset  = true
screenGui.Enabled         = false
screenGui.Parent          = playerGui

-- Fundo escuro
local overlay = Instance.new("Frame")
overlay.Size              = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3  = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.55
overlay.Parent            = screenGui

-- Janela central
local window = Instance.new("Frame")
window.Name               = "Window"
window.Size               = UDim2.new(0, 720, 0, 520)
window.Position           = UDim2.new(0.5, -360, 0.5, -260)
window.BackgroundColor3   = Color3.fromRGB(18, 18, 24)
window.BorderSizePixel    = 0
window.Parent             = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent       = window

-- Barra de título
local titleBar = Instance.new("Frame")
titleBar.Size             = UDim2.new(1, 0, 0, 54)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
titleBar.BorderSizePixel  = 0
titleBar.Parent           = window
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size             = UDim2.new(1, -60, 1, 0)
titleLabel.Position         = UDim2.new(0, 16, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text             = "⭐ Loja Brainrot Arena"
titleLabel.TextColor3       = Color3.fromRGB(20, 20, 20)
titleLabel.Font             = Enum.Font.GothamBold
titleLabel.TextSize         = 22
titleLabel.TextXAlignment   = Enum.TextXAlignment.Left
titleLabel.Parent           = titleBar

-- Coins do jogador (canto superior direito)
local coinDisplay = Instance.new("TextLabel")
coinDisplay.Name            = "CoinDisplay"
coinDisplay.Size            = UDim2.new(0, 160, 0, 36)
coinDisplay.Position        = UDim2.new(1, -180, 0, 9)
coinDisplay.BackgroundColor3= Color3.fromRGB(40, 40, 40)
coinDisplay.BackgroundTransparency = 0
coinDisplay.Text            = "💰 0 Coins"
coinDisplay.TextColor3      = Color3.fromRGB(255, 215, 0)
coinDisplay.Font            = Enum.Font.GothamBold
coinDisplay.TextSize        = 16
coinDisplay.Parent          = titleBar
Instance.new("UICorner", coinDisplay).CornerRadius = UDim.new(0, 8)

-- Botão fechar
local closeBtn = Instance.new("TextButton")
closeBtn.Size              = UDim2.new(0, 40, 0, 40)
closeBtn.Position          = UDim2.new(1, -50, 0, 7)
closeBtn.BackgroundColor3  = Color3.fromRGB(200, 40, 40)
closeBtn.Text              = "✕"
closeBtn.TextColor3        = Color3.fromRGB(255, 255, 255)
closeBtn.Font              = Enum.Font.GothamBold
closeBtn.TextSize          = 20
closeBtn.Parent            = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- Abas de categoria
local tabBar = Instance.new("Frame")
tabBar.Size             = UDim2.new(1, 0, 0, 40)
tabBar.Position         = UDim2.new(0, 0, 0, 54)
tabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 33)
tabBar.BorderSizePixel  = 0
tabBar.Parent           = window

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder     = Enum.SortOrder.LayoutOrder
tabLayout.Padding       = UDim.new(0, 4)
tabLayout.Parent        = tabBar

local CATEGORIES = {
    { id = "weapon",   label = "⚔️ Armas"      },
    { id = "boost",    label = "⚡ Boosts"      },
    { id = "cosmetic", label = "🎨 Cosméticos"  },
}

local tabButtons = {}
local activeCategory = "weapon"

-- Grade de itens
local itemGrid = Instance.new("ScrollingFrame")
itemGrid.Name                = "ItemGrid"
itemGrid.Size                = UDim2.new(1, -20, 1, -110)
itemGrid.Position            = UDim2.new(0, 10, 0, 100)
itemGrid.BackgroundTransparency = 1
itemGrid.ScrollBarThickness  = 6
itemGrid.ScrollBarImageColor3= Color3.fromRGB(255, 200, 0)
itemGrid.CanvasSize          = UDim2.new(0, 0, 0, 0)
itemGrid.AutomaticCanvasSize = Enum.AutomaticSize.Y
itemGrid.Parent              = window

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize     = UDim2.new(0, 200, 0, 140)
gridLayout.CellPadding  = UDim2.new(0, 12, 0, 12)
gridLayout.SortOrder    = Enum.SortOrder.LayoutOrder
gridLayout.Parent       = itemGrid

local gridPadding = Instance.new("UIPadding")
gridPadding.PaddingTop    = UDim.new(0, 8)
gridPadding.PaddingLeft   = UDim.new(0, 8)
gridPadding.Parent        = itemGrid

-- Notificação de resultado
local resultLabel = Instance.new("TextLabel")
resultLabel.Name              = "ResultLabel"
resultLabel.Size              = UDim2.new(0, 400, 0, 36)
resultLabel.Position          = UDim2.new(0.5, -200, 1, -46)
resultLabel.BackgroundColor3  = Color3.fromRGB(30, 30, 30)
resultLabel.BackgroundTransparency = 0.2
resultLabel.TextColor3        = Color3.fromRGB(100, 255, 100)
resultLabel.Font               = Enum.Font.GothamBold
resultLabel.TextSize           = 16
resultLabel.Visible            = false
resultLabel.Parent             = window
Instance.new("UICorner", resultLabel).CornerRadius = UDim.new(0, 8)

-- ============================================================
-- Construção dos cards de item
-- ============================================================

local RARITY_COLOR = {
    comum    = Color3.fromRGB(180, 180, 180),
    incomum  = Color3.fromRGB(0, 200, 80),
    raro     = Color3.fromRGB(0, 120, 255),
    épico    = Color3.fromRGB(160, 0, 220),
    lendário = Color3.fromRGB(255, 180, 0),
}

local function showResult(text, success)
    resultLabel.Text       = text
    resultLabel.TextColor3 = success and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(255, 80, 80)
    resultLabel.Visible    = true
    task.delay(3, function() resultLabel.Visible = false end)
end

local function buildItemCard(item, parent)
    local card = Instance.new("Frame")
    card.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    card.BorderSizePixel  = 0
    card.Parent           = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    -- Borda colorida por categoria
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color     = item.category == "weapon" and Color3.fromRGB(255, 80, 0)
        or item.category == "boost" and Color3.fromRGB(0, 200, 255)
        or Color3.fromRGB(200, 0, 255)
    cardStroke.Thickness = 2
    cardStroke.Parent    = card

    -- Nome
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size              = UDim2.new(1, -10, 0, 28)
    nameLabel.Position          = UDim2.new(0, 5, 0, 6)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text              = item.name
    nameLabel.TextColor3        = Color3.fromRGB(255, 255, 255)
    nameLabel.Font              = Enum.Font.GothamBold
    nameLabel.TextSize          = 14
    nameLabel.TextWrapped       = true
    nameLabel.Parent            = card

    -- Descrição
    local descLabel = Instance.new("TextLabel")
    descLabel.Size              = UDim2.new(1, -10, 0, 36)
    descLabel.Position          = UDim2.new(0, 5, 0, 36)
    descLabel.BackgroundTransparency = 1
    descLabel.Text              = item.description or ""
    descLabel.TextColor3        = Color3.fromRGB(180, 180, 180)
    descLabel.Font              = Enum.Font.Gotham
    descLabel.TextSize          = 11
    descLabel.TextWrapped       = true
    descLabel.Parent            = card

    -- Preço
    local priceLabel = Instance.new("TextLabel")
    priceLabel.Size             = UDim2.new(0.5, 0, 0, 22)
    priceLabel.Position         = UDim2.new(0, 5, 1, -60)
    priceLabel.BackgroundTransparency = 1
    priceLabel.Text             = "💰 " .. item.price
    priceLabel.TextColor3       = Color3.fromRGB(255, 215, 0)
    priceLabel.Font             = Enum.Font.GothamBold
    priceLabel.TextSize         = 14
    priceLabel.Parent           = card

    -- Botão Comprar
    local buyBtn = Instance.new("TextButton")
    buyBtn.Size               = UDim2.new(1, -12, 0, 30)
    buyBtn.Position           = UDim2.new(0, 6, 1, -36)
    buyBtn.BackgroundColor3   = Color3.fromRGB(255, 200, 0)
    buyBtn.Text               = "Comprar"
    buyBtn.TextColor3         = Color3.fromRGB(20, 20, 20)
    buyBtn.Font               = Enum.Font.GothamBold
    buyBtn.TextSize           = 15
    buyBtn.Parent             = card
    Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0, 6)

    buyBtn.MouseButton1Click:Connect(function()
        buyBtn.Text = "..."
        buyBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 0)

        local buyFunc = Remotes:FindFirstChild("BuyItem")
        if not buyFunc then
            showResult("Erro: servidor indisponível.", false)
            buyBtn.Text = "Comprar"
            buyBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
            return
        end

        local ok, msg = buyFunc:InvokeServer(item.id)
        showResult(msg or (ok and "Comprado!" or "Erro"), ok)

        buyBtn.Text = "Comprar"
        buyBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        updateCoins()
    end)

    -- Hover
    buyBtn.MouseEnter:Connect(function()
        TweenService:Create(buyBtn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(255, 230, 80) }):Play()
    end)
    buyBtn.MouseLeave:Connect(function()
        TweenService:Create(buyBtn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(255, 200, 0) }):Play()
    end)

    return card
end

-- ============================================================
-- População do grid por categoria
-- ============================================================

function updateCoins()
    local ls = localPlayer:FindFirstChild("leaderstats")
    local coins = ls and ls:FindFirstChild("Coins") and ls.Coins.Value or 0
    coinDisplay.Text = "💰 " .. coins .. " Coins"
end

local function populateGrid(category)
    for _, child in itemGrid:GetChildren() do
        if child:IsA("Frame") then child:Destroy() end
    end

    for _, item in GameConfig.SHOP_ITEMS do
        if item.category == category then
            buildItemCard(item, itemGrid)
        end
    end
    updateCoins()
end

-- ============================================================
-- Abas
-- ============================================================

local function setActiveTab(catId)
    activeCategory = catId
    for _, btn in tabButtons do
        if btn:GetAttribute("CatId") == catId then
            btn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
            btn.TextColor3       = Color3.fromRGB(20, 20, 20)
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            btn.TextColor3       = Color3.fromRGB(200, 200, 200)
        end
    end
    populateGrid(catId)
end

for i, cat in CATEGORIES do
    local btn = Instance.new("TextButton")
    btn:SetAttribute("CatId", cat.id)
    btn.Size              = UDim2.new(0, 160, 1, -8)
    btn.BackgroundColor3  = Color3.fromRGB(40, 40, 55)
    btn.Text              = cat.label
    btn.TextColor3        = Color3.fromRGB(200, 200, 200)
    btn.Font              = Enum.Font.GothamBold
    btn.TextSize          = 15
    btn.LayoutOrder       = i
    btn.Parent            = tabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    table.insert(tabButtons, btn)

    btn.MouseButton1Click:Connect(function()
        setActiveTab(cat.id)
    end)
end

-- ============================================================
-- Abrir / fechar loja
-- ============================================================

local function openShop()
    screenGui.Enabled = true
    setActiveTab("weapon")
    updateCoins()
    -- Animação de entrada
    window.Position = UDim2.new(0.5, -360, 0.6, -260)
    TweenService:Create(window, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -360, 0.5, -260)
    }):Play()
end

local function closeShop()
    TweenService:Create(window, TweenInfo.new(0.18), {
        Position = UDim2.new(0.5, -360, 0.6, -260)
    }).Completed:Connect(function()
        screenGui.Enabled = false
    end)
    TweenService:Create(window, TweenInfo.new(0.18), { Position = UDim2.new(0.5, -360, 0.6, -260) }):Play()
end

closeBtn.MouseButton1Click:Connect(closeShop)
overlay.MouseButton1Click:Connect(closeShop)

-- Remotes
Remotes:WaitForChild("OpenShop").OnClientEvent:Connect(openShop)

Remotes:WaitForChild("ShopResult").OnClientEvent:Connect(function(ok, msg)
    showResult(msg, ok)
    updateCoins()
end)

-- Atualiza coins quando leaderstats mudar
localPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    updateCoins()
end)
