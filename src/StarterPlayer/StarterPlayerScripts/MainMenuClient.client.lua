-- MainMenuClient.client.lua
-- Menu principal com 3 abas: Loja, Rebirth, Indice Brainrot
-- Botoes fixos na parte inferior da tela

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- ============================================================
-- GUI principal
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "MainMenuGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

-- ── Barra de botoes (inferior) ──────────────────────────────
local bottomBar = Instance.new("Frame")
bottomBar.Name = "BottomBar"
bottomBar.Size = UDim2.new(0, 400, 0, 60)
bottomBar.Position = UDim2.new(0.5, -200, 1, -70)
bottomBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
bottomBar.BackgroundTransparency = 0.2
bottomBar.BorderSizePixel = 0
bottomBar.Parent = gui
Instance.new("UICorner", bottomBar).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", bottomBar).Color = Color3.fromRGB(80, 80, 100)

local barLayout = Instance.new("UIListLayout")
barLayout.FillDirection = Enum.FillDirection.Horizontal
barLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
barLayout.VerticalAlignment = Enum.VerticalAlignment.Center
barLayout.Padding = UDim.new(0, 10)
barLayout.Parent = bottomBar

local TABS = {
    { id = "shop",    label = "Loja",    color = Color3.fromRGB(255, 200, 0) },
    { id = "rebirth", label = "Rebirth", color = Color3.fromRGB(255, 80, 255) },
    { id = "index",   label = "Indice",  color = Color3.fromRGB(0, 200, 255) },
}

-- ============================================================
-- Painel flutuante (aparece acima da barra)
-- ============================================================
local panelFrame = Instance.new("Frame")
panelFrame.Name = "PanelFrame"
panelFrame.Size = UDim2.new(0, 640, 0, 440)
panelFrame.Position = UDim2.new(0.5, -320, 0.5, -240)
panelFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
panelFrame.BorderSizePixel = 0
panelFrame.Visible = false
panelFrame.Parent = gui
Instance.new("UICorner", panelFrame).CornerRadius = UDim.new(0, 14)

-- Overlay escuro
local overlay = Instance.new("Frame")
overlay.Name = "Overlay"
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.55
overlay.Visible = false
overlay.ZIndex = 0
overlay.Parent = gui

-- Titulo do painel
local panelTitle = Instance.new("TextLabel")
panelTitle.Name = "PanelTitle"
panelTitle.Size = UDim2.new(1, 0, 0, 50)
panelTitle.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
panelTitle.BackgroundTransparency = 0
panelTitle.Text = "Menu"
panelTitle.TextColor3 = Color3.fromRGB(20, 20, 20)
panelTitle.Font = Enum.Font.GothamBold
panelTitle.TextSize = 22
panelTitle.BorderSizePixel = 0
panelTitle.Parent = panelFrame
Instance.new("UICorner", panelTitle).CornerRadius = UDim.new(0, 14)

-- Botao fechar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -48, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.Parent = panelFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- Area de conteudo
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -20, 1, -70)
contentArea.Position = UDim2.new(0, 10, 0, 60)
contentArea.BackgroundTransparency = 1
contentArea.Parent = panelFrame

-- ============================================================
-- ESTADO
-- ============================================================
local currentTab = nil

local function closePanel()
    panelFrame.Visible = false
    overlay.Visible = false
    currentTab = nil
end

closeBtn.MouseButton1Click:Connect(closePanel)
overlay.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        closePanel()
    end
end)

local function clearContent()
    for _, child in contentArea:GetChildren() do
        child:Destroy()
    end
end

-- ============================================================
-- ABA: LOJA (simplificada — link para ShopGui existente)
-- ============================================================
local function openShopTab()
    clearContent()
    panelTitle.Text = "Loja Brainrot"
    panelTitle.BackgroundColor3 = Color3.fromRGB(255, 200, 0)

    -- Info de coins
    local ls = localPlayer:FindFirstChild("leaderstats")
    local coins = ls and ls:FindFirstChild("Coins") and ls.Coins.Value or 0

    local coinsLabel = Instance.new("TextLabel")
    coinsLabel.Size = UDim2.new(1, 0, 0, 40)
    coinsLabel.BackgroundTransparency = 1
    coinsLabel.Text = "Coins: " .. coins
    coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    coinsLabel.Font = Enum.Font.GothamBold
    coinsLabel.TextSize = 24
    coinsLabel.Parent = contentArea

    -- Grid de itens
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, -50)
    scroll.Position = UDim2.new(0, 0, 0, 50)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = contentArea

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0, 190, 0, 130)
    grid.CellPadding = UDim2.new(0, 10, 0, 10)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = scroll

    Instance.new("UIPadding", scroll).PaddingTop = UDim.new(0, 5)

    local catColors = {
        weapon = Color3.fromRGB(255, 80, 0),
        boost = Color3.fromRGB(0, 200, 255),
        cosmetic = Color3.fromRGB(200, 0, 255),
    }

    for i, item in GameConfig.SHOP_ITEMS do
        local card = Instance.new("Frame")
        card.LayoutOrder = i
        card.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        card.BorderSizePixel = 0
        card.Parent = scroll
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke", card)
        stroke.Color = catColors[item.category] or Color3.fromRGB(100, 100, 100)
        stroke.Thickness = 2

        local nameL = Instance.new("TextLabel")
        nameL.Size = UDim2.new(1, -8, 0, 24)
        nameL.Position = UDim2.new(0, 4, 0, 4)
        nameL.BackgroundTransparency = 1
        nameL.Text = item.name
        nameL.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameL.Font = Enum.Font.GothamBold
        nameL.TextSize = 13
        nameL.TextWrapped = true
        nameL.Parent = card

        local descL = Instance.new("TextLabel")
        descL.Size = UDim2.new(1, -8, 0, 30)
        descL.Position = UDim2.new(0, 4, 0, 30)
        descL.BackgroundTransparency = 1
        descL.Text = item.description or ""
        descL.TextColor3 = Color3.fromRGB(160, 160, 160)
        descL.Font = Enum.Font.Gotham
        descL.TextSize = 10
        descL.TextWrapped = true
        descL.Parent = card

        local priceL = Instance.new("TextLabel")
        priceL.Size = UDim2.new(0.5, 0, 0, 20)
        priceL.Position = UDim2.new(0, 4, 1, -56)
        priceL.BackgroundTransparency = 1
        priceL.Text = item.price .. " coins"
        priceL.TextColor3 = Color3.fromRGB(255, 215, 0)
        priceL.Font = Enum.Font.GothamBold
        priceL.TextSize = 12
        priceL.Parent = card

        local buyBtn = Instance.new("TextButton")
        buyBtn.Size = UDim2.new(1, -10, 0, 28)
        buyBtn.Position = UDim2.new(0, 5, 1, -32)
        buyBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        buyBtn.Text = "Comprar"
        buyBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
        buyBtn.Font = Enum.Font.GothamBold
        buyBtn.TextSize = 14
        buyBtn.Parent = card
        Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0, 6)

        buyBtn.MouseButton1Click:Connect(function()
            buyBtn.Text = "..."
            local buyFunc = Remotes:FindFirstChild("BuyItem")
            if buyFunc then
                local ok, msg = buyFunc:InvokeServer(item.id)
                buyBtn.Text = ok and "OK!" or "Erro"
                task.delay(1, function() buyBtn.Text = "Comprar" end)
                -- Atualiza coins
                local lsNow = localPlayer:FindFirstChild("leaderstats")
                local c = lsNow and lsNow:FindFirstChild("Coins") and lsNow.Coins.Value or 0
                coinsLabel.Text = "Coins: " .. c
            end
        end)
    end
end

-- ============================================================
-- ABA: REBIRTH
-- ============================================================
local function openRebirthTab()
    clearContent()
    panelTitle.Text = "Rebirth"
    panelTitle.BackgroundColor3 = Color3.fromRGB(255, 80, 255)

    -- Busca info do servidor
    local infoFunc = Remotes:FindFirstChild("GetRebirthInfo")
    local info = infoFunc and infoFunc:InvokeServer() or {}

    local rebirths = info.rebirths or 0
    local cost = info.cost or 1000
    local coinMult = info.coinMult or 1
    local dmgMult = info.dmgMult or 1
    local nextCoinMult = info.nextCoinMult or 1.5
    local nextDmgMult = info.nextDmgMult or 1.1
    local maxRb = info.maxRebirths or 50

    -- Layout vertical
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 12)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = contentArea

    -- Titulo rebirth
    local rbTitle = Instance.new("TextLabel")
    rbTitle.LayoutOrder = 1
    rbTitle.Size = UDim2.new(0.8, 0, 0, 40)
    rbTitle.BackgroundTransparency = 1
    rbTitle.Text = "Rebirth: " .. rebirths .. " / " .. maxRb
    rbTitle.TextColor3 = Color3.fromRGB(255, 100, 255)
    rbTitle.Font = Enum.Font.GothamBold
    rbTitle.TextSize = 28
    rbTitle.Parent = contentArea

    -- Multiplicador atual
    local multLabel = Instance.new("TextLabel")
    multLabel.LayoutOrder = 2
    multLabel.Size = UDim2.new(0.8, 0, 0, 30)
    multLabel.BackgroundTransparency = 1
    multLabel.Text = "Multiplicador de Coins: " .. string.format("%.1f", coinMult) .. "x"
    multLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    multLabel.Font = Enum.Font.GothamBold
    multLabel.TextSize = 20
    multLabel.Parent = contentArea

    local dmgLabel = Instance.new("TextLabel")
    dmgLabel.LayoutOrder = 3
    dmgLabel.Size = UDim2.new(0.8, 0, 0, 26)
    dmgLabel.BackgroundTransparency = 1
    dmgLabel.Text = "Multiplicador de Dano: " .. string.format("%.1f", dmgMult) .. "x"
    dmgLabel.TextColor3 = Color3.fromRGB(255, 120, 80)
    dmgLabel.Font = Enum.Font.GothamBold
    dmgLabel.TextSize = 18
    dmgLabel.Parent = contentArea

    -- Separador
    local sep = Instance.new("Frame")
    sep.LayoutOrder = 4
    sep.Size = UDim2.new(0.7, 0, 0, 2)
    sep.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    sep.BorderSizePixel = 0
    sep.Parent = contentArea

    -- Proximo rebirth info
    local nextInfo = Instance.new("TextLabel")
    nextInfo.LayoutOrder = 5
    nextInfo.Size = UDim2.new(0.8, 0, 0, 50)
    nextInfo.BackgroundTransparency = 1
    nextInfo.Text = "Proximo Rebirth:\nCoins " .. string.format("%.1f", nextCoinMult) .. "x  |  Dano " .. string.format("%.1f", nextDmgMult) .. "x"
    nextInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
    nextInfo.Font = Enum.Font.Gotham
    nextInfo.TextSize = 16
    nextInfo.Parent = contentArea

    -- Custo
    local costLabel = Instance.new("TextLabel")
    costLabel.LayoutOrder = 6
    costLabel.Size = UDim2.new(0.8, 0, 0, 30)
    costLabel.BackgroundTransparency = 1
    costLabel.Text = "Custo: " .. cost .. " Coins"
    costLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    costLabel.Font = Enum.Font.GothamBold
    costLabel.TextSize = 20
    costLabel.Parent = contentArea

    -- Aviso
    local warnLabel = Instance.new("TextLabel")
    warnLabel.LayoutOrder = 7
    warnLabel.Size = UDim2.new(0.8, 0, 0, 24)
    warnLabel.BackgroundTransparency = 1
    warnLabel.Text = "AVISO: Kills e Coins serao resetados!"
    warnLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    warnLabel.Font = Enum.Font.GothamBold
    warnLabel.TextSize = 14
    warnLabel.Parent = contentArea

    -- Botao de Rebirth
    local rbBtn = Instance.new("TextButton")
    rbBtn.LayoutOrder = 8
    rbBtn.Size = UDim2.new(0.6, 0, 0, 50)
    rbBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 255)
    rbBtn.Text = "FAZER REBIRTH"
    rbBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rbBtn.Font = Enum.Font.GothamBold
    rbBtn.TextSize = 22
    rbBtn.Parent = contentArea
    Instance.new("UICorner", rbBtn).CornerRadius = UDim.new(0, 12)

    if rebirths >= maxRb then
        rbBtn.Text = "REBIRTH MAXIMO!"
        rbBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end

    rbBtn.MouseButton1Click:Connect(function()
        rbBtn.Text = "Processando..."
        rbBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 120)

        local rbFunc = Remotes:FindFirstChild("DoRebirth")
        if rbFunc then
            local ok, msg = rbFunc:InvokeServer()
            if ok then
                rbBtn.Text = "REBIRTH!"
                rbBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                task.delay(1.5, function()
                    openRebirthTab() -- Refresh
                end)
            else
                rbBtn.Text = msg or "Erro"
                rbBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                task.delay(2, function()
                    rbBtn.Text = "FAZER REBIRTH"
                    rbBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 255)
                end)
            end
        end
    end)

    -- Hover
    rbBtn.MouseEnter:Connect(function()
        TweenService:Create(rbBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(255, 120, 255) }):Play()
    end)
    rbBtn.MouseLeave:Connect(function()
        TweenService:Create(rbBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(255, 80, 255) }):Play()
    end)
end

-- ============================================================
-- ABA: INDICE BRAINROT
-- ============================================================
local function openIndexTab()
    clearContent()
    panelTitle.Text = "Indice Brainrot"
    panelTitle.BackgroundColor3 = Color3.fromRGB(0, 200, 255)

    -- Busca dados do servidor
    local indexFunc = Remotes:FindFirstChild("GetBrainrotIndex")
    local indexData = indexFunc and indexFunc:InvokeServer() or {}

    -- Header
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundTransparency = 1
    header.Text = "Complete todos os Brainrots para ganhar recompensas!"
    header.TextColor3 = Color3.fromRGB(200, 200, 200)
    header.Font = Enum.Font.Gotham
    header.TextSize = 14
    header.Parent = contentArea

    -- Scroll
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, -40)
    scroll.Position = UDim2.new(0, 0, 0, 35)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = contentArea

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = scroll

    -- Tier colors lookup
    local tierColors = {}
    for _, t in GameConfig.INDEX_TIERS do
        tierColors[t.name] = t.color
    end

    if #indexData == 0 then
        -- Ainda sem dados, mostra placeholder
        local placeholder = Instance.new("TextLabel")
        placeholder.Size = UDim2.new(1, 0, 0, 60)
        placeholder.BackgroundTransparency = 1
        placeholder.Text = "Mate mobs para desbloquear o indice!"
        placeholder.TextColor3 = Color3.fromRGB(150, 150, 150)
        placeholder.Font = Enum.Font.GothamBold
        placeholder.TextSize = 18
        placeholder.Parent = scroll
    end

    for i, entry in indexData do
        local card = Instance.new("Frame")
        card.LayoutOrder = i
        card.Size = UDim2.new(1, -10, 0, 80)
        card.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        card.BorderSizePixel = 0
        card.Parent = scroll
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

        -- Borda com cor do tier
        local tierColor = tierColors[entry.tierName] or Color3.fromRGB(100, 100, 100)
        local stroke = Instance.new("UIStroke", card)
        stroke.Color = tierColor
        stroke.Thickness = 2

        -- Icone (cor do mob por rarity)
        local rarityColors = {
            ["comum"] = Color3.fromRGB(180, 180, 180),
            ["incomum"] = Color3.fromRGB(0, 200, 80),
            ["raro"] = Color3.fromRGB(0, 120, 255),
            ["epico"] = Color3.fromRGB(160, 0, 220),
            ["lendario"] = Color3.fromRGB(255, 180, 0),
        }
        local icon = Instance.new("Frame")
        icon.Size = UDim2.new(0, 50, 0, 50)
        icon.Position = UDim2.new(0, 10, 0.5, -25)
        icon.BackgroundColor3 = rarityColors[entry.rarity] or Color3.fromRGB(100, 100, 100)
        icon.Parent = card
        Instance.new("UICorner", icon).CornerRadius = UDim.new(0.5, 0)

        -- Inicial do mob
        local initial = Instance.new("TextLabel")
        initial.Size = UDim2.new(1, 0, 1, 0)
        initial.BackgroundTransparency = 1
        initial.Text = string.sub(entry.displayName or entry.mobName, 1, 2)
        initial.TextColor3 = Color3.fromRGB(255, 255, 255)
        initial.Font = Enum.Font.GothamBold
        initial.TextSize = 18
        initial.Parent = icon

        -- Nome
        local nameL = Instance.new("TextLabel")
        nameL.Size = UDim2.new(0.5, -70, 0, 24)
        nameL.Position = UDim2.new(0, 68, 0, 6)
        nameL.BackgroundTransparency = 1
        nameL.Text = entry.displayName or entry.mobName
        nameL.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameL.Font = Enum.Font.GothamBold
        nameL.TextSize = 15
        nameL.TextXAlignment = Enum.TextXAlignment.Left
        nameL.Parent = card

        -- Tier badge
        local tierBadge = Instance.new("TextLabel")
        tierBadge.Size = UDim2.new(0, 90, 0, 22)
        tierBadge.Position = UDim2.new(0, 68, 0, 32)
        tierBadge.BackgroundColor3 = tierColor
        tierBadge.BackgroundTransparency = 0.3
        tierBadge.Text = entry.tierName
        tierBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
        tierBadge.Font = Enum.Font.GothamBold
        tierBadge.TextSize = 13
        tierBadge.Parent = card
        Instance.new("UICorner", tierBadge).CornerRadius = UDim.new(0, 6)

        -- Kills
        local killsL = Instance.new("TextLabel")
        killsL.Size = UDim2.new(0, 120, 0, 20)
        killsL.Position = UDim2.new(0, 68, 0, 56)
        killsL.BackgroundTransparency = 1
        killsL.Text = "Kills: " .. (entry.kills or 0)
        killsL.TextColor3 = Color3.fromRGB(180, 180, 180)
        killsL.Font = Enum.Font.Gotham
        killsL.TextSize = 12
        killsL.TextXAlignment = Enum.TextXAlignment.Left
        killsL.Parent = card

        -- Barra de progresso para proximo tier
        local barBg = Instance.new("Frame")
        barBg.Size = UDim2.new(0.4, 0, 0, 12)
        barBg.Position = UDim2.new(0.55, 0, 0.5, -6)
        barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        barBg.BorderSizePixel = 0
        barBg.Parent = card
        Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 6)

        local progress = 0
        if entry.nextTierName ~= "MAX" then
            -- Find current tier kills threshold
            local currentTierKills = 0
            for _, t in GameConfig.INDEX_TIERS do
                if t.name == entry.tierName then
                    currentTierKills = t.killsNeeded
                    break
                end
            end
            local range = entry.nextTierKills - currentTierKills
            if range > 0 then
                progress = math.clamp((entry.kills - currentTierKills) / range, 0, 1)
            end
        else
            progress = 1
        end

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(progress, 0, 1, 0)
        bar.BackgroundColor3 = tierColor
        bar.BorderSizePixel = 0
        bar.Parent = barBg
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 6)

        -- Next tier label
        local nextL = Instance.new("TextLabel")
        nextL.Size = UDim2.new(0.4, 0, 0, 16)
        nextL.Position = UDim2.new(0.55, 0, 0.5, 10)
        nextL.BackgroundTransparency = 1
        nextL.Text = entry.nextTierName == "MAX" and "COMPLETO!" or ("Proximo: " .. entry.nextTierName .. " (" .. entry.nextTierKills .. " kills)")
        nextL.TextColor3 = Color3.fromRGB(150, 150, 150)
        nextL.Font = Enum.Font.Gotham
        nextL.TextSize = 11
        nextL.TextXAlignment = Enum.TextXAlignment.Left
        nextL.Parent = card
    end
end

-- ============================================================
-- Logica de abas
-- ============================================================
local tabHandlers = {
    shop = openShopTab,
    rebirth = openRebirthTab,
    index = openIndexTab,
}

local function openTab(tabId)
    if currentTab == tabId then
        closePanel()
        return
    end

    currentTab = tabId
    overlay.Visible = true
    panelFrame.Visible = true

    -- Animacao
    panelFrame.Position = UDim2.new(0.5, -320, 0.55, -240)
    TweenService:Create(panelFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -320, 0.5, -240)
    }):Play()

    local handler = tabHandlers[tabId]
    if handler then handler() end
end

-- Cria botoes
for i, tab in TABS do
    local btn = Instance.new("TextButton")
    btn.Name = "Tab_"..tab.id
    btn.Size = UDim2.new(0, 120, 0, 44)
    btn.BackgroundColor3 = tab.color
    btn.Text = tab.label
    btn.TextColor3 = Color3.fromRGB(20, 20, 20)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 17
    btn.LayoutOrder = i
    btn.Parent = bottomBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    btn.MouseButton1Click:Connect(function()
        openTab(tab.id)
    end)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), { Size = UDim2.new(0, 126, 0, 48) }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), { Size = UDim2.new(0, 120, 0, 44) }):Play()
    end)
end

-- ============================================================
-- Eventos server -> client
-- ============================================================

-- Tier up notification
Remotes:WaitForChild("IndexTierUp").OnClientEvent:Connect(function(mobName, tierName, tierColor, reward, kills)
    -- Mini popup
    local popup = Instance.new("TextLabel")
    popup.Size = UDim2.new(0, 400, 0, 60)
    popup.Position = UDim2.new(0.5, -200, 0.3, 0)
    popup.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    popup.BackgroundTransparency = 0.15
    popup.Text = mobName .. " -> " .. tierName .. "!  +" .. reward .. " coins"
    popup.TextColor3 = tierColor
    popup.Font = Enum.Font.GothamBold
    popup.TextSize = 18
    popup.Parent = gui
    Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", popup).Color = tierColor

    TweenService:Create(popup, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Position = UDim2.new(0.5, -200, 0.25, 0) }):Play()

    task.delay(3, function()
        local fade = TweenService:Create(popup, TweenInfo.new(0.5), { BackgroundTransparency = 1, TextTransparency = 1 })
        fade:Play()
        fade.Completed:Connect(function() popup:Destroy() end)
    end)
end)

-- Rebirth done notification
Remotes:WaitForChild("RebirthDone").OnClientEvent:Connect(function(rebirths, mult, nextCost)
    if currentTab == "rebirth" then
        openRebirthTab() -- Refresh
    end
end)

-- OpenShop tambem abre o menu na aba loja (trigger da loja no estadio)
Remotes:WaitForChild("OpenShop").OnClientEvent:Connect(function()
    openTab("shop")
end)

print("[MainMenuClient] Menu principal carregado! (Loja / Rebirth / Indice)")
